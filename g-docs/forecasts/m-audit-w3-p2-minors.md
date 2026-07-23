# Forecast: M-audit W3 — P2 Minors (full scope)

> Created: 2026-07-22
> Plan: g-docs/plans/m-audit-w3-p2-minors.md
> Mode: regular

## Complexity
- Score: 7/10
- Breakdown: files 3 (≥6 distinct: 7 hooks + 7 test suites + 3 skills + 1 rule + profiles), waves 2 (4 waves), boundaries 1 (hooks + skills + rules surfaces), new surface 0, rule edits 1 (rules/g-rules/H-testing.md)

## Miss-risk: 85% — High (breadth-driven — calibration caveat below)

**Calibration caveat (per the 2026-07-18 field feedback):** this number is breadth-driven — 19 independent small items across 20+ files inflate the formula's file and scenario terms. The scenarios are largely independent; one item missing its target does not sink the wave. Read it as "some rework somewhere is near-certain," not "the wave will fail." The formula assumes the historical pattern set is representative.

## Estimated token cost: 69k–206k (Large)

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | Commit-gate self-modification regression — plan edits the gate's own libs (commit-detect.sh heredoc/alias paths, classify-changeset.sh) while the installed gate runs live; a bad edit bricks or fail-opens the gate mid-wave | 4 | 4 | 16 | Fail-before/pass-after fixtures mandatory per edit; never touch installed .claude/hooks mid-session (ADR-008 cadence); rollback snapshot exists (claude-install-snapshot-2026-07-22) | m-audit-w1 forecast (scenario fired, caught); #21 live incidents 2026-07-13/19 |
| 2 | Claim-vs-whole-file recurrence #4 — characterization or "already fixed" claim made from a partial read (tasks 2/6/9 conditionals depend on honest characterization) | 4 | 3 | 12 | Whole-file read before any surface claim; verify claims vs git diff; HQ spot-checks conditional-task closures | 2026-07-22-w2-pass1 retro; W1.5e full-file-diff rule; W2 Pass 4 walkthrough catch |
| 3 | False-green suite counters — new fixtures added to 6 suites; subshell-lost counters made a suite report 0/0 exit-0 before | 2 | 4 | 8 | Parent-shell counting convention; header-vs-runner count reconcile at Wave-4 attestation; canary corrupted-copy check where practical | W1.5b (counter trap + canary proof) |
| 4 | Stale carry-over items — tasks 7–11 written from milestone one-liners; some may be already closed post-W1.5f/W1.6 (HQ probes confirm 7/10/11 live today; 9 is a re-probe by design) | 3 | 2 | 6 | Probe-first inside each slot; "re-confirmed, no change" is a valid close — do not force a diff | W1.7 phantom-bug episode; task-9 design |
| 5 | Attestation dispatch killed by session limit — happened twice | 2 | 2 | 4 | HQ runs the suite directly per W1.5a precedent if g-forge-dev dies; resume-to-completion, never redeploy | W1.5a + W1.5e handoff notes |

## Recommendations

Re-scope before approving. Cut the highest-impact items or move to a follow-up milestone.
— Overridden context: developer directive "never skip issues — fix everything"; the risk number is breadth-driven (see caveat). Operative mitigations instead of cut: (1) keep the 3-pass split (fresh session per pass); (2) fail-before/pass-after fixtures on every gate-lib edit; (3) probe-first on tasks 7–11 conditionals; (4) whole-file reads before characterization claims.

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | did not happen (git) | W3 shipped; both live gates passed on the W3 commit and on the two subsequent stdin-guard/release commits — no gate brick, no fail-open. Fail-before/pass-after held on every gate-lib edit. |
| 2 | yes | did not happen (journal) | No partial-read characterization miss in W3 tasks 2/6/9; task-1 spike was empirical (scratch-repo verified). Note: a claim-vs-DATA sibling fired at W3 Pass 3 (attestation agent's confabulated 568/650 summary, HQ-caught) — tracked as recurrence #3 for /g-patterns, distinct from this whole-file-read scenario. |
| 3 | yes | did not happen (git) | W3 attestation 468/468 with header-vs-runner MATCH everywhere; parent-shell counting convention held. |
| 4 | yes | happened — absorbed as designed (journal) | Task 9 re-confirmed no-change; task 5 adjudicated spec-asymmetry-not-bug and routed to decision (resume preserves counter). Probe-first mitigation worked; no forced diffs. |
| 5 | yes | did not happen (git) | W3 Wave-4 attestation dispatch completed (its summary confabulation is scenario-2's note, not a dispatch kill). |
