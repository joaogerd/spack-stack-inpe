# Uso

Esta página explica como usar um ambiente `spack-stack-inpe` já validado.

## Carregar o stack validado

Use o script de ativação gerado ou documentado para a execução de validação escolhida:

```bash
source <script-gerado-do-stack>
```

Depois verifique a árvore de módulos:

```bash
module avail
module list
```

## Carregar módulos esperados

Os nomes exatos dependem da instalação validada. Um fluxo típico na JACI deve disponibilizar módulos de compilador, MPI e ambiente JEDI:

```bash
module load stack-gcc/<versao>
module load stack-cray-mpich/<versao>
module load jedi-mpas-env/<versao>
```

## Verificar antes de usar

```bash
which cc CC ftn
which mpicc mpicxx mpifort
spack find
```

O comportamento dos wrappers MPI é específico da JACI e deve estar consistente com a estratégia de overlay Cray MPICH documentada na referência técnica.
