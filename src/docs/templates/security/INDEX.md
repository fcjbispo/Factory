---
type: index
scope: security
updated: YYYY-MM-DD
---

# Security — Segurança

> ⚠️ Vulnerabilidades **ativas** não são documentadas aqui.
> São gerenciadas em canal privado e reportadas diretamente ao PO.
> Este repositório registra apenas vulnerabilidades já tratadas e as políticas vigentes.

## Documentos principais

| Arquivo | Conteúdo | Status |
|---|---|---|
| [policies.md](policies.md) | Políticas de segurança do projeto | `rascunho` |

## Threat Models

| Arquivo | Componente analisado | Data | Status |
|---|---|---|---|
| — | — | — | — |

## Como usar

- `policies.md`: leitura obrigatória para todos os agentes. Atualizado pelo @security-analyst, revisado a cada 6 meses ou após incidente.
- Threat models: copie `threat-models/_template.md`, nomeie como `YYYY-MM-DD-nome-do-componente.md` e adicione a entrada na tabela acima.
- Threat models devem ser criados pelo @security-analyst **antes** da implementação de features com dados sensíveis ou superfície de ataque relevante.
