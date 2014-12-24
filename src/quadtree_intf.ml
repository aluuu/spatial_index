module type Tree_S =
  sig
    type p

    type 'a t = Empty |
                Node of (bb * 'a t) list |
                Leaf of (bb * 'a) list

    val empty: 'a t

    val size: 'a t -> int

    val insert: 'a t -> p -> 'a -> 'a t

    val search: 'a t -> p -> 'a list
  end

module type S =
  sig
    module Tree: Tree_S
    type a
    type t
    val empty: t
    val size: t -> int
    val insert: t -> a -> t
    val search: t -> Point.t -> a list
  end

module type Quadtree_params =
  sig
    type t
    module Point: Point_intf.S
    val point: t -> Point.t
  end
