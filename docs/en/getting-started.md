# Getting started

This page gives a first orientation for users who need to understand what `spack-stack-inpe` provides before running any installation command.

## What you need to know

`spack-stack-inpe` is not an application workflow. It prepares and validates the software stack that MONAN/JEDI and MPAS-JEDI workflows consume later.

## Current active target

The active target is JACI:

```text
spack-stack release/2.1
CrayPE
Cray MPICH
PBS/qsub
Tcl environment modules
```

## Before installing

Confirm the machine context first:

```bash
uname -a
cat /etc/os-release
lscpu
module avail
module list
which cc CC ftn
which qsub mpirun
env | sort
```

Do not reuse values from EGEON, Derecho, Hera or any other machine unless they have been validated on the target system.
