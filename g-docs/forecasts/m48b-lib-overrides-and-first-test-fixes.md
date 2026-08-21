# Forecast: M48b — Lib overrides & first test fixes

> Created: 2026-08-20
> Plan: g-docs/plans/.pending-forecast.md (pre-approval handoff; saved as m48b-lib-overrides-and-first-test-fixes.md on approval)
> Mode: regular

## Complexity
- Score: 7/10
- Breakdown: files 3 (6 distinct), waves 2 (4 waves), boundaries 1 (test suites derive from skill/hook-layer sources), new surface 1 (env override + test constant), rule edits 0
- No blast-radius file — no adjustment applied

## Miss-risk: 75% — Elevated

Formula: 10 + 7×3 + min(12,15)×1.5 + min(12,15)×1.5 + min(6,15)×1.5 = 76 → rounded 75.
Calibration note (standing developer feedback): this gauge reads high and near-static across plans and is at risk of alarm fatigue; the informative part is the ranked scenarios, not the percentage. Forecast assumes the historical pattern set is representative.

## Estimated token cost: 26k–79k (Medium)

6 agent dispatches × 4k + 480 diff-lines × 4 + (6000 + 2000×6) review overhead ≈ 44k midpoint.

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | Fix/hardening pass mints the next defect — new prose claims (falsifiability comments, file:line refs in done conditions) go stale or wrong in the same pass | 4 | 3 | 12 | Every literal a task writes gets grepped the same turn it lands, CHANGELOG included; falsifiability comments carry no line numbers, only mechanism | retros 2026-08-15 (patterns-resolve), 2026-08-18 (adr-013), 2026-08-20 (m48a — scenario 1 hit in both forecasts) |
| 2 | Grep-pin is the wrong instrument for the claim — assertion greens on a pattern that doesn't pin what matters (the F4 class this milestone fixes, reproduced in its own fix) | 3 | 4 | 12 | Each new pin proven red in a scratch copy BEFORE recorded green (the falsifiability rule is the mitigation — enforce it as a done condition, which the plan does); prefer simulating the consumer's parse over counting lines | retros 2026-08-15 (grep -c false green), 2026-08-17 (mechanical check verifies wrong claim) |
| 3 | Attestation run invalidated — Wave 4 suite run started before every edit (incl. CHANGELOG/comment prose) is landed, or an edit lands mid-run | 3 | 2 | 6 | Wave 4 starts only after Wave 3 is committed-quiet; nothing edits during the run | retro 2026-08-20 (comment edit killed a running script) |
| 4 | Implementer agent yields silently mid-task on its scratch-copy red-run and needs a resume nudge | 3 | 2 | 6 | Budget one resume round-trip per implementer whose task includes shell runs; Interrupted ≠ FAILED — resume, never redeploy | retro 2026-08-19 (run-all agent silent stop) |
| 5 | Stale sibling literal survives — per-suite counts restated in tests/README, CLAUDE.md quick-commands table (local), or the CHANGELOG entry itself drift against the new Results lines | 3 | 2 | 6 | Task 10 includes a grep for the old per-suite counts of the three touched suites across tests/README.md and CHANGELOG.md; CLAUDE.md is local-only, already a named carry | retros 2026-08-20 (CHANGELOG is a carrier too — missed twice), 2026-08-15 (six-site sweep) |

## Recommendations

Apply at least the top-2 mitigations before approving. Consider splitting the largest wave.
— Top-2 are already structural in the plan: same-turn grep of every landed literal (task done conditions) and scratch-copy red-proof before green (falsifiability rule as done condition). Wave 1's four parallel slots are on four disjoint files; splitting it would add wall-clock for no risk reduction — flagged, not recommended.

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | yes | 4 consecutive fix rounds each minted a defect at a site the round edited (guard-literal republish, enumeration counts). The dominant failure of the pass. |
| 2 | yes | partial | The grep-pins themselves held (scratch-proven), but the wave's empty-override assertion shipped inert for its named regression — caught by code-lead r1, re-proven with a discriminating 4500ms bound. |
| 3 | yes | partial | No mid-run edit invalidation, but the first two attestation attempts were killed by the Bash tool's 10-min ceiling; fixed with detached run + Monitor. |
| 4 | yes | yes | Three record-write stalls (task 5+6 wave agent, doc-writer, doc-fixer); one SendMessage resume each. |
| 5 | yes | yes | Stale sibling counts were most of doc r1's 14 blockers (tests/README 575, CHANGELOG 41, CLAUDE.md date, build-order sites x6). |
