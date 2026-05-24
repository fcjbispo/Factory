---
type: stakeholder-request
status: active
owner: po
updated: 2026-05-18
related:
  - conception/po-playbook.md
  - specifications/domain/credit-approval-context.md
  - specifications/decisions/2026-05-18-credit-approval-scope.md
---

# Solicitação do Stakeholder — Aprovação de Crédito Automatizada

## Solicitação Original (Linguagem Natural)

> *"Olha, nosso processo atual de aprovação de crédito está nos matando. Leva de 2 a 3 dias úteis para um analista humano revisar cada solicitação. Perdemos candidatos para concorrentes que dão respostas instantâneas. Preciso de um sistema que faça isso automaticamente — do início ao fim — em menos de um minuto.
>
> Aqui é o que deve acontecer: a pessoa abre nosso app, preenche sua renda mensal, CPF e quanto de crédito ela quer. O sistema vai imediatamente ao bureau de crédito, puxa o score dela e calcula um limite baseado nas nossas faixas de risco. Se o score dela for muito baixo, rejeição automática — sem precisar de humano. Se ela pedir mais do que a política permite, aprova pelo valor menor. Cada passo precisa ser registrado para auditoria. E se um dos nossos gestores de crédito discordar de uma decisão automatizada, precisam ter uma forma de anular com justificativa por escrito.
>
> Por enquanto, é crédito pessoal apenas — pessoas físicas, não empresas. Uma moeda: USD. Não quero complicar a primeira versão. Mas quero robusto o suficiente para que 90% das solicitações nunca toquem uma mesa humana.
>
> O board já aprovou os multiplicadores de risco: clientes de baixo risco conseguem até 30 vezes a renda mensal, médio 20x, alto 10x. Quem está abaixo de 500 está fora. Teto de tudo em $500.000. Podemos revisitar crédito corporativo e multi-moeda depois.
>
> Consegue construir isso?"*

---

## Principais Dores Identificadas

| # | Dor | Impacto |
|---|---|---|
| 1 | Revisão manual leva 2-3 dias úteis | Perda de candidatos para concorrentes mais rápidos |
| 2 | Sem rejeição automatizada para scores baixos | Analistas perdem tempo com rejeições óbvias |
| 3 | Sem trilha de auditoria para decisões | Risco regulatório, resolução de disputas é manual |
| 4 | Sem mecanismo de aprovação parcial | Candidatos com bom perfil são totalmente rejeitados ao pedir demais |
| 5 | Sem mecanismo de anulação para gestores | Casos de exceção exigem gambiarras fora do sistema |

---

## Critérios de Sucesso (declarados pelo stakeholder)

- Tempo médio de avaliação: **< 60 segundos**
- Taxa de automação total: **>= 90%** das solicitações
- Escopo: **crédito pessoal apenas**, **USD apenas**
- Faixas de risco aprovadas pelo board:
  - BAIXO (score >= 750): 30x renda, máx $500K
  - MÉDIO (600-749): 20x renda, máx $300K
  - ALTO (500-599): 10x renda, máx $100K
  - INELEGÍVEL (< 500): rejeição automática

---

## O que o Stakeholder NÃO Disse (notas do PO)

- Sem menção de **sistema de notificações** — assume-se necessário mas fora do escopo do core v1
- Sem menção de **verificação de identidade / KYC** — assume-se delegado a provedor de identidade existente
- Sem menção de **interface frontend** — este é um microserviço backend; frontend é responsabilidade de outro time
- Sem menção de **processo de apelação** — adiado para v2
- Sem menção de **verificação de renda em tempo real** — confiamos na renda declarada no v1; integração com API bancária adiada

---

## Próximo Passo

Esta solicitação é **entrada bruta** para o PO. O PO deve agora transformá-la em linguagem de domínio estruturada usando o playbook em `po-playbook.md` e os templates do Factory.
