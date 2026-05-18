# How to validate CMake FindMPI

## Goal

Confirm that CMake detects the MPI implementation intended by the JACI `spack-stack` environment.

## Why this matters

On JACI, CrayPE uses `cc`, `CC` and `ftn`, while some build systems expect traditional MPI wrapper names. This validation checks whether the stack exposes a consistent MPI interface to CMake.

## Suggested checks

```bash
which cc CC ftn
which mpicc mpicxx mpifort
mpicc -show || true
mpicxx -show || true
mpifort -show || true
```

Then run the repository validation script:

```bash
bash scripts/05_validate_cmake_findmpi.sh
```

## Success criteria

- CMake completes configuration.
- The detected C, C++ and Fortran MPI compilers match the intended JACI wrapper strategy.
- The output is stored with the validation logs.
