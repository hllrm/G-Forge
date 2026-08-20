# Retro — 2026-08-20 — M48a review, fix rounds, and close

## What happened
- `/g-resume` → `/g-review` on the handed-off M48a changeset. code-lead round 1: **HOLD, 1 Critical · 18 Major · 11 Minor** (both cautious-profile reviewer passes agreed on the Critical: the new required sweep had no sanctioned executor).
- Fix round 2 (4 implementers: doc-gate contract, runner, rule text, records sweep) closed 24/25 blockers but **minted 4 new Majors** — leaked scratch file its own record denied, the M1 capture-stall mechanism reintroduced in the runner's own test, a README pointer at gitignored CLAUDE.md, the refuted procedure left in the durable ROADMAP block.
- Round 3 (1 implementer, 9 items) closed everything but staled CHANGELOG:28 (its own M7 fix). Round 4: HQ inline, 4 sites → **MERGE READY**.
- Doc gate, first live run under its new contract: **r1 DOCS HOLD 4B/5W** (caught the false "two heaviest" ordering basis and the write-tree misdescription four code rounds missed) → fixes → **r2 DOCS HOLD 2B/5W** (the fix missed 1 of its own 7 carriers; the fix staled CHANGELOG:29) → fixes + HQ grep re-sweep → **r3 DOCS READY** + r4 one-line addendum, 0/0.
- Committed `df2ca1b` (15 files, both sentinels, one stamp, ADR-004). **Push denied at the permission layer — commit is local.**
- Suite attested 4×: 564/18 pre-review baseline, then 575/19 ×3 (post-wave, post-round-3, final tree). Wall-clock 1242s → 709–775s from the M1 capture fix.

## Decisions
- **C1 owner (developer):** doc-reviewer holds a record-scoped `Write`; the sweep runs inside its live dispatch. Prefigures the M50/M45 reviewer-contract decision for the remaining 11 agents (todo row 6).
- **M7 path scheme (HQ):** round ordinal `-r[N]`, highest-plus-one, records never deleted — the record series IS Step 2c's state source.
- Falsifiability procedure: scratch-copy only (no restore hazard); comment is provenance, probe output goes in the pass record.

## Patterns
- **The milestone's thesis proved itself on its own changeset, twice.** Every fix round minted at least one defect of the exact class M48a exists to kill; both forecasts' scenario 1 hit. What converged it (30→9→4→0) was scoping round N+1 to round N's sites + same-turn re-derivation of every stated fact.
- **A sweep scoped by line numbers cannot cover semantic changes** (code-lead round-2 root cause). The doc gate's whole-block reading caught what the line-list sweeps missed.
- **The two-gate split worked**: the doc gate found 4 blocking accuracy defects after the code gate went MERGE READY — different lenses, not redundancy.
- **doc-reviewer's Grep/Glob tooling failed both sessions** (`EUNKNOWN uv_spawn`, standing) — it disclosed honestly and HQ ran the greps. Platform issue to watch; the gate's evidence contract survived because Step 2b lets HQ own recorded sweeps.
- Subagent silent-stall pattern recurred ×5 (doc-writer ×3, round-3 implementer ×1 + one prior-session case) — resume-with-nudge works, but budget the round-trips; HQ finished the doc-writer's remainder inline after stall 4.
- **Never edit a script a background run is executing** — bash reads incrementally; the mid-run comment edit crashed a green suite run at the summary (exit 2, phantom syntax error). Three other run kills were external, cause unknown.

## Avoid / do differently
- Scope fix-round sweeps by *reading the whole affected block against what landed*, never by a list of remembered line numbers.
- When a fix changes a fact, grep the fact's old literal the same turn, including the CHANGELOG entry describing the fix itself — the release note is a carrier too (missed twice this pass).
- Don't start the attestation suite run until every edit — including prose — is landed; comment edits to a running script kill the run.
- An agent's "no leftover files" claim is a disk check, not a prose claim: `git status --porcelain` pasted, or it didn't happen (N1).

## Cold-start context
**Branch:** main · **M48a ✅ `df2ca1b` (LOCAL — push pending permission)** · next `/g-plan` M48b
**Key files:** skills/g-doc-review/SKILL.md (new contract) · agents/doc-reviewer.md (lens 5 + Write) · rules/g-rules/H-testing.md (falsifiability) · tests/run-all.sh + tests/test-run-all.sh (575/19 baseline)
**Carry:** push `df2ca1b` · AFK settings residue decision · §A7 25%-USED doc task · CLAUDE.md:32 count stale (564/18 → 575/19, local file) · review-holds 28 · doc-reviewer Grep tooling failure standing
