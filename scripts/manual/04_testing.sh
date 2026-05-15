#!/usr/bin/env bash
# =============================================================================
# 04_testing.sh
# =============================================================================
#
# Purpose
# -------
# Test the generated Tcl modules for the JACI spack-stack-inpe environment.
#
# Important correction
# --------------------
# The generated module tree observed on JACI does not expose the short modules:
#
#   stack-gcc/12.3.0
#   stack-cray-mpich/8.1.31
#   jedi-mpas-env/1.0.0
#
# Instead, the JEDI MPAS meta environment is exposed as the hierarchical module:
#
#   cray-mpich/8.1.31/none/none/jedi-mpas-env/1.0.0
#
# This script loads that module directly.
#
# Prerequisite
# ------------
# Run first:
#
#   bash scripts/manual/01_create.sh
#   bash scripts/manual/02_install.sh
#   bash scripts/manual/03_generate_modules_tcl.sh
#
# Usage
# -----
#   bash scripts/manual/04_testing.sh
#
# =============================================================================

set -euo pipefail

export PROJECT_ROOT="${PROJECT_ROOT:-/p/projetos/monan_das/${USER}}"
export TEST_ID="${TEST_ID:-spack-stack-inpe-test-release-2.1-gcc12}"
export WORK_ROOT="${PROJECT_ROOT}/work/${TEST_ID}"
export LOG_ROOT="${PROJECT_ROOT}/logs/${TEST_ID}"
export ENV_NAME="${ENV_NAME:-jaci-mpas-jedi-gcc12-craympich}"
export JEDI_ENV_MODULE="${JEDI_ENV_MODULE:-cray-mpich/8.1.31/none/none/jedi-mpas-env/1.0.0}"

cd "${WORK_ROOT}/spack-stack"

source configs/sites/tier2/jaci/setup.sh

module use "${WORK_ROOT}/spack-stack/envs/${ENV_NAME}/modules"

module avail 2>&1 | tee "${LOG_ROOT}/15_module_avail_generated.txt"

if ! module avail "${JEDI_ENV_MODULE}" 2>&1 | grep -q "jedi-mpas-env"; then
  echo "[ERROR] Could not find expected module: ${JEDI_ENV_MODULE}" >&2
  echo "[ERROR] Available generated module files:" >&2
  find "${WORK_ROOT}/spack-stack/envs/${ENV_NAME}/modules" -type f | sort >&2
  exit 1
fi

echo "[INFO] Loading ${JEDI_ENV_MODULE}"
module load "${JEDI_ENV_MODULE}"

module list 2>&1 | tee "${LOG_ROOT}/16_module_list_stack_loaded.txt"

{
  echo "[INFO] Tool resolution after loading ${JEDI_ENV_MODULE}"
  command -v cmake || true
  command -v ecbuild || true
  command -v python || true
  command -v nccmp || true
  command -v h5dump || true
  command -v h5diff || true
} | tee "${LOG_ROOT}/17_which_tools.txt"

python --version | tee "${LOG_ROOT}/18_python_version.txt"
python -c "import mpi4py; print('mpi4py ok')" \
  | tee "${LOG_ROOT}/19_python_mpi4py_check.txt"
python -c "import netCDF4; print('netCDF4 ok')" \
  | tee "${LOG_ROOT}/20_python_netcdf4_check.txt"

echo "[INFO] Module validation finished."
