#!/usr/bin/env bash
# =============================================================================
# 06_collect_logs.sh
# =============================================================================
# Collect and summarize logs from the selected spack-stack-inpe validation flow.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

load_site_config

echo "[INFO] LOG_ROOT=${LOG_ROOT}"

if [[ ! -d "${LOG_ROOT}" ]]; then
  echo "[ERROR] LOG_ROOT does not exist: ${LOG_ROOT}" >&2
  exit 1
fi

find "${LOG_ROOT}" -type f | sort

echo
echo "[INFO] Last lines from concretize log:"
tail -n 120 "${LOG_ROOT}/10_spack_concretize.log" 2>/dev/null || true

echo
echo "[INFO] Last lines from install log:"
tail -n 120 "${LOG_ROOT}/12_spack_install.log" 2>/dev/null || true

echo
echo "[INFO] Last lines from module validation log:"
tail -n 80 "${LOG_ROOT}/17_module_list_stack_loaded.txt" 2>/dev/null || true

echo
echo "[INFO] Tool resolution:"
cat "${LOG_ROOT}/18_which_tools.txt" 2>/dev/null || true

echo
echo "[INFO] Python validation:"
cat "${LOG_ROOT}/19_python_version.txt" 2>/dev/null || true
cat "${LOG_ROOT}/20_python_mpi4py_check.txt" 2>/dev/null || true
cat "${LOG_ROOT}/21_python_netcdf4_check.txt" 2>/dev/null || true

echo
echo "[INFO] CMake FindMPI summary:"
cat "${LOG_ROOT}/22_cmake_findmpi_summary.txt" 2>/dev/null || true

echo
echo "[INFO] Errors found:"
grep -RniE "error|failed|cannot|conflict|No such file|undefined reference|CMake Error|spack error" "${LOG_ROOT}" \
  | grep -vi "keep_werror" \
  | head -n 200 || true
