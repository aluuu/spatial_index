This is the INSTALL file for the spatial_index distribution.

Dependencies
============

In order to compile this package, you will need:

* ocaml
* dune for executing builds
* core for library spatial_index
* ounit2 for executable `test`

Installing
==========

If you are using [OPAM](http://opam.ocaml.org/):

1. Run `opam install spatial_index`

In other case:

1. Uncompress the source archive and go to the root of the package
2. Run `dune build`

Testing
=======

1. Uncompress the source archive and go to the root of the package
2. Run `dune runtest`
