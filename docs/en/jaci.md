# JACI

JACI is the current active target for `spack-stack-inpe`.

## Confirmed technical direction

The current JACI line targets:

```text
spack-stack release/2.1
CrayPE
PrgEnv-gnu/8.6.0
cray-mpich/8.1.31
PBS/qsub
mpirun through Cray PALS
Tcl environment modules
```

## Filesystem policy

Builds, caches, install trees and logs should use the project filesystem, not `$HOME`:

```text
/p/projetos/<group>/<user>
```

For MONAN/DAS work:

```text
/p/projetos/monan_das/${USER}
```

## MPI wrapper policy

On CrayPE, the expected compiler drivers are:

```text
cc
CC
ftn
```

Some Spack packages ask the MPI provider for traditional wrapper names such as `mpicc`, `mpicxx` and `mpifort`. The JACI configuration therefore uses a Cray MPICH overlay/wrapper strategy so package recipes can find those names while the implementation delegates to the CrayPE drivers.

## Required validation

Every JACI validation should preserve:

- loaded modules;
- compiler paths;
- MPI wrapper paths;
- `spack concretize` logs;
- `spack install` logs;
- module generation logs;
- CMake `FindMPI` validation output.
