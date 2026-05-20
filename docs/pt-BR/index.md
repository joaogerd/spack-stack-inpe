# spack-stack-inpe

O `spack-stack-inpe` reúne configurações de site, scripts operacionais e documentação de validação para ambientes JCSDA `spack-stack` em sistemas HPC do INPE.

O alvo ativo atual é a JACI, usando `spack-stack release/2.1`, CrayPE e Cray MPICH. O material histórico da EGEON fica preservado como contexto legado, pois explica decisões anteriores envolvendo `spack-stack 1.7.0`, SLURM e automação de build do MPAS-JEDI.

## Limite do projeto

```text
spack-stack-inpe  -> cria e valida o stack de software
MONAN-JEDI        -> compila e testa MONAN/JEDI ou MPAS-JEDI usando o stack
MONAN-bundle      -> workflows de build e teste no nível da aplicação ou bundle
```

O código do MONAN, MPAS-JEDI ou JEDI fica em repositórios próprios.

## Seções principais

- Primeiros passos.
- Instalação.
- Uso.
- Configuração.
- Arquitetura.
- Conceitos.
- Histórico.
- JACI.
- Cookbook.
- Referência técnica.
- Desenvolvimento.
