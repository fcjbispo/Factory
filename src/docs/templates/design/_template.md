---
type: design
status: draft
owner: senior-architect
readers: [fullstack-developer, db-architect, qa-tester, security-analyst]
updated: YYYY-MM-DD
related: []
---

# [Feature Name]

## Context and problem

> Why does this feature exist? What business or technical problem does it solve?

## Proposed solution

> Describe the solution in clear language. Include the main flow and relevant alternative flows.

## Affected components

| Component | Impact type | Responsible agent |
|---|---|---|
| [name] | new / modified / removed | [agent] |

## API Contract

> Reference or describe the involved endpoints/events. If the contract does not yet exist in `api/`, it must be created before implementation.

```
# Reference: api/[contract-name].yaml
```

## Data model

> Describe new or modified entities. If there is a migration, the DB Architect must create the schema in `database/` before implementation.

## Acceptance criteria

- [ ] Given [context], when [action], then [expected result]
- [ ] Given [context], when [invalid action], then [expected error behavior]

## Testing approach

| Type | What to test | Responsible |
|---|---|---|
| Unit | [specific logic] | fullstack-developer |
| Integration | [specific flow] | qa-tester |
| E2E | [critical path] | qa-tester |

## Security considerations

> What sensitive data is involved? Are there specific authentication/authorization requirements? Reference the threat model if it exists.

## Performance considerations

> Are there volume or latency expectations? Are there risks of N+1 queries or known bottlenecks?

## Discarded alternatives

> Briefly document what was considered and why it was discarded.

## Change history

| Date | Change | By |
|---|---|---|
| YYYY-MM-DD | Initial version | senior-architect |