# Forecast: Hook stdin-hang guard (v2.3.0 release rider)

> Created: 2026-07-22
> Plan: g-docs/plans/hook-stdin-hang-guard.md (pending approval at forecast time)
> Mode: regular

## Complexity
- Score: 6/10
- Breakdown: files 3 (≈18 distinct), waves 2 (5 waves), boundaries 0, new surface 1 (hooks/lib/stdin-read.sh), rule edits 0

## Miss-risk: 80% — High (calibration caveat: formula historically over-reads on this repo — W2 forecast 85% High, shipped first-attempt clean; recurrence-weighted patterns below are already mitigated by schedule design. Treat as "watch-points are real," not "expect failure.")

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | Header-vs-runner count mismatch / confabulated attestation totals (claim-vs-data recurrence #3) | 4 | 3 | 12 | g-forge-dev attestation must paste per-suite runner output; HQ sums the table independently before accepting any total; 3 suites update header counts — verify each against runner-observed | W3 Pass 3 (568/650 confabulation), W2 Pass 4 reconcile |
| 2 | mkfifo/`read -t -d ''` semantics differ on Windows Git Bash (MSYS named-pipe emulation) — fixtures hang or false-pass on the very platform the bug bites | 3 | 4 | 12 | Task 2 executor probes mkfifo viability FIRST; if MSYS FIFO unreliable, fall back to open-FD-no-writer fixture (`exec 3< <(sleep 300)` style); attestation runs on this Windows machine = field-representative | memory windows-hook-gotchas; wave-planner risk 4 |
| 3 | Eager-install (Wave 4) precedes /g-review — review fix-forward lands in source after copies, drift suite then attests stale installed state as in-sync | 3 | 3 | 9 | If Wave 3/5 or review surfaces any hook defect, re-run install batches after the fix BEFORE re-attesting drift; byte-hash verify at review time, not install time | W2 Pass 4 (observe.sh source-newer catch), ADR-008 |
| 4 | Agent mid-run stall (session-limit / stdin-hang class) during 6-slot Wave 2 | 4 | 2 | 8 | W1.7 protocol standing: resume-to-completion once, verify state directly on 3rd stop, never 4th resume; ironic-but-real — this plan fixes the hang class that causes it | W3 Pass 1–2 dispatch notes |
| 5 | Sourced-lib ordering — a suite executed before its hook's lib wiring lands (every wired hook sources the NEW lib) | 2 | 4 | 8 | Schedule already holds attestation to terminal Wave 5 after all wiring + installs; enforce no ad-hoc mid-wave suite runs by implementers (sanity `bash -n` only) | W2 Pass 1 retro (Check-3 sourced-lib edge) |

## Recommendations

Apply at least the top-2 mitigations before approving. Consider splitting the largest wave.
- #1: attestation contract — runner output pasted, HQ-summed.
- #2: mkfifo viability probe first in task 2; fixture fallback named in advance.
(High tag carries the calibration caveat above — schedule design already embeds mitigations 3–5; re-scoping not recommended for a 15-task bug-fix slice.)

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | | |
| 2 | yes | | |
| 3 | yes | | |
| 4 | yes | | |
| 5 | yes | | |
