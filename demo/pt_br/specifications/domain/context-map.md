---
type: context-map
status: active
owner: senior-architect
updated: 2026-05-18
related:
  - domain/INDEX.md
  - domain/credit-approval-context.md
---

# Mapa de Contexto — Microserviço de Aprovação de Crédito

> Define como os bounded contexts se relacionam e se comunicam.
> Leitura obrigatória antes de criar specs de eventos ou integrações entre contextos.

---

## Diagrama do Mapa

```
[CreditApproval]  —[publisher]→  [Notifications]
[CreditApproval]  —[ACL]→        [ExternalCreditBureau]
[CreditApproval]  —[ACL]→        [IdentityProvider]
```

*Diagrama detalhado em `architecture/diagrams/context-map.mmd` (Mermaid)*

---

## Tipos de Relacionamento

| Tipo | Descrição | Implicação na spec |
|---|---|---|
| `publisher-consumer` | Um contexto publica eventos; outros consomem | Contrato AsyncAPI define o canal |
| `anti-corruption-layer` (ACL) | O consumidor traduz o modelo do publicador para o seu próprio | Spec de tradução explícita; termos podem diferir |

---

## Relacionamentos Detalhados

### CreditApproval → Notifications

**Tipo**: `publisher-consumer`
**Direção**: CreditApproval é o upstream

**Eventos publicados**:

| Evento | Canal | Spec |
|---|---|---|
| `CreditDecisionIssued` | `credit.decisions` | `api/events/credit-decision-event.yaml` |
| `CreditLimitUpdated` | `credit.limits` | `api/events/credit-limit-event.yaml` |

**Notas**:
- O contexto Notifications consome eventos para enviar emails/SMS aos candidatos
- Sem dependência síncrona — Notifications pode estar temporariamente indisponível

---

### CreditApproval → ExternalCreditBureau

**Tipo**: `anti-corruption-layer`
**Direção**: CreditApproval é o downstream

**Tradução**:

| Conceito em ExternalCreditBureau | Tradução em CreditApproval | Motivo |
|---|---|---|
| `risk_score` | `credit_score` | O domínio interno usa "credit_score" para alinhar com a linguagem de negócio |
| `inquiry_reason` | `application_type` | Mapeia códigos específicos do bureau para nossos tipos de domínio |

**Spec de integração**: `api/integrations/credit-bureau.yaml`

**Notas**:
- Respostas do bureau são cacheadas por 24 horas para reduzir custos
- Todo PII é criptografado em repouso

---

### CreditApproval → IdentityProvider

**Tipo**: `anti-corruption-layer`
**Direção**: CreditApproval é o downstream

**Tradução**:

| Conceito em IdentityProvider | Tradução em CreditApproval | Motivo |
|---|---|---|
| `sub` (JWT subject) | `applicant_id` | Alinha com a linguagem de domínio |

**Spec de integração**: `api/integrations/identity-provider.yaml`

---

## Contextos Externos (Sistemas de Terceiros)

| Sistema | Tipo de Integração | Responsável pelo ACL | Spec |
|---|---|---|---|
| ExternalCreditBureau | REST | CreditApproval | `api/integrations/credit-bureau.yaml` |
| IdentityProvider | OAuth 2.0 / JWT | CreditApproval | `api/integrations/identity-provider.yaml` |
| Notifications Service | Async (eventos) | Notifications | `api/events/*.yaml` |

---

## Regras de Evolução

1. **Mudanças quebrantes em contratos publicados** requerem aprovação de todos os contextos consumidores registrados neste mapa.
2. **Novos bounded contexts** são adicionados aqui antes de qualquer implementação.
3. **Contextos depreciados** permanecem no mapa com status `deprecated` até que todos os consumidores migrem.
4. **ACLs** são documentadas explicitamente — nunca implícitas no código.

---

## Histórico de Alterações

| Data | Alteração | Por |
|---|---|---|
| 2026-05-18 | Mapa inicial criado via Event Storming | senior-architect |
