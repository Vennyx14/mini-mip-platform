# AGENTS.md — mini-MIP Platform

## 1. Mission

This repository is a **learning and engineering lab** for a small AI/ML inference-platform control plane coordinating MLflow, KServe, and LiteLLM.

Do not reimplement those products. Learn and implement the integration/control responsibilities around them: catalog/revisions, deployment, readiness verification, routing, activation, rollback, idempotency, reconciliation, testing, and observability.

The repository must remain understandable and maintainable by a human who did not write the latest change.

## 2. Instruction priority

- System, developer, and explicit user instructions take precedence.
- Follow this file for repository-wide engineering behavior.
- A more-specific `AGENTS.md` or `AGENTS.override.md` may add or refine rules for its subtree.
- Do not invent conventions when the existing code/docs establish one.

## 3. Repository boundaries

- `README.md` — human-facing overview, setup, architecture, lifecycle, and status.
- `AGENTS.md` — durable instructions for coding agents.
- `docs/` — detailed design, lifecycle, troubleshooting, decisions, source maps, and learning artifacts.
- `apps/api/` — transport/API entrypoints and wiring; keep it thin.
- `src/mip/catalog/` — profiles and revisions.
- `src/mip/control/` — lifecycle orchestration and state transitions.
- `src/mip/integrations/` — MLflow, KServe/Kubernetes, and LiteLLM adapters.
- `src/mip/services/` — higher-level application services.
- `src/mip/models/` — domain schemas/shared models.
- `src/mip/storage/` — persistence abstraction and implementations.
- `configs/` — versioned configuration templates.
- `deployments/` — external component manifests/configuration.
- `tests/` — unit, integration, and end-to-end verification.

Do not put large design documents in `AGENTS.md`; link to `docs/` instead.

## 4. Core architecture

```text
MLflow model/version
        |
        v
   mini-MIP control plane
        |
        v
 KServe deployment/runtime
        |
        v
   serving endpoint
        |
        v
     LiteLLM
        |
        v
      client
```

Keep these concepts distinct:

- **Profile** — logical model/service configuration.
- **Revision** — versioned configuration; treat it as immutable after publication unless the design explicitly says otherwise.
- **Deployment Binding** — relationship between a revision and a concrete serving deployment.
- **Activation** — decision that a verified revision is live/eligible for routing.
- **Operation** — durable record of an externally observable action.
- **Generation** — identifier used when desired and observed state must be distinguished.

Critical invariant:

> **Registration != deployment != readiness != activation.**

Never mark a revision `ACTIVE` merely because a KServe resource was created.

## 5. Plan before coding

For non-trivial work:

1. Inspect the repository and relevant code.
2. Restate behavior and constraints.
3. Identify affected modules and external-system boundaries.
4. Produce a small implementation plan.
5. Implement only the approved scope.
6. Run relevant verification.
7. Review the final diff.
8. Update docs when behavior/interfaces/lifecycle/operations changed.
9. Summarize changes, checks, assumptions, and limitations.

For architectural, risky, or broad changes, stop after the plan until the human approves it.

Do not edit many files “just in case”. Prefer the smallest correct change.

## 6. AI-agent rules

The agent accelerates work; the human owns the repository.

Before changing code, inspect at least:

```bash
pwd
git status --short
git branch --show-current
git log -5 --oneline
find . -maxdepth 3 -type f | sort
```

When uncertain, inspect first and state assumptions. Do not silently replace the architecture with a different pattern.

Do not merge code that the maintainer cannot explain.

For every meaningful change, the maintainer should understand:

- control/data flow;
- state read/written;
- external systems called;
- failure modes;
- retry/duplicate behavior;
- verification strategy.

Use AI freely for boilerplate, tests, adapters, documentation, exploration, and review, but keep important lifecycle decisions explicit and reviewable.

## 7. Testing and verification

Tests are part of implementation.

For Python changes, run the narrowest relevant checks first and then broader checks when practical:

```bash
python -m pytest
ruff check .
ruff format --check .
python -m mypy src
```

Only run commands that are installed/configured; do not hide failed checks.

Do not weaken or delete tests solely to make a change pass. Update a test when intended behavior genuinely changed and explain the reason.

For integration/stateful changes, verify representative success and failure paths, including duplicate execution or partial failure where relevant.

## 8. External systems

Treat MLflow, Kubernetes/KServe, and LiteLLM as failure-prone external dependencies.

Never assume:

- a network call is instantaneous;
- a created resource is immediately ready;
- readiness alone proves the correct endpoint/configuration;
- retries are safe;
- external and local state changes are atomic.

Make timeouts, polling, retries, and failure semantics explicit.

## 9. State and idempotency

For every lifecycle transition, define:

- valid source state;
- target state;
- owner of the transition;
- repeated-request behavior;
- behavior when the external side effect succeeds but local persistence fails;
- how stale/partial state is detected or reconciled.

Prefer explicit state machines over scattered booleans for important lifecycle state.

## 10. Dependencies, config, and security

- Use the declared project dependency mechanism.
- Do not add a dependency without a clear reason.
- Avoid unrelated upgrades.
- Record validated version constraints intentionally.
- Keep secrets out of source control.
- Use `.env.example` only for variable names and safe placeholders.
- Never commit API keys, tokens, kubeconfigs, certificates, private credentials, or generated local state.

## 11. API and domain contracts

- Define request/response schemas explicitly.
- Validate at boundaries.
- Keep provider-specific payloads inside integration adapters where practical.
- Keep domain decisions out of vendor clients.
- Do not leak transport/provider details across the entire codebase without a reason.
- When a contract changes, update tests and documentation in the same change.

## 12. Documentation

Update documentation when changing:

- architecture;
- public API/contracts;
- lifecycle/state semantics;
- setup/deployment procedures;
- troubleshooting;
- important design decisions.

Use `docs/decisions/` for durable architecture decisions and trade-offs.

Maintain `docs/source-map.md` once source modules exist. It should allow a new developer to trace important requests through the codebase.

Use `docs/harness/build/` for execution plans for complex changes.

## 13. Git

Keep commits small and logically focused. Prefer imperative messages such as:

```text
feat: add MLflow model registry client
test: cover KServe readiness failures
docs: document activation lifecycle
refactor: isolate KServe adapter
```

Before committing:

```bash
git status --short
git diff
git diff --check
python -m pytest
```

Never rewrite or discard unrelated user changes.

## 14. Review rules

Review for:

- correctness and intended behavior;
- state/lifecycle consistency;
- failure handling;
- idempotency;
- external-system assumptions;
- test coverage;
- accidental scope expansion;
- maintainability and traceability;
- documentation consistency.

Prefer concrete, evidence-based findings over generic style commentary.

## 15. Definition of Done

A meaningful change is done when, as applicable:

- implementation matches the agreed design;
- relevant tests/checks pass;
- the final diff was inspected;
- integration behavior was manually verified when needed;
- documentation matches the new behavior;
- no unrelated files were changed;
- known limitations are recorded.

## 16. Project status and scope

This is an educational miniature, not a production clone of any internal MIP platform. Do not claim production guarantees that have not been implemented and verified.

Phase 0 establishes the repository contract. Future phases introduce Kubernetes, MLflow, KServe, LiteLLM, integration, lifecycle semantics, failure engineering, and takeover testing.

### Public design references

The workflow is informed by public OpenAI Codex and Anthropic Claude Code guidance: persistent repository instructions, plan-first work for complex tasks, and explicit test/review/verification loops.
