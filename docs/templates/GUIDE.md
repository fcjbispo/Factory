---
type: guide
scope: global
updated: YYYY-MM-DD
---

# Guia de Documentação do Projeto

Este guia define como criar, atualizar, manter e navegar a documentação deste projeto. É destinado tanto a humanos quanto a agentes de IA.

---

## Filosofia

Esta estrutura foi desenhada para o paradigma de **desenvolvimento assistido por agentes de IA**. Isso implica em princípios diferentes de uma documentação tradicional:

**1. Legibilidade por máquina é tão importante quanto por humanos.**
Documentos têm frontmatter estruturado, status explícito e responsáveis declarados. Agentes não "navegam" — eles buscam e leem. Torne o caminho óbvio.

**2. Um documento = uma responsabilidade.**
Não misture decisões arquiteturais com especificações de feature. Não misture runbook com postmortem. Documentos atômicos são mais fáceis de encontrar, atualizar e substituir.

**3. O INDEX.md de cada seção é a fonte de verdade sobre o que existe.**
Todo agente deve ler o `INDEX.md` de uma seção antes de criar um documento novo para evitar duplicação.

**4. Documentos têm ciclo de vida.**
Nenhum documento é permanente. Todo documento tem um status. Documentos `depreciados` ou `substituídos` não são deletados — são marcados e permanecem como histórico.

**5. Atualizações são obrigatórias.**
Um documento desatualizado é pior do que um documento inexistente: induz agentes e humanos a erro. Se algo mudou, atualize ou deprecie.

---

## Estrutura de frontmatter (obrigatória em todos os documentos)

Todo documento deve começar com um bloco YAML:

```yaml
---
type: adr | api-contract | architecture | design | database | runbook | postmortem | threat-model | test-strategy | decision | policy
status: rascunho | em-revisão | ativo | depreciado | substituído-por: [caminho/do/novo-arquivo.md]
owner: arquiteto-senior | fullstack-developer | db-architect | code-reviewer | qa-tester | devops-sre | security-analyst | po
readers: [lista de agentes que devem ler este documento]
updated: YYYY-MM-DD
related:
  - caminho/relativo/para/doc-relacionado.md
---
```

**Campos obrigatórios**: `type`, `status`, `owner`, `updated`
**Campos recomendados**: `readers`, `related`

---

## Guia por segmento

### `adr/` — Architecture Decision Records

**O que vai aqui**: decisões técnicas significativas e de alto impacto que são difíceis ou custosas de reverter.

**O que NÃO vai aqui**: decisões de produto, escolhas de implementação reversíveis, preferências de estilo.

**Quando criar um ADR**:
- Escolha de tecnologia (banco de dados, framework, linguagem)
- Definição de padrão arquitetural (microserviços vs monolito, event-driven vs request-response)
- Mudança que afeta múltiplos módulos ou equipes
- Decisão que foi debatida e teve alternativas consideradas

**Formato de nome**: `NNNN-titulo-curto-em-kebab-case.md` (ex: `0001-escolha-do-banco-de-dados.md`)

**Numeração**: sequencial, com zero-padding de 4 dígitos. Nunca reutilize um número.

**Estados de ADR**: `proposto` → `aceito` → `depreciado` | `substituído-por: [adr/NNNN-novo.md]`

**Responsável**: arquiteto-senior cria e mantém. PO aprova decisões de alto impacto.

---

### `api/` — Contratos de API

**O que vai aqui**: especificações formais de APIs REST (OpenAPI), GraphQL schemas, contratos de eventos/mensagens, webhooks.

**O que NÃO vai aqui**: documentação de uso interno de funções ou classes (isso é documentação de código).

**Quando criar**:
- Antes de implementar qualquer endpoint ou mutation
- Ao adicionar eventos de domínio ao sistema
- Ao expor integrações com sistemas externos

**Formato**: OpenAPI 3.x em YAML para REST. SDL para GraphQL. Markdown estruturado para eventos.

**Regra crítica**: o contrato é a fonte de verdade. Implementação segue o contrato — nunca o contrário. Divergências entre implementação e contrato são bugs.

**Responsável**: arquiteto-senior define. fullstack-developer implementa. code-reviewer valida conformidade.

---

### `architecture/` — Arquitetura do Sistema

**O que vai aqui**: visão geral do sistema, descrição de componentes, diagramas de contexto/container/componente, fluxos de dados, integrações externas.

**Subseção `diagrams/`**: armazene diagramas como código sempre que possível (Mermaid, PlantUML, C4) em vez de imagens binárias. Imagens ficam em `diagrams/assets/`.

**Documentos esperados**:
- `overview.md`: visão geral de alto nível — obrigatório, é o primeiro documento que todos os agentes leem
- `components.md`: descrição detalhada de cada componente/módulo
- `integrations.md`: sistemas externos e como o sistema interage com eles
- `data-flow.md`: como os dados fluem pelo sistema (opcional, conforme complexidade)

**Responsável**: arquiteto-senior cria e mantém.

