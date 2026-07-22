# Forecast: M-audit W2 — shim retirement (ADR-007) + conformance + residuals

> Created: 2026-07-22
> Plan: g-docs/plans/m-audit-w2-shim-retirement-conformance.md
> Mode: regular
> ⚠ Calibration caveat (standing, per 2026-07-18 developer feedback): the formula has never produced <50% on this repo (9 forecasts on record, 55–90%) — read the number as *relative* risk vs prior slices, not absolute probability. Risk here is scored on the CHANGE surface (files-to-change complexity), information not paranoia. This plan's structural driver is breadth (~70 files incl. 38 deletions), not depth — most tasks are mechanical.

## Complexity
- Score: 9/10
- Breakdown: files 3 (~70 distinct incl. 38 deletions), waves 2 (6 waves), boundaries 2 (commands↔skills↔agents↔hooks↔profiles), new surface 1 (g-help catch; bare-alias surface *removed*), rule edits 1 (architecture rule rewritten)
- No blast-radius file — no adjustment.

## Miss-risk: 85% — High
`10 + 9×3 + (18 + 18 + 13.5) = 86.5 → 85%`. Structural drivers: file breadth + the plan edits the live gate's own lib (source-only — see scenario 1 mitigation) + architecture-rule rewrite. Discriminator check: W1.5c (clean mechanical slice) scored 55; this is genuinely wider.

## Estimated token cost: 78k–235k (Large)
17 agent dispatches × 4k + ~5,600 diff lines × 4 + review overhead 40k = ~130k midpoint.

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | Live commit gate false-fires on legitimate task writes (heredoc/commit-phrase class — the very bug task 19 fixes); worst case: gate-self-modification confusion while editing commit-detect.sh | 4 | 3 | 12 | Task 19 edits SOURCE only — installed gating pair untouched this wave (gating installs are deliberate clone-first checkpoints per ADR-008 §2); agents write reports via Write tool, never bash heredocs; probe-hygiene rule stands | W1.5e retro, W1.7ii ledger (3 live incidents) |
| 2 | doc-writer child overreach — retro-edits shipped records during the Wave-3 docs sweep | 3 | 4 | 12 | doc-writer scoped to teaching docs ONLY (explicit file list in prompt); wave-close integrity check diffs FULL files against git, never spot-checks (W1.5e CHANGELOG-archaeology lesson) | 2026-07-18-w15cd retro, W1.5d ledger |
| 3 | Shim deletion leaves a live reference dangling (README command counts, g-doctor text, test fixture, CLAUDE.md) — docs/validators contradict the repo | 3 | 3 | 9 | Task 5 done condition = repo-wide grep excluding historical records; task 9 re-enumerates after amendments; task 16 walkthrough is the catch-net | W1.4 count-drift (doc gate caught ×2) |
| 4 | Consolidated Wave-3 slot (6+7+12) killed by session limit mid-run | 3 | 2 | 6 | Resume-to-completion pattern (W1.7 Wave-1 precedent — resumed, not redeployed, no thrash) | 2026-07-21h handoff |
| 5 | New test pins drift header-vs-runner counts | 2 | 2 | 4 | Attestation compares header vs runner independently (W1.6 r2 methodology — the fix that made M3 visible) | W1.6i ledger |

## Recommendations

High (≥75%) — strongly consider re-scoping before approval. Concretely: the pass-split at wave boundaries (recommended in the plan) IS the re-scope — each pass lands in a fresh session inside budget, the same mechanism that carried W1.5g/W1.6/W1.7 at 75–90% forecasts to clean closes. Apply mitigations 1–2 verbatim in wave prompts.

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | | |
| 2 | yes | | |
| 3 | yes | | |
| 4 | yes | | |
| 5 | yes | | |
