# FACTORY-GUIDE.md

**Version:** _1.3.0_

> Guia central do framework Factory.
> Leitura obrigatória para qualquer agente ou humano antes de iniciar, migrar ou operar um projeto sob este framework.

---

## O que é a Factory

A Factory é o framework de gestão e execução de projetos de software desta organização. Ela define como projetos são estruturados, documentados, operados e evoluídos — tanto por humanos quanto por agentes de IA.

A Factory gerencia **documentação e configuração**. O código-fonte vive separado, em `~/Dev/Projects/`. O script `factory-init.sh` é o ponto único de entrada para todas as operações de ciclo de vida de projetos — nunca crie estruturas manualmente.

---

## Paradigma DDD + SDD

A partir da versão 1.2.0, a Factory adota a integração entre **Domain-Driven Design (DDD)** e **Spec-Driven Development (SDD)** como paradigma central de modelagem e contratualização.

### O que cada um faz

**DDD é estratégico e tático** — define o quê e o porquê:
- Quais são os bounded contexts do sistema?
- Qual é a linguagem ubíqua de cada contexto?
- Quais são os agregados, entidades e value objects?
- Quais são os domain events e como os contextos se comunicam?

**SDD é operacional** — formaliza como isso se torna contrato executável:
- Como os conceitos do domínio viram contratos de API?
- Quais campos são obrigatórios? Quais são as invariantes?
- Como os contextos se comunicam via spec?
- O que constitui um breaking change?

### Regra de ouro

> Os nomes da spec devem ser **idênticos** à linguagem ubíqua do DDD.
> Se o domínio chama de `Pedido`, a spec não pode chamar de `Order` ou `Compra`.

### Sem DDD no SDD (o que evitar)

Spec usa nomes técnicos genéricos (`item`, `record`, `data`). Ninguém sabe o que representa. Contextos se misturam na mesma API. Invariantes de domínio são perdidas ou ficam apenas no código.

### Com DDD guiando o SDD (o objetivo)

Spec usa linguagem do negócio (`Pedido`, `Estoque`, `Pagamento`). Cada bounded context tem sua própria spec. Contratos refletem invariantes do domínio. A spec é legível por especialistas de negócio.

### Mapeamento DDD → SDD

| Conceito DDD | Elemento da Spec |
|---|---|
| Agregado raiz | Tipo principal + mutations (`createX`, `updateX`) |
| Entidade | Tipo com `id: ID!` |
| Value Object | `input type` (sem ID, imutável) |
| Invariante de domínio | Campo `!` (non-null) ou `minItems` |
| Estado do agregado | `enum` |
| Domain Event | Subscription GraphQL ou canal AsyncAPI |
| Bounded Context | Spec separada (arquivo próprio em `api/`) |
| Anti-Corruption Layer | Spec de tradução explícita entre contextos |

### Cada contexto = uma spec separada

Não há um schema gigante. Cada bounded context expõe sua própria API com seus próprios tipos e contratos. O arquivo `docs/domain/context-map.md` registra como os contextos se relacionam e quais specs correspondem a cada um.

---

## Estrutura da Factory

```
~/Dev/
├── Factory/ ← repositório da Factory
│ ├── FACTORY-GUIDE.md ← este documento
│ ├── factory-init.sh ← ponto único de entrada para operações
│ ├── docs/
│ │ ├── agents/ ← perfis dos agentes de IA
│ │ └── templates/ ← templates de documentação reutilizáveis
│ └── [nome-do-projeto]/ ← um diretório por projeto
│ ├── .factory ← config: registra src_path e metadados
│ ├── docs/ ← documentação (derivada dos templates)
│ └── docs-legado/ ← documentação pré-Factory (modo full)
│
└── Projects/
 └── [nome-do-projeto]/ ← código-fonte do projeto
 ├── .claude/
 │ └── commands/
 │ └── factory-init.md ← atalho para carregar contexto na sessão
 └── CLAUDE.md ← identidade do projeto e ponteiros para Factory
```

---

## Mapa completo: `Factory/docs/`

### `docs/agents/`

**Propósito**: repositório dos perfis de agentes de IA disponíveis para todos os projetos da Factory.

