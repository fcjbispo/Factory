---
type: stakeholder-request
status: active
owner: po
updated: 2026-05-18
related:
  - conception/po-playbook.md
  - specifications/domain/credit-approval-context.md
  - specifications/decisions/2026-05-18-credit-approval-scope.md
---

# Stakeholder Request — Automated Credit Approval

## Original Request (Natural Language)

> *"Look, our current credit approval process is killing us. It takes 2 to 3 business days for a human analyst to review each application. We lose applicants to competitors who give instant answers. I need a system that does this automatically — start to finish — in under a minute.
>
> Here's what should happen: a person opens our app, fills in their monthly income, CPF, and how much credit they want. The system immediately goes to the credit bureau, pulls their score, and calculates a limit based on our risk bands. If their score is too low, automatic rejection — no human needed. If they ask for more than the policy allows, approve them for the lower amount instead. Every single step must be logged for audit. And if one of our credit managers disagrees with an automated decision, they need a way to override it with a written justification.
>
> For now, this is personal credit only — individuals, not companies. One currency: USD. I don't want to overcomplicate the first version. But I do want it robust enough that 90% of applications never touch a human desk.
>
> The board has already approved the risk multipliers: low-risk clients get up to 30 times their monthly income, medium gets 20x, high gets 10x. Anyone below 500 is out. Cap everything at $500,000. We can revisit corporate credit and multi-currency later.
>
> Can you build this?"*

---

## Key Pain Points Identified

| # | Pain Point | Impact |
|---|---|---|
| 1 | Manual review takes 2-3 business days | Loss of applicants to faster competitors |
| 2 | No automated rejection for low scores | Analysts waste time on obvious rejections |
| 3 | No audit trail for decisions | Regulatory risk, dispute resolution is manual |
| 4 | No partial approval mechanism | Applicants with good profiles are fully rejected when asking too much |
| 5 | No override mechanism for managers | Edge cases require workarounds outside the system |

---

## Success Criteria (as stated by stakeholder)

- Average evaluation time: **< 60 seconds**
- Fully automated rate: **>= 90%** of applications
- Scope: **personal credit only**, **USD only**
- Risk bands approved by board:
  - LOW (score >= 750): 30x income, max $500K
  - MEDIUM (600-749): 20x income, max $300K
  - HIGH (500-599): 10x income, max $100K
  - INELIGIBLE (< 500): automatic rejection

---

## What the Stakeholder Did NOT Say (PO's notes)

- No mention of **notification system** — assumed needed but out of scope for v1 core
- No mention of **identity verification / KYC** — assumed delegated to existing identity provider
- No mention of **frontend UI** — this is a backend microservice; frontend is another team's responsibility
- No mention of **appeals process** — deferred to v2
- No mention of **real-time income verification** — we trust declared income for v1; bank API integration deferred

---

## Next Step

This request is **raw input** for the PO. The PO must now transform it into structured domain language using the playbook in `po-playbook.md` and the Factory templates.
