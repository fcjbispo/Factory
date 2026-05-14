---
type: domain-index
status: active
owner: senior-architect
updated: YYYY-MM-DD
---

# Domain — [PROJECT NAME]

> Central record of bounded contexts, ubiquitous language, and context map.
> **Every agent reads this file before creating or modifying any spec in `api/`.**

---

## Fundamental rule

The names in this document are the **source of truth** for all system nomenclature.
No name in `api/`, `database/`, or in code may diverge from the glossary of each context.
Divergences are bugs — fix in the spec or code, never in the glossary without PO approval.

---

## Registered bounded contexts

| Context | Status | Owner | Main spec | Glossary | Last updated |
|---|---|---|---|---|---|
| [context-name] | `active` | senior-architect | `api/[name]-api.yaml` | `domain/[name]-language.md` | YYYY-MM-DD |

**Possible statuses**: `discovered` → `documented` → `active` → `deprecated`

---

## Quick view of contexts

> Describe in 1-2 lines the central responsibility of each context.

### [Context Name]
Responsible for [main responsibility]. Aggregates [key entities].
Consumes events from [other contexts]. Publishes [main events].

---

## Dependency map (summary)

> Full details in `domain/context-map.md`.

```
[ContextA]  —[relation-type]→  [ContextB]
[ContextB]  —[relation-type]→  [ContextC]
```

**Relation types**: `conformist` | `anti-corruption-layer` | `publisher-consumer` | `partner` | `shared-kernel`

---

## Global domain events

| Event | Published by | Consumed by | Spec |
|---|---|---|---|
| [EventName] | [origin-context] | [destination-context] | `api/events/[name]-event.yaml` |

---

## Change history

| Date | Change | By |
|---|---|---|
| YYYY-MM-DD | Initial discovery of bounded contexts via Event Storming | senior-architect |
