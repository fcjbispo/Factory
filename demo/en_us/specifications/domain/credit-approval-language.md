---
type: ubiquitous-language
status: active
owner: senior-architect
updated: 2026-05-18
related:
  - domain/credit-approval-context.md
  - api/credit-approval-api.yaml
---

# Ubiquitous Language — Credit Approval

> This glossary is the **source of truth** for all nomenclature within the Credit Approval bounded context.
> All names in code, specs, tests, and documentation must correspond exactly to the terms defined here.
> Any divergence is a bug — do not adapt the glossary to the code, adapt the code to the glossary.

---

## How to Use This Document

- **AI agents**: before creating any type, field, mutation, or endpoint in this context, consult this glossary.
- **Developers**: when naming classes, tables, variables, and routes, use the terms from this glossary.
- **PO and domain specialists**: any new term must be approved and added here before being used.

---

## Domain Terms

### CreditApplication

**Definition**: A formal request submitted by an individual or entity seeking credit. It contains all information necessary for the credit evaluation process.

**DDD Type**: `Aggregate`

**Used as**:
- In spec: `type CreditApplication`, `input CreditApplicationInput`
- In code: `CreditApplication` (class), `creditApplication` (variable), `creditApplications` (collection)
- In database: `credit_applications` (table)

**Do NOT confuse with**:
- `CreditDecision` — the outcome of evaluating an application, not the request itself
- `Applicant` — the person/entity who submits the application

**Example usage**:
> "The applicant submitted a CreditApplication with a declared monthly income of $5,000."

---

### Applicant

**Definition**: The individual or legal entity requesting credit. An Applicant may submit multiple CreditApplications over time.

**DDD Type**: `Entity`

**Used as**:
- In spec: `type Applicant`, `input ApplicantInput`
- In code: `Applicant` (class), `applicant` (variable)
- In database: `applicants` (table)

**Example usage**:
> "The Applicant must provide proof of income before the CreditApplication can be processed."

---

### CreditDecision

**Definition**: The final outcome of evaluating a CreditApplication. It is immutable once issued and contains the decision (approved, rejected, or partially approved), the approved limit (if applicable), and the reasoning.

**DDD Type**: `Entity`

**Used as**:
- In spec: `type CreditDecision`, `enum DecisionStatus`
- In code: `CreditDecision` (class), `decision` (variable)
- In database: `credit_decisions` (table)

**Do NOT confuse with**:
- `CreditApplication` — the request, not the outcome
- `CreditLimit` — the maximum amount available, which may differ from the approved amount

**Example usage**:
> "The CreditDecision for application APP-2026-001 was APPROVED with a limit of $10,000."

---

### CreditLimit

**Definition**: The maximum amount of credit that an Applicant is authorized to use. Calculated based on income, credit score, and risk policies. Expressed in the Applicant's currency.

**DDD Type**: `Value Object`

**Used as**:
- In spec: `input CreditLimitInput`, `type CreditLimit`
- In code: `CreditLimit` (class), `limit` (variable)
- In database: `credit_limit` (column in `credit_decisions`)

**Validation rules**:
- Must be a positive decimal with 2 decimal places
- Maximum allowed: 30x the Applicant's monthly income
- Minimum allowed: $100.00

**Example usage**:
> "The calculated CreditLimit of $12,500 exceeded the policy cap, so it was reduced to $10,000."

---

### CreditScore

**Definition**: A numeric representation of the Applicant's creditworthiness, obtained from an external bureau. Ranges from 300 to 850. This is a read-only value in our domain — we do not calculate it.

**DDD Type**: `Value Object`

**Used as**:
- In spec: `type CreditScore`
- In code: `CreditScore` (class), `score` (variable)
- In database: `credit_score` (column in `credit_applications`)

**Validation rules**:
- Must be an integer between 300 and 850
- Scores below 500 trigger automatic rejection
- Scores above 750 qualify for premium limits

**Example usage**:
> "The Applicant's CreditScore of 720 placed them in the 'low risk' band."

---

### RiskBand

**Definition**: A classification that groups CreditScores into policy-driven categories. Determines the interest rate and maximum multiplier for CreditLimit calculation.

**DDD Type**: `Value Object` / `Enum`

**Possible values**:
- `LOW` — CreditScore >= 750
- `MEDIUM` — CreditScore 600-749
- `HIGH` — CreditScore 500-599
- `INELIGIBLE` — CreditScore < 500

**Used as**:
- In spec: `enum RiskBand`
- In code: `RiskBand` (enum), `riskBand` (variable)
- In database: `risk_band` (column as VARCHAR)

**Example usage**:
> "An Applicant in the HIGH RiskBand receives a maximum multiplier of 10x monthly income."

---

### AuditTrail

**Definition**: An immutable record of all actions taken during the lifecycle of a CreditApplication. Required for regulatory compliance and dispute resolution.

**DDD Type**: `Entity`

**Used as**:
- In spec: `type AuditTrailEntry`
- In code: `AuditTrailEntry` (class), `auditTrail` (collection)
- In database: `audit_trail` (table)

**Example usage**:
> "The AuditTrail shows that the CreditApplication was submitted at 09:15, scored at 09:16, and decided at 09:17."

---

## Forbidden Terms in This Context

| Forbidden Term | Use Instead | Reason |
|---|---|---|
| `customer` | `applicant` | "Customer" implies an existing relationship; our domain deals with prospects |
| `user` | `applicant` | Too generic — use the domain term |
| `loan` | `credit` | The domain is about credit approval, not loan disbursement |
| `data` | `[specific domain term]` | Too generic — use the specific entity name |
| `record` | `[entity name]` | Too generic — use the domain term |
| `status` | `[specific state]` | Use explicit state names: `SUBMITTED`, `SCORING`, `DECIDED` |

---

## Terms Shared With Other Contexts

| Term | Meaning in CreditApproval | Meaning in Notifications |
|---|---|---|
| `applicant` | The entity being evaluated | The recipient of notification messages |
| `decision` | The credit evaluation outcome | The action of sending a message ("send decision") |

---

## Domain Events — Canonical Names

| Canonical Name | When It Occurs |
|---|---|
| `CreditApplicationSubmitted` | When an applicant submits a new credit application |
| `CreditScoreReceived` | When the external bureau returns a score |
| `CreditDecisionIssued` | When the evaluation completes and a decision is recorded |
| `CreditLimitUpdated` | When a manual override changes an existing limit |

---

## Commands — Canonical Names

| Canonical Name | Intent |
|---|---|
| `SubmitCreditApplication` | Create a new credit application |
| `EvaluateCreditApplication` | Trigger the scoring and decision process |
| `OverrideCreditDecision` | Manually change an existing decision (requires authorization) |
| `RequestAuditTrail` | Retrieve the complete audit log for an application |

---

## Change History

| Date | Change | By |
|---|---|---|
| 2026-05-18 | Glossary created via Event Storming with PO | senior-architect |
