# FACTORY-GUIDE.md

**Version:** _1.3.0_

> Central guide of the Factory framework.
> Mandatory reading for any agent or human before starting, migrating, or operating a project under this framework.

---

## What is Factory

Factory is the software project management and execution framework of this organization. It defines how projects are structured, documented, operated, and evolved — by both humans and AI agents.

Factory manages **documentation and configuration**. Source code lives separately, in `~/Dev/Projects/`. The `factory-init.sh` script is the single entry point for all project lifecycle operations — never create structures manually.

---

## DDD + SDD Paradigm

Starting from version 1.2.0, Factory adopts the integration between **Domain-Driven Design (DDD)** and **Spec-Driven Development (SDD)** as the central paradigm for modeling and contract formalization.

### What each one does

**DDD is strategic and tactical** — defines the what and the why:
- What are the bounded contexts of the system?
- What is the ubiquitous language of each context?
- What are the aggregates, entities, and value objects?
- What are the domain events and how do contexts communicate?

**SDD is operational** — formalizes how this becomes an executable contract:
- How do domain concepts become API contracts?
- Which fields are mandatory? What are the invariants?
- How do contexts communicate via spec?
- What constitutes a breaking change?

### Golden rule

> Spec names must be **identical** to the DDD ubiquitous language.
> If the domain calls it `Pedido`, the spec cannot call it `Order` or `Compra`.

### Without DDD in SDD (what to avoid)

Spec uses generic technical names (`item`, `record`, `data`). Nobody knows what it represents. Contexts mix in the same API. Domain invariants are lost or remain only in code.

### With DDD guiding SDD (the goal)

Spec uses business language (`Pedido`, `Estoque`, `Pagamento`). Each bounded context has its own spec. Contracts reflect domain invariants. The spec is readable by business specialists.

### DDD → SDD Mapping

| DDD Concept | Spec Element |
|---|---|
| Root Aggregate | Main type + mutations (`createX`, `updateX`) |
| Entity | Type with `id: ID!` |
| Value Object | `input type` (no ID, immutable) |
| Domain Invariant | Field `!` (non-null) or `minItems` |
| Aggregate State | `enum` |
| Domain Event | GraphQL Subscription or AsyncAPI channel |
| Bounded Context | Separate spec (own file in `api/`) |
| Anti-Corruption Layer | Explicit translation spec between contexts |

### Each context = a separate spec

There is no giant schema. Each bounded context exposes its own API with its own types and contracts. The `docs/domain/context-map.md` file records how contexts relate and which specs correspond to each.

---

## Factory Structure

```
~/Dev/
├── Factory/ ← Factory repository
│ ├── FACTORY-GUIDE.md ← this document
│ ├── factory-init.sh ← single entry point for operations
│ ├── docs/
│ │ ├── agents/ ← AI agent profiles
│ │ └── templates/ ← reusable documentation templates
│ └── [project-name]/ ← one directory per project
│ ├── .factory ← config: records src_path and metadata
│ ├── docs/ ← documentation (derived from templates)
│ └── docs-legacy/ ← pre-Factory documentation (full mode)
│
└── Projects/
 └── [project-name]/ ← project source code
 ├── .claude/
 │ └── commands/
 │ └── factory-init.md ← shortcut to load context in session
 └── CLAUDE.md ← project identity and pointers to Factory
```

---

## Complete Map: `Factory/docs/`

### `docs/agents/`

**Purpose**: repository of AI agent profiles available for all Factory projects.

**Responsible**: PO defines the team. Senior Architect maintains technical profiles.

**When to use**: execute `./factory-init.sh agents` to install all agents globally in `~/.claude/agents/`. Available in any project on the machine without duplication.

