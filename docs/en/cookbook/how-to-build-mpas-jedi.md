# How to build MPAS-JEDI

## Goal

Use a validated `spack-stack-inpe` environment as the software base for MPAS-JEDI or MONAN/JEDI build workflows.

## Boundary

This repository does not own the MPAS-JEDI build workflow. The build should be executed from a separate repository such as `MONAN-JEDI` or `MONAN-bundle`.

## Expected flow

1. Create and validate the stack with `spack-stack-inpe`.
2. Record the validation identifier, for example `STACK_TEST_ID`.
3. Load the generated stack environment.
4. Move to the workflow repository.
5. Configure with CMake or ecbuild.
6. Build and run tests outside `spack-stack-inpe`.

## Validation

Before starting the application build, confirm:

```bash
module list
which cc CC ftn
which mpicc mpicxx mpifort
spack find
```
