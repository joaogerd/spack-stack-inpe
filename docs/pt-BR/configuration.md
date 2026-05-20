# Configuração

Esta página explica como o `spack-stack-inpe` organiza configuração de site e definição de ambiente.

## Camadas de configuração

```text
configuração de site      -> descreve a máquina HPC
definição de ambiente     -> descreve o stack de software
scripts operacionais      -> preparam, instalam, validam e coletam logs
```

## Configuração de site

Arquivos de site devem descrever apenas a infraestrutura local:

```text
configs/sites/tier2/jaci/
├── config.yaml
├── mirrors.yaml
├── modules.yaml
├── packages.yaml
├── packages_gcc-*.yaml
├── setup.sh
└── README.md
```

A camada de site deve definir compiladores, MPI, pacotes externos, caminhos de módulos, premissas de filesystem e configurações locais do Spack.

## Regra

Não misture infraestrutura da máquina com lógica de workflow MONAN/JEDI.
