#!/usr/bin/env bash
# =============================================================================
# 01_prepare_jaci_stack.sh
# =============================================================================
# Prepare a clean spack-stack tree using the selected INPE site configuration,
# create a JCSDA-defined environment and run concretization.
#
# Important boundary
# ------------------
# INPE provides the site configuration. JCSDA spack-stack provides the
# environment template that defines the scientific software stack.
#
# Default site:
#   SITE=jaci
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

load_site_config

export FRESH_INSTALL="${FRESH_INSTALL:-0}"

initialize_run_layout

if [[ "${FRESH_INSTALL}" = "1" ]]; then
  echo "[INFO] FRESH_INSTALL=1: removing INSTALL_ROOT=${INSTALL_ROOT}"
  rm -rf "${INSTALL_ROOT}"
fi
mkdir -p "${INSTALL_ROOT}"

print_run_context
printf '[INFO] FRESH_INSTALL=%s\n' "${FRESH_INSTALL}"
printf '[INFO] CRAY_MPICH_OVERLAY_PREFIX=%s\n' "${CRAY_MPICH_OVERLAY_PREFIX:-UNSET}"

# -----------------------------------------------------------------------------
# Load site base environment
# -----------------------------------------------------------------------------

site_base_env_path="${SPACK_STACK_INPE_ROOT}/${SITE_BASE_ENV_SCRIPT}"
if [[ ! -f "${site_base_env_path}" ]]; then
  echo "[ERROR] Site base environment script not found: ${site_base_env_path}" >&2
  exit 1
fi
source "${site_base_env_path}"

module list 2>&1 | tee "${LOG_ROOT}/00_module_list_base.txt"
{
  echo "[INFO] CRAY_MPICH_DIR=${CRAY_MPICH_DIR:-UNSET}"
  echo "[INFO] CRAY_MPICH_PREFIX=${CRAY_MPICH_PREFIX:-UNSET}"
} | tee "${LOG_ROOT}/00_cray_mpich_env.txt"
{
  which cc 2>/dev/null || true
  which CC 2>/dev/null || true
  which ftn 2>/dev/null || true
  which gcc 2>/dev/null || true
  which g++ 2>/dev/null || true
  which gfortran 2>/dev/null || true
} | tee "${LOG_ROOT}/00_which_compilers.txt"

# -----------------------------------------------------------------------------
# Clone/update JCSDA spack-stack
# -----------------------------------------------------------------------------

cd "${WORK_ROOT}"
if [[ ! -d spack-stack ]]; then
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
if [[ ! -d spack-stack-inpe ]]; then
  git clone "${SPACK_STACK_INPE_REPO}" spack-stack-inpe
fi

cd "${WORK_ROOT}/spack-stack-inpe"
git fetch --all --tags
git checkout "${SPACK_STACK_INPE_REF}"
git pull --ff-only || true
git rev-parse HEAD | tee "${LOG_ROOT}/02_spack_stack_inpe_commit.txt"
git status --short | tee "${LOG_ROOT}/02_spack_stack_inpe_status.txt"

# Reload site config from the cloned repository.
source "${WORK_ROOT}/spack-stack-inpe/${SITE_CONFIG_FILE#${SPACK_STACK_INPE_ROOT}/}"

# -----------------------------------------------------------------------------
# Optional site-specific CrayPE MPI overlay
# -----------------------------------------------------------------------------

if [[ "${SITE_USES_CRAY_MPICH_OVERLAY:-0}" = "1" ]]; then
  export REAL_CRAY_MPICH_PREFIX="${REAL_CRAY_MPICH_PREFIX:-${CRAY_MPICH_PREFIX:-${CRAY_MPICH_DIR:-${JACI_REAL_CRAY_MPICH_PREFIX:-}}}}"
  if [[ -z "${REAL_CRAY_MPICH_PREFIX}" ]]; then
    echo "[ERROR] REAL_CRAY_MPICH_PREFIX could not be determined." >&2
    exit 1
  fi

  bash "${WORK_ROOT}/spack-stack-inpe/scripts/create_craype_mpi_overlay.sh"

  test -x "${CRAY_MPICH_OVERLAY_PREFIX}/bin/mpicc"
  test -x "${CRAY_MPICH_OVERLAY_PREFIX}/bin/mpicxx"
  test -x "${CRAY_MPICH_OVERLAY_PREFIX}/bin/mpifort"
fi

# -----------------------------------------------------------------------------
# Copy INPE site configuration into the JCSDA spack-stack tree
# -----------------------------------------------------------------------------

