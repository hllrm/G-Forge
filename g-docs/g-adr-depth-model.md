# `/g-adr` Depth — Deliberation Record & Recommendation

> **Status:** Design record. Conclusion was **light touch or no update**; the **light
> touch shipped** (see "What shipped" below). Captures the M7d post-mortem deliberation on
> whether to tier the ADR interview, three premortems, and the codebase research behind the
> call. The fixed 7-question pass is unchanged — the change is a capture-mode choice and a
> mandatory reversibility + premortem closing pass, not question-tiering.

## What shipped

The maintainer chose the light touch. Implemented in `skills/g-adr/SKILL.md`:

- **Entry triage** (Step 1) — the front-door gap the post-mortem actually surfaced: place
  the decision as an **ADR**, a **brief row** (a one-line tech-decisions entry, for contained
  reversible choices), or **nothing**, before running the interview. Reversibility is the
  tell; propose-don't-impose. This is what keeps the corpus rare and high-signal — and what
  stops a heavyweight ADR being run on a lightweight decision (the originating misuse).
- **Pre-deliberated capture mode** (Step 2) — "I've worked it out" vs "interview me," the
  low-risk cadence change that touches *how* answers are gathered, not *which* questions.
- **Mandatory reversibility check + premortem** (new Step 8) — reversibility (two-way vs
  one-way door) recorded in the ADR header, paired with a premortem whose depth **scales
  with reversibility** (inline for two-way, off-context subagent for one-way). This is the
  one place the conversation's hard-won signal — *reversibility, not self-rated stakes* —
  routes depth. Decision-support, never a gate.

Deliberately **not** shipped: question-count tiering, a stakes classifier, the piggybacked
signal-detection layer, a depth stamp. Those failed the premortems below and remain parked.

## Recommendation (and what was chosen)

**The bar to touch `/g-adr` was deliberately high**: it fires rarely, is never a gate, the
evidence was a single field report, and every error asymmetry favors restraint. The skill's
load-bearing engineering (the off-context deliberation subagent, the §A7 reset loop) was
never the complaint — the debate was entirely about the capture surface.

**Within that, the light touch was chosen and shipped** (see "What shipped"):

- The **pre-deliberated capture mode** — cadence change, not a question change.
- A **mandatory reversibility check + premortem**, with reversibility (the one signal that
  survived all three premortems) scaling the premortem's depth. `Assumptions` stays
  unconditional; nothing gates; the seven questions are untouched.

A future option still on the table if friction recurs: let the *depth of each answer* scale
with stakes (one sentence per section for a contained change, full treatment for a Pillar) —
same questions, scaled answers.

**Explicitly not built** — the heavy version (a stakes classifier, a piggybacked
signal-detection layer, conditional templates, a depth stamp). Each failed a premortem.
If it is ever revisited, it must ship whole or not at all (see Known Risks).

## What we learned

The most valuable output of the whole exercise — the reasoning future-you needs to
avoid reopening it:

1. **The same flaw appeared three times in disguise: every stakes-router was strongest
   where help was least needed, weakest where it was most needed.**
   - Routing on self-reported stakes → self-report is most wrong on the biggest decisions.
   - Routing on a `/g-blast-radius` crawl → works on existing code, blind on greenfield,
     and greenfield is the Pillar case.
   - Routing on piggybacked pipeline signals → live inside full-tier machinery, dark on
     the casual/light path, which is exactly where the report's user was.
   - **A router built on a *convenient* signal inherits that signal's blind spot, and the
     blind spot lands on the high-stakes edge case by construction.** The corrective each
     time converged on one signal: **reversibility** — cheap, observable, tier-independent,
     greenfield-valid. It survived all three premortems.

2. **Self-assessment of stakes is the unreliable primitive, and it keeps sneaking back in**
   (banned as "how big is this?", it returned as "will this edit the brief?" and "is this
   just a brief row?"). Ask about *properties of the decision* (is it reversible? are you
   certain?) — never *predictions of its impact*. A property is an observation; an
   impact-prediction is introspection, and introspection is where the bias lives.

3. **Frequency-before-friction.** The most decision-relevant fact — `/g-adr` fires rarely
   and is never gated (it is not in the auto-trigger loop; it is only prompted at milestone
   close) — came from the wiring research, and late. Establish how often a thing runs before
   optimizing its per-run cost. We were optimizing the page layout before checking the print
   volume.

4. **Mitigations have their own premortems; complexity is conserved.** Each fix
   (tool-grounding, a floor, a stamp) introduced a failure worse than the one it patched,
   and the net drifted toward the *worst-of-both* attractor — tiering's machinery plus
   fixed-7's friction, for a ~2-question saving.

