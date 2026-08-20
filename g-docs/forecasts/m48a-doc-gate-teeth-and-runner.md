# Forecast: M48a — Doc-gate teeth & suite runner

> Created: 2026-08-19
> Plan: g-docs/plans/m48a-doc-gate-teeth-and-runner.md (written on approval)
> Mode: regular
> Parent: M48 split 2026-08-19 (see g-docs/forecasts/m48-review-pipeline-hardening.md for the family-level premortem)

## Complexity
- Score: 5/10
- Breakdown: files 2 (4 distinct paths), waves 0 (1 wave), boundaries 1 (skills/agents/rules + tests), new surface 1 (tests/run-all.sh), rule edits 1 (G-RULES §H)

## Miss-risk: 75% — Elevated

Same calibration caveat as the parent forecast: the corpus is dense with the classes this family touches; the number reflects surface history, not plan quality. Top mitigations are baked into done conditions.

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | Fix pass mints next defect in the two doc edits (skill step renumbering, rule wording) | 3 | 4 | 12 | Additive-only edits; round-2 review scoped to only round-1's changed sites | 2026-08-18-adr-013-derive.md; ec9bf8a |
| 2 | Review of this sub blows up unscoped | 3 | 4 | 12 | Dispatch /g-review scoped by exclusion: 4 named files, attested baseline off-limits | 2026-08-17 retro; todo task 11 |
| 3 | run-all.sh parallelism flaky on MSYS (4 literal `< <(sleep 300)` sleeper sites, 9 runtime spawns — the class-split site loops six hooks through one fixture) | 3 | 3 | 9 | Done condition requires identical totals vs serial; reorder-first, parallelise only if totals hold | audit-7 §6 |

## Recommendations

Apply at least the top-2 mitigations before approving (both already encoded as done conditions / dispatch rules). Consider nothing further — smallest sub of the family.

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | **YES** | Hit twice: code re-review found 4 new Majors minted by the fix wave (leaked scratch file, M1 mechanism reintroduced in its own test, gitignored-pointer README fix, refuted procedure left in ROADMAP), and doc-gate r2 found the W1 fix itself staled CHANGELOG:29. The mitigation (scope round N+1 to round N's sites) is exactly what caught them. |
| 2 | yes | **NO** | Scoping-by-exclusion held across 4 code rounds + 4 doc rounds: named files, attested baseline off-limits, no whole-repo re-derivation. Convergence 30→9→4→0. |
| 3 | yes | **NO — but the sleeper class bit anyway** | Parallelism never attempted (serial by design). The 4 sleeper sites stalled the runner through a different mechanism: command-substitution capture waits on pipe EOF, inheriting the 300s sleeper lifetimes (finding M1, probe-verified, fixed with tee-to-temp-file; 1242s → ~709-775s measured). |
