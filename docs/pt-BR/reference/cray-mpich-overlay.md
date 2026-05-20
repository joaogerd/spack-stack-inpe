# Overlay Cray MPICH

Esta página documenta a estratégia de overlay para o Cray MPICH na JACI.

## Problema

Algumas receitas do Spack consultam o provedor MPI usando nomes tradicionais de wrappers, por exemplo:

```python
self.spec["mpi"].mpicc
```

Na JACI com CrayPE carregado, os drivers esperados são:

```text
cc
CC
ftn
```

## Estratégia

O overlay fornece nomes tradicionais como `mpicc`, `mpicxx` e `mpifort`, mas internamente redireciona para os drivers do CrayPE.

## Motivo

Essa estratégia evita aplicar correções locais em várias receitas que consomem MPI.

## Validação

```bash
which mpicc mpicxx mpifort
mpicc -show || true
mpicxx -show || true
mpifort -show || true
which cc CC ftn
```

A saída deve ser preservada junto com os logs de validação.

## Status

Esta é uma solução operacional específica da JACI e deve ser revisada sempre que o ambiente CrayPE ou Cray MPICH for alterado.
