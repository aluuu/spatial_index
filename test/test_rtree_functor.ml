open Core.Std
open OUnit
open Spatial_index

type sample_type = Sample of string * Bounding_box.t

module SampleRTree = Rtree_intf.Make(struct
                                 type t = sample_type
                                 let bounding_box (Sample (_, bb)) = bb
                               end)

open SampleRTree

let test_samples = [
  Sample ("a", ((0., 0.), (10., 10.)));
  Sample ("b", ((2., 2.), (4., 4.)));
  Sample ("c", ((5., 5.), (10., 10.)));
  Sample ("d", ((1., 1.), (2., 2.)));
  Sample ("e", ((0., 3.), (10., 7.)));
  Sample ("f", ((3., 0.), (4., 10.)))
];;

let test_insert () =
    let tree =
    List.fold_left test_samples ~init:empty ~f:insert in
  assert_equal (size tree) 6

let test_lookup () =
  let tree =
    List.fold_left test_samples ~init:empty ~f:insert in
  let found_1 = search tree ((0., 0.), (2., 2.)) in
  let found_2 = search tree ((9., 9.), (10., 10.)) in
  let found_3 = search tree ((5., 5.), (6., 6.)) in
  let found_4 = search tree ((3., 3.), (4., 5.)) in

  let lookup el samples =
    let found = (List.find ~f:(fun (Sample (v, _)) -> (v = el)) samples) in
    match found with
    | None -> None
    | Some (Sample (v, _)) -> Some v
  in

  assert_equal (Some "a") (lookup "a" found_1);

  assert_equal (Some "a") (lookup "a" found_2);
  assert_equal (Some "c") (lookup "c" found_2);

  assert_equal (Some "a") (lookup "a" found_3);
  assert_equal (Some "e") (lookup "e" found_3);
  assert_equal (Some "c") (lookup "c" found_3);

  assert_equal (Some "a") (lookup "a" found_4);
  assert_equal (Some "e") (lookup "e" found_4);
  assert_equal (Some "f") (lookup "f" found_4)

let test_delete () =
  failwith "not implemented"

let test =
  "RTree functor" >::: [
    "insert" >:: test_insert;
    "lookup" >:: test_lookup;
    "delete" >:: test_delete
  ];;