**Responsável**: PO define o time. Arquiteto Sênior mantém os perfis técnicos.

**Quando usar**: execute `./factory-init.sh agents` para instalar todos os agentes globalmente em `~/.claude/agents/`. Disponíveis em qualquer projeto da máquina sem duplicação.

| Arquivo | Agente | Papel principal |
|---|---|---|
| `arquiteto-senior.md` | Arquiteto Sênior | Decisões de arquitetura, ADRs, contratos de API, modelagem DDD, design de sistema |
| `fullstack-developer.md` | Full-Stack Developer | Implementação de features, testes unitários, commits |
| `db-architect.md` | DB Architect | Modelagem de dados, migrations, otimização de queries |
| `code-reviewer.md` | Code Reviewer | Revisão obrigatória de PRs, qualidade, padrões, segurança no código |
| `qa-tester.md` | QA Tester | Estratégia de testes, automação, critérios de qualidade para release |
| `devops-sre.md` | DevOps/SRE | CI/CD, infraestrutura, observabilidade, postmortems |
| `security-analyst.md` | Security Analyst | Threat modeling, políticas de segurança, auditoria de vulnerabilidades |
| `README.md` | — | Instruções de instalação e uso dos agentes |

---

### `docs/templates/`

**Propósito**: templates canônicos de documentação. Nenhum documento de projeto é criado do zero — sempre parte de um template desta pasta.

**Responsável**: Arquiteto Sênior mantém os templates técnicos. PO mantém os templates de decisão de produto.

**Quando usar**: o `factory-init.sh` copia automaticamente esta estrutura para `Factory/[projeto]/docs/` ao criar ou adotar um projeto. Nunca copie manualmente.

---

#### `templates/INDEX.md`

**Propósito**: ponto de entrada da documentação de qualquer projeto. Lista o que existe, onde está e quem deve ler o quê por agente.

**Responsável**: Arquiteto Sênior cria ao iniciar o projeto e mantém atualizado.

**Ação obrigatória**: todo agente lê este arquivo antes de qualquer outra coisa ao entrar em um projeto.

---

#### `templates/GUIDE.md`

**Propósito**: guia de uso da estrutura de documentação do projeto — convenções de nomenclatura, frontmatter obrigatório, ciclo de vida dos documentos, regras de manutenção e periodicidade de revisão.

**Responsável**: Arquiteto Sênior. Não deve ser alterado por outros agentes sem aprovação.

**Ação obrigatória**: leitura na primeira sessão de trabalho em qualquer projeto.

---

#### `templates/domain/` ← **novo em v1.2.0**

**Propósito**: modelagem do domínio pelo paradigma DDD. Define os bounded contexts, a linguagem ubíqua, os agregados, entidades, value objects e domain events. É a **fonte de verdade para os nomes e contratos** de todas as specs em `api/`.

**Responsável**: Arquiteto Sênior lidera com especialistas de domínio (PO e stakeholders de negócio). Nenhum nome na spec pode divergir deste glossário.

**Regra crítica**: toda spec em `api/` deve ser derivada de um bounded context documentado em `domain/`. Specs não rastreáveis a um contexto de domínio não são aceitas.

| Arquivo | Descrição |
|---|---|
| `INDEX.md` | Registro tabular de todos os bounded contexts com status e spec correspondente |
| `context-map.md` | Mapa de como os contextos se relacionam (conformista, ACL, publicador/consumidor) |
| `_template-bounded-context.md` | Template para documentar um bounded context: agregados, entidades, value objects, invariantes e domain events |
| `_template-ubiquitous-language.md` | Template para o glossário da linguagem ubíqua de cada contexto |

**Nomenclatura de contextos**: `[nome-do-contexto]-context.md` — ex: `pedidos-context.md`, `estoque-context.md`
**Nomenclatura de glossários**: `[nome-do-contexto]-language.md` — ex: `pedidos-language.md`

**Quando criar**:
- Ao iniciar um projeto novo: antes de qualquer spec em `api/`
- Ao adotar um projeto existente: como parte da avaliação inicial
- Ao identificar um novo bounded context emergindo no código

