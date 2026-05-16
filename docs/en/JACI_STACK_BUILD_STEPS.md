# JACI spack-stack build and validation manual

This document describes the operational procedure to prepare, concretize, build and validate a JCSDA `spack-stack` environment on the INPE JACI machine using the `spack-stack-inpe` repository.

The goal is to allow another member of the group to execute the full procedure reproducibly, without depending on previous local test history. After the procedure is repeated successfully by another user, the repository can be marked with a validation tag.

## 1. Scope

This repository contains only the INPE/JACI institutional configuration for use with the JCSDA `spack-stack`.

It includes:

```text
configs/sites/tier2/jaci/
envs/jaci/mpas-jedi-gcc12-craympich/
scripts/
docs/
```

This repository must not contain the MONAN, MPAS, MPAS-JEDI or `jedi-bundle` source tree. The MONAN/MPAS-JEDI build step should be handled in a separate repository, for example `MONAN-bundle`.

## 2. Validated target environment

The validated operational target is:

```text
spack-stack: release/2.1
site: configs/sites/tier2/jaci
environment: envs/jaci/mpas-jedi-gcc12-craympich
compiler: gcc-native/12.3
Cray environment: PrgEnv-gnu/8.6.0
MPI: cray-mpich/8.1.31
interconnect: libfabric/1.22.0
launcher: cray-pals/1.6.1
target architecture: craype-x86-turin
generated modules: Tcl
```

The use of `gcc-native/13.2` remains experimental in this repository, because the available `cray-mpich/8.1.31` on JACI exports its GNU backend at:

```text
/opt/cray/pe/mpich/8.1.31/ofi/gnu/12.3
```

and, at validation time, there is no corresponding backend at:

```text
/opt/cray/pe/mpich/8.1.31/ofi/gnu/13.2
```

## 3. Essential technical point: the cray-mpich overlay

In a CrayPE environment, packages should not directly use:

```text
/opt/cray/pe/mpich/.../bin/mpicc
/opt/cray/pe/mpich/.../bin/mpicxx
/opt/cray/pe/mpich/.../bin/mpifort
```

CrayPE expects MPI builds to use the compiler drivers:

```text
cc
CC
ftn
```

During the initial validation, we observed that Spack recipes, such as the `hdf5` recipe, may internally call:

```python
self.spec["mpi"].mpicc
```

If the external `cray-mpich` points directly to the real Cray MPICH prefix, this attribute resolves to the raw `mpicc` wrapper and fails under CrayPE.

The solution adopted in this repository is global: the script creates an overlay for the external `cray-mpich`. This overlay contains wrapper names expected by Spack:

```text
mpicc
mpicxx
mpic++
mpifort
mpif90
mpif77
```

but internally they call:

```text
/opt/cray/pe/craype/2.7.33/bin/cc
/opt/cray/pe/craype/2.7.33/bin/CC
/opt/cray/pe/craype/2.7.33/bin/ftn
```

As a result, any recipe using `self.spec["mpi"].mpicc` receives a controlled overlay path, without requiring package-specific patches in `hdf5`, `fftw`, `netcdf-c`, `parallel-netcdf`, `parallelio`, `eckit`, `mpi4py` or other MPI consumers.

## 4. Initial preparation

Log into JACI and clone or update the repository:

```bash
cd /p/projetos/monan_das/${USER}/projects

git clone https://github.com/joaogerd/spack-stack-inpe.git 2>/dev/null || true
cd spack-stack-inpe

git pull
```

Choose a new test identifier. For institutional validation, do not reuse an old `TEST_ID`.

```bash
export TEST_ID="spack-stack-inpe-validation-$(date -u +%Y%m%dT%H%M%SZ)"
export FRESH_INSTALL=1
export FORCE_SOURCE_BUILD=1
export INSTALL_JOBS=1
export SPACK_INSTALL_VERBOSE=1
export SPACK_INSTALL_FAIL_FAST=1
```

For quick tests, `INSTALL_JOBS` may be increased. For initial validation and diagnosis, use `INSTALL_JOBS=1`.

## 5. Phase 1: prepare tree, site, environment and concretization

Run:

```bash
bash scripts/01_prepare_jaci_stack.sh
```

This phase:

```text
loads the JACI base environment;
clones or updates the JCSDA spack-stack tree;
checks out release/2.1;
updates spack-stack submodules;
clones or updates spack-stack-inpe;
copies configs/sites/tier2/jaci into the spack-stack tree;
copies envs/jaci/mpas-jedi-gcc12-craympich;
creates the cray-mpich overlay;
changes the cray-mpich external prefix to the overlay;
changes install_tree.root to the current TEST_ID INSTALL_ROOT;
activates the Spack environment;
runs spack config blame;
runs spack concretize.
```

Important log files:

```text
${LOG_ROOT}/00_module_list_base.txt
${LOG_ROOT}/03_craype_mpi_overlay.txt
${LOG_ROOT}/04_effective_cray_mpich_external.txt
${LOG_ROOT}/08_spack_config_blame_config.txt
${LOG_ROOT}/08_spack_config_blame_packages.txt
${LOG_ROOT}/10_spack_concretize.log
```

Validate that the effective `cray-mpich` external points to the overlay:

```bash
export PROJECT_ROOT="/p/projetos/monan_das/${USER}"
export WORK_ROOT="${PROJECT_ROOT}/work/${TEST_ID}"
export ENV_NAME="jaci-mpas-jedi-gcc12-craympich"
export LOG_ROOT="${PROJECT_ROOT}/logs/${TEST_ID}"

grep -nA20 "cray-mpich:" \
  "${WORK_ROOT}/spack-stack/envs/${ENV_NAME}/site/packages.yaml"

cat "${LOG_ROOT}/03_craype_mpi_overlay.txt"
cat "${LOG_ROOT}/04_effective_cray_mpich_external.txt"
```