| File | Agent | Main Role |
|---|---|---|
| `arquiteto-senior.md` | Senior Architect | Architecture decisions, ADRs, API contracts, DDD modeling, system design |
| `fullstack-developer.md` | Full-Stack Developer | Feature implementation, unit tests, commits |
| `db-architect.md` | DB Architect | Data modeling, migrations, query optimization |
| `code-reviewer.md` | Code Reviewer | Mandatory PR review, quality, standards, code security |
| `qa-tester.md` | QA Tester | Testing strategy, automation, release quality criteria |
| `devops-sre.md` | DevOps/SRE | CI/CD, infrastructure, observability, postmortems |
| `security-analyst.md` | Security Analyst | Threat modeling, security policies, vulnerability auditing |
| `README.md` | — | Agent installation and usage instructions |

---

### `docs/templates/`

**Purpose**: canonical documentation templates. No project document is created from scratch — always based on a template from this folder.

**Responsible**: Senior Architect maintains technical templates. PO maintains product decision templates.

**When to use**: `factory-init.sh` automatically copies this structure to `Factory/[project]/docs/` when creating or adopting a project. Never copy manually.

---

#### `templates/INDEX.md`

**Purpose**: entry point for documentation of any project. Lists what exists, where it is, and who should read what by agent.

**Responsible**: Senior Architect creates when starting the project and keeps updated.

**Mandatory action**: every agent reads this file before anything else when entering a project.

---

#### `templates/GUIDE.md`

**Purpose**: usage guide for the project's documentation structure — naming conventions, mandatory frontmatter, document lifecycle, maintenance rules, and review periodicity.

**Responsible**: Senior Architect. Should not be changed by other agents without approval.

**Mandatory action**: read on the first work session in any project.

---

#### `templates/domain/` ← **new in v1.2.0**

**Purpose**: domain modeling by the DDD paradigm. Defines bounded contexts, ubiquitous language, aggregates, entities, value objects, and domain events. It is the **source of truth for names and contracts** of all specs in `api/`.

**Responsible**: Senior Architect leads with domain specialists (PO and business stakeholders). No name in the spec may diverge from this glossary.

**Critical rule**: every spec in `api/` must be derived from a bounded context documented in `domain/`. Specs not traceable to a domain context are not accepted.

| File | Description |
|---|---|
| `INDEX.md` | Tabular record of all bounded contexts with status and corresponding spec |
| `context-map.md` | Map of how contexts relate (conformist, ACL, publisher/consumer) |
| `_template-bounded-context.md` | Template to document a bounded context: aggregates, entities, value objects, invariants, and domain events |
| `_template-ubiquitous-language.md` | Template for the ubiquitous language glossary of each context |

**Context naming**: `[context-name]-context.md` — ex: `orders-context.md`, `inventory-context.md`
**Glossary naming**: `[context-name]-language.md` — ex: `orders-language.md`

**When to create**:
- When starting a new project: before any spec in `api/`
- When adopting an existing project: as part of the initial assessment
- When identifying a new bounded context emerging in the code

---

#### `templates/adr/`

**Purpose**: records significant and irreversible architectural decisions. An accepted ADR is never edited — it is replaced by a new one.

**Responsible**: Senior Architect creates. PO approves high-impact decisions.

| File | Description |
|---|---|
| `INDEX.md` | Tabular record of all project ADRs with status |
| `_template.md` | Template for new ADRs (context, decision, alternatives, consequences) |

**Naming**: `NNNN-short-title-in-kebab-case.md` — ex: `0001-database-choice.md`

**When to create an ADR**: technology choice, architectural pattern definition, change affecting multiple modules, any debated decision with alternatives considered. Includes bounded context delimitation decisions.

---

#### `templates/api/`

**Purpose**: formal API contracts. The contract is the source of truth — implementation follows the contract, never the opposite.

**Responsible**: Senior Architect defines contracts. Full-Stack Developer implements. Code Reviewer validates compliance.

| File | Description |
|---|---|
| `INDEX.md` | Record of all active contracts with type, version, originating bounded context, and status |

**Accepted formats**: OpenAPI 3.x (`.yaml`) for REST, SDL (`.graphql`) for GraphQL, AsyncAPI (`.yaml`) for events and messages.

**Critical rule**: no endpoint or event is implemented without an approved contract in this folder.

