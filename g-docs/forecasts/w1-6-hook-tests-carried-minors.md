# Forecast: W1.6 — Remaining Hook Tests + Carried Minors

> Created: 2026-07-21
> Plan: g-docs/plans/w1-6-hook-tests-carried-minors.md (pending approval at forecast time)
> Mode: regular
> ⚠ Standing calibration caveat (2026-07-18 developer feedback): every forecast on record reads 55–90% — treat the scenarios as the information, not the percentage. Risk here is scored on the CHANGE (20 files, mostly test-layer, no gating-hook edits), not project complexity.

## Complexity
- Score: 6/10
- Breakdown: files 3 (~20 distinct), waves 2 (7 waves), boundaries 1 (hooks↔tests via task 15), new surface 0 (new files are internal test suites), rule edits 0

## Estimated token cost: 65k–195k (Medium)

## Miss-risk: 75% — Elevated

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | First-attestation red on the 4 new suites — test-writer cannot run what it writes, and the invocation-form/path-resolution class just bit W1.5g (24/26 fail under relative invocation) | 4 | 3 | 12 | Task prompts pin the absolute-once-at-top pattern + canonical repo-root invocation; Wave 3 batch attestation is the hard gate before Pass 1 closes; expect a fix loop, budget for it | 2026-07-21-w15g-pass1.md; #20 doctrine (multiple retros) |
| 2 | Latent hook bugs surfaced by first-ever suites — session-start/pre-compact/workflow-checkpoint have NEVER had behavioral tests; documented vs actual behavior may diverge (tier matrix, counters, thresholds) | 3 | 3 | 9 | Standing rule: divergences route as findings for a developer fix-in-slice vs W1.7 call — never silently absorbed into the test to make it green; suite asserts ACTUAL behavior only after HQ adjudicates | w15b riders precedent; 2026-07-19-dogfood-gap ("shipped vs live conflated") |
| 3 | Budget overrun mid-Pass-2 → unplanned handoff (est. 81 exchanges total; Pass 2 ≈45 vs ~40 fresh-session budget) | 3 | 3 | 9 | Planned pass boundaries at Waves 3/6; Wave 6 explicitly slides to Pass 3 if the session runs hot; §A7 capacity check at every wave close | W1.5 split history; W1.5g approved-split precedent |
| 4 | Agent overreach / parallel collision in the 6-slot Wave 4 (largest parallel wave of the milestone; doc-writer-child class observed 2×) | 3 | 3 | 9 | Hard no-child-dispatch line in Wave-4 prompts; wave-close integrity via full git status diff; on any overreach full-file diff, never spot-revert | 2026-07-18-w15cd + 2026-07-19-adr007-w15e retros |
| 5 | Session-limit kill on the batched attestation dispatches (Waves 3 and 7 — long g-forge-dev runs died 3× in W1.5a/e/f) | 4 | 2 | 8 | HQ-run fallback per W1.5a precedent; resume killed agents via SendMessage, never redeploy; keep attestation dispatches early in fresh windows | 2026-07-19-adr007-w15e ("2nd occurrence"), w15f handoff (3rd) |

## Recommendations

Elevated — apply at least the top-2 mitigations before approving. Consider splitting the largest wave. Concretely for this plan: (1) the invocation-form pin + Wave-3 attestation gate are already structural — keep them; (2) pre-agree the scenario-2 protocol (bug found in an untested hook = finding, developer decides fix-in-slice vs defer) so Wave 1 doesn't stall on the first divergence. The pass split already absorbs scenario 3. Forecast assumes the historical pattern set is representative.

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | | |
| 2 | yes | | |
| 3 | yes | | |
| 4 | yes | | |
| 5 | yes | | |
