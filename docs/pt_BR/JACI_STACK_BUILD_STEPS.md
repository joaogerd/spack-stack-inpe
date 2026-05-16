# Manual de construção e validação do spack-stack na JACI

Este documento descreve o procedimento operacional para preparar, concretizar, compilar e validar um ambiente `spack-stack` do JCSDA na máquina JACI do INPE usando o repositório `spack-stack-inpe`.

O objetivo é permitir que outra pessoa do grupo execute o processo completo de forma reprodutível, sem depender do histórico local de testes anteriores. Depois que o procedimento for repetido com sucesso por outro usuário, o repositório pode ser marcado com uma tag de validação.

## 1. Escopo

Este repositório contém apenas a configuração institucional do INPE/JACI para uso com o `spack-stack` do JCSDA.

Ele inclui:

```text
configs/sites/tier2/jaci/
envs/jaci/mpas-jedi-gcc12-craympich/
scripts/
docs/
```

Este repositório não deve conter o código fonte do MONAN, MPAS, MPAS-JEDI ou `jedi-bundle`. A etapa de compilação do MONAN/MPAS-JEDI deve ser tratada em outro repositório, por exemplo `MONAN-bundle`.

## 2. Ambiente alvo validado

O alvo operacional validado é:

```text
spack-stack: release/2.1
site: configs/sites/tier2/jaci
ambiente: envs/jaci/mpas-jedi-gcc12-craympich
compilador: gcc-native/12.3
ambiente Cray: PrgEnv-gnu/8.6.0
MPI: cray-mpich/8.1.31
interconexão: libfabric/1.22.0
launcher: cray-pals/1.6.1
arquitetura alvo: craype-x86-turin
módulos gerados: Tcl
```

O uso de `gcc-native/13.2` permanece experimental neste repositório, porque o `cray-mpich/8.1.31` disponível na JACI exporta o backend GNU em:

```text
/opt/cray/pe/mpich/8.1.31/ofi/gnu/12.3
```

e não há, no momento da validação, um backend correspondente em:

```text
/opt/cray/pe/mpich/8.1.31/ofi/gnu/13.2
```

## 3. Ponto técnico essencial: overlay do cray-mpich

Em ambiente CrayPE, os pacotes não devem usar diretamente:

```text
/opt/cray/pe/mpich/.../bin/mpicc
/opt/cray/pe/mpich/.../bin/mpicxx
/opt/cray/pe/mpich/.../bin/mpifort
```

O CrayPE espera que a compilação MPI use os drivers:

```text
cc
CC
ftn
```

Durante a validação inicial foi observado que receitas do Spack, como a do `hdf5`, podem chamar internamente:

```python
self.spec["mpi"].mpicc
```

Se o external `cray-mpich` aponta diretamente para o prefixo real do Cray MPICH, esse atributo resolve para o wrapper bruto `mpicc`, causando erro no CrayPE.

A solução adotada neste repositório é global: o script cria um overlay para o `cray-mpich` externo. Esse overlay contém wrappers compatíveis com nomes esperados pelo Spack:

```text
mpicc
mpicxx
mpic++
mpifort
mpif90
mpif77
```

mas internamente eles chamam:

```text
/opt/cray/pe/craype/2.7.33/bin/cc
/opt/cray/pe/craype/2.7.33/bin/CC
/opt/cray/pe/craype/2.7.33/bin/ftn
```

Com isso, qualquer receita que use `self.spec["mpi"].mpicc` passa a receber um caminho controlado pelo overlay, sem exigir patches específicos em `hdf5`, `fftw`, `netcdf-c`, `parallel-netcdf`, `parallelio`, `eckit`, `mpi4py` ou outros consumidores de MPI.

## 4. Preparação inicial

Entre na JACI e clone ou atualize o repositório:

```bash
cd /p/projetos/monan_das/${USER}/projects

git clone https://github.com/joaogerd/spack-stack-inpe.git 2>/dev/null || true
cd spack-stack-inpe

git pull
```

Escolha um identificador novo para o teste. Para validação institucional, não reutilize um `TEST_ID` antigo.

```bash
export TEST_ID="spack-stack-inpe-validation-$(date -u +%Y%m%dT%H%M%SZ)"
export FRESH_INSTALL=1
export FORCE_SOURCE_BUILD=1
export INSTALL_JOBS=1
export SPACK_INSTALL_VERBOSE=1
export SPACK_INSTALL_FAIL_FAST=1
```

