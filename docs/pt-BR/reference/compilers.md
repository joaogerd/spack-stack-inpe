# Compiladores

Esta página documenta a política de compiladores do `spack-stack-inpe`.

## Modelo da JACI

A linha JACI usa o ambiente de programação Cray. A interface ativa de compilação é fornecida pelos drivers do CrayPE:

```text
cc
CC
ftn
```

## O que documentar

Para cada configuração de compilador, registre:

- módulos carregados;
- versão reportada pelo driver;
- caminhos resolvidos por `which`;
- spec de compilador usada pelo Spack;
- arquitetura alvo;
- saída dos comandos de validação.

## Regra

Não assuma que o nome do módulo do compilador é igual à versão efetiva reportada pelo driver. Valide sempre com saída real de comando.
