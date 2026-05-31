---
type: index
scope: api
updated: YYYY-MM-DD
---

# API — Interface Contracts

Every API must have its contract defined **before** implementation.
The contract is the source of truth — implementation follows the contract, never the other way around.

## Active Contracts

| File | Type | Version | Status | Owner |
|---|---|---|---|---|
| — | REST / GraphQL / Events | — | — | — |

## How to use

- REST: create `.yaml` files in the OpenAPI 3.x standard
- GraphQL: create `.graphql` files with the full SDL
- Events/Messages: create `.md` files describing payload, producer, and consumers
- Name files in `kebab-case` with the type suffix: `users-api.yaml`, `order-events.md`
- When creating a new contract, add the entry in the table above and notify @fullstack-developer
