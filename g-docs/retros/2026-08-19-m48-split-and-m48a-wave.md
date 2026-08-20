# Retro: m48-split-and-m48a-wave — 2026-08-19

## What was done
- **Prior pass committed and pushed** (`b70f524`, 2026-08-18): ADR-013 clean-slate verification (all claims held), first-ever `/g-trim` completion, README 2.5-statement rewrite — DOCS READY 0 blocking, ADR-004 flow clean.
- **M48 planned, then split into M48a–M48e** at `/g-plan`'s Step 3c budget gate: task-decomposer produced 17 tasks / 0 clarifications; wave-planner scheduled 6 waves / 17 slots; estimate ~74 exchanges vs ~33 remaining. Developer first accepted the handoff risk, then chose the split when presented at the approval gate. Split follows the wave-dependency structure (each sub ≈ one wave, one session, own review + commit); durable record written into the ROADMAP M48 entry.
- **M48a Wave 1 executed via `/g-afk`, 4/4 DONE**: fix-closure sweep (Step 2b, required) + round-3 consolidation note (Step 2c, advisory) in `skills/g-doc-review/SKILL.md`; volatile-fact heuristic (lens 5) in `agents/doc-reviewer.md`; falsifiability comment rule in `rules/g-rules/H-testing.md`; `tests/run-all.sh` (glob-derived suite set, subset-checked ordering hint, summed totals, proven identical to serial across two full real runs — 564/0/18 both).
- **Session closed at the corrected context gate** (25% usage crossed) with M48a's `/g-review` NOT yet run — handed off.

## Decisions made
- **Split over proceed** (developer, at the approval gate after initially choosing proceed at the budget gate): five subs M48a–M48e, order pinned a→e, all ride v2.5.0. Evidence: ROADMAP M48 entry, 2026-08-19.
- **§A7 context gate corrected** (developer): the session is unsafe past **25% of the window USED** — not "reset when remaining < 25%" as the shipped rule text says. Acted on immediately (this close); saved to auto-memory (`context-threshold-25-percent-usage`); shipped `rules/g-rules/A-session.md` + `hooks/workflow-checkpoint.sh` wording queued as a doc task.
- **Task-17 heredoc fix kept as CANDIDATE**, deferred to M48e's plan approval. Decomposer refuted the scope brief's claim that `hooks/pre-commit` consumes `commit-detect.sh` (grep-verified: sole consumer is `hooks/check-commit.sh:222`).
- **HQ accepted task 4 with its wall-clock clause unmet**: reordering cannot shrink a serial sum — a plan-time misphrasing, not an implementation failure. Recorded in the plan Progress notes rather than papered over; the real lever (fast guard windows) is M48b/c scope.

## Patterns
### Worked well
- The budget-gate → split flow produced a better plan than the monolith: five committable increments, each with its own gate, along dependency lines already computed — no re-decomposition needed.
- Scoped dispatches stayed cheap and honest: decomposer 0 clarifications and one genuine scope correction; doc-reviewer (prior pass) verified 27/27 claims; wave agents returned compact blocks with real evidence (run-all pasted both proof runs).
- ADR-013 discipline caught a live error at HQ: a hand-typed "5 @-imports" in the handoff was wrong (4) and fixed before commit — the rule works when applied in the same turn.

### Avoid / do differently
- **"Reorder for wall-clock" was a plan-time arithmetic error** — reordering serial suites can never reduce total runtime, only perceived progress. A done condition promising "lower measured wall-clock" from reordering alone was unfulfillable as written. Check the mechanism can deliver the metric before writing it into a done condition.
- **The workflow-checkpoint amber and §A7 text pointed at the wrong gauge** — "remaining < 25%" let a 29%-used session read as healthy. The developer's correction (25% used) is the operative rule until the shipped text is fixed.
- **A background-waiting subagent stops silently**: the run-all agent yielded to wait on its own background suite run and needed an explicit resume nudge (Interrupted ≠ FAILED — resumed, not redeployed). Budget for one resume round-trip when an agent's task includes long shell runs.
- **AFK's settings write is one-way**: `/g-afk` merges an `allow: Bash(*)` block into `.claude/settings.json` and never removes it — residue that auto-approves everything for future sessions. Strip-or-keep is a pending developer decision (in the handoff); a cleanup step belongs in the skill (G-Proof-side fix, or M48-family rider).

## Cold-start context
**Branch:** main
**Active milestone:** v2.5 arc — M48 split a–e; M48a wave complete, review pending; then M48b–e, M50, M45, M38, M40, M43, M49, M41
**Next up:** Fresh session → `/g-resume` → `/g-review` the uncommitted M48a changeset (suite direct via `bash tests/run-all.sh`) → commit (mixed: both sentinels, one stamp) → `/g-plan` M48b
**Key files touched:** skills/g-doc-review/SKILL.md, agents/doc-reviewer.md, rules/g-rules/H-testing.md, tests/run-all.sh (new), g-docs/ROADMAP.md (M48 split + handoff), g-docs/forecasts/m48*.md (2 new), g-docs/plans/m48a-doc-gate-teeth-and-runner.md (gitignored)
**Carry-over context:** the `Active context:` line of the `## Active Session` block in `g-docs/ROADMAP.md` (25%-USED gate · ADR-013 · M48a records · ADR-004 flow · AFK settings residue)

## Journal basis
2026-08-19: 38 events, all agent-kind (wave dispatches/stops, review dispatches, resumes). The `b70f524` commit+push landed under 2026-08-18's journal. No test, revert, or destructive entries.
