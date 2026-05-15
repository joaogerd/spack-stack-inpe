# JACI spack-stack build manual

## 1. Purpose

This document describes the manual procedure to prepare a JCSDA `spack-stack` environment for the JACI machine at INPE.

The goal of this repository is not to replace the JCSDA `spack-stack` repository. Instead, this repository stores the INPE/JACI site configuration and the operational steps needed to reproduce a validated stack on JACI.

The intended final layout follows the JCSDA site convention:

```text
configs/sites/<tier>/<site>/
```

For JACI, the proposed site layout is:

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

At this stage, this manual records the expected operational flow. The actual YAML files still need to be populated from the validated JACI configuration.

## 2. Current technical status

### Confirmed

A previous discovery workflow validated the following baseline on JACI:

```text
spack-stack release/2.1
PrgEnv-gnu/8.6.0
gcc-native/12.3
cray-mpich/8.1.31
CrayPE compiler drivers: cc, CC, ftn
```

Using that stack, a reduced MPAS-JEDI-only `jedi-bundle` path was configured, built and tested through PBS/PALS. The MPAS-JEDI CTest result was:

```text
61/62 tests passed
1 stable numerical reference mismatch in mpasjedi_lgetkf_height_vloc
```

The remaining failure was reproducible on JACI and was classified as a stable platform-specific numerical mismatch, not as an infrastructure failure.

### Target for the institutional configuration

The preferred target for `spack-stack-inpe` is to use the newest GNU environment currently available by default on JACI:

```text
PrgEnv-gnu/8.6.0
gcc-native/13.2
cray-mpich/8.1.31
```

This target still needs a full validation run. The GCC 12.3 environment remains a confirmed diagnostic baseline, not necessarily the final institutional choice.

## 3. Important CrayPE rule for JACI

On JACI, with CrayPE loaded, builds must use the CrayPE compiler drivers:

```text
cc
CC
ftn
```

or their full paths:

```text
/opt/cray/pe/craype/2.7.33/bin/cc
/opt/cray/pe/craype/2.7.33/bin/CC
/opt/cray/pe/craype/2.7.33/bin/ftn
```

Do not force builds to use the raw Cray MPICH wrappers directly, such as:

```text
/opt/cray/pe/mpich/8.1.31/ofi/gnu/<version>/bin/mpicc
/opt/cray/pe/mpich/8.1.31/ofi/gnu/<version>/bin/mpicxx
/opt/cray/pe/mpich/8.1.31/ofi/gnu/<version>/bin/mpifort
```

When CrayPE is active, those wrappers can trigger errors of the form:

```text
CrayPE is loaded, use cc/CC/ftn instead of mpicc/mpicxx/mpifort
```

Therefore, in the JACI site configuration and in the runtime environment, MPI compiler variables must resolve to `cc`, `CC` and `ftn`.

## 4. Directory convention used in this manual

Set a working area. The paths below are examples and should be adapted to the user or project area.

```bash
export PROJECT_ROOT="/p/projetos/monan_das/$USER"
export WORK_ROOT="$PROJECT_ROOT/work/jaci-spack-stack-work-release-2.1-gcc13"
export INSTALL_ROOT="$PROJECT_ROOT/env/spack-stack/install-release-2.1-gcc13"
export LOG_ROOT="$PROJECT_ROOT/logs/jaci-spack-stack-release-2.1-gcc13"
```

Create the directories:

```bash
mkdir -p "$WORK_ROOT"
mkdir -p "$INSTALL_ROOT"
mkdir -p "$LOG_ROOT"
```

Validate:

```bash
ls -ld "$WORK_ROOT" "$INSTALL_ROOT" "$LOG_ROOT"
```

## 5. Load the base JACI environment

For the GCC 13.2 target:

```bash
module purge

module load PrgEnv-gnu/8.6.0
module load craype-x86-turin
module load cray-mpich/8.1.31
module load libfabric/1.22.0
module load cray-pals/1.6.1
```

Check the loaded modules:

```bash
module list
```

Check the compiler drivers:

```bash
which cc
which CC
which ftn
which gcc
which g++
which gfortran

cc --version
CC --version
ftn --version
gcc --version
gfortran --version
```

Expected CrayPE compiler driver paths:

```text
/opt/cray/pe/craype/2.7.33/bin/cc
/opt/cray/pe/craype/2.7.33/bin/CC
/opt/cray/pe/craype/2.7.33/bin/ftn
```

Expected GNU backend for the target configuration:

```text
gcc-native/13.2
```

If a future fallback baseline is required, the previously validated GCC 12.3 environment requires unloading the default GNU backend first:

