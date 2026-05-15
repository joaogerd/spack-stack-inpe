#!/usr/bin/env bash
# =============================================================================
# create_craype_mpi_overlay.sh
# =============================================================================
#
# Purpose
# -------
# Create a Cray MPICH overlay prefix for JACI/CrayPE.
#
# Why this exists
# ---------------
# In CrayPE, packages must compile MPI code through the CrayPE compiler drivers:
#
#   cc   for C
#   CC   for C++
#   ftn  for Fortran
#
# However, many Spack package recipes call:
#
#   self.spec["mpi"].mpicc
#   self.spec["mpi"].mpicxx
#   self.spec["mpi"].mpifc
#
# For an external `cray-mpich` prefix, these properties normally resolve to:
#
#   <mpi-prefix>/bin/mpicc
#   <mpi-prefix>/bin/mpicxx
#   <mpi-prefix>/bin/mpif90 or mpifort
#
# On JACI these raw Cray MPICH wrappers abort when CrayPE is loaded:
#
#   Error: CrayPE is loaded, use cc/CC/ftn instead of mpicc/mpicxx/mpifort
#
# This script creates an overlay prefix containing replacement mpicc/mpicxx/
# mpifort executables that delegate to cc/CC/ftn. Then Spack can keep using
# `self.spec["mpi"].mpicc`, but it resolves to the overlay shim instead of the
# raw Cray MPICH wrapper.
#
# The overlay intentionally supports MPICH-style query options such as:
#
#   -show
#   -compile-info
#   -link-info
#
# It does not implement OpenMPI-specific `-showme:*` options, because those are
# not part of the Cray MPICH interface and should not be used to validate JACI.
#
# The overlay also symlinks include/lib/share/etc/man from the real Cray MPICH
# prefix, so it behaves like a valid MPI prefix for Spack package logic.
#
# Usage
# -----
# Usually called by scripts/01_prepare_jaci_stack.sh.
#
# Manual use:
#
#   export PROJECT_ROOT=/p/projetos/monan_das/$USER
#   export TEST_ID=spack-stack-inpe-test-release-2.1-gcc12
#   bash scripts/create_craype_mpi_overlay.sh
#
# Outputs
# -------
#   ${CRAY_MPICH_OVERLAY_PREFIX}/bin/mpicc
#   ${CRAY_MPICH_OVERLAY_PREFIX}/bin/mpicxx
#   ${CRAY_MPICH_OVERLAY_PREFIX}/bin/mpifort
#   ${CRAY_MPICH_OVERLAY_PREFIX}/bin/mpif90
#   ${CRAY_MPICH_OVERLAY_PREFIX}/bin/mpif77
#
# =============================================================================

set -euo pipefail

export PROJECT_ROOT="${PROJECT_ROOT:-/p/projetos/monan_das/${USER}}"
export TEST_ID="${TEST_ID:-spack-stack-inpe-test-release-2.1-gcc12}"
export WORK_ROOT="${WORK_ROOT:-${PROJECT_ROOT}/work/${TEST_ID}}"
export LOG_ROOT="${LOG_ROOT:-${PROJECT_ROOT}/logs/${TEST_ID}}"

export CRAYPE_CC="${CRAYPE_CC:-/opt/cray/pe/craype/2.7.33/bin/cc}"
export CRAYPE_CXX="${CRAYPE_CXX:-/opt/cray/pe/craype/2.7.33/bin/CC}"
export CRAYPE_FC="${CRAYPE_FC:-/opt/cray/pe/craype/2.7.33/bin/ftn}"

export REAL_CRAY_MPICH_PREFIX="${REAL_CRAY_MPICH_PREFIX:-${CRAY_MPICH_PREFIX:-${CRAY_MPICH_DIR:-/opt/cray/pe/mpich/8.1.31/ofi/gnu/12.3}}}"
export CRAY_MPICH_OVERLAY_PREFIX="${CRAY_MPICH_OVERLAY_PREFIX:-${WORK_ROOT}/wrappers/cray-mpich-overlay}"

