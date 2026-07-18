# Forecast: M-audit W1.5a — commit-detect suite + hardening

> Created: 2026-07-17
> Plan: g-docs/plans/w1-5a-commit-detect-suite-hardening.md (pending approval at forecast time)
> Mode: regular (8 retros + patterns-deferred.md + 1 rework marker in last 50 commits)

## Complexity
- Score: 4/10
- Breakdown: files 1 (2 distinct), waves 2 (3 waves), boundaries 1 (tests ↔ hooks/lib), new surface 0, rule edits 0

## Miss-risk: 60% — Elevated

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | test-writer false-DONE — suite's fail-before/pass-after claims asserted, not observed (test-writer has no Bash) | 3 | 3 | 9 | Task 4 attestation is mandatory and blocking; treat task-1 output as UNVERIFIED until g-forge-dev pastes the run showing the 2 named FAILs before the fix and 0 FAIL after | M-audit finding #20; retro 2026-07-16-adr-006 (journal degradation forces evidence discipline) |
| 2 | live PreToolUse gate false-fires on dev/test commands whose strings contain `git commit` (finding #21 surface 1/3 — this plan's test file is FULL of such strings) | 4 | 2 | 8 | All execution via script files, never inline Bash strings containing `git commit`; commit messages path-free; the workaround is proven (2026-07-16 live) | M-audit ledger #21 (reproduced live 3× on 2026-07-13, again 2026-07-16) |
| 3 | doc/count drift — new suite makes README + CLAUDE.md quick-commands/suite-count stale (hit twice in W1.4 as forecast scenario 2) | 4 | 2 | 8 | Update README test list/count in the same changeset; doc gate backstops (it caught both W1.4 instances) | forecast w1-4 Outcome; retro 2026-07-16-w13 |
| 4 | commit-gate self-modification regression — commit-detect.sh is sourced by the gate lineage; a bad edit weakens detection silently | 2 | 4 | 8 | Sandbox temp repos only; task 4 runs the FULL suite (existing -C/-c pins must stay green), not just the new file | forecast m-audit-w1-enforcement-fixes (scenario fired live 2026-07-06, caught by tests) |
| 5 | phantom findings from stale mid-edit reads by agents | 2 | 2 | 4 | Waves are strictly sequential single-agent here; attest from fresh reads only | retro 2026-07-16-w13 (3 phantom bugs refuted by HQ) |

## Recommendations

Apply at least the top-2 mitigations before approving. Both are already structural in this plan (task 4 attestation; script-file discipline noted for g-execute dispatch prompts). Consider splitting the largest wave — not applicable: no wave exceeds one dispatch. Forecast assumes the historical pattern set is representative.

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | | |
| 2 | yes | | |
| 3 | yes | | |
| 4 | yes | | |
| 5 | yes | | |
