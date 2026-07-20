# Retro: dogfood-gap-adr008 — 2026-07-19 (second retro this date — deliberate double, developer-approved: this thread forked after the W1.5f retro closed and none of it was captured)

## What was done
- **Finding #28 discovered and measured — the dogfood gap.** Trigger: the W1.5f retro's irony note (#22 fixed in source, journal still blind). Developer asked whether we should deploy changes internally before shipping; measurement answered harder than expected: 7/7 installed hooks drift, `.claude/hooks/lib/` absent entirely (install predates W1.1), native `pre-commit` not installed, skills+agents cache-pinned at v2.2.1 and drifted, 0/10 g-rules section files installed (G-RULES `@`-includes silently no-op — **sessions here have never loaded doctrine sections A–J**). The W1.5f commit was gated by the v2.2.1 gate containing the bugs W1.5a fixed. All three field bugs were consumer-found because the canary reports on vN−1 by construction.
- **ADR-008 recorded (Accepted, two-way door):** `g-docs/decisions/008-self-host-working-tree-split-cadence.md` — working-tree self-host; cadence split by hook class (non-gating eager at slice close / gating clone-first at verified checkpoints); mechanism = self-host-aware `/g-update`+`/g-init` (root `plugin.json` name-match flips source root — kills the stale-cache footgun structurally); #27 reclassified prerequisite (verification before installation); routine drift check in `/g-review` Step 1; never-exit-nonzero suite invariant enforcing the class split; skills/agents layer factually out of scope (cache-pinned by construction) → Spike S1.
- **Off-context deliberation resolved a scope-determining fact:** skills/agents **cannot** be locally shadowed — command routers hardcode the cache Glob; plugin skills/agents occupy the `g-forge:` namespace; the apparent counter-example (`claude-plugin-architect`) is a profile agent, a copy-install path not a shadow. True scope = hooks + rules + profile agents.
- **Risk pricing corrected mid-thread:** the original "recoverable in seconds" reassurance leaned on PreToolUse terminal-commit blindness — which is the enforcement hole ADR-004 exists to close. Re-priced on git-level hatches only (`--no-verify`, hook-file delete), which survive ADR-004.
- **Repo preservation executed before any decision:** full `.claude/` + git-hooks-dir snapshot to scratchpad (`claude-install-snapshot-2026-07-19`); source integrity confirmed at `e38f474`.
- **W1.5g inserted** (roadmap slice with full task sketch for the next `/g-plan`); **W1.7 rescoped** (gating-hook clone-first checkpoint; local `/g-update` task moved into W1.5g via the new mechanism); ledger row #28 written, #27 cross-linked.

## Decisions made
- **ADR-008 Accepted with all four implementation forks resolved now, not deferred** — developer challenged the initial defer-the-forks proposal ("best solution or least blast radius?"); re-analysis showed all four are evidence-determined two-way doors with no pending information → deferral was pure loss. Mechanism: self-host-aware /g-update. #27: prerequisite. Check 16: routine loop in /g-review Step 1. Gating: clone-first.
- **Execute W1.5g in a FRESH window, not this one** (developer offered; declined on discipline, not headroom): the entry gate is verifying ADR-008 clean-slate, and this window authored it — same-eyes verification is the exact anti-pattern the thread exposed. ADR-006 precedent followed: all docs left uncommitted for the fresh session to verify-then-commit.
- **Double retro approved** (developer) — the skip-rule assumes same-ground coverage; this thread is disjoint from the W1.5f retro.

## Patterns
### Worked well
- **The retro→question→measurement chain.** A single honest "avoid" bullet (installed-copy lag) → developer's deploy-internally question → 3-command measurement that overturned the working assumption ("we dogfood") with hard counts. Writing uncomfortable observations down is what makes them findable.
- **Developer challenge improved the decision twice:** "is this the best solution or the least-blast-radius one?" forced the fork resolutions and surfaced the mechanism design; earlier, "grill my feelings" set the register for honest analysis. The tooling followed the human.
- **Off-context deliberation caught a scope ceiling HQ would have missed** (namespace/router evidence for cache-pinning) and flagged the escape-hatch/ADR-004 tension — the second time the g-adr seam has materially changed a decision (first: ADR-006's three design holes).
- **Snapshot-before-decide.** Preservation cost ~30 seconds and made every subsequent option reversible; the rollback contract existed on disk before the ADR referencing it.
### Avoid / do differently
- **A permanently-red required check is a disabled check.** Check 16 existed, was required, would have flagged all seven drifts — and was in no routine loop. Alarms need a loop that fires them, or they are documentation. (Now structural: /g-review Step 1.)
- **"Shipped" and "live here" were conflated for months.** Every "the enforcement layer actually enforces now" claim was true of source and false of the runtime. Claims about self-state need the same verify-don't-trust treatment as ADR claims.
- **HQ initially offered emotional management instead of analysis** (defer-the-forks framed as prudence, calibrated to a misread of developer state). The developer caught it in the thinking process. Corrective: this developer prices risk professionally — deliver the engineering answer; state fear-shaped reasoning as such if it exists.
- **The g-adr deliberation grounded in repo files but not platform capabilities** — the local-marketplace dev-install path (Spike S1's subject) was invisible to it. Deliberation prompts for platform-adjacent decisions should direct the analyst at platform mechanisms too.

## Cold-start context
**Branch:** main
**Active milestone:** M-audit-2026-07 — Forge Integrity (🔄; v2.3.0 at W1 close)
**Next up:** ⚠ FIRST: verify ADR-008 against actual repo state (clean-slate, fresh window) → commit the ADR/ledger/roadmap/retro docs (all UNCOMMITTED — ADR-006 precedent) → `/g-plan` W1.5g (full task sketch on the roadmap bullet: #27 → mechanism → routine check → invariant → non-gating install → Spike S1) → W1.6 → W1.7 (rescoped: gating clone-first checkpoint).
**Key files touched:** 008-self-host-working-tree-split-cadence.md (new), M-audit-2026-07.md (#28 row, #27 reclassified), ROADMAP.md (W1.5g slice, W1.7 rescope, handoff FIRST), this retro. Snapshot: scratchpad claude-install-snapshot-2026-07-19.
**Carry-over context:** main @ e38f474, 9 commits ahead of origin (unpushed). W1.5a–f shipped. ADR-007 verify-before-W2 still stands. Installed runtime remains v2.2.1-era BY DECISION until W1.5g executes (do NOT run /g-update before the mechanism ships — it would install stale cache over source; the footgun is live until W1.5g task 2). stash@{0} superseded, droppable.

## Journal basis
Same-day journal (136+ events) still attributes nothing — all agent events `unknown` (finding #22 fixed in source, not yet live here; that gap IS this retro's subject). Attribution from HQ context + git.