**DDD rule**: every spec must reference the originating bounded context in its frontmatter (`domain_context: context-name`). Type, field, and operation names must follow the glossary of the corresponding context in `domain/`.

---

#### `templates/architecture/`

**Purpose**: system overview — components, diagrams, integrations, data flows.

**Responsible**: Senior Architect creates and maintains.

| File/Folder | Description |
|---|---|
| `overview.md` | System overview. Mandatory reading for all agents. |
| `diagrams/` | Diagrams as code (Mermaid, PlantUML, C4). Binary images in `diagrams/assets/`. |

**Additional recommended documents** (create as needed by project):
- `components.md`: detailed description of each module
- `integrations.md`: external systems and how the project interacts with them
- `data-flow.md`: how data flows through the system

---

#### `templates/database/`

**Purpose**: data model, schema changelog, and data handling policies.

**Responsible**: DB Architect creates and maintains. Security Analyst reviews `data-policies.md`.

| File | Description |
|---|---|
| `INDEX.md` | Index of database documents with status |
| `schema.md` (to create) | Complete current state of the data model |
| `changelog.md` (to create) | Append-only history of schema changes |
| `data-policies.md` (to create) | Sensitive data classification, retention, LGPD/GDPR |

**Critical rule**: `changelog.md` is append-only — never edit previous entries.

---

#### `templates/backlog/` — NEW in v1.3.0

**Purpose**: continuous production management — bugs, improvements, technical debt, documentation, security, performance, dependencies, and data.

**Responsible**: PO triages and prioritizes. Architect assesses technical impact. Agents execute according to role.

| File/Folder | Description |
|---|---|
| `INDEX.md` | Backlog overview and flow rules |
| `backlog-rules.md` | Prioritization rules (MoSCoW + RICE), states, responsibilities |
| `_template.md` | Standardized template for any backlog item |
| `issues/` | Bugs and reported problems |
| `improvements/` | Improvements and technical features |
| `tech-debt/` | Technical debt and refactoring |
| `documentation/` | Management of outdated or missing documentation |
| `security/` | Vulnerabilities, patches, and security updates |
| `performance/` | Bottlenecks, tuning, and scalability |
| `dependencies/` | Dependency updates, EOL, and vulnerabilities |
| `data/` | Migrations, backup, and retention policies |

**Naming**: `YYYY-MM-DD-short-title.md`

**States**: `open` → `under-analysis` → `prioritized` → `in-progress` → `resolved` | `rejected` | `suspended`

**Priority**: `P1` (critical) | `P2` (high) | `P3` (medium) | `P4` (low)

**General rules**:
1. Every item must have clear acceptance criteria
2. Mandatory quarterly review for tech-debt
3. Mandatory postmortem for critical severity issues
4. Deadlines: critical security=24h, high=7 days, medium=30 days, low=90 days

---

#### `templates/design/`

**Purpose**: feature specifications written **before** implementation. Defines the contract between PO, Architect, and implementation agents.

**Responsible**: Senior Architect creates. PO approves. All involved agents read before starting.

| File | Description |
|---|---|
| `INDEX.md` | Record of features in progress and completed |
| `_template.md` | Template with context, solution, affected components, acceptance criteria |

**Naming**: `YYYY-MM-DD-name-of-feature.md`

**When to create**: for any feature involving more than one agent or non-trivial design decisions.

---

#### `templates/operations/`

**Purpose**: critical operational procedures and historical incident records.

**Responsible**: DevOps/SRE creates and maintains.

| File/Folder | Description |
|---|---|
| `INDEX.md` | Index of operational documents and postmortem list |
| `runbook.md` (to create) | Living document with real commands for critical operations |
| `postmortems/` | One file per incident |
| `postmortems/_template.md` | Blameless template with timeline, root cause, and corrective actions |

**Postmortem naming**: `YYYY-MM-DD-name-of-incident.md`

---

#### `templates/security/`

**Purpose**: project security policies and threat models by component.

**Responsible**: Security Analyst creates and maintains.

