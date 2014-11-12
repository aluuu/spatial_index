This is the INSTALL file for the spatial_index distribution.

This package uses OASIS to generate its build system. See section OASIS for
full information.

Dependencies
============

In order to compile this package, you will need:

* ocaml for all
* findlib
* core for library spatial_index
* oUnit for executable `test`

Installing
==========

If you are using [OPAM](http://opam.ocaml.org/):

1. Run `opam install spatial_index`

In other case:

1. Uncompress the source archive and go to the root of the package
2. Run 'ocaml setup.ml -configure'
3. Run 'ocaml setup.ml -build'
4. Run 'ocaml setup.ml -install'

Testing
=======

1. Uncompress the source archive and go to the root of the package
2. Run 'ocaml setup.ml -configure --enable-tests'
3. Run 'ocaml setup.ml -build'
4. Run 'ocaml setup.ml -test'

Uninstalling
============

1. Go to the root of the package
2. Run 'ocaml setup.ml -uninstall'

OASIS
=====

OASIS is a program that generates a setup.ml file using a simple '_oasis'
configuration file. The generated setup only depends on the standard OCaml
installation: no additional library is required.
