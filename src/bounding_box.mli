open Core.Std

type c = float * float

type t = c * c

val empty: t

val area: t -> float

val overlaps: t -> t -> bool

val union: t -> t -> t

val union_many: t list -> t