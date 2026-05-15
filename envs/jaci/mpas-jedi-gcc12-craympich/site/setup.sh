# JACI environment site setup
#
# Purpose: load the validated JACI GCC 12.3 + Cray MPICH target.
# Use: source site/setup.sh from the active environment context.

module purge
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
