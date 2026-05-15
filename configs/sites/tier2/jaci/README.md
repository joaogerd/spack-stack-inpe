# JACI site configuration

This directory stores the INPE/JACI site configuration for the JCSDA `spack-stack` layout.

The intended layout follows the upstream convention:

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

## Status

This site is being organized from the validated JACI discovery work.

Confirmed diagnostic baseline:

```text
spack-stack release/2.1
PrgEnv-gnu/8.6.0
gcc-native/12.3
cray-mpich/8.1.31
CrayPE drivers cc, CC, ftn
```

Target to validate:

```text
spack-stack release/2.1
PrgEnv-gnu/8.6.0
gcc-native/13.2
cray-mpich/8.1.31
CrayPE drivers cc, CC, ftn
```

## Critical CrayPE rule

When CrayPE is loaded, packages must build with:

```text
cc
CC
ftn
```

They must not force the raw Cray MPICH wrappers:

```text
mpicc
mpicxx
mpifort
```

The `setup.sh` file in this directory exports the compiler and MPI compiler variables accordingly.

## Open items

The YAML files in this directory are initial skeletons. They must be completed using the real validated JACI configuration before being treated as production-ready.
