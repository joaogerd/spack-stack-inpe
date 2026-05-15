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
# Exported metadata
# -----------------
# The generic variables below identify the active site, compiler target and MPI
# target without embedding the site name in the variable itself:
#
#   SITE_NAME
#   TARGET_COMPILER
#   TARGET_MPI

module load PrgEnv-gnu/8.6.0
module unload gcc-native/13.2 2>/dev/null || true
module load gcc-native/12.3
module load craype-x86-turin
module load cray-mpich/8.1.31
module load libfabric/1.22.0
module load cray-pals/1.6.1

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
