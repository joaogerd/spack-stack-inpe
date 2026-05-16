#!/usr/bin/env bash
# =============================================================================
# scripts/sites/jaci/load_base_environment.sh
# =============================================================================
# Load the validated JACI CrayPE base environment.
#
# This file is intentionally site-specific. Generic scripts should call it only
# when SITE=jaci or when JACI-specific validation is explicitly required.
# =============================================================================

set -euo pipefail

module --force purge || module purge || true

IFS=':' read -r -a module_paths <<< "${JACI_MODULEPATH_ENTRIES:-}"
for d in "${module_paths[@]}"; do
  if [[ -n "${d}" && -d "${d}" ]]; then
    module use "${d}"
  fi
done

module load "${JACI_PRGENV_MODULE:-PrgEnv-gnu/8.6.0}"
module unload "${JACI_GCC_MODULE_TO_UNLOAD:-gcc-native/13.2}" 2>/dev/null || true
module load "${JACI_GCC_MODULE:-gcc-native/12.3}"
module load "${JACI_CRAYPE_TARGET_MODULE:-craype-x86-turin}"
module load "${JACI_CRAY_MPICH_MODULE:-cray-mpich/8.1.31}"
module load "${JACI_LIBFABRIC_MODULE:-libfabric/1.22.0}"
module load "${JACI_CRAY_PALS_MODULE:-cray-pals/1.6.1}"

export CC=cc
export CXX=CC
export FC=ftn
export F77=ftn
export F90=ftn
export MPICC="${CRAYPE_CC}"
export MPICXX="${CRAYPE_CXX}"
export MPIFC="${CRAYPE_FC}"
export MPIF77="${CRAYPE_FC}"
export MPIF90="${CRAYPE_FC}"
