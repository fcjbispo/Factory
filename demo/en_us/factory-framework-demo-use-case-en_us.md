## Use Case Proposal for Software Factory Demo

---

### 🎯 Recommended Use Case: **Credit Approval Microservice**

**Why this use case?**
- Rich, recognizable domain for any audience (technical or corporate)
- Clear, demonstrable business rules (score, limits, policies)
- Perfect scope for an isolated microservice
- Familiar enough to require no business explanation, yet complex enough to justify the framework

---

### 📦 Application Technical Scope

**Domain:** Personal credit approval
**Suggested stack:** Node.js (or Python) + REST API + relational database + automated tests + Docker + cloud deployment

**Core business rules:**
- Credit score analysis (score bands with different decisions)
- Credit limit calculated based on declared income
- Automatic rejection policy (blacklisted, insufficient income)
- Partial approval with adjusted amount
- Audit trail for all decisions (immutable log)

---

### 🎬 Video Structure (End-to-End)

#### **Act 1 — Conception** *(~5 min)*
> *"The client arrives with an idea. The PO (you) transforms it into domain language."*

- You present the briefing in natural language to the **PO/Analyst** agent
- The agent extracts: Ubiquitous Language, Bounded Contexts, Entities, Aggregates, Value Objects
- Output: Domain document (DDD Canvas)

#### **Act 2 — Architecture and Design** *(~5 min)*
> *"The domain becomes structure. SDD defines what will be built."*

- **Architect** agent receives the DDD Canvas
- Generates: component diagram, API contracts (OpenAPI), folder structure, documented technical decisions
- Output: Solution Design Document (SDD)

#### **Act 3 — Coding by Agents** *(~8 min)*
> *"The agents develop. You supervise as PO."*

- **Backend Dev** agent implements endpoints and business rules
- **DB Designer** agent creates schema and migrations
- You show the generated code, navigate the structure, validate DDD adherence
- Highlight: the code **reflects the domain** (class names = Ubiquitous Language)

#### **Act 4 — Automated Testing** *(~5 min)*
> *"Quality is guaranteed by agents, not by luck."*

- **QA** agent generates unit tests for business rules
- Generates integration tests for endpoints
- Live test execution in the terminal — all passing ✅
- Highlight: credit rule coverage (edge cases)

#### **Act 5 — Deploy and Delivery** *(~4 min)*
> *"From code to production in minutes."*

- **DevOps** agent generates Dockerfile + docker-compose
- Basic CI/CD pipeline (GitHub Actions or similar)
- Deployment demonstrated (Railway, Render or similar — fast and visual)
- Final API test in production via Postman/Thunder Client live

---

### 🧩 What Makes This Demo Powerful

| Element | Impact for Devs | Impact for Corporate |
|---|---|---|
| AI-generated DDD Canvas | Validates technical rigor | Shows organization and process |
| SDD as an artifact | Proves traceability | Ensures governance |
| Domain-adherent code | Architectural quality | Maintainability = ROI |
| Tests passing live | Technical confidence | Risk reduction |
| End-to-end deploy | Process completeness | Time-to-market |

---

### ⏱️ Estimated Total Duration
**~25–30 minutes** — ideal for a complete technical demo video, without cuts that compromise credibility.

---

**Suggested next steps:**

1. Validate the use case and adjust business rules if needed
2. Define which agents you will use (Claude, GPT, Cursor, etc.) and how they will be presented on screen
3. Build the detailed script with the exact prompts for each stage
4. Prepare the expected output artifacts (DDD Canvas and SDD templates)

Would you like me to start with the detailed script including prompts, or would you prefer to first define the architecture of the agents that will appear in the demo?