| File/Folder | Description |
|---|---|
| `INDEX.md` | Index with warning about active vulnerabilities and threat model list |
| `policies.md` (to create) | Authentication, authorization, secrets, sensitive data policies |
| `threat-models/` | One file per analyzed component or feature |
| `threat-models/_template.md` | STRIDE template with assets, threats, controls, and accepted risks |

**Warning**: active vulnerabilities **do not** live in this folder — they are managed in a private channel.

---

#### `templates/testing/`

**Purpose**: project testing strategy — SBD paradigm, tools, thresholds, and release criteria.

**Responsible**: QA Tester creates and maintains.

| File | Description |
|---|---|
| `test-strategy.md` | Central document with complete strategy. Mandatory reading for all agents. |

---

#### `templates/decisions/`

**Purpose**: product and business decisions made by the PO. Distinct from ADRs, which are technical decisions.

**Responsible**: PO creates and maintains. Agents consult to understand business context.

| File | Description |
|---|---|
| `INDEX.md` | Record of all product decisions with status |
| `_template.md` | Template with context, decision, motivation, trade-offs, and review criteria |

**Naming**: `YYYY-MM-DD-title-of-decision.md`

---

#### `templates/context/`

**Purpose**: persistent session context between work sessions.

**Responsible**: all agents update at the end of each significant session.

| File | Description |
|---|---|
| `active.md` | Current focus, recent decisions, next steps, blockers |
| `progress.md` | What is complete, in progress, and pending |

**Rule**: mandatory reading at the beginning of each session, before any task.

---

## Initial Factory Setup (once per machine)

```bash
cd ~/Dev/Factory

# Install agents globally
./factory-init.sh agents

# Add shell function to profile
./factory-init.sh shell-setup >> ~/.zshrc && source ~/.zshrc
```

---

## Starting a project from scratch

```bash
cd ~/Dev/Factory
./factory-init.sh new <project-name>
```

The script automatically creates:
- `~/Dev/Projects/<name>/` with `CLAUDE.md`
- `Factory/<name>/docs/` from templates (includes `domain/`)
- `Factory/<name>/docs/context/` for session context
- `Factory/<name>/.factory` with `src_path` registered
- `.claude/commands/factory-init.md` in the project

### First session

```bash
cd ~/Dev/Projects/<project-name>
# open Claude Code / your provider
```

Within the session:

```
/add-dir ~/Dev/Factory/<name>/docs
/factory-init
```

Then, the mandatory DDD → SDD → implementation sequence:

```
@arquiteto-senior Read docs/INDEX.md and docs/GUIDE.md.
Execute Event Storming with available context:
1. Identify the bounded contexts of the system
2. Create docs/domain/context-map.md with the context map
3. For each context, create docs/domain/[name]-context.md and docs/domain/[name]-language.md
4. Create docs/architecture/overview.md describing the initial architecture
5. Register the first ADR with technology decisions

@arquiteto-senior With bounded contexts defined in domain/,
create the corresponding API contracts in docs/api/,
ensuring all names follow the ubiquitous language of each context.

@qa-tester Read docs/architecture/overview.md and docs/domain/context-map.md.
Create docs/testing/test-strategy.md using SBD as paradigm,
considering the bounded contexts and domain events identified.

@security-analyst Read docs/architecture/overview.md and docs/domain/ .
Create docs/security/policies.md with initial security policies,
considering sensitive data for each bounded context.
```

---

## Integrating an existing project

Existing projects can be integrated in two modes: **full migration** or **coexistence**.

### Initial assessment (mandatory for both modes)

Start a session at the root of the existing project and execute:

```
@arquiteto-senior Perform an assessment of this project:
1. Map the code structure (modules, layers, identified patterns)
2. Identify bounded contexts emerging in the existing code
3. List all existing documentation and assess its quality
4. Identify technical decisions that should become ADRs
5. Point out the ubiquitous language implicit in the code (class names, tables, routes)
6. Point out critical documentation gaps
Produce a report for the PO to decide the integration mode.
```

---

### Mode 1: Full migration

