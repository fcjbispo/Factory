---
type: design
status: draft
owner: senior-architect
readers: [fullstack-developer, db-architect, qa-tester, security-analyst]
updated: 2026-05-18
related:
  - domain/credit-approval-context.md
  - api/credit-approval-api.yaml
  - architecture/overview.md
---

# Aprovação de Crédito — Design da Feature

## Contexto e Problema

O negócio precisa de um sistema automatizado para avaliar aplicações de crédito de indivíduos. Atualmente o processo é manual, propenso a erros e leva 2-3 dias úteis. O objetivo é reduzir o tempo de avaliação para menos de 60 segundos mantendo compliance regulatório e auditabilidade.

**Regras de negócio a automatizar**:
- Análise de score de crédito (faixas com decisões diferentes)
- Limite de crédito calculado com base na renda declarada
- Política de rejeição automática (lista negra, renda insuficiente)
- Aprovação parcial com valor ajustado
- Trilha de auditoria para todas as decisões (log imutável)

---

## Solução Proposta

Um microserviço RESTful que recebe aplicações de crédito, as enriquece com dados de bureau externo, aplica regras de negócio e emite uma decisão de crédito imutável. Todas as ações são registradas em trilha de auditoria.

**Fluxo principal**:
1. Aplicante submete aplicação via `POST /applications`
2. Sistema valida entrada e cria `CreditApplication` (status: `SUBMITTED`)
3. Sistema busca `CreditScore` do bureau externo (assíncrono, cacheado)
4. Sistema calcula `RiskBand` e `CreditLimit`
5. Sistema emite `CreditDecision` (status: `DECIDED` ou `REJECTED`)
6. Sistema publica evento `CreditDecisionIssued`
7. Trilha de auditoria registra todos os passos

**Fluxo alternativo — Bureau indisponível**:
- Se o bureau retornar 5xx ou timeout após 3 retries, a aplicação permanece em `SUBMITTED`
- Job em background retenta a cada 5 minutos por até 1 hora
- Se ainda falhar, flag de revisão manual é levantada

**Fluxo alternativo — Anulação manual**:
- Admin com papel `CREDIT_ADMIN` pode anular uma aplicação `DECIDED`
- Anulação requer justificativa (mínimo 20 caracteres)
- Nova `CreditDecision` é criada, a antiga é marcada `SUPERSEDED`
- Evento `CreditLimitUpdated` é publicado

---

## Componentes Afetados

| Componente | Tipo de Impacto | Agente Responsável |
|---|---|---|
| `credit-application-api` | novo | fullstack-developer |
| `credit-evaluation-service` | novo | fullstack-developer |
| `credit-decision-repository` | novo | db-architect |
| `external-bureau-adapter` | novo | fullstack-developer |
| `audit-trail-service` | novo | fullstack-developer |
| `notifications-publisher` | novo | fullstack-developer |
| `postgresql` | modificado | db-architect |
| `redis` | novo | devops-sre |

---

## Contrato de API

Referência: `api/credit-approval-api.yaml`

Endpoints principais:
- `POST /v1/applications` — Submeter nova aplicação de crédito
- `GET /v1/applications/{id}` — Recuperar aplicação com decisão atual
- `POST /v1/applications/{id}/evaluate` — Disparar avaliação (interno/async)
- `POST /v1/applications/{id}/override` — Anulação manual (apenas admin)
- `GET /v1/applications/{id}/audit` — Recuperar trilha de auditoria

---

## Modelo de Dados

### Novas Entidades

**credit_applications**:
- `id` (UUID, PK)
- `applicant_id` (UUID, FK → applicants)
- `declared_income` (DECIMAL, 15,2)
- `requested_amount` (DECIMAL, 15,2)
- `currency` (VARCHAR(3), padrão 'USD')
- `credit_score` (INTEGER, nullable)
- `risk_band` (VARCHAR(20), nullable)
- `status` (VARCHAR(20), padrão 'SUBMITTED')
- `submitted_at` (TIMESTAMP)
- `decided_at` (TIMESTAMP, nullable)

