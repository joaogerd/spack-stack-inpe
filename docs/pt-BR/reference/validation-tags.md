# Tags de validação

Tags de validação identificam estados do stack que foram reproduzidos e revisados.

## Formato sugerido

```text
jaci-spack-stack-2.1-gcc12-craympich-YYYYMMDD
```

## Requisitos mínimos

Antes de criar uma tag de validação:

- execute com novo `TEST_ID`;
- use árvore de instalação limpa;
- preserve os logs;
- revise a saída de concretização e instalação;
- valide os módulos;
- valide o CMake `FindMPI`;
- peça que outro usuário reproduza o procedimento quando possível.

## Significado da tag

Uma tag de validação significa que o procedimento de criação do stack atingiu os critérios de sucesso documentados. Ela não valida automaticamente todos os workflows de aplicação que podem usar o stack.
