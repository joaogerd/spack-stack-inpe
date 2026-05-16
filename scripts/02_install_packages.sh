#!/usr/bin/env bash
# =============================================================================
# 02_install_packages.sh
# =============================================================================
# Compile and install all packages from the already concretized spack-stack-inpe
# environment.
#
# Default site: JACI. Override with SITE=<site> when another site is added.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

load_site_config
initialize_run_layout

export INSTALL_JOBS="${INSTALL_JOBS:-16}"
export FORCE_SOURCE_BUILD="${FORCE_SOURCE_BUILD:-0}"
export SPACK_INSTALL_VERBOSE="${SPACK_INSTALL_VERBOSE:-1}"
export SPACK_INSTALL_FAIL_FAST="${SPACK_INSTALL_FAIL_FAST:-1}"

cd "${WORK_ROOT}/spack-stack"

activate_stack_environment

INSTALL_ARGS=(-j "${INSTALL_JOBS}")

if [[ "${FORCE_SOURCE_BUILD}" = "1" ]]; then
  INSTALL_ARGS=(--no-cache "${INSTALL_ARGS[@]}")
fi

if [[ "${SPACK_INSTALL_VERBOSE}" = "1" ]]; then
  INSTALL_ARGS=(-v "${INSTALL_ARGS[@]}")
fi

if [[ "${SPACK_INSTALL_FAIL_FAST}" = "1" ]]; then
  INSTALL_ARGS=(--fail-fast "${INSTALL_ARGS[@]}")
fi

{
  echo "[INFO] Starting package installation"
  echo "[INFO] Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  print_run_context
  echo "[INFO] INSTALL_JOBS=${INSTALL_JOBS}"
  echo "[INFO] FORCE_SOURCE_BUILD=${FORCE_SOURCE_BUILD}"
  echo "[INFO] SPACK_INSTALL_VERBOSE=${SPACK_INSTALL_VERBOSE}"
  echo "[INFO] SPACK_INSTALL_FAIL_FAST=${SPACK_INSTALL_FAIL_FAST}"
  echo "[INFO] Command: spack install ${INSTALL_ARGS[*]}"
  echo "[INFO] Live log: ${LOG_ROOT}/12_spack_install.log"
  echo "[INFO] If output appears quiet, check another shell with:"
  echo "[INFO]   tail -f ${LOG_ROOT}/12_spack_install.log"
  echo "[INFO]   ps -fu ${USER} | grep -E 'spack|make|ninja|cmake|gcc|g\\+\\+|gfortran|cc|ftn'"
} | tee "${LOG_ROOT}/12_spack_install.start.txt"

spack install "${INSTALL_ARGS[@]}" 2>&1 | tee "${LOG_ROOT}/12_spack_install.log"

spack find -v 2>&1 | tee "${LOG_ROOT}/13_spack_find_after_install.txt"

{
  echo "[INFO] Install finished."
  echo "[INFO] Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "[INFO] Logs are in: ${LOG_ROOT}"
} | tee "${LOG_ROOT}/12_spack_install.done.txt"
