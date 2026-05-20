# Usage

This page explains how to use an already validated `spack-stack-inpe` environment.

## Load the validated stack

Use the activation script generated or documented for the selected validation run:

```bash
source <generated-stack-env-script>
```

Then inspect the generated module tree:

```bash
module avail
module list
```

## Load the expected modules

The exact module names depend on the validated installation. A typical JACI workflow should expose stack compiler, MPI and JEDI environment modules:

```bash
module load stack-gcc/<version>
module load stack-cray-mpich/<version>
module load jedi-mpas-env/<version>
```

## Verify before using

```bash
which cc CC ftn
which mpicc mpicxx mpifort
spack find
```

The MPI wrapper behavior is site-specific on JACI and must be consistent with the CrayPE overlay documented in the reference section.
