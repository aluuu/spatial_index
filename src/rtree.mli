open Core.Std

module Bounding_box: sig
  type c = float * float
  type t = c * c
  val empty: t
  val area: t -> float
  val overlaps: t -> t -> bool
  val union: t -> t -> t
  val union_many: t list -> t
end

type 'a t = Empty |
            Node of (Bounding_box.t * 'a t) list |
            Leaf of (Bounding_box.t * 'a) list

val empty: 'a t

val empty_node: Bounding_box.t * 'a t

val bounding_box_of_nodes: (Bounding_box.t * 'b) list -> Bounding_box.t

val bounding_box_delta: Bounding_box.t -> Bounding_box.t -> float

val bounding_box_distance:
  (Bounding_box.t * 'b) -> (Bounding_box.t * 'b) -> float

val size: 'a t -> int

val partition_by_min_delta:
  (Bounding_box.t * 'a t) list -> Bounding_box.t ->
  (Bounding_box.t * 'a t) * (Bounding_box.t * 'a t) list

val quadratic_split:
  (Bounding_box.t * 'a) list ->
  (Bounding_box.t * (Bounding_box.t * 'a) list) *
    (Bounding_box.t * (Bounding_box.t *'a) list)

val insert': ?max_nodes:(int) -> 'a t -> Bounding_box.t -> 'a ->
             (Bounding_box.t * 'a t) * (Bounding_box.t * 'a t)

val insert: ?max_nodes:(int) -> 'a t -> Bounding_box.t -> 'a -> 'a t

val search: 'a t -> Bounding_box.t -> 'a list
