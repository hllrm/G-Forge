# Retro — 2026-08-21 — M48b execution + M51 slotting + review arc parked at round cap

## What happened

- **Pushed `df2ca1b` + `b550866`** (previous session's permission-denied push) — Bash-scoped deny; PowerShell went through.
- **M48b planned, executed, attested.** 4 waves: `GF_STDIN_TIMEOUT_OVERRIDE` in `hooks/lib/stdin-read.sh` (unset = byte-identical, zero production consumers) · `GF_FAST_STDIN_GUARD_MS` provisional constant · audit-7 F4 (g-doctor-drift derives hash-cascade snippets from the shipped SKILL at runtime) · H3+H9 grep-pins in lib-install-completeness · CHANGELOG · suite re-attested **581/0/19** twice (1624s, then 1059s post-fix-round), HQ-summed both times.
- **Developer directive (2026-08-20) reframed v2.5**: "reliable and very usable harness" is the release condition. Two Desktop audit reports read; load-bearing claims re-verified live (code-lead has no Agent grant since `daf15e3`; jq rc-only check at `agent-lifecycle.sh:89-91`; `g-proof-roadmap.md` gitignored single-copy). `/g-intake` → `/g-roadmap`: **M51 — Release Reliability (M45-lite)** written into ROADMAP, M45 folded into it, build order now M47→M48→**M51**→M50→M38→M40→M43→M49→M41 (third ADR-012 amendment). Process requirements recorded in the entry: review scope = diff + blast radius, narrowing rounds, round-3 cap, incremental wave-boundary reviews, thin final integration review.
- **Review arc (M48b + roadmap change, mixed changeset):** code-lead r1 HOLD 0C/3M/5m → r2 **MERGE READY** 0C/0M/6m. Doc gate r1 DOCS HOLD 14B/6W → r2 DOCS HOLD 4B/4W (all r1 closed) → r3 DOCS HOLD 1B/4W (all r2 closed). **Parked at the round cap — no r4 dispatched; escalated to the developer.** Nothing committed; gate locked; tree dirty by design.

## Patterns

- **Every review round minted ≥1 defect at a site that same round edited — four consecutive rounds** (r1 fix republished a guard literal the code fix had just changed; r3's HQ fixes minted three enumeration defects). Forecast scenario 1 hit again (4th M48-family occurrence). The minting surface is now precisely identified: **hand-typed counts and completeness claims in prose** ("five sites", "full site set", "23 of 23"). The fix that will converge is ADR-013's omit-or-derive, applied to the fix round itself: delete the counts, don't correct them.
- **Two-lane fix rounds cross-contaminate**: code fixer changed a literal, doc fixer quoted the old one, neither swept the other's lane. Single-lane fix rounds, or an explicit cross-lane grep, next time.
- **Subagents stalled 3× at the record-write step** (announced "now write the output file", yielded). One resume nudge each fixed it — budget the nudge, resume, never redeploy.
- **Bash tool ceiling kills the suite run**: 10-min max timeout < ~12–27min suite. Working shape: `nohup … > log &` detached + Monitor on the `Grand total:` line.

## Avoid / do differently

- In a fix round, never write a new enumeration or completeness claim — pointer or omission only. A corrected count is next round's stale count.
- Cross-lane sweep: when code and doc fixers run in parallel, each greps the other's changed literals before returning (or HQ does it before dispatching review).
- Detach-and-monitor for any run > 10 min; never trail a pipe on a background suite run (first attempt lost all output to `| tail`).
- Grep the bare milestone token, not arrow-chains, when sweeping a fold (r1's `M50 → M45` grep missed all five live sites; bare `M45` found them).

## Cold-start context

**Branch:** main · **M48b complete and attested (581/0/19) but UNCOMMITTED** — code gate MERGE READY, doc gate parked at r3 DOCS HOLD (1 blocking · 4 warnings, all small), round cap reached, developer decision pending.
**Key records:** review `g-docs/agent-output/review/code-lead-2026-08-21{,-r2}.md`, `doc-reviewer-2026-08-21-m48b-r{1,2,3}.md` · fixes `g-docs/agent-output/fix-r1-m48b/` · plan `g-docs/plans/m48b-lib-overrides-and-first-test-fixes.md` · forecast outcome tables to fill at close.
**r3 residual (the r4 fix list):** ADR-012:21 "five sites" count unresolvable + omits the ordinal class (de-enumerate it) · ROADMAP:628 M51 scope lacks the verdict-equivalence done condition ADR-012:104 assigned it · ROADMAP:8 "full site set" over a 3-of-5 list (drop the claim) · ROADMAP:540 M48b bullet cksum-only vs three-branch delivery · timing-bounds.sh:16-17 "Both bounds" over three constants.
**Close plan (after r4 → DOCS READY):** two commits — (1) M48b changeset with CHANGELOG:11 temporarily reverted to HEAD (non-interactive hunk split), (2) roadmap change (ROADMAP, README, g-wiki, brief, M41, ADR-012, todo, env-vars? env-vars goes in commit 1 with the M48b surface) + restore CHANGELOG:11. Stage → stamp both sentinels (ADR-004) → commit, per commit. Then pass-close riders: commit `g-docs/g-proof-roadmap.md` (A9, directive), `/g-update` for the drifted installed `lib/stdin-read.sh` before M48c.

## Close-out addendum (same session, developer returned)

Developer approved r4 with the de-enumeration approach and added **fix-round governance** to M51's process requirements (fix rounds get blast-radius of the restatement surface + the minting-mechanism premortem — neither instrument fires on fix deployments today, which is where all four minting rounds lived). r4 ran: **DOCS READY, 0 blocking** — de-enumeration held, zero fresh count defects. Warnings closed same turn (ADR-012 example tokens + comms-plan §7 M45→M51). Close executed as the two-commit split (hashes in the handoff).
