---
type: ubiquitous-language
status: active
owner: senior-architect
updated: 2026-05-18
related:
  - domain/credit-approval-context.md
  - api/credit-approval-api.yaml
---

# Linguagem Ubíqua — Aprovação de Crédito

> Este glossário é a **fonte da verdade** para toda a nomenclatura dentro deste bounded context.
> Todos os nomes em código, specs, testes e documentação devem corresponder exatamente aos termos definidos aqui.
> Qualquer divergência é um bug — não adapte o glossário ao código, adapte o código ao glossário.

---

## Como Usar Este Documento

- **Agentes de IA**: antes de criar qualquer tipo, campo, mutation ou endpoint neste contexto, consulte este glossário.
- **Desenvolvedores**: ao nomear classes, tabelas, variáveis e rotas, use os termos deste glossário.
- **PO e especialistas de domínio**: qualquer novo termo deve ser aprovado e adicionado aqui antes de ser usado.

---

## Termos de Domínio

### CreditApplication

**Definição**: Uma solicitação formal submetida por um indivíduo ou entidade buscando crédito. Contém toda a informação necessária para o processo de avaliação de crédito.

**DDD Type**: `Aggregate`

**Usado como**:
- Na spec: `type CreditApplication`, `input CreditApplicationInput`
- No código: `CreditApplication` (classe), `creditApplication` (variável), `creditApplications` (coleção)
- No banco: `credit_applications` (tabela)

**NÃO confunda com**:
- `CreditDecision` — o resultado de avaliar uma aplicação, não a solicitação em si
- `Applicant` — a pessoa/entidade que submete a aplicação

**Exemplo de uso**:
> "O aplicante submeteu uma CreditApplication com renda mensal declarada de $5.000."

---

### Applicant

**Definição**: O indivíduo ou entidade jurídica solicitando crédito. Um Applicant pode submeter múltiplas CreditApplications ao longo do tempo.

**DDD Type**: `Entity`

**Usado como**:
- Na spec: `type Applicant`, `input ApplicantInput`
- No código: `Applicant` (classe), `applicant` (variável)
- No banco: `applicants` (tabela)

**Exemplo de uso**:
> "O Applicant deve fornecer comprovante de renda antes que a CreditApplication possa ser processada."

---

### CreditDecision

**Definição**: O resultado final da avaliação de uma CreditApplication. É imutável uma vez emitida e contém a decisão (aprovada, rejeitada ou parcialmente aprovada), o limite aprovado (se aplicável) e a justificativa.

**DDD Type**: `Entity`

**Usado como**:
- Na spec: `type CreditDecision`, `enum DecisionStatus`
- No código: `CreditDecision` (classe), `decision` (variável)
- No banco: `credit_decisions` (tabela)

**NÃO confunda com**:
- `CreditApplication` — a solicitação, não o resultado
- `CreditLimit` — o valor máximo disponível, que pode diferir do valor aprovado

**Exemplo de uso**:
> "A CreditDecision para a aplicação APP-2026-001 foi APPROVED com limite de $10.000."

---

### CreditLimit

**Definição**: O valor máximo de crédito que um Applicant está autorizado a usar. Calculado com base na renda, score e políticas de risco. Expresso na moeda do Applicant.

**DDD Type**: `Value Object`

**Usado como**:
- Na spec: `input CreditLimitInput`, `type CreditLimit`
- No código: `CreditLimit` (classe), `limit` (variável)
- No banco: `credit_limit` (coluna em `credit_decisions`)

**Regras de validação**:
- Deve ser um decimal positivo com 2 casas decimais
- Máximo permitido: 30x a renda mensal do Applicant
- Mínimo permitido: $100,00

**Exemplo de uso**:
> "O CreditLimit calculado de $12.500 excedeu o teto da política, então foi reduzido para $10.000."

---

### CreditScore

**Definição**: Uma representação numérica da capacidade de crédito do Applicant, obtida de um bureau externo. Varia de 300 a 850. É um valor somente-leitura no nosso domínio — não o calculamos.

