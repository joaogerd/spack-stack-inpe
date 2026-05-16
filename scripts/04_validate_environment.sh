#!/usr/bin/env bash
# =============================================================================
# 04_validate_environment.sh
# =============================================================================
# Validate the generated Tcl module tree for a spack-stack-inpe site environment.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

load_site_config
initialize_run_layout

export JEDI_ENV_MODULE="${JEDI_ENV_MODULE:-${JACI_ENV_MODULE:-cray-mpich/8.1.31/none/none/jedi-mpas-env/1.0.0}}"

cd "${WORK_ROOT}/spack-stack"
source_spack_stack_site_setup
module use "${WORK_ROOT}/spack-stack/envs/${ENV_NAME}/modules"

module avail 2>&1 | tee "${LOG_ROOT}/16_module_avail_generated.txt"
module load "${JEDI_ENV_MODULE}"
module list 2>&1 | tee "${LOG_ROOT}/17_module_list_stack_loaded.txt"

{
  command -v cmake || true
  command -v ecbuild || true
  command -v python || true
  command -v nccmp || true
  command -v h5dump || true
  command -v h5diff || true
} | tee "${LOG_ROOT}/18_which_tools.txt"

python --version | tee "${LOG_ROOT}/19_python_version.txt"
python -c "import mpi4py; print('mpi4py ok')" | tee "${LOG_ROOT}/20_python_mpi4py_check.txt"
python -c "import netCDF4; print('netCDF4 ok')" | tee "${LOG_ROOT}/21_python_netcdf4_check.txt"
