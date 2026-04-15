---
type: index
scope: global
updated: YYYY-MM-DD
version: 1.0.0
---

# Índice Mestre de Documentação

> **Ponto de entrada obrigatório para todos os agentes.**
> Leia este arquivo antes de qualquer outro. Ele define o que existe, onde está e quem deve ler o quê.

## Estado geral do projeto

| Campo | Valor |
|---|---|
| Projeto | [NOME DO PROJETO] |
| Status | `em-desenvolvimento` / `produção` / `manutenção` |
| Stack principal | [ex: Node.js + PostgreSQL + React] |
| Última atualização | YYYY-MM-DD |
| PO responsável | [nome] |

---

## Mapa de documentação por agente

Use esta tabela para saber exatamente o que ler ao iniciar uma tarefa.

| Você é | Leia obrigatoriamente | Consulte conforme necessidade |
|---|---|---|
| **Arquiteto Sênior** | `architecture/overview.md`, `adr/INDEX.md` | `api/INDEX.md`, `security/INDEX.md` |
| **Full-Stack Developer** | `architecture/overview.md`, `api/INDEX.md`, `design/INDEX.md` | `database/schema.md`, `security/policies.md` |
| **DB Architect** | `database/INDEX.md`, `architecture/overview.md` | `adr/INDEX.md`, `security/policies.md` |
| **Code Reviewer** | `architecture/overview.md`, `adr/INDEX.md` | `api/INDEX.md`, `security/policies.md` |
| **QA Tester** | `testing/test-strategy.md`, `design/INDEX.md` | `api/INDEX.md`, `database/schema.md` |
| **DevOps/SRE** | `operations/runbook.md`, `architecture/overview.md` | `security/policies.md`, `database/INDEX.md` |
| **Security Analyst** | `security/INDEX.md`, `architecture/overview.md` | `adr/INDEX.md`, `api/INDEX.md` |

---

## Estrutura de documentação

```
docs/
├── INDEX.md                        ← você está aqui
├── GUIDE.md                        ← como usar esta estrutura
│
├── adr/                            ← decisões arquiteturais irreversíveis
├── api/                            ← contratos de API (OpenAPI, GraphQL, eventos)
├── architecture/                   ← visão do sistema, componentes, diagramas
├── database/                       ← modelo de dados, schema, changelog
├── design/                         ← especificações de features
├── operations/                     ← runbooks, deploys, postmortems
├── security/                       ← políticas, threat models, vulnerabilidades
├── testing/                        ← estratégia de testes, cobertura, qualidade
└── decisions/                      ← decisões de produto e negócio
```

---

## Status de cada seção

| Seção | Status | Responsável | Última atualização |
|---|---|---|---|
| `adr/` | `ativo` | arquiteto-senior | YYYY-MM-DD |
| `api/` | `ativo` | arquiteto-senior | YYYY-MM-DD |
| `architecture/` | `ativo` | arquiteto-senior | YYYY-MM-DD |
| `database/` | `ativo` | db-architect | YYYY-MM-DD |
| `design/` | `ativo` | arquiteto-senior | YYYY-MM-DD |
| `operations/` | `ativo` | devops-sre | YYYY-MM-DD |
| `security/` | `ativo` | security-analyst | YYYY-MM-DD |
| `testing/` | `ativo` | qa-tester | YYYY-MM-DD |
| `decisions/` | `ativo` | po | YYYY-MM-DD |

---

## Convenções globais

- **Status de documentos**: `rascunho` → `em-revisão` → `ativo` → `depreciado` | `substituído-por: [arquivo]`
- **Nomenclatura**: `kebab-case` para arquivos. Prefixo de data `YYYY-MM-DD-` para documentos cronológicos (postmortems, decisões).
- **Frontmatter**: todo documento começa com bloco YAML de metadados (veja `GUIDE.md`).
- **Atualizações**: ao atualizar qualquer documento, atualize também o campo `updated` do frontmatter e registre o que mudou na seção `## Histórico de mudanças` do próprio documento.
- **Templates**: todo segmento tem um `_template.md`. Nunca crie documentos sem usar o template da seção.
- **Links**: use sempre caminhos relativos a partir da raiz de `docs/`.
