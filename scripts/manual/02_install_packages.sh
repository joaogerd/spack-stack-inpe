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
#   bash scripts/manual/01_prepare_jaci_stack.sh
#
# For a true fresh build, use a new TEST_ID or set FRESH_INSTALL=1 in the
# preparation phase:
#
#   FRESH_INSTALL=1 TEST_ID=<new-name> bash scripts/manual/01_prepare_jaci_stack.sh
#   TEST_ID=<new-name> bash scripts/manual/02_install_packages.sh
#
# Usage
# -----
#   bash scripts/manual/02_install_packages.sh
#
# Optional overrides
# ------------------
#   PROJECT_ROOT=/p/projetos/monan_das/$USER
#   TEST_ID=spack-stack-inpe-test-release-2.1-gcc12
#   INSTALL_JOBS=16
#   FORCE_SOURCE_BUILD=0
#
# Notes
# -----
# FORCE_SOURCE_BUILD=1 passes --no-cache to spack install. This avoids using
# binary buildcache where available, but it does not delete an already-installed
# install tree. To rebuild from scratch, use FRESH_INSTALL=1 in phase 01 or use a
# new TEST_ID/INSTALL_ROOT.
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

cd "${WORK_ROOT}/spack-stack"

source configs/sites/tier2/jaci/setup.sh
source setup.sh
spack env activate "envs/${ENV_NAME}"

if [ "${FORCE_SOURCE_BUILD}" = "1" ]; then
  INSTALL_ARGS=(--no-cache -j "${INSTALL_JOBS}")
else
  INSTALL_ARGS=(-j "${INSTALL_JOBS}")
fi

echo "[INFO] Running: spack install ${INSTALL_ARGS[*]}"
spack install "${INSTALL_ARGS[@]}" 2>&1 | tee "${LOG_ROOT}/12_spack_install.log"

spack find -v 2>&1 | tee "${LOG_ROOT}/13_spack_find_after_install.txt"

echo "[INFO] Install finished."
echo "[INFO] Logs are in: ${LOG_ROOT}"
