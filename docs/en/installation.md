# Installation

This page describes the operational procedure for creating and validating the JACI `spack-stack` environment.

## Recommended workspace

Use the institutional project filesystem, not `$HOME`, for builds, caches, install trees and logs:

```bash
cd /p/projetos/monan_das/${USER}/projects
```

## Validation-oriented workflow

```bash
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

## Success criteria

- The environment concretizes without errors.
- Packages install without errors.
- Tcl modules are generated.
- CMake `FindMPI` resolves the expected MPI wrappers.
- Logs are collected and preserved under the current `TEST_ID`.
