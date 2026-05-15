# Experimental JACI MPAS-JEDI GCC 13 Cray MPICH environment

## Purpose

This directory documents a possible GCC 13.2 MPAS-JEDI stack target for JACI.

It is intentionally marked as experimental and must not be treated as the production stack target.

## Context

The current validated JACI production target is:

```text
spack-stack release/2.1
PrgEnv-gnu/8.6.0
gcc-native/12.3
cray-mpich/8.1.31
CrayPE drivers cc, CC, ftn
```

The `gcc-native/13.2` module exists on JACI, but with `PrgEnv-gnu/8.6.0`, `gcc-native/13.2` and `cray-mpich/8.1.31` loaded, CrayPE still exports:

```text
CRAY_MPICH_DIR=/opt/cray/pe/mpich/8.1.31/ofi/gnu/12.3
CRAY_MPICH_PREFIX=/opt/cray/pe/mpich/8.1.31/ofi/gnu/12.3
```

The following path does not exist on JACI:

```text
/opt/cray/pe/mpich/8.1.31/ofi/gnu/13.2
```

Therefore, a GCC 13.2 target would currently be a hybrid configuration unless JACI provides a Cray MPICH backend compatible with GNU 13.2 or unless this hybrid path is explicitly validated.

## Validation status

Not validated.

This environment must not be used as the official JACI spack-stack target.

## How to use

Do not use this environment for production or institutional validation at this stage.

Use instead:

```text
envs/jaci/mpas-jedi-gcc12-craympich/
configs/sites/tier2/jaci/packages_gcc-12.3.yaml
```

## Open items

1. Confirm whether JACI will provide `/opt/cray/pe/mpich/8.1.31/ofi/gnu/13.2` or an equivalent GNU 13.2 Cray MPICH backend.
2. If not, decide whether a GCC 13.2 compiler with a GNU 12.3 Cray MPICH backend is acceptable as an explicit experimental path.
3. If this target is pursued, run a full spack-stack build and MONAN/MPAS-JEDI validation before promoting it.
