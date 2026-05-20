# Arquitetura

O `spack-stack-inpe` separa infraestrutura, criação do stack e workflows de aplicação.

## Responsabilidades do repositório

```text
configs/   -> definições de site e ambiente
scripts/   -> preparação e validação operacional do stack
docs/      -> documentação para usuários, mantenedores e desenvolvedores
tests/     -> testes rápidos e auxiliares de validação
```

## Stack versus workflow

```text
módulos JACI + CrayPE
        |
        v
configs/sites/tier2/jaci
        |
        v
JCSDA spack-stack release/2.1
        |
        v
pacotes e módulos validados
        |
        v
workflows MONAN-JEDI / MPAS-JEDI
```

O repositório para no stack validado. Build e testes de MONAN/JEDI ou MPAS-JEDI devem ficar em repositórios separados.

## Decisão central

A JACI precisa de uma estratégia de overlay para Cray MPICH porque algumas receitas Spack esperam nomes tradicionais como `mpicc`, enquanto o CrayPE usa `cc`, `CC` e `ftn`.
