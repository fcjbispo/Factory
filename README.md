# Factory Framework

> Framework for managing and executing software projects with AI agents.
> Integrates **Domain-Driven Design (DDD)** and **Spec-Driven Development (SDD)** as the central paradigm.

Factory defines how projects are structured, documented, operated, and evolved — by both humans and AI agents. It manages **documentation and configuration**, keeping a clear separation from source code.

## DDD + SDD Paradigm

Starting from v1.2.0, Factory adopts the integration between DDD (strategic/tactical) and SDD (operational):

- **DDD** defines the what and the why — bounded contexts, ubiquitous language, aggregates, domain events
- **SDD** formalizes how this becomes an executable contract — APIs, invariants, breaking changes

Each bounded context exposes its own spec in `docs/api/`. The file `docs/domain/context-map.md` records how contexts relate to each other.

## Structure

```
~/Dev/
├── Factory/                    ← Factory repository
│   ├── factory-init.sh         ← single entry point
│   ├── FACTORY-GUIDE.md        ← canonical guide
│   └── docs/
│       ├── agents/             ← 7 AI agent profiles
│       └── templates/          ← documentation templates
└── Projects/
    └── <project>/              ← source code
```

Documentation and configuration live in `~/Dev/Factory/<project>/`. Source code lives in `~/Dev/Projects/<project>/`. The bridge between the two is `/add-dir` inside Claude Code sessions.

## Installation

```bash
cd ~/Dev/Factory

# Install agents globally
./factory-init.sh agents

# Add shell function to profile
./factory-init.sh shell-setup >> ~/.zshrc && source ~/.zshrc
```

## Quick usage

```bash
# Create new project
./factory-init.sh new my-project

# Integrate existing project (full migration)
./factory-init.sh adopt my-project --mode=full

# Integrate existing project (coexistence)
./factory-init.sh adopt my-project --mode=coexist

# List registered projects
./factory-init.sh list

# Update framework from master branch
./factory-init.sh update [--version=X.Y.Z] [--dry-run]

# Propagate templates to project
./factory-init.sh sync <name> [--dry-run]

# Show command to start session
./factory-init.sh work my-project
```

## AI Agents

7 specialized agents, installed globally via `./factory-init.sh agents`:

| Agent                | Role                                                   |
| ----------------------| --------------------------------------------------------|
| Senior Architect     | Architecture, ADRs, API contracts, system design       |
| Full-Stack Developer | Feature implementation, bug fixes, commits               |
| DB Architect         | Data modeling, migrations, query optimization            |
| Code Reviewer        | Mandatory PR review, quality, security                   |
| QA Tester            | Test strategy, automation, release quality criteria    |
| DevOps/SRE           | CI/CD, infrastructure, observability, postmortems      |
| Security Analyst     | Threat modeling, vulnerabilities, LGPD/GDPR              |

## Documentation

Every Factory project is documented with canonical templates in the sections: ADR, API, architecture, backlog (production management), database, design, domain (DDD context-map), operations, security, testing, product decisions, and session context.

### Backlog (new in v1.3.0)

Continuous production management with MoSCoW + RICE prioritization. Categories: bugs, improvements, technical debt, documentation, security, performance, dependencies, and data. States: `open` → `in-analysis` → `prioritized` → `in-progress` → `resolved`.

## Fundamental rules

- No document is created without a template — always use the section's `_template.md`
- Every document has mandatory YAML frontmatter (`type`, `status`, `owner`, `updated`)
- Accepted ADRs are never edited — they are replaced by a new one
- `database/changelog.md` is append-only
- Active vulnerabilities are not stored in the repository

## Further reading

- [FACTORY-GUIDE.md](FACTORY-GUIDE.md) — complete canonical guide
- [docs/templates/INDEX.md](docs/templates/INDEX.md) — documentation entry point
- [docs/templates/GUIDE.md](docs/templates/GUIDE.md) — documentation conventions
