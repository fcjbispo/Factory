---
type: index
scope: backlog
updated: 2026-04-28
---

# Backlog — Production Management

Production management documents for projects in continuous operation.

## Main Documents

| File | Content | Status |
|---|---|---|
| [backlog-rules.md](backlog-rules.md) | Prioritization and backlog flow rules | `draft` |
| [issues/INDEX.md](issues/INDEX.md) | Bugs and reported problems | `draft` |
| [improvements/INDEX.md](improvements/INDEX.md) | Improvements and technical features | `draft` |
| [tech-debt/INDEX.md](tech-debt/INDEX.md) | Technical debt and refactoring | `draft` |
| [documentation/INDEX.md](documentation/INDEX.md) | Documentation management | `draft` |
| [security/INDEX.md](security/INDEX.md) | Vulnerabilities and patches | `draft` |
| [performance/INDEX.md](performance/INDEX.md) | Bottlenecks and tuning | `draft` |
| [dependencies/INDEX.md](dependencies/INDEX.md) | Updates and EOL | `draft` |
| [data/INDEX.md](data/INDEX.md) | Migrations and backup | `draft` |

## How to use

- All items follow the `_template.md` template
- Naming: `YYYY-MM-DD-short-title.md`
- Status: `open` → `under-analysis` → `prioritized` → `in-progress` → `resolved` | `rejected` | `suspended`
- Priority: `P1` (critical) | `P2` (high) | `P3` (medium) | `P4` (low)

## Owners

- **PO** — triage and prioritization
- **Architect** — technical impact and estimation
- **Agents** — execution according to role

## Flow

1. Item is reported (any agent or PO)
2. PO does initial triage
3. Architect assesses technical impact
4. PO prioritizes
5. Agent executes
6. Code reviewer validates
7. QA tester verifies
8. DevOps/SRE deploys
9. Item closed