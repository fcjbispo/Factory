---
type: decision
status: active
owner: po
readers: [senior-architect, fullstack-developer]
updated: 2026-05-18
related:
  - design/credit-approval-design.md
  - architecture/overview.md
---

# Product Decision: Scope and Business Rules for Credit Approval v1

## Context

The company needs to automate credit evaluation to reduce the current manual process from 2-3 days to under 60 seconds. The product team must define the exact scope, business rules, and success criteria for the first release.

## Decision

1. **V1 scope**: Personal credit only (individuals, not businesses)
2. **Currency**: USD only for launch; multi-currency deferred to v2
3. **Credit limit calculation**: Based solely on declared income and credit score band
   - LOW risk (score >= 750): 30x monthly income, max $500,000
   - MEDIUM risk (600-749): 20x monthly income, max $300,000
   - HIGH risk (500-599): 10x monthly income, max $100,000
   - INELIGIBLE (< 500): automatic rejection
4. **Partial approval**: When the calculated limit is less than the requested amount, approve the lower amount with status `PARTIALLY_APPROVED`
5. **Blacklist**: A hard-coded list of blocked document numbers for v1; integration with external blacklist service deferred to v2
6. **Manual override**: Credit admins can override any decided application with reason; no amount ceiling for overrides in v1
7. **Audit**: All actions recorded; audit trail retained for 7 years (regulatory requirement)

## Motivation

- Personal credit is 80% of current volume and has simpler rules than corporate
- USD-only reduces complexity in bureau integrations and limit calculations
- The risk band multipliers are based on the current manual policy and have board approval
- Partial approval reduces applicant friction when they request more than policy allows
- Manual override is a regulatory requirement — the system must allow human intervention

## Expected Impact

- Average evaluation time drops from 48-72 hours to < 60 seconds
- 90%+ of applications are fully automated (no manual review)
- Audit compliance is guaranteed by design
- Admin override rate should be < 5% of decisions

## Accepted Trade-offs

- **No real-time income verification**: We trust the declared income. Income verification via bank APIs is planned for v2.
- **Hard-coded blacklist**: Manual maintenance until v2. Risk is low for demo/launch.
- **No appeals process**: Applicants cannot challenge decisions in v1. Appeals deferred to v2.
- **Single currency**: International applicants must apply in USD.

## Review Criteria

Revisit this decision if:
- Override rate exceeds 10% (indicates rules are too rigid)
- Rejection rate exceeds 40% (indicates scoring threshold may be too high)
- Regulatory requirements change (e.g., new audit retention rules)
- Business expands to corporate credit or new currencies

## Change History

| Date | Change | By |
|---|---|---|
| 2026-05-18 | Initial scope decision | po |
