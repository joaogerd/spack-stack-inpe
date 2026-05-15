

<!-- REPO_AUDIT_BEGIN -->

# Auditoria de Repositórios Locais

**Data de geração:** 2026-05-02 09:48:50

**Caminho auditado:** `/media/extra/wrk/dev`

## Objetivo

Este diretório foi auditado para identificar possíveis repositórios Git e SVN, verificar seu estado local/remoto e apontar diretórios que podem ser candidatos à limpeza da máquina local.

## Resumo da auditoria

- Total de registros analisados: **110**
- Repositórios encontrados: **110**
- Repositórios Git: **96**
- Repositórios SVN: **14**
- Candidatos à limpeza: **34**
- Critério de sem uso: **12 meses**

## Arquivos gerados

- `repo_audit_report.md`: relatório completo em Markdown.
- `repo_audit_report.csv`: relatório tabular para abertura em planilhas.
- `README.md`: este arquivo, com resumo da auditoria.

## Como interpretar

Os repositórios classificados como **atualizado e limpo** não possuem alterações locais detectadas, não possuem arquivos novos não rastreados, não possuem commits pendentes de push e não parecem estar atrás do remoto.

Os repositórios classificados como **repositório antigo e aparentemente sem uso** são candidatos à limpeza apenas porque estavam limpos e sem atividade recente conforme o critério configurado.

## Recomendações de limpeza

Antes de apagar qualquer diretório manualmente:

- confira o relatório Markdown completo;
- abra o diretório e execute `git status` ou `svn status`;
- confirme se existe remoto configurado;
- confirme se não há arquivos importantes fora do controle de versão;
- confirme se o diretório não é usado por scripts, ambientes ou workflows externos;
- faça backup se houver qualquer dúvida.

> Atenção: não apague diretórios apenas com base no relatório. Faça sempre uma conferência manual.

<!-- REPO_AUDIT_END -->
# spack-stack-inpe
