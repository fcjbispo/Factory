---
type: context-map
status: active
owner: senior-architect
updated: YYYY-MM-DD
related:
  - domain/INDEX.md
---

# Context Map — [PROJECT NAME]

> Defines how bounded contexts relate and communicate.
> It is the source of truth for integration decisions between contexts.
> Mandatory reading before creating event specs or integrations between contexts.

---

## Map diagram

```
[ContextA]  —[conformist]→  [ContextB]
[ContextB]  —[publisher]→   [ContextC]
[ContextA]  —[ACL]→          [ExternalContext]
```

*Detailed diagram in `architecture/diagrams/context-map.mmd` (Mermaid)*

---

## Relationship types

| Type | Description | Implication in spec |
|---|---|---|
| `conformist` | Consumer adopts the publisher's model without translation | Types in the consumer spec mirror those of the publisher |
| `anti-corruption-layer` (ACL) | Consumer translates the publisher's model to its own | Explicit translation spec; terms may differ |
| `publisher-consumer` | One context publishes events; others consume | AsyncAPI contract defines the channel |
| `partner` | Two contexts evolve together with mutual agreement | Coordinated specs; breaking changes require agreement |
| `shared-kernel` | Two contexts share a subset of the model | Extreme caution with changes in the shared kernel |

---

## Detailed relationships

### [ContextA] → [ContextB]

**Type**: `[relationship-type]`
**Direction**: [ContextA] is the [upstream/downstream]

**What is shared**:
- [shared concept or event]

**Translation** (if ACL):
| Concept in [ContextA] | Translation in [ContextB] | Reason |
|---|---|---|
| `[OriginConcept]` | `[DestinationConcept]` | [why the names differ] |

**Integration spec**: `api/events/[name]-event.yaml`

**Notes**:
- [relevant observations about this integration]

---

### [ContextB] → [ContextC]

**Type**: `publisher-consumer`
**Published events**:

| Event | Channel | Spec |
|---|---|---|
| `[EventName]` | `[channel-name]` | `api/events/[name]-event.yaml` |

---

## External contexts (third-party systems)

> Systems outside this application's domain. Always treated with ACL.

| System | Integration type | ACL responsible | Spec |
|---|---|---|---|
| [ExternalSystemName] | REST / GraphQL / Webhook | `[ConsumingContext]` | `api/integrations/[name].yaml` |

---

## Evolution rules

1. **Breaking changes in published contracts** require approval from all registered consumer contexts in this map.
2. **New bounded contexts** are added here before any implementation.
3. **Deprecated contexts** remain in the map with status `deprecated` until all consumers migrate.
4. **ACLs** are documented explicitly — never implicit in code.

---

## Change history

| Date | Change | By |
|---|---|---|
| YYYY-MM-DD | Initial map created via Event Storming | senior-architect |
