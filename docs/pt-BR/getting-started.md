# Primeiros passos

Esta página orienta quem vai usar o `spack-stack-inpe` pela primeira vez.

## Ideia principal

O `spack-stack-inpe` não é o workflow de aplicação. Ele prepara e valida o stack de software que depois será usado por workflows MONAN/JEDI ou MPAS-JEDI.

## Alvo ativo

```text
JACI
spack-stack release/2.1
CrayPE
Cray MPICH
PBS/qsub
módulos Tcl
```

## Diagnóstico inicial

Antes de instalar ou adaptar o stack, colete informações reais da máquina:

```bash
uname -a
cat /etc/os-release
lscpu
module avail
module list
which cc CC ftn
which qsub mpirun
env | sort
```

Não reutilize valores da EGEON, Derecho, Hera ou outra máquina sem validação na JACI.
