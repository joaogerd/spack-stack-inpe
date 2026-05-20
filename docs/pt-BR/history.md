# Histórico

Esta página registra a evolução técnica do `spack-stack-inpe`.

## Linha EGEON

A etapa inicial teve foco na EGEON, com `spack-stack 1.7.0`, `gnu9`, OpenMPI, Lmod e SLURM. Essa linha gerou instruções de instalação, testes com NetCDF, HDF5 e MPI, além de automação de build do MPAS-JEDI em repositório separado.

## Linha JACI

A etapa seguinte passou a focar a JACI, com CrayPE, Cray MPICH, PBS/qsub, Cray PALS e filesystem em `/p/projetos`.

## Consolidação

O papel atual do `spack-stack-inpe` é consolidar configurações de site, scripts de validação e documentação operacional. Workflows de aplicação devem permanecer em repositórios próprios.

## Regra

Preserve o histórico quando ele explicar decisões técnicas, mas mantenha claro qual é o caminho operacional ativo.
