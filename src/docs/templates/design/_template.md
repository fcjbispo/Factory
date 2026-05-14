---
type: design
status: rascunho
owner: arquiteto-senior
readers: [fullstack-developer, db-architect, qa-tester, security-analyst]
updated: YYYY-MM-DD
related: []
---

# [Nome da Feature]

## Contexto e problema

> Por que esta feature existe? Qual problema de negócio ou técnico ela resolve?

## Solução proposta

> Descreva a solução em linguagem clara. Inclua o fluxo principal e os fluxos alternativos relevantes.

## Componentes afetados

| Componente | Tipo de impacto | Agente responsável |
|---|---|---|
| [nome] | novo / modificado / removido | [agente] |

## Contrato de API

> Referencie ou descreva os endpoints/eventos envolvidos. Se o contrato ainda não existe em `api/`, ele deve ser criado antes da implementação.

```
# Referência: api/[nome-do-contrato].yaml
```

## Modelo de dados

> Descreva as entidades novas ou modificadas. Se houver migration, o DB Architect deve criar o schema em `database/` antes da implementação.

## Critérios de aceitação

- [ ] Dado [contexto], quando [ação], então [resultado esperado]
- [ ] Dado [contexto], quando [ação inválida], então [comportamento de erro esperado]

## Abordagem de testes

| Tipo | O que testar | Responsável |
|---|---|---|
| Unitário | [lógica específica] | fullstack-developer |
| Integração | [fluxo específico] | qa-tester |
| E2E | [caminho crítico] | qa-tester |

## Considerações de segurança

> Quais dados sensíveis estão envolvidos? Há requisitos de autenticação/autorização específicos? Referencie o threat model se existir.

## Considerações de performance

> Existem expectativas de volume ou latência? Há riscos de N+1 queries ou gargalos conhecidos?

## Alternativas descartadas

> Documente brevemente o que foi considerado e por que foi descartado.

## Histórico de mudanças

| Data | Mudança | Por |
|---|---|---|
| YYYY-MM-DD | Versão inicial | arquiteto-senior |
