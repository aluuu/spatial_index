open Core.Std
open OUnit
open SpatialIndex.RTree

let test_simple_search () =
  let tree =
    Node [
        (((0.0, 0.0), (100.0, 100.0)),
         Node [(((0.0, 0.0), (50.0, 50.0)),
                Leaf [(((0.0, 0.0), (50.0, 50.0)), "a")]);
               (((0.0, 0.0), (25.0, 25.0)),
                Leaf [(((0.0, 0.0), (25.0, 25.0)), "c")]);
               (((50.0, 50.0), (100.0, 100.0)),
                Leaf [(((50.0, 50.0), (100.0, 100.0)), "b")])]
      )] in
  let found = search tree ((10.0, 10.0), (12.0, 12.0)) in
  assert_equal found ["a"; "c"]

let test_insert () =
  let tree = Empty in
  let records = [
    ("a", ((0., 0.), (10., 10.)));
    ("b", ((2., 2.), (4., 4.)));
    ("c", ((5., 5.), (10., 10.)));
    ("d", ((1., 1.), (2., 2.)));
    ("e", ((0., 3.), (10., 7.)));
    ("f", ((3., 0.), (4., 10.)))
  ] in
  let tree =
    List.fold_left records ~init:tree ~f:(fun t (r, bb) -> insert t bb r) in
  assert_equal (size tree) 6

let test_lookup () =
  failwith "not implemented"

let test_delete () =
  failwith "not implemented"

let test =
  "RTree" >::: [
    "simple search" >:: test_simple_search;
    "insert" >:: test_insert;
    "lookup" >:: test_lookup;
    "delete" >:: test_delete
  ];;
