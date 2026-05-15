# JACI spack-stack build manual

## 1. Purpose

This document describes the manual procedure to prepare a JCSDA `spack-stack` environment for the JACI machine at INPE.

The goal of this repository is not to replace the JCSDA `spack-stack` repository. Instead, this repository stores the INPE/JACI site configuration and the operational steps needed to reproduce a validated stack on JACI.

The intended layout follows the JCSDA site convention:

```text
configs/sites/<tier>/<site>/
```

For JACI, the site layout is:

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

The current production target is GCC 12.3 with Cray MPICH 8.1.31. The GCC 13.2 file is kept only as experimental documentation until a compatible Cray MPICH backend is confirmed or a complete explicit validation is performed.

## 2. Current technical status

### Validated target

The validated JACI stack target is:

```text
spack-stack release/2.1
PrgEnv-gnu/8.6.0
gcc-native/12.3
cray-mpich/8.1.31
CrayPE compiler drivers: cc, CC, ftn
Tcl modulefiles under $env/modules
```

Using that stack, a reduced MPAS-JEDI-only `jedi-bundle` path was configured, built and tested through PBS/PALS. The MPAS-JEDI CTest result was:

```text
61/62 tests passed
1 stable numerical reference mismatch in mpasjedi_lgetkf_height_vloc
```

The remaining failure was reproducible on JACI and was classified as a stable platform-specific numerical mismatch, not as an infrastructure failure.

### Experimental GCC 13.2 target

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

Therefore, GCC 13.2 is considered experimental/hybrid and must not be used as the production stack target until this is explicitly validated.

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
/opt/cray/pe/mpich/8.1.31/ofi/gnu/12.3/bin/mpicc
/opt/cray/pe/mpich/8.1.31/ofi/gnu/12.3/bin/mpicxx
/opt/cray/pe/mpich/8.1.31/ofi/gnu/12.3/bin/mpifort
```

When CrayPE is active, those wrappers can trigger errors indicating that `cc`, `CC` and `ftn` must be used instead. Therefore, in the JACI site configuration and in the runtime environment, MPI compiler variables must resolve to `cc`, `CC` and `ftn`.

## 4. Directory convention used in this manual

Set a working area. The paths below are examples and should be adapted to the user or project area.

```bash
export PROJECT_ROOT="/p/projetos/monan_das/$USER"
export WORK_ROOT="$PROJECT_ROOT/work/jaci-spack-stack-work-release-2.1-gcc12"
export INSTALL_ROOT="$PROJECT_ROOT/env/spack-stack/install-release-2.1-gcc12"
export LOG_ROOT="$PROJECT_ROOT/logs/jaci-spack-stack-release-2.1-gcc12"
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

## 5. Load the validated base JACI environment

Use the validated GCC 12.3 target:

```bash
module purge

module load PrgEnv-gnu/8.6.0
module unload gcc-native/13.2 2>/dev/null || true
module load gcc-native/12.3
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

Expected GNU backend:

```text
gcc-native/12.3
```

Expected Cray MPICH prefix:

```bash
echo "$CRAY_MPICH_DIR"
echo "$CRAY_MPICH_PREFIX"
```

Expected values:

```text
/opt/cray/pe/mpich/8.1.31/ofi/gnu/12.3
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

The JACI site configuration is stored under:

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
packages_gcc-12.3.yaml
packages_gcc-13.2.yaml
setup.sh
README.md
```

The current production compiler-specific file is:

```text
packages_gcc-12.3.yaml
```

## 10. Source the JACI site setup

The canonical site environment setup is:

```bash
cd "$WORK_ROOT/spack-stack"
source configs/sites/tier2/jaci/setup.sh
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
echo "$TARGET_COMPILER"
echo "$TARGET_MPI"
```

Expected metadata:

```text
TARGET_COMPILER=gcc-native/12.3
TARGET_MPI=cray-mpich/8.1.31
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
grep -nE "tcl|projections|mpi|autoload|ROOT" \
  configs/sites/tier2/jaci/modules.yaml
```

The validated module configuration uses Tcl modulefiles under `$env/modules`.

### 11.4 packages.yaml

```bash
grep -nE "providers|mpi|blas|lapack|openblas|cray-mpich" \
  configs/sites/tier2/jaci/packages.yaml
```

This file should contain common package rules not specific to one compiler backend.

### 11.5 packages_gcc-12.3.yaml

```bash
grep -nE "gcc@12.3.0|cray-mpich|MPICC|MPICXX|MPIFC|prefix|modules" \
  configs/sites/tier2/jaci/packages_gcc-12.3.yaml
