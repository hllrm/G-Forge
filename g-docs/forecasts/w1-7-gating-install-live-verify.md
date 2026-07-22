# Forecast: W1.7 — Gating-Hook Install Checkpoint + Live Verification + Ledger Close

> Created: 2026-07-21
> Plan: g-docs/plans/w1-7-gating-install-live-verify.md (pending approval at forecast time)
> Mode: regular
> ⚠ Calibration caveat (standing, per 2026-07-18 developer feedback): every forecast on record has read ≥55% — treat the percentage as a *ranking of scenarios*, not a calibrated probability. Risk here is scored on the CHANGE (first live gating install), not project complexity. The structural mitigations (clone-first hard gate, rollback snapshot, escape hatches) are already IN the plan — the number does not net them out.

## Complexity
- Score: 7/10
- Breakdown: files 3 (≥6 distinct), waves 2 (12 waves), boundaries 1 (source ↔ installed runtime surface), new surface 1 (first-ever native pre-commit install + new clone fixture), rule edits 0

## Miss-risk: 80% — High (see calibration caveat — W1.5g forecast 90% on the same class and shipped clean across 3 passes)

Est. tokens: 79k–237k (Large)

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | Gate self-modification lockout/fail-open — freshly installed gating pair misbehaves live, blocking this session's own commits (or silently failing open) with the session mid-flight | 3 | 5 | 15 | Structural: Task 8 clone-first GREEN is a hard gate; Task 9 snapshot precedes install; Task 12 proves both escape hatches (--no-verify, hook-delete+restore) BEFORE any live gated commit. If lockout occurs: restore from snapshot, do not debug the live gate in-session | ADR-008; retros 2026-07-19-dogfood-gap-adr008, 2026-07-06 W1 forecast scenario 1 (fired, caught) |
| 2 | Fixture false-green — new clone fixture reports GREEN while scenarios never actually ran (dead guard branches, subshell-lost counters, phantom passes) | 3 | 3 | 9 | Mandatory fixture elements in the Wave-1 task prompt: parent-shell counting, absolute-path-once-at-top, and a CANARY run (corrupted hook must go red) before Task 8's attestation counts | W1.6 Critical (test-agent-lifecycle false-green); W1.5b counter trap |
| 3 | #21-class false-positive resurfaces live — commit whose message cites file paths misclassified mixed/blocked by the NEW gate on the first real commit (Task 14 carries the slice's edits; ledger commits cite code+doc paths) | 3 | 3 | 9 | Task 6 probes exactly this in the clone first; keep Task 14/15 commit messages path-free until the probe class is proven closed; dual sentinels stamped before commit | Finding #21 (3 live surfaces); fired again on HQ probe string 2026-07-21 |
| 4 | g-forge-dev attestation dispatch killed by session limit (Tasks 8, 13) | 4 | 2 | 8 | Standing precedent: HQ runs the suite directly and pastes verbatim output; not a plan failure | W1.5a/W1.5e/W1.5f (3 kills) |
| 5 | Implementer bundle overreach — Tasks 20–24 agent touches files beyond its 8 scoped targets (CLAUDE.md edits invite drift) | 2 | 2 | 4 | ADR-006 wave-close integrity check (full-file diff vs git for every touched file); scope boundary explicit in prompt | W1.5d doc-writer overreach; ADR-006 |

## Recommendations

High risk — strongly consider re-scoping before approval. In practice: the 3-pass split at wave boundaries (Waves 1–2 / 3–7 / 8–12) IS the re-scope — it isolates the clone-proof pass from the live-install pass from the live-commit pass, so a scenario-1 event never strands an overloaded session. Apply mitigations 1–2 verbatim in the Wave-1 task prompts. Forecast assumes the historical pattern set is representative.

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | | |
| 2 | yes | | |
| 3 | yes | | |
| 4 | yes | | |
| 5 | yes | | |
