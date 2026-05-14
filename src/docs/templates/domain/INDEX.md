---
type: domain-index
status: ativo
owner: arquiteto-senior
updated: YYYY-MM-DD
---

# Domínio — [NOME DO PROJETO]

> Registro central dos bounded contexts, linguagem ubíqua e mapa de contextos.
> **Todo agente lê este arquivo antes de criar ou modificar qualquer spec em `api/`.**

---

## Regra fundamental

Os nomes neste documento são a **fonte de verdade** para toda nomenclatura do sistema.
Nenhum nome em `api/`, `database/` ou no código pode divergir do glossário de cada contexto.
Divergências são bugs — corrija na spec ou no código, nunca no glossário sem aprovação do PO.

---

## Bounded contexts registrados

| Contexto | Status | Responsável | Spec principal | Glossário | Última atualização |
|---|---|---|---|---|---|
| [nome-do-contexto] | `ativo` | arquiteto-senior | `api/[nome]-api.yaml` | `domain/[nome]-language.md` | YYYY-MM-DD |

**Status possíveis**: `descoberto` → `documentado` → `ativo` → `depreciado`

---

## Visão rápida dos contextos

> Descreva em 1-2 linhas a responsabilidade central de cada contexto.

### [Nome do Contexto]
Responsável por [responsabilidade principal]. Agrega [entidades-chave].
Consome eventos de [outros contextos]. Publica [eventos principais].

---

## Mapa de dependências (resumo)

> Detalhes completos em `domain/context-map.md`.

```
[ContextoA]  —[tipo-relação]→  [ContextoB]
[ContextoB]  —[tipo-relação]→  [ContextoC]
```

**Tipos de relação**: `conformista` | `anti-corruption-layer` | `publicador-consumidor` | `parceiro` | `shared-kernel`

---

## Domain events globais

| Evento | Publicado por | Consumido por | Spec |
|---|---|---|---|
| [NomeDoEvento] | [contexto-origem] | [contexto-destino] | `api/events/[nome]-event.yaml` |

---

## Histórico de mudanças

| Data | Mudança | Por |
|---|---|---|
| YYYY-MM-DD | Descoberta inicial dos bounded contexts via Event Storming | arquiteto-senior |
