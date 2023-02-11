open Core
open Rtree_intf

module Tree (BB: Bounding_box_intf.S) =
  struct
    type bb = BB.t

    type 'a t = Empty |
                Node of (bb * 'a t) list |
                Leaf of (bb * 'a) list

    type op_result = Condense | Noop

    let empty = Empty

    let empty_node = (BB.empty, Empty)

    let bounding_box_of_nodes nodes =
      BB.union_many (List.map ~f:(fun (bb, _) -> bb) nodes)

    let rec size = function
      | Empty -> 0
      | Leaf recs -> List.length recs
      | Node nodes ->
         let lens = List.map ~f:(fun (_, n) -> size n) nodes in
         List.fold_left lens ~init:0 ~f:(+)

    let partition_by_min_delta nodes bb =
      match nodes with
      | [] ->
         raise (Invalid_argument "cannot partition an empty node")
      | _ ->
         let open BB.Num in
         let deltas =
           List.map
             ~f:(fun node -> (BB.delta bb (fst node), node))
             nodes in
         let min_delta =
           deltas |> List.map ~f:fst |> List.reduce_exn ~f:min in
         let (_, min_delta_node) =
           deltas
           |> List.find_exn ~f:(Fn.compose ((=) min_delta) fst) in
         let others =
           let open Core.Poly in
           deltas
           |> List.filter ~f:(fun (_, n) -> n <> min_delta_node)
           |> List.map ~f:snd in
         min_delta_node, others

    let quadratic_split nodes =
      (* originally `QuadraticSplit` in [1] *)

      let pick_seeds nodes =
        (* originally `PickSeeds` in [1] *)
        let pairs = List.cartesian_product nodes nodes in
        let distances =
          List.map
            ~f:(fun (((bb, _) as n), ((bb', _) as n')) ->
                ((BB.distance bb bb'), (n, n'))) pairs in
        let max_distance =
          distances |> List.map ~f:fst |> List.reduce_exn ~f:BB.Num.max in
        let (_, (n, n')) =
          distances
          |> List.find_exn ~f:(Fn.compose (BB.Num.(=) max_distance) fst) in
        n, n' in

      let pick_next bb bb' = function
        (* originally `PickNext` in [1] *)
        | [] -> raise (Invalid_argument "can't pick from empty nodes list")
        | nodes ->
           let diff (bb'', _) =
             BB.Num.abs (BB.Num.(-) (BB.delta bb bb'') (BB.delta bb' bb'')) in
           let diffs = List.map ~f:(fun n -> (diff n, n)) nodes in
           let max_diff = diffs |> List.map ~f:fst |> List.reduce_exn ~f:BB.Num.max in
           let (_, max_diff_node) =
             diffs
             |> List.find_exn ~f:(Fn.compose (BB.Num.(=) max_diff) fst) in
           max_diff_node in

      let rec split ns_bb ns ms_bb ms = function
        | [] -> (ns_bb, ns), (ms_bb, ms)
        | nodes ->
           let (bb, _) as n = pick_next ns_bb ms_bb nodes in
           let nodes' = List.filter ~f:(Fn.compose not (phys_equal n)) nodes in
           let delta_n = BB.delta bb ns_bb in
           let delta_m = BB.delta bb ms_bb in
           if BB.Num.(>=) delta_m delta_n then
             split (BB.union ns_bb bb) (n :: ns) ms_bb ms nodes'
           else
             split ns_bb ns (BB.union ms_bb bb) (n :: ms) nodes' in

      match nodes with
      | [] -> failwith "Can't split empty list"
      | _ ->
         let open Core.Poly in
         let (((bb1, _) as s1), ((bb2, _) as s2)) = pick_seeds nodes in
         let rest = List.filter ~f:(fun n -> n <> s1 && n <> s2) nodes in
         split bb1 [s1] bb2 [s2] rest

    let rec insert' ?max_nodes:(max_nodes=8) tree bb record = match tree with
      | Node nodes ->
         begin
           let (_, min_tree), other_trees =
             partition_by_min_delta nodes bb in
           match insert' min_tree bb record with
           | min_tree', (_, Empty) ->
              let nodes' = min_tree' :: other_trees in
              let bb' = bounding_box_of_nodes nodes' in
              (bb', Node nodes'), empty_node
           | min_tree', min_tree'' when (List.length other_trees + 2) < max_nodes ->
              let nodes' = min_tree' :: min_tree'' :: other_trees in
              let bb' = bounding_box_of_nodes nodes' in
              (bb', Node nodes'), empty_node
           | min_tree', min_tree'' ->
              let nodes' = min_tree' :: min_tree'' :: other_trees in
              let (a_bb, a), (b_bb, b) = quadratic_split nodes' in
              (a_bb, Node a), (b_bb, Node b)
         end
      | Leaf records ->
         begin
           let records' = (bb, record) :: records in
           match List.length records' > max_nodes with
           | true ->
              let (a_bb, a), (b_bb, b) = quadratic_split records' in
              (a_bb, Leaf a), (b_bb, Leaf b)
           | false ->
              let bb' = bounding_box_of_nodes records' in
              (bb', Leaf records'), empty_node
         end
      | Empty -> (bb, Leaf [(bb, record)]), empty_node

    let insert ?max_nodes:(max_nodes=8) tree bb record =
      match insert' ~max_nodes:max_nodes tree bb record with
      | (_, n), (_, Empty) -> n
      | n, m -> Node [n; m]

    let rec search tree bb =
      let filter_overlapping bb nodes =
        List.filter ~f:(fun (bb', _) -> BB.overlaps bb' bb) nodes in
      match tree with
      | Empty -> []
      | Node nodes ->
         let overlapping = filter_overlapping bb nodes in
         let found = List.map ~f:(fun (_, n) -> search n bb) overlapping in
         List.concat found
      | Leaf records ->
         let overlapping = filter_overlapping bb records in
         List.map ~f:snd overlapping

    let delete ?max_nodes:(max_nodes=8) tree bb record =
      let rec cleanup_node (bb: BB.t) (record: 'a) (t: 'a t) : (op_result * 'a t) =
        (* TODO: handle Condense *)
        match t with
        | Leaf records ->
           let (matched, rest) =
             records
             |> List.partition_map ~f:(fun (bba, a) ->
                    if (BB.equals bba bb) && (Poly.equal a record)
                    then First (bba, a)
                    else Second (bba, a))
           in
           if List.is_empty matched then
             (Noop, t)
           else begin
             match max_nodes < List.length rest with
             | true -> (Condense, Leaf rest)
             | false -> (Noop, Leaf rest)
             end
        | Node nodes ->
           let nodes = nodes
                       |> List.map ~f:(fun (node_bb, node) ->
                              let (_, node') = cleanup_node bb record node
                              in (node_bb, node'))
           in
           (Noop, Node nodes)
        | Empty -> (Noop, Empty)
      in
      match cleanup_node bb record tree with
      | (Condense, Node [(bb, Leaf [(_, r)])]) -> Leaf [(bb, r)]
      | (_, r) -> r
  end

module Make (P: Rtree_params) =
  struct
    module Tree = Tree (P.Bounding_box)
    type a = P.t
    type t = a Tree.t
    let empty = Tree.empty
    let size = Tree.size
    let insert t a = Tree.insert ~max_nodes:P.max_nodes t (P.bounding_box a) a
    let search = Tree.search
    let delete t a = Tree.delete ~max_nodes:P.max_nodes t (P.bounding_box a) a
  end
