open Rtree_intf

module Tree (BB: Bounding_box_intf.S) : Tree_S
       with type bb = BB.t

module Make (P: Rtree_params) :
  sig
    module Tree: Tree_S
    type a = P.t
    type t = P.t Tree.t
    val empty: t
    val size: t -> int
    val insert: t -> a -> t
    val search: t -> P.Bounding_box.t -> a list
    val delete: t -> a -> t
  end
