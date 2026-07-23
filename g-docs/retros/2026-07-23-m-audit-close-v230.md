# Retro: m-audit-close-v230 — 2026-07-23

## What was done

- **Stdin-guard Pass 2 executed to close (Waves 4–5 of 5).** Wave 4: eager-install batches A/B/C — 7 non-gating hook files (incl. new `lib/stdin-read.sh`) copied to `.claude/hooks/`, HQ hash-verified 7/7 byte-identical; `check-commit.sh` deliberately NOT installed (ADR-008 gate cadence), divergence verified. Wave 5: g-forge-dev full attestation — 306/306 across the 10 touched suites after one recalibration (below), then 187/187 across the remaining 6 suites at review time; full-suite total 493/493 across 16 suites, matching the handoff's predicted ≈493 exactly, header-vs-runner MATCH everywhere.
- **GUARD_WINDOW_MS recalibration (HQ inline).** First execution of the abandoned-stdin fixtures produced 4 timing-only reds (8013–9896ms vs 8000ms bound) — guard exit-0 behavior correct in all 4; root cause = 3s epsilon too tight for MSYS subprocess overhead after the 5s read. Bound extracted to a `GUARD_WINDOW_MS=20000` constant with WHY comment; re-attested 38/0 (max observed 8094ms — would still breach the old bound on a quiet machine, confirming real overhead, not load flake).
- **Stdin-guard changeset shipped `b7bad18`** (13 files, 473+/23−) through BOTH live gates: code-lead MERGE READY (0c/0M/1m — missing-lib `command -v` outlier on session-start/workflow-checkpoint; 1 Info — fixtures leak 300s `sleep` procs), /g-doc-review DOCS READY (0b/2w same degradation-comment class). Dual ADR-004 sentinels stamped off staged write-tree `abe59faf`; committed tree = stamped tree exact; sentinels auto-consumed.
- **v2.3.0 RELEASED `9b2488e` and pushed** (12 commits to origin/main). CHANGELOG `[2.3.0] — 2026-07-23` cut; dual version bump plugin.json + marketplace.json same commit; first README status strip (version + Changelog/Roadmap links — standing currency convention starts here); ADR-007 migration check PASS (single router, bare tokens; consumer migration rides versioned cache replacement). Release diff got its own gate pass: code-lead MERGE READY 0 findings; doc-review DOCS HOLD → README agent table stale (18 rows, missing `doc-reviewer`; "16 specialist agents" vs 17) → HQ fixed against disk roster (19 rows = 19 files) → re-gate DOCS READY.
- **M-audit-2026-07 milestone CLOSED** — status flipped ✅ in ROADMAP + milestone file; CLAUDE.md test table synced (25/38/10 rows + 493 total); both outstanding forecast Outcome tables reconciled (`hook-stdin-hang-guard.md`, `m-audit-w3-p2-minors.md`).

## Decisions made

- **GUARD_WINDOW_MS 8000→20000ms** — evidence-forced test-bound calibration on first empirical run (attestation reds + quiet-machine re-run both above old bound); guard behavior unchanged. (commit `b7bad18`)
- **Stalled code-lead treated as delivered, not redeployed** — its heredoc record-write wedged in the permission layer post-verdict (known class, distinct from the fixed stdin-hang); developer killed it; HQ transcribed the record verbatim from the in-flight call with a provenance note rather than burning a fresh review. (journal 23:0x, record file provenance note)
- **README currency fix taken in-release rather than deferred** — DOCS HOLD blocking finding (stale agent table) fixed inline against the disk roster per the standing never-defer directive, then re-gated. (commit `9b2488e`)

## Patterns

### Worked well
- Attestation contract held end-to-end: runner output pasted, HQ summed the per-suite table independently — totals honest this time (306=306, 187 matched, 493 predicted=observed). The claim-vs-data recurrence-#3 mitigation is doing its job.
- Wave discipline clean: 4/4 install + attestation slots first-attempt, zero redeploys; dirty set stayed exactly plan scope at every checkpoint.
- The gate defended itself correctly twice: denied a chained stamp+commit (sentinels not yet on disk at PreToolUse evaluation — correct-by-design), then passed the split stamp-then-commit sequence; both sentinels auto-consumed both commits.
- Doc gate earned its keep at release: the mandated count spot-check surfaced a real pre-existing README/roster contradiction (missing `doc-reviewer` row) that had survived since v2.1.0.

### Avoid / do differently
- Heredoc writes by review agents stall in the permission layer (second occurrence — W3 r1, now release code-lead). Agent prompts this session started mandating Write-tool-not-heredoc for record files; make that a standing dispatch rule for agents that only have Bash for writes (or grant Write as with g-forge-dev).
- Test fixtures leak: abandoned-stdin fixtures spawn 300s `sleep` processes and never kill them (~9 per suite run) — code-lead Info; fold cleanup into the next test-touching slice.
- Timing assertions on MSYS need empirical calibration headroom from day one — first-run bound was authored 3s over the guard window; real overhead is 3–5s. Author generous, tighten on evidence (inverse of threshold-offset direction).

## Cold-start context
**Branch:** main
**Active milestone:** M-audit-2026-07 ✅ Complete (v2.3.0 released); next in arc: M41 — Release Machinery + README Currency (v2.4.0)
**Next up:** Close swarm (/g-patterns, /g-telemetry, /g-align, ADR prompt), /g-intake M36 note, then /g-plan M41
**Key files touched:** stdin-read.sh, test-stdin-read.sh, test-class-split-invariant.sh, test-check-commit.sh, 7 hooks, CHANGELOG.md, README.md, plugin.json, marketplace.json, ROADMAP.md, M-audit-2026-07.md
**Carry-over context:** v2.3.0 live on origin/main (`9b2488e`); installed non-gating hooks byte-current incl. stdin guard; installed check-commit.sh still pre-guard by design (gate cadence — next /g-update or gated install slice picks it up); ADR-006 implementation still POST-M-audit backlog; minors routed forward: session-start/workflow-checkpoint `command -v` hardening, fixture sleep-leak cleanup, per-session counter-file accumulation.

## Journal basis
2026-07-22.jsonl (UTC-keyed, spans all three passes that day incl. this session's close): 589 agent · 8 commit · 5 test · 16 session · 13 destructive · 1 merge · 1 push. This session's tail: install/attest agent pairs, doc-reviewer DOCS READY stop, v2.3.0 commit + push events.