---

#### `templates/adr/`

**Propósito**: registra decisões arquiteturais significativas e irreversíveis. Um ADR aceito nunca é editado — é substituído por um novo.

**Responsável**: Arquiteto Sênior cria. PO aprova decisões de alto impacto.

| Arquivo | Descrição |
|---|---|
| `INDEX.md` | Registro tabular de todos os ADRs do projeto com status |
| `_template.md` | Template para novos ADRs (contexto, decisão, alternativas, consequências) |

**Nomenclatura**: `NNNN-titulo-em-kebab-case.md` — ex: `0001-escolha-do-banco-de-dados.md`

**Quando criar um ADR**: escolha de tecnologia, definição de padrão arquitetural, mudança que afeta múltiplos módulos, qualquer decisão debatida com alternativas consideradas. Inclui decisões de delimitação de bounded contexts.

---

#### `templates/api/`

**Propósito**: contratos formais de API. O contrato é a fonte de verdade — a implementação segue o contrato, nunca o contrário.

**Responsável**: Arquiteto Sênior define os contratos. Full-Stack Developer implementa. Code Reviewer valida conformidade.

| Arquivo | Descrição |
|---|---|
| `INDEX.md` | Registro de todos os contratos ativos com tipo, versão, bounded context de origem e status |

**Formatos aceitos**: OpenAPI 3.x (`.yaml`) para REST, SDL (`.graphql`) para GraphQL, AsyncAPI (`.yaml`) para eventos e mensagens.

**Regra crítica**: nenhum endpoint ou evento é implementado sem contrato aprovado nesta pasta.

**Regra DDD**: cada spec deve referenciar o bounded context de origem no seu frontmatter (`domain_context: nome-do-contexto`). Nomes de tipos, campos e operações devem seguir o glossário do contexto correspondente em `domain/`.

---

#### `templates/architecture/`

**Propósito**: visão do sistema — componentes, diagramas, integrações, fluxos de dados.

**Responsável**: Arquiteto Sênior cria e mantém.

| Arquivo/Pasta | Descrição |
|---|---|
| `overview.md` | Visão geral do sistema. Leitura obrigatória para todos os agentes. |
| `diagrams/` | Diagramas como código (Mermaid, PlantUML, C4). Imagens binárias em `diagrams/assets/`. |

**Documentos adicionais recomendados** (criar conforme necessidade do projeto):
- `components.md`: descrição detalhada de cada módulo
- `integrations.md`: sistemas externos e como o projeto interage com eles
- `data-flow.md`: fluxo de dados pelo sistema

---

#### `templates/database/`

**Propósito**: modelo de dados, histórico de mudanças de schema e políticas de tratamento de dados.

**Responsável**: DB Architect cria e mantém. Security Analyst revisa `data-policies.md`.

| Arquivo | Descrição |
|---|---|
| `INDEX.md` | Índice dos documentos de banco com status |
| `schema.md` (a criar) | Estado atual completo do modelo de dados |
| `changelog.md` (a criar) | Histórico append-only de mudanças de schema |
| `data-policies.md` (a criar) | Classificação de dados sensíveis, retenção, LGPD/GDPR |

**Regra crítica**: `changelog.md` é append-only — nunca edite entradas anteriores.

---

#### `templates/backlog/` — NOVO na v1.3.0

**Propósito**: gestão de produção contínua — bugs, melhorias, débito técnico, documentação, segurança, performance, dependências e dados.

**Responsável**: PO faz triage e priorização. Arquiteto avalia impacto técnico. Agentes executam conforme papel.

| Arquivo/Pasta | Descrição |
|---|---|
| `INDEX.md` | Visão geral do backlog e regras de fluxo |
| `backlog-rules.md` | Regras de priorização (MoSCoW + RICE), estados, responsabilidades |
| `_template.md` | Template padronizado para qualquer item de backlog |
| `issues/` | Bugs e problemas reportados |
| `improvements/` | Melhorias e features técnicas |
| `tech-debt/` | Débito técnico e refactoring |
| `documentation/` | Gestão de documentação desatualizada ou faltante |
| `security/` | Vulnerabilidades, patches e atualizações de segurança |
| `performance/` | Bottlenecks, tuning e escalabilidade |
| `dependencies/` | Updates de dependências, EOL e vulnerabilidades |
| `data/` | Migrations, backup e políticas de retenção |

