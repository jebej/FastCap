# FastCap.jl

FastCap.jl is a package meant to make it easier to create FastCap meshes and run
the program itself to extract the capacitance matrix. Note that on Windows,
the [FastFieldSolvers](http://www.fastfieldsolvers.com/) (FastCap2) and/or the
[Whiteley Research](http://www.wrcad.com/freestuff.html) version of fastcap
should be installed (in the later case, fastcap.exe should be on the path).

FastCap.jl has not yet been tested on Linux or MacOS, although I will try to
fix this.

FastCap.jl includes a few functions to help making meshes using
[Gmsh](http://gmsh.info/). This requires gmsh to be on the path.

No documentation is available for now, but the examples should be
fairly self explanatory.
