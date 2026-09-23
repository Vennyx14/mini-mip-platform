# mini-MIP Platform

A hands-on learning project that builds a small **AI/ML inference-platform control plane** around **MLflow**, **KServe**, and **LiteLLM**.

> The project is intentionally miniature. It is designed to teach production-oriented reasoning about model lifecycle, serving, routing, state, failure handling, and source-code ownership—not to reimplement or replace the underlying platforms.

## 1. Why this project exists

The main learning objective is to become capable of joining an existing AI/ML platform codebase and eventually taking ownership of a feature or service.

The project therefore prioritizes:

- architecture comprehension;
- tracing real request/lifecycle paths through source code;
- explicit state transitions;
- integration boundaries;
- failure handling and idempotency;
- tests and verification;
- documentation and source maps;
- disciplined use of AI coding agents.

Success means being able to explain, debug, modify, and operate the codebase—not merely generate it.

## 2. System boundary

mini-MIP owns the **control/orchestration layer**.

MLflow owns model tracking/registry concerns.

KServe owns self-hosted model serving on Kubernetes.

LiteLLM owns gateway/routing concerns for inference requests.

```text
                    +-----------------------+
                    |       Developer       |
                    |      CLI / REST       |
                    +-----------+-----------+
                                |
                                v
                    +-----------------------+
                    |       mini-MIP        |
                    |     Control Plane     |
                    |-----------------------|
                    | Catalog               |
                    | Revision              |
                    | Deployment            |
                    | Activation            |
                    | Rollback              |
                    | Operation             |
                    | Reconciliation        |
                    +----+----------+-------+
                         |          |
              +----------+          +-----------+
              v                                 v
        +-----------+                      +-----------+
        |  MLflow   |                      |  KServe   |
        | Registry  |                      | Serving   |
        +-----+-----+                      +-----+-----+
              |                                  |
              | model artifact/version           | endpoint
              |                                  |
              +----------------+-----------------+
                               |
                               v
                         +-----------+
                         | LiteLLM   |
                         | Gateway   |
                         +-----+-----+
                               |
                               v
                            Client
```

The deployment lifecycle is conceptually:

```text
MLflow model version
        |
        v
  resolve + validate
        |
        v
 create/update KServe deployment
        |
        v
 wait for readiness
        |
        v
 verify serving identity
        |
        v
 configure/verify LiteLLM route
        |
        v
      activate
```

Important invariant:

> **Registration != deployment != readiness != activation**

A successful MLflow registration does not mean the model is deployed. Creating a KServe resource does not guarantee the model is ready. Readiness does not automatically mean the revision should become active.

## 3. Project phases

### Phase 0 — Repository foundation

Current phase.

Deliver:

- repository structure;
- `AGENTS.md` agent contract;
- `CLAUDE.md` compatibility shim;
- project README;
- Python project metadata;
- test/lint/type-check entry points;
- documentation and harness structure;
- Git-safe configuration templates.

### Phase 1 — Kubernetes and environment fundamentals

Understand the local Kubernetes environment, namespaces, pods, deployments, services, CRDs, logs, events, and readiness.

Target: a tiny non-LLM model can run locally on Kubernetes.

### Phase 2 — MLflow lab

Learn:

```text
Experiment -> Run -> Artifact -> Registered Model -> Model Version
```

Target: train/log a tiny model, register it, resolve its version, and retrieve its artifact URI.

### Phase 3 — KServe lab

Learn:

```text
InferenceService -> Controller -> Kubernetes resources -> Runtime -> Endpoint
```

Target: deploy the tiny model and diagnose readiness failures using Kubernetes evidence.

### Phase 4 — LiteLLM lab

Learn proxy/gateway concepts, model configuration, routing, upstream calls, authentication, and failure behavior.

Target: send an inference request through LiteLLM to an upstream model endpoint.

### Phase 5 — Three-way integration

Connect:

```text
MLflow -> mini-MIP -> KServe -> LiteLLM -> client
```

Target: one command or API workflow can resolve a model version, deploy it, verify readiness, configure routing, and activate it.

### Phase 6 — Control-plane semantics

Implement and test:

- Profile;
- Revision;
- Deployment Binding;
- Activation;
- Operation;
- Generation;
- explicit lifecycle/state transitions.

### Phase 7 — Failure engineering

Intentionally simulate:

- MLflow unavailable;
- model version missing;
- KServe deployment failure;
- readiness timeout;
- LiteLLM update failure;
- duplicate deploy requests;
- process crash during an operation;
- partial success requiring reconciliation;
- rollback.

### Phase 8 — Ownership / takeover test