```

This file should contain the validated GCC 12.3 compiler external and the Cray MPICH external with `+wrappers`, using `cc`, `CC` and `ftn` through `extra_attributes.environment.set`.

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

The environment definition for the validated target is stored in this repository as:

```text
envs/jaci/mpas-jedi-gcc12-craympich/spack.yaml
```

Install it into the JCSDA `spack-stack` tree:

```bash
mkdir -p "$WORK_ROOT/spack-stack/envs/jaci-mpas-jedi-gcc12-craympich"

cp "$WORK_ROOT/spack-stack-inpe/envs/jaci/mpas-jedi-gcc12-craympich/spack.yaml" \
   "$WORK_ROOT/spack-stack/envs/jaci-mpas-jedi-gcc12-craympich/spack.yaml"
```

Activate the environment:

```bash
spack env activate "$WORK_ROOT/spack-stack/envs/jaci-mpas-jedi-gcc12-craympich"
```

Validate:

```bash
spack env status
```

Expected active environment:

```text
jaci-mpas-jedi-gcc12-craympich
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

and/or the active environment-specific `site/` and `common/` configuration directories generated by spack-stack.

If not, the JACI site configuration is not being applied correctly.

## 15. Check compiler handling

The validated flow does not rely on a traditional populated `compilers.yaml`. The compiler is represented through package externals, especially the `gcc` package external in `packages_gcc-12.3.yaml`.

Check:

```bash
spack config blame compilers
spack config blame packages | grep -nE "gcc@12.3.0|cray-mpich|MPICC|MPICXX|MPIFC"
```

Critical rule:

```text
Do not accept a configuration that causes builds to use raw mpicc/mpicxx/mpifort instead of CrayPE cc/CC/ftn.
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
MPI resolves to cray-mpich@8.1.31+wrappers.
The compiler backend is gcc@12.3.0 through the JACI GCC external.
```

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

## 18. Generate Tcl modulefiles

The validated JACI stack used Tcl modules.

```bash
spack module tcl refresh -y 2>&1 | tee "$LOG_ROOT/spack_module_refresh.log"
```

Find generated module directories:

```bash
find "$WORK_ROOT/spack-stack/envs/jaci-mpas-jedi-gcc12-craympich" \
  -type d -name modules | sort
```

Find generated modules:

```bash
find "$WORK_ROOT/spack-stack/envs/jaci-mpas-jedi-gcc12-craympich/modules" \
  -type f | sort | head -n 100
```

Expected projection style:

```text
cray-mpich/8.1.31/gcc/12.3.0/<package>/<version>
gcc/12.3.0/<package>/<version>
```

## 19. Load generated stack modules

Open a fresh login shell or clean the module environment.

```bash
module purge
source "$WORK_ROOT/spack-stack/configs/sites/tier2/jaci/setup.sh"
```

Add the Tcl module path:

```bash
module use "$WORK_ROOT/spack-stack/envs/jaci-mpas-jedi-gcc12-craympich/modules"
```

Inspect modules:

```bash
module avail
```

Load the required stack modules according to the generated names. For example, the validated discovery stack included modules such as:

```text
stack-gcc/12.3.0
stack-cray-mpich/8.1.31
jedi-mpas-env/1.0.0
```

The exact names must be confirmed from `module avail` after module generation.

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
3. setup.sh loads PrgEnv-gnu, gcc-native/12.3, craype-x86-turin, cray-mpich, libfabric and cray-pals.
4. cc, CC and ftn are used as C, C++ and Fortran compiler drivers.
5. MPI resolves to cray-mpich@8.1.31+wrappers.
6. MPICC, MPICXX and MPIFC resolve to cc, CC and ftn.
7. spack concretize completes successfully.
8. spack install completes successfully.
9. Tcl modulefiles are generated under $env/modules.
10. stack modules can be loaded from the generated module tree.
11. python, mpi4py, netCDF4, cmake and ecbuild are available.
12. CMake FindMPI resolves to cc, CC and ftn.
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
1. The current production target is GCC 12.3 + Cray MPICH 8.1.31.
2. GCC 13.2 exists on JACI, but it is experimental because Cray MPICH still points to the GNU 12.3 backend.
3. The current spack.yaml is still a documented skeleton and must be replaced by the exact validated environment specification.
4. The config.yaml install tree should be finalized for institutional use.
5. A future INPE mirror/buildcache policy should be added to mirrors.yaml.
```
