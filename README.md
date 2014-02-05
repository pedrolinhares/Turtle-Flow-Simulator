+=== TURTLE FLOW SIMULATOR (TFS) ===+
Developers: Pedro Henrique Linhares (pedrolmota@gmail.com)
            Wagner Queiroz (wagnerqb@gmail.com)
Institution:
            Laboratório de Desenvolvimento de Software Científico e Aplicado (LDSC)
            Laboratório de Engenharia, Exploração e Produção de Petróleo (LENEP)
            Universidade Estadual do Norte Fluminense Darcy Ribeiro (UENF)

License: GPLv3 or later
License URI: http://www.gnu.org/licenses/gpl-3.0.html
Copyright (C) 2013-2014

== Description ==

The TFS software is a reservoir simulator that is able to simulate the behaviour of an one-dimensional
single phase petroleum reservoir under production conditions.

The software presents a graphical interface where the user can configure the simulation parameters.
After that, the user can generate a set of configuration files needed by the simulator in order
to initiate the simulation. Finnished the simulation, the interface can present the results
through a set of graphics so the user can better understand the simulation.

== Dependencies ==
In order to build the TFS software, the following software are required:

* Qt 5.0 or higher with development libraries (specially the qmake tool)
* C++11
* Gnuplot 4.4 or higher (http://www.gnuplot.info)

== Building ==
You can build the TFS executable either by:

1. running the script build_all.sh:
    $ sh ./build_all.sh

2. running make as follows:
    $ make -f Makefile
    $ cd ./src/kernel
    $ make -f Makefile

The binaries are going to be generated in the bin/ folder at the root project.

== Running ==
To run the software you should execute it from the bin/ folder, from the project root directory do as follows:
    $ cd ./bin/
    $ ./tfs

== Examples ==
The tutorial folder contains two examples of the TFS software:

1. One-dimensional horizontal closed homogeneous reservoir.
2. Anticline two litology reservoir with specified pressure.

== Changelog ==

= 1.0 =
* Basic simulation of one-dimensional single phase petroleum reservoir implemented.
* Merged the interface and kernel.
* Created the kernel module.
* Created software interface.