**credit_decisions**:
- `id` (UUID, PK)
- `application_id` (UUID, FK → credit_applications, unique)
- `decision` (VARCHAR(20))
- `approved_amount` (DECIMAL, 15,2, nullable)
- `reason` (VARCHAR(500))
- `decided_at` (TIMESTAMP)
- `decided_by` (VARCHAR(100))

**audit_trail**:
- `id` (UUID, PK)
- `application_id` (UUID, FK)
- `action` (VARCHAR(50))
- `actor` (VARCHAR(100))
- `payload` (JSONB)
- `occurred_at` (TIMESTAMP)

---

## Critérios de Aceitação

- [ ] Dada uma aplicação válida com renda $5.000 e score 720, quando avaliada, então decisão é APPROVED com limite $150.000 (30x)
- [ ] Dada uma aplicação válida com renda $5.000 e score 550, quando avaliada, então decisão é APPROVED com limite $50.000 (10x)
- [ ] Dada uma aplicação válida com score 480, quando avaliada, então decisão é REJECTED com razão "Credit score below minimum threshold"
- [ ] Dada uma aplicação com renda $0, quando submetida, então validação falha com erro "declared_income must be greater than 0"
- [ ] Dada uma aplicação decidida, quando um admin anula com razão, então uma nova decisão é criada e evento é publicado
- [ ] Dada qualquer transição de aplicação, quando ocorre, então uma entrada de trilha de auditoria é criada em até 100ms
- [ ] Dado um timeout do bureau, quando avaliando, então aplicação permanece em SUBMITTED e retry é agendado

---

## Abordagem de Testes

| Tipo | O que Testar | Responsável |
|---|---|---|
| Unitário | Cálculo de limite de crédito para cada faixa de risco | fullstack-developer |
| Unitário | Regras de rejeição automática (score, renda, lista negra) | fullstack-developer |
| Unitário | Registro de trilha de auditoria | fullstack-developer |
| Integração | Fluxo end-to-end: submeter → avaliar → decidir | qa-tester |
| Integração | Resiliência do adaptador de bureau (timeouts, retries) | qa-tester |
| Integração | Validação e respostas de erro da API | qa-tester |
| E2E | Fluxos completos de aprovação e rejeição via API | qa-tester |
| Segurança | Autenticação no endpoint de anulação | security-analyst |
| Performance | Avaliação completa em < 60 segundos sob carga | qa-tester |

---

## Considerações de Segurança

- **PII**: document_number e email do aplicante são criptografados em repouso (AES-256)
- **Autenticação**: Todos os endpoints requerem JWT (exceto health checks)
- **Autorização**: Endpoint de anulação requer papel `CREDIT_ADMIN`
- **Auditoria**: Todo acesso à trilha de auditoria é ele mesmo auditado
- **Chamadas externas**: Chave de API do bureau armazenada em variável de ambiente, nunca logada
- **Rate limiting**: 10 aplicações por minuto por applicant_id

---

## Considerações de Performance

- Alvo: percentil 95 do tempo de avaliação < 60 segundos
- Cache de score do bureau: 24 horas por aplicante para reduzir chamadas externas
- Banco de dados: índice em `credit_applications.status` e `credit_applications.applicant_id`
- Avaliação em background via fila de mensagens para evitar bloquear requisições HTTP
- Volume esperado: 1.000 aplicações/dia no lançamento

---

## Alternativas Descartadas

- **Avaliação síncrona**: Rejeitada porque a latência do bureau (2-5s) bloquearia requisições HTTP. Avaliação assíncrona em background foi escolhida.
- **API GraphQL**: Rejeitada porque a superfície da API é pequena (4 endpoints) e REST é mais simples para o time frontend.
- **Event sourcing para decisões**: Rejeitada como overkill para v1. Tabela de auditoria simples é suficiente; event sourcing pode ser reconsiderado se os requisitos de auditoria crescerem.

---

## Histórico de Alterações

| Data | Alteração | Por |
|---|---|---|
| 2026-05-18 | Versão inicial | senior-architect |
