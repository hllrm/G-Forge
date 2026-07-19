# Forecast: M-audit W1.5d — sentinel-read extraction + install propagation

> Created: 2026-07-18
> Plan: g-docs/plans/w1-5d-sentinel-read-extraction.md (pending approval at forecast time)
> Mode: regular
> Presentation note: per the 2026-07-18 calibration feedback (g-docs/milestones/M36-salience-inputs/2026-07-18-forecast-calibration-feedback.md), scenarios+mitigations are the product; the percentage is a headline with known upward bias. Notable calibration data point: the formula DOES discriminate — W1.5c (one fixture file) scored 55, this slice (the gate's own parser + 4 propagation surfaces) scores 80. The ordering is informative even where the absolute level is inflated.

## Complexity
- Score: 7/10
- Breakdown: files 8 (→3), waves 4 (→2), boundaries 1 (hooks ↔ skills/README propagation), new surface 1 (new shared lib), rule edits 0

## Miss-risk: 80% — High (formula output; see presentation note — the risk ordering vs. W1.5c matters more than the absolute number. The "re-scope" recommendation the High tag implies has ALREADY been applied: this slice was isolated to run alone precisely because it is the riskiest.)

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | Extraction not byte-identical — parser drift (CRLF strip, space-truncation, terminal worktree read) silently changes gate behavior | 3 | 5 | 15 | Verbatim function move with explicit body-diff-empty done condition; fixture 35/35 as end-to-end regression net (exercises the parser through the real hook); new suite pins the contract field-by-field | W1.2 r1 HOLD (worktree truncation Major), ADR-004 |
| 2 | workflow-checkpoint legacy/fail-open semantics broken — D2 subtlety: legacy bare sentinel must still read approved via the presence branch; empty-resolution must stay fail-open advisory | 3 | 3 | 9 | D2 recorded in plan header; task 5 done condition byte-preserves the outer dispatch + fail-open branches; implementer checklist names the legacy path explicitly | W1.3 review advisories, workflow-checkpoint comments |
| 3 | Count drift across the 4 propagation surfaces | 4 | 2 | 8 | Task 12 is the explicit grep sweep (all-4-surfaces + zero-stale-language); doc gate re-checks at commit | W1.4 forecast scenario 2 (hit twice, caught twice) |
| 4 | Fail-before evidence destroyed by ordering slip (lib lands before the attestation) | 2 | 2 | 4 | Wave 2 is a hard gate before Wave 3; wave boundary enforced by g-execute | W1.5 sandwich discipline |
| 5 | Gate self-modification friction — editing hooks/pre-commit while the installed PreToolUse gate watches; #21 false-fires on probe commands | 2 | 2 | 4 | Probes from script files; path-free commit message; sentinel write in a separate call from the commit | retros 2026-07-13/16, W1.5c pass |

## Recommendations

High per formula — but the standard "re-scope before approving" advice is pre-satisfied: W1.5d was already carved out to run alone because it touches the enforcement layer's own parser. Apply mitigations 1–2 (both already encoded as done conditions) and hold the Wave 2→3 ordering strictly. Est. tokens: 48k–145k (Medium).

Forecast assumes the historical pattern set is representative.

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | | |
| 2 | yes | | |
| 3 | yes | | |
| 4 | yes | | |
| 5 | yes | | |
