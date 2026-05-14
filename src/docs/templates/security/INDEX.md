---
type: index
scope: security
updated: YYYY-MM-DD
---

# Security — Security

> ⚠️ **Active** vulnerabilities are not documented here.
> They are managed in a private channel and reported directly to the PO.
> This repository only records already treated vulnerabilities and current policies.

## Main Documents

| File | Content | Status |
|---|---|---|
| [policies.md](policies.md) | Project security policies | `draft` |

## Threat Models

| File | Analyzed component | Date | Status |
|---|---|---|---|
| — | — | — | — |

## How to use

- `policies.md`: mandatory reading for all agents. Updated by @security-analyst, reviewed every 6 months or after an incident.
- Threat models: copy `threat-models/_template.md`, name it `YYYY-MM-DD-name-of-component.md` and add the entry in the table above.
- Threat models must be created by @security-analyst **before** implementing features with sensitive data or relevant attack surface.