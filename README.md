# spack-stack-inpe

INPE site configuration and operational notes for using the JCSDA `spack-stack` on INPE HPC systems.

The initial focus is the JACI machine, using the JCSDA `spack-stack` `release/2.1` branch with CrayPE and Cray MPICH.

## Scope

This repository is intended to store:

```text
- JACI site configuration files following the JCSDA spack-stack layout;
- ready-to-copy YAML files for the site configuration;
- a site `setup.sh` for loading the required CrayPE environment;
- manual build and validation instructions;
- stack-level validation notes.
```

This repository is not intended to store the MONAN/MPAS-JEDI source tree or the MPAS-JEDI build workflow. That belongs in the `MONAN-bundle` repository.

## Expected JCSDA-compatible layout

```text
configs/sites/tier2/jaci/
├── config.yaml
├── mirrors.yaml
├── modules.yaml
├── packages.yaml
├── packages_gcc-12.3.yaml
├── packages_gcc-13.2.yaml
├── setup.sh
└── README.md
```

## Current validated target

The current production target for JACI is:

```text
spack-stack release/2.1
PrgEnv-gnu/8.6.0
gcc-native/12.3
cray-mpich/8.1.31
CrayPE drivers cc, CC, ftn
Tcl modulefiles under $env/modules
```

This target was validated during the JACI discovery workflow and supported a reduced MPAS-JEDI-only build and PBS/PALS test execution.

The MPAS-JEDI validation status associated with this stack was:

```text
61/62 MPAS-JEDI tests passed
1 stable numerical reference mismatch: mpasjedi_lgetkf_height_vloc
```

The remaining failure was reproducible and classified as a platform-specific numerical reference mismatch, not an infrastructure failure.

## Experimental GCC 13.2 target

The `gcc-native/13.2` module exists on JACI, but it is not the current production target for this repository.

With `PrgEnv-gnu/8.6.0`, `gcc-native/13.2` and `cray-mpich/8.1.31` loaded, CrayPE still exports:

```text
CRAY_MPICH_DIR=/opt/cray/pe/mpich/8.1.31/ofi/gnu/12.3
CRAY_MPICH_PREFIX=/opt/cray/pe/mpich/8.1.31/ofi/gnu/12.3
```

The following path does not exist on JACI:

```text
/opt/cray/pe/mpich/8.1.31/ofi/gnu/13.2
```

Therefore, GCC 13.2 is kept only as an experimental/hybrid target until a compatible Cray MPICH backend is available or a full explicit validation is performed.

## Main documentation

Start with:

```text
docs/JACI_STACK_BUILD_STEPS.md
```

This document describes the manual procedure from loading the JACI base environment through creating, concretizing, installing and validating the `spack-stack` environment.

## Boundary with MONAN-bundle

This repository stops at the validated `spack-stack` environment.

The MONAN/MPAS-JEDI build and test workflow should consume this stack from:

```text
https://github.com/GAD-DIMNT-CPTEC/MONAN-bundle
```
