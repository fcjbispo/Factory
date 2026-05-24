---
type: bounded-context
status: active
owner: senior-architect
updated: 2026-05-18
related:
  - domain/INDEX.md
  - domain/context-map.md
  - domain/credit-approval-language.md
  - api/credit-approval-api.yaml
---

# Context: Credit Approval

> **Central responsibility**: Evaluate credit applications and issue credit decisions based on risk policies, income verification, and external bureau data.

---

## Overview

The Credit Approval context is the core of the microservice. It receives credit applications from applicants, enriches them with external credit scores, applies business rules and risk policies, and produces an immutable credit decision. All actions are recorded in an audit trail for compliance.

**What belongs to this context**:
- Submission and validation of credit applications
- Integration with external credit bureaus for scoring
- Application of risk bands and credit limit calculations
- Issuance of credit decisions (approved, rejected, partially approved)
- Audit trail recording for all decisions

**What does NOT belong to this context**:
- Sending notifications to applicants (Notifications context)
- Identity verification / KYC (IdentityProvider external system)
- Credit limit usage tracking or billing (outside scope)
- Manual review UI or workflow management (outside scope)

---

## Aggregates

### CreditApplication *(aggregate root)*

**Responsibility**: Represents the entire lifecycle of a credit request. It is the only entry point for creating, evaluating, and deciding a credit application.

**Invariants**:
- A CreditApplication must have exactly one Applicant
- A CreditApplication cannot be modified after a CreditDecision is issued
- The declared income must be > 0
- The requested amount must be >= $100.00

**Fields**:
| Field | Type | Required | Description |
|---|---|---|---|
| id | UUID | yes | Unique identifier (format: APP-YYYY-NNNN) |
| applicant_id | UUID | yes | Reference to the Applicant |
| declared_income | Decimal | yes | Monthly income declared by the applicant |
| requested_amount | Decimal | yes | Amount of credit requested |
| currency | String(3) | yes | ISO 4217 currency code (default: USD) |
| credit_score | Integer | no | Score from external bureau (null until scoring) |
| risk_band | Enum | no | Calculated band (null until scoring) |
| status | Enum | yes | Current state of the application |
| submitted_at | DateTime | yes | When the application was received |
| decided_at | DateTime | no | When the decision was issued |

**Possible states**:
```
SUBMITTED → SCORING → DECIDED
              ↓
          REJECTED
```

**Transitions and commands**:
| Command | Pre-condition | Result |
|---|---|---|
| `SubmitCreditApplication` | Applicant exists, income > 0, amount >= 100 | Status: SUBMITTED, event: CreditApplicationSubmitted |
| `EvaluateCreditApplication` | Status: SUBMITTED, credit_score received | Status: SCORING → DECIDED/REJECTED, event: CreditDecisionIssued |
| `OverrideCreditDecision` | Status: DECIDED, user has ADMIN role | Status: DECIDED (updated), event: CreditLimitUpdated |

---

## Entities

### Applicant

**Responsibility**: Represents the individual or entity requesting credit. Maintains identity across multiple applications.

**Fields**:
| Field | Type | Required | Description |
|---|---|---|---|
| id | UUID | yes | Unique identifier |
| full_name | String(255) | yes | Legal name |
| document_number | String(50) | yes | Government ID (CPF/SSN equivalent) |
| email | String(255) | yes | Contact email |
| date_of_birth | Date | yes | For age-based policies |
| created_at | DateTime | yes | Registration timestamp |

### CreditDecision

**Responsibility**: The immutable outcome of evaluating a CreditApplication.

**Fields**:
| Field | Type | Required | Description |
|---|---|---|---|
| id | UUID | yes | Unique identifier |
| application_id | UUID | yes | Reference to CreditApplication |
| decision | Enum | yes | APPROVED, REJECTED, PARTIALLY_APPROVED |
| approved_amount | Decimal | no | Final approved limit (null if REJECTED) |
| reason | String(500) | yes | Human-readable explanation |
| decided_at | DateTime | yes | Timestamp of the decision |
| decided_by | String | yes | `SYSTEM` or admin user ID |

---

## Value Objects

### CreditScore

**Responsibility**: Immutable score returned by external bureau.
**Immutable**: yes

**Fields**:
| Field | Type | Required | Description |
|---|---|---|---|
| score | Integer | yes | 300-850 |
| source | String | yes | Bureau identifier (e.g., "EXPERIAN_V3") |
| retrieved_at | DateTime | yes | When the score was fetched |

