#!/usr/bin/env bash
# =============================================================================
# 01_prepare_jaci_stack.sh
# =============================================================================
#
# Purpose
# -------
# Prepare a clean JACI spack-stack tree using the INPE site configuration,
# activate the MPAS-JEDI environment and run concretization.
#
# This phase does not install packages. Installation is performed by:
#
#   02_install_packages.sh
#
# Validated target
# ----------------
#   spack-stack release/2.1
#   PrgEnv-gnu/8.6.0
#   gcc-native/12.3
#   cray-mpich/8.1.31
#   CrayPE drivers cc, CC and ftn
#
# Important CrayPE detail
# -----------------------
# The JACI CrayPE environment must not use the raw Cray MPICH wrappers from:
#
#   /opt/cray/pe/mpich/.../bin/mpicc
#   /opt/cray/pe/mpich/.../bin/mpicxx
#   /opt/cray/pe/mpich/.../bin/mpif90
#
# Many Spack package recipes access MPI wrappers through:
#
#   self.spec["mpi"].mpicc
#   self.spec["mpi"].mpicxx
#   self.spec["mpi"].mpifc
#
# To fix this globally, this script creates a Cray MPICH overlay prefix with
# shim wrappers named mpicc/mpicxx/mpifort that delegate to the correct CrayPE
# drivers cc/CC/ftn. The external cray-mpich prefix in the copied environment is
# patched to point to this overlay before concretization.
#
# Usage
# -----
#   bash scripts/01_prepare_jaci_stack.sh
#
# Optional overrides
# ------------------
#   PROJECT_ROOT=/p/projetos/monan_das/$USER
#   TEST_ID=spack-stack-inpe-test-release-2.1-gcc12
#   INSTALL_ROOT=/p/projetos/monan_das/$USER/env/spack-stack/<name>/install
#   FRESH_INSTALL=1
#   SPACK_STACK_REF=release/2.1
#   SPACK_STACK_INPE_REF=main
#
# =============================================================================

set -euo pipefail

export PROJECT_ROOT="${PROJECT_ROOT:-/p/projetos/monan_das/${USER}}"
export TEST_ID="${TEST_ID:-spack-stack-inpe-test-release-2.1-gcc12}"
export WORK_ROOT="${PROJECT_ROOT}/work/${TEST_ID}"
export INSTALL_ROOT="${INSTALL_ROOT:-${PROJECT_ROOT}/env/spack-stack/${TEST_ID}/install}"
export LOG_ROOT="${PROJECT_ROOT}/logs/${TEST_ID}"
export FRESH_INSTALL="${FRESH_INSTALL:-0}"

export SPACK_STACK_REPO="${SPACK_STACK_REPO:-https://github.com/JCSDA/spack-stack.git}"
export SPACK_STACK_REF="${SPACK_STACK_REF:-release/2.1}"
export SPACK_STACK_INPE_REPO="${SPACK_STACK_INPE_REPO:-https://github.com/joaogerd/spack-stack-inpe.git}"
export SPACK_STACK_INPE_REF="${SPACK_STACK_INPE_REF:-main}"
export ENV_NAME="${ENV_NAME:-jaci-mpas-jedi-gcc12-craympich}"

export CRAYPE_CC="${CRAYPE_CC:-/opt/cray/pe/craype/2.7.33/bin/cc}"
export CRAYPE_CXX="${CRAYPE_CXX:-/opt/cray/pe/craype/2.7.33/bin/CC}"
export CRAYPE_FC="${CRAYPE_FC:-/opt/cray/pe/craype/2.7.33/bin/ftn}"
export CRAY_MPICH_OVERLAY_PREFIX="${CRAY_MPICH_OVERLAY_PREFIX:-${WORK_ROOT}/wrappers/cray-mpich-overlay}"

mkdir -p "${WORK_ROOT}" "${LOG_ROOT}"

if [ "${FRESH_INSTALL}" = "1" ]; then
  echo "[INFO] FRESH_INSTALL=1: removing INSTALL_ROOT=${INSTALL_ROOT}"
  rm -rf "${INSTALL_ROOT}"
fi
mkdir -p "${INSTALL_ROOT}"

printf '[INFO] WORK_ROOT=%s\n' "${WORK_ROOT}"
printf '[INFO] INSTALL_ROOT=%s\n' "${INSTALL_ROOT}"
printf '[INFO] LOG_ROOT=%s\n' "${LOG_ROOT}"
printf '[INFO] FRESH_INSTALL=%s\n' "${FRESH_INSTALL}"
printf '[INFO] CRAY_MPICH_OVERLAY_PREFIX=%s\n' "${CRAY_MPICH_OVERLAY_PREFIX}"

# -----------------------------------------------------------------------------
# Load validated JACI base environment
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
export MPICC="${CRAYPE_CC}"
export MPICXX="${CRAYPE_CXX}"
export MPIFC="${CRAYPE_FC}"
export MPIF77="${CRAYPE_FC}"
export MPIF90="${CRAYPE_FC}"

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
# Create global CrayPE MPI overlay
# -----------------------------------------------------------------------------

export REAL_CRAY_MPICH_PREFIX="${CRAY_MPICH_PREFIX:-${CRAY_MPICH_DIR:-/opt/cray/pe/mpich/8.1.31/ofi/gnu/12.3}}"
bash "${WORK_ROOT}/spack-stack-inpe/scripts/create_craype_mpi_overlay.sh"

