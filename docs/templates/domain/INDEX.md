---
type: domain-index
status: active
owner: senior-architect
updated: YYYY-MM-DD
---

# Domain — [PROJECT NAME]

> Central registry of bounded contexts, ubiquitous language, and context map.
> **Every agent reads this file before creating or modifying any spec in `api/`.**

---

## Fundamental rule

The names in this document are the **source of truth** for all system nomenclature.
No name in `api/`, `database/`, or in code may diverge from each context's glossary.
Divergences are bugs — fix in the spec or code, never in the glossary without PO approval.

---

## Registered bounded contexts

| Context | Status | Responsible | Main spec | Glossary | Last updated |
|---|---|---|---|---|---|
| [context-name] | `active` | senior-architect | `api/[name]-api.yaml` | `domain/[name]-language.md` | YYYY-MM-DD |

**Possible statuses**: `discovered` → `documented` → `active` → `deprecated`

---

## Quick context overview

> Describe in 1-2 lines the core responsibility of each context.

### [Context Name]
Responsible for [main responsibility]. Aggregates [key-entities].
Consumes events from [other contexts]. Publishes [main events].

---

## Dependency map (summary)

> Complete details in `domain/context-map.md`.

```
[ContextA]  —[relationship-type]→  [ContextB]
[ContextB]  —[relationship-type]→  [ContextC]
```

**Relationship types**: `conformist` | `anti-corruption-layer` | `publisher-consumer` | `partner` | `shared-kernel`

---

## Global domain events

| Event | Published by | Consumed by | Spec |
|---|---|---|---|
| [EventName] | [source-context] | [target-context] | `api/events/[name]-event.yaml` |

---

## Change history

| Date | Change | By |
|---|---|---|
| YYYY-MM-DD | Initial bounded context discovery via Event Storming | senior-architect |
