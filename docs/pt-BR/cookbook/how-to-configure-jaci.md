# Como configurar a JACI

## Objetivo

Preparar a configuração de site da JACI para uso com o JCSDA `spack-stack`.

## Diagnóstico inicial

```bash
uname -a
lscpu
module avail
module list
which cc CC ftn
which qsub mpirun
env | sort
```

## Áreas de configuração

- Preparação do ambiente CrayPE.
- Ambiente GNU.
- Cray MPICH como MPI da máquina.
- Caminhos no filesystem de projeto.
- Geração de módulos Tcl.
- Validação do CMake `FindMPI`.

## Regra importante

A JACI deve ser configurada a partir de observações feitas na própria JACI. Não copie valores de outras máquinas sem validação.
