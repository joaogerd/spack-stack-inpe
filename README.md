# spack-stack-inpe

INPE site configuration and operational documentation for using the JCSDA `spack-stack` on INPE HPC systems.

The initial validated target remains the JACI machine, using the JCSDA `spack-stack` `release/2.1` branch with CrayPE and Cray MPICH. The repository is organized to support additional INPE machines/sites without mixing site-specific rules with generic workflow logic.

## Purpose

This repository stores INPE site configurations and operational procedures required to build and validate JCSDA-defined `spack-stack` environments on INPE machines.

The conceptual boundary is:

```text
JCSDA spack-stack = defines the scientific software environment
INPE spack-stack-inpe = defines how that environment is built on INPE machines
```

It is intended to contain:

```text
- site configuration files following the JCSDA spack-stack layout;
- ready-to-use YAML files for each site configuration;
- site setup.sh files for loading machine-specific environments;
- site.env files with script-level defaults for each machine;
- reusable scripts for preparation, installation and validation;
- site-specific helper scripts when required;
- Portuguese and English operational documentation;
- stack-level validation notes.
```

This repository is not intended to store MONAN, MPAS-JEDI, `jedi-bundle`, or a copied JCSDA environment definition. The JEDI/MPAS-JEDI package set should come from the selected JCSDA `spack-stack` release and template.

## Repository layout

```text
spack-stack-inpe/
├── configs/
│   └── sites/
│       └── tier2/
│           └── jaci/
│               ├── config.yaml
│               ├── mirrors.yaml
│               ├── modules.yaml
│               ├── packages.yaml
│               ├── packages_gcc-12.3.yaml
│               ├── packages_gcc-13.2.yaml
│               ├── setup.sh
│               ├── site.env
│               └── README.md
├── scripts/
│   ├── 01_prepare_jaci_stack.sh
│   ├── 02_install_packages.sh
│   ├── 03_generate_tcl_modules.sh
│   ├── 04_validate_environment.sh
│   ├── 05_validate_cmake_findmpi.sh
│   ├── 06_collect_logs.sh
│   ├── create_craype_mpi_overlay.sh
│   ├── lib/
│   │   └── common.sh
│   └── sites/
│       └── jaci/
│           └── load_base_environment.sh
└── docs/
    ├── ARCHITECTURE.md
    ├── ADDING_A_SITE.md
    ├── pt_BR/
    └── en/
```

## Separation of concepts

Generic logic lives in the numbered scripts and in:

```text
scripts/lib/common.sh
```

Site-specific values live under the site configuration and site script directories:

```text
configs/sites/tier2/jaci/site.env
configs/sites/tier2/jaci/*.yaml
configs/sites/tier2/jaci/setup.sh
scripts/sites/jaci/load_base_environment.sh
```

The JCSDA environment template is selected in `site.env` through variables such as:

```text
JCSDA_SITE_NAME
JCSDA_ENV_TEMPLATE
JCSDA_COMPILER
DEFAULT_ENV_NAME
```

The script uses `spack stack create env` from JCSDA `spack-stack` to generate the environment. The INPE repository does not maintain a separate `envs/` tree at this stage.

## Documentation

Architecture and site onboarding:

```text
docs/ARCHITECTURE.md
docs/ADDING_A_SITE.md
```

Portuguese documentation:

```text
docs/pt_BR/README.md
docs/pt_BR/JACI_STACK_BUILD_STEPS.md
```

English documentation:

```text
docs/en/README.md
docs/en/JACI_STACK_BUILD_STEPS.md
```

## JCSDA-compatible site layout

The JACI site files follow the JCSDA `spack-stack` convention:

```text
configs/sites/tier2/jaci/
├── config.yaml
├── mirrors.yaml
├── modules.yaml
├── packages.yaml
├── packages_gcc-12.3.yaml
├── packages_gcc-13.2.yaml
├── setup.sh
├── site.env
└── README.md
```

The `site.env` file is not a JCSDA `spack-stack` file. It is used by the scripts in this repository to define runtime defaults for the site.

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

The GCC 13.2 target is kept as experimental because, with the current JACI CrayPE configuration, `cray-mpich/8.1.31` exports the GNU 12.3 backend path:

```text
/opt/cray/pe/mpich/8.1.31/ofi/gnu/12.3
```

and not a GNU 13.2 backend path.

## Cray MPICH overlay

The repository uses a JACI-specific overlay for the external `cray-mpich` package.

This is required because some Spack recipes call attributes such as:

```python
self.spec["mpi"].mpicc
```

On CrayPE systems, directly using the raw Cray MPICH wrappers under `/opt/cray/pe/mpich/.../bin/mpicc` can fail. The overlay provides wrapper names expected by Spack, such as `mpicc`, `mpicxx` and `mpifort`, while internally delegating to the CrayPE compiler drivers:

```text
cc
CC
ftn
```

This avoids package-by-package patches for MPI consumers such as HDF5, FFTW, NetCDF, Parallel-NetCDF, ParallelIO, eckit and mpi4py.

## Manual workflow for JACI

The default site is `jaci`, so the current workflow remains:

```bash
cd /p/projetos/monan_das/${USER}/projects/spack-stack-inpe

git pull

export TEST_ID="spack-stack-inpe-validation-$(date -u +%Y%m%dT%H%M%SZ)"
export FRESH_INSTALL=1
export FORCE_SOURCE_BUILD=1
export INSTALL_JOBS=1
export SPACK_INSTALL_VERBOSE=1
export SPACK_INSTALL_FAIL_FAST=1

bash scripts/01_prepare_jaci_stack.sh
bash scripts/02_install_packages.sh
bash scripts/03_generate_tcl_modules.sh
bash scripts/04_validate_environment.sh
bash scripts/05_validate_cmake_findmpi.sh
bash scripts/06_collect_logs.sh
```

A future site can use the same numbered scripts by setting `SITE`:

```bash
SITE=<site-name> bash scripts/01_prepare_jaci_stack.sh
```

The first script still has `jaci` in the file name to preserve compatibility with the current documented procedure. The selected site is controlled by `SITE` and the corresponding `site.env`.

## Tagging policy

A validation tag should only be created after another member of the group successfully executes the complete procedure with a new `TEST_ID`, a fresh install tree and reviewed logs.

Suggested tag format:

```text
jaci-spack-stack-2.1-gcc12-craympich-YYYYMMDD
```

## Boundary with MONAN-bundle

This repository stops at the validated `spack-stack` environment.

The MONAN/MPAS-JEDI build and test workflow should consume this stack from a separate repository, for example:

```text
https://github.com/GAD-DIMNT-CPTEC/MONAN-bundle
```