---

### `database/` — Banco de Dados

**O que vai aqui**: modelo entidade-relacionamento, descrição das tabelas/coleções, índices, políticas de acesso, changelog de schema.

**Documentos esperados**:
- `schema.md`: descrição completa do modelo de dados atual
- `changelog.md`: histórico de todas as mudanças de schema (append-only, nunca edite entradas anteriores)
- `indexes.md`: justificativa dos índices existentes (opcional, conforme complexidade)
- `data-policies.md`: classificação de dados sensíveis, retenção, LGPD/GDPR

**Responsável**: db-architect cria e mantém. security-analyst revisa `data-policies.md`.

---

### `design/` — Especificações de Features

**O que vai aqui**: documento de design de cada feature ou mudança significativa, escrito antes da implementação.

**Formato de nome**: `YYYY-MM-DD-nome-da-feature.md`

**Quando criar**: para qualquer feature que envolva mais de um agente ou que implique decisões de design não triviais. Features simples (CRUD straightforward) podem ser implementadas diretamente com base nos critérios de aceitação.

**Conteúdo mínimo**: contexto e problema, solução proposta, alternativas consideradas, impacto em componentes existentes, critérios de aceitação, abordagem de testes.

**Responsável**: arquiteto-senior cria. PO aprova. Todos os agentes envolvidos leem antes de iniciar.

---

### `operations/` — Operações

**O que vai aqui**: runbooks, procedimentos de deploy, procedimentos de rollback, postmortems de incidentes.

**`runbook.md`**: documento vivo com todos os procedimentos operacionais críticos. Deve ser executável — comandos reais, não descrições vagas.

**Subseção `postmortems/`**: um arquivo por incidente. Formato: `YYYY-MM-DD-nome-do-incidente.md`. Postmortems são blameless — o foco é em sistemas, processos e prevenção, nunca em pessoas.

**Responsável**: devops-sre cria e mantém. Postmortems envolvem todos os agentes afetados.

---

### `security/` — Segurança

**O que vai aqui**: políticas de segurança, threat models, registro de vulnerabilidades tratadas.

**`policies.md`**: documento com todas as políticas de segurança do projeto (autenticação, autorização, tratamento de dados sensíveis, secrets management, etc.). Todos os agentes devem ler.

**Subseção `threat-models/`**: um arquivo por feature ou componente analisado. Formato: `YYYY-MM-DD-nome-do-componente.md`.

**Regra crítica**: vulnerabilidades ativas não ficam neste repositório — são gerenciadas em canal privado e reportadas ao PO. Este repositório registra apenas vulnerabilidades já tratadas, como histórico.

**Responsável**: security-analyst cria e mantém.

---

### `testing/` — Testes e Qualidade

**O que vai aqui**: estratégia de testes, pirâmide de testes do projeto, thresholds de cobertura, ambientes de teste, dados de teste.

**`test-strategy.md`**: documento central com a estratégia completa. Inclui o que é testado em cada nível (unitário, integração, e2e), ferramentas utilizadas, thresholds de cobertura e critérios de qualidade para release.

**Responsável**: qa-tester cria e mantém. arquiteto-senior e devops-sre contribuem.

---

### `decisions/` — Decisões de Produto e Negócio

**O que vai aqui**: decisões tomadas pelo PO que impactam o produto — priorizações, mudanças de escopo, trade-offs de negócio, definição de personas, requisitos não-funcionais.

**O que NÃO vai aqui**: decisões técnicas (vão em `adr/`).

**Formato de nome**: `YYYY-MM-DD-titulo-da-decisao.md`

**Responsável**: PO cria e mantém. Agentes consultam para entender contexto de negócio.

---

## Regras de manutenção

**Ao criar um documento**:
1. Use o `_template.md` da seção
2. Preencha o frontmatter completamente
3. Adicione a entrada no `INDEX.md` da seção
4. Se o documento substitui outro, atualize o status do antigo para `substituído-por: [novo-arquivo.md]`

**Ao atualizar um documento**:
1. Atualize o campo `updated` do frontmatter
2. Registre o que mudou na seção `## Histórico de mudanças`
3. Se a mudança é significativa, notifique os `readers` declarados no frontmatter

**Ao depreciar um documento**:
1. Altere `status` para `depreciado` ou `substituído-por: [caminho]`
2. Adicione uma nota no topo do documento explicando por quê foi depreciado
3. NÃO delete o arquivo

**Periodicidade de revisão**:
- `architecture/overview.md`: revise a cada release major
- `adr/`: nunca edite um ADR aceito — crie um novo que o substitua
- `operations/runbook.md`: revise após cada incidente
- `security/policies.md`: revise a cada 6 meses ou após incidente de segurança
- `testing/test-strategy.md`: revise quando a estratégia de testes mudar

---

## Histórico de mudanças deste guia

| Data | Mudança | Por |
|---|---|---|
| YYYY-MM-DD | Versão inicial | arquiteto-senior |
