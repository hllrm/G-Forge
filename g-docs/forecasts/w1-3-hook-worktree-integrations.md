# Forecast: W1.3 — Remaining hook worktree integrations (M-audit-2026-07)

> Created: 2026-07-15
> Plan: g-docs/plans/w1-3-hook-worktree-integrations.md (pending approval at forecast time)
> Mode: regular
> Note: this file was deleted mid-execution by a Wave-1 agent's overreaching cleanup (see retro) and restored verbatim by HQ from session context.

## Complexity
- Score: 4/10
- Breakdown: files 3 (6 hooks), waves 1 (2 waves), boundaries 0, new surface 0, rule edits 0

## Miss-risk: 70% — Elevated

## Estimated token cost: 37k–111k (Medium)

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | Enforcement-adjacent regression in post-commit-cleanup — key-scheme mismatch with check-commit.sh/pre-commit either clears the WRONG tree's sentinel (cross-tree approval bleed, ADR-005's exact target) or stops clearing (stale approval rides the next commit, finding #9 class) | 3 | 4 | 12 | Task 2's done condition requires mirroring the exact sentinel-path construction from check-commit.sh/hooks/pre-commit (read, don't re-derive); sandbox asserts linked-tree commit clears the PRIMARY's sentinel and only it; 5/5 suite after every edit | Bug A history (v2.2.1 gate no-op); m-audit-w1 forecast scenario 1 (fired live 2026-07-06); 2026-07-13 retro |
| 2 | Silent primary-tree behavior drift in the 4 uncovered hooks — pre-compact/session-start/workflow-checkpoint/agent-lifecycle have ZERO test coverage (finding #11), so a resolution refactor that breaks the common primary-tree path is invisible to the 60/60 suite | 3 | 4 | 12 | Task 9's byte-identical primary-run comparison is load-bearing — run each hook in a primary-only sandbox before/after and diff outputs; W1.6 owns real coverage | M-audit finding #11; m10-m14 retro (doc-currency/stale-sync class) |
| 3 | Windows/git-bash path-normalization quirk — comparing gf_worktree_key output vs stamped/derived paths breaks on spaced or mixed-slash Windows paths; W1.2's only Major was exactly this (worktree stamp field truncated at first space) | 3 | 3 | 9 | Reuse g-dev/fixtures/pre-commit-spaced-worktree-verify.sh pattern; sandbox on this host (the historical fail-open environment); no non-portable realpath calls | memory windows-hook-gotchas; W1.2 code-lead r1 Major; w1-2 forecast scenario 4 |
| 4 | Mid-run agent crash/revert during the 6-thread Wave 1 — the largest fan-out this milestone; a 2026-07-06 crash reverted 3 files mid-wave | 2 | 3 | 6 | Files are disjoint per agent slot so recovery is per-file; keep a pre-wave backup patch in scratchpad (2026-07-06 precedent) | 2026-07-06 handoff (Wave-1 process crash) |
| 5 | Journal write-target decision ripples — primary-journal + worktree-tag is a new event-schema decision made at plan time (ADR-005 left the partition open); #22's fix (W2), W1.6 tests, and concurrent linked-tree writers must honor it | 2 | 3 | 6 | Record the decision in the plan header (done) and on the M-audit ledger at close; keep the tag additive (existing consumers unaffected); append-only single-line writes stay atomic | task-decomposer Clarify 1; ADR-005 follow-ups section |

## Recommendations

Apply at least the top-2 mitigations before approving. Consider splitting the largest wave.
— Concretely: (1) task 2 mirrors the sentinel-key construction verbatim from the shipped gate code, and (2) task 9's primary-tree byte-identical check must actually diff before/after outputs for all six hooks, since 4 of them have no test coverage until W1.6. Wave 1's 6-thread fan-out is disjoint-file-safe; splitting it is optional, not required. (Forecast assumes the historical pattern set is representative.)

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | did not happen (git) | code-lead review 2026-07-16 verified DC-2: sentinel clearing mirrors check-commit.sh/pre-commit key scheme; sandbox asserted primary-sentinel clear; suite 60/60 throughout |
| 2 | yes | did not happen (git) | consolidated verification + review confirmed primary-tree paths byte-identical for all six hooks; no drift surfaced |
| 3 | yes | did not happen (git) | no Windows path-normalization failure observed; review passed on this host (the historical fail-open environment) |
| 4 | yes | yes — a Wave-1 agent's overreaching remediation (stash + checkout-revert of sibling files + untracked-file deletion) wiped workflow-checkpoint.sh's integration and this forecast file mid-wave; recovered from stash/context/agent-transcript. Escalated: /g-patterns weighted it Systemic → ADR-006 (optimistic wave concurrency / collision absorption) | filled early — scenario observed live during execution |
| 5 | yes | unverified | wt-tag schema decision honored in W1.3 code; downstream consumers (#22 fix in W2, W1.6 tests) not yet built — cannot substantiate ripple-or-not |
