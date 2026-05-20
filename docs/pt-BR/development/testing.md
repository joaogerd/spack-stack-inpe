# Testes

Os testes no `spack-stack-inpe` são orientados à validação operacional do stack.

## Áreas de validação

- Sintaxe dos arquivos YAML.
- Execução dos scripts shell.
- Concretização do Spack.
- Instalação dos pacotes.
- Geração de módulos Tcl.
- Consistência dos wrappers MPI.
- Comportamento do CMake `FindMPI`.
- Coleta de logs.

## Sequência sugerida

A validação deve seguir a ordem operacional dos scripts numerados em `scripts/`, começando pela preparação da árvore JACI e terminando com a coleta de logs.

## Requisito para tag

Uma tag de validação só deve ser criada depois que outra pessoa reproduzir o fluxo completo com novo `TEST_ID`, árvore de instalação limpa e logs revisados.
