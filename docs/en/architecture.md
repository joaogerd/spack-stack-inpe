# Architecture

`spack-stack-inpe` follows a strict separation between infrastructure, stack creation and application workflows.

## Repository responsibilities

```text
configs/   -> site and environment definitions
scripts/   -> operational stack preparation and validation
docs/      -> user, maintainer and developer documentation
tests/     -> smoke tests and validation helpers
```

## Stack versus workflow

```text
JACI modules + CrayPE
        |
        v
configs/sites/tier2/jaci
        |
        v
JCSDA spack-stack release/2.1
        |
        v
validated modules and packages
        |
        v
MONAN-JEDI / MPAS-JEDI workflows
```

The repository stops at the validated stack. Build and test workflows for MONAN/JEDI or MPAS-JEDI belong in separate repositories.

## Main architectural decision

The JACI configuration needs a Cray MPICH overlay because Spack packages may request `self.spec["mpi"].mpicc`, while CrayPE expects `cc`, `CC` and `ftn` as the active compiler drivers.
