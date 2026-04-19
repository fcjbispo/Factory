---
type: bounded-context
status: rascunho
owner: arquiteto-senior
updated: YYYY-MM-DD
related:
  - domain/INDEX.md
  - domain/context-map.md
  - domain/[nome]-language.md
  - api/[nome]-api.yaml
---

# Contexto: [Nome do Contexto]

> **Responsabilidade central**: [descreva em uma frase o que este contexto é responsável por]

---

## Visão geral

[Descrição de 3-5 linhas explicando o propósito deste bounded context, o problema de negócio que resolve e seus limites.]

**O que pertence a este contexto**:
- [lista de responsabilidades]

**O que NÃO pertence a este contexto**:
- [lista explícita de o que fica fora — evita scope creep]

---

## Agregados

> Um agregado é um cluster de objetos de domínio tratado como uma unidade. O agregado raiz é o único ponto de entrada para modificações.

### [NomeDoAgregado] *(agregado raiz)*

**Responsabilidade**: [o que este agregado representa e protege]

**Invariantes** (regras que nunca podem ser violadas):
- [invariante 1 — ex: "um Pedido deve ter ao menos um item"]
- [invariante 2]

**Campos**:
| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| id | UUID | sim | Identificador único |
| [campo] | [tipo] | sim/não | [descrição] |

**Estados possíveis** (se aplicável):
```
[ESTADO_A] → [ESTADO_B] → [ESTADO_C]
              ↓
          [ESTADO_CANCELADO]
```

**Transições e comandos**:
| Comando | Pré-condição | Resultado |
|---|---|---|
| [NomeDoComando] | [condição necessária] | [estado resultante ou evento publicado] |

---

## Entidades

> Entidades têm identidade própria (um `id`) e ciclo de vida independente dentro do agregado.

### [NomeDaEntidade]

**Responsabilidade**: [descrição]

**Campos**:
| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| id | UUID | sim | Identificador único |
| [campo] | [tipo] | sim/não | [descrição] |

---

## Value Objects

> Value Objects são imutáveis e definidos pelo valor de seus atributos, não por identidade. Não têm `id`.

### [NomeDoValueObject]

**Responsabilidade**: [descrição]
**Imutável**: sim — para alterar, cria-se um novo.

**Campos**:
| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| [campo] | [tipo] | sim | [descrição] |

**Regras de validação**:
- [regra 1 — ex: "CEP deve ter 8 dígitos"]
- [regra 2]

---

## Domain Events

> Eventos de domínio representam algo que aconteceu e é relevante para o negócio. São imutáveis e em tempo passado.

| Evento | Publicado quando | Payload obrigatório | Consumido por |
|---|---|---|---|
| [NomeDoEvento] | [condição de publicação] | [campos essenciais] | [contextos consumidores] |

### Detalhes por evento

#### [NomeDoEvento]

**Quando é publicado**: [descreva a ação de domínio que o dispara]

**Payload**:
| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| eventId | UUID | sim | Identificador único do evento |
| occurredAt | datetime | sim | Timestamp do ocorrido |
| [campo-do-domínio] | [tipo] | sim | [descrição] |

**Invariantes do payload** (regras que o evento sempre deve satisfazer):
- [ex: "a lista de itens deve ter ao menos 1 elemento"]

---

## Serviços de domínio

> Use quando uma operação não pertence naturalmente a nenhuma entidade ou agregado.

### [NomeDoServiço]

**Responsabilidade**: [o que este serviço calcula ou coordena]
**Inputs**: [o que recebe]
**Output**: [o que retorna ou publica]

---

## Repositórios

> Interfaces de acesso a agregados. A implementação fica fora do domínio.

| Repositório | Operações |
|---|---|
| `[Nome]Repository` | `findById`, `save`, `delete`, `findBy[Critério]` |

---

## Mapeamento para Spec (SDD)

> Como os conceitos deste contexto se tornam contratos em `api/`.

| Conceito DDD | Elemento da Spec | Arquivo |
|---|---|---|
| [NomeDoAgregado] (agregado raiz) | `type [NomeDoAgregado]` + mutations | `api/[nome]-api.yaml` |
| [NomeDaEntidade] | `type [NomeDaEntidade] { id: ID! }` | `api/[nome]-api.yaml` |
| [NomeDoValueObject] | `input [NomeDoValueObject]Input` | `api/[nome]-api.yaml` |
| [invariante: lista obrigatória] | `[campo]: [[Tipo]!]!` | `api/[nome]-api.yaml` |
| [estado do agregado] | `enum [NomeDoEstado]` | `api/[nome]-api.yaml` |
| [NomeDoEvento] | canal AsyncAPI / subscription | `api/events/[nome]-event.yaml` |

---

## Anti-Corruption Layer

> Se este contexto consome conceitos de outros contextos, documente aqui como a tradução é feita.

| Conceito externo (contexto origem) | Tradução neste contexto | Motivo |
|---|---|---|
| `[Conceito]` de `[ContextoOrigem]` | `[ConceitorTraduzido]` | [por que o nome difere neste contexto] |

---

## Histórico de mudanças

| Data | Mudança | Por |
|---|---|---|
| YYYY-MM-DD | Documento criado via Event Storming | arquiteto-senior |
