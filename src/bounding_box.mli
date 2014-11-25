open Core.Std
open Bounding_box_intf

module type Numeric =
  sig
    type t
    val zero: t
    val (+): t -> t -> t
    val (-): t -> t -> t
    val ( * ): t -> t -> t
    val (>=): t -> t -> bool
    val min: t -> t -> t
    val max: t -> t -> t
  end

module Make (Num: Numeric) : S with type a = Num.t

type a = float
type c = a * a
type t = c * c
val empty: t
val area: t -> a
val overlaps: t -> t -> bool
val union: t -> t -> t
val union_many: t list -> t
