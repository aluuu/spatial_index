open Core.Std

type c = float * float

type t = c * c

let empty = ((0.0, 0.0), (0.0, 0.0))

let area ((x1, y1), (x2, y2)) = (x2 -. x1) *. (y2 -. y1)

let overlaps ((x1, y1), (x2, y2)) ((x1', y1'), (x2', y2')) =
  let x_overlap = x1 <= x1' && x1 <= x2' && x2 >= x1' && x2 >= x2' in
  let y_overlap = y1 <= y1' && y1 <= y2' && y2 >= y1' && y2 >= y2' in
  x_overlap && y_overlap

let union ((x1, y1), (x2, y2)) ((x1', y1'), (x2', y2')) =
  ((min x1 x1', min y1 y1'), (max x2 x2', max y2 y2'))

let union_many = function
  | [] -> empty
  | boxes -> List.fold_left boxes ~f:union ~init:(List.hd_exn boxes)