**When to use**: project in active development, existing documentation scarce or outdated.

```bash
cd ~/Dev/Factory
./factory-init.sh adopt <project-name> --mode=full
```

The script automatically:
- Copies existing `docs/` to `Factory/<name>/docs-legacy/`
- Creates `Factory/<name>/docs/` from templates (includes `domain/`)
- Creates `Factory/<name>/docs/context/`
- Creates `CLAUDE.md` in the project with pointers to Factory and legacy
- Creates `.claude/commands/factory-init.md` in the project
- Registers the project in `Factory/<name>/.factory`

### First session after adopt

```bash
cd ~/Dev/Projects/<project-name>
# open Claude Code / your provider
```

```
/add-dir ~/Dev/Factory/<name>/docs
/factory-init
execute prompt factory-adoption
```

The `factory-adoption` prompt (saved in `~/Dev/Contexts/Prompts/factory-adoption.md`)
guides agents through the complete scan and population of the Factory structure,
including the discovery and documentation of bounded contexts in `domain/`.

### Archive legacy after validation with PO

```bash
tar -czf ~/Dev/Factory/<name>/docs-legacy.tar.gz \
 ~/Dev/Factory/<name>/docs-legacy/
rm -rf ~/Dev/Factory/<name>/docs-legacy/
```

---

### Mode 2: Coexistence

**When to use**: project in critical production, existing documentation still valid, immediate migration costly.

```bash
cd ~/Dev/Factory
./factory-init.sh adopt <project-name> --mode=coexist
```

The script creates `Factory/<name>/docs/` without touching the existing and configures
`CLAUDE.md` with precedence rules between the two sources.

### Behavior in coexistence mode

| Situation | Action |
|---|---|
| Create new documentation | Always in `Factory/<name>/docs/` |
| Create API specs | Always derived from `domain/` (ubiquitous language mandatory) |
| Consult documentation | Read both — Factory prevails in conflict |
| Update existing doc | Migrate from `docs/` to Factory first |

### Criteria to end coexistence mode

- More than 80% of active documentation in `Factory/docs/`
- No file in `docs/` consulted in the last 60 days
- `domain/` with all bounded contexts documented
- PO approves final migration

To end:

```bash
./factory-init.sh adopt <project-name> --mode=full
```

---

## Starting a work session

For any already registered project:

```bash
cd ~/Dev/Projects/<project-name>
# open Claude Code / your provider
```

Within the session, always in sequence:

```
/add-dir ~/Dev/Factory/<name>/docs
/factory-init
```

`/add-dir` loads Factory docs into the session context.
`/factory-init` guides Claude to read `docs/INDEX.md`,
`docs/context/active.md`, and `docs/context/progress.md`.

### Global reminder hook (optional)

Add to `~/.claude/settings.json` to receive the correct `/add-dir`
automatically when starting any session in a Factory project:

```json
{
 "hooks": {
 "SessionStart": [
 {
 "hooks": [
 {
 "type": "command",
 "command": "bash -c 'PROJECT=$(basename \"$PWD\"); DOCS=\"$HOME/Dev/Factory/$PROJECT/docs\"; if [ -d \"$DOCS\" ]; then echo \"{\\\"additionalContext\\\": \\\"/add-dir $DOCS\\\"}\" ; fi'"
 }
 ]
 }
 ]
 }
}
```

---

## Adding `/factory-init` to an already existing project

If the project was adopted before this script version:

```bash
cd ~/Dev/Factory
./factory-init.sh add-command <project-name>
```

---

## Quick reference for `factory-init.sh`

| Command | What it does |
|---|---|
| `./factory-init.sh agents` | Installs agents in `~/.claude/agents/` |
| `./factory-init.sh new <name>` | Creates new project (code + docs + domain/ + command) |
| `./factory-init.sh adopt <name> --mode=full` | Integrates existing project — full migration |
| `./factory-init.sh adopt <name> --mode=coexist` | Integrates existing project — coexistence |
| `./factory-init.sh add-command <name>` | Adds `/factory-init` to existing project |
| `./factory-init.sh work <name>` | Shows how to start session on the project |
| `./factory-init.sh list` | Lists registered projects with status |
| `./factory-init.sh shell-setup` | Generates shell function block for `.bashrc`/`.zshrc` |

