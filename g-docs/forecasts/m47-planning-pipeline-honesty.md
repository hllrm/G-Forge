# Forecast: M47 — Planning-Pipeline Honesty (decomposer + calibration)

> Created: 2026-08-12
> Plan: g-docs/plans/m47-planning-pipeline-honesty.md
> Mode: regular

## Complexity
- Score: 5/10
- Breakdown: files 3 (6 distinct), waves 1 (2 waves), boundaries 1 (agent ↔ skill contract seam), new surface 0, rule edits 0

## Miss-risk: 70% — Elevated

> Caveat: this number comes from the exact uncalibrated Step 6 formula M47 tasks 4–5 exist to replace. Three scenario scores of 9–12 push scenario_contribution to 45 points on a 6-file prose-edit milestone — the "reads high, gets ignored" complaint, demonstrated on its own fix. Treat the ranked scenarios as the real signal; the percentage is the before-picture.

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | Partial-enumeration fix: a formula/number restatement site is missed (Step 3c has ≥3 literal restatements + README:625; more may exist unenumerated) | 4 | 3 | 12 | Pre-execution repo-wide grep for the OLD formula string to enumerate ALL sites, hand executor the complete list; post-fix grep for what should be GONE, not the replacement | 2026-08-11 audit (stale cross-refs ×4, partial-enum ×3), retro 2026-07-26 ("a fix list is not a blast radius") |
| 2 | Fix-loop mints the next defect across review rounds | 3 | 3 | 9 | Apply M48's grep-the-literal-fact sweep manually at each review round; derive every count/number in written text from ground truth before writing | ec8a pass (9 rounds, 7 new defects, 2 after clean verdicts — ROADMAP:526), keyline §1 |
| 3 | Wave-1 parallel-writer file collision / scope overreach in the shared tree | 3 | 3 | 9 | Hard scope boundaries in each dispatch (files NOT to touch); on any overreach, full-file diff against git for every touched file, never spot-revert | retros 2026-07-16-w13 (doc-writer clobbered sibling hooks), 2026-07-19-adr007-w15e (overreach class, 2nd data point) |
| 4 | Calibration lands but the number is still effectively static (a smarter constant) | 2 | 4 | 8 | Done condition enforced at review: demonstrate the number MOVES against two different corpus states (e.g. with/without unverified rows) | M47 premortem (ROADMAP:517), standing developer complaint |
| 5 | Decomposer seam change ripples to wave-planner / g-execute consumers | 2 | 4 | 8 | Additive-only contract enforced by task 2's done condition (field names/values byte-unchanged); diff review greps for renamed/removed fields | M47 premortem (ROADMAP:516) |

## Recommendations

Apply at least the top-2 mitigations before approving. Consider splitting the largest wave.
— Concretely: (1) the pre-execution old-string enumeration grep becomes part of Group B's dispatch brief; (2) the literal-fact sweep is applied at review. Wave 1's three groups are file-disjoint, so the split recommendation is already satisfied structurally; scenario 3 is mitigated by scope boundaries, not further splitting.
(Forecast assumes the historical pattern set is representative.)

## Estimated token cost
19k–57k (Medium) — 4 agent dispatches, 6 files, review overhead included.

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | | |
| 2 | yes | | |
| 3 | yes | | |
| 4 | yes | | |
| 5 | yes | | |
