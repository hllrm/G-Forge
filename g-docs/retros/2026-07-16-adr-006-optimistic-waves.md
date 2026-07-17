# Retro: adr-006-optimistic-waves — 2026-07-16

## What was done
- **/g-review W1.3 (six hook worktree integrations) → MERGE READY.** Suite attested 60/60 (22+3+16+5+9+5); code-lead verified all 9 done conditions structurally (0 critical, 0 major, 4 minor routed to W1.4/W1.5/W1.6); prior implementer's phantom W2/W3/W6 "bugs" re-confirmed absent against live files. Tier-3 satisfied by the sandbox model (no-manual-QA doctrine). Approval sentinel written; commit gate open. Record updated: ROADMAP W1.3 bullet, M-audit ledger row `11i–18i`, handoff FIRST line. Report: `g-docs/agent-output/review/code-lead-2026-07-16.md`.
- **/g-patterns run (post-milestone-review mining).** Corpus: 7 retros · 4 forecasts · todo-done · git. One Systemic pattern surfaced: `parallel-agent-file-collision` (weight 3 — retro + forecast predicted-and-hit). Emerging: #21 and #22 recurrences (both already-scoped code fixes, not rule edits). Triage of the collision pattern escalated into a design conversation instead of the proposed prompt-rule band-aid.
- **ADR-006 written and Accepted:** `g-docs/decisions/006-optimistic-wave-concurrency-collisions-absorbed.md` — optimistic wave concurrency; collisions are a controlled risk (detected, bounded, absorbed in-band) via wave-open baseline sweep + flight recorder (`git hash-object -w` + append-only log) + owner-aware wave-close integrity check with report-first restore + `NEEDS_GLOBAL`→HQ + solo-wave rule + frozen 3-verb friction deny. Worktree isolation off-doctrine behind a quantitative re-open trigger (absorption cost >5% of wave tokens over rolling 5 waves). Deliberation ran off-context (single-use analyst subagent); its stress-test produced three real design amendments (untracked-file baseline sweep; ownership-aware sha comparison; report-first restore) that were folded into the Decision. All 8 flagged weaknesses closed with explicit dispositions (designed-in / defined-now / instrumented).
- **Pattern triage closed:** `g-docs/patterns-deferred.md` entry logs `parallel-agent-file-collision` → resolved by ADR-006; the prompt-rule edit survives only as ADR-006 parts 3–4 (advisory, backstopped), never load-bearing alone.

## Decisions made
- **ADR-006 (Accepted, two-way door):** wave concurrency is optimistic; absorb collisions, don't prevent them; mechanisms key on content hashes, never command strings (#21 lesson applied). Evidence: the ADR file + this session's transcript-driven deliberation.
- **B-lite (command deny-gate) rejected as #21-shaped**, except a frozen 3-verb friction core (bare `git stash`, `git reset --hard`, tree-wide `checkout --`/`restore`) — list frozen by rule, extension prohibited.
- **Re-open trigger defined quantitatively** so the doctrine is self-falsifying from the first instrumented wave.
- **W1.3 declared review-complete without further split** — the ⚠ oversized flag on W1.3 proved unnecessary at review time (single code-lead pass, no HOLD round).

## Patterns
### Worked well
- **Off-context deliberation earned its keep** — the throwaway analyst found 3 design holes HQ's inline reasoning had missed (pre-existing untracked files unprotected; ownership-blind sha comparison; restore-over-human-edits), plus 3 unnamed alternatives. The g-adr seam (weigh off-window, promote only the draft) demonstrably improved the decision.
- **Single-pass MERGE READY** — W1.3 cleared review with zero critical/major on the first round; the prior session's HQ verification of phantom agent findings meant the review started from trusted ground truth.
- **Developer-led doctrine reframe** — the collision fix went from "pick a wall" to "change the objective function" (steady operativity, accommodate collisions) because the developer challenged the premise; the tooling followed the human, not vice versa.
### Avoid / do differently
- **Finding #22, third consecutive retro** — all 25 agent journal events today are `unknown start/stop`; this retro again attributes work from HQ context + git, not the journal. The learning loop's evidence base stays degraded until W2 lands.
- **Commit still pending at session end** — MERGE READY was issued and the sentinel written, but W1.3 remains uncommitted (11 files + stash residue); the approval now spans a session boundary, which ADR-004's stamp binding exists to make safe, but it lengthens the exposure window.

## Cold-start context
**Branch:** main
**Active milestone:** M-audit-2026-07 — Forge Integrity (🔄 in progress, ships v2.2.2)
**Next up:** ⚠ FIRST: verify ADR-006 against actual repo state (clean-slate check) → commit W1.3 (sentinel written, gate open) → `/g-plan` W1.4 (install wiring + drift). ADR-006 implementation is a post-M-audit milestone slice — do not wedge into W1.
**Key files touched:** 006-optimistic-wave-concurrency-collisions-absorbed.md, patterns-deferred.md, ROADMAP.md, M-audit-2026-07.md, code-lead-2026-07-16.md, g-forge-approved (all uncommitted except none; W1.3 hook diffs carried from prior passes)
**Carry-over context:** W1.3 reviewed MERGE READY (0c/0M/4m routed W1.4–W1.6; strongest advisory = extract workflow-checkpoint's stamp parser to hooks/lib). ADR-006 Accepted, needs fresh-session verification before its implementation slice is planned. stash@{0} droppable once working tree confirmed authoritative. Cleanup queue unchanged (Confluence 109314050 + Drive + Gmail labels).

## Journal basis
35 events today (25 agent · 9 session · 1 destructive — the scoped sandbox teardown). Agents logged as "unknown" (finding #22); attribution drawn from HQ context + git, not the journal.
