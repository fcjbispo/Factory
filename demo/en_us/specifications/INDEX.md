---
type: index
scope: global
updated: 2026-05-18
version: 1.0.0
---

# Credit Approval Microservice — Project Index

> **Mandatory entry point for all agents.**
> Read this file first before accessing any other document in this repository.

## Project Status

| Field | Value |
|---|---|
| Project | Credit Approval Microservice |
| Status | `em-desenvolvimento` |
| Stack | Node.js + Express + PostgreSQL + Docker |
| Last Updated | 2026-05-18 |
| PO | Product Owner (Demo) |

---

## Agent Map

| Agent | Must Read | Consult as Needed |
|---|---|---|
| **@senior-architect** | `domain/INDEX.md`, `domain/context-map.md`, `architecture/overview.md`, `adr/INDEX.md` | `api/INDEX.md`, `security/INDEX.md` |
| **@fullstack-developer** | `domain/INDEX.md`, `architecture/overview.md`, `api/INDEX.md`, `design/INDEX.md` | `domain/credit-approval-language.md`, `database/schema.md`, `security/policies.md` |
| **@db-architect** | `domain/INDEX.md`, `database/INDEX.md`, `architecture/overview.md` | `adr/INDEX.md`, `security/policies.md` |
| **@code-reviewer** | `domain/INDEX.md`, `architecture/overview.md`, `adr/INDEX.md` | `api/INDEX.md`, `security/policies.md` |
| **@qa-tester** | `domain/INDEX.md`, `testing/test-strategy.md`, `design/INDEX.md` | `api/INDEX.md`, `database/schema.md` |
| **@devops-sre** | `operations/runbook.md`, `architecture/overview.md` | `security/policies.md`, `database/INDEX.md` |
| **@security-analyst** | `domain/INDEX.md`, `security/INDEX.md`, `architecture/overview.md` | `adr/INDEX.md`, `api/INDEX.md` |

---

## Document Sections

| Section | Purpose | Owner |
|---|---|---|
| `domain/` | Bounded contexts, ubiquitous language, context map | senior-architect |
| `adr/` | Architecture Decision Records | senior-architect |
| `api/` | API contracts (OpenAPI) | senior-architect |
| `architecture/` | System overview, diagrams, tech stack | senior-architect |
| `database/` | Schema, migrations, data policies | db-architect |
| `design/` | Functional specifications per feature | senior-architect |
| `operations/` | Runbooks, deployment, monitoring | devops-sre |
| `security/` | Policies, threat models, compliance | security-analyst |
| `testing/` | Test strategy, coverage criteria | qa-tester |
| `decisions/` | Product decisions and business rules | po |
| `backlog/` | Items, tech debt, improvements | po |
| `context/` | Active focus, progress, blockers | todos |

---

## Quick Start

1. Read `docs/templates/GUIDE.md` for documentation conventions
2. Read `domain/context-map.md` to understand the domain
3. Read `architecture/overview.md` for system context
4. Consult the relevant section for your task

---

## Conventions

- All documents require YAML frontmatter (`type`, `status`, `owner`, `updated`)
- No document created without using the section's `_template.md`
- ADRs are never edited after acceptance — replaced by a new one
- `database/changelog.md` is append-only
- Active vulnerabilities are NOT stored in the repo
