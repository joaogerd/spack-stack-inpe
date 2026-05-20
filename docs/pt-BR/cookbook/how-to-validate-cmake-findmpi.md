# Como validar CMake FindMPI

## Objetivo

Confirmar que o CMake detecta a implementação MPI esperada pelo ambiente `spack-stack` da JACI.

## Por que isso importa

Na JACI, o CrayPE usa `cc`, `CC` e `ftn`, enquanto alguns sistemas de build procuram nomes tradicionais de wrappers MPI. Esta validação verifica se o stack oferece uma interface MPI consistente ao CMake.

## Verificações sugeridas

```bash
which cc CC ftn
which mpicc mpicxx mpifort
```

Depois rode:

```bash
bash scripts/05_validate_cmake_findmpi.sh
```

## Critérios de sucesso

- O CMake completa a configuração.
- Os compiladores MPI detectados seguem a estratégia definida para a JACI.
- A saída fica armazenada junto aos logs de validação.
