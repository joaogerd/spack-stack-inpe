cd /caminho/para/spack-stack-inpe

mkdir -p configs/sites/tier2/jaci

cat > configs/sites/tier2/jaci/setup.sh <<'EOF'
# JACI setup for spack-stack

module load PrgEnv-gnu/8.6.0
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

export JACI_SITE_NAME=jaci
export JACI_TARGET_COMPILER=gcc-native/13.2
export JACI_TARGET_MPI=cray-mpich/8.1.31
EOF

chmod +x configs/sites/tier2/jaci/setup.sh

git add configs/sites/tier2/jaci/setup.sh
git commit -m "Add JACI site setup script"
git push
