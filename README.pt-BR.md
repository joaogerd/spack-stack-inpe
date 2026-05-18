# spack-stack-inpe

Configurações de site e documentação operacional do INPE para implantação de ambientes JCSDA `spack-stack` em sistemas HPC institucionais.

O alvo inicial validado é a máquina **JACI**, usando `spack-stack release/2.1`, CrayPE e Cray MPICH, com foco no uso futuro com MONAN/JEDI e MPAS-JEDI.

English version: [README.md](README.md)

## Visão geral

O `spack-stack-inpe` armazena arquivos de configuração específicos de máquinas, scripts operacionais e notas de validação necessários para criar ambientes `spack-stack` reproduzíveis em máquinas HPC do INPE.

O repositório deve apoiar fluxos MONAN, JEDI e MPAS-JEDI sem armazenar o código-fonte do MONAN, MPAS-JEDI ou JEDI.

## Motivação

As máquinas HPC do INPE exigem adaptação local de compiladores, MPI, sistema de módulos, caminhos de filesystem, scheduler e pacotes externos. Este repositório registra essas decisões de forma reproduzível e auditável.

O trabalho atual para a JACI incorpora lições aprendidas na linha anterior da EGEON e no repositório experimental `jaci-spack-stack-bootstrap`. O objetivo agora é consolidar a configuração estável de site e a documentação operacional em um único repositório institucional.

## Relação com MONAN, MPAS-JEDI e JEDI

Este repositório fornece a pilha de software validada. Os workflows MONAN/JEDI consomem essa pilha a partir de repositórios separados.

```text
spack-stack-inpe  -> cria e valida o stack de software
MONAN-JEDI        -> compila e testa MONAN/JEDI ou MPAS-JEDI usando o stack
MONAN-bundle      -> workflows de build e teste no nível da aplicação ou bundle
```

## Status atual

| Máquina | Status | Stack | Observações |
|---|---|---|---|
| JACI | alvo ativo | `spack-stack release/2.1` | CrayPE, Cray MPICH, PBS |
| EGEON | histórico/legado | `spack-stack 1.7.0` | SLURM, `gnu9`, OpenMPI |

## Funcionalidades principais

- Layout compatível com o JCSDA `spack-stack`.
- Configuração de site para a JACI.
- Procedimento de preparação do ambiente CrayPE.
- Estratégia de overlay e wrappers para Cray MPICH.
- Scripts de validação reproduzíveis.
- Documentação em português e inglês.
- Notas operacionais de troubleshooting.

## Estrutura do repositório

```text
spack-stack-inpe/
├── configs/        # arquivos de configuração de site e ambientes
├── scripts/        # scripts operacionais para preparar e validar stacks
├── docs/           # documentação MkDocs em inglês e português
├── tests/          # testes rápidos e auxiliares de validação
├── README.md       # entrada rápida em inglês
├── README.pt-BR.md # entrada rápida em português
└── mkdocs.yml      # configuração do Material for MkDocs
```

## Instalação rápida na JACI

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

## Exemplo mínimo de uso

Depois que o stack estiver validado:

```bash
source <script-gerado-do-stack>
module avail
module load stack-gcc/<versao>
module load stack-cray-mpich/<versao>
module load jedi-mpas-env/<versao>
```

## Documentação

Documentação completa:

- [Documentação em português](docs/pt-BR/index.md)
- [Documentação em inglês](docs/en/index.md)

## Como contribuir

Use `develop` como branch de integração e crie branches temáticos para documentação, correções e atualizações de site.

Padrão recomendado:

```text
main         -> estado estável e publicável
develop      -> branch de integração
docs/*       -> documentação
feature/*    -> novas funcionalidades
fix/*        -> correções
refactor/*   -> reorganizações estruturais
experiment/* -> testes não produtivos
```

## Licença

LGPL v3.0, salvo definição institucional diferente.

## Limites do projeto

Este repositório não armazena o código-fonte do MONAN, MPAS-JEDI ou JEDI. Ele fornece o ambiente `spack-stack` validado para ser consumido por esses projetos.