```bash
module purge
module load PrgEnv-gnu/8.6.0
module unload gcc-native/13.2
module load gcc-native/12.3
module load craype-x86-turin
module load cray-mpich/8.1.31
module load libfabric/1.22.0
module load cray-pals/1.6.1
```

## 6. Export compiler variables

Set explicit compiler variables so that CMake, Spack and package builds consistently use the CrayPE drivers.

```bash
export CC=/opt/cray/pe/craype/2.7.33/bin/cc
export CXX=/opt/cray/pe/craype/2.7.33/bin/CC
export FC=/opt/cray/pe/craype/2.7.33/bin/ftn
export F77=/opt/cray/pe/craype/2.7.33/bin/ftn
export F90=/opt/cray/pe/craype/2.7.33/bin/ftn

export MPICC="$CC"
export MPICXX="$CXX"
export MPIFC="$FC"
export MPIF77="$FC"
export MPIF90="$FC"
```

Validate:

```bash
echo "$CC"
echo "$CXX"
echo "$FC"
echo "$MPICC"
echo "$MPICXX"
echo "$MPIFC"
```

All values should point to `cc`, `CC` or `ftn` from CrayPE.

## 7. Clone the JCSDA spack-stack repository

```bash
cd "$WORK_ROOT"

git clone https://github.com/JCSDA/spack-stack.git
cd spack-stack
git checkout release/2.1
```

Record the state:

```bash
git rev-parse HEAD | tee "$LOG_ROOT/spack_stack_commit.txt"
git status | tee "$LOG_ROOT/spack_stack_git_status.txt"
```

Expected branch:

```bash
git branch --show-current
```

Expected output:

```text
release/2.1
```

## 8. Clone the INPE site configuration repository

```bash
cd "$WORK_ROOT"

git clone https://github.com/joaogerd/spack-stack-inpe.git
```

The JACI site configuration should be stored in this repository under:

```text
configs/sites/tier2/jaci/
```

## 9. Install the JACI site configuration into spack-stack

Copy the JACI site configuration into the JCSDA `spack-stack` tree:

```bash
cp -r "$WORK_ROOT/spack-stack-inpe/configs/sites/tier2/jaci" \
      "$WORK_ROOT/spack-stack/configs/sites/tier2/"
```

Validate:

```bash
find "$WORK_ROOT/spack-stack/configs/sites/tier2/jaci" -maxdepth 1 -type f | sort
```

Expected files:

```text
config.yaml
mirrors.yaml
modules.yaml
packages.yaml
packages_gcc-13.2.yaml
setup.sh
README.md
```

## 10. Source the JACI site setup

The canonical site environment setup should be:

```bash
cd "$WORK_ROOT/spack-stack"
source configs/sites/tier2/jaci/setup.sh
```

The `setup.sh` file should do the equivalent of:

```bash
module purge
module load PrgEnv-gnu/8.6.0
module load craype-x86-turin
module load cray-mpich/8.1.31
module load libfabric/1.22.0
module load cray-pals/1.6.1

export CC=/opt/cray/pe/craype/2.7.33/bin/cc
export CXX=/opt/cray/pe/craype/2.7.33/bin/CC
export FC=/opt/cray/pe/craype/2.7.33/bin/ftn
export F77=/opt/cray/pe/craype/2.7.33/bin/ftn
export F90=/opt/cray/pe/craype/2.7.33/bin/ftn

export MPICC="$CC"
export MPICXX="$CXX"
export MPIFC="$FC"
export MPIF77="$FC"
export MPIF90="$FC"
```

Validate:

```bash
module list
which cc
which CC
which ftn
echo "$CC"
echo "$CXX"
echo "$FC"
```

## 11. Inspect the JACI YAML files

Before creating the environment, inspect the YAML files manually.

### 11.1 config.yaml

```bash
grep -nE "install_tree|build_stage|source_cache|misc_cache|concretizer|locks" \
  configs/sites/tier2/jaci/config.yaml
```

This file should define the general Spack behavior on JACI, including installation tree, build stage, caches and concretizer settings.

### 11.2 mirrors.yaml

```bash
cat configs/sites/tier2/jaci/mirrors.yaml
```

This file may initially be minimal, but it should exist to follow the JCSDA site convention and to support future INPE mirrors or buildcaches.

### 11.3 modules.yaml

```bash
grep -nE "lmod|hierarchy|stack-gcc|cray-mpich|jedi-mpas-env" \
  configs/sites/tier2/jaci/modules.yaml
```

The module configuration should generate the expected hierarchical modules for the stack.

### 11.4 packages.yaml

