open Spatial_index.Bounding_box

let bounding_box: t Alcotest.testable = Alcotest.(pair (pair (float 0.) (float 0.)) (pair (float 0.) (float 0.)))

let test_overlap () =
  let bb1 = ((0.0, 0.0), (500.0, 500.0)) in
  let bb2 = ((10.0, 10.0), (20.0, 20.0)) in
  Alcotest.(check bool) "two bounding boxes overlap" true (overlaps bb1 bb2)

let test_exact_overlap () =
  let bb1 = ((0.0, 0.0), (100.0, 100.0)) in
  let bb2 = ((0.0, 0.0), (100.0, 100.0)) in
  Alcotest.(check bool) "two exactly equal bounding boxes overlap" true (overlaps bb1 bb2)

let test_doesnt_overlap_1 () =
  let bb1 = ((1.0, 1.0), (100.0, 100.0)) in
  let bb2 = ((0.0, 0.0), (100.0, 100.0)) in
  Alcotest.(check bool) "two bounding boxes don't overlap" false (overlaps bb1 bb2)

let test_doesnt_overlap_2 () =
  let bb1 = ((10.0, 0.0), (100.0, 100.0)) in
  let bb2 = ((110.0, 0.0), (200.0, 100.0)) in
  Alcotest.(check bool) "two bounding boxes don't overlap" false (overlaps bb1 bb2)

let test_doesnt_overlap_3 () =
  let bb1 = ((-10.0, 0.0), (-100.0, 100.0)) in
  let bb2 = ((110.0, 0.0), (200.0, 100.0)) in
  Alcotest.(check bool) "two bounding boxes don't overlap" false (overlaps bb1 bb2)

let test_area () =
  let bb = ((0., 0.), (10., 10.)) in
  Alcotest.(check (float 0.)) "area is correct" 100. (area bb)

let test_union () =
  let bb1 = ((9., 0.), (10., 10.)) in
  let bb2 = ((-1., -10.), (0., 0.)) in
  let bb = ((-1., -10.), (10., 10.)) in
  Alcotest.(check bounding_box) "union contains both bounding boxes" bb (union bb1 bb2)

let test_union_many () =
  let bb1 = ((9., 0.), (10., 10.)) in
  let bb2 = ((-1., -10.), (0., 0.)) in
  let bb3 = ((-10., -10.), (0., 0.)) in
  let bb = ((-10., -10.), (10., 10.)) in
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
