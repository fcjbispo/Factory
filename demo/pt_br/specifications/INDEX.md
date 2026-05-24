---
type: index
scope: global
updated: 2026-05-18
version: 1.0.0
---

# Microserviço de Aprovação de Crédito — Índice do Projeto

> **Ponto de entrada obrigatório para todos os agentes.**
> Leia este arquivo primeiro antes de acessar qualquer outro documento neste repositório.

## Status do Projeto

| Campo | Valor |
|---|---|
| Projeto | Microserviço de Aprovação de Crédito |
| Status | `em-desenvolvimento` |
| Stack | Node.js + Express + PostgreSQL + Docker |
| Última Atualização | 2026-05-18 |
| PO | Product Owner (Demo) |

---

## Mapa de Agentes

| Agente | Deve Ler | Consultar Conforme Necessário |
|---|---|---|
| **@senior-architect** | `domain/INDEX.md`, `domain/context-map.md`, `architecture/overview.md`, `adr/INDEX.md` | `api/INDEX.md`, `security/INDEX.md` |
| **@fullstack-developer** | `domain/INDEX.md`, `architecture/overview.md`, `api/INDEX.md`, `design/INDEX.md` | `domain/credit-approval-language.md`, `database/schema.md`, `security/policies.md` |
| **@db-architect** | `domain/INDEX.md`, `database/INDEX.md`, `architecture/overview.md` | `adr/INDEX.md`, `security/policies.md` |
| **@code-reviewer** | `domain/INDEX.md`, `architecture/overview.md`, `adr/INDEX.md` | `api/INDEX.md`, `security/policies.md` |
| **@qa-tester** | `domain/INDEX.md`, `testing/test-strategy.md`, `design/INDEX.md` | `api/INDEX.md`, `database/schema.md` |
| **@devops-sre** | `operations/runbook.md`, `architecture/overview.md` | `security/policies.md`, `database/INDEX.md` |
| **@security-analyst** | `domain/INDEX.md`, `security/INDEX.md`, `architecture/overview.md` | `adr/INDEX.md`, `api/INDEX.md` |

---

## Seções de Documentos

| Seção | Propósito | Dono |
|---|---|---|
| `domain/` | Bounded contexts, linguagem ubíqua, mapa de contexto | senior-architect |
| `adr/` | Architecture Decision Records | senior-architect |
| `api/` | Contratos de API (OpenAPI) | senior-architect |
| `architecture/` | Visão geral do sistema, diagramas, stack tecnológico | senior-architect |
| `database/` | Schema, migrações, políticas de dados | db-architect |
| `design/` | Especificações funcionais por feature | senior-architect |
| `operations/` | Runbooks, deploy, monitoramento | devops-sre |
| `security/` | Políticas, modelos de ameaça, compliance | security-analyst |
| `testing/` | Estratégia de testes, critérios de cobertura | qa-tester |
| `decisions/` | Decisões de produto e regras de negócio | po |
| `backlog/` | Itens, dívida técnica, melhorias | po |
| `context/` | Foco atual, progresso, bloqueios | todos |

---

## Início Rápido

1. Leia `docs/templates/GUIDE.md` para convenções de documentação
2. Leia `domain/context-map.md` para entender o domínio
3. Leia `architecture/overview.md` para contexto do sistema
4. Consulte a seção relevante para sua tarefa

---

## Convenções

- Todos os documentos requerem frontmatter YAML (`type`, `status`, `owner`, `updated`)
- Nenhum documento criado sem usar o `_template.md` da seção
- ADRs nunca são editados após aceitação — substituídos por um novo
- `database/changelog.md` é append-only
- Vulnerabilidades ativas NÃO são armazenadas no repositório
