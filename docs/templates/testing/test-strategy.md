---
type: test-strategy
status: active
owner: qa-tester
readers: [all]
updated: YYYY-MM-DD
related:
  - architecture/overview.md
---

# Test Strategy

## Test pyramid

```
        /\
       /E2E\          few — critical end-to-end flows
      /------\
     /Integration\     moderate — collaboration between modules
    /------------\
   /   Unit Test  \   majority — isolated business logic
  /--------------/
```

## Tools

| Type | Tool | Configuration |
|---|---|---|
| Unit | [ex: Jest, Vitest, pytest] | [config file] |
| Integration | [ex: Supertest, pytest] | [config file] |
| E2E | [ex: Playwright, Cypress] | [config file] |
| Coverage | [ex: Istanbul, coverage.py] | [config file] |

## Coverage thresholds

| Metric | Minimum threshold | Desired threshold |
|---|---|---|
| Lines | 80% | 90% |
| Branches | 75% | 85% |
| Functions | 80% | 90% |

> Builds below the minimum threshold are blocked in CI.

## What to test at each level

### Unit
- All business logic in services and use-cases
- Transformation, validation, and calculation functions
- Edge cases and error handling

### Integration
- API endpoints (request → response, including errors)
- Database access (queries, migrations)
- Integration with external services (via mocks/contracts)

### E2E
- Critical flows from the user's perspective
- Maximum of [N] scenarios — prioritize highest business value flows

## Test data

- Fixtures: [location]
- Seeds: [location or command]
- PII in tests: never use real data. Use synthetic data generators.

## Flaky tests

Every unstable test must be registered and fixed within [N days]. A flaky test is a bug.

## Release quality criteria

- [ ] Full suite passes without failures
- [ ] Coverage above minimum thresholds
- [ ] No active flaky tests
- [ ] Regression tests for all bugs fixed in the release

## Change history

| Date | Change | By |
|---|---|---|
| YYYY-MM-DD | Initial version | qa-tester |
