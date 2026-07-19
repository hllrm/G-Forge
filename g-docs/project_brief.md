# Project Brief — G-Forge

**Created:** 2026-07-01 (retroactive — project is live at v2.2.0; review/amend as needed)
**Status:** Approved (retroactive draft — supersede via `/g-brief` when refined)

## What this builds

G-Forge is an opinionated multi-agent **Claude Code plugin** that wraps an *educated, enforced project-management* layer around Claude: planned execution, production architecture, enforced review, and context/hallucination control. It lets a solo developer — or a small team — get disciplined, senior-engineer-grade delivery out of an LLM: the machine runs the **process** (decompose → wave-dispatch → review-gate → commit-gate → retro), the human owns the **judgment**. The point is to let models *punch above their weight* while keeping the human the most valuable part of the loop. It is an **empowerment tool**, not a human-replacement — "simpler for humans," not "minimal."

## Goals

- **Enforce the process the way a good team lead would** — non-trivial work goes plan → execute → review → commit, and the **hard git commit gate** (a hook that blocks `git commit` without a review sign-off sentinel) makes the discipline non-optional, not advisory. This is the one novel, load-bearing differentiator.
- **Control context and hallucination** — single-use agents, distilled memory (retros/ADRs/handoff), the §A7 context reset, and `/g-resume` re-hydration keep the working window clean instead of poisoned.
- **Make the LLM govern itself honestly** — premortems, forecasts, architecture-review and doc-review gates, alignment/drift checks, and a passive observer journal (retro without interview) so quality is measured, not asserted.
- **Stay opinionated but degradable** — three integration tiers (`full`/`balanced`/`light`); with the plugin inert the repo behaves byte-identically to a plain project.
- **Scale governance from one session to many** — the multiplayer arc (see Roadmap): coordinate concurrent sessions/users without an AI ever becoming the master.

## Non-goals (explicitly out of scope)

- **Not autonomous AI-dispatches-AI, not a hosted authority.** Humans orchestrate; the machine surfaces, suggests, and records. Even the shared-work arc keeps a *human* orchestrator seat (ADR-002).
- **Not a replacement for the developer's judgment.** Every gate proposes; the human approves. "Swapping humans for brains" is explicitly rejected.
- **Not a CI/build system or a git replacement.** It advises git actions; it never auto-merges or gates the pipeline.
- **Not a general framework** — it is specifically a Claude Code plugin, leaning on Claude Code's skills/agents/hooks/MCP surfaces.

## MVP

Shipped at **M15 / v1.0.0**: the end-to-end enforced loop — `/g-kickoff` → `/g-roadmap` → `/g-init` → `/g-specialize`, then the per-task loop `/g-plan` → `/g-execute` → `/g-review` with the **commit gate** enforcing review sign-off. **Done condition (met):** a non-trivial feature can be taken from request to reviewed, gated, committed code without the developer manually orchestrating agents.

## Roadmap

| Milestone | Features | Rationale |
|-----------|----------|-----------|
| M1–M15 — Foundation → v1.0 | Agent roster, skills/orchestration, stack profiles, commit enforcement, intelligence (patterns/forecast/telemetry) | The enforced-PM MVP and its self-improvement loop |
| M23 — Production audit → v2.0.0 | Hardening, self-guarded hooks, rename pass | Make it shippable and safe to install anywhere |
| M27–M28 → v2.1–2.2 | Doc-review gate; `g-docs/` as canonical committed home | Docs gated like code; one tracking home |
| M29 — the register *(next build)* | Claim/lease substrate for concurrent sessions | The collision-avoidance substrate the whole multiplayer arc stands on |
| M33 — the Roundtable *(built, Phase A)* | Shared-doc human communication layer (`/g-roundtable`) | The cooperation arc's human-facing interface; dual-surface validated (Confluence/Gmail) |
| M34 — cross-session orchestration *(scoped)* | Dependency graph + pull/push suggestions (advised) | The arc's spine: run G-Forge orchestration across many sessions/users |
| M30–M32 *(provisional)* | Membership · handoff · reconciliation | Consequences of M34's graph; reconcile against it |

## Tech decisions

| Component | Choice | Rationale | Risk | Code-lead note |
|-----------|--------|-----------|------|----------------|
| Platform | Claude Code plugin (skills/agents/hooks/rules/commands) | Native to the target runtime; auto-discovered, travels to web/mobile/Actions when committed in `.claude/` | Coupled to Claude Code's plugin model | None |
| Enforcement | Git hook commit gate + review/doc sentinels (`.claude/g-forge-approved`, `-docs-approved`) | The hard gate is the differentiator — discipline made non-optional | Hook must self-guard to G-Forge projects only | Verified by unit tests |
| Memory | Distilled durable record in `g-docs/` (ROADMAP handoff, ADRs, retros) + passive observer journal | Clean-window re-entry over transcript inheritance | Distillation quality is load-bearing | `/g-retro` synthesizes; no interview |
| Agents | Single-use, scoped dispatch (task-decomposer, wave-planner, code-lead, etc.) | Keep HQ's context clean; offload high-branching reasoning | Agent sprawl | Promote finished answers only |
| Coordination surface (multiplayer) | Surface-agnostic adapter; **Confluence advised**, Gmail floor, Drive out (ADR-001) | Lead on official MCPs; degrade by capability tier without skill change | MCP availability divergence | Confluence = in-place; Gmail = draft-and-nod |
| Authority (multiplayer) | One **human** orchestrator seat per Roundtable, never co-chairs (ADR-002) | Answers "who owns `main`"; keeps AI out of the master role | Stale seat blocks decisions | Seat is an M29-leased claim |
| Deployment | GitHub repo + Claude Code marketplace; self-hosted on this repo (dogfood) | Distribution + continuous dogfooding | — | `/g-update` realigns installs |
| Naming / version strategy | Arc runs its natural life as **G-Forge 2.x**; rebrand ships as the **M44 capstone — G-Proof 1.0**, versioning restarts under the new name; **no mid-arc 3.0.0** (developer, 2026-07-18–19; downgraded from ADR — product strategy, not architecture) | Consumers keep a stable name through the heavy middle; "proof" claimed only when M38/M39 self-governance can back it | 2.13→1.0 reads as a downgrade to the unbriefed — announcement + CHANGELOG lead with the lineage note (M44.md premortem) | Not an ADR by triage |

## Success metrics

- **MVP worked:** a non-trivial change goes request → gated, reviewed, committed code without manual agent orchestration (met since v1.0).
- **Feature-complete signal:** context stays clean across long projects (compaction avoided via the gate), review catches regressions before merge, and — for the multiplayer arc — two sessions/users cooperate on one repo without colliding and without an AI taking the master seat.
- **Adoption:** the enforced-PM + commit-gate combination is recognizably the thing that makes an LLM "punch above its weight."

## Decisions and overrides

- **Positioning locked as "educated, enforced project management"** — context/hallucination control + the hard commit gate are the distinguishing capabilities (validated by deep research).
- **Empowerment over automation** — recurring developer directive: the human is the most valuable part of the loop; reject anything that reads as replacing them.
- **Multiplayer arc, human-first** — humans orchestrate; the Roundtable surfaces and records; the orchestrator seat is always human (ADR-002).

## Open questions

- **M29 feasibility:** is convention (an MCP mutable field — Confluence property / Gmail label) enough for a reliable claim/lease register? Phase A is the gating spike.
- **M30–M32 boundaries** will firm up (and likely fold under M34) once M29 ships and the dependency graph is real.
- **Versioning:** M33 Phase A shipped un-versioned on `main`; it ships its own minor when Phase B lands.
