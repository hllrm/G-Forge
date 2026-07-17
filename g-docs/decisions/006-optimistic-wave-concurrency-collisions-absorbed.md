# ADR-006: Adopt optimistic wave concurrency — collisions absorbed, not prevented

**Date:** 2026-07-16
**Status:** Accepted
**Reversibility:** two-way door (reversible — all mechanism is additive: hooks, one skill step, one planner tag; removable in under a day; the doctrine itself carries its own defined switch-away trigger)
**Context:** G-Forge wave orchestration (`/g-execute`, wave-planner contract, hooks layer)

## Context

Parallel wave agents share one physical working tree. Wave planning partitions *logical* file ownership (disjoint files per agent), but any tree-global command — `git stash`, `git checkout -- .`, `git reset`, `rm` — operates on the shared filesystem/index and blows through the partition. Observed live in M-audit W1.3 Wave 1: a doc-writer agent ran stash + checkout-revert + `rm` of an untracked file as "cleanup," wiping a sibling agent's hook integration and a pre-existing forecast file mid-wave; recovery was manual and costly. The incident was predicted by the wave premortem (forecast w1-3 §4) and weighted Systemic by `/g-patterns`. Constraints: finding #21's lesson that string-classifying commands is an unwinnable open set; token economy; and the prime directive that steady operativity must not be perturbed by collisions — the system should absorb them.

## Decision

Wave concurrency is **optimistic** (optimistic-concurrency-control, not pessimistic locking): agents run full speed on the shared tree; collisions are a **controlled risk — always detected, damage-bounded, absorbed in-band** as routine orchestration hygiene, never an incident. Mechanism keys on **effects (content hashes), never on command strings** (the #21 lesson). Six parts:

0. **Wave-open baseline sweep** — at wave start, hash every dirty *and untracked* file into the git object store (`git hash-object -w`) and journal it. Pre-existing state a wave agent never writes is thereby restorable (the W1.3 forecast-file casualty class).
1. **Flight recorder** — a PostToolUse hook fires after every wave-agent Write/Edit: `git hash-object -w <file>` (blobs survive stash/checkout/reset/`rm`; gc horizon ≫ wave lifetime) + append `<timestamp> <agent> <sha> <path>` to an append-only log resolved to the **common git dir** (`--git-common-dir`, ADR-005-coherent — one telemetry stream per project). A SubagentStop sweep hashes the agent's `owns:` scope to catch Bash-side writes.
2. **Wave-close integrity check** — a routine `/g-execute` boundary step: re-hash each journaled path and compare against the **owner's last recorded sha** (never the globally-last write — an offender's own logged clobber must not mask itself). Mismatch ⇒ mechanical restore via `git cat-file blob`, **report-first when the intervening writer is not a wave agent** (the absorber never silently overwrites HQ/human edits). Verification that ran against clobbered content is re-run, not just bytes restored. Wave report gains an `integrity: N restores` line. **Fail-loud is double-enforced:** a hook-side tripwire (SubagentStop marks that agents ran; empty flight log + marker ⇒ loud error artifact) plus the skill-step check — the auditor is not softer than the audited.
3. **`NEEDS_GLOBAL` → HQ** — wave agents never run tree-global operations; they return `NEEDS_GLOBAL: <op> — <why>` (alongside DONE/FAILED/BLOCKED) and HQ — the only seat with global context — decides and executes. Generalizes "agents never commit; HQ commits."
4. **Solo-wave rule** — a task tagged `global: true` at plan time is never co-scheduled; it gets a wave of one.
5. **Frozen friction deny** — in wave-agent context, deny exactly three verbs: bare `git stash`, `git reset --hard`, tree-wide `git checkout --` / `git restore`. The list is **frozen at three by rule**: it claims no guarantee, only frequency reduction, and any urge to extend it is the #21 open-set signal — the answer is no.

**Dependency statement:** parts 3–5 are advisory/friction frequency-reducers and are valid **only because parts 0–2 mechanically backstop them**. They are never load-bearing alone.

**Re-open trigger (quantitative, defined now):** prevention via per-agent worktree isolation is **off-doctrine** — not merely deferred — unless *absorption cost* (tokens spent on restores + re-running invalidated downstream/verification work, measured per wave from the flight log and wave report) **exceeds 5% of wave tokens sustained over a rolling 5-wave window**. Crossing it opens a successor ADR for worktree isolation; the flight log is the arbitrating instrument.

## Alternatives considered

