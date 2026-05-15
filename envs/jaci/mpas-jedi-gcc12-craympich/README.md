# JACI MPAS-JEDI GCC 12 Cray MPICH environment

## Purpose

This directory stores the target `spack.yaml` environment definition for the currently validated JACI MPAS-JEDI stack.

## Context

This environment is intended for use with the JACI site configuration under:

```text
configs/sites/tier2/jaci/
```

The validated baseline uses:

```text
spack-stack release/2.1
PrgEnv-gnu/8.6.0
gcc-native/12.3
cray-mpich/8.1.31
CrayPE drivers cc, CC, ftn
```

## Validation status

This compiler/MPI target is the current validated baseline from the discovery workflow.

A reduced MPAS-JEDI-only workflow was built and tested with this stack, producing:

```text
61/62 MPAS-JEDI tests passed
1 stable numerical reference mismatch: mpasjedi_lgetkf_height_vloc
```

The remaining failure was reproducible and classified as a platform-specific numerical reference mismatch, not an infrastructure failure.

## How to use

After copying the JACI site configuration into the JCSDA `spack-stack` tree, copy this `spack.yaml` into an environment directory, for example:

```bash
mkdir -p <spack-stack>/envs/jaci-mpas-jedi-gcc12-craympich
cp envs/jaci/mpas-jedi-gcc12-craympich/spack.yaml \
   <spack-stack>/envs/jaci-mpas-jedi-gcc12-craympich/spack.yaml
```

Then activate and concretize from the JCSDA `spack-stack` tree.

## Open items

1. Replace the skeleton `spack.yaml` with the exact environment definition from the validated JACI stack.
2. Confirm whether the final environment name should remain `jaci-mpas-jedi-gcc12-craympich` or follow an institutional naming convention.
3. Preserve the GCC 13.2 environment only as experimental until Cray MPICH support is clarified.
