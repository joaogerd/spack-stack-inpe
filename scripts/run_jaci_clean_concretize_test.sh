#!/usr/bin/env bash
# =============================================================================
# JACI spack-stack-inpe clean concretization test
# =============================================================================
#
# Purpose
# -------
# Run a clean test of the INPE/JACI spack-stack configuration against the JCSDA
# spack-stack release/2.1 tree.
#
# Context
# -------
# This script clones or updates:
#
#   https://github.com/JCSDA/spack-stack.git
#   https://github.com/joaogerd/spack-stack-inpe.git
#
# Then it copies the JACI site and environment configuration from
# spack-stack-inpe into the JCSDA spack-stack tree and runs:
#
#   spack config blame
#   spack concretize -f
#
# Validation target
# -----------------
# Current validated JACI target:
#
#   spack-stack release/2.1
#   PrgEnv-gnu/8.6.0
#   gcc-native/12.3
#   cray-mpich/8.1.31
#   CrayPE drivers cc, CC and ftn
#
# Important implementation detail
# -------------------------------
# The JCSDA spack-stack repository requires the internal Spack checkout under
# the `spack/` directory. Therefore this script always runs:
#
#   git submodule update --init --recursive
#
# before sourcing the JCSDA setup.sh.
#
# How to use
# ----------
# Run this script as a program, not with source:
#
#   bash scripts/run_jaci_clean_concretize_test.sh
#
# Optional environment overrides:
#
#   PROJECT_ROOT=/p/projetos/monan_das/$USER
#   TEST_ID=spack-stack-inpe-test-release-2.1-gcc12
#   SPACK_STACK_REF=release/2.1
#   SPACK_STACK_INPE_REF=main
#
# Output
# ------
# Logs are written under:
#
#   ${PROJECT_ROOT}/logs/${TEST_ID}
#
# =============================================================================

set -euo pipefail

export PROJECT_ROOT="${PROJECT_ROOT:-/p/projetos/monan_das/${USER}}"
export TEST_ID="${TEST_ID:-spack-stack-inpe-test-release-2.1-gcc12}"

export WORK_ROOT="${PROJECT_ROOT}/work/${TEST_ID}"
export INSTALL_ROOT="${PROJECT_ROOT}/env/spack-stack/${TEST_ID}"
export LOG_ROOT="${PROJECT_ROOT}/logs/${TEST_ID}"

export SPACK_STACK_REPO="${SPACK_STACK_REPO:-https://github.com/JCSDA/spack-stack.git}"
export SPACK_STACK_REF="${SPACK_STACK_REF:-release/2.1}"

export SPACK_STACK_INPE_REPO="${SPACK_STACK_INPE_REPO:-https://github.com/joaogerd/spack-stack-inpe.git}"
export SPACK_STACK_INPE_REF="${SPACK_STACK_INPE_REF:-main}"

export ENV_NAME="${ENV_NAME:-jaci-mpas-jedi-gcc12-craympich}"

mkdir -p "${WORK_ROOT}" "${INSTALL_ROOT}" "${LOG_ROOT}"

printf '[INFO] WORK_ROOT=%s\n' "${WORK_ROOT}"
printf '[INFO] INSTALL_ROOT=%s\n' "${INSTALL_ROOT}"
printf '[INFO] LOG_ROOT=%s\n' "${LOG_ROOT}"

# -----------------------------------------------------------------------------
# Clean module state and load validated JACI base environment
# -----------------------------------------------------------------------------

module --force purge || module purge || true

if [ -d "/opt/cray/pe/modulefiles" ]; then
  module use "/opt/cray/pe/modulefiles"
fi
if [ -d "/opt/cray/modulefiles" ]; then
  module use "/opt/cray/modulefiles"
fi
if [ -d "/opt/cray/pe/craype-targets/default/modulefiles" ]; then
  module use "/opt/cray/pe/craype-targets/default/modulefiles"
fi
if [ -d "/p/app/modulefiles" ]; then
  module use "/p/app/modulefiles"
fi
if [ -d "/opt/cray/pals/modulefiles" ]; then
  module use "/opt/cray/pals/modulefiles"
fi

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

{
  echo "[INFO] CRAY_MPICH_DIR=${CRAY_MPICH_DIR:-UNSET}"
  echo "[INFO] CRAY_MPICH_PREFIX=${CRAY_MPICH_PREFIX:-UNSET}"
} | tee "${LOG_ROOT}/00_cray_mpich_env.txt"

{
  which cc
  which CC
  which ftn
  which gcc
  which g++
  which gfortran
} | tee "${LOG_ROOT}/00_which_compilers.txt"

# -----------------------------------------------------------------------------
# Clone or update JCSDA spack-stack
# -----------------------------------------------------------------------------

cd "${WORK_ROOT}"

if [ ! -d spack-stack ]; then
  git clone "${SPACK_STACK_REPO}" spack-stack
fi

cd "${WORK_ROOT}/spack-stack"
git fetch --all --tags
git checkout "${SPACK_STACK_REF}"

# Required by JCSDA spack-stack setup.sh.
git submodule update --init --recursive 2>&1 | tee "${LOG_ROOT}/01_git_submodule_update.log"

test -x spack/bin/spack
test -f spack/share/spack/setup-env.sh

git rev-parse HEAD | tee "${LOG_ROOT}/01_spack_stack_commit.txt"
git status --short | tee "${LOG_ROOT}/01_spack_stack_status.txt"

# -----------------------------------------------------------------------------
# Clone or update spack-stack-inpe
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

source configs/sites/tier2/jaci/setup.sh
source setup.sh

which spack | tee "${LOG_ROOT}/05_which_spack.txt"
spack --version | tee "${LOG_ROOT}/05_spack_version.txt"

# -----------------------------------------------------------------------------
# Activate environment
# -----------------------------------------------------------------------------

spack env activate "envs/${ENV_NAME}"
spack env status | tee "${LOG_ROOT}/06_spack_env_status.txt"

# -----------------------------------------------------------------------------
# Audit effective configuration
# -----------------------------------------------------------------------------

spack config blame config \
  | tee "${LOG_ROOT}/07_spack_config_blame_config.txt"

spack config blame packages \
  | tee "${LOG_ROOT}/07_spack_config_blame_packages.txt"

spack config blame compilers \
  | tee "${LOG_ROOT}/07_spack_config_blame_compilers.txt"

spack config blame modules \
  | tee "${LOG_ROOT}/07_spack_config_blame_modules.txt"

# -----------------------------------------------------------------------------
# Sanity checks before concretization
# -----------------------------------------------------------------------------

grep -R "gcc@12.3.0" "envs/${ENV_NAME}" \
  | tee "${LOG_ROOT}/08_check_gcc_external.txt"

grep -R "cray-mpich@8.1.31" "envs/${ENV_NAME}" \
  | tee "${LOG_ROOT}/08_check_cray_mpich_external.txt"

grep -R "MPICC\|MPICXX\|MPIFC\|MPIF77\|MPIF90" "envs/${ENV_NAME}" \
  | tee "${LOG_ROOT}/08_check_mpi_driver_vars.txt"

# -----------------------------------------------------------------------------
# Concretize
# -----------------------------------------------------------------------------

spack concretize -f 2>&1 | tee "${LOG_ROOT}/09_spack_concretize.log"

# -----------------------------------------------------------------------------
# Summarize concretization
# -----------------------------------------------------------------------------

spack find -v 2>&1 | tee "${LOG_ROOT}/10_spack_find_after_concretize.txt"

printf '[INFO] Test finished through concretization.\n'
printf '[INFO] Logs are in: %s\n' "${LOG_ROOT}"
