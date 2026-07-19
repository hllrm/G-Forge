# Forecast: M-audit W1.5f — guard-idiom normalization + terminal attestation

> Created: 2026-07-19
> Plan: g-docs/plans/w1-5f-guard-idiom-normalization.md (pending approval at forecast time)
> Mode: regular
> Calibration caveat (standing, per the 2026-07-18 developer feedback): miss-risk is scored on the CHANGE — a shared-guard consolidation across the six live enforcement hooks — not on project complexity. The number is information, not paranoia: 65% here vs 55% (W1.5c, one fixture file) and 80% (W1.5d, the gate's own parser) reflects that this slice edits six behavior-bearing hooks at once but under a heavier test pin than W1.5d had.

## Complexity
- Score: 6/10
- Breakdown: files 3 (8 distinct), waves 2 (4 waves), boundaries 0 (all hook-layer + its tests), new surface 1 (one new shared lib function), rule edits 0

## Miss-risk: 65% — Elevated

Est. tokens: 30k–91k (Medium)

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | Behavior drift hidden in "behavior-preserving" consolidation — variant differences (Variant A's redundant git-tree probe removed; canonical function requires PRIMARY GATED; stderr-suppression differences) change an edge case in a live enforcement hook | 3 | 3 | 9 | Task-1 implementer must diff the decision matrix per hook BEFORE editing (enumerate each variant's proceed/exit conditions vs the canonical function's three cases); review gate verifies the primary-gated claim per hook; suite green before AND after each wave | M-audit ledger 8i+9i+10i+21i (W1.2 r1 HOLD — stamp truncation), retros/2026-07-18-w15cd (sandwich discipline rationale) |
| 2 | Context-budget overrun → mid-plan handoff (est. ~36 exchanges vs ~31 remaining) | 3 | 3 | 9 | Waves 1–2 are the bulk; keep dispatch prompts terse; if depth hits red before Wave 3, hand off at the wave boundary with the plan file as the resume point (W1.5 split precedent) | retros/2026-07-16-w13 (review deferred at §A7 floor), ROADMAP W1.5 split rationale |
| 3 | Parallel-wave scope overreach — 3 agents editing 6 hook files in Wave 2 | 2 | 4 | 8 | Structural mitigations now in place (agent-file scope rule applied 2026-07-19; no-child-dispatch line in every Wave-2 prompt; wave-close full-file integrity diff per the new §C recovery rule) | retros/2026-07-18-w15cd, retros/2026-07-19-adr007-w15e, forecasts/w1-5d §3 (predicted-and-hit) |
| 4 | Terminal attestation dispatch killed by session limit (3rd occurrence) | 3 | 2 | 6 | Schedule Wave 4 while headroom remains; HQ-direct fallback is the established precedent (W1.5a, W1.5e) — budget for it | retros/2026-07-19-adr007-w15e |
| 5 | #21-class gate false-positive blocks an agent's probe/write quoting commit phrases | 3 | 2 | 6 | Script-file probes + path-free messages (W1.5c mitigation set); HQ persists any denied report per W1.5e precedent | retros/2026-07-13, 2026-07-16-w13, 2026-07-19 (new heredoc form) |

## Recommendations

Elevated — apply at least the top-2 mitigations before approving. Top-1 is folded into Task 1's dispatch contract (decision-matrix diff before edit); top-2 is a session-management commitment (terse dispatches, wave-boundary handoff if red). No split recommended: the 4-wave shape is already minimal, and the tight budget is the argument for executing now with fresh headroom rather than splitting a 7-task slice.

Forecast assumes the historical pattern set is representative.

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | | |
| 2 | yes | | |
| 3 | yes | | |
| 4 | yes | | |
| 5 | yes | | |
