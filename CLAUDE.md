# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Factory is a framework for managing AI-assisted software projects. It provides documentation templates, agent profiles, and a lifecycle script (`factory-init.sh`) that structures how projects are created, documented, and operated. This repository contains **only the framework itself** — no application code, no test suite, no linter.

The canonical reference is `FACTORY-GUIDE.md` (version 1.1.0).

## Architecture

Two-root separation: documentation/configuration lives in `~/Dev/Factory/<project>/`, source code lives in `~/Dev/Projects/<project>/`. The bridge between them is `/add-dir` inside Claude Code sessions. `factory-init.sh` is the single entry point for all project lifecycle operations — never create structures manually.

```
Factory/
├── factory-init.sh          ← single entry point (all commands)
├── FACTORY-GUIDE.md         ← canonical reference
├── docs/
│   ├── agents/              ← 7 AI agent profiles (installed globally)
│   └── templates/           ← documentation templates (copied to each project)
│       ├── INDEX.md         ← mandatory first read for all agents
│       └── GUIDE.md         ← documentation conventions
```

### .factory config format

Each project under `Factory/<name>/` has a `.factory` file (key=value) with: `name`, `src_path` (absolute path to source code), `created` (date), `mode` (`full` or `coexist`).

### Zikkaron hooks

`.claude/settings.json` configures 5 hooks for persistent memory across sessions:
- **PreCompact**: drains context to Zikkaron before compaction
- **SessionStart**: injects project context on new sessions; restores after compaction
- **PostToolUse**: captures every tool action into action log
- **UserPromptSubmit**: auto-recalls relevant memories on each user turn

## Validating factory-init.sh

No test suite exists. Validate with shellcheck:

```bash
shellcheck factory-init.sh
```

## Running factory-init.sh

Always execute from the repository root:

```bash
./factory-init.sh agents                        # install agent profiles to ~/.claude/agents/
./factory-init.sh new <name>                     # create new project
./factory-init.sh adopt <name> --mode=full       # integrate existing project (full migration)
./factory-init.sh adopt <name> --mode=coexist    # integrate existing project (coexistence)
./factory-init.sh add-command <name>             # add /factory-init command to existing project
./factory-init.sh work <name>                    # show session start command
./factory-init.sh list                           # list registered projects
./factory-init.sh shell-setup                    # generate shell function for .bashrc/.zshrc
```

Environment variables: `FACTORY_ROOT` (repo root), `FACTORY_PROJECTS_DIR` (default `~/Dev/Projects`).

## Agent profiles

7 agents in `docs/agents/`, installed globally via `./factory-init.sh agents`. All profiles use `model: inherit` (inherit from the parent Claude Code session).

| Agent | Recommended model | Role |
|---|---|---|
| senior-architect | Opus | Architecture, ADRs, API contracts, system design |
| fullstack-developer | Sonnet | Feature implementation, bug fixes, commits |
| db-architect | Sonnet | Data modeling, migrations, query optimization |
| code-reviewer | Opus | Mandatory PR review, quality, security in code |
| qa-tester | Sonnet | Test strategy, automation, release quality criteria |
| devops-sre | Sonnet | CI/CD, infrastructure, observability, postmortems |
| security-analyst | Opus | Threat modeling, vulnerability analysis, LGPD/GDPR |

## Documentation templates

`docs/templates/` contains the canonical templates copied to every project on `new` or `adopt`. Each section has an `INDEX.md` (registry) and `_template.md` (scaffold). Sections: `adr/`, `api/`, `architecture/`, `database/`, `design/`, `operations/`, `security/`, `testing/`, `decisions/`, `context/`.

Note: `context/` (`active.md` + `progress.md`) is created at project init time but doesn't exist in the templates — `factory-init.sh` creates the directory and files.

Key rules:
- No document created without using the section's `_template.md`
- All documents require YAML frontmatter (`type`, `status`, `owner`, `updated`)
- ADRs are never edited after acceptance — replaced by a new one
- `database/changelog.md` is append-only
- Active vulnerabilities are NOT stored in the repo

## Conventions

- **Language**: Code and docs in English. User interaction in Brazilian Portuguese.
- **Commits**: Conventional Commits format. Short, imperative messages.
- **Frontmatter status lifecycle**: `rascunho` → `em-revisão` → `ativo` → `depreciado` | `substituído-por: [file]`
- **Naming**: `kebab-case` for files. Date prefix `YYYY-MM-DD-` for chronological documents (postmortems, decisions). `NNNN-title.md` for ADRs.