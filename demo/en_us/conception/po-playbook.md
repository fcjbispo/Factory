---
type: po-playbook
status: active
owner: po
updated: 2026-05-18
related:
  - conception/stakeholder-request.md
  - specifications/domain/credit-approval-context.md
  - specifications/domain/credit-approval-language.md
  - specifications/domain/context-map.md
---

# PO Playbook — Act 1: Conception

> **Goal**: Transform the stakeholder's natural language request into a structured DDD Canvas that all downstream agents can consume.
> **Input**: `stakeholder-request.md`
> **Output**: `domain/credit-approval-context.md`, `domain/credit-approval-language.md`, `domain/context-map.md`, `decisions/YYYY-MM-DD-credit-approval-scope.md`

---

## Step 1 — Read the Stakeholder Request

Open `stakeholder-request.md`. Identify:
- **Pain points** (why this system exists)
- **Actors** (who interacts with the system)
- **Business rules** (what decisions the system must make)
- **Constraints** (what is explicitly in or out of scope)

Do not skip this step. The stakeholder's exact words are the source of truth for the domain language.

---

## Step 2 — Open the Factory Templates

Load the following templates into context before engaging the `@senior-architect` agent:

1. `src/docs/templates/domain/_template-bounded-context.md` — for the context document
2. `src/docs/templates/domain/_template-ubiquitous-language.md` — for the glossary
3. `src/docs/templates/domain/context-map.md` — for the context map
4. `src/docs/templates/decisions/_template.md` — for the product decision

These templates enforce the required frontmatter, structure, and conventions.

---

## Step 3 — Engage the @senior-architect Agent

Feed the agent in this order:

1. **The stakeholder request** (verbatim or summarized)
2. **The templates** (so the agent knows the output format)
3. **This instruction**: *"Extract the bounded context, ubiquitous language, and context map from this request. Follow the templates exactly. All terms must be in English. All documents need YAML frontmatter with type, status, owner, updated."*

The agent will produce a first draft of:
- `domain/credit-approval-context.md`
- `domain/credit-approval-language.md`
- `domain/context-map.md`

---

## Step 4 — PO Validates the Domain Language

Before accepting the agent's output, the PO must verify:

| Check | Question |
|---|---|
| Term accuracy | Do the terms match what the stakeholder actually said? |
| Forbidden terms | Are there any generic words like `customer`, `user`, `data`, `status` that should be domain-specific? |
| Scope boundaries | Is there a clear list of what does **not** belong to this context? |
| Invariants | Are the business rules stated as invariants that can never be violated? |

If any term feels wrong, correct it. Do not let technical convenience override business language.

---

## Step 5 — Define the Product Decision

Using `src/docs/templates/decisions/_template.md`, the PO writes the scope decision document (`decisions/YYYY-MM-DD-credit-approval-scope.md`).

This document must include:
- **What was decided** (v1 scope, business rules, numbers)
- **Why** (motivation from the stakeholder)
- **Trade-offs accepted** (what we are giving up for speed)
- **Review criteria** (when to revisit this decision)

This is the **contract** between business and engineering. The architect and developers will build against this document.

---

## Step 6 — Review and Freeze

Before moving to Act 2 (Architecture), the PO must:

1. Confirm all four documents are complete and consistent
2. Ensure `context-map.md` correctly identifies external systems and their integration type
3. Ensure `credit-approval-language.md` has a "Forbidden Terms" section
4. Add the documents to the project `INDEX.md` under the `domain/` and `decisions/` sections

**Do not proceed to Act 2 if the domain language is unstable.** Changing a term after the architect has designed the API is expensive.

---

## Agent Map for Act 1

| Role | Agent | Input | Output |
|---|---|---|---|
| PO | Human | Stakeholder request | Validated requirements |
| Domain Modeler | `@senior-architect` | Stakeholder request + templates | DDD Canvas (context, language, map) |
| Product Decision | Human (PO) | Domain Canvas + stakeholder constraints | Scope decision document |

---

## Output Checklist

Before closing Act 1, verify these files exist and are linked in `INDEX.md`:

- [ ] `domain/credit-approval-context.md` — Bounded context with aggregates, entities, VO, events
- [ ] `domain/credit-approval-language.md` — Ubiquitous language glossary with forbidden terms
- [ ] `domain/context-map.md` — Context map with external systems and ACLs
- [ ] `decisions/YYYY-MM-DD-credit-approval-scope.md` — Product scope and business rules

---

## Common Mistakes to Avoid

- **Skipping the glossary**: If the PO does not define "Applicant" vs "customer", developers will use both in the codebase.
- **Mixing technical and business terms**: The domain document should not mention "REST", "JWT", or "PostgreSQL". Those belong in architecture.
- **No explicit scope exclusions**: Saying "personal credit only" is not enough. List what is explicitly out: corporate credit, multi-currency, appeals, billing.
- **No invariants**: "The score must be between 300 and 850" is an invariant. "We usually reject low scores" is not.

---

## Change History

| Date | Change | By |
|---|---|---|
| 2026-05-18 | Initial playbook for Act 1 — Conception | po |