cd "${WORK_ROOT}/spack-stack"
mkdir -p "$(dirname "${SITE_STACK_PATH}")"
rm -rf "${SITE_STACK_PATH}"
cp -a "${WORK_ROOT}/spack-stack-inpe/${SITE_STACK_PATH}" "${SITE_STACK_PATH}"
find "${SITE_STACK_PATH}" -maxdepth 1 -type f | sort \
  | tee "${LOG_ROOT}/03_installed_site_files.txt"

# Patch the copied site configuration to use the Cray MPICH overlay prefix when enabled.
if [[ "${SITE_USES_CRAY_MPICH_OVERLAY:-0}" = "1" ]]; then
  sed -i "s|prefix: ${JACI_REAL_CRAY_MPICH_PREFIX}|prefix: ${CRAY_MPICH_OVERLAY_PREFIX}|" \
    "${SITE_STACK_PATH}/packages_gcc-12.3.yaml" \
    "${SITE_STACK_PATH}/packages.yaml" \
    2>/dev/null || true
fi

# -----------------------------------------------------------------------------
# Initialize Spack submodule and source setup
# -----------------------------------------------------------------------------

echo "[INFO] Updating spack-stack submodules"
git submodule update --init --recursive 2>&1 | tee "${LOG_ROOT}/05_git_submodule_update.log"

test -x spack/bin/spack
test -f spack/share/spack/setup-env.sh
ls -l spack/bin/spack | tee "${LOG_ROOT}/05_check_spack_bin.txt"
ls -l spack/share/spack/setup-env.sh | tee "${LOG_ROOT}/05_check_spack_setup_env.txt"

source_spack_stack_site_setup
source_spack_stack_setup
which spack | tee "${LOG_ROOT}/06_which_spack.txt"
spack --version | tee "${LOG_ROOT}/06_spack_version.txt"

# -----------------------------------------------------------------------------
# Create environment using JCSDA spack-stack tooling
# -----------------------------------------------------------------------------

if [[ -z "${JCSDA_COMPILER}" ]]; then
  echo "[ERROR] JCSDA_COMPILER is not defined in ${SITE_CONFIG_FILE}" >&2
  exit 1
fi

rm -rf "envs/${ENV_NAME}"

echo "[INFO] Creating JCSDA spack-stack environment"
echo "[INFO] Command: spack stack create env --site ${JCSDA_SITE_NAME} --template ${JCSDA_ENV_TEMPLATE} --compiler ${JCSDA_COMPILER} --name ${ENV_NAME} --prefix ${INSTALL_ROOT}"

spack stack create env \
  --site "${JCSDA_SITE_NAME}" \
  --template "${JCSDA_ENV_TEMPLATE}" \
  --compiler "${JCSDA_COMPILER}" \
  --name "${ENV_NAME}" \
  --prefix "${INSTALL_ROOT}" \
  2>&1 | tee "${LOG_ROOT}/04_spack_stack_create_env.log"

if [[ "${SITE_USES_CRAY_MPICH_OVERLAY:-0}" = "1" ]]; then
  sed -i "s|prefix: ${JACI_REAL_CRAY_MPICH_PREFIX}|prefix: ${CRAY_MPICH_OVERLAY_PREFIX}|" \
    "envs/${ENV_NAME}/site/packages.yaml" \
    2>/dev/null || true
fi

echo "[INFO] Effective install tree root:"
grep -n "root:" "envs/${ENV_NAME}/site/config.yaml" \
  | tee "${LOG_ROOT}/04_effective_install_root.txt" || true

echo "[INFO] Effective cray-mpich prefix:"
grep -nA16 "cray-mpich:" "envs/${ENV_NAME}/site/packages.yaml" \
  | tee "${LOG_ROOT}/04_effective_cray_mpich_external.txt" || true

find "envs/${ENV_NAME}" -maxdepth 3 -type f | sort \
  | tee "${LOG_ROOT}/04_generated_env_files.txt"

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

grep -R "gcc@12.3" "envs/${ENV_NAME}" \
  | tee "${LOG_ROOT}/09_check_gcc_external.txt" || true
grep -R "cray-mpich@8.1.31" "envs/${ENV_NAME}" \
  | tee "${LOG_ROOT}/09_check_cray_mpich_external.txt" || true
grep -R "MPICC\|MPICXX\|MPIFC\|MPIF77\|MPIF90" "envs/${ENV_NAME}" \
  | tee "${LOG_ROOT}/09_check_mpi_driver_vars.txt" || true

echo "[INFO] Concretizing"
spack concretize -f 2>&1 | tee "${LOG_ROOT}/10_spack_concretize.log"
spack find -v 2>&1 | tee "${LOG_ROOT}/11_spack_find_after_concretize.txt"

echo "[INFO] Preparation and concretization finished."
echo "[INFO] Logs are in: ${LOG_ROOT}"