mkdir -p "${CRAY_MPICH_OVERLAY_PREFIX}/bin" "${LOG_ROOT}"

write_wrapper() {
  local path="$1"
  local compiler="$2"
  local base="$3"

  cat > "${path}" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
compiler="__COMPILER__"
base="__BASE__"

normalize_cray_opts() {
  local raw token payload part
  raw="$(${compiler} --cray-print-opts=all 2>/dev/null || true)"
  for token in ${raw}; do
    case "${token}" in
      -Wl,*)
        payload="${token#-Wl,}"
        IFS=',' read -r -a parts <<< "${payload}"
        for part in "${parts[@]}"; do
          case "${part}" in
            ""|--as-needed|--no-as-needed) ;;
            -l*|-L*) printf '%s ' "${part}" ;;
          esac
        done
        ;;
      -I*|-L*|-l*) printf '%s ' "${token}" ;;
    esac
  done
}

show_compile_flags() {
  normalize_cray_opts | tr ' ' '\n' | grep '^-I' | tr '\n' ' ' || true
  echo
}

show_link_flags() {
  normalize_cray_opts | tr ' ' '\n' | grep -E '^(-L|-l)' | tr '\n' ' ' || true
  echo
}

case "${1:-}" in
  -show|--show)
    echo "${base} $(normalize_cray_opts)"
    exit 0
    ;;
  -compile-info|--compile-info)
    show_compile_flags
    exit 0
    ;;
  -link-info|--link-info)
    show_link_flags
    exit 0
    ;;
esac

exec "${compiler}" "$@"
EOF

  sed -i "s#__COMPILER__#${compiler}#g" "${path}"
  sed -i "s#__BASE__#${base}#g" "${path}"
  chmod +x "${path}"
}

write_wrapper "${CRAY_MPICH_OVERLAY_PREFIX}/bin/mpicc"   "${CRAYPE_CC}"  "${CRAYPE_CC}"
write_wrapper "${CRAY_MPICH_OVERLAY_PREFIX}/bin/mpicxx"  "${CRAYPE_CXX}" "${CRAYPE_CXX}"
write_wrapper "${CRAY_MPICH_OVERLAY_PREFIX}/bin/mpic++"  "${CRAYPE_CXX}" "${CRAYPE_CXX}"
write_wrapper "${CRAY_MPICH_OVERLAY_PREFIX}/bin/mpifort" "${CRAYPE_FC}"  "${CRAYPE_FC}"
write_wrapper "${CRAY_MPICH_OVERLAY_PREFIX}/bin/mpif90"  "${CRAYPE_FC}"  "${CRAYPE_FC}"
write_wrapper "${CRAY_MPICH_OVERLAY_PREFIX}/bin/mpif77"  "${CRAYPE_FC}"  "${CRAYPE_FC}"

if [[ -d "${REAL_CRAY_MPICH_PREFIX}" ]]; then
  for entry in include lib lib64 share etc man; do
    if [[ -e "${REAL_CRAY_MPICH_PREFIX}/${entry}" && ! -e "${CRAY_MPICH_OVERLAY_PREFIX}/${entry}" ]]; then
      ln -s "${REAL_CRAY_MPICH_PREFIX}/${entry}" "${CRAY_MPICH_OVERLAY_PREFIX}/${entry}"
    fi
  done
fi

{
  echo "[INFO] Cray MPICH overlay prefix: ${CRAY_MPICH_OVERLAY_PREFIX}"
  echo "[INFO] Real Cray MPICH prefix:    ${REAL_CRAY_MPICH_PREFIX}"
  echo "[INFO] mpicc -> ${CRAYPE_CC}"
  echo "[INFO] mpicxx -> ${CRAYPE_CXX}"
  echo "[INFO] mpifort/mpif90/mpif77 -> ${CRAYPE_FC}"
  ls -l "${CRAY_MPICH_OVERLAY_PREFIX}/bin"
} | tee "${LOG_ROOT}/03_craype_mpi_overlay.txt"
