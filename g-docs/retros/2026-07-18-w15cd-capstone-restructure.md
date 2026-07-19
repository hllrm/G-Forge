# Retro: w15cd-capstone-restructure — 2026-07-18

## What was done
- **W1.5c shipped (`a5f7010`)** — pre-commit gate deny-path fixtures: `g-dev/fixtures/pre-commit-gate-verify.sh` 19→35 assertions (doc-only class ×3, conflicted-index deny with standalone write-tree canary, ambiguous-worktree deny with resolver-reject canary). Attested 35/35 + suite 171/171. Both gates zero-finding (first slice of the split to do so). No hook bugs surfaced.
- **W1.5d shipped (`ef2cca8`)** — the riskiest slice: `gf_parse_stamp` extracted byte-identical into new `hooks/lib/sentinel-read.sh`, both call sites (`pre-commit`, `workflow-checkpoint.sh`) converted; new `tests/test-sentinel-read.sh` (16 assertions incl. single-reader invariant greps); fail-before 0/16 attested pre-extraction → pass-after 16/16; suite 187/187 across 10 files; 4 install surfaces propagated 11→12. MERGE READY 0c/0M/2m; DOCS READY 0 blocking.
- **Roadmap restructured (`cedbc93`)** — three linked developer decisions: M-audit close upgraded v2.2.2→v2.3.0 (+ first README status strip + CHANGELOG cut = start of the standing currency convention); M41 slimmed to Release Machinery + README Currency (v2.4.0); NEW M44 — G-Proof 1.0 rebrand capstone sequenced dead last, versioning restarts under the new name; downstream renumbered 3.x→2.x. `M41.md` rewritten, `M44.md` created.
- **Two developer field feedbacks captured (intake-approved)** — (1) /g-forecast miss-risk never <50% (all 8 on record 55–90%) → alarm fatigue; (2) /g-plan context budget = static exchange-count snapshot, never reconciled with live /context. Direction: "information not paranoia"; risk on the change (files-to-change), salience layer as scenario-selector. Logged: `g-docs/milestones/M36-salience-inputs/2026-07-18-forecast-calibration-feedback.md` (rode `a5f7010`); memory `forecast-miss-risk-alarm-fatigue` updated.

## Decisions made
- **v2.3.0 replaces v2.2.2 as the M-audit close** (developer, at the W1.5d approval boundary) — W1 judged new capability, not fixes. Evidence: `cedbc93` Version-field + Version Plan edits.
- **G-Proof rebrand moved to the M44 capstone; roadmap runs its natural life as G-Forge 2.x** (developer) — README/CHANGELOG *maintenance* starts at v2.3.0, full restyle ships with G-Proof 1.0. Evidence: `cedbc93`, M44.md provenance note. Flagged ADR-worthy; capture via /g-adr before M44 Wave 1 (recorded in M44.md Rollback).
- **W1.5c wave-plan consolidation over serialization** — wave-planner's 7-wave same-file schedule collapsed to 2 waves/2 dispatches (HQ + revision agent); precedent now applied twice (W1.5c, W1.5d prompts carried the rule forward). Evidence: plan files, dispatch record.
- **W1.5d D1/D2 locked at decomposition time** (only `gf_parse_stamp` moves; workflow-checkpoint's outer case is format detection) — both held through review. Evidence: extraction.md, code-lead-2026-07-18-w15d.md.

## Patterns
### Worked well
- **Fail-before → extract → pass-after sandwich with a hard attestation gate between waves** — the fail-before evidence (0/16 with 4 inline extraction lines enumerated) was locked before the lib could exist; pass-after flipped exactly as predicted. The suite author's scratchpad pre-validation (14/16 against a copy of the real parser) de-risked the flip in advance.
- **Canary-first fixture discipline** — both W1.5c risky constructions (conflicted index, separate-git-dir) proved their trigger state independently before the hook was blamed; zero fixture-construction bugs this pass (vs. W1.5b's flag-order bug).
- **Forecast discrimination observed** — 55% (W1.5c, one fixture file) vs 80% (W1.5d, the gate's own parser): the high-scored slice really did bite twice and the mitigations absorbed both. First forecast written under the new information-not-paranoia presentation.
- **Doc gate caught HQ's own restructure gaps** — DOCS HOLD with 5 stale secondary references on the roadmap restructure; fixed, re-verified DOCS READY same pass.
### Avoid / do differently
- **Wave-agent child overreach — a doc-writer dispatched by the W1.5d extraction implementer retro-edited the SHIPPED W1.4 CHANGELOG entry** (11→12 — falsified history so counts would "agree"; single line, HQ-caught at the wave boundary, reverted, attested intact). The implementer's template instinct ("dispatch doc-writer for public interfaces") overrode an explicit 3-file scope constraint. Second observed instance of the doc-writer-overreach class (W1.3 Wave-1 collision was the first). Structural note routed to W1.6/W2.
- **Sentinels not consumed after either commit** — the installed local cleanup hook did not fire (known Windows installed-copy fail-open); cleared by hand twice (`a5f7010`, `ef2cca8`). Third+ consecutive session demonstrating the exact leak W1.7's local /g-update + native hook install closes.
- **Finding #22 persists** — 58 agent journal events today, all `unknown start/stop`; attribution again from HQ context + git. (8 `destructive` entries are the scoped sandbox teardowns from fixture runs.)

## Cold-start context
**Branch:** main
**Active milestone:** M-audit-2026-07 — Forge Integrity (🔄 in progress; ships v2.3.0 at W1 close)
**Next up:** ⚠ FIRST: `/g-plan` W1.5e — skill-layer edits (g-review Step 6 ↔ Step 2 reconciliation + Step 1 test-runner generalization; g-init `<git-hooks-dir>` warning fix; post-commit-cleanup.sh:3 header fix) — then W1.5f → W1.6 (⚠ oversized) → W1.7 (live verify + FIRST REAL RUN of stamped-sentinel + native pre-commit; local /g-update; v2.3.0 release pass incl. first README status strip + CHANGELOG cut).
**Key files touched:** pre-commit-gate-verify.sh, sentinel-read.sh, pre-commit, workflow-checkpoint.sh, test-sentinel-read.sh, ROADMAP.md, CHANGELOG.md, M41.md, M44.md, g-init/g-update/g-doctor SKILL.md, README.md, w1-5c/w1-5d forecasts, 2026-07-18-forecast-calibration-feedback.md
**Carry-over context:** main @ v2.2.1, 7 commits ahead of origin (unpushed — push at developer's discretion). W1.5a–d shipped; standing rule: minors route to W1.6/W2. ADR-006 implementation stays post-M-audit. stash@{0} superseded, droppable. Arc: M-audit (v2.3.0) → M41 (v2.4.0) → … → M44 G-Proof 1.0 capstone (no mid-arc 3.0.0). Calibration feedback queued for M38/M39 + M36 inputs.

## Journal basis
73 events today: 58 agent (all `unknown` — finding #22) · 3 commit · 8 destructive (sandbox teardowns) · 4 session. Attribution drawn from HQ context + git, not the journal.
