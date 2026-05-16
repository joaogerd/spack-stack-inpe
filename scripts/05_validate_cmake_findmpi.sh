#!/usr/bin/env bash
# =============================================================================
# 05_validate_cmake_findmpi.sh
# =============================================================================
# Run a minimal CMake FindMPI probe using the selected site environment.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

load_site_config
initialize_run_layout

source_spack_stack_site_setup
source_spack_stack_setup

mkdir -p "${WORK_ROOT}/probes/cmake-findmpi"
cd "${WORK_ROOT}/probes/cmake-findmpi"

cat > CMakeLists.txt <<'EOF'
cmake_minimum_required(VERSION 3.20)
project(test_findmpi LANGUAGES C CXX Fortran)

find_package(MPI REQUIRED COMPONENTS C CXX Fortran)

message(STATUS "MPI_C_COMPILER=${MPI_C_COMPILER}")
message(STATUS "MPI_CXX_COMPILER=${MPI_CXX_COMPILER}")
message(STATUS "MPI_Fortran_COMPILER=${MPI_Fortran_COMPILER}")
EOF

cmake -S . -B build \
  -DCMAKE_C_COMPILER="${CC}" \
  -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_Fortran_COMPILER="${FC}" \
  2>&1 | tee "${LOG_ROOT}/21_cmake_findmpi_probe.log"

grep -E "MPI_C_COMPILER|MPI_CXX_COMPILER|MPI_Fortran_COMPILER" \
  "${LOG_ROOT}/21_cmake_findmpi_probe.log" \
  | tee "${LOG_ROOT}/22_cmake_findmpi_summary.txt"
