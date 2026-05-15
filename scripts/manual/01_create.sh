#!/usr/bin/env bash
# =============================================================================
# 01_create.sh
# =============================================================================
#
# Purpose
# -------
# Create a clean JACI spack-stack-inpe test tree, install the INPE/JACI site
# configuration into a JCSDA spack-stack release/2.1 checkout, activate the
# environment and run concretization.
#
# This script corresponds to the manual phase:
#
#   1. clone/update JCSDA spack-stack;
#   2. initialize the internal Spack submodule;
#   3. clone/update spack-stack-inpe;
#   4. copy the JACI site and environment files;
#   5. source setup scripts;
#   6. activate the environment;
#   7. audit configuration;
#   8. concretize.
#
# Validated target
# ----------------
#   spack-stack release/2.1
#   PrgEnv-gnu/8.6.0
#   gcc-native/12.3
#   cray-mpich/8.1.31
#   CrayPE drivers cc, CC and ftn
#
# Usage
# -----
#   bash scripts/manual/01_create.sh
#
# Optional overrides
# ------------------
#   PROJECT_ROOT=/p/projetos/monan_das/$USER
#   TEST_ID=spack-stack-inpe-test-release-2.1-gcc12
#   SPACK_STACK_REF=release/2.1
#   SPACK_STACK_INPE_REF=main
#
# =============================================================================

set -euo pipefail

export PROJECT_ROOT="${PROJECT_ROOT:-/p/projetos/monan_das/${USER}}"
export TEST_ID="${TEST_ID:-spack-stack-inpe-test-release-2.1-gcc12}"

export WORK_ROOT="${PROJECT_ROOT}/work/${TEST_ID}"
export INSTALL_ROOT="${PROJECT_ROOT}/env/spack-stack/install-release-2.1-gcc12-inpe-test"
export LOG_ROOT="${PROJECT_ROOT}/logs/${TEST_ID}"

export SPACK_STACK_REPO="${SPACK_STACK_REPO:-https://github.com/JCSDA/spack-stack.git}"
export SPACK_STACK_REF="${SPACK_STACK_REF:-release/2.1}"

export SPACK_STACK_INPE_REPO="${SPACK_STACK_INPE_REPO:-https://github.com/joaogerd/spack-stack-inpe.git}"
export SPACK_STACK_INPE_REF="${SPACK_STACK_INPE_REF:-main}"

export ENV_NAME="${ENV_NAME:-jaci-mpas-jedi-gcc12-craympich}"

mkdir -p "${WORK_ROOT}" "${INSTALL_ROOT}" "${LOG_ROOT}"

echo "[INFO] WORK_ROOT=${WORK_ROOT}"
echo "[INFO] INSTALL_ROOT=${INSTALL_ROOT}"
echo "[INFO] LOG_ROOT=${LOG_ROOT}"

# -----------------------------------------------------------------------------
# Clean module state and load validated JACI base environment
# -----------------------------------------------------------------------------

module --force purge || module purge || true

for d in \
  /opt/cray/pe/modulefiles \
  /opt/cray/modulefiles \
  /opt/cray/pe/craype-targets/default/modulefiles \
  /p/app/modulefiles \
  /opt/cray/pals/modulefiles
  do
  if [ -d "${d}" ]; then
    module use "${d}"
  fi
done

module load PrgEnv-gnu/8.6.0
module unload gcc-native/13.2 2>/dev/null || true
module load gcc-native/12.3
module load craype-x86-turin
module load cray-mpich/8.1.31
module load libfabric/1.22.0
module load cray-pals/1.6.1

export CC=cc
export CXX=CC
export FC=ftn
export F77=ftn
export F90=ftn

export MPICC=/opt/cray/pe/craype/2.7.33/bin/cc
export MPICXX=/opt/cray/pe/craype/2.7.33/bin/CC
export MPIFC=/opt/cray/pe/craype/2.7.33/bin/ftn
export MPIF77=/opt/cray/pe/craype/2.7.33/bin/ftn
export MPIF90=/opt/cray/pe/craype/2.7.33/bin/ftn

module list 2>&1 | tee "${LOG_ROOT}/00_module_list_base.txt"

echo "[INFO] CRAY_MPICH_DIR=${CRAY_MPICH_DIR:-UNSET}" | tee "${LOG_ROOT}/00_cray_mpich_env.txt"
echo "[INFO] CRAY_MPICH_PREFIX=${CRAY_MPICH_PREFIX:-UNSET}" | tee -a "${LOG_ROOT}/00_cray_mpich_env.txt"

which cc  | tee "${LOG_ROOT}/00_which_compilers.txt"
which CC  | tee -a "${LOG_ROOT}/00_which_compilers.txt"
which ftn | tee -a "${LOG_ROOT}/00_which_compilers.txt"
which gcc | tee -a "${LOG_ROOT}/00_which_compilers.txt"
which g++ | tee -a "${LOG_ROOT}/00_which_compilers.txt"
which gfortran | tee -a "${LOG_ROOT}/00_which_compilers.txt"

# -----------------------------------------------------------------------------
# Clone/update JCSDA spack-stack
# -----------------------------------------------------------------------------

cd "${WORK_ROOT}"

if [ ! -d spack-stack ]; then
  git clone "${SPACK_STACK_REPO}" spack-stack
fi

