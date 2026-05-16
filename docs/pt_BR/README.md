# Documentação em português

Este diretório contém a documentação operacional em português para preparar, instalar e validar o `spack-stack` do JCSDA na máquina JACI do INPE usando as configurações deste repositório.

## Documentos

```text
JACI_STACK_BUILD_STEPS.md
```

Manual principal com o procedimento completo desde a preparação da árvore `spack-stack` até a validação final do ambiente.

## Estado atual

O foco validado do repositório é a preparação de um ambiente `spack-stack release/2.1` para JACI com:

```text
PrgEnv-gnu/8.6.0
gcc-native/12.3
cray-mpich/8.1.31
CrayPE drivers cc, CC e ftn
módulos Tcl gerados pelo Spack
```

O fluxo atual usa um overlay para o `cray-mpich` externo. Esse overlay faz com que chamadas internas do Spack, como `self.spec["mpi"].mpicc`, resolvam para wrappers controlados que chamam os drivers corretos do CrayPE, em vez de usar diretamente os wrappers `mpicc`, `mpicxx` e `mpifort` do diretório do Cray MPICH.

## Regra para validação institucional

Antes de criar uma tag, recomenda-se que outra pessoa do grupo execute o procedimento completo em um `TEST_ID` novo, sem reaproveitar diretórios antigos de `work`, `logs` ou `install`.
