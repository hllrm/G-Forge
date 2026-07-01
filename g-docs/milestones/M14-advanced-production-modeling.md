# M14 — Advanced Production Modeling

**Status:** ✅ Complete
**Version:** v0.15.0
**Branch:** feat/m14-advanced-production-modeling

## Goal

Give the planning layer the ability to reason about feature dependencies, costs, and long-term project trajectory. Three new capabilities: dependency intelligence (blast-radius mapping), economic reasoning (token-cost estimates folded into forecasts), and temporal project cognition (narrative project-personality synthesis from accumulated history).

## Scope

### 1 — `/g-blast-radius` — dependency intelligence

Maps the forward + reverse dependency graph for a target (file, plan, or feature label). Computes per-file volatility from recent git history. Aggregates to one of three ratings: Narrow / Moderate / Wide. Persists report to `docs/blast-radius/<slug>.md`.

**Done condition:** `skills/g-blast-radius/SKILL.md` exists with proper structure; running it produces a structured report; integration into `/g-forecast` Step 2b reads the persisted rating.

---

### 2 — Economic reasoning in `/g-forecast`

`/g-forecast` Step 2c computes a token-cost band per plan from agent-dispatch count × 4000 + diff-size estimate × 4 + review overhead. Expressed as `low – high` with size tag (Small / Medium / Large / Very Large). Surfaces in the Step 7 report alongside complexity and miss-risk. Advisory only.

**Done condition:** `/g-forecast` Step 2c present with formula and tagging; Step 7 report includes `Est. tokens: low – high (tag)` line.

---

### 3 — `/g-identity` — temporal project cognition

Synthesises the project's operational personality from accumulated retros, forecasts, telemetry, ADRs, blast-radius reports, CHANGELOG, ROADMAP, and git history. Produces a 5-section narrative (what this project is / how it ships / what it does well / where it struggles / what it's becoming) written to `docs/identity.md`. Refuses to run on a thin corpus.

**Done condition:** `skills/g-identity/SKILL.md` exists with proper structure; reads all relevant signal sources; produces narrative-form output (not metric tables); never prescribes — only describes.

---

## Done Conditions (milestone)

- [x] `skills/g-blast-radius/SKILL.md` with frontmatter, Announce, Steps 1–7, Rules
- [x] `commands/g-blast-radius.md` router
- [x] `skills/g-identity/SKILL.md` with frontmatter, Announce, Steps 1–5, Rules
- [x] `commands/g-identity.md` router
- [x] `/g-blast-radius` and `/g-identity` registered in `commands/g-team.md` and `G-RULES.md` §B
- [x] `/g-forecast` Step 2b (blast-radius integration) added
- [x] `/g-forecast` Step 2c (economic reasoning) added
- [x] `/g-forecast` Step 7 report updated to include both new lines
- [x] `plugin.json` and `marketplace.json` at v0.15.0; skill count 28
- [x] CHANGELOG `[0.15.0]` entry added
- [x] README skill list, count, and roadmap table reflect M14
- [x] M14 marked ✅ Complete in ROADMAP.md

## Tier 3 DoD

Developer runs `/g-blast-radius skills/g-plan` on this repo. The skill produces a Moderate-or-narrower rating with a populated reverse-dependency list (other skills that reference g-plan).

Developer runs `/g-identity` on this repo. The skill produces a 5-section narrative covering this project's operational personality, written to `docs/identity.md`.

Developer runs `/g-forecast m14-advanced-production-modeling` (or any plan slug). The Step 7 report now includes both `Est. tokens:` and (when `docs/blast-radius/<slug>.md` exists) a `+ blast-radius adjustment` annotation on the complexity score.

## Depends on

M10 (`/g-patterns` corpus + sentinel filter), M11 (`/g-forecast` + outcomes), M12 (telemetry snapshots), M13 (independent — slots here as pre-shipping closer).
