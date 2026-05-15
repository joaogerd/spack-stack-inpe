# JACI MPAS-JEDI GCC 13 Cray MPICH environment

## Purpose

This directory is intended to store the `spack.yaml` environment definition for the JACI MPAS-JEDI stack using:

```text
spack-stack release/2.1
PrgEnv-gnu/8.6.0
gcc-native/13.2
cray-mpich/8.1.31
```

## Context

This environment is the stack-level environment expected to provide the scientific libraries and tools required by MONAN/MPAS-JEDI. It should not contain MONAN-bundle source code or MPAS-JEDI build products.

## Validation status

The GCC 12.3 diagnostic baseline was validated in the discovery workflow. This GCC 13.2 environment is the intended institutional target, but still requires a full spack-stack installation and MPAS-JEDI validation run.

## How to use

After copying the JACI site configuration into the JCSDA `spack-stack` tree, copy this `spack.yaml` into an environment directory, for example:

```bash
mkdir -p <spack-stack>/envs/jaci-mpas-jedi-gcc13-craympich
cp envs/jaci/mpas-jedi-gcc13-craympich/spack.yaml \
   <spack-stack>/envs/jaci-mpas-jedi-gcc13-craympich/spack.yaml
```

Then activate and concretize from the JCSDA `spack-stack` tree.

## Open items

1. Replace the skeleton `spack.yaml` with the actual environment definition derived from the validated stack.
2. Confirm exact package list for the GCC 13.2 target.
3. Confirm module generation and environment name.
4. Re-run MONAN/MPAS-JEDI validation using this target.
