#!/usr/bin/env bash
# =============================================================================
# scripts/lib/common.sh
# =============================================================================
# Shared helpers for spack-stack-inpe operational scripts.
#
# Generic workflow logic belongs here. Machine-specific values belong in
# configs/sites/<layout>/<site>/site.env or in scripts/sites/<site>/.
# =============================================================================

set -euo pipefail

spack_stack_inpe_repo_root() {
  local source_dir
  source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "${source_dir}/../.." && pwd
}

export SPACK_STACK_INPE_ROOT="${SPACK_STACK_INPE_ROOT:-$(spack_stack_inpe_repo_root)}"
export SITE="${SITE:-jaci}"

load_site_config() {
  local site_config=""

  if [[ -n "${SITE_CONFIG_FILE:-}" ]]; then
    site_config="${SITE_CONFIG_FILE}"
  elif [[ -f "${SPACK_STACK_INPE_ROOT}/configs/sites/tier2/${SITE}/site.env" ]]; then
    site_config="${SPACK_STACK_INPE_ROOT}/configs/sites/tier2/${SITE}/site.env"
  elif [[ -f "${SPACK_STACK_INPE_ROOT}/configs/sites/${SITE}/site.env" ]]; then
    site_config="${SPACK_STACK_INPE_ROOT}/configs/sites/${SITE}/site.env"
  fi

  if [[ -z "${site_config}" || ! -f "${site_config}" ]]; then
    echo "[ERROR] Site configuration not found for SITE=${SITE}" >&2
    return 1
  fi

  source "${site_config}"
  export SITE_CONFIG_FILE="${site_config}"

  export PROJECT_ROOT="${PROJECT_ROOT:-${DEFAULT_PROJECT_ROOT}}"
  export TEST_ID="${TEST_ID:-${DEFAULT_TEST_ID}}"
  export WORK_ROOT="${WORK_ROOT:-${PROJECT_ROOT}/work/${TEST_ID}}"
  export INSTALL_ROOT="${INSTALL_ROOT:-${PROJECT_ROOT}/env/spack-stack/${TEST_ID}/install}"
  export LOG_ROOT="${LOG_ROOT:-${PROJECT_ROOT}/logs/${TEST_ID}}"
  export ENV_NAME="${ENV_NAME:-${DEFAULT_ENV_NAME}}"
  export SPACK_STACK_REPO="${SPACK_STACK_REPO:-${DEFAULT_SPACK_STACK_REPO}}"
  export SPACK_STACK_REF="${SPACK_STACK_REF:-${DEFAULT_SPACK_STACK_REF}}"
  export SPACK_STACK_INPE_REPO="${SPACK_STACK_INPE_REPO:-${DEFAULT_SPACK_STACK_INPE_REPO}}"
  export SPACK_STACK_INPE_REF="${SPACK_STACK_INPE_REF:-${DEFAULT_SPACK_STACK_INPE_REF}}"
  export SITE_STACK_PATH="${SITE_STACK_PATH:-${DEFAULT_SITE_STACK_PATH}}"
  export JCSDA_SITE_NAME="${JCSDA_SITE_NAME:-${SITE}}"
  export JCSDA_ENV_TEMPLATE="${JCSDA_ENV_TEMPLATE:-empty}"
  export JCSDA_COMPILER="${JCSDA_COMPILER:-}"
}

initialize_run_layout() {
  mkdir -p "${WORK_ROOT}" "${LOG_ROOT}"
}

print_run_context() {
  echo "[INFO] SITE=${SITE}"
  echo "[INFO] SITE_CONFIG_FILE=${SITE_CONFIG_FILE}"
  echo "[INFO] PROJECT_ROOT=${PROJECT_ROOT}"
  echo "[INFO] TEST_ID=${TEST_ID}"
  echo "[INFO] WORK_ROOT=${WORK_ROOT}"
  echo "[INFO] INSTALL_ROOT=${INSTALL_ROOT:-UNSET}"
  echo "[INFO] LOG_ROOT=${LOG_ROOT}"
  echo "[INFO] ENV_NAME=${ENV_NAME}"
  echo "[INFO] SPACK_STACK_REF=${SPACK_STACK_REF}"
  echo "[INFO] SITE_STACK_PATH=${SITE_STACK_PATH}"
  echo "[INFO] JCSDA_SITE_NAME=${JCSDA_SITE_NAME}"
  echo "[INFO] JCSDA_ENV_TEMPLATE=${JCSDA_ENV_TEMPLATE}"
  echo "[INFO] JCSDA_COMPILER=${JCSDA_COMPILER:-UNSET}"
}

source_spack_stack_site_setup() {
  local setup_file="${WORK_ROOT}/spack-stack/${SITE_STACK_PATH}/setup.sh"
  if [[ ! -f "${setup_file}" ]]; then
    echo "[ERROR] Site setup.sh not found: ${setup_file}" >&2
    return 1
  fi
  source "${setup_file}"
}

source_spack_stack_setup() {
  local setup_file="${WORK_ROOT}/spack-stack/setup.sh"
  if [[ ! -f "${setup_file}" ]]; then
    echo "[ERROR] spack-stack setup.sh not found: ${setup_file}" >&2
    return 1
  fi
  source "${setup_file}"
}

activate_stack_environment() {
  cd "${WORK_ROOT}/spack-stack"
  source_spack_stack_site_setup
  source_spack_stack_setup
  spack env activate "envs/${ENV_NAME}"
}
