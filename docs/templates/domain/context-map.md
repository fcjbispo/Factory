---
type: context-map
status: ativo
owner: arquiteto-senior
updated: YYYY-MM-DD
related:
  - domain/INDEX.md
---

# Mapa de Contextos — [NOME DO PROJETO]

> Define como os bounded contexts se relacionam e se comunicam.
> É a fonte de verdade para decisões de integração entre contextos.
> Leitura obrigatória antes de criar specs de eventos ou integrações entre contextos.

---

## Diagrama do mapa

```
[ContextoA]  —[conformista]→  [ContextoB]
[ContextoB]  —[publicador]→   [ContextoC]
[ContextoA]  —[ACL]→          [ContextoExterno]
```

*Diagrama detalhado em `architecture/diagrams/context-map.mmd` (Mermaid)*

---

## Tipos de relacionamento

| Tipo | Descrição | Implicação na spec |
|---|---|---|
| `conformista` | O consumidor adota o modelo do publicador sem tradução | Tipos da spec do consumidor espelham os do publicador |
| `anti-corruption-layer` (ACL) | O consumidor traduz o modelo do publicador para seu próprio | Spec de tradução explícita; termos podem diferir |
| `publicador-consumidor` | Um contexto publica eventos; outros consomem | Contrato AsyncAPI define o canal |
| `parceiro` | Dois contextos evoluem juntos com acordo mútuo | Specs coordenadas; breaking changes exigem acordo |
| `shared-kernel` | Dois contextos compartilham um subconjunto de modelo | Cuidado extremo com mudanças no kernel compartilhado |

---

## Relacionamentos detalhados

### [ContextoA] → [ContextoB]

**Tipo**: `[tipo-de-relação]`
**Direção**: [ContextoA] é o [upstream/downstream]

**O que é compartilhado**:
- [conceito ou evento compartilhado]

**Tradução** (se ACL):
| Conceito em [ContextoA] | Tradução em [ContextoB] | Motivo |
|---|---|---|
| `[ConceitoOrigem]` | `[ConceitoDestino]` | [por que os nomes diferem] |

**Spec de integração**: `api/events/[nome]-event.yaml`

**Notas**:
- [observações relevantes sobre esta integração]

---

### [ContextoB] → [ContextoC]

**Tipo**: `publicador-consumidor`
**Eventos publicados**:

| Evento | Canal | Spec |
|---|---|---|
| `[NomeDoEvento]` | `[nome-do-canal]` | `api/events/[nome]-event.yaml` |

---

## Contextos externos (sistemas de terceiros)

> Sistemas fora do domínio desta aplicação. Sempre tratados com ACL.

| Sistema | Tipo de integração | ACL responsável | Spec |
|---|---|---|---|
| [NomeDoSistemaExterno] | REST / GraphQL / Webhook | `[ContextoQueConsome]` | `api/integrations/[nome].yaml` |

---

## Regras de evolução

1. **Breaking changes em contratos publicados** exigem aprovação de todos os contextos consumidores registrados neste mapa.
2. **Novos bounded contexts** são adicionados aqui antes de qualquer implementação.
3. **Contextos depreciados** permanecem no mapa com status `depreciado` até que todos os consumidores migrem.
4. **ACLs** são documentadas explicitamente — nunca implícitas no código.

---

## Histórico de mudanças

| Data | Mudança | Por |
|---|---|---|
| YYYY-MM-DD | Mapa inicial criado via Event Storming | arquiteto-senior |
