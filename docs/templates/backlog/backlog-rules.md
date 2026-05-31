---
type: rules
scope: backlog
updated: 2026-04-28
---

# Backlog Rules

## Prioritization

### MoSCoW + RICE

| Priority | MoSCoW | RICE Score | Who decides |
|---|---|---|---|
| P1 (critical) | Must have | >100 | PO + Architect |
| P2 (high) | Should have | 50-100 | PO |
| P3 (medium) | Could have | 20-50 | PO |
| P4 (low) | Won't have | <20 | PO |

### RICE Factors

- **Reach**: how many users/systems affected?
- **Impact**: what is the business impact? (0.25=marginal, 0.5=low, 1=medium, 2=high, 3=massive)
- **Confidence**: how certain is the data? (%)
- **Effort**: how many person-months?

## State Flow

```
open → in-analysis → prioritized → in-progress → resolved
                                    ↓
                              suspended → rejected
```

## Transitions

| From | To | Who can | Condition |
|---|---|---|---|
| open | in-analysis | Any agent | Item reported |
| in-analysis | prioritized | PO + Architect | Impact assessed |
| in-analysis | rejected | PO | Does not make sense |
| prioritized | in-progress | PO | Capacity available |
| in-progress | resolved | Executor | Acceptance criteria met |
| in-progress | suspended | PO | External blocker |
| suspended | in-progress | PO | Blocker resolved |
| suspended | rejected | PO | Permanent blocker |

## Responsibilities

| Role | Responsibility |
|---|---|
| PO | Triage, prioritization, approval |
| Architect | Technical impact, estimation, risks |
| Executor | Implementation, testing, documentation |
| Code Reviewer | Technical validation |
| QA Tester | Functional validation |
| DevOps/SRE | Deploy, monitoring |

## Meetings

- **Daily**: 15min, focus on blockers
- **Review**: weekly, demonstration
- **Retrospective**: monthly, continuous improvement
- **Planning**: biweekly, next sprint

## Metrics

- Lead time: open → resolved
- Cycle time: in-progress → resolved
- Throughput: items resolved/week
- WIP limit: maximum items in progress per agent
