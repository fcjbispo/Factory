---
type: research
scope: backlog.v1.3.0
updated: 2026-04-28
---

# Pesquisa v1.3.0 — Gestão de Backlog

## Fontes

- Hel (DevOps/SRE) — glm-5.1:cloud
- Balder (DB Architect) — deepseek-v4-flash:cloud (timeout)
- Web search — SearXNG

## Aprendizados de Hel

### Severidade por Categoria

| Categoria | Crítico | Alto | Médio | Baixo |
|---|---|---|---|---|
| Bugs | Produção fora | Degradado | Workaround | Cosmético |
| Segurança | CVSS ≥ 9 | CVSS 7-8.9 | CVSS 4-6.9 | CVSS < 4 |
| Performance | SLO quebrado | Latência alta | Degradação leve | Otimização |
| Tech Debt | Bloqueante | Dificulta features | Refactoring | Modernização |

### Template de Triage

Campos obrigatórios:
- Severidade técnica
- Impacto de negócio
- Esforço estimado
- Risco de não fazer
- Dependências

## Aprendizados de Web Search

### Melhores Práticas 2026

1. **Shift-left security** — incluir segurança desde o início
2. **Dependency scanning** — automação de verificação
3. **SBOM** — Software Bill of Materials obrigatório
4. **Blameless postmortems** — foco em sistemas
5. **Sustainable development** — alocar tempo para débito técnico

### Gestão de Débito Técnico

- Visibilidade: tornar débito visível
- Priorização estratégica
- Alocação consistente (20% do tempo)
- Métricas: lead time, cycle time

## Gaps Identificados

- Necessidade de integração com GitHub Issues (futuro)
- Automação de triage (futuro)
- Dashboard de métricas (futuro)

## Decisões

- Priorização: MoSCoW + RICE
- Estados: aberto → em-analise → priorizado → em-progresso → resolvido
- Template único para todas as categorias
- Review trimestral de tech debt
