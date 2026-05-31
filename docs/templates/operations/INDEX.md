---
type: index
scope: operations
updated: YYYY-MM-DD
---

# Operations — Operations and Reliability

## Main documents

| File | Content | Status |
|---|---|---|
| [runbook.md](runbook.md) | Critical operational procedures | `draft` |

## Postmortems

| File | Incident | Severity | Date | Status |
|---|---|---|---|---|
| — | — | — | — | — |

## How to use

- `runbook.md`: living document with real, executable commands. Updated by @devops-sre after each incident or infrastructure change.
- Postmortems: copy `postmortems/_template.md`, name it `YYYY-MM-DD-incident-name.md` and add the entry in the table above.
- Postmortems are **blameless** — focus on systems and processes, never on people.
- Severity: `P1` (critical, production down) | `P2` (degraded, partial impact) | `P3` (low impact)
