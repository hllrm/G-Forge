# Forecast: M-audit W1.5c — pre-commit gate fixtures

> Created: 2026-07-18
> Plan: g-docs/plans/w1-5c-pre-commit-gate-fixtures.md (pending approval at forecast time)
> Mode: regular

## Complexity
- Score: 2/10
- Breakdown: files 1 (single fixture file → 1), waves 2 (→ 1), boundaries 0, new surface 0, rule edits 0

## Miss-risk: 55% — Elevated

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | New deny-path coverage exposes a REAL hook bug (write-tree-failure or ambiguous-resolution arm misbehaves) → HOLD cycle or in-slice fix temptation | 3 | 3 | 9 | Standing rule pre-armed in the plan header: failing fixture + report routes to W1.6/W2, never fixed in-slice. Canary tasks (4, 5) prove the fixture reproduces the trigger state before blaming the hook. | retros/2026-07-16-w13 (W1.5a glued-chain HOLD precedent), forecasts/w1-5a |
| 2 | Fixture-construction bug (merge-conflict or separate-git-dir setup wrong) → scenario silently tests the wrong state | 4 | 2 | 8 | Both risky constructions carry independent canaries: `ls-files -u` non-empty + standalone `write-tree` non-zero (task 4); direct resolver call rc=1 + empty stdout (task 5). Reuse test-worktree-resolve.sh's proven reject construction. | retros/2026-07-16-w13 (harness printf bug), W1.5b fixture flag-order bug |
| 3 | False-green counter regression — new checks counted in a subshell → SUMMARY undercounts, suite passes vacuously | 2 | 4 | 8 | Task 6 is this mitigation: parent-shell check() placement verified + SUMMARY totals reconciled against raw PASS/FAIL line count; W1.5b canary-proof precedent. | W1.5b (handoff 2026-07-18b: Results 0/0 trap + canary proof) |
| 4 | Commit gate false-fires on probe/implementation commands containing "git commit" strings (finding #21, still live until W1.7) | 3 | 2 | 6 | Run probes from script files, not inline Bash strings; keep commit messages path-free at commit time. | retros/2026-07-16-w13, 2026-07-13-bug2 |
| 5 | Doc-gate count drift at commit time (CHANGELOG/README counts stale for the new assertion total) | 2 | 2 | 4 | Update CHANGELOG in the same pass with the exact new assertion count from the implementer's report (19 + N); doc gate re-check before stamp. | retros/2026-05-19-m10-m14, W1.4 (scenario 2 hit twice) |

## Recommendations

Elevated — apply at least the top-2 mitigations before approving. Both are already folded into the plan as explicit task content (canary sub-steps in tasks 4–5; counter-integrity as task 6), and the route-to-W1.6/W2 rule is in the plan header. No wave split needed — Wave 1 is one agent on one file.

Forecast assumes the historical pattern set is representative.

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | | |
| 2 | yes | | |
| 3 | yes | | |
| 4 | yes | | |
| 5 | yes | | |
