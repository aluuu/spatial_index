open Spatial_index

module IntCoordinate = struct
  include Core.Int
  type t = Core.Int.t [@@deriving show, eq]
  let show = Format.asprintf "%a" pp
end

module Bounding_box_int = Bounding_box.Make(IntCoordinate)

open Bounding_box_int

let bounding_box: t Alcotest.testable = Alcotest.(pair (pair int int) (pair int int))

let test_overlap () =
  let bb1 = ((0, 0), (500, 500)) in
  let bb2 = ((10, 10), (20, 20)) in
  Alcotest.(check bool) "two bounding boxes overlap" true (overlaps bb1 bb2)

let test_exact_overlap () =
  let bb1 = ((0, 0), (100, 100)) in
  let bb2 = ((0, 0), (100, 100)) in
  Alcotest.(check bool) "two exactly equal bounding boxes overlap" true (overlaps bb1 bb2)

let test_doesnt_overlap_1 () =
  let bb1 = ((1, 1), (100, 100)) in
  let bb2 = ((0, 0), (100, 100)) in
  Alcotest.(check bool) "two bounding boxes don't overlap" false (overlaps bb1 bb2)

let test_doesnt_overlap_2 () =
  let bb1 = ((10, 0), (100, 100)) in
  let bb2 = ((110, 0), (200, 100)) in
  Alcotest.(check bool) "two bounding boxes don't overlap" false (overlaps bb1 bb2)

let test_doesnt_overlap_3 () =
  let bb1 = ((-10, 0), (-100, 100)) in
  let bb2 = ((110, 0), (200, 100)) in
  Alcotest.(check bool) "two bounding boxes don't overlap" false (overlaps bb1 bb2)

let test_area () =
  let bb = ((0, 0), (10, 10)) in
  Alcotest.(check int) "area is correct" 100 (area bb)

let test_union () =
  let bb1 = ((9, 0), (10, 10)) in
  let bb2 = ((-1, -10), (0, 0)) in
  let bb = ((-1, -10), (10, 10)) in
  Alcotest.(check bounding_box) "union contains both bounding boxes" bb (union bb1 bb2)

let test_union_many () =
  let bb1 = ((9, 0), (10, 10)) in
  let bb2 = ((-1, -10), (0, 0)) in
  let bb3 = ((-10, -10), (0, 0)) in
  let bb = ((-10, -10), (10, 10)) in
  Alcotest.(check bounding_box) "union contains all bounding boxes" bb (union_many [bb1; bb2; bb3])

let tests =
  let open Alcotest in
  [
    test_case "Overlap (happy case)" `Quick test_overlap;
    test_case "Overlap (disjoint 1)" `Quick test_doesnt_overlap_1;
    test_case "Overlap (disjoint 2)" `Quick test_doesnt_overlap_2;
    test_case "Overlap (disjoint 3)" `Quick test_doesnt_overlap_3;
    test_case "Area" `Quick test_area;
    test_case "Union" `Quick test_union;
    test_case "Union of mulitple" `Quick test_union_many;
  ]
