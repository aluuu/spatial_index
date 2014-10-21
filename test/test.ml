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
       [Test_boundingbox.test;
        Test_rtree.test])

let main () =
  ignore (run_test_tt_main
            (all_tests ()):OUnit.test_result list)

let () = Core.Exn.handle_uncaught ~exit:true main
