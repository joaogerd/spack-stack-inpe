#!/usr/bin/env bash
# =============================================================================
# 03_generate_modules_tcl.sh
# =============================================================================
#
# Purpose
# -------
# Generate Tcl modulefiles for the installed JACI spack-stack-inpe environment.
#
# Prerequisite
# ------------
# Run first:
#
#   bash scripts/manual/01_create.sh
#   bash scripts/manual/02_install.sh
#
# Usage
# -----
#   bash scripts/manual/03_generate_modules_tcl.sh
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

spack module tcl refresh -y 2>&1 | tee "${LOG_ROOT}/13_spack_module_tcl_refresh.log"

find "envs/${ENV_NAME}/modules" -type f | sort \
  | tee "${LOG_ROOT}/14_generated_tcl_modules.txt"

echo "[INFO] Tcl modules generated under:"
echo "${WORK_ROOT}/spack-stack/envs/${ENV_NAME}/modules"
