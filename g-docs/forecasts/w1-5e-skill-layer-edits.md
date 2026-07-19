# Forecast: W1.5e — Skill-layer edits (M-audit)

> Created: 2026-07-19
> Plan: g-docs/plans/w1-5e-skill-layer-edits.md (pending approval at forecast time)
> Mode: regular

## Complexity
- Score: 5/10
- Breakdown: files 2 (3 distinct files), waves 1 (2 waves), boundaries 1 (scope spans skills/ + hooks/, though no single task crosses), new surface 1 (test-runner-agent convention is new consumer-facing convention text), rule edits 0

## Miss-risk: 55% — Elevated

> ⚠ Calibration caveat (standing, per 2026-07-18 developer feedback): the formula has never produced <50% on record (9 forecasts, 55–90). Read the number as *information, not paranoia*: this is a 4-edit text/comment slice with mechanical done conditions; the risk mass concentrates in scenario 1 (agent-behavior class), not in the edits themselves. Formula recalibration is queued for M38/M39 with M36 salience as scenario-selector.

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | Wave-agent child overreach — an implementer dispatches a doc-writer child that edits outside scope (2 prior instances, incl. retro-editing a shipped CHANGELOG entry) | 3 | 3 | 9 | Dispatch prompts hard-forbid child agent dispatch (all tasks are single-file text edits — no doc-writer is ever needed) + wave-close integrity check: only the 3 scoped files may differ | retros/2026-07-18-w15cd (2nd instance), retros/2026-07-16-w13 (1st), patterns-deferred.md (Systemic) |
| 2 | Skill-text coherence miss — the Step 6 reconciliation fixes the flagged sentences but a contradictory diff-target/HEAD sentence survives elsewhere in g-review SKILL.md | 3 | 2 | 6 | Done condition requires whole-file side-by-side read of Steps 2+6, not just the flagged lines; grep for unqualified `git rev-parse HEAD` is mechanical | finding #19 drift class; W1.4 doc-gate count-drift catches (forecasts/w1-4) |
| 3 | Commit-time friction — installed cleanup hook doesn't fire on Windows (sentinels cleared by hand, 3rd+ session) and/or gate false-fires on paths in the commit message (#21 residual) | 4 | 1 | 4 | Known workarounds: path-free commit message, manual sentinel clear post-commit; both close permanently in W1.7 | retros/2026-07-18-w15cd, retros/2026-07-13-bug2 |
| 4 | Convention-text-is-generic failure — repo-specific names (g-forge-dev, g-dev/) leak into the generalized Step 1 text | 2 | 2 | 4 | Done-condition grep for repo-specific tokens is mechanical; reviewer re-runs it | fixture-as-crutch class (M42 field report) |

## Recommendations

```
Recommendations:
  [Elevated] Apply at least the top-2 mitigations before approving. Both are
  already folded into the plan: (1) the Wave 1 dispatch prompts will carry a
  no-child-dispatch hard line + 3-file scope + wave-close integrity check;
  (2) task 1's done condition mandates the whole-file coherence read + grep.
  No wave split warranted — Wave 1 is 3 parallel single-file text edits.
```

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | | |
| 2 | yes | | |
| 3 | yes | | |
| 4 | yes | | |
