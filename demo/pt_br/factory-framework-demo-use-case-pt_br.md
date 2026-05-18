## Proposta de Use Case para Demo da Software Factory

---

### 🎯 Use Case Recomendado: **Microserviço de Aprovação de Crédito**

**Por quê este use case?**
- Domínio rico e reconhecível por qualquer público (técnico ou corporativo)
- Regras de negócio claras e demonstráveis (score, limites, políticas)
- Escopo perfeito para um microserviço isolado
- Familiar o suficiente para não precisar de explicação de negócio, mas complexo o suficiente para justificar o framework

---

### 📦 Escopo Técnico da Aplicação

**Domínio:** Concessão de crédito para pessoa física
**Stack sugerida:** Node.js (ou Python) + REST API + banco relacional + testes automatizados + Docker + deploy em cloud

**Regras de negócio principais:**
- Análise de score de crédito (faixas com decisões diferentes)
- Limite de crédito calculado com base em renda declarada
- Política de rejeição automática (negativado, renda insuficiente)
- Aprovação parcial com valor ajustado
- Auditoria de todas as decisões (log imutável)

---

### 🎬 Estrutura do Vídeo (End-to-End)

#### **Ato 1 — Concepção** *(~5 min)*
> *"O cliente chega com uma ideia. O PO (você) transforma isso em linguagem de domínio."*

- Você apresenta o briefing em linguagem natural para o agente **PO/Analista**
- O agente extrai: Ubiquitous Language, Bounded Contexts, Entidades, Agregados, Value Objects
- Saída: Documento de domínio (DDD Canvas)

#### **Ato 2 — Arquitetura e Design** *(~5 min)*
> *"O domínio vira estrutura. SDD define o que será construído."*

- Agente **Arquiteto** recebe o DDD Canvas
- Gera: diagrama de componentes, contratos de API (OpenAPI), estrutura de pastas, decisões técnicas documentadas
- Saída: Solution Design Document (SDD)

#### **Ato 3 — Codificação pelos Agentes** *(~8 min)*
> *"Os agentes desenvolvem. Você supervisiona como PO."*

- Agente **Backend Dev** implementa os endpoints e regras de negócio
- Agente **DB Designer** cria o schema e migrations
- Você mostra o código gerado, navega pela estrutura, valida aderência ao DDD
- Destaque: o código **reflete o domínio** (nomes de classes = Ubiquitous Language)

#### **Ato 4 — Testes Automatizados** *(~5 min)*
> *"A qualidade é garantida por agentes, não por sorte."*

- Agente **QA** gera testes unitários para as regras de negócio
- Gera testes de integração para os endpoints
- Execução ao vivo dos testes no terminal — todos passando ✅
- Destaque: cobertura das regras de crédito (casos de borda)

#### **Ato 5 — Deploy e Entrega** *(~4 min)*
> *"Do código para produção em minutos."*

- Agente **DevOps** gera Dockerfile + docker-compose
- Pipeline CI/CD básico (GitHub Actions ou similar)
- Deploy demonstrado (Railway, Render ou similar — rápido e visual)
- Teste final da API em produção via Postman/Thunder Client ao vivo

---

### 🧩 O que Torna Esta Demo Poderosa

| Elemento | Impacto para Devs | Impacto para Corporativo |
|---|---|---|
| DDD Canvas gerado por IA | Valida rigor técnico | Mostra organização e processo |
| SDD como artefato | Prova rastreabilidade | Garante governança |
| Código aderente ao domínio | Qualidade arquitetural | Manutenibilidade = ROI |
| Testes passando ao vivo | Confiança técnica | Redução de risco |
| Deploy end-to-end | Completude do processo | Time-to-market |

---

### ⏱️ Duração Total Estimada
**~25–30 minutos** — ideal para um vídeo técnico de demonstração completa, sem cortes que comprometam a credibilidade.

---

**Próximos passos sugeridos:**

1. Validar o use case e ajustar as regras de negócio se necessário
2. Definir quais agentes você usará (Claude, GPT, Cursor, etc.) e como serão apresentados na tela
3. Montar o roteiro detalhado com os prompts exatos de cada etapa
4. Preparar os artefatos de saída esperados (templates do DDD Canvas e SDD)

Quer que eu comece pelo roteiro detalhado com os prompts, ou prefere primeiro definir a arquitetura dos agentes que aparecerão na demo?
