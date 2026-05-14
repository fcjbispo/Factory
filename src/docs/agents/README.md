# Multi-Agent Team — Installation

## Structure

```
.claude/
└── agents/
    ├── senior-architect.md
    ├── fullstack-developer.md
    ├── db-architect.md
    ├── code-reviewer.md
    ├── qa-tester.md
    ├── devops-sre.md
    └── security-analyst.md
```

## Installation in the project

```bash
mkdir -p .claude/agents
cp agents/*.md .claude/agents/
```

## Global installation (available in all projects)

```bash
mkdir -p ~/.claude/agents
cp agents/*.md ~/.claude/agents/
```

## How to invoke

```bash
# Within a Claude Code session:
@senior-architect review the proposed module structure
@fullstack-developer implement the POST /users endpoint according to the contract in docs/api/users.yaml
@db-architect create the migration for the Order entity
@code-reviewer review the PR with changes in src/services/
@qa-tester create integration tests for the authentication module
@devops-sre configure CI pipeline for the new service
@security-analyst do the threat model of the payment flow
```

## Recommended flow by phase

| Phase | Involved agents |
|---|---|
| Project start | Senior Architect → DB Architect → DevOps → Security |
| New feature | Senior Architect → DB Architect → Full-Stack → QA → Security → Code Reviewer |
| Bug fix | Full-Stack → QA → Code Reviewer |
| Release | QA → Code Reviewer → DevOps → Security |
| Incident | DevOps → Security → Senior Architect |

## Models used

| Agent | Model | Reason |
|---|---|---|
| Senior Architect | Opus | Complex architectural reasoning |
| Full-Stack Developer | Sonnet | Cost/capacity balance for code production |
| DB Architect | Sonnet | Cost/capacity balance |
| Code Reviewer | Opus | Deep analysis and subtlety detection |
| QA Tester | Sonnet | Cost/capacity balance |
| DevOps/SRE | Sonnet | Cost/capacity balance |
| Security Analyst | Opus | Risk analysis and subtle vulnerability detection |