The expected prefix should look like:

```text
/p/projetos/monan_das/<user>/work/<TEST_ID>/wrappers/cray-mpich-overlay
```

## 6. Phase 2: build and install packages

Run:

```bash
bash scripts/02_install_packages.sh
```

This phase runs `spack install`. With the recommended variables, the command is executed with:

```text
--fail-fast
-v
--no-cache
-j ${INSTALL_JOBS}
```

Main log file:

```text
${LOG_ROOT}/12_spack_install.log
```

To monitor it from another terminal:

```bash
tail -f "${LOG_ROOT}/12_spack_install.log"
```

If an error occurs, collect:

```bash
tail -n 300 "${LOG_ROOT}/12_spack_install.log"

grep -nEi "error|failed|exception|traceback|cannot|fatal|killed|terminated|no space|permission denied|undefined reference|CMake Error|make.*Error" \
  "${LOG_ROOT}/12_spack_install.log" | tail -n 120 || true
```

## 7. Phase 3: generate Tcl modules

Run:

```bash
bash scripts/03_generate_tcl_modules.sh
```

This phase executes:

```text
spack module tcl refresh -y
```

The modules are generated under:

```text
${WORK_ROOT}/spack-stack/envs/${ENV_NAME}/modules
```

Log file:

```text
${LOG_ROOT}/14_generated_tcl_modules.txt
```

## 8. Phase 4: validate the module environment

Run:

```bash
bash scripts/04_validate_environment.sh
```

This phase should load the generated JEDI/MPAS environment module. The expected full module name is:

```text
cray-mpich/8.1.31/none/none/jedi-mpas-env/1.0.0
```

The `none/none` component is expected for `spack-stack` meta environment packages, because `jedi-mpas-env` is not a normal compiled library. It is a meta package that loads the dependency set for the environment.

The validation checks:

```text
cmake
ecbuild
python
nccmp
h5dump
h5diff
mpi4py
netCDF4
```

Main logs:

```text
${LOG_ROOT}/15_module_avail_generated.txt
${LOG_ROOT}/16_module_list_stack_loaded.txt
${LOG_ROOT}/17_which_tools.txt
${LOG_ROOT}/18_python_version.txt
${LOG_ROOT}/19_python_mpi4py_check.txt
${LOG_ROOT}/20_python_netcdf4_check.txt
```

## 9. Phase 5: validate CMake FindMPI

Run:

```bash
bash scripts/05_validate_cmake_findmpi.sh
```

The goal is to confirm that CMake resolves MPI to the CrayPE drivers:

```text
MPI_C_COMPILER=/opt/cray/pe/craype/2.7.33/bin/cc
MPI_CXX_COMPILER=/opt/cray/pe/craype/2.7.33/bin/CC
MPI_Fortran_COMPILER=/opt/cray/pe/craype/2.7.33/bin/ftn
```

Main logs:

```text
${LOG_ROOT}/21_cmake_findmpi_probe.log
${LOG_ROOT}/22_cmake_findmpi_summary.txt
```

## 10. Phase 6: collect logs

Run:

```bash
bash scripts/06_collect_logs.sh
```

This phase lists the generated logs, prints the final sections of the main logs and searches for common error signatures.

Use this phase to provide technical evidence for review.

## 11. Full copy-and-paste sequence

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

## 12. Success criteria

The validation can be considered successful when:

```text
spack concretize completes without error;
spack install completes without error;
Tcl modulefiles are generated;
the jedi-mpas-env module loads correctly;
cmake, ecbuild, python, nccmp, h5dump and h5diff are found;
mpi4py imports correctly;
netCDF4 imports correctly;
CMake FindMPI resolves to cc, CC and ftn;
the cray-mpich external points to the overlay;
no package tries to use /opt/cray/pe/mpich/.../bin/mpicc directly during compilation.
```

## 13. Recommended evidence before tagging

Before creating a tag, archive or review:

```text
${LOG_ROOT}/00_module_list_base.txt
${LOG_ROOT}/03_craype_mpi_overlay.txt
${LOG_ROOT}/04_effective_cray_mpich_external.txt
${LOG_ROOT}/10_spack_concretize.log
${LOG_ROOT}/12_spack_install.log
${LOG_ROOT}/14_generated_tcl_modules.txt
${LOG_ROOT}/16_module_list_stack_loaded.txt
${LOG_ROOT}/17_which_tools.txt
${LOG_ROOT}/21_cmake_findmpi_probe.log
${LOG_ROOT}/22_cmake_findmpi_summary.txt
```

Also record:

```bash
cd /p/projetos/monan_das/${USER}/projects/spack-stack-inpe
git rev-parse HEAD

echo "TEST_ID=${TEST_ID}"
echo "WORK_ROOT=/p/projetos/monan_das/${USER}/work/${TEST_ID}"
echo "LOG_ROOT=/p/projetos/monan_das/${USER}/logs/${TEST_ID}"
```

## 14. When to create a tag

Create a tag only after:

```text
a second person executes the complete procedure;
the TEST_ID is new;
the install tree is new or explicitly cleaned;
module-based validation passes;
CMake/FindMPI validation passes;
logs are reviewed;
the validated commit is identified.
```

Suggested tag name:

```text
jaci-spack-stack-2.1-gcc12-craympich-YYYYMMDD
```

## 15. Items not covered by this repository

This repository does not automatically validate:

```text
MONAN/MPAS-JEDI compilation;
complete MPAS-JEDI execution;
MPAS-JEDI ctest;
PBS operational workflows;
JEDI test data;
MPAS-JEDI numerical references.
```

Those steps should be documented in the repository responsible for the MONAN/MPAS-JEDI bundle or workflow.
