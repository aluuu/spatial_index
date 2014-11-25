open OUnit

let rec flatten_list acc = function
  | [] -> acc
  | (TestCase _ as r)::rest -> flatten_list (r::acc) rest
  | (TestList l)::rest ->
    let acc = flatten_list acc l in
    flatten_list acc rest
  | (TestLabel (lbl,test))::rest ->
    flatten_list
      (TestLabel (lbl,flatten test)::acc)
      rest
and flatten = function
  | TestCase _ as res  -> res
  | TestLabel (s,test) -> TestLabel (s,flatten test)
  | TestList l -> TestList (List.rev (flatten_list [] l))

let all_tests () =
  flatten
    (TestList
       [Test_bounding_box.test;
        Test_rtree_functor.test])

let rec was_successful =
  function
  | [] -> true
  | RSuccess _::t
  | RSkip _::t ->
     was_successful t
  | RFailure _::_
  | RError _::_
  | RTodo _::_ ->
     false

let () =
  if (not
        (was_successful
           (run_test_tt_main
              (all_tests ()):OUnit.test_result list))) then
    exit 1
