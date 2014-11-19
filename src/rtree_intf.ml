include Rtree

module type Boundable =
  sig
    type t
    val bounding_box: t -> Bounding_box.t
  end

module type Rtree_params =
  sig
    val max_nodes: int
  end

module Make(P: Rtree_params) (B: Boundable) =
  struct
    type a = B.t
    type t = a Rtree.t
    let empty = Rtree.empty
    let size = Rtree.size
    let insert t a = Rtree.insert ~max_nodes:P.max_nodes t (B.bounding_box a) a
    let search = Rtree.search
  end
