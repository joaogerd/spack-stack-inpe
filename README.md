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
├── packages_gcc-13.2.yaml
├── setup.sh
└── README.md
```

## Current status

The current repository contains the initial manual and skeleton site structure.

Confirmed baseline from previous validation:

```text
spack-stack release/2.1
PrgEnv-gnu/8.6.0
gcc-native/12.3
cray-mpich/8.1.31
CrayPE drivers cc, CC, ftn
```

Institutional target to validate next:

```text
spack-stack release/2.1
PrgEnv-gnu/8.6.0
gcc-native/13.2
cray-mpich/8.1.31
CrayPE drivers cc, CC, ftn
```

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
