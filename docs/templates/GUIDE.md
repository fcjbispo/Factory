---
type: guide
scope: global
updated: YYYY-MM-DD
---

# Project Documentation Guide

This guide defines how to create, update, maintain, and navigate this project's documentation. It is intended for both humans and AI agents.

---

## Philosophy

This structure was designed for the **AI-assisted development** paradigm. This implies different principles from traditional documentation:

**1. Machine readability is as important as human readability.**
Documents have structured frontmatter, explicit status, and declared owners. Agents do not "browse" — they search and read. Make the path obvious.

**2. One document = one responsibility.**
Do not mix architectural decisions with feature specifications. Do not mix runbook with postmortem. Atomic documents are easier to find, update, and replace.

**3. The INDEX.md of each section is the source of truth for what exists.**
Every agent must read the `INDEX.md` of a section before creating a new document to avoid duplication.

**4. Documents have a lifecycle.**
No document is permanent. Every document has a status. `deprecated` or `replaced` documents are not deleted — they are marked and remain as history.

**5. Updates are mandatory.**
An outdated document is worse than a nonexistent one: it leads agents and humans to error. If something changed, update or deprecate it.

---

## Frontmatter structure (mandatory in all documents)

Every document must begin with a YAML block:

```yaml
---
type: adr | api-contract | architecture | design | database | runbook | postmortem | threat-model | test-strategy | decision | policy
status: draft | in-review | active | deprecated | replaced-by: [path/to/new-file.md]
owner: senior-architect | fullstack-developer | db-architect | code-reviewer | qa-tester | devops-sre | security-analyst | po
readers: [list of agents that must read this document]
updated: YYYY-MM-DD
related:
  - relative/path/to/related-doc.md
---
```

**Mandatory fields**: `type`, `status`, `owner`, `updated`
**Recommended fields**: `readers`, `related`

---

## Guide by section

### `adr/` — Architecture Decision Records

**What goes here**: significant, high-impact technical decisions that are difficult or costly to reverse.

**What does NOT go here**: product decisions, reversible implementation choices, style preferences.

**When to create an ADR**:
- Technology choice (database, framework, language)
- Architectural pattern definition (microservices vs monolith, event-driven vs request-response)
- Change that affects multiple modules or teams
- Decision that was debated and had alternatives considered

**Naming format**: `NNNN-short-title-in-kebab-case.md` (ex: `0001-database-choice.md`)

**Numbering**: sequential, with 4-digit zero-padding. Never reuse a number.

**ADR statuses**: `proposed` → `accepted` → `deprecated` | `replaced-by: [adr/NNNN-new.md]`

**Owner**: senior-architect creates and maintains. PO approves high-impact decisions.

---

### `api/` — API Contracts

**What goes here**: formal specifications of REST APIs (OpenAPI), GraphQL schemas, event/message contracts, webhooks.

**What does NOT go here**: internal usage documentation of functions or classes (this is code documentation).

**When to create**:
- Before implementing any endpoint or mutation
- When adding domain events to the system
- When exposing integrations with external systems

**Format**: OpenAPI 3.x in YAML for REST. SDL for GraphQL. Structured Markdown for events.

**Critical rule**: the contract is the source of truth. Implementation follows the contract — never the opposite. Divergences between implementation and contract are bugs.

**Owner**: senior-architect defines. fullstack-developer implements. code-reviewer validates compliance.

---

### `architecture/` — System Architecture

**What goes here**: system overview, component description, context/container/component diagrams, data flows, external integrations.

**Subsection `diagrams/`**: store diagrams as code whenever possible (Mermaid, PlantUML, C4) instead of binary images. Images go in `diagrams/assets/`.

**Expected documents**:
- `overview.md`: high-level overview — mandatory, it is the first document all agents read
- `components.md`: detailed description of each component/module
- `integrations.md`: external systems and how the system interacts with them
- `data-flow.md`: how data flows through the system (optional, depending on complexity)

