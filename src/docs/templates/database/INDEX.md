---
type: index
scope: database
updated: YYYY-MM-DD
---

# Database — Data Model

Every schema change must be reflected here **before** reaching code.

## Documents

| File | Content | Status |
|---|---|---|
| [schema.md](schema.md) | Complete current data model | `draft` |
| [changelog.md](changelog.md) | Schema change history (append-only) | `draft` |
| [data-policies.md](data-policies.md) | Data classification, retention, LGPD/GDPR | `draft` |

## How to use

- `schema.md`: describes the **current** state of the model. Updated by @db-architect with each migration.
- `changelog.md`: **append-only** record — never edit previous entries, only add new ones.
- `data-policies.md`: reviewed by @security-analyst. Classifies each field with sensitive data or PII.
- For new entities: produce the ERD before writing any migration and submit to @senior-architect.