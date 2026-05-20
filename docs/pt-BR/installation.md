# Instalação

Esta página descreve o procedimento operacional para criar e validar o ambiente `spack-stack` da JACI.

## Diretório recomendado

Use o filesystem institucional de projeto para builds, caches, instalações e logs:

```bash
cd /p/projetos/monan_das/${USER}/projects
```

Evite usar `$HOME` para builds pesados do Spack.

## Fluxo de validação

```bash
export TEST_ID="spack-stack-inpe-validation-$(date -u +%Y%m%dT%H%M%SZ)"
export FRESH_INSTALL=1
export FORCE_SOURCE_BUILD=1
export INSTALL_JOBS=1
export SPACK_INSTALL_VERBOSE=1
export SPACK_INSTALL_FAIL_FAST=1

bash scripts/01_prepare_jaci_stack.sh
bash scripts/02_install_packages.sh
bash scripts/03_generate_tcl_modules.sh
bash scripts/04_validate_environment.sh
bash scripts/05_validate_cmake_findmpi.sh
bash scripts/06_collect_logs.sh
```

## Critérios de sucesso

- concretização sem erro;
- instalação sem erro;
- módulos Tcl gerados;
- CMake `FindMPI` validado;
- logs preservados com o `TEST_ID` usado na execução.
