# How to use external packages

## Goal

Declare packages already provided by the HPC system as Spack externals when rebuilding them is not required.

## Typical external candidates

- MPI provided by the machine.
- System compilers.
- Python provided by the site.
- Math libraries provided by the machine.
- Basic tools required during bootstrap.

## Risks

External packages can introduce ABI, compiler, MPI or module inconsistencies. Always validate that the external package matches the selected compiler and MPI stack.

## JACI note

On JACI, `cray-mpich` is provided by the machine. The documented overlay strategy exists because some Spack recipes expect wrapper names such as `mpicc`, `mpicxx` and `mpifort`, while CrayPE uses `cc`, `CC` and `ftn`.
