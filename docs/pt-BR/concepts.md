# Conceitos

Esta página explica os principais conceitos usados no `spack-stack-inpe`.

## Spack

Spack é o gerenciador de pacotes usado para construir e compor ambientes de software científico.

## spack-stack

O JCSDA `spack-stack` é uma camada organizada sobre o Spack usada por workflows JEDI e sistemas relacionados.

## Site

Um site descreve uma máquina HPC: compiladores, MPI, módulos, filesystem, mirrors, pacotes externos e políticas locais do Spack.

## Ambiente

Um ambiente descreve um stack de software concreto a ser criado a partir da configuração de site e das especificações de pacotes.

## Pacote externo

Um pacote externo é fornecido pelo sistema ou pelo fabricante e reutilizado pelo Spack em vez de ser compilado do zero.

## Concretização

Concretização é a etapa em que o Spack resolve versões, variantes, compiladores, providers e dependências.

## CrayPE

CrayPE fornece drivers como `cc`, `CC` e `ftn`. Na JACI, esses drivers são a interface esperada para o ambiente de programação Cray.