cd "${WORK_ROOT}/spack-stack"
git fetch --all --tags
git checkout "${SPACK_STACK_REF}"

git rev-parse HEAD | tee "${LOG_ROOT}/01_spack_stack_commit.txt"
git status --short | tee "${LOG_ROOT}/01_spack_stack_status.txt"

# -----------------------------------------------------------------------------
# Clone/update spack-stack-inpe
# -----------------------------------------------------------------------------

cd "${WORK_ROOT}"

if [ ! -d spack-stack-inpe ]; then
  git clone "${SPACK_STACK_INPE_REPO}" spack-stack-inpe
fi

cd "${WORK_ROOT}/spack-stack-inpe"
git fetch --all --tags
git checkout "${SPACK_STACK_INPE_REF}"
git pull --ff-only || true

git rev-parse HEAD | tee "${LOG_ROOT}/02_spack_stack_inpe_commit.txt"
git status --short | tee "${LOG_ROOT}/02_spack_stack_inpe_status.txt"

# -----------------------------------------------------------------------------
# Install JACI site configuration into JCSDA spack-stack tree
# -----------------------------------------------------------------------------

cd "${WORK_ROOT}/spack-stack"

mkdir -p configs/sites/tier2
rm -rf configs/sites/tier2/jaci

cp -a "${WORK_ROOT}/spack-stack-inpe/configs/sites/tier2/jaci" \
      "configs/sites/tier2/jaci"

find configs/sites/tier2/jaci -maxdepth 1 -type f | sort \
  | tee "${LOG_ROOT}/03_installed_jaci_site_files.txt"

# -----------------------------------------------------------------------------
# Install JACI MPAS-JEDI environment into JCSDA spack-stack tree
# -----------------------------------------------------------------------------

rm -rf "envs/${ENV_NAME}"
mkdir -p "envs/${ENV_NAME}"

cp -a "${WORK_ROOT}/spack-stack-inpe/envs/jaci/mpas-jedi-gcc12-craympich/." \
      "envs/${ENV_NAME}/"

find "envs/${ENV_NAME}" -maxdepth 3 -type f | sort \
  | tee "${LOG_ROOT}/04_installed_jaci_env_files.txt"

# -----------------------------------------------------------------------------
# Source site setup and JCSDA spack-stack setup
# -----------------------------------------------------------------------------

cd "${WORK_ROOT}/spack-stack"

echo "[INFO] Updating spack-stack submodules"
git submodule update --init --recursive 2>&1 | tee "${LOG_ROOT}/05_git_submodule_update.log"

echo "[INFO] Checking internal Spack checkout"
test -x spack/bin/spack
test -f spack/share/spack/setup-env.sh

ls -l spack/bin/spack | tee "${LOG_ROOT}/05_check_spack_bin.txt"
ls -l spack/share/spack/setup-env.sh | tee "${LOG_ROOT}/05_check_spack_setup_env.txt"

echo "[INFO] Reloading JACI setup and spack-stack setup"
source configs/sites/tier2/jaci/setup.sh
source setup.sh

which spack | tee "${LOG_ROOT}/06_which_spack.txt"
spack --version | tee "${LOG_ROOT}/06_spack_version.txt"

# -----------------------------------------------------------------------------
# Activate environment
# -----------------------------------------------------------------------------

echo "[INFO] Activating environment"
spack env activate "envs/${ENV_NAME}"
spack env status | tee "${LOG_ROOT}/07_spack_env_status.txt"

# -----------------------------------------------------------------------------
# Audit effective configuration
# -----------------------------------------------------------------------------

echo "[INFO] Auditing effective configuration"

spack config blame config \
  | tee "${LOG_ROOT}/08_spack_config_blame_config.txt"

spack config blame packages \
  | tee "${LOG_ROOT}/08_spack_config_blame_packages.txt"

spack config blame compilers \
  | tee "${LOG_ROOT}/08_spack_config_blame_compilers.txt"

spack config blame modules \
  | tee "${LOG_ROOT}/08_spack_config_blame_modules.txt"

# -----------------------------------------------------------------------------
# Sanity checks before concretization
# -----------------------------------------------------------------------------

echo "[INFO] Checking expected GCC external references"
grep -R "gcc@12.3.0" "envs/${ENV_NAME}" \
  | tee "${LOG_ROOT}/09_check_gcc_external.txt"

echo "[INFO] Checking expected Cray MPICH external references"
grep -R "cray-mpich@8.1.31" "envs/${ENV_NAME}" \
  | tee "${LOG_ROOT}/09_check_cray_mpich_external.txt"

echo "[INFO] Checking CrayPE MPI driver variables"
grep -R "MPICC\|MPICXX\|MPIFC\|MPIF77\|MPIF90" "envs/${ENV_NAME}" \
  | tee "${LOG_ROOT}/09_check_mpi_driver_vars.txt"

# -----------------------------------------------------------------------------
# Concretize
# -----------------------------------------------------------------------------

echo "[INFO] Concretizing"
spack concretize -f 2>&1 | tee "${LOG_ROOT}/10_spack_concretize.log"

# -----------------------------------------------------------------------------
# Summarize concretization
# -----------------------------------------------------------------------------

spack find -v 2>&1 | tee "${LOG_ROOT}/11_spack_find_after_concretize.txt"

echo "[INFO] Test finished through concretization."
echo "[INFO] Logs are in: ${LOG_ROOT}"