test -x "${CRAY_MPICH_OVERLAY_PREFIX}/bin/mpicc"
test -x "${CRAY_MPICH_OVERLAY_PREFIX}/bin/mpicxx"
test -x "${CRAY_MPICH_OVERLAY_PREFIX}/bin/mpifort"

# -----------------------------------------------------------------------------
# Copy INPE JACI site and environment into JCSDA spack-stack
# -----------------------------------------------------------------------------

cd "${WORK_ROOT}/spack-stack"
mkdir -p configs/sites/tier2
rm -rf configs/sites/tier2/jaci
cp -a "${WORK_ROOT}/spack-stack-inpe/configs/sites/tier2/jaci" configs/sites/tier2/jaci
find configs/sites/tier2/jaci -maxdepth 1 -type f | sort \
  | tee "${LOG_ROOT}/03_installed_jaci_site_files.txt"

rm -rf "envs/${ENV_NAME}"
mkdir -p "envs/${ENV_NAME}"
cp -a "${WORK_ROOT}/spack-stack-inpe/envs/jaci/mpas-jedi-gcc12-craympich/." \
      "envs/${ENV_NAME}/"

# Patch the copied environment to use this run's install tree.
sed -i "s|root: .*env/spack-stack.*|root: ${INSTALL_ROOT}|" \
  "envs/${ENV_NAME}/site/config.yaml"

# Patch the copied environment to use the Cray MPICH overlay prefix. This is the
# key global fix for self.spec["mpi"].mpicc/mpicxx/mpifc on CrayPE.
sed -i "s|prefix: /opt/cray/pe/mpich/8.1.31/ofi/gnu/12.3|prefix: ${CRAY_MPICH_OVERLAY_PREFIX}|" \
  "envs/${ENV_NAME}/site/packages.yaml"

# Keep the site template in sync inside the copied spack-stack tree as evidence.
sed -i "s|prefix: /opt/cray/pe/mpich/8.1.31/ofi/gnu/12.3|prefix: ${CRAY_MPICH_OVERLAY_PREFIX}|" \
  "configs/sites/tier2/jaci/packages_gcc-12.3.yaml" \
  "configs/sites/tier2/jaci/packages.yaml" \
  2>/dev/null || true

echo "[INFO] Effective install tree root:"
grep -n "root:" "envs/${ENV_NAME}/site/config.yaml" \
  | tee "${LOG_ROOT}/04_effective_install_root.txt"

echo "[INFO] Effective cray-mpich prefix:"
grep -nA16 "cray-mpich:" "envs/${ENV_NAME}/site/packages.yaml" \
  | tee "${LOG_ROOT}/04_effective_cray_mpich_external.txt"

find "envs/${ENV_NAME}" -maxdepth 3 -type f | sort \
  | tee "${LOG_ROOT}/04_installed_jaci_env_files.txt"

# -----------------------------------------------------------------------------
# Initialize Spack submodule and source setup
# -----------------------------------------------------------------------------

echo "[INFO] Updating spack-stack submodules"
git submodule update --init --recursive 2>&1 | tee "${LOG_ROOT}/05_git_submodule_update.log"

test -x spack/bin/spack
test -f spack/share/spack/setup-env.sh
ls -l spack/bin/spack | tee "${LOG_ROOT}/05_check_spack_bin.txt"
ls -l spack/share/spack/setup-env.sh | tee "${LOG_ROOT}/05_check_spack_setup_env.txt"

source configs/sites/tier2/jaci/setup.sh
source setup.sh
which spack | tee "${LOG_ROOT}/06_which_spack.txt"
spack --version | tee "${LOG_ROOT}/06_spack_version.txt"

# -----------------------------------------------------------------------------
# Activate, audit and concretize
# -----------------------------------------------------------------------------

echo "[INFO] Activating environment"
spack env activate "envs/${ENV_NAME}"
spack env status | tee "${LOG_ROOT}/07_spack_env_status.txt"

spack config blame config    | tee "${LOG_ROOT}/08_spack_config_blame_config.txt"
spack config blame packages  | tee "${LOG_ROOT}/08_spack_config_blame_packages.txt"
spack config blame compilers | tee "${LOG_ROOT}/08_spack_config_blame_compilers.txt"
spack config blame modules   | tee "${LOG_ROOT}/08_spack_config_blame_modules.txt"

grep -R "gcc@12.3.0" "envs/${ENV_NAME}" \
  | tee "${LOG_ROOT}/09_check_gcc_external.txt"
grep -R "cray-mpich@8.1.31" "envs/${ENV_NAME}" \
  | tee "${LOG_ROOT}/09_check_cray_mpich_external.txt"
grep -R "MPICC\|MPICXX\|MPIFC\|MPIF77\|MPIF90" "envs/${ENV_NAME}" \
  | tee "${LOG_ROOT}/09_check_mpi_driver_vars.txt"

echo "[INFO] Concretizing"
spack concretize -f 2>&1 | tee "${LOG_ROOT}/10_spack_concretize.log"
spack find -v 2>&1 | tee "${LOG_ROOT}/11_spack_find_after_concretize.txt"

echo "[INFO] Preparation and concretization finished."
echo "[INFO] Logs are in: ${LOG_ROOT}"
