---
type: decision
status: active
owner: po
readers: [senior-architect, fullstack-developer]
updated: 2026-05-18
related:
  - design/credit-approval-design.md
  - architecture/overview.md
---

# Decisão de Produto: Escopo e Regras de Negócio para Aprovação de Crédito v1

## Contexto

A empresa precisa automatizar a avaliação de crédito para reduzir o processo manual atual de 2-3 dias para menos de 60 segundos. O time de produto deve definir o escopo exato, regras de negócio e critérios de sucesso para o primeiro release.

## Decisão

1. **Escopo v1**: Crédito pessoal apenas (indivíduos, não empresas)
2. **Moeda**: USD apenas no lançamento; multi-moeda adiado para v2
3. **Cálculo de limite de crédito**: Baseado apenas na renda declarada e na faixa de score
   - Baixo risco (score >= 750): 30x renda mensal, máx $500.000
   - Médio risco (600-749): 20x renda mensal, máx $300.000
   - Alto risco (500-599): 10x renda mensal, máx $100.000
   - INELEGÍVEL (< 500): rejeição automática
4. **Aprovação parcial**: Quando o limite calculado é menor que o valor solicitado, aprova o valor menor com status `PARTIALLY_APPROVED`
5. **Lista negra**: Lista hard-coded de números de documento bloqueados para v1; integração com serviço externo de lista negra adiada para v2
6. **Anulação manual**: Admins de crédito podem anular qualquer aplicação decidida com justificativa; sem teto de valor para anulações no v1
7. **Auditoria**: Todas as ações registradas; trilha de auditoria retida por 7 anos (requerimento regulatório)

## Motivação

- Crédito pessoal representa 80% do volume atual e tem regras mais simples que corporativo
- USD-only reduz complexidade nas integrações com bureau e nos cálculos de limite
- Os multiplicadores de faixa de risco são baseados na política manual atual e têm aprovação do board
- Aprovação parcial reduz fricção do aplicante quando pedem mais que a política permite
- Anulação manual é requerimento regulatório — o sistema deve permitir intervenção humana

## Impacto Esperado

- Tempo médio de avaliação cai de 48-72 horas para < 60 segundos
- 90%+ das aplicações são totalmente automatizadas (sem revisão manual)
- Compliance de auditoria é garantido por design
- Taxa de anulação por admin deve ser < 5% das decisões

## Trade-offs Aceitos

- **Sem verificação de renda em tempo real**: Confiamos na renda declarada. Verificação via APIs bancárias está planejada para v2.
- **Lista negra hard-coded**: Manutenção manual até v2. Risco é baixo para demo/lançamento.
- **Sem processo de apelação**: Aplicantes não podem contestar decisões no v1. Apelações adiadas para v2.
- **Moeda única**: Aplicantes internacionais devem se candidatar em USD.

## Critérios de Revisão

Revisite esta decisão se:
- Taxa de anulação exceder 10% (indica que as regras são muito rígidas)
- Taxa de rejeição exceder 40% (indica que o threshold de pontuação pode estar muito alto)
- Requerimentos regulatórios mudarem (ex: novas regras de retenção de auditoria)
- O negócio expandir para crédito corporativo ou novas moedas

## Histórico de Alterações

| Data | Alteração | Por |
|---|---|---|
| 2026-05-18 | Decisão de escopo inicial | po |
