# Equipe Multi-Agente — Instalação

## Estrutura

```
.claude/
└── agents/
    ├── arquiteto-senior.md
    ├── fullstack-developer.md
    ├── db-architect.md
    ├── code-reviewer.md
    ├── qa-tester.md
    ├── devops-sre.md
    └── security-analyst.md
```

## Instalação no projeto

```bash
mkdir -p .claude/agents
cp agents/*.md .claude/agents/
```

## Instalação global (disponível em todos os projetos)

```bash
mkdir -p ~/.claude/agents
cp agents/*.md ~/.claude/agents/
```

## Como invocar

```bash
# Dentro de uma sessão Claude Code:
@arquiteto-senior revise a estrutura de módulos proposta
@fullstack-developer implemente o endpoint POST /users conforme o contrato em docs/api/users.yaml
@db-architect crie a migration para a entidade Order
@code-reviewer revise o PR com as mudanças em src/services/
@qa-tester crie os testes de integração para o módulo de autenticação
@devops-sre configure o pipeline de CI para o novo serviço
@security-analyst faça o threat model do fluxo de pagamento
```

## Fluxo recomendado por fase

| Fase | Agentes envolvidos |
|---|---|
| Início do projeto | Arquiteto Sênior → DB Architect → DevOps → Security |
| Nova feature | Arquiteto Sênior → DB Architect → Full-Stack → QA → Security → Code Reviewer |
| Bug fix | Full-Stack → QA → Code Reviewer |
| Release | QA → Code Reviewer → DevOps → Security |
| Incidente | DevOps → Security → Arquiteto Sênior |

## Modelos utilizados

| Agente | Modelo | Motivo |
|---|---|---|
| Arquiteto Sênior | Opus | Raciocínio arquitetural complexo |
| Full-Stack Developer | Sonnet | Equilíbrio custo/capacidade para produção de código |
| DB Architect | Sonnet | Equilíbrio custo/capacidade |
| Code Reviewer | Opus | Análise profunda e detecção de sutilezas |
| QA Tester | Sonnet | Equilíbrio custo/capacidade |
| DevOps/SRE | Sonnet | Equilíbrio custo/capacidade |
| Security Analyst | Opus | Análise de risco e detecção de vulnerabilidades sutis |
