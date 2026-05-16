#!/usr/bin/env bash
# =============================================================================
# 03_generate_tcl_modules.sh
# =============================================================================
# Generate Tcl modulefiles for the installed spack-stack-inpe environment.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

load_site_config
initialize_run_layout

activate_stack_environment

spack module tcl refresh -y 2>&1 | tee "${LOG_ROOT}/13_spack_module_tcl_refresh.log"

find "envs/${ENV_NAME}/modules" -type f | sort \
  | tee "${LOG_ROOT}/14_generated_tcl_modules.txt"

echo "[INFO] Tcl modules generated under:"
echo "${WORK_ROOT}/spack-stack/envs/${ENV_NAME}/modules"
