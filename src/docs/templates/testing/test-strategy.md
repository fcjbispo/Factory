---
type: test-strategy
status: ativo
owner: qa-tester
readers: [all]
updated: YYYY-MM-DD
related:
  - architecture/overview.md
---

# Estratégia de Testes

## Pirâmide de testes

```
        /\
       /E2E\          poucos — fluxos críticos end-to-end
      /------\
     /Integração\     moderados — colaboração entre módulos
    /------------\
   /   Unitários  \   maioria — lógica de negócio isolada
  /--------------/
```

## Ferramentas

| Tipo | Ferramenta | Configuração |
|---|---|---|
| Unitário | [ex: Jest, Vitest, pytest] | [arquivo de config] |
| Integração | [ex: Supertest, pytest] | [arquivo de config] |
| E2E | [ex: Playwright, Cypress] | [arquivo de config] |
| Cobertura | [ex: Istanbul, coverage.py] | [arquivo de config] |

## Thresholds de cobertura

| Métrica | Threshold mínimo | Threshold desejado |
|---|---|---|
| Linhas | 80% | 90% |
| Branches | 75% | 85% |
| Funções | 80% | 90% |

> Builds abaixo do threshold mínimo são bloqueados no CI.

## O que testar em cada nível

### Unitários
- Toda lógica de negócio em services e use-cases
- Funções de transformação, validação e cálculo
- Edge cases e tratamento de erros

### Integração
- Endpoints de API (request → response, incluindo erros)
- Acesso ao banco de dados (queries, migrations)
- Integração com serviços externos (via mocks/contratos)

### E2E
- Fluxos críticos do ponto de vista do usuário
- Máximo de [N] cenários — priorize fluxos de maior valor de negócio

## Dados de teste

- Fixtures: [localização]
- Seeds: [localização ou comando]
- PII em testes: nunca use dados reais. Use geradores de dados sintéticos.

## Flaky tests

Todo teste instável deve ser registrado e corrigido em até [N dias]. Teste flaky é bug.

## Critérios de qualidade para release

- [ ] Suite completa passa sem falhas
- [ ] Cobertura acima dos thresholds mínimos
- [ ] Nenhum teste flaky ativo
- [ ] Testes de regressão para todos os bugs corrigidos na release

## Histórico de mudanças

| Data | Mudança | Por |
|---|---|---|
| YYYY-MM-DD | Versão inicial | qa-tester |