```bash
grep -nE "providers|mpi|blas|lapack|cray-mpich|libfabric|cray-libsci" \
  configs/sites/tier2/jaci/packages.yaml
```

This file should contain common package rules not specific to one compiler backend.

### 11.5 packages_gcc-13.2.yaml

```bash
grep -nE "cray-mpich|libfabric|libsci|external|prefix|modules" \
  configs/sites/tier2/jaci/packages_gcc-13.2.yaml
```

Compiler-specific externals and paths belong here.

For GCC 13.2, the Cray MPICH path is expected to follow the GNU 13.2 backend layout, such as:

```text
/opt/cray/pe/mpich/8.1.31/ofi/gnu/13.2
```

This must be verified on JACI before treating it as confirmed.

## 12. Initialize Spack from the JCSDA spack-stack tree

Inside the `spack-stack` repository:

```bash
cd "$WORK_ROOT/spack-stack"
source setup.sh
```

If needed, source Spack directly:

```bash
source spack/share/spack/setup-env.sh
```

Validate:

```bash
which spack
spack --version
```

## 13. Create or install the JACI environment

The final environment definition should be stored in this repository, for example:

```text
envs/jaci/mpas-jedi-gcc13-craympich/spack.yaml
```

Install it into the JCSDA `spack-stack` tree:

```bash
mkdir -p "$WORK_ROOT/spack-stack/envs/jaci-mpas-jedi-gcc13-craympich"

cp "$WORK_ROOT/spack-stack-inpe/envs/jaci/mpas-jedi-gcc13-craympich/spack.yaml" \
   "$WORK_ROOT/spack-stack/envs/jaci-mpas-jedi-gcc13-craympich/spack.yaml"
```

Activate the environment:

```bash
spack env activate "$WORK_ROOT/spack-stack/envs/jaci-mpas-jedi-gcc13-craympich"
```

Validate:

```bash
spack env status
```

Expected active environment:

```text
jaci-mpas-jedi-gcc13-craympich
```

## 14. Check that the site configuration is visible

Use Spack blame commands:

```bash
spack config blame config
spack config blame packages
spack config blame compilers
spack config blame modules
```

The output should reference files from:

```text
configs/sites/tier2/jaci/
```

If not, the JACI site configuration is not being applied correctly.

## 15. Check compilers

```bash
spack compiler list
```

If the compiler must be detected:

```bash
spack compiler find
spack compiler list
```

Then inspect:

```bash
spack config blame compilers
```

Critical rule:

```text
Do not accept a compiler configuration that causes builds to use raw mpicc/mpicxx/mpifort instead of CrayPE cc/CC/ftn.
```

## 16. Concretize the environment

```bash
spack concretize -f 2>&1 | tee "$LOG_ROOT/spack_concretize.log"
```

Check for errors:

```bash
grep -Ei "error|failed|conflict|cannot" "$LOG_ROOT/spack_concretize.log" | head -n 100
```

Check MPI resolution:

```bash
spack find -v cray-mpich
spack find -v mpi
```

Expected result:

```text
MPI resolves to cray-mpich@8.1.31.
The compiler backend is the intended GNU/CrayPE configuration.
```

For the GCC 13.2 target, this still needs to be confirmed by a full build.

## 17. Install the environment

```bash
spack install -j 16 2>&1 | tee "$LOG_ROOT/spack_install.log"
```

Check for failures:

```bash
grep -Ei "error|failed|FAILED|cannot|No such file" "$LOG_ROOT/spack_install.log" | head -n 100
```

List installed packages:

```bash
spack find
```

## 18. Generate Lmod modulefiles

```bash
spack module lmod refresh -y 2>&1 | tee "$LOG_ROOT/spack_module_refresh.log"
```

Find generated module directories:

```bash
find "$WORK_ROOT/spack-stack/envs/jaci-mpas-jedi-gcc13-craympich" \
  -type d \( -name modules -o -name Core \) | sort
```

Find expected modules:

```bash
find "$WORK_ROOT/spack-stack/envs/jaci-mpas-jedi-gcc13-craympich/modules" \
  -type f | grep -E "stack-gcc|stack-cray-mpich|jedi-mpas-env"
```

Expected modules:

```text
stack-gcc/<gcc-version>
stack-cray-mpich/8.1.31
jedi-mpas-env/1.0.0
```

The exact `stack-gcc` version string must be verified after module generation.

## 19. Load the generated stack modules

Open a fresh login shell or clean the module environment.

```bash
module purge
source "$WORK_ROOT/spack-stack/configs/sites/tier2/jaci/setup.sh"
```

Add module paths:

