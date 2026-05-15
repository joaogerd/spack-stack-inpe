#!/usr/bin/env bash
# =============================================================================
# 02_install.sh
# =============================================================================
#
# Purpose
# -------
# Install the already-concretized JACI spack-stack-inpe environment.
#
# Prerequisite
# ------------
# Run first:
#
#   bash scripts/manual/01_create.sh
#
# Usage
# -----
#   bash scripts/manual/02_install.sh
#
# =============================================================================

set -euo pipefail

export PROJECT_ROOT="${PROJECT_ROOT:-/p/projetos/monan_das/${USER}}"
export TEST_ID="${TEST_ID:-spack-stack-inpe-test-release-2.1-gcc12}"
export WORK_ROOT="${PROJECT_ROOT}/work/${TEST_ID}"
export LOG_ROOT="${PROJECT_ROOT}/logs/${TEST_ID}"
export ENV_NAME="${ENV_NAME:-jaci-mpas-jedi-gcc12-craympich}"

cd "${WORK_ROOT}/spack-stack"

source configs/sites/tier2/jaci/setup.sh
source setup.sh

spack env activate "envs/${ENV_NAME}"

spack install -j 16 2>&1 | tee "${LOG_ROOT}/11_spack_install.log"

spack find -v 2>&1 | tee "${LOG_ROOT}/12_spack_find_after_install.txt"

echo "[INFO] Install finished."
echo "[INFO] Logs are in: ${LOG_ROOT}"