| Option | Why rejected |
|--------|-------------|
| A — Prompt containment rule alone | Advisory only; the W1.3 offender was already under disjoint-ownership instructions and ran stash + revert + `rm` anyway. Advice is not a mechanism (same rejection lineage as ADR-004's "docs warning"). Survives only *inside* this design as parts 3–4, explicitly backstopped. |
| B — Per-agent `git worktree` isolation (pessimistic locking) | ~150–400k token build + 3–6%/wave recurring + merge-back complexity + entanglement with ADR-005's open worktree follow-ups, against a rare, now-bounded failure. Certain recurring cost vs. rare bounded cost. Kept behind the quantitative re-open trigger. |
| B-lite — PreToolUse deny-gate enumerating "dangerous" commands | #21-shaped: command-string classification is an open set; the commit gate already fell into this trap. Adopted only as the frozen 3-verb friction layer (part 5) claiming no guarantee. |
| C — Wave-open snapshot only | Protects pre-existing state but not the wave's own mid-wave output — half the W1.3 damage. Its baseline half is adopted as part 0; alone it is insufficient. |
| D — Per-agent checkpoint commits / temp refs | Committing manipulates the shared index — the mechanism would itself be a tree-global collision source. `hash-object -w` records content without touching the index. |
| E — Continuous mid-wave integrity checking | Lower detection latency at recurring cost, without evidence of need. The flight log measures whether mid-wave waste ever justifies it; if so, this is the cheap first escalation before worktrees. |
| F — Filesystem-level protection (read-only non-owned files) | Same-OS-user reversibility; Windows/POSIX divergence on this repo's weakest platform; re-opens the #21 open set at the FS layer. |

## Consequences

**Easier:** Near-zero recurring token cost (hooks run off-model; only the `integrity:` line and occasional `NEEDS_GLOBAL` round-trips are model-visible). Worst case bounded and mechanical: restores + at most one wave-slice of invalidated work — vs. W1.3's manual archaeology. Collisions downgrade from incident to log line, serving steady operativity directly. Free telemetry: the flight log is the evidence stream that arbitrates its own re-open trigger — the decision carries its own falsification instrument. Self-similar with ADR-004 (detect-and-invalidate over prevent) and composes with ADR-005 (common-dir resolution). M-audit W1 proceeds unwedged.

**Harder / constrained:** Collisions still occur; detection is deferred to the wave boundary, so intra-wave downstream work can build on clobbered content — and verification that ran against clobbered files must be re-run after restore (the W1.3 "phantom bugs" were stale-snapshot reads). The absorber inherits hook reliability on a repo with documented Windows fail-open history (mitigated: Check 16 drift detection + double-enforced fail-loud). `/g-execute` gains a mandatory boundary step; wave reports and the wave-planner contract change. Loose-object accumulation is harmless within gc horizons, but the log's archival value outlives blob reachability.

**Follow-up decisions:** Implement post-M-audit as its own milestone slice: baseline sweep + recorder hook + SubagentStop sweep + tripwire, wave-close integrity step (owner-aware, report-first), `NEEDS_GLOBAL` as fourth terminal status, `global: true` planner tag, frozen 3-verb deny, `integrity:` wave-report line. Flight-log lifecycle (rotation; gc interaction for telemetry afterlife). Stash-residue hygiene (`stash@{0}` from the incident). Measure absorption cost per the defined trigger from the first instrumented wave.

**Risks:** Hook fail-open silently disarms the recorder — the one failure converting "controlled risk" back to "uninsured risk"; countered by the double-enforced tripwire, accepted as residual. Stop-time sweep races a destroyer that fires before the victim's stop (residual, bounded by part 0's baseline). Out-of-scope Bash writes by an offender escape capture; only the victim's own recorded writes make its files recoverable — acceptable because recovery, not attribution, is the goal. n=1 evidence base: the premortem hit confirms the failure *mode*, not its *rate* — closed by instrumentation, since the flight log measures the true rate from wave one and the trigger makes the doctrine self-falsifying.

## Rejected Alternatives

| Alternative | Deciding factor |
|-------------|-----------------|
| A — Prompt rule alone | Already violated live under existing instructions; advice is not a mechanism. |
| B — Worktree isolation | Certain recurring cost against a rare, bounded failure; behind a defined quantitative re-open trigger, not discarded. |
| B-lite — Open-ended command deny-gate | Finding #21: string-classifying commands is an unwinnable open set. Only a frozen 3-verb friction core survives, claiming no guarantee. |
| C — Wave-open snapshot only | Cannot protect mid-wave agent output created after the snapshot. |
| D — Checkpoint commits / temp refs | Shared-index manipulation — the guard would itself be a collision source. |
| E — Continuous mid-wave checking | Recurring cost without measured need; first escalation candidate if the log proves mid-wave waste. |
| F — FS-level read-only protection | Same-user reversibility; Windows semantics; #21 open set at the FS layer. |

## Assumptions That Held

- **Disjoint wave planning keeps collision frequency low.** Fragility: n=1, and it was a partition *violation*, not a planning failure — planning quality does not bound violation rate. Converted from assumption to measurement by the flight log; the 5%/5-wave trigger arbitrates.
- **Hooks actually fire.** Fragility: high on this repo (Windows fail-open history, installed-copy drift #5). Mitigated by Check 16 + double-enforced fail-loud tripwire.
- **Git objects survive all porcelain until gc.** Holds within `gc.pruneExpire` (default 2 weeks ≫ wave lifetime); restores from an *old* log may reference pruned blobs — the log's telemetry value outlives its restore guarantee, accepted.
- **The stop-time sweep + baseline sweep adequately cover Bash-side writes.** Fragility: highest of the set — a stop-sweep races an early destroyer; residual bounded by part 0.
- **Wave-close detection latency is acceptable.** Bound assumes intra-wave independence; cross-task reads inside a wave can widen invalidation from bytes to conclusions — hence "re-run verification, not just restore bytes" is part of the check.

## Constraints That Drove This Decision

- **Token economy** — recurring per-wave overhead is first-class; the absorber runs off-model vs. worktrees' 3–6%/wave forever.
- **The #21 anti-enumeration lesson** — mechanisms key on *effects* (content hashes), never on command strings; the one command-list in this design is frozen at three by rule.
- **Prime directive: steady operativity** — collisions must not perturb flow; absorbed in-band as routine hygiene.
- **M-audit mid-flight** — worktree plumbing cannot be wedged into W1; ADR-005 follow-ups still open.
- **Doctrine coherence** — self-similar with ADR-004 (detect-and-invalidate), composes with ADR-005 (common-dir, single-writer analogs).
- **Portable POSIX shell, no new runtime deps** — `git hash-object`/`cat-file` + append-only log fit the existing hook contract; fail loud, never silently no-op.
- **Solo-developer economics** — a rare bounded restore beats a permanent orchestration tax.
