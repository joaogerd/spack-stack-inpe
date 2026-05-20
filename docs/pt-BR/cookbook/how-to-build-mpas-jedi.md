# Como compilar o MPAS-JEDI

## Objetivo

Usar um ambiente `spack-stack-inpe` validado como base de software para workflows MPAS-JEDI ou MONAN/JEDI.

## Limite

Este repositório não deve conter o workflow completo de build do MPAS-JEDI. A compilação deve ser executada a partir de um repositório separado, como `MONAN-JEDI` ou `MONAN-bundle`.

## Fluxo esperado

1. Criar e validar o stack com o `spack-stack-inpe`.
2. Registrar o identificador da validação, por exemplo `STACK_TEST_ID`.
3. Carregar o ambiente do stack.
4. Entrar no repositório de workflow.
5. Configurar com CMake ou ecbuild.
6. Compilar e rodar testes fora do `spack-stack-inpe`.

## Verificação antes do build

```bash
module list
which cc CC ftn
which mpicc mpicxx mpifort
spack find
```
