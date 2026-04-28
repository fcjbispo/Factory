---
type: index
scope: backlog
updated: 2026-04-28
---

# Backlog — Gestão de Produção

Documentos de gestão de produção para projetos em operação contínua.

## Documentos principais

| Arquivo | Conteúdo | Status |
|---|---|---|
| [backlog-rules.md](backlog-rules.md) | Regras de priorização e fluxo do backlog | `rascunho` |
| [issues/INDEX.md](issues/INDEX.md) | Bugs e problemas reportados | `rascunho` |
| [improvements/INDEX.md](improvements/INDEX.md) | Melhorias e features técnicas | `rascunho` |
| [tech-debt/INDEX.md](tech-debt/INDEX.md) | Débito técnico e refactoring | `rascunho` |
| [documentation/INDEX.md](documentation/INDEX.md) | Gestão de documentação | `rascunho` |
| [security/INDEX.md](security/INDEX.md) | Vulnerabilidades e patches | `rascunho` |
| [performance/INDEX.md](performance/INDEX.md) | Bottlenecks e tuning | `rascunho` |
| [dependencies/INDEX.md](dependencies/INDEX.md) | Updates e EOL | `rascunho` |
| [data/INDEX.md](data/INDEX.md) | Migrations e backup | `rascunho` |

## Como usar

- Todos os itens seguem o template `_template.md`
- Nomenclatura: `YYYY-MM-DD-titulo-curto.md`
- Status: `aberto` → `em-analise` → `priorizado` → `em-progresso` → `resolvido` | `rejeitado` | `suspenso`
- Prioridade: `P1` (crítico) | `P2` (alto) | `P3` (médio) | `P4` (baixo)

## Responsáveis

- **PO** — triage e priorização
- **Arquiteto** — impacto técnico e estimativa
- **Agentes** — execução conforme papel

## Fluxo

1. Item é reportado (qualquer agente ou PO)
2. PO faz triage inicial
3. Arquiteto avalia impacto técnico
4. PO prioriza
5. Agente executa
6. Code reviewer valida
7. QA tester verifica
8. DevOps/SRE deploya
9. Item fechado
