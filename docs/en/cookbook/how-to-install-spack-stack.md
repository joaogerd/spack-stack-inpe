# How to install spack-stack

## Goal

Create a validated JACI `spack-stack` environment using the operational scripts provided by this repository.

## Prerequisites

- Access to JACI.
- Access to the project filesystem under `/p/projetos`.
- Git available.
- Environment Modules available.
- PBS/qsub and `mpirun` available.

## Commands

```bash
cd /p/projetos/monan_das/${USER}/projects

git clone https://github.com/joaogerd/spack-stack-inpe.git
cd spack-stack-inpe

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

## Expected result

A local, reproducible `spack-stack` environment is created and validated for JACI.

## Validation

Review the logs collected by `scripts/06_collect_logs.sh` and confirm that concretization, installation, module generation and CMake `FindMPI` validation completed successfully.