**Validation rules**:
- Score must be between 300 and 850
- Scores are cached for 24 hours per applicant

### CreditLimit

**Responsibility**: The maximum credit amount calculated from income and risk band.
**Immutable**: yes

**Fields**:
| Field | Type | Required | Description |
|---|---|---|---|
| amount | Decimal | yes | Calculated limit |
| currency | String(3) | yes | ISO 4217 code |
| multiplier | Decimal | yes | Applied multiplier (e.g., 20x) |

**Validation rules**:
- amount = declared_income * multiplier
- multiplier is determined by RiskBand:
  - LOW: 30x
  - MEDIUM: 20x
  - HIGH: 10x
  - INELIGIBLE: 0 (automatic rejection)
- Maximum cap: $500,000.00

### RiskBand

**Responsibility**: Classification derived from CreditScore.
**Immutable**: yes

**Fields**:
| Field | Type | Required | Description |
|---|---|---|---|
| band | Enum | yes | LOW, MEDIUM, HIGH, INELIGIBLE |
| min_score | Integer | yes | Lower bound of this band |
| max_score | Integer | yes | Upper bound of this band |

---

## Domain Events

| Event | Published When | Mandatory Payload | Consumed By |
|---|---|---|---|
| `CreditApplicationSubmitted` | Application passes validation | application_id, applicant_id, submitted_at | Notifications |
| `CreditScoreReceived` | Bureau returns score | application_id, score, source | Internal (triggers evaluation) |
| `CreditDecisionIssued` | Decision is recorded | application_id, decision, approved_amount | Notifications, Audit |
| `CreditLimitUpdated` | Manual override applied | application_id, new_amount, overridden_by | Notifications, Audit |

### Details by Event

#### CreditDecisionIssued

**When it is published**: After the evaluation logic completes and the CreditDecision is persisted.

**Payload**:
| Field | Type | Required | Description |
|---|---|---|---|
| event_id | UUID | yes | Unique event identifier |
| occurred_at | DateTime | yes | Timestamp |
| application_id | UUID | yes | Reference |
| decision | Enum | yes | APPROVED, REJECTED, PARTIALLY_APPROVED |
| approved_amount | Decimal | no | Null if REJECTED |
| reason | String | yes | Explanation |

**Payload invariants**:
- If decision is REJECTED, approved_amount must be null
- If decision is APPROVED or PARTIALLY_APPROVED, approved_amount must be > 0

---

## Domain Services

### CreditEvaluationService

**Responsibility**: Calculates the credit limit and determines the final decision based on risk band, income, and policies.
**Inputs**: CreditApplication (with score), RiskBand rules, Policy limits
**Output**: CreditDecision (approved/rejected/partial with amount and reason)

---

## Repositories

| Repository | Operations |
|---|---|
| `CreditApplicationRepository` | `findById`, `save`, `findByApplicantId`, `findByStatus` |
| `ApplicantRepository` | `findById`, `save`, `findByDocumentNumber` |
| `CreditDecisionRepository` | `findById`, `save`, `findByApplicationId` |
| `AuditTrailRepository` | `findByApplicationId`, `save` |

---

## Mapping to Spec (SDD)

| DDD Concept | Spec Element | File |
|---|---|---|
| CreditApplication (aggregate root) | `type CreditApplication` + mutations | `api/credit-approval-api.yaml` |
| Applicant | `type Applicant { id: ID! }` | `api/credit-approval-api.yaml` |
| CreditDecision | `type CreditDecision` | `api/credit-approval-api.yaml` |
| CreditScore | `input CreditScoreInput` | `api/credit-approval-api.yaml` |
| RiskBand | `enum RiskBand` | `api/credit-approval-api.yaml` |
| CreditApplicationSubmitted | AsyncAPI channel / subscription | `api/events/credit-application-event.yaml` |
| CreditDecisionIssued | AsyncAPI channel / subscription | `api/events/credit-decision-event.yaml` |

---

## Anti-Corruption Layer

| External Concept (Origin Context) | Translation in This Context | Reason |
|---|---|---|
| `risk_score` from ExternalCreditBureau | `credit_score` | Internal domain uses business language |
| `sub` from IdentityProvider | `applicant_id` | JWT subject maps to our Applicant entity |

---

## Change History

| Date | Change | By |
|---|---|---|
| 2026-05-18 | Document created via Event Storming | senior-architect |
