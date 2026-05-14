---
type: index
scope: database
updated: YYYY-MM-DD
---

# Database — Modelo de Dados

Toda mudança de schema deve ser refletida aqui **antes** de chegar ao código.

## Documentos

| Arquivo | Conteúdo | Status |
|---|---|---|
| [schema.md](schema.md) | Modelo de dados atual completo | `rascunho` |
| [changelog.md](changelog.md) | Histórico de mudanças de schema (append-only) | `rascunho` |
| [data-policies.md](data-policies.md) | Classificação de dados, retenção, LGPD/GDPR | `rascunho` |

## Como usar

- `schema.md`: descreve o estado **atual** do modelo. Atualizado pelo @db-architect a cada migration.
- `changelog.md`: registro **append-only** — nunca edite entradas anteriores, apenas adicione novas.
- `data-policies.md`: revisado pelo @security-analyst. Classifica cada campo com dado sensível ou PII.
- Para novas entidades: produza o ERD antes de escrever qualquer migration e submeta ao @arquiteto-senior.
