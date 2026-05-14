---
type: index
scope: api
updated: YYYY-MM-DD
---

# API — Contratos de Interface

Toda API deve ter contrato definido **antes** da implementação.
O contrato é a fonte de verdade — implementação segue o contrato, nunca o contrário.

## Contratos ativos

| Arquivo | Tipo | Versão | Status | Responsável |
|---|---|---|---|---|
| — | REST / GraphQL / Eventos | — | — | — |

## Como usar

- REST: crie arquivos `.yaml` no padrão OpenAPI 3.x
- GraphQL: crie arquivos `.graphql` com o SDL completo
- Eventos/Mensagens: crie arquivos `.md` descrevendo payload, produtor e consumidores
- Nomeie os arquivos em `kebab-case` com sufixo do tipo: `users-api.yaml`, `order-events.md`
- Ao criar um contrato novo, adicione a entrada na tabela acima e comunique ao @fullstack-developer
