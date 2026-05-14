---
type: bounded-context
status: draft
owner: senior-architect
updated: YYYY-MM-DD
related:
  - domain/INDEX.md
  - domain/context-map.md
  - domain/[name]-language.md
  - api/[name]-api.yaml
---

# Context: [Context Name]

> **Central responsibility**: [describe in one sentence what this context is responsible for]

---

## Overview

[3-5 line description explaining the purpose of this bounded context, the business problem it solves, and its limits.]

**What belongs to this context**:
- [list of responsibilities]

**What does NOT belong to this context**:
- [explicit list of what stays outside — avoids scope creep]

---

## Aggregates

> An aggregate is a cluster of domain objects treated as a unit. The aggregate root is the only entry point for modifications.

### [AggregateName] *(aggregate root)*

**Responsibility**: [what this aggregate represents and protects]

**Invariants** (rules that can never be violated):
- [invariant 1 — ex: "an Order must have at least one item"]
- [invariant 2]

**Fields**:
| Field | Type | Required | Description |
|---|---|---|---|
| id | UUID | yes | Unique identifier |
| [field] | [type] | yes/no | [description] |

**Possible states** (if applicable):
```
[STATE_A] → [STATE_B] → [STATE_C]
              ↓
          [STATE_CANCELLED]
```

**Transitions and commands**:
| Command | Pre-condition | Result |
|---|---|---|
| [CommandName] | [necessary condition] | [resulting state or published event] |

---

## Entities

> Entities have their own identity (an `id`) and independent lifecycle within the aggregate.

### [EntityName]

**Responsibility**: [description]

**Fields**:
| Field | Type | Required | Description |
|---|---|---|---|
| id | UUID | yes | Unique identifier |
| [field] | [type] | yes/no | [description] |

---

## Value Objects

> Value Objects are immutable and defined by the value of their attributes, not by identity. They have no `id`.

### [ValueObjectName]

**Responsibility**: [description]
**Immutable**: yes — to change, create a new one.

**Fields**:
| Field | Type | Required | Description |
|---|---|---|---|
| [field] | [type] | yes | [description] |

**Validation rules**:
- [rule 1 — ex: "ZIP code must have 8 digits"]
- [rule 2]

---

## Domain Events

> Domain events represent something that happened and is relevant to the business. They are immutable and in past tense.

| Event | Published when | Mandatory payload | Consumed by |
|---|---|---|---|
| [EventName] | [publication condition] | [essential fields] | [consuming contexts] |

### Details by event

#### [EventName]

**When it is published**: [describe the domain action that triggers it]

**Payload**:
| Field | Type | Required | Description |
|---|---|---|---|
| eventId | UUID | yes | Unique event identifier |
| occurredAt | datetime | yes | Timestamp of occurrence |
| [domain-field] | [type] | yes | [description] |

**Payload invariants** (rules the event must always satisfy):
- [ex: "the item list must have at least 1 element"]

---

## Domain services

> Use when an operation does not naturally belong to any entity or aggregate.

### [ServiceName]

**Responsibility**: [what this service calculates or coordinates]
**Inputs**: [what it receives]
**Output**: [what it returns or publishes]

---

## Repositories

> Aggregate access interfaces. Implementation lives outside the domain.

| Repository | Operations |
|---|---|
| `[Name]Repository` | `findById`, `save`, `delete`, `findBy[Criterion]` |

---

## Mapping to Spec (SDD)

> How concepts from this context become contracts in `api/`.

| DDD Concept | Spec Element | File |
|---|---|---|
| [AggregateName] (aggregate root) | `type [AggregateName]` + mutations | `api/[name]-api.yaml` |
| [EntityName] | `type [EntityName] { id: ID! }` | `api/[name]-api.yaml` |
| [ValueObjectName] | `input [ValueObjectName]Input` | `api/[name]-api.yaml` |
| [invariant: mandatory list] | `[field]: [[Type]!]!` | `api/[name]-api.yaml` |
| [aggregate state] | `enum [StateName]` | `api/[name]-api.yaml` |
| [EventName] | AsyncAPI channel / subscription | `api/events/[name]-event.yaml` |

---

## Anti-Corruption Layer

> If this context consumes concepts from other contexts, document here how the translation is done.

| External concept (origin context) | Translation in this context | Reason |
|---|---|---|
| `[Concept]` from `[OriginContext]` | `[TranslatedConcept]` | [why the name differs in this context] |

---

## Change history

| Date | Change | By |
|---|---|---|
| YYYY-MM-DD | Document created via Event Storming | senior-architect |