**Nomenclatura**: `YYYY-MM-DD-titulo-curto.md`

**Estados**: `aberto` → `em-analise` → `priorizado` → `em-progresso` → `resolvido` | `rejeitado` | `suspenso`

**Prioridade**: `P1` (crítico) | `P2` (alto) | `P3` (médio) | `P4` (baixo)

**Regras gerais**:
1. Todo item deve ter critérios de aceitação claros
2. Review trimestral obrigatório para tech-debt
3. Postmortem obrigatório para issues de severidade crítica
4. Prazos: segurança crítica=24h, alto=7 dias, médio=30 dias, baixo=90 dias

---

#### `templates/design/`

**Propósito**: especificações de features escritas **antes** da implementação. Define o contrato entre PO, Arquiteto e agentes de implementação.

**Responsável**: Arquiteto Sênior cria. PO aprova. Todos os agentes envolvidos leem antes de iniciar.

| Arquivo | Descrição |
|---|---|
| `INDEX.md` | Registro de features em andamento e concluídas |
| `_template.md` | Template com contexto, solução, componentes afetados, critérios de aceitação |

**Nomenclatura**: `YYYY-MM-DD-nome-da-feature.md`

**Quando criar**: para qualquer feature que envolva mais de um agente ou decisões de design não triviais.

---

#### `templates/operations/`

**Propósito**: procedimentos operacionais críticos e registro histórico de incidentes.

**Responsável**: DevOps/SRE cria e mantém.

| Arquivo/Pasta | Descrição |
|---|---|
| `INDEX.md` | Índice dos documentos operacionais e lista de postmortems |
| `runbook.md` (a criar) | Documento vivo com comandos reais para operações críticas |
| `postmortems/` | Um arquivo por incidente |
| `postmortems/_template.md` | Template blameless com linha do tempo, causa raiz e ações corretivas |

**Nomenclatura de postmortems**: `YYYY-MM-DD-nome-do-incidente.md`

---

#### `templates/security/`

**Propósito**: políticas de segurança do projeto e threat models por componente.

**Responsável**: Security Analyst cria e mantém.

| Arquivo/Pasta | Descrição |
|---|---|
| `INDEX.md` | Índice com aviso sobre vulnerabilidades ativas e lista de threat models |
| `policies.md` (a criar) | Políticas de autenticação, autorização, secrets, dados sensíveis |
| `threat-models/` | Um arquivo por componente ou feature analisada |
| `threat-models/_template.md` | Template STRIDE com ativos, ameaças, controles e riscos aceitos |

**Aviso**: vulnerabilidades ativas **não** ficam nesta pasta — são gerenciadas em canal privado.

---

#### `templates/testing/`

**Propósito**: estratégia de testes do projeto — paradigma SBD, ferramentas, thresholds e critérios de release.

**Responsável**: QA Tester cria e mantém.

| Arquivo | Descrição |
|---|---|
| `test-strategy.md` | Documento central de estratégia de testes. Leitura obrigatória para todos os agentes. |

---

#### `templates/decisions/`

**Propósito**: decisões de produto e negócio tomadas pelo PO. Distinto de ADRs, que são decisões técnicas.

**Responsável**: PO cria e mantém. Agentes consultam para entender contexto de negócio.

| Arquivo | Descrição |
|---|---|
| `INDEX.md` | Registro de todas as decisões de produto com status |
| `_template.md` | Template com contexto, decisão, motivação, trade-offs e critérios de revisão |

**Nomenclatura**: `YYYY-MM-DD-titulo-da-decisao.md`

---

#### `templates/context/`

**Propósito**: contexto de sessão persistente entre sessões de trabalho.

**Responsável**: todos os agentes atualizam ao final de cada sessão significativa.

| Arquivo | Descrição |
|---|---|
| `active.md` | Foco atual, decisões recentes, próximos passos, bloqueadores |
| `progress.md` | O que está completo, em andamento e pendente |