---

## Quick reference for responsibilities

| Artifact | Creates | Maintains | Approves | Mandatory reading |
|---|---|---|---|---|
| `INDEX.md` (root) | senior-architect | senior-architect | — | all agents |
| `GUIDE.md` | senior-architect | senior-architect | PO | all agents (1st session) |
| `domain/INDEX.md` | senior-architect | senior-architect | PO | all agents |
| `domain/context-map.md` | senior-architect | senior-architect | PO | all agents |
| `domain/[ctx]-context.md` | senior-architect | senior-architect | PO | senior-architect, fullstack-developer |
| `domain/[ctx]-language.md` | senior-architect | senior-architect + PO | PO | all agents |
| `context/active.md` | any agent | all agents | — | all agents (session start) |
| `context/progress.md` | any agent | all agents | — | all agents (session start) |
| `adr/` | senior-architect | senior-architect | PO (high impact) | senior-architect, code-reviewer |
| `api/` | senior-architect | senior-architect | senior-architect | fullstack-developer, code-reviewer |
| `architecture/overview.md` | senior-architect | senior-architect | — | all agents |
| `database/` | db-architect | db-architect | senior-architect | fullstack-developer, security-analyst |
| `design/` | senior-architect | senior-architect | PO | all agents involved in the feature |
| `operations/runbook.md` | devops-sre | devops-sre | — | devops-sre |
| `operations/postmortems/` | devops-sre | devops-sre | — | all affected agents |
| `security/policies.md` | security-analyst | security-analyst | PO | all agents |
| `security/threat-models/` | security-analyst | security-analyst | senior-architect | devops-sre |
| `testing/test-strategy.md` | qa-tester | qa-tester | — | fullstack-developer, devops-sre |
| `decisions/` | PO | PO | — | senior-architect, fullstack-developer |

---

## General rules

1. **No document is created without a template.** Always use the `_template.md` of the corresponding section.
2. **Every document has frontmatter.** Fields `type`, `status`, `owner`, and `updated` are mandatory.
3. **Deprecated documents are not deleted.** Change the status and leave the history intact.
4. **Factory does not store source code.** Only management, documentation, and templates.
5. **One project per directory.** Never share code between Factory projects.
6. **`docs/` of project derives from `Factory/docs/templates/`.** Never edit templates directly in a project — edit in `Factory/docs/templates/` and propagate with `factory-init.sh`.
7. **Every project lifecycle passes through `factory-init.sh`.** Never create structures manually.
8. **Specs derive from domain.** No contract in `api/` is created without a corresponding bounded context in `domain/`. Names diverging from the ubiquitous language are documentation bugs.
9. **Ubiquitous language is contract.** The glossary in `domain/[ctx]-language.md` is the source of truth for naming. Any divergence between the glossary and the code or spec must be resolved — always in favor of the glossary.

---

## Change history

| Date | Version | Change | By |
|---|---|---|---|
| 2026-04-15 | 1.0.0 | Initial version | senior-architect |
| 2026-04-19 | 1.1.0 | Refactor: manual commands replaced by factory-init.sh; code/docs separation; work session section; global hook; context/ added | senior-architect |
| 2026-04-19 | 1.2.0 | DDD+SDD integration: new `domain/` section in templates; DDD→SDD paradigm documented; DDD concept to spec element mapping; rules 8 and 9 added; domain/ responsibilities in table; first session sequence updated to include Event Storming and bounded context discovery | senior-architect |
| 2026-04-28 | 1.3.0 | Production management: new `backlog/` section in templates; template for bugs, improvements, technical debt, documentation, security, performance, dependencies, and data; MoSCoW + RICE prioritization rules; state flow and responsibilities; Makefile with helper and release target; shellcheck passing without errors | senior-architect |
