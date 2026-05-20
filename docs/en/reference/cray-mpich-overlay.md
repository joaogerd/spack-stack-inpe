# Cray MPICH overlay

This page documents the JACI Cray MPICH overlay strategy.

## Problem

Some Spack package logic asks the MPI provider for traditional wrapper names such as:

```python
self.spec["mpi"].mpicc
```

On JACI with CrayPE loaded, the intended compiler drivers are:

```text
cc
CC
ftn
```

## Strategy

The overlay provides traditional wrapper names such as `mpicc`, `mpicxx` and `mpifort`, while internally delegating to the CrayPE drivers.

## Why it exists

This avoids adding local patches to many MPI-consuming packages.

## Validation

```bash
which mpicc mpicxx mpifort
mpicc -show || true
mpicxx -show || true
mpifort -show || true
which cc CC ftn
```

The output must be stored with the validation logs.

## Status

This is a site-specific operational solution for JACI and should be reviewed whenever the CrayPE or Cray MPICH environment changes.
