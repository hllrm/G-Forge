# Forecast: W1.2 — Commit gate + native pre-commit hook

> Created: 2026-07-15
> Plan: g-docs/plans/.pending-forecast.md (pending approval → g-docs/plans/w1-2-commit-gate-pre-commit-hook.md)
> Mode: regular

## Complexity
- Score: 7/10
- Breakdown: files 2 (4 distinct: classify-changeset.sh, check-commit.sh, pre-commit, g-doc-review SKILL.md), waves 2 (3 waves), boundaries 1 (hooks ↔ skills), new surface 2 (new enforcement hook + new shared lib), rule edits 0
- Blast-radius file: none — no adjustment

## Miss-risk: 75% — Elevated

Est. tokens: 22k–67k (Medium)

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | Gate self-modification regression — editing check-commit.sh breaks the gate that gates the edit itself; the gate's own bugs obstructed committing during the last two passes | 4 | 3 | 12 | Run `bash tests/test-check-commit.sh` after EVERY task in the 2+3+4+5 chain, not just at chain end; keep a pre-change backup patch like the 2026-07-06 pass; commit with path-free messages until task 4 lands | 2026-07-13-bug2-triage-and-scope.md; m-audit-w1-enforcement-fixes forecast (scenario #1 fired live) |
| 2 | Stamper/verifier contract skew — pre-commit hook and /g-review//g-doc-review disagree on stamp fields or hash method → deny-storm or silent pass; ledger row 8d is a live instance (DOC sentinel wrote literal `approved` against a stamp-expecting gate) | 3 | 4 | 12 | Task 8's parser must copy field names byte-for-byte from skills/g-review/SKILL.md Step 6; task 10's fixture must generate its stamps by running the same commands the skill specifies, not hand-typed literals | M-audit ledger row 8d; ADR-004 Risks section |
| 3 | Existence-vs-content validation split violated — an implementer "helpfully" adds stamp-field validation to check-commit.sh, breaking the 22-test suite's bare-sentinel fixtures (or the suite passes while semantics drift, Bug-A family) | 2 | 3 | 6 | The design decision is explicit in the plan header; instruct the Wave-2 check-commit.sh agent that sentinel checks stay existence-only; suite green is a per-task done condition | Bug A history (test asserted exit 1 — invisible no-op); tests/test-check-commit.sh fixtures |
| 4 | Windows/git-bash portability quirk in the new hook (write-tree/rev-parse edge, CRLF, path normalization) — the dogfooding host is the environment where hooks historically failed open | 2 | 3 | 6 | ADR-004/005 primitives already verified live on this host (W1.1); task 10 sandbox runs on the same host; avoid `realpath -m`-style non-portable calls | memory windows-hook-gotchas; 2026-07-06 handoff (matcher fail-open) |
| 5 | Mid-run agent crash/revert — a Wave-1 process crash reverted 3 files during the last enforcement-fixes run; parallel Wave 2 writes two files concurrently | 2 | 3 | 6 | Keep per-wave backup patches in scratchpad (as 2026-07-06 did); Wave 2 agents touch disjoint files so recovery is per-file | 2026-07-06 handoff (⚠ Wave-1 process crash note) |

## Recommendations

Apply at least the top-2 mitigations before approving. Consider splitting the largest wave.
- Top-2 mitigations are execution-discipline items (suite-per-task + byte-for-byte stamp contract) — bake both into the Wave 2 agent prompts rather than re-scoping.
- Wave 2 is two parallel single-file chains — already minimal; further splitting adds waves without reducing risk. The 75% figure sits at the Elevated/High boundary: the dominant risks are process-history-driven (the gate has bitten three passes in a row), not scope-size-driven.
- Forecast assumes the historical pattern set is representative.

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | | |
| 2 | yes | | |
| 3 | yes | | |
| 4 | yes | | |
| 5 | yes | | |
