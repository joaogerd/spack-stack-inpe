# JACI setup for JCSDA spack-stack
#
# Purpose
# -------
# Load the base HPE/Cray programming environment required to build and use
# the JACI spack-stack site configuration.
#
# Context
# -------
# JACI uses CrayPE. In this environment, the correct compiler drivers for
# builds are:
#
#   cc   for C
#   CC   for C++
#   ftn  for Fortran
#
# Do not force packages or CMake to use the raw Cray MPICH wrappers directly,
# such as mpicc, mpicxx or mpifort. When CrayPE is loaded, those wrappers can
# produce errors indicating that cc, CC and ftn must be used instead.
#
# Validation status
# -----------------
# This setup uses the validated GNU 12.3 + Cray MPICH target.
#
# The newer gcc-native/13.2 module exists on JACI, but cray-mpich/8.1.31 still
# exports:
#
#   CRAY_MPICH_DIR=/opt/cray/pe/mpich/8.1.31/ofi/gnu/12.3
#   CRAY_MPICH_PREFIX=/opt/cray/pe/mpich/8.1.31/ofi/gnu/12.3
#
# and the following directory does not exist:
#
#   /opt/cray/pe/mpich/8.1.31/ofi/gnu/13.2
#
# Therefore GCC 13.2 is not used here as the production target. A GCC 13.2
# configuration would be an experimental/hybrid target until explicitly
# validated.
#
# How to use
# ----------
# Source this file from inside a shell before creating, concretizing,
# installing or loading the JACI spack-stack environment:
#
#   source configs/sites/tier2/jaci/setup.sh
#
# Do not execute it in a subshell with `bash setup.sh`, because the module and
# environment changes must remain active in the current shell.
#
# This file intentionally resets the module state and explicitly unloads
# gcc-native/13.2 before loading gcc-native/12.3. The explicit unload is kept
# even after `module purge` because gcc-native/13.2 is the default GNU backend
# on JACI and may be restored by local module initialization behavior.
#
# Exported metadata
# -----------------
# The generic variables below identify the active site, compiler target and MPI
# target without embedding the site name in the variable itself:
#
#   SITE_NAME
#   TARGET_COMPILER
#   TARGET_MPI

module purge || { echo "ERROR: module purge failed while initializing JACI." >&2; return 1 2>/dev/null || exit 1; }

module load PrgEnv-gnu/8.6.0 || {
  echo "ERROR: failed to load PrgEnv-gnu/8.6.0." >&2
  return 1 2>/dev/null || exit 1
}

# Some JACI login environments leave or reintroduce a generic GNU compiler
# module such as gcc/12.3.0/zstd/1.5.7 when PrgEnv-gnu is loaded. That module
# belongs to the same compiler family and conflicts with the validated CrayPE
# backend gcc-native/12.3. Normalize the family before loading the target.
__JACI_TARGET_COMPILER="gcc-native/12.3"
IFS=':' read -r -a __JACI_LOADED_MODULES <<< "${LOADEDMODULES:-}"
for __JACI_MODULE in "${__JACI_LOADED_MODULES[@]}"; do
  case "${__JACI_MODULE}" in
    gcc/*|gcc-native/*)
      if [[ "${__JACI_MODULE}" != "${__JACI_TARGET_COMPILER}" ]]; then
        module unload "${__JACI_MODULE}" || {
          echo "ERROR: failed to unload conflicting compiler module ${__JACI_MODULE}." >&2
          unset __JACI_TARGET_COMPILER __JACI_MODULE __JACI_LOADED_MODULES
          return 1 2>/dev/null || exit 1
        }
      fi
      ;;
  esac
done
unset __JACI_MODULE __JACI_LOADED_MODULES

module load "${__JACI_TARGET_COMPILER}" || {
  echo "ERROR: failed to load validated compiler ${__JACI_TARGET_COMPILER}." >&2
  unset __JACI_TARGET_COMPILER
  return 1 2>/dev/null || exit 1
}
unset __JACI_TARGET_COMPILER

module load craype-x86-turin || {
  echo "ERROR: failed to load craype-x86-turin." >&2
  return 1 2>/dev/null || exit 1
}
module load cray-mpich/8.1.31 || {
  echo "ERROR: failed to load cray-mpich/8.1.31." >&2
  return 1 2>/dev/null || exit 1
}
module load libfabric/1.22.0 || {
  echo "ERROR: failed to load libfabric/1.22.0." >&2
  return 1 2>/dev/null || exit 1
}
module load cray-pals/1.6.1 || {
  echo "ERROR: failed to load cray-pals/1.6.1." >&2
  return 1 2>/dev/null || exit 1
}

export CC=cc
export CXX=CC
export FC=ftn
export F77=ftn
export F90=ftn

export MPICC=cc
export MPICXX=CC
export MPIFC=ftn
export MPIF77=ftn
export MPIF90=ftn

export SITE_NAME=jaci
export TARGET_COMPILER=gcc-native/12.3
export TARGET_MPI=cray-mpich/8.1.31
