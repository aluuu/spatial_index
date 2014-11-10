include RTree

module type Boundable =
  sig
    type t
    val bounding_box: t -> BoundingBox.t
  end

module Make(B: Boundable) =
  struct
    type a = B.t
    type t = a RTree.t
    let empty = RTree.empty
    let size = RTree.size
    let insert t a = RTree.insert t (B.bounding_box a) a
    let search = RTree.search
    let delete = RTree.delete
  end
