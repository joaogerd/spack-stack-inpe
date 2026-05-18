# How to configure JACI

## Goal

Prepare the JACI site configuration for use with JCSDA `spack-stack`.

## Diagnostic commands

```bash
uname -a
lscpu
module avail
module list
which cc CC ftn
which qsub mpirun
env | sort
```

## Configuration areas

- CrayPE module setup.
- GNU programming environment.
- Cray MPICH external provider.
- Project filesystem paths.
- Tcl module generation.
- CMake `FindMPI` validation.

## Important rule

JACI must be configured from JACI observations. Do not copy machine values from EGEON, Derecho, Hera, Orion or any other system without validation.
