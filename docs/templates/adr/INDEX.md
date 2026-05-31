---
type: index
scope: adr
updated: YYYY-MM-DD
---

# ADR — Architecture Decision Records

Registry of all significant architectural decisions of the project.
An accepted ADR is never edited — it is replaced by a new ADR.

## Registry

| ID | Title | Status | Date | Superseded by |
|---|---|---|---|---|
| [0001](0001-example.md) | [Decision title] | `proposed` | YYYY-MM-DD | — |

## How to use

- To propose a decision: copy `_template.md`, name it `NNNN-title.md` and set status to `proposed`
- To accept: change status to `accepted` after approval from the PO and Senior Architect
- To supersede: create a new ADR referencing the previous one, update the old one to `superseded-by: NNNN-new.md`