Durante testes rápidos, `INSTALL_JOBS` pode ser aumentado. Para validação inicial e diagnóstico, use `INSTALL_JOBS=1`.

## 5. Fase 1: preparar árvore, site, ambiente e concretização

Execute:

```bash
bash scripts/01_prepare_jaci_stack.sh
```

Esta fase faz:

```text
carrega o ambiente base da JACI;
clona ou atualiza o spack-stack do JCSDA;
faz checkout de release/2.1;
atualiza submódulos do spack-stack;
clona ou atualiza o spack-stack-inpe;
copia configs/sites/tier2/jaci para a árvore do spack-stack;
copia o ambiente envs/jaci/mpas-jedi-gcc12-craympich;
cria o overlay do cray-mpich;
ajusta o prefixo do external cray-mpich para o overlay;
ajusta o install_tree.root para o INSTALL_ROOT do TEST_ID atual;
ativa o ambiente Spack;
executa spack config blame;
executa spack concretize.
```

Arquivos de log importantes:

```text
${LOG_ROOT}/00_module_list_base.txt
${LOG_ROOT}/03_craype_mpi_overlay.txt
${LOG_ROOT}/04_effective_cray_mpich_external.txt
${LOG_ROOT}/08_spack_config_blame_config.txt
${LOG_ROOT}/08_spack_config_blame_packages.txt
${LOG_ROOT}/10_spack_concretize.log
```

Valide se o `cray-mpich` efetivo aponta para o overlay:

```bash
export PROJECT_ROOT="/p/projetos/monan_das/${USER}"
export WORK_ROOT="${PROJECT_ROOT}/work/${TEST_ID}"
export ENV_NAME="jaci-mpas-jedi-gcc12-craympich"
export LOG_ROOT="${PROJECT_ROOT}/logs/${TEST_ID}"

grep -nA20 "cray-mpich:" \
  "${WORK_ROOT}/spack-stack/envs/${ENV_NAME}/site/packages.yaml"

cat "${LOG_ROOT}/03_craype_mpi_overlay.txt"
cat "${LOG_ROOT}/04_effective_cray_mpich_external.txt"
```

O prefixo esperado é semelhante a:

```text
/p/projetos/monan_das/<usuario>/work/<TEST_ID>/wrappers/cray-mpich-overlay
```

## 6. Fase 2: compilar e instalar pacotes

Execute:

```bash
bash scripts/02_install_packages.sh
```

Esta fase executa `spack install`. Com as variáveis recomendadas, o comando é executado com:

```text
--fail-fast
-v
--no-cache
-j ${INSTALL_JOBS}
```

Arquivo de log principal:

```text
${LOG_ROOT}/12_spack_install.log
```

Para acompanhar em outro terminal:

```bash
tail -f "${LOG_ROOT}/12_spack_install.log"
```

Se houver erro, colete:

```bash
tail -n 300 "${LOG_ROOT}/12_spack_install.log"

grep -nEi "error|failed|exception|traceback|cannot|fatal|killed|terminated|no space|permission denied|undefined reference|CMake Error|make.*Error" \
  "${LOG_ROOT}/12_spack_install.log" | tail -n 120 || true
```

## 7. Fase 3: gerar módulos Tcl

Execute:

```bash
bash scripts/03_generate_tcl_modules.sh
```

Esta fase executa:

```text
spack module tcl refresh -y
```

Os módulos são gerados sob:

```text
${WORK_ROOT}/spack-stack/envs/${ENV_NAME}/modules
```

Arquivo de log:

```text
${LOG_ROOT}/14_generated_tcl_modules.txt
```

## 8. Fase 4: validar o ambiente por módulos

Execute:

```bash
bash scripts/04_validate_environment.sh
```

Esta fase deve carregar o módulo do ambiente JEDI/MPAS gerado. A forma completa esperada é:

```text
cray-mpich/8.1.31/none/none/jedi-mpas-env/1.0.0
```

O trecho `none/none` é esperado para meta pacotes de ambiente do `spack-stack`, porque `jedi-mpas-env` não é uma biblioteca compilada comum. Ele é um meta pacote que carrega o conjunto de dependências do ambiente.

A validação verifica:

