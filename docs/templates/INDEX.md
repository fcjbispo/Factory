---
type: index
scope: global
updated: YYYY-MM-DD
version: 1.3.0
---

# Master Documentation Index

> **Mandatory entry point for all agents.**
> Read this file before any other. It defines what exists, where it is, and who should read what.

## Overall project status

| Field | Value |
|---|---|
| Project | [PROJECT NAME] |
| Status | `in-development` / `production` / `maintenance` |
| Main stack | [ex: Node.js + PostgreSQL + React] |
| Last updated | YYYY-MM-DD |
| Responsible PO | [name] |

---

## Documentation map by agent

Use this table to know exactly what to read when starting a task.

| You are | Must read | Consult as needed |
|---|---|---|
| **Senior Architect** | `domain/INDEX.md`, `domain/context-map.md`, `architecture/overview.md`, `adr/INDEX.md` | `api/INDEX.md`, `security/INDEX.md` |
| **Full-Stack Developer** | `domain/INDEX.md`, `architecture/overview.md`, `api/INDEX.md`, `design/INDEX.md` | `domain/[ctx]-language.md`, `database/schema.md`, `security/policies.md` |
| **DB Architect** | `domain/INDEX.md`, `database/INDEX.md`, `architecture/overview.md` | `adr/INDEX.md`, `security/policies.md` |
| **Code Reviewer** | `domain/INDEX.md`, `architecture/overview.md`, `adr/INDEX.md` | `api/INDEX.md`, `security/policies.md` |
| **QA Tester** | `domain/INDEX.md`, `testing/test-strategy.md`, `design/INDEX.md` | `api/INDEX.md`, `database/schema.md` |
| **DevOps/SRE** | `operations/runbook.md`, `architecture/overview.md` | `security/policies.md`, `database/INDEX.md` |
| **Security Analyst** | `domain/INDEX.md`, `security/INDEX.md`, `architecture/overview.md` | `adr/INDEX.md`, `api/INDEX.md` |

---

## Documentation structure

```
docs/
├── INDEX.md ← you are here
├── GUIDE.md ← how to use this structure
│
├── domain/ ← DDD modeling: bounded contexts, ubiquitous language, domain events
├── adr/ ← irreversible architectural decisions
├── api/ ← API contracts (OpenAPI, GraphQL, AsyncAPI)
├── architecture/ ← system view, components, diagrams
├── database/ ← data model, schema, changelog
├── design/ ← feature specifications
├── operations/ ← runbooks, deploys, postmortems
├── security/ ← policies, threat models, vulnerabilities
├── testing/ ← test strategy, coverage, quality
└── decisions/ ← product and business decisions
```

---

## Status of each section

| Section | Status | Owner | Last updated |
|---|---|---|---|
| `domain/` | `active` | senior-architect | YYYY-MM-DD |
| `adr/` | `active` | senior-architect | YYYY-MM-DD |
| `api/` | `active` | senior-architect | YYYY-MM-DD |
| `architecture/` | `active` | senior-architect | YYYY-MM-DD |
| `database/` | `active` | db-architect | YYYY-MM-DD |
| `design/` | `active` | senior-architect | YYYY-MM-DD |
| `operations/` | `active` | devops-sre | YYYY-MM-DD |
| `security/` | `active` | security-analyst | YYYY-MM-DD |
| `testing/` | `active` | qa-tester | YYYY-MM-DD |
| `decisions/` | `active` | po | YYYY-MM-DD |

---

## Registered bounded contexts

> Quick listing for navigation. Full details in `domain/INDEX.md`.

| Context | Status | Corresponding spec |
|---|---|---|
| [context-name] | `active` | `api/[name]-api.yaml` |

---

## Global conventions

- **Document status**: `draft` → `in-review` → `active` → `deprecated` | `replaced-by: [file]`
- **Naming**: `kebab-case` for files. Date prefix `YYYY-MM-DD-` for chronological documents (postmortems, decisions).
- **Frontmatter**: every document begins with a YAML metadata block (see `GUIDE.md`).
- **Ubiquitous language**: all names in `api/` derive from the glossary in `domain/[ctx]-language.md`. Divergences are bugs.
- **Updates**: when updating any document, also update the `updated` field in the frontmatter and record what changed in the `## Change history` section of the document itself.
- **Templates**: every segment has a `_template.md`. Never create documents without using the section's template.
- **Links**: always use paths relative to the `docs/` root.
