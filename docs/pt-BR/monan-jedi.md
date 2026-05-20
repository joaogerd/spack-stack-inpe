# Integração MONAN/JEDI

O `spack-stack-inpe` fornece o stack de software validado que será consumido por workflows MONAN/JEDI.

## Separação de responsabilidades

```text
spack-stack-inpe
  - configuração de site
  - criação do stack
  - validação do stack
  - geração de módulos
  - documentação do ambiente

MONAN-JEDI ou MONAN-bundle
  - checkout do código fonte
  - configuração com CMake/ecbuild
  - compilação
  - ctest
  - logs da aplicação
```

## Fluxo esperado

1. Validar o stack da JACI com o `spack-stack-inpe`.
2. Registrar o identificador da validação, por exemplo `STACK_TEST_ID`.
3. Carregar o stack validado no repositório de workflow.
4. Configurar, compilar e testar MPAS-JEDI ou MONAN-JEDI fora deste repositório.

## Limite

Não adicione árvores de código do MONAN ou MPAS-JEDI a este repositório.
