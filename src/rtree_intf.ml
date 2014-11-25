module type Tree_S =
  sig
    type bb

    type 'a t = Empty |
                Node of (bb * 'a t) list |
                Leaf of (bb * 'a) list

    val empty: 'a t

    val empty_node: bb * 'a t

    val bounding_box_of_nodes: (bb * 'b) list -> bb

    val size: 'a t -> int

    val partition_by_min_delta: (bb * 'a t) list -> bb -> (bb * 'a t) * (bb * 'a t) list

    val quadratic_split: (bb * 'a) list -> (bb * (bb * 'a) list) * (bb * (bb *'a) list)

    val insert': ?max_nodes:(int) -> 'a t -> bb -> 'a -> (bb * 'a t) * (bb * 'a t)

    val insert: ?max_nodes:(int) -> 'a t -> bb -> 'a -> 'a t

    val search: 'a t -> bb -> 'a list
  end

module type S =
  sig
    module Tree: Tree_S
    type a
    type t
    val empty: t
    val size: t -> int
    val insert: t -> a -> t
    val search: t -> Bounding_box.t -> a list
  end

module type Rtree_params =
  sig
    type t
    module Bounding_box: Bounding_box_intf.S
    val bounding_box: t -> Bounding_box.t
    val max_nodes: int
  end
