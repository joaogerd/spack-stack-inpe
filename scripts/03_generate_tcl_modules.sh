#!/usr/bin/env bash
# =============================================================================
# 03_generate_modules_tcl.sh
# =============================================================================
#
# Purpose
# -------
# Generate Tcl modulefiles and spack-stack meta modules for the installed JACI
# spack-stack-inpe environment.
#
# Prerequisite
# ------------
# Run first:
#
#   bash scripts/01_prepare_jaci_stack.sh
#   bash scripts/02_install_packages.sh
#
# Usage
# -----
#   bash scripts/03_generate_tcl_modules.sh
#
# Notes
# -----
# `spack module tcl refresh` generates the regular Tcl modulefiles for the
# installed specs. `spack stack setup-meta-modules` then creates the stack-level
# entry modules such as stack-gcc and stack-cray-mpich when supported by the
# active spack-stack environment configuration.
#
# =============================================================================

set -euo pipefail

export PROJECT_ROOT="${PROJECT_ROOT:-/p/projetos/monan_das/${USER}}"
export TEST_ID="${TEST_ID:-spack-stack-inpe-test-release-2.1-gcc12}"
export WORK_ROOT="${PROJECT_ROOT}/work/${TEST_ID}"
export LOG_ROOT="${PROJECT_ROOT}/logs/${TEST_ID}"
export ENV_NAME="${ENV_NAME:-jaci-mpas-jedi-gcc12-craympich}"

mkdir -p "${LOG_ROOT}"

cd "${WORK_ROOT}/spack-stack"

source configs/sites/tier2/jaci/setup.sh
source setup.sh

spack env activate "envs/${ENV_NAME}"

echo "[INFO] Refreshing Tcl modulefiles..."
spack module tcl refresh -y 2>&1 | tee "${LOG_ROOT}/13_spack_module_tcl_refresh.log"

echo "[INFO] Creating spack-stack meta modules..."
spack stack setup-meta-modules 2>&1 | tee "${LOG_ROOT}/14_spack_stack_setup_meta_modules.log"

echo "[INFO] Listing generated Tcl modulefiles..."
find "envs/${ENV_NAME}/modules" -type f | sort \
  | tee "${LOG_ROOT}/15_generated_tcl_modules.txt"

echo "[INFO] Tcl modules generated under:"
echo "${WORK_ROOT}/spack-stack/envs/${ENV_NAME}/modules"

echo "[INFO] To inspect stack meta modules, run:"
echo "module use ${WORK_ROOT}/spack-stack/envs/${ENV_NAME}/modules"
echo "module avail stack"
