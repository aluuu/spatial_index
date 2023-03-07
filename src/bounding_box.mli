open Bounding_box_intf

module Make (Num: Numeric_S) : S
       with module Num = Num
       with type a = Num.t

module Num: Numeric_S with type t = Core.Float.t

type a = Num.t [@@deriving show, eq]
type c = a * a [@@deriving show, eq]
type t = c * c [@@deriving show, eq]
val empty: t
val area: t -> a
val overlaps: t -> t -> bool
val union: t -> t -> t
val union_many: t list -> t
val delta: t -> t -> a
val distance: t -> t -> a
