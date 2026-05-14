---
type: ubiquitous-language
status: active
owner: senior-architect
updated: YYYY-MM-DD
related:
  - domain/[name]-context.md
  - api/[name]-api.yaml
---

# Ubiquitous Language — [Context Name]

> This glossary is the **source of truth** for all nomenclature within this bounded context.
> All names in code, specs, tests, and documentation must correspond exactly to the terms defined here.
> Any divergence is a bug — do not adapt the glossary to the code, adapt the code to the glossary.

---

## How to use this document

- **AI agents**: before creating any type, field, mutation, or endpoint in this context, consult this glossary.
- **Developers**: when naming classes, tables, variables, and routes, use the terms from this glossary.
- **PO and domain specialists**: any new term must be approved and added here before being used.

---

## Domain terms

### [Term]

**Definition**: [precise description of what this term means in this context]

**DDD Type**: `Aggregate` | `Entity` | `Value Object` | `Domain Service` | `Event` | `Business Concept`

**Used as**:
- In spec: `type [Term]` / `input [Term]Input` / `enum [TermState]`
- In code: `[Term]` (class), `[term]` (variable), `[terms]` (collection)
- In database: `[terms]` (table), `[term_field]` (column)

**Do NOT confuse with**:
- `[OtherTerm]` — [explanation of why they are different]
- `[TermFromOtherContext]` in `[OtherContext]` — [difference in meaning between contexts]

**Example usage**:
> "[example sentence using the term in business context]"

---

### [OtherTerm]

**Definition**: [description]

**DDD Type**: [type]

**Used as**:
- In spec: [element]
- In code: [convention]

---

## Forbidden terms in this context

> Terms that exist in other contexts or in technical language but **must not be used** here to avoid confusion.

| Forbidden term | Use instead | Reason |
|---|---|---|
| `[ForbiddenTerm]` | `[CorrectTerm]` | [why the forbidden term causes ambiguity] |
| `item` | `[SpecificName]` | "item" is too generic — use the domain name |
| `data` | `[SpecificName]` | ditto |
| `record` | `[SpecificName]` | ditto |

---

## Terms shared with other contexts

> Terms that appear in multiple contexts, but with different meanings. Special attention when working with integrations.

| Term | Meaning in this context | Meaning in [OtherContext] |
|---|---|---|
| `[Term]` | [local definition] | [definition in the other context] |

---

## Domain events — canonical names

> Events are named in the **past tense** and follow the pattern `[Aggregate][Action]`.

| Canonical name | When it occurs |
|---|---|
| `[AggregateAction]` | [description of what occurred] |

---

## Commands — canonical names

> Commands express **intent** and follow the pattern `[verb][Aggregate]`.

| Canonical name | Intent |
|---|---|
| `[CreateAggregateVerb]` | [what the user/system wants to do] |
| `[CancelAggregateVerb]` | [idem] |

---

## Change history

| Date | Change | By |
|---|---|---|
| YYYY-MM-DD | Glossary created via Event Storming with PO | senior-architect |
