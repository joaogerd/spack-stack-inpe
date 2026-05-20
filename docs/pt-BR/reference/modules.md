# Módulos

Esta página documenta a política de uso e geração de módulos.

## Sistemas de módulos

O trabalho ativo da JACI usa módulos Tcl. Outras máquinas podem usar Lmod ou outro layout de módulos e devem ser documentadas separadamente.

## O que registrar

- Caminhos base adicionados por `module use`.
- Módulos carregados pelo `setup.sh` do site.
- Módulos gerados pelo Spack.
- Meta-módulos gerados pelo `spack-stack`.
- Alterações necessárias em `MODULEPATH`.

## Comandos de validação

```bash
module avail
module list
echo "$MODULEPATH"
```

## Regra

Um stack só deve ser considerado utilizável quando a árvore de módulos gerada puder ser carregada em uma sessão limpa de shell.
