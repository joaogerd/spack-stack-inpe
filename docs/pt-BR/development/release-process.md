# Processo de release

## Objetivo

Criar pontos rastreáveis de validação para o `spack-stack-inpe`.

## Modelo de branches

- `main` contém o estado estável e publicável.
- `develop` integra mudanças revisadas.
- branches temáticos entram em `develop` por pull request.
- releases validadas são promovidas de `develop` para `main`.

## Tags de validação

Formato sugerido para a JACI:

```text
jaci-spack-stack-2.1-gcc12-craympich-YYYYMMDD
```

Uma tag deve corresponder a logs revisados e a uma execução reproduzível de validação.
