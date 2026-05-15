#!/usr/bin/env bash
# =============================================================================
# 05_testing_cmake.sh
# =============================================================================
#
# Purpose
# -------
# Run a minimal CMake FindMPI probe using the validated JACI CrayPE environment.
#
# Expected behavior
# -----------------
# FindMPI should resolve to CrayPE drivers:
#
#   cc
#   CC
#   ftn
#
# Prerequisite
# ------------
# Run first:
#
#   bash scripts/manual/01_create.sh
#
# Usage
# -----
#   bash scripts/manual/05_testing_cmake.sh
#
# =============================================================================

set -euo pipefail

export PROJECT_ROOT="${PROJECT_ROOT:-/p/projetos/monan_das/${USER}}"
export TEST_ID="${TEST_ID:-spack-stack-inpe-test-release-2.1-gcc12}"
export WORK_ROOT="${PROJECT_ROOT}/work/${TEST_ID}"
export LOG_ROOT="${PROJECT_ROOT}/logs/${TEST_ID}"

source "${WORK_ROOT}/spack-stack/configs/sites/tier2/jaci/setup.sh"
source "${WORK_ROOT}/spack-stack/setup.sh"

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
