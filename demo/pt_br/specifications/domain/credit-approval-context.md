---
type: bounded-context
status: active
owner: senior-architect
updated: 2026-05-18
related:
  - domain/INDEX.md
  - domain/context-map.md
  - domain/credit-approval-language.md
  - api/credit-approval-api.yaml
---

# Contexto: Credit Approval

> **Responsabilidade central**: Avaliar aplicações de crédito e emitir decisões de crédito baseadas em políticas de risco, verificação de renda e dados de bureau externo.

---

## Visão Geral

O contexto Credit Approval é o núcleo do microserviço. Ele recebe aplicações de crédito de aplicantes, as enriquece com scores externos, aplica regras de negócio e bandas de risco, e produz uma decisão de crédito imutável. Todas as ações são registradas em uma trilha de auditoria para compliance.

**O que pertence a este contexto**:
- Submissão e validação de aplicações de crédito
- Integração com bureaus de crédito externos para pontuação
- Aplicação de bandas de risco e cálculo de limites de crédito
- Emissão de decisões de crédito (aprovada, rejeitada, parcialmente aprovada)
- Registro de trilha de auditoria para todas as decisões

**O que NÃO pertence a este contexto**:
- Envio de notificações aos aplicantes (contexto Notifications)
- Verificação de identidade / KYC (sistema externo IdentityProvider)
- Rastreamento de uso de limite de crédito ou faturamento (fora do escopo)
- Interface UI de revisão manual ou gestão de workflow (fora do escopo)

---

## Agregados

### CreditApplication *(raiz de agregado)*

**Responsabilidade**: Representa o ciclo de vida completo de uma solicitação de crédito. É o único ponto de entrada para criar, avaliar e decidir uma aplicação de crédito.

**Invariantes**:
- Uma CreditApplication deve ter exatamente um Applicant
- Uma CreditApplication não pode ser modificada após uma CreditDecision ser emitida
- A renda declarada deve ser > 0
- O valor solicitado deve ser >= $100,00

**Campos**:
| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| id | UUID | sim | Identificador único (formato: APP-YYYY-NNNN) |
| applicant_id | UUID | sim | Referência ao Applicant |
| declared_income | Decimal | sim | Renda mensal declarada pelo aplicante |
| requested_amount | Decimal | sim | Valor de crédito solicitado |
| currency | String(3) | sim | Código de moeda ISO 4217 (padrão: USD) |
| credit_score | Integer | não | Score do bureau externo (nulo até a pontuação) |
| risk_band | Enum | não | Faixa calculada (nula até a pontuação) |
| status | Enum | sim | Estado atual da aplicação |
| submitted_at | DateTime | sim | Quando a aplicação foi recebida |
| decided_at | DateTime | não | Quando a decisão foi emitida |

**Estados possíveis**:
```
SUBMITTED → SCORING → DECIDED
              ↓
          REJECTED
```

**Transições e comandos**:
| Comando | Pré-condição | Resultado |
|---|---|---|
| `SubmitCreditApplication` | Applicant existe, renda > 0, valor >= 100 | Status: SUBMITTED, evento: CreditApplicationSubmitted |
| `EvaluateCreditApplication` | Status: SUBMITTED, credit_score recebido | Status: SCORING → DECIDED/REJECTED, evento: CreditDecisionIssued |
| `OverrideCreditDecision` | Status: DECIDED, usuário tem papel ADMIN | Status: DECIDED (atualizado), evento: CreditLimitUpdated |

---

## Entidades

### Applicant

**Responsabilidade**: Representa o indivíduo ou entidade solicitando crédito. Mantém identidade entre múltiplas aplicações.

**Campos**:
| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| id | UUID | sim | Identificador único |
| full_name | String(255) | sim | Nome legal |
| document_number | String(50) | sim | Documento de identidade (CPF/SSN equivalente) |
| email | String(255) | sim | Email de contato |
| date_of_birth | Date | sim | Para políticas baseadas em idade |
| created_at | DateTime | sim | Timestamp de registro |

### CreditDecision

**Responsabilidade**: O resultado imutável da avaliação de uma CreditApplication.

**Campos**:
| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| id | UUID | sim | Identificador único |
| application_id | UUID | sim | Referência à CreditApplication |
| decision | Enum | sim | APPROVED, REJECTED, PARTIALLY_APPROVED |
| approved_amount | Decimal | não | Limite final aprovado (nulo se REJECTED) |
| reason | String(500) | sim | Explicação legível por humanos |
| decided_at | DateTime | sim | Timestamp da decisão |
| decided_by | String | sim | `SYSTEM` ou ID do usuário admin |

---

## Value Objects

### CreditScore

**Responsabilidade**: Score imutável retornado pelo bureau externo.
**Imutável**: sim

