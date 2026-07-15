# Forecast: W1.1 — Shared foundations (M-audit-2026-07)

> Created: 2026-07-14
> Plan: g-docs/plans/.pending-forecast.md (not yet saved as w1-1-shared-foundations.md — pending approval)
> Mode: regular

## Complexity
- Score: 4/10
- Breakdown: files 2 (3 files: commit-detect.sh, worktree-resolve.sh, g-review/SKILL.md → weight 2), waves 0 (1 wave), boundaries 1 (hooks/lib ↔ skills layer crossing), new surface 1 (two new shared library files consumed by later waves), rule edits 0

## Miss-risk: 60% — Elevated risk — premortem mitigations recommended before approval

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | Stale cross-file contract — the sentinel stamp field names (`commit_sentinel_ts`/`commit_sentinel_head`/`commit_sentinel_worktree`) are written here (task 9+10) but consumed by W1.2's pre-commit hook in a separate `/g-plan` invocation, possibly a different session | 3 | 4 | 12 | Field names are already fixed verbatim in this plan and in W1.2's task spec (wave-planner's stated contract) — when running `/g-plan` on W1.2, paste the exact field names from this plan rather than re-deriving them | g-docs/retros/2026-05-19-m10-m14-pre-shipping-sweep.md (stale list synchronisation across 3 locations) |
| 2 | Self-modifying gate obstructs its own repair — editing `skills/g-review/SKILL.md` (the tool that produces the sentinel the commit gate checks) mid-session can make routine commits (including this work's own docs/code commits) get blocked by the very thing being changed | 3 | 3 | 9 | Land this wave's changes with path-free commit messages and split `git add`/`git commit` calls if the gate misbehaves mid-edit; do not disable the gate to work around it | g-docs/retros/2026-07-13-bug2-triage-and-scope.md (BUG-2's own bug obstructed recording the bug) |
| 3 | Cross-session collision on `main` — this plan is explicitly designed to be resumed across multiple `/g-plan` sub-invocations, possibly different sessions, without a claim/lock primitive (M29 hasn't shipped yet) | 2 | 3 | 6 | `git fetch` + check `origin/main` divergence before starting any W1.x sub-plan, not just this one | g-docs/retros/2026-06-29-m27-doc-review-gate.md (M27 hit this exact collision) |

## Recommendations

Apply at least the top-2 mitigations before approving. Consider splitting the largest wave.

(Note: this wave is already a single 1-wave/3-task plan — "splitting" here means: when running `/g-plan` on W1.2 next, carry the exact stamp-format contract forward verbatim rather than re-deriving it, which is itself mitigation #1.)

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | | |
| 2 | yes | | |
| 3 | yes | | |
