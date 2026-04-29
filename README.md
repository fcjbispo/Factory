# Factory Framework

> Framework de gestão e execução de projetos de software com agentes de IA.

A Factory define como projetos são estruturados, documentados, operados e evoluídos — tanto por humanos quanto por agentes de IA. Ela gerencia **documentação e configuração**, mantendo separação clara do código-fonte.

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

# Mostrar comando para iniciar sessão
./factory-init.sh work meu-projeto
```

## Agentes de IA

7 agentes especializados, instalados globalmente via `./factory-init.sh agents`:

| Agente | Papel |
|---|---|
| Arquiteto Sênior | Arquitetura, ADRs, contratos de API, design de sistema |
| Full-Stack Developer | Implementação de features, correções, commits |
| DB Architect | Modelagem de dados, migrations, otimização de queries |
| Code Reviewer | Revisão obrigatória de PRs, qualidade, segurança |
| QA Tester | Estratégia de testes, automação, critérios de release |
| DevOps/SRE | CI/CD, infraestrutura, observabilidade, postmortems |
| Security Analyst | Threat modeling, vulnerabilidades, LGPD/GDPR |

## Documentação

Cada projeto Factory é documentado com templates canônicos nas seções: ADR, API, arquitetura, banco de dados, design, operações, segurança, testes, decisões de produto e contexto de sessão.

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
