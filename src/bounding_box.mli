open Core.Std
open Bounding_box_intf

module type Numeric =
  sig
    type t
    val zero: t
    val (+): t -> t -> t
    val (-): t -> t -> t
    val ( * ): t -> t -> t
    val min: t -> t -> t
    val max: t -> t -> t
  end

module Make (Num: Numeric) : S with type a = Num.t
