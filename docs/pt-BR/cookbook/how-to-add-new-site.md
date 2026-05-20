# Como adicionar novo site

## Objetivo

Adicionar uma nova máquina HPC do INPE ao `spack-stack-inpe` sem misturar infraestrutura da máquina com lógica de aplicação.

## Passos

1. Coletar diagnóstico da máquina.
2. Identificar compiladores, MPI, módulos, filesystem e scheduler.
3. Definir quais pacotes devem ser usados como externos.
4. Criar `configs/sites/<tier>/<site>/`.
5. Adicionar `config.yaml`, `packages.yaml`, arquivos específicos por compilador, `modules.yaml`, `mirrors.yaml` e `setup.sh`.
6. Criar ou reutilizar uma definição de ambiente.
7. Rodar concretização e instalação.
8. Validar módulos, MPI e CMake.
9. Documentar riscos, limitações e pontos ainda não verificados.

## Evidência necessária

Todo novo site deve se basear em saída real de comandos ou documentação oficial da máquina. Não infira compilador, MPI ou caminhos de módulos a partir de outro cluster.
