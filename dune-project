(lang dune 2.3)

(name spatial_index)
(version 0.0.2)

(generate_opam_files true)



(source (github aluuu/spatial_index))
(license BSD-3-Clause)
(authors "Aleksandr Dinu")
(maintainers "aluuu@husa.su")

(package
 (name spatial_index)
 (synopsis " Implementation of several spatial indexes (R-tree, etc.)")
 (depends
  (dune (= 2.3.1))
  (ocaml (< 4.08.0))
  (ounit2 :with-test)
  (spawn (= v0.12.0))
  (core (< v0.12.0))))
