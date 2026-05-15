# Manual JACI spack-stack validation workflow

## Purpose

This directory contains the manual validation workflow for the INPE/JACI `spack-stack` configuration.

The workflow is intentionally split into phases so each step can be inspected, rerun and debugged independently.

## Recommended script names

The preferred names are:

```text
01_prepare_jaci_stack.sh
02_install_packages.sh
03_generate_tcl_modules.sh
04_validate_environment.sh
05_validate_cmake_findmpi.sh
06_collect_logs.sh
```

These names are clearer than the initial names because they describe the action performed by each phase instead of using generic names such as `create`, `testing` or `collect`.

## Meaning of each phase

```text
01_prepare_jaci_stack.sh
```

Creates or updates the JCSDA `spack-stack` tree, copies the INPE/JACI site configuration and environment files, activates the environment and runs concretization.

```text
02_install_packages.sh
```

Compiles and installs the concretized packages.

```text
03_generate_tcl_modules.sh
```

Generates Tcl modulefiles from the installed environment.

```text
04_validate_environment.sh
```

Loads the generated JEDI MPAS environment module and validates tools such as `cmake`, `ecbuild`, `python`, `nccmp`, `h5dump`, `mpi4py` and `netCDF4`.

```text
05_validate_cmake_findmpi.sh
```

Runs a minimal CMake `FindMPI` probe and verifies that MPI resolves to the CrayPE drivers `cc`, `CC` and `ftn`.

```text
06_collect_logs.sh
```

Collects and summarizes the logs from all phases.

## Fresh build policy

A true fresh package build requires a fresh install tree. Reusing the same install tree allows Spack to reuse already installed packages.

The preferred fresh-build command is:

```bash
export TEST_ID="spack-stack-inpe-fresh-$(date -u +%Y%m%dT%H%M%SZ)"
export FRESH_INSTALL=1
export FORCE_SOURCE_BUILD=1

bash scripts/manual/01_prepare_jaci_stack.sh
bash scripts/manual/02_install_packages.sh
bash scripts/manual/03_generate_tcl_modules.sh
bash scripts/manual/04_validate_environment.sh
bash scripts/manual/05_validate_cmake_findmpi.sh
bash scripts/manual/06_collect_logs.sh
```

## Notes

`FRESH_INSTALL=1` removes the selected `INSTALL_ROOT` before concretization.

`FORCE_SOURCE_BUILD=1` passes `--no-cache` to `spack install`, avoiding binary buildcache use where applicable.

Using a unique `TEST_ID` is the safest way to avoid reusing an old work tree, old logs or an old install tree.
