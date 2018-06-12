# pipromela

PiPromela : open reconfigurable systems in Promela

Overview
========

PiPromela is an experiment to enhance the Promela modelling language with name-passing features and an observational theory. The objective is to be able to model and verify behavioral properties of *reconfigurable systems*, i.e. systems whose (communication) structure evolves over time.

In comparison to the Promela that considers so-called *closed systems*, the objective is to model *open systems* which means that the environment is not modelled explicitly.

Put in other words, PiPromela is Promela extended with (the main features of) the pi-calculus.

First steps
===========

The spin model checker must be installed first, cf. http://spinroot.com/spin/whatispin.html

Then, in a text editor any file of the `examples/` directory can be edited.


=====
PiPromela is Copyright (C) 2018 Frédéric Peschanski under the MIT License

