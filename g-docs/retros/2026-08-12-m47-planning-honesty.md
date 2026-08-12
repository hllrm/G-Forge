# Retro — 2026-08-12 — M47 Planning-Pipeline Honesty

## What happened

- `/g-resume` → `/g-plan M47` → approval → 2-wave execution (8 tasks collapsed to 4 agent slots by M47's own sizing rule, applied to its own plan) → **4 review rounds** (tallies = cautious record's summary + code-lead's non-duplicate majors; code-lead minors excluded: r1 HOLD 2C/8M/7m · r2 HOLD 1C/8M+2M/9m · r3 HOLD 0C/7M+1M/8m · r4 — code-lead-only delta round, no cautious axis — **MERGE READY** 0C/0M/6m, minors swept pre-commit; the M47 commit carried no doc sentinel — doc coverage ran as the cautious reviewer's backstop) → merge `6590b60` to main, pushed.
- Shipped: task-decomposer same-file serial-chain sizing rule + scoped-Write `output_file` self-check (early grant, M45 exception recorded in todo task 6) · `/g-plan` Step 2 validated per-run fallback + Step 3c task-based review-chain cost term (bands re-tuned, worked example required) + `-split<N>` depth cap propagated into `/g-roadmap` templates · `/g-forecast` outcome-corpus calibration (Step 5b, N≥5 floor, bounded bidirectional, `mitigation-held:` half-credit with its `/g-retro` writer) · README.md (calibration coverage :368, formula + depth cap :465/:625-628) and CHANGELOG.md Unreleased entries rode the same commit.
- Suite 564/564 green attested twice on the final tree (one mid-pass full run went 562+2 on the abandoned-stdin timing pair **under 18-agent parallel load** — quiet re-run 38/38 twice; load flake, not deterministic).
- **The M47 scope items reproduced live during their own build**: the first task-decomposer dispatch returned an empty final message and needed a resume (scope item 2, same-day evidence), and the plan's own forecast printed 70% Elevated off the uncalibrated formula tasks 4–5 replaced (the before-picture is preserved in `g-docs/forecasts/m47-planning-pipeline-honesty.md`).

## Decisions inferred

- task-decomposer holds a Write grant scoped to its own output file — M47-local exception ahead of M45's record-write ADR; 11 agents + wave-planner's Step 3 seam remain that ADR's population (todo task 6).
- Review-chain cost term scales with task_count (code-touched proxy, split-invariant), never wave count — keyline field report's own finding, honored after two wrong derivations.
- `g-docs/forecasts/` is now a formula input (Step 5b), so forecast files are commit content, not scratch.

## Patterns (for /g-patterns)

- **Fix waves minted new defects in rounds 1→2 and 2→3** (stale same-day fallback; re-minted typed counts) — the ec9bf8a class again, ×3 occurrences now. What converged it: round-3's consolidation discipline (no typed counts of derivable sets; one stated basis per number) + delta-scoped r4.
- **Convention-without-writer, twice in one milestone** (`-split<N>` with no g-roadmap writer, r2; `mitigation-held:` with no g-retro writer, r3 — the second caused by HQ's own scope fence in the fix brief). Cross-cutting propagation (§B blast-radius) applies to *conventions minted mid-fix-wave*, not just planned primitives.
- **Pre-execution enumeration grep beat review-time discovery**: the round-0 old-formula sweep found README:465 missing from the decomposer's fix list before any agent ran.
- Timing-guard suites and parallel agent load don't mix — run the attestation suite on a quiet machine, by design not by luck.

## Avoid / do differently

- When a dispatch brief says "X is out of your scope, define the convention here," HQ has just minted a reader with no writer. Blast-radius the convention in the same round.
- Check an agent's tool grant before writing a done condition that requires the tool (r1's C1 was HQ's brief assuming Write).
- Delta-scoped review rounds (r4) converge; full re-reviews (r2, r3) keep re-opening the field. Scope round N+1 to round N's findings + the fix diff.

## Cold-start context

**Branch:** `main` @ `6590b60`, clean, pushed. **Active milestone:** — (M47 ✅; next per ROADMAP sequence: M48 Review-Pipeline Hardening, whose /g-plan folds todo task 5 test-teeth riders). **Carry:** milestone close swarm (/g-patterns, /g-telemetry, /g-align, /g-wiki refresh, /g-doctor odd-count check) deferred from this close-out — context gate; run in the fresh session. Intake candidate: abandoned-stdin GUARD_WINDOW_MS bound (20s) vs worst-observed-under-load 24.3s — the repo's own ≥2× rule says revisit.
