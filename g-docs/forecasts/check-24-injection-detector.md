# Forecast: Check 24 — CLAUDE.md injection-rule detector (ADR-011)

> Created: 2026-07-27
> Plan: g-docs/plans/check-24-injection-detector.md (pending approval at forecast time)
> Mode: regular

## Complexity
- Score: 6/10
- Breakdown: files 3 (6 distinct paths), waves 2 (4 waves), boundaries 0, new surface 1 (one new public check), rule edits 0. No blast-radius file — no adjustment.

## Miss-risk: 70% — Elevated

Calibration note: the dominant driver (scenario 1) is a fully mitigable pattern and its mitigation is folded into the plan's done conditions; with it applied the effective risk reads closer to Moderate. Forecast assumes the historical pattern set is representative. (Standing feedback: miss-risk reads high/static across forecasts — intake row, alarm-fatigue calibration.)

## Estimated tokens: 29k–86k (Medium)

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | Stale count sites beyond the named list — "23 checks"-class strings live in files the plan doesn't name (g-wiki/usage.md:222 was exactly this miss last cycle; recurrence #4 of the class) | 5 | 3 | 15 | Wave 3 sweeps the WHOLE repo for the count-string class (`23 check`, `16 + 7`, `16+7`, `23-point`), not just the named files | retros/2026-07-23-m46-update-integrity.md, 2026-05-19-m10-m14-pre-shipping-sweep.md, 2026-07-26-adr-010-verify.md |
| 2 | /g-update vocabulary creep — implementer "helpfully" adds `G-Forge local-only:` to g-update's marker matcher, destroying the survive-update property | 2 | 4 | 8 | Hard scope boundary in every dispatch prompt: skills/g-update/SKILL.md is a no-touch file; Wave 4 confirms it unchanged via git status | ADR-011 constraint; handoff 2026-07-27 |
| 3 | Verify-by-absence inversion — sweep verified by grepping for the NEW string ("24") instead of the absence of the old ("23"-count refs), passing silently on a missed site | 3 | 2 | 6 | Done conditions grep for what should be GONE; HQ re-runs the absence grep at Wave 3 independently | retros/2026-07-26-adr-010-verify.md |
| 4 | Present-tense over-claim in the Check 24 body — the check text asserts capabilities or counts that don't exist yet (the ADR committed this sin and both gates caught it) | 3 | 2 | 6 | Implementer instructed: describe what the check DOES, cite ADR-011 for spec provenance, no forward-looking claims | retros/2026-07-26-adr-010-verify.md (doc-gate HOLD r1) |
| 5 | Agent output lost — dispatch lacks Write for record files or returns empty final text (task-decomposer did exactly this, this session) | 3 | 2 | 6 | Implementers write project files with Write (held by role); all agents told final message must carry the full result inline — no scratchpad-only returns | retros/2026-07-23-m-audit-close-v230.md; this session's decomposer dispatch |

## Recommendations

Elevated — apply at least the top-2 mitigations before approving. Both are already folded into the plan (Wave 3 repo-wide absence-grep; g-update no-touch boundary in dispatch prompts), which is why the calibration note reads the effective risk as Moderate. No re-scope recommended.

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | | |
| 2 | yes | | |
| 3 | yes | | |
| 4 | yes | | |
| 5 | yes | | |
