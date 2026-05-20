# JACI

A JACI é o alvo ativo atual do `spack-stack-inpe`.

## Direção técnica confirmada

A linha atual da JACI considera:

```text
spack-stack release/2.1
CrayPE
PrgEnv-gnu/8.6.0
cray-mpich/8.1.31
PBS/qsub
mpirun via Cray PALS
módulos Tcl
```

## Política de filesystem

Builds, caches, árvores de instalação e logs devem usar o filesystem de projeto, não `$HOME`:

```text
/p/projetos/<grupo>/<usuario>
```

Para o trabalho MONAN/DAS:

```text
/p/projetos/monan_das/${USER}
```

## Política de wrappers MPI

No CrayPE, os drivers esperados são:

```text
cc
CC
ftn
```

Algumas receitas Spack procuram nomes tradicionais como `mpicc`, `mpicxx` e `mpifort`. Por isso, a configuração da JACI usa uma estratégia de overlay para Cray MPICH.

## Validação obrigatória

Cada validação na JACI deve preservar:

- módulos carregados;
- caminhos dos compiladores;
- caminhos dos wrappers MPI;
- logs de concretização;
- logs de instalação;
- logs de geração de módulos;
- saída de validação do CMake `FindMPI`.
