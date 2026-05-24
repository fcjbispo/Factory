---
type: design
status: draft
owner: senior-architect
readers: [fullstack-developer, db-architect, qa-tester, security-analyst]
updated: 2026-05-18
related:
  - domain/credit-approval-context.md
  - api/credit-approval-api.yaml
  - architecture/overview.md
---

# Credit Approval — Feature Design

## Context and Problem

The business needs an automated system to evaluate credit applications from individuals. Currently, this process is manual, error-prone, and takes 2-3 business days. The goal is to reduce the evaluation time to under 60 seconds while maintaining regulatory compliance and auditability.

**Business rules to automate**:
- Credit score analysis with score bands
- Credit limit calculation based on declared income
- Automatic rejection for blacklisted applicants or insufficient income
- Partial approval with adjusted amount when requested limit exceeds policy
- Immutable audit trail for every decision

---

## Proposed Solution

A RESTful microservice that receives credit applications, enriches them with external bureau data, applies business rules, and issues an immutable credit decision. All actions are recorded in an audit trail.

**Main flow**:
1. Applicant submits application via `POST /applications`
2. System validates input and creates `CreditApplication` (status: `SUBMITTED`)
3. System fetches `CreditScore` from external bureau (asynchronous, cached)
4. System calculates `RiskBand` and `CreditLimit`
5. System issues `CreditDecision` (status: `DECIDED` or `REJECTED`)
6. System publishes `CreditDecisionIssued` event
7. Audit trail records all steps

**Alternative flow — Bureau unavailable**:
- If bureau returns 5xx or times out after 3 retries, application remains in `SUBMITTED`
- Background job retries every 5 minutes for up to 1 hour
- If still failing, manual review flag is raised

**Alternative flow — Manual override**:
- Admin with `CREDIT_ADMIN` role can override a `DECIDED` application
- Override requires reason (min 20 characters)
- New `CreditDecision` is created, old one is marked `SUPERSEDED`
- `CreditLimitUpdated` event is published

---

## Affected Components

| Component | Impact Type | Responsible Agent |
|---|---|---|
| `credit-application-api` | new | fullstack-developer |
| `credit-evaluation-service` | new | fullstack-developer |
| `credit-decision-repository` | new | db-architect |
| `external-bureau-adapter` | new | fullstack-developer |
| `audit-trail-service` | new | fullstack-developer |
| `notifications-publisher` | new | fullstack-developer |
| `postgresql` | modified | db-architect |
| `redis` | new | devops-sre |

---

## API Contract

Reference: `api/credit-approval-api.yaml`

Key endpoints:
- `POST /v1/applications` — Submit new credit application
- `GET /v1/applications/{id}` — Retrieve application with current decision
- `POST /v1/applications/{id}/evaluate` — Trigger evaluation (internal/async)
- `POST /v1/applications/{id}/override` — Manual override (admin only)
- `GET /v1/applications/{id}/audit` — Retrieve audit trail

---

## Data Model

### New Entities

**credit_applications**:
- `id` (UUID, PK)
- `applicant_id` (UUID, FK → applicants)
- `declared_income` (DECIMAL, 15,2)
- `requested_amount` (DECIMAL, 15,2)
- `currency` (VARCHAR(3), default 'USD')
- `credit_score` (INTEGER, nullable)
- `risk_band` (VARCHAR(20), nullable)
- `status` (VARCHAR(20), default 'SUBMITTED')
- `submitted_at` (TIMESTAMP)
- `decided_at` (TIMESTAMP, nullable)

**credit_decisions**:
- `id` (UUID, PK)
- `application_id` (UUID, FK → credit_applications, unique)
- `decision` (VARCHAR(20))
- `approved_amount` (DECIMAL, 15,2, nullable)
- `reason` (VARCHAR(500))
- `decided_at` (TIMESTAMP)
- `decided_by` (VARCHAR(100))

**audit_trail**:
- `id` (UUID, PK)
- `application_id` (UUID, FK)
- `action` (VARCHAR(50))
- `actor` (VARCHAR(100))
- `payload` (JSONB)
- `occurred_at` (TIMESTAMP)

---

## Acceptance Criteria

- [ ] Given a valid application with income $5,000 and score 720, when evaluated, then decision is APPROVED with limit $150,000 (30x)
- [ ] Given a valid application with income $5,000 and score 550, when evaluated, then decision is APPROVED with limit $50,000 (10x)
- [ ] Given a valid application with score 480, when evaluated, then decision is REJECTED with reason "Credit score below minimum threshold"
- [ ] Given an application with income $0, when submitted, then validation fails with error "declared_income must be greater than 0"
- [ ] Given a decided application, when an admin overrides with reason, then a new decision is created and event is published
- [ ] Given any application transition, when it occurs, then an audit trail entry is created within 100ms
- [ ] Given a bureau timeout, when evaluating, then application stays in SUBMITTED and retry is scheduled

---

## Testing Approach

| Type | What to Test | Responsible |
|---|---|---|
| Unit | Credit limit calculation for each risk band | fullstack-developer |
| Unit | Automatic rejection rules (score, income, blacklist) | fullstack-developer |
| Unit | Audit trail recording | fullstack-developer |
| Integration | End-to-end flow: submit → evaluate → decide | qa-tester |
| Integration | Bureau adapter resilience (timeouts, retries) | qa-tester |
| Integration | API validation and error responses | qa-tester |
| E2E | Complete approval and rejection flows via API | qa-tester |
| Security | Authentication on override endpoint | security-analyst |
| Performance | Evaluation completes in < 60 seconds under load | qa-tester |

---

## Security Considerations

- **PII**: applicant document_number and email are encrypted at rest (AES-256)
- **Authentication**: All endpoints require JWT (except health checks)
- **Authorization**: Override endpoint requires `CREDIT_ADMIN` role
- **Audit**: All access to audit trail is itself audited
- **External calls**: Bureau API key stored in environment variable, never logged
- **Rate limiting**: 10 applications per minute per applicant_id

---

## Performance Considerations

- Target: 95th percentile evaluation time < 60 seconds
- Bureau score caching: 24 hours per applicant to reduce external calls
- Database: index on `credit_applications.status` and `credit_applications.applicant_id`
- Background evaluation via message queue to avoid blocking HTTP requests
- Expected volume: 1,000 applications/day at launch

---

## Discarded Alternatives

- **Synchronous evaluation**: Rejected because bureau latency (2-5s) would block HTTP requests. Background async evaluation was chosen instead.
- **GraphQL API**: Rejected because the API surface is small (4 endpoints) and REST is simpler for the frontend team.
- **Event sourcing for decisions**: Rejected as overkill for v1. Simple audit table is sufficient; event sourcing can be reconsidered if audit requirements grow.

---

## Change History

| Date | Change | By |
|---|---|---|
| 2026-05-18 | Initial version | senior-architect |