**DDD Type**: `Value Object`

**Usado como**:
- Na spec: `type CreditScore`
- No código: `CreditScore` (classe), `score` (variável)
- No banco: `credit_score` (coluna em `credit_applications`)

**Regras de validação**:
- Deve ser um inteiro entre 300 e 850
- Scores abaixo de 500 disparam rejeição automática
- Scores acima de 750 qualificam para limites premium

**Exemplo de uso**:> "O CreditScore de 720 do Applicant o colocou na faixa 'baixo risco'."

---

### RiskBand

**Definição**: Uma classificação que agrupa CreditScores em categorias definidas por políticas. Determina a taxa de juros e o multiplicador máximo para cálculo do CreditLimit.

**DDD Type**: `Value Object` / `Enum`

**Valores possíveis**:
- `LOW` — CreditScore >= 750
- `MEDIUM` — CreditScore 600-749
- `HIGH` — CreditScore 500-599
- `INELIGIBLE` — CreditScore < 500

**Usado como**:
- Na spec: `enum RiskBand`
- No código: `RiskBand` (enum), `riskBand` (variável)
- No banco: `risk_band` (coluna como VARCHAR)

**Exemplo de uso**:
> "Um Applicant na faixa HIGH RiskBand recebe um multiplicador máximo de 10x a renda mensal."

---

### AuditTrail

**Definição**: Um registro imutável de todas as ações tomadas durante o ciclo de vida de uma CreditApplication. Obrigatório para compliance regulatório e resolução de disputas.

**DDD Type**: `Entity`

**Usado como**:
- Na spec: `type AuditTrailEntry`
- No código: `AuditTrailEntry` (classe), `auditTrail` (coleção)
- No banco: `audit_trail` (tabela)

**Exemplo de uso**:
> "O AuditTrail mostra que a CreditApplication foi submetida às 09:15, pontuada às 09:16 e decidida às 09:17."

---

## Termos Proibidos Neste Contexto

| Termo Proibido | Use Em Vez | Motivo |
|---|---|---|
| `customer` | `applicant` | "Customer" implica um relacionamento existente; nosso domínio lida com prospects |
| `user` | `applicant` | Muito genérico — use o termo de domínio |
| `loan` | `credit` | O domínio é sobre aprovação de crédito, não liberação de empréstimo |
| `data` | `[termo específico de domínio]` | Muito genérico — use o nome da entidade |
| `record` | `[nome da entidade]` | Muito genérico — use o termo de domínio |
| `status` | `[estado específico]` | Use nomes explícitos de estado: `SUBMITTED`, `SCORING`, `DECIDED` |

---

## Termos Compartilhados com Outros Contextos

| Termo | Significado em CreditApproval | Significado em Notifications |
|---|---|---|
| `applicant` | A entidade sendo avaliada | O destinatário das mensagens de notificação |
| `decision` | O resultado da avaliação de crédito | A ação de enviar uma mensagem ("send decision") |

---

## Eventos de Domínio — Nomes Canônicos

| Nome Canônico | Quando Ocorre |
|---|---|
| `CreditApplicationSubmitted` | Quando um aplicante submete uma nova aplicação de crédito |
| `CreditScoreReceived` | Quando o bureau externo retorna um score |
| `CreditDecisionIssued` | Quando a avaliação completa e uma decisão é registrada |
| `CreditLimitUpdated` | Quando uma anulação manual altera uma decisão existente |

---

## Comandos — Nomes Canônicos

| Nome Canônico | Intenção |
|---|---|
| `SubmitCreditApplication` | Criar uma nova aplicação de crédito |
| `EvaluateCreditApplication` | Disparar o processo de pontuação e decisão |
| `OverrideCreditDecision` | Alterar manualmente uma decisão existente (requer autorização) |
| `RequestAuditTrail` | Recuperar o log completo de auditoria para uma aplicação |

---

## Histórico de Alterações

| Data | Alteração | Por |
|---|---|---|
| 2026-05-18 | Glossário criado via Event Storming com PO | senior-architect |
