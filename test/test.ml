let () =
  let open Alcotest in
  run "Spatial_index" [
      "Bounding box", Test_bounding_box.tests;
      "Bounding box (int coord)", Test_bounding_box_int.tests;
      "Rtree (functor)", Test_rtree_functor.tests;
    ]