**Campos**:
| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| score | Integer | sim | 300-850 |
| source | String | sim | Identificador do bureau (ex: "EXPERIAN_V3") |
| retrieved_at | DateTime | sim | Quando o score foi obtido |

**Regras de validação**:
- Score deve estar entre 300 e 850
- Scores são cacheados por 24 horas por applicant

### CreditLimit

**Responsabilidade**: O valor máximo de crédito calculado a partir da renda e faixa de risco.
**Imutável**: sim

**Campos**:
| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| amount | Decimal | sim | Limite calculado |
| currency | String(3) | sim | Código ISO 4217 |
| multiplier | Decimal | sim | Multiplicador aplicado (ex: 20x) |

**Regras de validação**:
- amount = declared_income * multiplier
- O multiplicador é determinado pela RiskBand:
  - LOW: 30x
  - MEDIUM: 20x
  - HIGH: 10x
  - INELIGIBLE: 0 (rejeição automática)
- Teto máximo: $500.000,00

### RiskBand

**Responsabilidade**: Classificação derivada do CreditScore.
**Imutável**: sim

**Campos**:
| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| band | Enum | sim | LOW, MEDIUM, HIGH, INELIGIBLE |
| min_score | Integer | sim | Limite inferior desta faixa |
| max_score | Integer | sim | Limite superior desta faixa |

---

## Eventos de Domínio

| Evento | Publicado Quando | Payload Obrigatório | Consumido Por |
|---|---|---|---|
| `CreditApplicationSubmitted` | Aplicação passa na validação | application_id, applicant_id, submitted_at | Notifications |
| `CreditScoreReceived` | Bureau retorna score | application_id, score, source | Interno (dispara avaliação) |
| `CreditDecisionIssued` | Decisão é registrada | application_id, decision, approved_amount | Notifications, Audit |
| `CreditLimitUpdated` | Anulação manual aplicada | application_id, new_amount, overridden_by | Notifications, Audit |

### Detalhes por Evento

#### CreditDecisionIssued

**Quando é publicado**: Após a lógica de avaliação completar e a CreditDecision ser persistida.

**Payload**:
| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| event_id | UUID | sim | Identificador único do evento |
| occurred_at | DateTime | sim | Timestamp |
| application_id | UUID | sim | Referência |
| decision | Enum | sim | APPROVED, REJECTED, PARTIALLY_APPROVED |
| approved_amount | Decimal | não | Nulo se REJECTED |
| reason | String | sim | Explicação |

**Invariantes do payload**:
- Se a decisão for REJECTED, approved_amount deve ser nulo
- Se a decisão for APPROVED ou PARTIALLY_APPROVED, approved_amount deve ser > 0

---

## Serviços de Domínio

### CreditEvaluationService

**Responsabilidade**: Calcula o limite de crédito e determina a decisão final baseada na faixa de risco, renda e políticas.
**Entradas**: CreditApplication (com score), regras de RiskBand, limites de política
**Saída**: CreditDecision (aprovada/rejeitada/parcial com valor e razão)

---

## Repositórios

| Repositório | Operações |
|---|---|
| `CreditApplicationRepository` | `findById`, `save`, `findByApplicantId`, `findByStatus` |
| `ApplicantRepository` | `findById`, `save`, `findByDocumentNumber` |
| `CreditDecisionRepository` | `findById`, `save`, `findByApplicationId` |
| `AuditTrailRepository` | `findByApplicationId`, `save` |

---

## Mapeamento para Spec (SDD)

| Conceito DDD | Elemento da Spec | Arquivo |
|---|---|---|
| CreditApplication (raiz de agregado) | `type CreditApplication` + mutations | `api/credit-approval-api.yaml` |
| Applicant | `type Applicant { id: ID! }` | `api/credit-approval-api.yaml` |
| CreditDecision | `type CreditDecision` | `api/credit-approval-api.yaml` |
| CreditScore | `input CreditScoreInput` | `api/credit-approval-api.yaml` |
| RiskBand | `enum RiskBand` | `api/credit-approval-api.yaml` |
| CreditApplicationSubmitted | Canal / subscription AsyncAPI | `api/events/credit-application-event.yaml` |
| CreditDecisionIssued | Canal / subscription AsyncAPI | `api/events/credit-decision-event.yaml` |

---

## Anti-Corruption Layer

| Conceito Externo (Contexto de Origem) | Tradução Neste Contexto | Motivo |
|---|---|---|
| `risk_score` de ExternalCreditBureau | `credit_score` | Domínio interno usa linguagem de negócio |
| `sub` de IdentityProvider | `applicant_id` | JWT subject mapeia para nossa entidade Applicant |

---

## Histórico de Alterações

| Data | Alteração | Por |
|---|---|---|
| 2026-05-18 | Documento criado via Event Storming | senior-architect |
