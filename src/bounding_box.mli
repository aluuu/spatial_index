open Bounding_box_intf

module Make (Num: Numeric_S) : S
       with module Num = Num
       with type a = Num.t

module Num: Numeric_S with type t = float
type a = Num.t
type c = a * a
type t = c * c
val empty: t
val area: t -> a
val overlaps: t -> t -> bool
val union: t -> t -> t
val union_many: t list -> t
val delta: t -> t -> a
val distance: t -> t -> a
