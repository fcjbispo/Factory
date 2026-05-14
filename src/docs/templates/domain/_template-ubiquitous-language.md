---
type: ubiquitous-language
status: ativo
owner: arquiteto-senior
updated: YYYY-MM-DD
related:
  - domain/[nome]-context.md
  - api/[nome]-api.yaml
---

# Linguagem Ubíqua — [Nome do Contexto]

> Este glossário é a **fonte de verdade** para toda nomenclatura dentro deste bounded context.
> Todos os nomes no código, nas specs, nos testes e na documentação devem corresponder exatamente aos termos aqui definidos.
> Qualquer divergência é um bug — não adapte o glossário ao código, adapte o código ao glossário.

---

## Como usar este documento

- **Agentes de IA**: antes de criar qualquer tipo, campo, mutation ou endpoint neste contexto, consulte este glossário.
- **Desenvolvedores**: ao nomear classes, tabelas, variáveis e rotas, use os termos deste glossário.
- **PO e especialistas de domínio**: qualquer novo termo deve ser aprovado e adicionado aqui antes de ser usado.

---

## Termos do domínio

### [Termo]

**Definição**: [descrição precisa do que este termo significa neste contexto]

**Tipo DDD**: `Agregado` | `Entidade` | `Value Object` | `Serviço de Domínio` | `Evento` | `Conceito de negócio`

**Usado como**:
- Na spec: `type [Termo]` / `input [Termo]Input` / `enum [EstadoDoTermo]`
- No código: `[Termo]` (class), `[termo]` (variable), `[termos]` (collection)
- No banco: `[termos]` (tabela), `[campo_do_termo]` (coluna)

**NÃO confundir com**:
- `[OutroTermo]` — [explicação de por que são diferentes]
- `[TermoDeOutroContexto]` em `[OutroContexto]` — [diferença de significado entre contextos]

**Exemplo de uso**:
> "[frase de exemplo usando o termo em contexto de negócio]"

---

### [OutroTermo]

**Definição**: [descrição]

**Tipo DDD**: [tipo]

**Usado como**:
- Na spec: [elemento]
- No código: [convenção]

---

## Termos proibidos neste contexto

> Termos que existem em outros contextos ou na linguagem técnica mas **não devem ser usados** aqui para evitar confusão.

| Termo proibido | Use em vez disso | Motivo |
|---|---|---|
| `[TermoProibido]` | `[TermoCorreto]` | [por que o termo proibido causa ambiguidade] |
| `item` | `[NomeEspecífico]` | "item" é genérico demais — use o nome do domínio |
| `data` | `[NomeEspecífico]` | idem |
| `record` | `[NomeEspecífico]` | idem |

---

## Termos compartilhados com outros contextos

> Termos que aparecem em múltiplos contextos, mas com significados diferentes. Atenção especial ao trabalhar com integrações.

| Termo | Significado neste contexto | Significado em [OutroContexto] |
|---|---|---|
| `[Termo]` | [definição local] | [definição no outro contexto] |

---

## Eventos de domínio — nomes canônicos

> Eventos são nomeados no **passado** e seguem o padrão `[Agregado][Ação]`.

| Nome canônico | Quando ocorre |
|---|---|
| `[AgregadoAção]` | [descrição do que ocorreu] |

---

## Comandos — nomes canônicos

> Comandos expressam **intenção** e seguem o padrão `[verbo][Agregado]`.

| Nome canônico | Intenção |
|---|---|
| `[VerboCriarAgregado]` | [o que o usuário/sistema quer fazer] |
| `[VerboCancelarAgregado]` | [idem] |

---

## Histórico de mudanças

| Data | Mudança | Por |
|---|---|---|
| YYYY-MM-DD | Glossário criado via Event Storming com PO | arquiteto-senior |
