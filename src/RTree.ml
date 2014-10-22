open Core.Std

module BoundingBox = BoundingBox

let max_nodes = 8

type 'a t = Empty |
            Node of (BoundingBox.t * 'a t) list |
            Leaf of (BoundingBox.t * 'a) list

let empty = Empty

let empty_node = (BoundingBox.empty, Empty)

let bounding_box_of_nodes nodes =
  BoundingBox.union_many (List.map ~f:(fun (bb, _) -> bb) nodes)

let bounding_box_delta bb bb' =
  (BoundingBox.area (BoundingBox.union bb bb')) -. BoundingBox.area bb

let bounding_box_distance (bb1, _) (bb2, _) =
  (BoundingBox.area (BoundingBox.union bb1 bb2)) -.
    (BoundingBox.area bb1) -. (BoundingBox.area bb2)

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
     let deltas =
       List.map
         ~f:(fun node -> (bounding_box_delta bb (fst node), node))
         nodes in
     let min_delta =
       deltas |> List.map ~f:fst |> List.reduce_exn ~f:min in
     let (_, min_delta_node) =
       deltas
       |> List.find_exn ~f:(Fn.compose ((=) min_delta) fst) in
     let others =
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
        ~f:(fun (n, n') -> ((bounding_box_distance n n'), (n, n'))) pairs in
    let max_distance =
      distances |> List.map ~f:fst |> List.reduce_exn ~f:max in
    let (_, (n, n')) =
      distances
      |> List.find_exn ~f:(Fn.compose ((=) max_distance) fst) in
    n, n' in
  let pick_next bb bb' = function
    (* originally `PickNext` in [1] *)
    | [] -> raise (Invalid_argument "can't pick from empty nodes list")
    | nodes ->
       let diff (bb'', _) =
         Float.abs
           ((bounding_box_delta bb bb'') -. (bounding_box_delta bb' bb'')) in
       let diffs = List.map ~f:(fun n -> (diff n, n)) nodes in
       let max_diff = diffs |> List.map ~f:fst |> List.reduce_exn ~f:max in
       let (_, max_diff_node) =
         diffs
         |> List.find_exn ~f:(Fn.compose ((=) max_diff) fst) in
       max_diff_node in
  let rec split ns_bb ns ms_bb ms = function
    | [] -> (ns_bb, ns), (ms_bb, ms)
    | nodes ->
       let (bb, _) as n = pick_next ns_bb ms_bb nodes in
       let nodes' = List.filter ~f:(Fn.compose not (phys_equal n)) nodes in
       let delta_n = bounding_box_delta bb ns_bb in
       let delta_m = bounding_box_delta bb ms_bb in
       if delta_n < delta_m then
         split (BoundingBox.union ns_bb bb) (n :: ns) ms_bb ms nodes'
       else
         split ns_bb ns (BoundingBox.union ms_bb bb) (n :: ms) nodes' in
  match nodes with
  | [] -> failwith "Can't split empty list"
  | _ ->
     let (((bb1, _) as s1), ((bb2, _) as s2)) = pick_seeds nodes in
     let rest = List.filter ~f:(fun n -> n <> s1 && n <> s2) nodes in
     split bb1 [s1] bb2 [s2] rest

let rec insert' tree bb record = match tree with
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

let insert tree bb record =
  match insert' tree bb record with
  | (_, n), (_, Empty) -> n
  | n, m -> Node [n; m]

let delete tree record =
  failwith "not implemented"

let rec search tree bb =
  let filter_overlapping bb nodes =
    List.filter ~f:(fun (bb', _) -> BoundingBox.overlaps bb' bb) nodes in
  match tree with
  | Empty -> []
  | Node nodes ->
     let overlapping = filter_overlapping bb nodes in
     let found = List.map ~f:(fun (_, n) -> search n bb) overlapping in
     List.concat found
  | Leaf records ->
     let overlapping = filter_overlapping bb records in
     List.map ~f:snd overlapping
