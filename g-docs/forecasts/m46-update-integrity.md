# Forecast: M46 — Update Integrity

> Created: 2026-07-23
> Plan: g-docs/plans/m46-update-integrity.md (approved 2026-07-23; forecast generated pre-approval from the pending handoff)
> Mode: regular

## Complexity
- Score: 9/10
- Breakdown: files 3 (≈17 distinct incl. installed mirrors + manifests), waves 2 (6 waves), boundaries 2 (hook ↔ sourced lib, hook/skill version-triple contract, g-update ↔ g-doctor detect/diagnose/fix split, G-RULES layer), new surface 1 (hooks/lib/semver-compare.sh — gf_semver_compare consumed by workflow-checkpoint + g-doctor + g-update contract), rule edits 1 (G-RULES §B table, source + installed copy)
- Blast-radius: not yet available (task 11 generates g-docs/blast-radius/M46-wave1-version-triple.md at Wave 1 close — re-run /g-forecast after if desired); no adjustment applied

## Miss-risk: 85% — High

Calibration caveat (standing, per reconciled outcomes): the formula historically over-reads on this repo — W2 forecast 85% High and shipped first-attempt clean; stdin-guard forecast 80% High and shipped with one absorbed variant. Scenarios below are tagged **change-scoped** (exposed by exactly what this plan changes) vs **standing-noise** (recurring class already mitigated by a shipped rule/ADR — watch-point, not expected failure). Treat High as "watch-points are real," not "expect failure."

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | Confabulated/HQ-arithmetic attestation totals (claim-vs-data recurrence #3+) — 3 attest tasks (3/6/10) feed CLAUDE.md's new suite row + total (task 18); a wrong total ships into the tracked doc surface. Standing class (shipped rule) with **change-scoped** exposure via task 18's derived total | 4 | 3 | 12 | g-forge-dev pastes real per-suite runner output; HQ sums independently; task 18's total sourced only from the attested tables of tasks 3+6 — never re-derived | w1-5g-pass1 retro (247 double-count), m-audit-w3-p2-minors Outcome #2 (568/650 confabulation), hook-stdin-hang-guard #1 |
| 2 | Compare-semantics divergence survives the consolidation — the M46 origin bug (three hand-rolled compares) re-enters via g-doctor's new check re-implementing a compare or g-update SKILL prose describing semantics inconsistent with the lib's -1/0/1 contract. **Change-scoped** — this is the very class being fixed | 3 | 4 | 12 | Task 4 done-condition grep ("no second hand-rolled compare") extended repo-wide at Wave 3 close: grep hooks/ + skills/ for version-compare idioms; task 11 blast-radius enumerates every triple reader; task 12 must read the triple *via the shared lib contract*, never inline | M46 origin bug (plan header), m10-m14 retro (stale triple-list sync class) |
| 3 | Doc-writer overreach/collision in Wave 4 (4 parallel doc-writers; skills/g-update/SKILL.md touched by tasks 8/13/14 across waves 1/3/4) — an out-of-scope edit clobbers a sibling's landed change. Standing class (ADR-006 absorbs) with **change-scoped** exposure: highest same-file traffic of the plan | 3 | 3 | 9 | Cross-wave serialization already in schedule — keep it; explicit scope-boundary + no-child-dispatch lines in all W4 prompts; ADR-006 wave-close integrity check = full git-status diff, and any overreach recovery is full-file diff vs git, never spot-revert | ADR-006, w1-3 Outcome #4 (predicted-and-hit), w13 retro, w1-5d Outcome #3 |
| 4 | MSYS platform-semantics fires at the assertion layer — task 9's zero-mtime-change assertion (and task 5's fail-before capture) hits Windows/MSYS timestamp granularity or subprocess overhead, producing false reds/greens on the field-representative platform. Standing class (shipped rule: author generous, tighten on evidence) with **change-scoped** exposure: zero-write-via-mtime is a new assertion type here | 3 | 3 | 9 | Author fixture bounds with empirical headroom from day one; probe mtime granularity in a scratch dir before asserting; run fixture in a throwaway clone with plugin-cache restore after (W1.5g precedent) | m-audit-close retro (timing headroom rule), hook-stdin-hang-guard Outcome #2 (happened-variant), w17 retro (escaping probes) |
| 5 | Budget overrun forces an unplanned mid-wave handoff — plan's own estimate is ~74 exchanges vs ~30 remaining; w1-5f precedent ran ~40 vs ~29 and finished "on fumes." **Change-scoped** — the plan header already prices it | 4 | 2 | 8 | Honor the proposed 3-pass split at wave boundaries (M-audit precedent); /context check at every wave boundary per §A7; never start a new wave below the ~25% floor — handoff instead | plan header, w1-5f retro + Outcome #2, w15f retro (budget-ran-hot) |

Near-miss candidates below the cut: partial eager-mirror (task 7 mirroring workflow-checkpoint.sh without .claude/hooks/lib/semver-compare.sh breaks the live UserPromptSubmit hook — mitigate: byte-hash BOTH files + one live-prompt smoke after mirroring, score 8); heredoc-record stalls in W4/W5 doc tasks (shipped Write-tool-not-heredoc rule — standing-noise, score 4); plugin.json/marketplace.json version split (task 19 done-condition already pins same-commit, score 4).

## Recommendations

Re-scope before approving. Cut the highest-impact items or move to a follow-up milestone.
— High tag carries the calibration caveat above. The concrete read: the 3-pass split the plan already proposes IS the re-scope — approve with the split honored at wave boundaries rather than cutting tasks (19-task integrity fix with tight internal coupling; cutting the docs sweep or g-doctor absorption would re-open the single-owner-per-check contract). Apply at minimum the top-2 mitigations before Wave 1: (1) attestation contract — runner output pasted, HQ-summed, task-18 totals only from attested tables; (2) repo-wide compare-idiom grep scheduled at Wave 3 close + lib-contract-only reads in task 12. Also byte-hash both mirrored files in task 7 (near-miss list) — cheap and the failure mode is a live hook break on every prompt.

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | | |
| 2 | yes | | |
| 3 | yes | | |
| 4 | yes | | |
| 5 | yes | | |
