---
type: index
scope: operations
updated: YYYY-MM-DD
---

# Operations — Operações e Confiabilidade

## Documentos principais

| Arquivo | Conteúdo | Status |
|---|---|---|
| [runbook.md](runbook.md) | Procedimentos operacionais críticos | `rascunho` |

## Postmortems

| Arquivo | Incidente | Severidade | Data | Status |
|---|---|---|---|---|
| — | — | — | — | — |

## Como usar

- `runbook.md`: documento vivo com comandos reais e executáveis. Atualizado pelo @devops-sre após cada incidente ou mudança de infraestrutura.
- Postmortems: copie `postmortems/_template.md`, nomeie como `YYYY-MM-DD-nome-do-incidente.md` e adicione a entrada na tabela acima.
- Postmortems são **blameless** — foco em sistemas e processos, nunca em pessoas.
- Severidade: `P1` (crítico, produção fora) | `P2` (degradado, impacto parcial) | `P3` (baixo impacto)