**Owner**: senior-architect creates and maintains.

---

### `database/` — Database

**What goes here**: entity-relationship model, table/collection description, indexes, access policies, schema changelog.

**Expected documents**:
- `schema.md`: complete description of the current data model
- `changelog.md`: history of all schema changes (append-only, never edit previous entries)
- `indexes.md`: justification for existing indexes (optional, depending on complexity)
- `data-policies.md`: sensitive data classification, retention, LGPD/GDPR

**Owner**: db-architect creates and maintains. security-analyst reviews `data-policies.md`.

---

### `design/` — Feature Specifications

**What goes here**: design document for each feature or significant change, written before implementation.

**Naming format**: `YYYY-MM-DD-name-of-feature.md`

**When to create**: for any feature that involves more than one agent or that implies nontrivial design decisions. Simple features (straightforward CRUD) may be implemented directly based on acceptance criteria.

**Minimum content**: context and problem, proposed solution, alternatives considered, impact on existing components, acceptance criteria, testing approach.

**Owner**: senior-architect creates. PO approves. All involved agents read before starting.

---

### `operations/` — Operations

**What goes here**: runbooks, deploy procedures, rollback procedures, incident postmortems.

**`runbook.md`**: living document with all critical operational procedures. Must be executable — real commands, not vague descriptions.

**Subsection `postmortems/`**: one file per incident. Format: `YYYY-MM-DD-name-of-incident.md`. Postmortems are blameless — the focus is on systems, processes, and prevention, never on people.

**Owner**: devops-sre creates and maintains. Postmortems involve all affected agents.

---

### `security/` — Security

**What goes here**: security policies, threat models, record of handled vulnerabilities.

**`policies.md`**: document with all project security policies (authentication, authorization, sensitive data handling, secrets management, etc.). All agents must read.

**Subsection `threat-models/`**: one file per analyzed feature or component. Format: `YYYY-MM-DD-name-of-component.md`.

**Critical rule**: active vulnerabilities do not live in this repository — they are managed in a private channel and reported to the PO. This repository only records already handled vulnerabilities, as history.

**Owner**: security-analyst creates and maintains.

---

### `testing/` — Testing and Quality

**What goes here**: test strategy, project test pyramid, coverage thresholds, test environments, test data.

**`test-strategy.md`**: central document with the complete strategy. Includes what is tested at each level (unit, integration, e2e), tools used, coverage thresholds, and quality criteria for release.

**Owner**: qa-tester creates and maintains. senior-architect and devops-sre contribute.

---

### `decisions/` — Product and Business Decisions

**What goes here**: decisions made by the PO that impact the product — prioritizations, scope changes, business trade-offs, persona definitions, nonfunctional requirements.

**What does NOT go here**: technical decisions (go in `adr/`).

**Naming format**: `YYYY-MM-DD-title-of-decision.md`

**Owner**: PO creates and maintains. Agents consult to understand business context.

---

## Maintenance rules

**When creating a document**:
1. Use the section's `_template.md`
2. Fill out the frontmatter completely
3. Add the entry to the section's `INDEX.md`
4. If the document replaces another, update the old one's status to `replaced-by: [new-file.md]`

**When updating a document**:
1. Update the frontmatter `updated` field
2. Record what changed in the `## Change history` section
3. If the change is significant, notify the `readers` declared in the frontmatter

**When deprecating a document**:
1. Change `status` to `deprecated` or `replaced-by: [path]`
2. Add a note at the top of the document explaining why it was deprecated
3. DO NOT delete the file

**Review periodicity**:
- `architecture/overview.md`: review at every major release
- `adr/`: never edit an accepted ADR — create a new one that replaces it
- `operations/runbook.md`: review after each incident
- `security/policies.md`: review every 6 months or after a security incident
- `testing/test-strategy.md`: review when the test strategy changes

---

## Change history of this guide

| Date | Change | By |
|---|---|---|
| YYYY-MM-DD | Initial version | senior-architect |