```text
cmake
ecbuild
python
nccmp
h5dump
h5diff
mpi4py
netCDF4
```

Logs principais:

```text
${LOG_ROOT}/15_module_avail_generated.txt
${LOG_ROOT}/16_module_list_stack_loaded.txt
${LOG_ROOT}/17_which_tools.txt
${LOG_ROOT}/18_python_version.txt
${LOG_ROOT}/19_python_mpi4py_check.txt
${LOG_ROOT}/20_python_netcdf4_check.txt
```

## 9. Fase 5: validar CMake FindMPI

Execute:

```bash
bash scripts/05_validate_cmake_findmpi.sh
```

O objetivo é confirmar que o CMake resolve MPI para os drivers CrayPE:

```text
MPI_C_COMPILER=/opt/cray/pe/craype/2.7.33/bin/cc
MPI_CXX_COMPILER=/opt/cray/pe/craype/2.7.33/bin/CC
MPI_Fortran_COMPILER=/opt/cray/pe/craype/2.7.33/bin/ftn
```

Logs principais:

```text
${LOG_ROOT}/21_cmake_findmpi_probe.log
${LOG_ROOT}/22_cmake_findmpi_summary.txt
```

## 10. Fase 6: coletar logs

Execute:

```bash
bash scripts/06_collect_logs.sh
```

Esta fase lista os logs gerados, imprime trechos finais dos logs principais e procura assinaturas comuns de erro.

Use esta fase para enviar evidências para revisão técnica.

## 11. Sequência completa para copiar e colar

```bash
cd /p/projetos/monan_das/${USER}/projects/spack-stack-inpe

git pull

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

## 12. Critérios de sucesso

A validação pode ser considerada bem-sucedida quando:

```text
spack concretize termina sem erro;
spack install termina sem erro;
os módulos Tcl são gerados;
o módulo jedi-mpas-env carrega corretamente;
cmake, ecbuild, python, nccmp, h5dump e h5diff são encontrados;
mpi4py importa corretamente;
netCDF4 importa corretamente;
CMake FindMPI resolve para cc, CC e ftn;
o external cray-mpich aponta para o overlay;
nenhum pacote tenta usar diretamente /opt/cray/pe/mpich/.../bin/mpicc durante a compilação.
```

## 13. Evidências recomendadas antes da tag

Antes de criar uma tag, arquive ou revise:

```text
${LOG_ROOT}/00_module_list_base.txt
${LOG_ROOT}/03_craype_mpi_overlay.txt
${LOG_ROOT}/04_effective_cray_mpich_external.txt
${LOG_ROOT}/10_spack_concretize.log
${LOG_ROOT}/12_spack_install.log
${LOG_ROOT}/14_generated_tcl_modules.txt
${LOG_ROOT}/16_module_list_stack_loaded.txt
${LOG_ROOT}/17_which_tools.txt
${LOG_ROOT}/21_cmake_findmpi_probe.log
${LOG_ROOT}/22_cmake_findmpi_summary.txt
```

Também registre:

```bash
cd /p/projetos/monan_das/${USER}/projects/spack-stack-inpe
git rev-parse HEAD

echo "TEST_ID=${TEST_ID}"
echo "WORK_ROOT=/p/projetos/monan_das/${USER}/work/${TEST_ID}"
echo "LOG_ROOT=/p/projetos/monan_das/${USER}/logs/${TEST_ID}"
```

## 14. Quando criar uma tag

Crie uma tag somente depois que:

```text
uma segunda pessoa executar o procedimento completo;
o TEST_ID usado for novo;
o install tree for novo ou explicitamente limpo;
a validação por módulo passar;
a validação CMake/FindMPI passar;
os logs forem revisados;
o commit validado estiver identificado.
```

Sugestão de tag:

```text
jaci-spack-stack-2.1-gcc12-craympich-YYYYMMDD
```

## 15. Pontos não cobertos por este repositório

Este repositório não valida automaticamente:

```text
compilação do MONAN/MPAS-JEDI;
execução completa do MPAS-JEDI;
ctest do MPAS-JEDI;
fluxos operacionais com PBS;
dados de teste do JEDI;
referências numéricas do MPAS-JEDI.
```

Essas etapas devem ser documentadas no repositório responsável pelo bundle ou workflow MONAN/MPAS-JEDI.
