open Core
open Bounding_box_intf

module Make (Num: Numeric_S) =
  struct
    type a = Num.t [@@deriving show, eq]
    type c = a * a [@@deriving show, eq]
    type t = c * c [@@deriving show, eq]

    module Num = Num

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

    let delta bb bb' =
      let open Num in
      (area (union bb bb')) - (area bb)

    let distance bb bb' =
      let open Num in
      (area (union bb bb')) - (area bb) - (area bb')
  end

module FloatCoordinate = struct
  include Core.Float
  type t = Core.Float.t [@@deriving show, eq]
end

module Bounding_box = Make(FloatCoordinate)

include Bounding_box
