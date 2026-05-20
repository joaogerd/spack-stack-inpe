# Solução de problemas

As entradas de troubleshooting devem separar fatos confirmados, hipóteses técnicas, testes sugeridos e pontos ainda não verificados.

## Estrutura recomendada

```text
Sintoma
Fatos confirmados
Hipótese técnica
Comandos de diagnóstico
Solução proposta
Validação
Riscos e limitações
```

## Tópicos comuns

- Timeout de lock do Spack.
- Falhas de concretização.
- Detecção incorreta de wrappers MPI.
- Falhas no CMake `FindMPI`.
- Árvore de módulos não visível.
- Cache antigo do Spack.
- Uso indevido do `$HOME` para builds pesados.
- Falhas em componentes opcionais do `parallel-netcdf`.

## Diagnóstico básico

```bash
module list
which cc CC ftn
which mpicc mpicxx mpifort
spack debug report
spack find
env | sort
```
