open Core.Std
open OUnit
open Spatial_index.Rtree

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
  let records = [
    ("a", ((0., 0.), (10., 10.)));
    ("b", ((2., 2.), (4., 4.)));
    ("c", ((5., 5.), (10., 10.)));
    ("d", ((1., 1.), (2., 2.)));
    ("e", ((0., 3.), (10., 7.)));
    ("f", ((3., 0.), (4., 10.)))
  ] in
  let tree =
    List.fold_left records ~init:Empty ~f:(fun t (r, bb) -> insert t bb r) in
  assert_equal (size tree) 6

let test_lookup () =
  let records = [
    ("a", ((0., 0.), (10., 10.)));
    ("b", ((2., 2.), (4., 4.)));
    ("c", ((5., 5.), (10., 10.)));
    ("d", ((1., 1.), (2., 2.)));
    ("e", ((0., 3.), (10., 7.)));
    ("f", ((3., 0.), (4., 10.)))
  ] in
  let tree =
    List.fold_left records ~init:Empty ~f:(fun t (r, bb) -> insert t bb r) in
  let found_1 = search tree ((0., 0.), (2., 2.)) in
  let found_2 = search tree ((9., 9.), (10., 10.)) in
  let found_3 = search tree ((5., 5.), (6., 6.)) in
  let found_4 = search tree ((3., 3.), (4., 5.)) in
  let lookup el = (List.find ~f:((=) el)) in

  assert_equal (Some "a") (lookup "a" found_1);

  assert_equal (Some "a") (lookup "a" found_2);
  assert_equal (Some "c") (lookup "c" found_2);

  assert_equal (Some "a") (lookup "a" found_3);
  assert_equal (Some "e") (lookup "e" found_3);
  assert_equal (Some "c") (lookup "c" found_3);

  assert_equal (Some "a") (lookup "a" found_4);
  assert_equal (Some "e") (lookup "e" found_4);
  assert_equal (Some "f") (lookup "f" found_4)

let test =
  "Rtree" >::: [
    "simple search" >:: test_simple_search;
    "insert" >:: test_insert;
    "lookup" >:: test_lookup;
  ];;
