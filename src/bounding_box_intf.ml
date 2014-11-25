module type Numeric_S =
  sig
    type t
    val zero: t
    val (+): t -> t -> t
    val (-): t -> t -> t
    val ( * ): t -> t -> t
    val (>=): t -> t -> bool
    val min: t -> t -> t
    val max: t -> t -> t
    val abs: t -> t
  end

module type S =
  sig
    module Num: Numeric_S
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
  end
