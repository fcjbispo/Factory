---
type: index
scope: api
updated: YYYY-MM-DD
---

# API — Interface Contracts

Every API must have a defined contract **before** implementation.
The contract is the source of truth — implementation follows the contract, never the opposite.

## Active Contracts

| File | Type | Version | Status | Owner |
|---|---|---|---|---|
| — | REST / GraphQL / Events | — | — | — |

## How to use

- REST: create `.yaml` files in OpenAPI 3.x standard
- GraphQL: create `.graphql` files with complete SDL
- Events/Messages: create `.md` files describing payload, producer, and consumers
- Name files in `kebab-case` with type suffix: `users-api.yaml`, `order-events.md`
- When creating a new contract, add the entry in the table above and communicate to @fullstack-developer
