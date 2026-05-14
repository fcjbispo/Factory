# Factory Framework

> Framework de gestão e execução de projetos de software com agentes de IA.
> Integra **Domain-Driven Design (DDD)** e **Spec-Driven Development (SDD)** como paradigma central.

A Factory define como projetos são estruturados, documentados, operados e evoluídos — tanto por humanos quanto por agentes de IA. Ela gerencia **documentação e configuração**, mantendo separação clara do código-fonte.

## Paradigma DDD + SDD

A partir da v1.2.0, a Factory adota a integração entre DDD (estratégico/tático) e SDD (operacional):

- **DDD** define o quê e o porquê — bounded contexts, linguagem ubíqua, agregados, domain events
- **SDD** formaliza como isso vira contrato executável — APIs, invariantes, breaking changes

Cada bounded context expõe sua própria spec em `docs/api/`. O arquivo `docs/domain/context-map.md` registra como os contextos se relacionam.

## Estrutura

```
~/Dev/
├── Factory/                    ← repositório da Factory
│   ├── factory-init.sh         ← ponto único de entrada
│   ├── FACTORY-GUIDE.md        ← guia canônico
│   └── docs/
│       ├── agents/             ← 7 perfis de agentes de IA
│       └── templates/          ← templates de documentação
└── Projects/
    └── <projeto>/              ← código-fonte
```

Documentação e configuração vivem em `~/Dev/Factory/<projeto>/`. Código-fonte vive em `~/Dev/Projects/<projeto>/`. A ponte entre os dois é o `/add-dir` dentro das sessões Claude Code.

## Instalação

```bash
cd ~/Dev/Factory

# Instalar agentes globalmente
./factory-init.sh agents

# Adicionar função shell ao perfil
./factory-init.sh shell-setup >> ~/.zshrc && source ~/.zshrc
```

## Uso rápido

```bash
# Criar projeto novo
./factory-init.sh new meu-projeto

# Integrar projeto existente (migração completa)
./factory-init.sh adopt meu-projeto --mode=full

# Integrar projeto existente (convivência)
./factory-init.sh adopt meu-projeto --mode=coexist

# Listar projetos registrados
./factory-init.sh list

# Atualizar framework da branch master
./factory-init.sh update [--version=X.Y.Z] [--dry-run]

# Propagar templates para projeto
./factory-init.sh sync <nome> [--dry-run]

# Mostrar comando para iniciar sessão
./factory-init.sh work meu-projeto
```

## Agentes de IA

7 agentes especializados, instalados globalmente via `./factory-init.sh agents`:

| Agente               | Papel                                                  |
| ----------------------| --------------------------------------------------------|
| Arquiteto Sênior     | Arquitetura, ADRs, contratos de API, design de sistema |
| Full-Stack Developer | Implementação de features, correções, commits          |
| DB Architect         | Modelagem de dados, migrations, otimização de queries  |
| Code Reviewer        | Revisão obrigatória de PRs, qualidade, segurança       |
| QA Tester            | Estratégia de testes, automação, critérios de release  |
| DevOps/SRE           | CI/CD, infraestrutura, observabilidade, postmortems    |
| Security Analyst     | Threat modeling, vulnerabilidades, LGPD/GDPR           |

## Documentação

Cada projeto Factory é documentado com templates canônicos nas seções: ADR, API, arquitetura, backlog (gestão de produção), banco de dados, design, domínio (context-map DDD), operações, segurança, testes, decisões de produto e contexto de sessão.

### Backlog (novo na v1.3.0)

Gestão de produção contínua com priorização MoSCoW + RICE. Categorias: bugs, melhorias, débito técnico, documentação, segurança, performance, dependências e dados. Estados: `aberto` → `em-análise` → `priorizado` → `em-progresso` → `resolvido`.

## Regras fundamentais

- Nenhum documento é criado sem template — use sempre o `_template.md` da seção
- Todo documento tem frontmatter YAML obrigatório (`type`, `status`, `owner`, `updated`)
- ADRs aceitos nunca são editados — são substituídos por um novo
- `database/changelog.md` é append-only
- Vulnerabilidades ativas não são armazenadas no repositório

## Leitura adicional

- [FACTORY-GUIDE.md](FACTORY-GUIDE.md) — guia canônico completo
- [docs/templates/INDEX.md](docs/templates/INDEX.md) — ponto de entrada da documentação
- [docs/templates/GUIDE.md](docs/templates/GUIDE.md) — convenções de documentação
