# spack-stack-inpe

INPE site configuration and operational documentation for using the JCSDA `spack-stack` on INPE HPC systems.

The initial validated target is the JACI machine, using the JCSDA `spack-stack` `release/2.1` branch with CrayPE and Cray MPICH.

## Purpose

This repository stores the INPE/JACI site configuration and the operational procedure required to build and validate a local `spack-stack` environment suitable for future MONAN/MPAS-JEDI work.

It is intended to contain:

```text
- JACI site configuration files following the JCSDA spack-stack layout;
- ready-to-use YAML files for the site configuration;
- a site setup.sh for loading the required CrayPE environment;
- scripts for manual installation and validation;
- Portuguese and English operational documentation;
- stack-level validation notes.
```

This repository is not intended to store the MONAN, MPAS-JEDI or `jedi-bundle` source tree. The MONAN/MPAS-JEDI build workflow should consume the validated stack from a separate repository, such as `MONAN-bundle`.

## Documentation

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

The main operational manual is available in both languages and describes the procedure from preparing the JACI `spack-stack` tree to validating the generated Tcl module environment and CMake/FindMPI behavior.

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
└── README.md
```

## Environment layout

The validated JACI environment is stored under:

```text
envs/jaci/mpas-jedi-gcc12-craympich/
├── spack.yaml
├── common/
└── site/
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

The GCC 13.2 target is kept as experimental because, with the current JACI CrayPE configuration, `cray-mpich/8.1.31` exports the GNU 12.3 backend path:

```text
/opt/cray/pe/mpich/8.1.31/ofi/gnu/12.3
```

and not a GNU 13.2 backend path.

## Cray MPICH overlay

The repository uses a global overlay for the external `cray-mpich` package.

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

## Manual workflow

The official workflow is split into six scripts:

```text
scripts/01_prepare_jaci_stack.sh
scripts/02_install_packages.sh
scripts/03_generate_tcl_modules.sh
scripts/04_validate_environment.sh
scripts/05_validate_cmake_findmpi.sh
scripts/06_collect_logs.sh
```

Recommended validation sequence:

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