5. **The error asymmetry is the compass.** Under-capture (a missed ADR) is recoverable —
   write it later; the brief row holds the headline. Over-capture (forced ADRs, gating)
   pollutes permanently — a noisy corpus buries the few that matter. Every arrow points the
   same way: **do less, fail open, never gate.**

6. **The lightest "ADR" is a category error — it already exists.** The "just a logged note"
   tier is a row in `g-docs/project_brief.md`'s tech-decisions table, not a thin ADR. Don't build a
   second home for something already housed.

7. **Research reframes the problem; premortems stress the solution — both were needed.**
   The step-back research moved the goalposts (brief-row, rarity, the artifact-vs-doctrine
   split) more than any premortem; the premortems then killed each candidate solution.

## If ever implemented: the model (floor over enrichment)

This is the *shape* a light-touch implementation would take — recorded so it's not
re-derived, not endorsed for building now.

**Front door:** *Is this an ADR, or a brief row?* The lightest case is a tech-decisions
entry, not a lightweight ADR.

**Core capture (default floor for any ADR):**
- Probe (always): Decision · Context.
- Core (always): Consequences · Assumptions · Status. `Assumptions` is **unconditional** —
  its value is surfacing risks nobody flagged, so a conditional trigger is self-defeating.

**Routing floor — tier-independent, always asked (the load-bearing signals):**
- **Reversibility** — "could you undo this in a day, or does other code/data commit to it?"
- **Uncertainty** — "confident, or still unsure?" Uncertainty *escalates* depth; confidence
  never shortcuts it. Self-report used only in the safe direction.
- These are the floor because they are the only signals available on *every* path,
  regardless of tier or whether a `g-docs/project_brief.md` exists.

**Deepen (pull in Alternatives · Constraints) when the floor — or an enrichment signal —
says the fork is real.**

**Enrichment signals (precision only when the pipeline already ran — never the base):**

| Signal | Source (piggyback, no new patrol) |
|--------|-----------------------------------|
| Supersedes / conflicts with an in-force ADR | one grep of `g-docs/decisions/` at ADR start |
| Forces an edit to `g-docs/project_brief.md` (Pillar) | cheap check at ADR start; `/g-align` at close |
| Inside a premortem-flagged high-risk milestone | existing `/g-forecast` output |
| One-way door (new dep / contract / schema) | `dependency-auditor`, `spec-writer` (already in `/g-plan`) |
| Project-wide pattern / precedent | `code-reviewer` (already flags this) |
| An ADR's work keeps failing | `/g-retro` / journal at milestone close |

> **Emphasis correction (premortem 3):** these signals are *enrichment*, not the base.
> Four of the six only fire inside the full-tier pipeline and go dark on the casual/light
> path — so depth-detection cannot rest on them. The reversibility + uncertainty floor is
> what makes routing work everywhere.

## Weight budget — "piggyback, don't patrol"

If built: the detection layer must be cheaper than fixed-7 or it defeats itself.
No new background scanner, no per-commit ADR surveillance — enrichment signals only ride
on skills that already run, or are a single cheap check at ADR start. Fail toward shallow:
a missed deep ADR is recoverable; an overwhelming watch gets the plugin dropped as heavy.

## Known risks if implemented (premortem 3)

- **Pipeline coupling** — enrichment signals dark on the casual/light/standalone path
  (mitigated by the reversibility+uncertainty floor).
- **Rarely-walked deepen path rots** — two code paths drift; the deep branch (rare) carries
  latent bugs fixed-7's single path never has.
- **Front-door under-capture leak** — "this is just a brief row" can downgrade a decision
  that deserved an ADR, losing the rationale.
- **Unpredictability erodes trust** — a command that asks 3 things sometimes and 5 others,
  on invisible signals, can *feel* heavier even when lighter on average.
- **Partial-implementation hazard** — shipping the cheap detection half without the
  expensive correctness half (conditional subagent + template) yields a router that detects
  but mis-produces. Whole or not at all.

## Explicitly NOT doing

- No tiering of question count by self-rated stakes.
- No fresh `/g-blast-radius` crawl at ADR time (cost + greenfield-blind).
- No background ADR watcher / per-commit surveillance.
- No gate — `/g-adr` stays prompted/recommended, never blocking. Over-enforcement causes
  corpus pollution, which is worse than under-use.
- No lightweight-ADR mode — the light case is a brief row, which already exists.

## Trigger to revisit

A second or third independent report describing the *same* friction — especially the
from-scratch-interview friction over pre-deliberated answers, not the question count.
One report is a signal; a pattern beats the leave-it-alone asymmetry.
