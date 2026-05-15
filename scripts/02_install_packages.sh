#!/usr/bin/env bash
# =============================================================================
# 02_install_packages.sh
# =============================================================================
#
# Purpose
# -------
# Compile and install all packages from the already concretized JACI
# spack-stack-inpe environment.
#
# Prerequisite
# ------------
# Run first:
#
#   bash scripts/01_prepare_jaci_stack.sh
#
# For a true fresh build, use a new TEST_ID or set FRESH_INSTALL=1 in the
# preparation phase:
#
#   FRESH_INSTALL=1 TEST_ID=<new-name> bash scripts/01_prepare_jaci_stack.sh
#   TEST_ID=<new-name> bash scripts/02_install_packages.sh
#
# Usage
# -----
#   bash scripts/02_install_packages.sh
#
# Optional overrides
# ------------------
#   PROJECT_ROOT=/p/projetos/monan_das/$USER
#   TEST_ID=spack-stack-inpe-test-release-2.1-gcc12
#   INSTALL_JOBS=16
#   FORCE_SOURCE_BUILD=0
#   SPACK_INSTALL_VERBOSE=1
#   SPACK_INSTALL_FAIL_FAST=1
#
# Notes
# -----
# FORCE_SOURCE_BUILD=1 passes --no-cache to spack install. This avoids using
# binary buildcache where available, but it does not delete an already-installed
# install tree. To rebuild from scratch, use FRESH_INSTALL=1 in phase 01 or use a
# new TEST_ID/INSTALL_ROOT.
#
# Spack can stay silent for long periods while building a package. This does not
# necessarily mean the process is stuck. During installation, monitor:
#
#   tail -f ${LOG_ROOT}/12_spack_install.log
#   ps -fu $USER | grep -E 'spack|make|ninja|cmake|gcc|g\+\+|gfortran|cc|ftn'
#
# If old Spack processes with PPID 1 remain from previous days, they may hold
# locks or confuse diagnosis. Inspect them before killing anything.
#
# =============================================================================

set -euo pipefail

export PROJECT_ROOT="${PROJECT_ROOT:-/p/projetos/monan_das/${USER}}"
export TEST_ID="${TEST_ID:-spack-stack-inpe-test-release-2.1-gcc12}"
export WORK_ROOT="${PROJECT_ROOT}/work/${TEST_ID}"
export LOG_ROOT="${PROJECT_ROOT}/logs/${TEST_ID}"
export ENV_NAME="${ENV_NAME:-jaci-mpas-jedi-gcc12-craympich}"
export INSTALL_JOBS="${INSTALL_JOBS:-16}"
export FORCE_SOURCE_BUILD="${FORCE_SOURCE_BUILD:-0}"
export SPACK_INSTALL_VERBOSE="${SPACK_INSTALL_VERBOSE:-1}"
export SPACK_INSTALL_FAIL_FAST="${SPACK_INSTALL_FAIL_FAST:-1}"

mkdir -p "${LOG_ROOT}"

cd "${WORK_ROOT}/spack-stack"

source configs/sites/tier2/jaci/setup.sh
source setup.sh
spack env activate "envs/${ENV_NAME}"

INSTALL_ARGS=(-j "${INSTALL_JOBS}")

if [ "${FORCE_SOURCE_BUILD}" = "1" ]; then
  INSTALL_ARGS=(--no-cache "${INSTALL_ARGS[@]}")
fi

if [ "${SPACK_INSTALL_VERBOSE}" = "1" ]; then
  INSTALL_ARGS=(-v "${INSTALL_ARGS[@]}")
fi

if [ "${SPACK_INSTALL_FAIL_FAST}" = "1" ]; then
  INSTALL_ARGS=(--fail-fast "${INSTALL_ARGS[@]}")
fi

{
  echo "[INFO] Starting package installation"
  echo "[INFO] Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "[INFO] WORK_ROOT=${WORK_ROOT}"
  echo "[INFO] LOG_ROOT=${LOG_ROOT}"
  echo "[INFO] ENV_NAME=${ENV_NAME}"
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
