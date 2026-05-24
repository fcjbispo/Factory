---
type: context-map
status: active
owner: senior-architect
updated: 2026-05-18
related:
  - domain/INDEX.md
  - domain/credit-approval-context.md
---

# Context Map — Credit Approval Microservice

> Defines how bounded contexts relate and communicate.
> Mandatory reading before creating event specs or integrations between contexts.

---

## Map Diagram

```
[CreditApproval]  —[publisher]→  [Notifications]
[CreditApproval]  —[ACL]→        [ExternalCreditBureau]
[CreditApproval]  —[ACL]→        [IdentityProvider]
```

*Detailed diagram in `architecture/diagrams/context-map.mmd` (Mermaid)*

---

## Relationship Types

| Type | Description | Implication in spec |
|---|---|---|
| `publisher-consumer` | One context publishes events; others consume | AsyncAPI contract defines the channel |
| `anti-corruption-layer` (ACL) | Consumer translates the publisher's model to its own | Explicit translation spec; terms may differ |

---

## Detailed Relationships

### CreditApproval → Notifications

**Type**: `publisher-consumer`
**Direction**: CreditApproval is the upstream

**Published events**:

| Event | Channel | Spec |
|---|---|---|
| `CreditDecisionIssued` | `credit.decisions` | `api/events/credit-decision-event.yaml` |
| `CreditLimitUpdated` | `credit.limits` | `api/events/credit-limit-event.yaml` |

**Notes**:
- Notifications context consumes events to send emails/SMS to applicants
- No synchronous dependency — Notifications can be temporarily unavailable

---

### CreditApproval → ExternalCreditBureau

**Type**: `anti-corruption-layer`
**Direction**: CreditApproval is the downstream

**Translation**:

| Concept in ExternalCreditBureau | Translation in CreditApproval | Reason |
|---|---|---|
| `risk_score` | `credit_score` | Internal domain uses "credit_score" to align with business language |
| `inquiry_reason` | `application_type` | Maps bureau-specific codes to our domain types |

**Integration spec**: `api/integrations/credit-bureau.yaml`

**Notes**:
- Bureau responses are cached for 24 hours to reduce costs
- All PII is encrypted at rest

---

### CreditApproval → IdentityProvider

**Type**: `anti-corruption-layer`
**Direction**: CreditApproval is the downstream

**Translation**:

| Concept in IdentityProvider | Translation in CreditApproval | Reason |
|---|---|---|
| `sub` (JWT subject) | `applicant_id` | Aligns with domain language |

**Integration spec**: `api/integrations/identity-provider.yaml`

---

## External Contexts (Third-Party Systems)

| System | Integration Type | ACL Responsible | Spec |
|---|---|---|---|
| ExternalCreditBureau | REST | CreditApproval | `api/integrations/credit-bureau.yaml` |
| IdentityProvider | OAuth 2.0 / JWT | CreditApproval | `api/integrations/identity-provider.yaml` |
| Notifications Service | Async (events) | Notifications | `api/events/*.yaml` |

---

## Evolution Rules

1. **Breaking changes in published contracts** require approval from all registered consumer contexts in this map.
2. **New bounded contexts** are added here before any implementation.
3. **Deprecated contexts** remain in the map with status `deprecated` until all consumers migrate.
4. **ACLs** are documented explicitly — never implicit in code.

---

## Change History

| Date | Change | By |
|---|---|---|
| 2026-05-18 | Initial map created via Event Storming | senior-architect |
