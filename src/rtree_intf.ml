module type Boundable =
  sig
    type t
    val bounding_box: t -> Bounding_box.t
  end

module type Rtree_params =
  sig
    val max_nodes: int
  end
