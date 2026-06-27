# `/g-adr` Depth Model — Event-Triggered Depth

> **Status:** Design note (not yet implemented). Captures the conclusion of the
> M7d post-mortem deliberation on whether to tier the ADR interview.
> **Supersedes the idea of:** tiering the question count by self-rated stakes.

## The decision in one line

**Depth is event-triggered, not stakes-declared.** Every `/g-adr` runs a shallow
*core capture* by default; the deeper questions are pulled in only when an
**observable signal** says the decision is a fork worth defending. Routing never
trusts a developer's self-assessment of "how big is this," because the systematic
human error here is under-reporting blast radius.

## Why not the alternatives

- **Fixed-depth-7 (status quo).** Asks the full interview every time. Cheap
  insurance, but heavier than a contained, reversible decision warrants — and
  `/g-adr` is the one place in G-Forge still fixed-depth while everything else
  tunes ceremony to stakes.
- **Tier the questions by self-rated stakes (the original proposal).** Failed two
  premortems: (1) developers under-report reach, so the router under-fires exactly
  on the decisions that needed depth; (2) every mitigation dragged it back toward
  fixed-7, until the "saving" was ~2 questions for a router + tool call + conditional
  template. Rejected.
- **A fresh `/g-blast-radius` crawl at ADR time.** Costs a dependency-graph crawl
  per ADR, and is blind to greenfield decisions (no code to crawl yet) — i.e. blind
  to the highest-stakes case. Rejected as the *primary* signal; allowed only as an
  optional, developer-invoked confirm.

## The model

```
                          ┌─ not an ADR ──→  a row in project_brief.md "Tech decisions"
the lightest case  ───────┤                  (the "logged note" tier already exists here)
                          └─ an ADR ─────→  CORE CAPTURE (default)  ──(+signal)──→  DEEPEN
```

**Front door (before anything):** *Is this an ADR, or a brief row?* The lightest
"just log it" case is a tech-decisions-table entry, not a lightweight ADR. An ADR
is by definition the heavyweight artifact; we do not build a lightweight ADR mode.

**Core capture (the default floor for any ADR):**
- **Probe (always):** Decision · Context — opens the decision and its situation.
- **Core (always):** Consequences · Assumptions · Status.
  - `Assumptions` is **unconditional** — never gated. It is the proven risk-catcher
    (the M7d field report's one documented save). A conditional trigger for it is
    self-defeating: its value is surfacing risks *nobody had flagged yet*, so it must
    always fire.
  - Answer *depth* scales with stakes: one sentence per section for a contained
    change, full treatment for a Pillar. Same questions, scaled answers.

**Deepen (only on a depth signal):**
- Pulls in **Alternatives · Constraints** — the "defend the fork" questions — and
  the deliberation subagent's full rejected-alternatives analysis.
- These cost the most and only pay off when a signal says the fork is real.

## Depth signals

Split by cost. **Auto-detected** signals must add *zero new always-on machinery*
(see the weight budget below). **Must-ask** is the single safe-direction question.

### Auto-detected (free — read from existing artifacts or one cheap check at ADR start)

| # | Signal | How it's detected (no new patrol) |
|---|--------|-----------------------------------|
| 1 | **Supersedes / conflicts with an in-force ADR** | One grep of `docs/decisions/` for the area, *only when `/g-adr` runs*. Overturning a reasoned choice needs the why. |
| 2 | **Forces an edit to `project_brief.md`** (goals / non-goals / MVP / tech-decisions) | The crisp, objective definition of a **Pillar**. Cheap check at ADR start; `/g-align` also surfaces brief-drift at milestone close. |
| 3 | **Inside a milestone the premortem flagged high-risk on core code** | Read the `/g-forecast` / `/g-blast-radius` output that already ran at `/g-plan`. No new analysis. |
| 4 | **Introduces a one-way door** — new external dependency, public contract/API, or persisted schema/migration | `dependency-auditor` and `spec-writer` already flag new deps in `/g-plan`. Reversibility signal; works greenfield. |
| 5 | **Establishes a project-wide pattern / precedent** | `code-reviewer` already flags "new pattern applied project-wide" as a Major missing-ADR trigger. |
| 6 | **An existing ADR's work keeps failing** | Surfaced by `/g-retro` / the journal at milestone close — reality is invalidating the "Assumptions That Held." A *feedback* trigger: re-examine or supersede. Not a continuous watch. |

### Must-ask (one question; self-report used only in the safe direction)

| # | Signal | Rule |
|---|--------|------|
| 7 | **Decided under genuine uncertainty** | "Confident in this, or still uncertain?" Uncertainty **escalates** depth; confidence **never** shortcuts it. Self-report only ever *adds* depth, so the under-reporting bias cannot hurt routing. |

## Weight budget — "piggyback, don't patrol" (non-negotiable)

The detection layer must be **cheaper than fixed-7**, or it defeats its own purpose
and G-Forge gets dropped as heavy. Two hard rules:

1. **Piggyback, don't patrol.** Every signal is either (a) already produced by a skill
   that runs anyway (`/g-forecast`, `dependency-auditor`, `code-reviewer`, `/g-retro`,
   `/g-align`), or (b) a single cheap check performed *only at the moment `/g-adr` runs*
   (signals 1, 2). **No new background scanner. No per-commit ADR surveillance.**
2. **Fail toward shallow.** If detecting a signal would cost a new scan, skip it. A
   missed deep ADR is recoverable (write it later; the brief row covers the headline).
   An overwhelming watch is not — it gets the whole plugin abandoned. The asymmetry
   always favors *not* firing.

**Net cost added at ADR time:** one grep + one glance at the brief + one question.
Everything else free-rides on work already done upstream. If an upstream skill didn't
run (e.g. `light` tier), `/g-adr` simply doesn't inherit the hint and stays shallow —
fail-safe by construction.

## Explicitly NOT doing (so it stays light)

- No tiering of question count by self-rated stakes.
- No fresh `/g-blast-radius` crawl at ADR time (cost + greenfield-blind).
- No background ADR watcher / per-commit surveillance.
- No gate — `/g-adr` stays prompted/recommended, **never blocking**. Over-enforcement
  causes corpus pollution (ADR spam, records written from code/memory), which is worse
  than under-use because a polluted corpus buries the few ADRs that matter.
- No lightweight-ADR mode — the light case is a brief row, which already exists.

## Why this is safe

The report's documented catch — `Assumptions` surfacing the one real risk on a
decision that *looked* contained — is preserved, because `Assumptions` sits in the
always-on core, not behind a gate. Even the shallowest ADR keeps the risk-catcher.
Deepening only adds the fork-defense questions, and only when a signal says the fork
is real. Default-shallow + Assumptions-always + event-triggered-deepen survives both
premortems and the step-back: it never trusts a self-rating for routing, never adds a
patrol, and never makes the rare, high-stakes tool heavier to run.
