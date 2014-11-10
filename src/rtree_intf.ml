include Rtree

module type Boundable =
  sig
    type t
    val bounding_box: t -> Bounding_box.t
  end

module Make(B: Boundable) =
  struct
    type a = B.t
    type t = a Rtree.t
    let empty = Rtree.empty
    let size = Rtree.size
    let insert t a = Rtree.insert t (B.bounding_box a) a
    let search = Rtree.search
    let delete = Rtree.delete
  end
