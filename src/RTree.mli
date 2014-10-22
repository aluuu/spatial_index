open Core.Std

module BoundingBox: sig
  type c = float * float
  type t = c * c
  val empty: t
  val area: t -> float
  val overlaps: t -> t -> bool
  val union: t -> t -> t
  val union_many: t list -> t
end

type 'a t = Empty |
            Node of (BoundingBox.t * 'a t) list |
            Leaf of (BoundingBox.t * 'a) list

val empty_node: BoundingBox.t * 'a t

val bounding_box_of_nodes: (BoundingBox.t * 'b) list -> BoundingBox.t

val bounding_box_delta: BoundingBox.t -> BoundingBox.t -> float

val bounding_box_distance:
  (BoundingBox.t * 'b) -> (BoundingBox.t * 'b) -> float

val size: 'a t -> int

val partition_by_min_delta:
  (BoundingBox.t * 'a t) list -> BoundingBox.t ->
  (BoundingBox.t * 'a t) * (BoundingBox.t * 'a t) list

val quadratic_split:
  (BoundingBox.t * 'a) list ->
  (BoundingBox.t * (BoundingBox.t * 'a) list) *
    (BoundingBox.t * (BoundingBox.t *'a) list)

val insert':
  'a t -> BoundingBox.t -> 'a ->
  (BoundingBox.t * 'a t) * (BoundingBox.t * 'a t)

val insert: 'a t -> BoundingBox.t -> 'a -> 'a t

val delete: 'a t -> 'a -> 'a t

val search: 'a t -> BoundingBox.t -> 'a list
