---
type: po-playbook
status: active
owner: po
updated: 2026-05-18
related:
  - conception/stakeholder-request.md
  - specifications/domain/credit-approval-context.md
  - specifications/domain/credit-approval-language.md
  - specifications/domain/context-map.md
---

# Playbook do PO — Ato 1: Concepção

> **Objetivo**: Transformar a solicitação em linguagem natural do stakeholder em um DDD Canvas estruturado que todos os agentes downstream possam consumir.
> **Entrada**: `stakeholder-request.md`
> **Saída**: `domain/credit-approval-context.md`, `domain/credit-approval-language.md`, `domain/context-map.md`, `decisions/YYYY-MM-DD-credit-approval-scope.md`

---

## Passo 1 — Ler a Solicitação do Stakeholder

Abrir `stakeholder-request.md`. Identificar:
- **Dores** (por que esse sistema existe)
- **Atores** (quem interage com o sistema)
- **Regras de negócio** (que decisões o sistema deve tomar)
- **Restrições** (o que está explicitamente dentro ou fora do escopo)

Não pule este passo. As palavras exatas do stakeholder são a fonte da verdade para a linguagem de domínio.

---

## Passo 2 — Abrir os Templates do Factory

Carregar os seguintes templates no contexto antes de acionar o agente `@senior-architect`:

1. `src/docs/templates/domain/_template-bounded-context.md` — para o documento de contexto
2. `src/docs/templates/domain/_template-ubiquitous-language.md` — para o glossário
3. `src/docs/templates/domain/context-map.md` — para o mapa de contexto
4. `src/docs/templates/decisions/_template.md` — para a decisão de produto

Estes templates impõem o frontmatter, estrutura e convenções obrigatórios.

---

## Passo 3 — Acionar o Agent @senior-architect

Alimentar o agente nesta ordem:

1. **A solicitação do stakeholder** (verbatim ou resumida)
2. **Os templates** (para que o agente conheça o formato de saída)
3. **Esta instrução**: *"Extraia o bounded context, ubiquitous language e context map desta solicitação. Siga os templates exatamente. Todos os termos devem estar em inglês. Todos os documentos precisam de YAML frontmatter com type, status, owner, updated."*

O agente produzirá um primeiro rascunho de:
- `domain/credit-approval-context.md`
- `domain/credit-approval-language.md`
- `domain/context-map.md`

---

## Passo 4 — PO Valida a Linguagem de Domínio

Antes de aceitar a saída do agente, o PO deve verificar:

| Verificação | Pergunta |
|---|---|
| Precisão dos termos | Os termos correspondem ao que o stakeholder realmente disse? |
| Termos proibidos | Há palavras genéricas como `customer`, `user`, `data`, `status` que deveriam ser específicas do domínio? |
| Limites do escopo | Há uma lista clara do que **não** pertence a este contexto? |
| Invariantes | As regras de negócio estão declaradas como invariantes que nunca podem ser violadas? |

Se algum termo parecer errado, corrija. Não deixe a conveniência técnica sobrepor a linguagem de negócio.

---

## Passo 5 — Definir a Decisão de Produto

Usando `src/docs/templates/decisions/_template.md`, o PO escreve o documento de escopo (`decisions/YYYY-MM-DD-credit-approval-scope.md`).

Este documento deve incluir:
- **O que foi decidido** (escopo v1, regras de negócio, números)
- **Por que** (motivação do stakeholder)
- **Trade-offs aceitos** (o que estamos abrindo mão por velocidade)
- **Critérios de revisão** (quando revisitar esta decisão)

Este é o **contrato** entre negócio e engenharia. O arquiteto e os desenvolvedores construirão com base neste documento.

---

## Passo 6 — Revisar e Congelar

Antes de avançar para o Ato 2 (Arquitetura), o PO deve:

1. Confirmar que todos os quatro documentos estão completos e consistentes
2. Garantir que `context-map.md` identifica corretamente os sistemas externos e seu tipo de integração
3. Garantir que `credit-approval-language.md` tem uma seção "Termos Proibidos"
4. Adicionar os documentos ao `INDEX.md` do projeto sob as seções `domain/` e `decisions/`

**Não prossiga para o Ato 2 se a linguagem de domínio estiver instável.** Mudar um termo depois que o arquiteto desenhou a API é caro.

---

## Mapa de Agentes do Ato 1

| Papel | Agente | Entrada | Saída |
|---|---|---|---|
| PO | Humano | Solicitação do stakeholder | Requisitos validados |
| Modelador de Domínio | `@senior-architect` | Solicitação do stakeholder + templates | DDD Canvas (contexto, linguagem, mapa) |
| Decisão de Produto | Humano (PO) | Domain Canvas + restrições do stakeholder | Documento de escopo |

---

## Checklist de Saída

Antes de fechar o Ato 1, verifique que estes arquivos existem e estão linkados no `INDEX.md`:

- [ ] `domain/credit-approval-context.md` — Bounded context com agregados, entidades, VO, eventos
- [ ] `domain/credit-approval-language.md` — Glossário de linguagem ubíqua com termos proibidos
- [ ] `domain/context-map.md` — Mapa de contexto com sistemas externos e ACLs
- [ ] `decisions/YYYY-MM-DD-credit-approval-scope.md` — Escopo de produto e regras de negócio

---

## Erros Comuns a Evitar

- **Pular o glossário**: Se o PO não define "Applicant" vs "customer", os desenvolvedores usarão ambos no código.
- **Misturar termos técnicos e de negócio**: O documento de domínio não deve mencionar "REST", "JWT" ou "PostgreSQL". Isso pertence à arquitetura.
- **Sem exclusões de escopo explícitas**: Dizer "crédito pessoal apenas" não é suficiente. Liste o que está explicitamente fora: crédito corporativo, multi-moeda, apelações, faturamento.
- **Sem invariantes**: "O score deve estar entre 300 e 850" é uma invariante. "Geralmente rejeitamos scores baixos" não é.

---

## Histórico de Alterações

| Data | Alteração | Por |
|---|---|---|
| 2026-05-18 | Playbook inicial para Ato 1 — Concepção | po |
