# Forecast: M48 — Review-Pipeline Hardening (fix-loop killers)

> Created: 2026-08-19
> Plan: g-docs/plans/.pending-forecast.md (pre-approval handoff; saved as m48-review-pipeline-hardening.md on approval)
> Mode: regular

## Complexity
- Score: 9/10
- Breakdown: files 3 (17 distinct paths), waves 2 (6 waves), boundaries 2 (skills ↔ tests ↔ hooks/lib), new surface 1 (tests/run-all.sh runner + 3 new suites, no new public API), rule edits 1 (G-RULES §H)
- Blast-radius adjustment: none (no g-docs/blast-radius/m48 file)

## Miss-risk: 95% — High

Formula: 10 + 9×3 + min-capped top-3 contribution (16+12+12)×1.5 = 95 (clamped ceiling).
Calibration caveat (recorded standing feedback): the miss-risk number has read high/static across recent forecasts and risks alarm fatigue. The mechanism here is visible: the corpus is dense with exactly the failure classes this plan touches — which is also why M48 exists. The score says "this surface has bitten before," not "the plan is malformed."

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | Fix pass mints the next defect — count/enumeration edits (CLAUDE.md suite table, new suite totals) introduce fresh false claims during fix rounds | 4 | 4 | 16 | Every count re-summed from run Results lines in the same turn (ADR-013); reviewer round N+1 scoped to only the sites round N changed | 2026-08-18-adr-013-derive.md, ec9bf8a 9-round pass, doc-reviewer memory (enumeration-fix-introduces-new-enumerations) |
| 2 | Confabulated suite totals — a runner or agent attests a total disagreeing with its own per-suite table (4 prior occurrences) | 4 | 3 | 12 | Suite verification runs DIRECT (this milestone's own task 5), not via agent; HQ sums the per-suite table independently before accepting any total | todo task 9; CLAUDE.md three prior occurrences |
| 3 | Unscoped review blowup — the M48 review gate re-derives the whole repo, costing hours/rounds | 3 | 4 | 12 | Scope the /g-review dispatch by exclusion: name changed files, declare the attested baseline off-limits, forbid suite re-runs and architecture re-derivation | 2026-08-17-m50-scope-and-scoped-review.md; todo task 11 (three-project pattern) |
| 4 | New fast timing bounds too tight on MSYS — the ~2s override plus fork overhead breaches an author-time bound, flaky red | 3 | 3 | 9 | Author generous per the architecture rule (≥2× worst observed under the override, named *_MS constant, WHY comment); tighten on evidence only | GUARD_WINDOW_MS 8000→20000 history (architecture profile note) |
| 5 | Parallel/reordered runner flaky on MSYS — run-all.sh parallelism collides with the 4 literal `< <(sleep 300)` sleeper sites (9 runtime spawns — the class-split site loops six hooks through one fixture) or mktemp fixtures | 3 | 3 | 9 | run-all.sh must prove identical totals vs serial before adoption (its own done condition); reorder-first, parallelise only if totals hold; sleeper-reaping rider noted | audit-7 §6 sleep-leak rider; todo task 7 remainder |

## Recommendations

Re-scope before approving. Cut the highest-impact items or move to a follow-up milestone.
(Advisory. PM note: the plan already carries the top-3 mitigations as done conditions — direct suite execution, re-sum-from-output, scoped review — because M48's scope IS the fix for scenarios 1–3. Developer approval is authoritative.)

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | | |
| 2 | yes | | |
| 3 | yes | | |
| 4 | yes | | |
| 5 | yes | | |