```bash
module use "$WORK_ROOT/spack-stack/envs/jaci-mpas-jedi-gcc13-craympich/modules/Core"
module use "$WORK_ROOT/spack-stack/envs/jaci-mpas-jedi-gcc13-craympich/modules"
```

Inspect modules:

```bash
module avail stack-gcc
module avail stack-cray-mpich
module avail jedi-mpas-env
```

Load modules. Adjust the exact version if needed:

```bash
module load stack-gcc/13.2.0
module load stack-cray-mpich/8.1.31
module load jedi-mpas-env/1.0.0
```

Validate:

```bash
module list
which cmake
which ecbuild
which python
which cc
which CC
which ftn
```

## 20. Validate the installed stack

Basic Python checks:

```bash
python -c "import mpi4py; print('mpi4py ok')"
python -c "import netCDF4; print('netCDF4 ok')"
```

Tool checks:

```bash
which cmake
cmake --version

which ecbuild
ecbuild --version || true

which nccmp
which h5dump
which h5diff
which pycodestyle
```

Check CMake prefix paths:

```bash
echo "$CMAKE_PREFIX_PATH" | tr ':' '\n' | grep -E 'eckit|fckit|atlas|ioda|ufo|saber|oops|gsibec|ip|netcdf|hdf5'
```

## 21. Validate CMake FindMPI with CrayPE drivers

Create a minimal probe:

```bash
mkdir -p "$WORK_ROOT/probes/cmake-findmpi"
cd "$WORK_ROOT/probes/cmake-findmpi"

cat > CMakeLists.txt <<'EOF'
cmake_minimum_required(VERSION 3.20)
project(test_findmpi LANGUAGES C CXX Fortran)

find_package(MPI REQUIRED COMPONENTS C CXX Fortran)

message(STATUS "MPI_C_COMPILER=${MPI_C_COMPILER}")
message(STATUS "MPI_CXX_COMPILER=${MPI_CXX_COMPILER}")
message(STATUS "MPI_Fortran_COMPILER=${MPI_Fortran_COMPILER}")
EOF
```

Configure:

```bash
cmake -S . -B build \
  -DCMAKE_C_COMPILER="$CC" \
  -DCMAKE_CXX_COMPILER="$CXX" \
  -DCMAKE_Fortran_COMPILER="$FC" \
  2>&1 | tee "$LOG_ROOT/cmake_findmpi_probe.log"
```

Expected result:

```text
MPI_C_COMPILER=/opt/cray/pe/craype/2.7.33/bin/cc
MPI_CXX_COMPILER=/opt/cray/pe/craype/2.7.33/bin/CC
MPI_Fortran_COMPILER=/opt/cray/pe/craype/2.7.33/bin/ftn
```

## 22. Stack success criteria

The JACI stack is considered usable when the following are true:

```text
1. spack-stack release/2.1 is checked out.
2. configs/sites/tier2/jaci is installed in the spack-stack tree.
3. setup.sh loads PrgEnv-gnu, craype-x86-turin, cray-mpich, libfabric and cray-pals.
4. cc, CC and ftn are used as C, C++ and Fortran compilers.
5. MPI resolves to cray-mpich@8.1.31.
6. spack concretize completes successfully.
7. spack install completes successfully.
8. Lmod modulefiles are generated.
9. stack-gcc, stack-cray-mpich and jedi-mpas-env can be loaded.
10. python, mpi4py, netCDF4, cmake and ecbuild are available.
11. CMake FindMPI resolves to cc, CC and ftn.
```

## 23. Boundary with MONAN-bundle

This repository stops at the validated spack-stack environment.

The next phase belongs to `MONAN-bundle`:

```text
https://github.com/GAD-DIMNT-CPTEC/MONAN-bundle
```

`MONAN-bundle` should assume the JACI stack is already loaded and should then handle:

```text
1. preparing the reduced MPAS-JEDI bundle;
2. configuring MPAS-JEDI;
3. building MPAS-JEDI;
4. materializing Git LFS test data;
5. preparing MPAS block decomposition;
6. running MPAS-JEDI tests through PBS/PALS;
7. documenting MPAS-JEDI validation results.
```

## 24. Known open items

```text
1. The GCC 13.2 target still requires a full spack-stack build and MPAS-JEDI validation.
2. The GCC 12.3 baseline is validated but should not automatically become the final institutional target.
3. The actual JACI YAML files must be extracted from the validated configuration and adapted to the JCSDA site layout.
4. The exact generated module names for GCC 13.2 must be verified.
5. A future INPE mirror/buildcache policy should be added to mirrors.yaml.
```
