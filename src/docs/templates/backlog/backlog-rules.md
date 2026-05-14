---
type: rules
scope: backlog
updated: 2026-04-28
---

# Regras do Backlog

## Priorização

### MoSCoW + RICE

| Prioridade | MoSCoW | RICE Score | Quem decide |
|---|---|---|---|
| P1 (crítico) | Must have | >100 | PO + Arquiteto |
| P2 (alto) | Should have | 50-100 | PO |
| P3 (médio) | Could have | 20-50 | PO |
| P4 (baixo) | Won't have | <20 | PO |

### Fatores RICE

- **Reach**: quantos usuários/sistemas afetados?
- **Impact**: qual impacto no negócio? (0.25=marginal, 0.5=baixo, 1=médio, 2=alto, 3=massivo)
- **Confidence**: qual certeza dos dados? (%)
- **Effort**: quantas pessoas-mês?

## Fluxo de Estados

```
aberto → em-analise → priorizado → em-progresso → resolvido
                                    ↓
                              suspenso → rejeitado
```

## Transições

| De | Para | Quem pode | Condição |
|---|---|---|---|
| aberto | em-analise | Qualquer agente | Item reportado |
| em-analise | priorizado | PO + Arquiteto | Impacto avaliado |
| em-analise | rejeitado | PO | Não faz sentido |
| priorizado | em-progresso | PO | Capacidade disponível |
| em-progresso | resolvido | Executor | Critérios aceitos |
| em-progresso | suspenso | PO | Bloqueio externo |
| suspenso | em-progresso | PO | Bloqueio resolvido |
| suspenso | rejeitado | PO | Bloqueio permanente |

## Responsabilidades

| Papel | Responsabilidade |
|---|---|
| PO | Triage, priorização, aprovação |
| Arquiteto | Impacto técnico, estimativa, riscos |
| Executor | Implementação, testes, documentação |
| Code Reviewer | Validação técnica |
| QA Tester | Validação funcional |
| DevOps/SRE | Deploy, monitoramento |

## Reuniões

- **Daily**: 15min, foco em bloqueios
- **Review**: semanal, demonstração
- **Retrospective**: mensal, melhoria contínua
- **Planning**: quinzenal, próxima sprint

## Métricas

- Lead time: aberto → resolvido
- Cycle time: em-progresso → resolvido
- Throughput: itens resolvidos/semana
- WIP limit: máximo de itens em progresso por agente