**Regra**: leitura obrigatória no início de cada sessão, antes de qualquer tarefa.

---

## Setup inicial da Factory (uma vez por máquina)

```bash
cd ~/Dev/Factory

# Instalar agentes globalmente
./factory-init.sh agents

# Adicionar a função shell ao perfil
./factory-init.sh shell-setup >> ~/.zshrc && source ~/.zshrc
```

---

## Iniciando um projeto do zero

```bash
cd ~/Dev/Factory
./factory-init.sh new <nome-do-projeto>
```

O script cria automaticamente:
- `~/Dev/Projects/<nome>/` com `CLAUDE.md`
- `Factory/<nome>/docs/` a partir dos templates (inclui `domain/`)
- `Factory/<nome>/docs/context/` para contexto de sessão
- `Factory/<nome>/.factory` com `src_path` registrado
- `.claude/commands/factory-init.md` no projeto

### Primeira sessão

```bash
cd ~/Dev/Projects/<nome-do-projeto>
# abra o Claude Code / seu provedor
```

Dentro da sessão:

```
/add-dir ~/Dev/Factory/<nome>/docs
/factory-init
```

Em seguida, a sequência obrigatória DDD → SDD → implementação:

```
@arquiteto-senior Leia docs/INDEX.md e docs/GUIDE.md.
Execute Event Storming com o contexto disponível:
1. Identifique os bounded contexts do sistema
2. Crie docs/domain/context-map.md com o mapa de contextos
3. Para cada contexto, crie docs/domain/[nome]-context.md e docs/domain/[nome]-language.md
4. Crie docs/architecture/overview.md descrevendo a arquitetura inicial
5. Registre o primeiro ADR com as decisões tecnológicas

@arquiteto-senior Com os bounded contexts definidos em domain/,
crie os contratos de API correspondentes em docs/api/,
garantindo que todos os nomes seguem a linguagem ubíqua de cada contexto.

@qa-tester Leia docs/architecture/overview.md e docs/domain/context-map.md.
Crie docs/testing/test-strategy.md usando SBD como paradigma,
considerando os bounded contexts e domain events identificados.

@security-analyst Leia docs/architecture/overview.md e docs/domain/ .
Crie docs/security/policies.md com as políticas de segurança iniciais,
considerando os dados sensíveis de cada bounded context.
```

---

## Integrando um projeto existente

Projetos existentes podem ser integrados em dois modos: **migração completa** ou **convivência**.

### Avaliação inicial (obrigatória para ambos os modos)

Inicie uma sessão na raiz do projeto existente e execute:

```
@arquiteto-senior Faça uma avaliação deste projeto:
1. Mapeie a estrutura de código (módulos, camadas, padrões identificados)
2. Identifique bounded contexts emergentes no código existente
3. Liste toda documentação existente e avalie sua qualidade
4. Identifique decisões técnicas que deveriam virar ADRs
5. Aponte a linguagem ubíqua implícita no código (nomes de classes, tabelas, rotas)
6. Aponte gaps de documentação críticos
Produza um relatório para que o PO decida o modo de integração.
```

---

### Modo 1: Migração completa

**Quando usar**: projeto em desenvolvimento ativo, documentação existente escassa ou desatualizada.

```bash
cd ~/Dev/Factory
./factory-init.sh adopt <nome-do-projeto> --mode=full
```

O script executa automaticamente:
- Copia `docs/` existente para `Factory/<nome>/docs-legado/`
- Cria `Factory/<nome>/docs/` a partir dos templates (inclui `domain/`)
- Cria `Factory/<nome>/docs/context/`
- Cria `CLAUDE.md` no projeto com ponteiros para Factory e legado
- Cria `.claude/commands/factory-init.md` no projeto
- Registra o projeto em `Factory/<nome>/.factory`

### Primeira sessão após o adopt

```bash
cd ~/Dev/Projects/<nome-do-projeto>
# abra o Claude Code / seu provedor
```

```
/add-dir ~/Dev/Factory/<nome>/docs
/factory-init
execute prompt factory-adoption
```

