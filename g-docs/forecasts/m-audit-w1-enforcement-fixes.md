# Forecast: M-audit-2026-07 Wave 1 — Enforcement Integrity Fixes (Sub-plan A)

> Created: 2026-07-06
> Plan: g-docs/plans/m-audit-w1-enforcement-fixes.md
> Mode: regular

## Complexity
- Score: 7/10
- Breakdown: files 8 (3), waves 5 (2), boundaries skill↔hook (1), new surface — new required check + 2 new test suites (1), rule edits 0

## Miss-risk: 90% — High

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | check-commit.sh self-modification regression — a bug in the -C/-c or -a/pathspec hardening fails the commit gate OPEN (stops blocking) or over-blocks legit commits | 3 | 5 | 15 | Every fix ships a fail-before/pass-after pinning test; run full tests/test-check-commit.sh after each check-commit.sh edit; explicitly re-verify bare `git commit` still blocks AND normal/amend still passes (no over-block) | plan surface + Bug A history (v2.2.1 commit-gate no-op) |
| 2 | g-doctor renumbering / count-string drift — advisory 16–20→17–21 and count 20→22 / N/15→N/16 leaves stale references elsewhere | 4 | 3 | 12 | After Tasks 2–3, grep the whole repo (README, CHANGELOG, commands/g-doctor.md, g-wiki) for /g-doctor check-number and count references; reconcile all | m10-m14 retro (stale-list-sync, doc-currency ×2) |
| 3 | wave-split mid-plan handoff — 5 waves over the ~40 budget ceiling forces an incomplete-wave stop | 4 | 3 | 12 | A/B split already applied; if red hits, /g-execute pauses at a wave boundary and /g-resume picks up cleanly | plan surface + budget check |
| 4 | concurrent multi-session collision on main — executing directly on main risks colliding with another session / dirtying main | 2 | 3 | 6 | Create a feature branch (e.g. fix/m-audit-w1-enforcement) before /g-execute; git fetch + check origin/main divergence first | m27 retro |
| 5 | portable hash cascade unverified across shells — drift check's sha256sum→shasum→cksum fallback only exercised on one utility | 2 | 2 | 4 | Fixture test asserts the comparison method actually resolves on this environment; document which utility was used | plan surface |

## Recommendations

Re-scope before approving is the nominal High-risk advice, but the A/B split has already been applied and the residual risk is concentrated in surfaces inherent to the milestone (you cannot fix the commit gate without touching the commit gate) — every top scenario has a concrete, cheap mitigation. Apply at least the top-3 mitigations before/during execution: (1) full test-check-commit.sh run after each hook edit + bare-commit re-verify, (2) repo-wide grep for g-doctor check-number/count references after renumbering, (3) work on a feature branch, not main. Proceed with those in place rather than fragmenting a coherent fix further.

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | | |
| 2 | yes | | |
| 3 | yes | | |
| 4 | yes | | |
| 5 | yes | | |
