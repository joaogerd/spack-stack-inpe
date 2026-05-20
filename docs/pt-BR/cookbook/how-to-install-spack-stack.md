# Como instalar o spack-stack

## Objetivo

Criar um ambiente `spack-stack` validado para a JACI usando os scripts operacionais deste repositório.

## Pré-requisitos

- Acesso à JACI.
- Acesso ao filesystem de projeto em `/p/projetos`.
- `git` disponível.
- Sistema de módulos disponível.
- PBS/qsub e `mpirun` disponíveis.

## Comandos

```bash
cd /p/projetos/monan_das/${USER}/projects

git clone https://github.com/joaogerd/spack-stack-inpe.git
cd spack-stack-inpe

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

## Resultado esperado

Um ambiente `spack-stack` local e reproduzível fica criado e validado para a JACI.

## Validação

Revise os logs coletados pelo script `06_collect_logs.sh` e confirme que concretização, instalação, geração de módulos e validação do CMake `FindMPI` terminaram sem erro.
