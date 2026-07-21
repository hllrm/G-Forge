# Forecast: W1.5g — Self-Host Integrity

> Created: 2026-07-20
> Plan: g-docs/plans/w1-5g-self-host-integrity.md (saved on approval)
> Mode: regular
> ⚠ Calibration caveat (standing, per the 2026-07-18 developer feedback logged in `g-docs/milestones/M36-salience-inputs/2026-07-18-forecast-calibration-feedback.md`): every forecast on record reads ≥55%; treat the number as a ranking signal across slices, not an absolute probability. Discriminating context: this formula scored W1.5c at 55 and W1.5d at 80 — W1.5g lands at the top of the range because it combines live runtime self-mutation (first ever) with a plan that exceeds the session budget, both structural, not code-difficulty, drivers.

## Complexity
- Score: 9/10
- Breakdown: files 3 (≥6 distinct), waves 2 (7 waves), boundaries 2 (skills ↔ tests ↔ live runtime), new surface 2 (new invariant suite + self-host detection convention), rule edits 0
- Blast-radius file: none (propagation set enumerated by ADR-008 — g-doctor, g-update, g-init, g-review, tests, live .claude/ runtime)

## Miss-risk: 90% — High
(10 + 9×3 + min(15,15)+min(12,15)+min(9,15) ×1.5 = 91 → 90. "Miss" here = does not complete in one clean pass — dominated by the budget scenario; a planned wave-boundary split largely absorbs it.)

## Est. tokens: 52k–157k (Medium)

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | Context-budget overrun forces mid-plan handoff (est. 69 exchanges vs 38 remaining here; 40 even fresh) | 5 | 3 | 15 | Execute in a FRESH session; plan the handoff at the Wave 3→4 boundary instead of letting red force it mid-wave; Waves 6–7 (spike) explicitly deferrable to a third pass | retros/2026-07-19-w15f ("budget ran hot"), w1-5e forecast caveat |
| 2 | Session-limit kill on a long g-forge-dev/implementer dispatch (3 prior occurrences) | 4 | 3 | 12 | Keep attestation dispatches single-purpose; resume interrupted agents via SendMessage (context intact — never redeploy/discard); HQ-run fallback per W1.5a precedent | retros/2026-07-19-adr007-w15e §5, 2026-07-19-w15f-guard-and-22 |
| 3 | Live install (Wave 4) changes the running session's own hook behavior mid-flight — the ADR's named "mid-session surprise" trade | 3 | 3 | 9 | Task 12 durable snapshot BEFORE; Wave 4/5 solo + HQ-supervised; task 14 immediate Check-16 verify; git-level rollback contract (one cp -r) | ADR-008 Consequences; installed-copy fail-open retro class |
| 4 | Combined-dispatch overreach — an implementer/doc-writer child edits beyond declared file scope (2 prior occurrences, incl. falsified CHANGELOG history) | 3 | 3 | 9 | Explicit per-dispatch file-scope constraint; wave-close integrity = full-file diff against git, never spot-revert; no doc-writer children on Wave 1 dispatches | retros/2026-07-18-w15cd, 2026-07-19-adr007-w15e §4 |
| 5 | Count/wording drift across the plan's own surfaces (10-mapping list, task 6↔7 verbatim wording, CLAUDE.md totals) | 3 | 2 | 6 | 6+7 single combined dispatch (scheduled); task 11 only after attested counts (scheduled); doc gate re-checks currency pre-commit | M13 stale-list retro class; W1.4 count-drift (caught twice by doc gate) |

Watch-point (scored 6, outside top-5 table): #21-class gate false-positive — the stale installed PreToolUse gate may deny spike/install commands or report writes that merely quote commit phrases; workaround precedent: run from script files, path-free messages.

## Recommendations

Apply at least the top-2 mitigations before approving. Consider splitting the largest wave. Specifically: approve here, execute in a fresh session with a PLANNED handoff at the Wave 3→4 boundary (code+tests+attestation first pass; live install+verify second; spike third if budget demands). This converts scenario 1 from a risk into the execution design. (Advisory — approval is authoritative.)

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | did not happen (Pass 1) | Planned split converted it to design as recommended — handoff at Wave 3→4 was scheduled, never forced mid-wave (evidence: plan Progress + session) |
| 2 | yes | did not happen (Pass 1) | All 11 dispatches returned without a session-limit kill (evidence: journal 22 agent events, 11 start/stop pairs) |
| 3 | yes | unverified | Wave 4 live install not yet executed — reconcile at Pass 2 retro |
| 4 | yes | did not happen (Pass 1) | Wave-close integrity full git-status diff: tracked delta exactly the six scoped files; no doc-writer children dispatched (evidence: git) |
| 5 | yes | did not happen (Pass 1) | Task 11 counts sourced from the attested runner record, not re-derived; task 6↔7 verbatim wording grep-verified. Adjacent near-miss: HQ's own 247 total estimate was wrong (double-counted) — the attestation record was authoritative and no drift landed (evidence: git + agent-output) |