O prompt `factory-adoption` (salvo em `~/Dev/Contexts/Prompts/factory-adoption.md`)
conduz os agentes pela varredura completa e população da estrutura Factory,
incluindo a descoberta e documentação dos bounded contexts em `domain/`.

### Arquivar o legado após validação com o PO

```bash
tar -czf ~/Dev/Factory/<nome>/docs-legado.tar.gz \
 ~/Dev/Factory/<nome>/docs-legado/
rm -rf ~/Dev/Factory/<nome>/docs-legado/
```

---

### Modo 2: Convivência

**Quando usar**: projeto em produção crítica, documentação existente ainda válida, migração imediata custosa.

```bash
cd ~/Dev/Factory
./factory-init.sh adopt <nome-do-projeto> --mode=coexist
```

O script cria `Factory/<nome>/docs/` sem tocar no existente e configura
o `CLAUDE.md` com as regras de precedência entre as duas fontes.

### Comportamento no modo convivência

| Situação | Ação |
|---|---|
| Criar documentação nova | Sempre em `Factory/<nome>/docs/` |
| Criar specs de API | Sempre derivadas de `domain/` (linguagem ubíqua obrigatória) |
| Consultar documentação | Leia ambas — Factory prevalece em conflito |
| Atualizar doc existente | Migre de `docs/` para Factory primeiro |

### Critérios para encerrar o modo convivência

- Mais de 80% da documentação ativa em `Factory/docs/`
- Nenhum arquivo em `docs/` consultado nos últimos 60 dias
- `domain/` com todos os bounded contexts documentados
- PO aprova a migração final

Para encerrar:

```bash
./factory-init.sh adopt <nome-do-projeto> --mode=full
```

---

## Iniciando uma sessão de trabalho

Para qualquer projeto já registrado:

```bash
cd ~/Dev/Projects/<nome-do-projeto>
# abra o Claude Code / seu provedor
```

Dentro da sessão, sempre em sequência:

```
/add-dir ~/Dev/Factory/<nome>/docs
/factory-init
```

O `/add-dir` carrega os docs Factory no contexto da sessão.
O `/factory-init` orienta o Claude a ler `docs/INDEX.md`,
`docs/context/active.md` e `docs/context/progress.md`.

### Hook global de lembrete (opcional)

Adicione ao `~/.claude/settings.json` para receber o `/add-dir` correto
automaticamente ao iniciar qualquer sessão em projeto Factory:

```json
{
 "hooks": {
 "SessionStart": [
 {
 "hooks": [
 {
 "type": "command",
 "command": "bash -c 'PROJECT=$(basename \"$PWD\"); DOCS=\"$HOME/Dev/Factory/$PROJECT/docs\"; if [ -d \"$DOCS\" ]; then echo \"{\\\"additionalContext\\\": \\\"/add-dir $DOCS\\\"}\" ; fi'"
 }
 ]
 }
 ]
 }
}
```

---

## Adicionando `/factory-init` a um projeto já existente

Se o projeto foi adotado antes desta versão do script:

```bash
cd ~/Dev/Factory
./factory-init.sh add-command <nome-do-projeto>
```

---

## Referência rápida do `factory-init.sh`

| Comando | O que faz |
|---|---|
| `./factory-init.sh agents` | Instala agentes em `~/.claude/agents/` |
| `./factory-init.sh new <nome>` | Cria projeto novo (código + docs + domain/ + comando) |
| `./factory-init.sh adopt <nome> --mode=full` | Integra projeto existente — migração completa |
| `./factory-init.sh adopt <nome> --mode=coexist` | Integra projeto existente — convivência |
| `./factory-init.sh add-command <nome>` | Adiciona `/factory-init` a projeto existente |
| `./factory-init.sh work <nome>` | Mostra como iniciar a sessão no projeto |
| `./factory-init.sh list` | Lista projetos registrados com status |
| `./factory-init.sh shell-setup` | Gera bloco de função shell para `.bashrc`/`.zshrc` |

---

## Referência rápida de responsabilidades

