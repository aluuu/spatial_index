open Core.Std

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

module Make (Num: Numeric) =
  struct
    type a = Num.t
    type c = a * a
    type t = c * c

    let empty = ((Num.zero, Num.zero), (Num.zero, Num.zero))

    let area ((x1, y1), (x2, y2)) =
      let open Num in
      (x2 - x1) * (y2 - y1)

    let overlaps ((x1, y1), (x2, y2)) ((x1', y1'), (x2', y2')) =
      let open Num in
      let x_overlap = x1' >= x1 && x2' >= x1 && x2 >= x1' && x2 >= x2' in
      let y_overlap = y1' >= y1 && y2' >= y1 && y2 >= y1' && y2 >= y2' in
      x_overlap && y_overlap

    let union ((x1, y1), (x2, y2)) ((x1', y1'), (x2', y2')) =
      let open Num in
      ((min x1 x1', min y1 y1'), (max x2 x2', max y2 y2'))

    let union_many = function
      | [] -> empty
      | boxes -> List.fold_left boxes ~f:union ~init:(List.hd_exn boxes)
  end

module Bounding_box =
  Make(struct
        type t = Float.t
        let zero = 0.0
        let (+) = Float.add
        let (-) = Float.sub
        let ( * ) = Float.scale
        let (>=) = (>=)
        let min = min
        let max = max
      end)

include Bounding_box