A maintainer should be able to open a fresh terminal and trace, explain, test, debug, and modify the deployment lifecycle without relying on an AI agent.

## 4. Repository layout

```text
mini-mip-platform/
├── AGENTS.md
├── CLAUDE.md
├── README.md
├── pyproject.toml
├── .env.example
├── .gitignore
│
├── apps/
│   └── api/
│       ├── __init__.py
│       └── main.py
│
├── src/
│   └── mip/
│       ├── __init__.py
│       ├── catalog/
│       │   └── __init__.py
│       ├── control/
│       │   └── __init__.py
│       ├── integrations/
│       │   └── __init__.py
│       ├── services/
│       │   └── __init__.py
│       ├── models/
│       │   └── __init__.py
│       └── storage/
│           └── __init__.py
│
├── configs/
│   ├── profiles/
│   └── environments/
│
├── deployments/
│   ├── mlflow/
│   ├── kserve/
│   └── litellm/
│
├── docs/
│   ├── architecture.md
│   ├── lifecycle.md
│   ├── source-map.md
│   ├── troubleshooting.md
│   ├── decisions/
│   └── harness/
│       ├── context/
│       ├── build/
│       └── code_review/
│
├── research/
│   └── experiments/
│
├── scripts/
│   ├── bootstrap_repo.sh
│   └── ...
│
└── tests/
    ├── unit/
    ├── integration/
    └── e2e/
```

### Directory responsibilities

| Path | Responsibility |
|---|---|
| `apps/api/` | HTTP/API transport and application wiring |
| `src/mip/catalog/` | profiles and revisions |
| `src/mip/control/` | lifecycle orchestration and state transitions |
| `src/mip/integrations/` | MLflow, KServe/Kubernetes, and LiteLLM adapters |
| `src/mip/services/` | higher-level application services |
| `src/mip/models/` | domain schemas and shared data models |
| `src/mip/storage/` | persistence abstraction and implementations |
| `configs/` | versioned configuration templates |
| `deployments/` | manifests/config for external runtime components |
| `docs/` | architecture, lifecycle, troubleshooting, decisions, and takeover material |
| `tests/` | unit, integration, and end-to-end verification |

## 5. Development philosophy

The repository deliberately follows a small-change, inspect-and-verify workflow:

```text
Understand
    -> Plan
    -> Implement
    -> Inspect diff
    -> Test
    -> Manually verify
    -> Explain
    -> Document
    -> Commit
```

AI agents may accelerate implementation, but the human maintainer remains responsible for architecture, correctness, review, and repository ownership.

See `AGENTS.md` for the detailed agent contract.

## 6. Working with AI coding agents

For complex tasks, ask the agent to inspect and plan before editing.

Recommended pattern:

```text
1. Inspect repository
2. Explain relevant architecture
3. Propose a minimal plan
4. Implement only the approved scope
5. Run tests/checks
6. Review diff
7. Explain changed code and failure modes
8. Update docs
```

Do not accept a large multi-file change that you cannot explain.

## 7. Local development

Phase 0 intentionally keeps runtime dependencies minimal. The environment will be expanded as each lab phase is introduced.

Recommended Python environment:

```bash
python -m venv .venv
source .venv/Scripts/activate
```

On Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
```

Install the project in editable mode with development dependencies:

```bash
python -m pip install -e ".[dev]"
```

Run tests:

```bash
python -m pytest
```

Run linting/format checks when those tools are installed:

```bash
ruff check .
ruff format --check .
```

Run type checking when configured:

```bash
python -m mypy src
```

## 8. Git workflow

Keep changes small and logically focused.

Examples:

```text
feat: add MLflow model registry client
test: cover KServe readiness failures
docs: document activation lifecycle
refactor: isolate KServe adapter
```

Before a commit:

```bash
git status --short
git diff
python -m pytest
```

## 9. Learning and takeover criteria

The project is considered successful only when the maintainer can answer, without asking an agent to reveal the answer:

1. Where does a deployment request enter the system?
2. Where is the MLflow model version resolved?
3. Where is the KServe resource created?
4. How is readiness determined?
5. Where is the deployment binding persisted?
6. Where and how is a revision activated?
7. What happens if KServe succeeds but the LiteLLM update fails?
8. What happens when the same operation is submitted twice?
9. How is rollback represented?
10. How would reconciliation detect and repair partial state?

The maintainer should also be able to add a small feature without an AI agent and then use an agent to accelerate larger changes while still reviewing the result.

## 10. Current status

**Phase 0 — Repository foundation**

Status: scaffolded.

Next implementation target: Phase 1 environment/Kubernetes lab. No production-grade guarantees are claimed at this stage.