| Artefato | Cria | Mantém | Aprova | Lê obrigatoriamente |
|---|---|---|---|---|
| `INDEX.md` (raiz) | arquiteto-senior | arquiteto-senior | — | todos os agentes |
| `GUIDE.md` | arquiteto-senior | arquiteto-senior | PO | todos os agentes (1ª sessão) |
| `domain/INDEX.md` | arquiteto-senior | arquiteto-senior | PO | todos os agentes |
| `domain/context-map.md` | arquiteto-senior | arquiteto-senior | PO | todos os agentes |
| `domain/[ctx]-context.md` | arquiteto-senior | arquiteto-senior | PO | arquiteto-senior, fullstack-developer |
| `domain/[ctx]-language.md` | arquiteto-senior | arquiteto-senior + PO | PO | todos os agentes |
| `context/active.md` | qualquer agente | todos os agentes | — | todos os agentes (início de sessão) |
| `context/progress.md` | qualquer agente | todos os agentes | — | todos os agentes (início de sessão) |
| `adr/` | arquiteto-senior | arquiteto-senior | PO (alto impacto) | arquiteto-senior, code-reviewer |
| `api/` | arquiteto-senior | arquiteto-senior | arquiteto-senior | fullstack-developer, code-reviewer |
| `architecture/overview.md` | arquiteto-senior | arquiteto-senior | — | todos os agentes |
| `database/` | db-architect | db-architect | arquiteto-senior | fullstack-developer, security-analyst |
| `design/` | arquiteto-senior | arquiteto-senior | PO | todos os agentes envolvidos na feature |
| `operations/runbook.md` | devops-sre | devops-sre | — | devops-sre |
| `operations/postmortems/` | devops-sre | devops-sre | — | todos os agentes afetados |
| `security/policies.md` | security-analyst | security-analyst | PO | todos os agentes |
| `security/threat-models/` | security-analyst | security-analyst | arquiteto-senior | devops-sre |
| `testing/test-strategy.md` | qa-tester | qa-tester | — | fullstack-developer, devops-sre |
| `decisions/` | PO | PO | — | arquiteto-senior, fullstack-developer |

---

## Regras gerais

1. **Nenhum documento é criado sem template.** Use sempre o `_template.md` da seção correspondente.
2. **Todo documento tem frontmatter.** Campos `type`, `status`, `owner` e `updated` são obrigatórios.
3. **Documentos depreciados não são deletados.** Altere o status e deixe o histórico intacto.
4. **A Factory não armazena código-fonte.** Apenas gestão, documentação e templates.
5. **Um projeto por diretório.** Nunca compartilhe código entre projetos Factory.
6. **`docs/` de projeto deriva de `Factory/docs/templates/`.** Nunca edite os templates diretamente em um projeto — edite em `Factory/docs/templates/` e propague com `factory-init.sh`.
7. **Todo ciclo de vida de projeto passa pelo `factory-init.sh`.** Nunca crie estruturas manualmente.
8. **Specs derivam de domínio.** Nenhum contrato em `api/` é criado sem bounded context correspondente em `domain/`. Nomes divergentes da linguagem ubíqua são bugs de documentação.
9. **Linguagem ubíqua é contrato.** O glossário em `domain/[ctx]-language.md` é a fonte de verdade para nomenclatura. Qualquer divergência entre o glossário e o código ou a spec deve ser resolvida — sempre em favor do glossário.

---

## Histórico de mudanças

| Data | Versão | Mudança | Por |
|---|---|---|---|
| YYYY-MM-DD | 1.0.0 | Versão inicial | arquiteto-senior |
| YYYY-MM-DD | 1.1.0 | Refatoração: comandos manuais substituídos por factory-init.sh; separação código/docs; seção de sessão de trabalho; hook global; context/ adicionado | arquiteto-senior |
| YYYY-MM-DD | 1.2.0 | Integração DDD+SDD: nova seção `domain/` nos templates; paradigma DDD→SDD documentado; mapeamento conceitos DDD para elementos de spec; regras 8 e 9 adicionadas; responsabilidades de domain/ na tabela; sequência de primeira sessão atualizada para incluir Event Storming e descoberta de bounded contexts | arquiteto-senior |
