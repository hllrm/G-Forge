# Forecast: M-audit W1.4 — Install wiring + drift detection

> Created: 2026-07-17
> Plan: g-docs/plans/.pending-forecast.md (pre-approval handoff; saved as g-docs/plans/w1-4-install-wiring-drift-detection.md on approval)
> Mode: regular

## Complexity
- Score: 4/10
- Breakdown: files 2 (5 distinct), waves 0 (single wave), boundaries 1 (skills ↔ hooks/tests), new surface 1 (new install target: git-hooks-path pre-commit), rule edits 0
- No blast-radius file — no adjustment applied.

## Estimated token cost: 19k–57k (Medium)
(4 dispatches × 4000 + 400 diff-lines × 4 + 14000 review overhead = ~31.6k midpoint)

## Miss-risk: 65% — Elevated
(10 + 4×3 + min-capped top-3 scenario contribution 42; heuristic — assumes the historical pattern set is representative. Note the set currently overweights one Systemic pattern whose fix is designed but unbuilt.)

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | parallel-agent-file-collision — a wave agent runs a tree-global op (stash/reset/checkout/rm) and clobbers a sibling's file; ADR-006 absorber designed but NOT yet implemented, so this wave runs unprotected | 3 | 4 | 12 | Prompt every agent with the NEEDS_GLOBAL rule (never run tree-global git ops; return the need to HQ); HQ snapshots `git status` + `git stash list` at wave open and diffs each unit's files at wave close before review | retros/2026-07-16-w13-verify-gproof-rebrand.md · forecasts/w1-3 §4 · patterns-deferred.md (Systemic) |
| 2 | stale count/list drift — "seven hooks" prose lives in more places than the 3 scoped SKILL files (README, commands/, CLAUDE.md rules, finding #19's 3-place descriptions); plan fixes only the scoped files and ships a contradiction | 4 | 2 | 8 | At wave close, grep repo-wide for `seven hook`/`7 hooks`/hook-count strings and reconcile every hit (or route to doc gate explicitly) | retros/2026-05-19-m10-m14 (stale triple-list, M13) · finding #19 · today's CHANGELOG doc-gate catch |
| 3 | commit-gate self-modification regression — task 9 edits a gate-adjacent hook; a regression fails the enforcement layer open | 2 | 4 | 8 | Fail-before/pass-after assertion is in-plan; additionally run the FULL 60-test suite at wave close, not just test-post-commit-cleanup.sh | forecasts/m-audit-w1-enforcement-fixes.md (scenario #1, fired 2026-07-06 and was caught) |
| 4 | phantom findings from stale mid-wave reads — verification reads a file while a sibling is mid-write and reports false bugs | 2 | 3 | 6 | All verification happens after every agent has stopped; any anomaly is re-checked once from the settled tree before being treated as real | retros/2026-07-16-adr-006-optimistic-waves.md (W1.3 phantom W2/W3/W6) |
| 5 | mixed-commit doc-gate loop — W1.4's commit is mixed (skills+hooks+tests); missing CHANGELOG/doc currency forces a HOLD-fix-rerun loop | 3 | 2 | 6 | Run /g-doc-review proactively before the commit attempt; draft the CHANGELOG [Unreleased] W1.4 bullet as part of close-out | live this session (W1.3 commit denied; DOCS HOLD on missing CHANGELOG entry) · retros/2026-05-19-m10-m14 (doc currency found late, 3 of 5 milestones) |

## Recommendations

Apply at least the top-2 mitigations before approving. Consider splitting the largest wave.
— Concretely: both top-2 mitigations are cheap and folded into execution (agent-prompt rule + wave-open/close snapshot; wave-close count grep). The single wave is already minimal (4 file-disjoint units); no split warranted. Scenario 3's mitigation is already in-plan via task 9's test pin; run the full suite at close regardless.

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | | |
| 2 | yes | | |
| 3 | yes | | |
| 4 | yes | | |
| 5 | yes | | |
