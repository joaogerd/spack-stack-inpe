# Como usar pacotes externos

## Objetivo

Declarar no Spack pacotes já fornecidos pela máquina HPC quando não for necessário recompilá-los.

## Candidatos comuns

- MPI fornecido pela máquina.
- Compiladores do sistema.
- Python do site.
- Bibliotecas matemáticas da máquina.
- Ferramentas básicas necessárias ao bootstrap.

## Riscos

Pacotes externos podem introduzir inconsistências de ABI, compilador, MPI ou módulos. Sempre valide se o pacote externo é compatível com o compilador e o MPI selecionados.

## Nota sobre a JACI

Na JACI, o `cray-mpich` é fornecido pela máquina. A estratégia de overlay existe porque algumas receitas Spack esperam nomes como `mpicc`, `mpicxx` e `mpifort`, enquanto o CrayPE usa `cc`, `CC` e `ftn`.
