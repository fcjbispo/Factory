---
type: research
scope: backlog.v1.3.0
updated: 2026-04-28
---

# Research v1.3.0 — Backlog Management

## Sources

- Hel (DevOps/SRE) — glm-5.1:cloud
- Balder (DB Architect) — deepseek-v4-flash:cloud (timeout)
- Web search — SearXNG

## Learnings from Hel

### Severity by Category

| Category | Critical | High | Medium | Low |
|---|---|---|---|---|
| Bugs | Production down | Degraded | Workaround | Cosmetic |
| Security | CVSS ≥ 9 | CVSS 7-8.9 | CVSS 4-6.9 | CVSS < 4 |
| Performance | SLO broken | High latency | Light degradation | Optimization |
| Tech Debt | Blocking | Hinders features | Refactoring | Modernization |

### Triage Template

Mandatory fields:
- Technical severity
- Business impact
- Estimated effort
- Risk of not doing
- Dependencies

## Learnings from Web Search

### Best Practices 2026

1. **Shift-left security** — include security from the start
2. **Dependency scanning** — verification automation
3. **SBOM** — Software Bill of Materials mandatory
4. **Blameless postmortems** — focus on systems
5. **Sustainable development** — allocate time for technical debt

### Technical Debt Management

- Visibility: make debt visible
- Strategic prioritization
- Consistent allocation (20% of time)
- Metrics: lead time, cycle time

## Identified Gaps

- Need for integration with GitHub Issues (future)
- Triage automation (future)
- Metrics dashboard (future)

## Decisions

- Prioritization: MoSCoW + RICE
- States: open → in-analysis → prioritized → in-progress → resolved
- Single template for all categories
- Quarterly tech debt review
