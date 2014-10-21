open Core.Std

module BoundingBox = BoundingBox

let max_nodes = 2


type 'a t = Empty |
            Node of (BoundingBox.t * 'a t) list |
            Leaf of (BoundingBox.t * 'a) list

let empty_node = (BoundingBox.empty, Empty)

let rec size = function
  | Empty -> 0
  | Leaf recs -> List.length recs
  | Node nodes ->
     let lens = List.map ~f:(fun (_, n) -> size n) nodes in
     List.fold_left lens ~init:0 ~f:(+)

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

let bounding_box_of_nodes nodes =
  BoundingBox.union_many (List.map ~f:(fun (bb, _) -> bb) nodes)

let bounding_box_delta bb bb' =
  (BoundingBox.area (BoundingBox.union bb bb')) -. BoundingBox.area bb

let partition_by_min_delta nodes bb =
  match nodes with
  | [] ->
     raise (Invalid_argument "cannot partition an empty node")
  | _ ->
     let deltas =
       List.map
         ~f:(fun node -> (bounding_box_delta bb (fst node), node))
         nodes in
     let min_delta = deltas |> List.map ~f:fst |> List.reduce_exn ~f:min in
     let (_, min_node) =
       deltas
       |> List.find_exn ~f:(fun (delta, _) -> phys_equal delta min_delta) in
     let others =
       deltas
       |> List.filter ~f:(fun (_, n) -> n <> min_node)
       |> List.map ~f:snd in
     min_node, others

let split_nodes nodes =
  failwith "not implemented"

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
          let (a_bb, a), (b_bb, b) = split_nodes nodes' in
          (a_bb, Node a), (b_bb, Node b)
     end
  | Leaf records ->
     begin
       let records' = (bb, record) :: records in
       match List.length records' > max_nodes with
       | true ->
          let (a_bb, a), (b_bb, b) = split_nodes records' in
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
