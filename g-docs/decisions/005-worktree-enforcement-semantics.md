# ADR-005: Define what the commit gate means inside a git worktree

**Date:** 2026-07-12
**Status:** Accepted
**Reversibility:** two-way door (reversible) — revert the resolution logic in the hooks; ~a day, local files only
**Context:** g-forge — the commit gate under `isolation: worktree` agent sessions
**Depends on:** ADR-004 (same sentinel files — per-worktree keying is required for correctness)

## Context

Claude Code can run subagents with `isolation: worktree` (a fresh `git worktree`, its own working dir, shared `.git`). Because g-forge's runtime state under `.claude/` is gitignored, it is **absent** in a new worktree — so the project guard `[ -f ".claude/integration-tier" ]` at the top of every hook fails and **all seven hooks silently no-op** (finding #10). Enforcement is off exactly where parallel wave agents do the most work, and the plugin dogfoods worktree isolation itself. This is a semantics question, not a mechanical bug: *should* a worktree be gated, and against whose state?

## Decision

Treat the **primary working tree as the single source of enforcement truth**. In each hook, detect worktree context and resolve the g-forge state (the integration-tier marker, tier setting, and sentinels) from the primary repo via `git rev-parse --git-common-dir` — so a worktree of a gated project **inherits the gate** instead of silently no-op'ing. To prevent one shared approval from being consumed across trees, **sentinels are per-worktree-keyed** (keyed by `git rev-parse --show-toplevel`, e.g. a per-worktree subpath under the primary `.claude/`). Gate **normally** on successful resolution; **deny** only when the primary `integration-tier` is genuinely unreachable or ambiguous. A project that never ran `/g-init` still resolves to nothing and stays inert everywhere — unchanged. Explicitly do **not** silently no-op in a worktree of a gated project.

## Alternatives considered

| Option | Why rejected |
|--------|-------------|
| Status quo — worktrees ungated, "gate at merge to main" | No mechanism actually blocks an in-worktree commit, and a fast-forward/rebase merge can carry unreviewed worktree commits onto main without passing the gate. Violates fail-toward-enforcement and the "don't silently no-op a gated project" rule. |
| Fail-CLOSED as the default (deny all worktree commits until wired) | Correct direction, wrong default: bricks the dogfooded happy path — every wave agent's first commit denied until a human intervenes. Kept only as the ambiguity fallback inside the chosen option. |
| Copy/symlink `.claude/` into each worktree at creation | Duplicates single-writer mutable state; a copied sentinel is stale the moment `/g-review` runs in either tree; needs a race-free creation hook that POSIX + manual `git worktree add` can't guarantee. Adds a creation-time dependency to enforce a commit-time invariant. |
| Stop gitignoring `.claude/` so it materializes in worktrees | Sentinels/journal/counters become tracked and PR-visible; a committable approval sentinel is a security regression; breaks ADR-004's ephemerality assumption. |
| Required `/g-init --worktree` per worktree | Opt-in enforcement = the status-quo hole with extra steps; depends on remembering to arm it. Survives only as a deliberate isolation escape hatch, not the default. |
| Declare worktrees a non-gated runtime "by design" (the ADR-003 mirror) | ADR-003 declared Cowork not-a-host because hooks *architecturally cannot fire* there — an external constraint. In a worktree the hooks **do** fire and the primary state **is** reachable via `--git-common-dir`; declaring it ungated would be choosing to disarm an armable gate, the reverse of ADR-003's forced hand. |

## Consequences

**Easier:** parallel wave agents can no longer launder unreviewed code through an ungated worktree; the gate means the same thing in the primary tree and any linked worktree, with no per-worktree arming step to forget. The inert-in-non-G-Forge guarantee is preserved for free. Dogfooded immediately.

**Harder / constrained:** every one of the seven hooks must learn a two-mode state-dir resolution (primary vs. linked worktree) in portable POSIX shell, normalizing the relative-vs-absolute paths `--git-common-dir` returns, without regressing the non-worktree path. State must be partitioned: `integration-tier` / tier are project-global (resolve to primary), but sentinels and per-session counters must be per-tree. Concurrent parallel agents now write shared primary state (counters/stamps) — non-atomic writes can corrupt them.

**Follow-up decisions:**
- Exact state partition: enumerate every `.claude/` file the seven hooks touch and mark shared vs. per-worktree. Load-bearing — if left ad hoc, hooks will diverge.
- Sentinel key mechanics: per-worktree subpath under primary `.claude/` vs. a `show-toplevel`-hashed suffix; must compose with ADR-004's stamp format.
- Which ambiguities deny vs. gate-normally — specify precisely so the fail-closed fallback doesn't become a fleet-wide commit outage on a single resolution edge case.
- Whether an intentionally isolated worktree escape hatch (`/g-tier light` scoped to a worktree, or `--worktree`) is supported.
- Whether a complementary native merge-time check (main-side) is worth adding later as defense in depth.

**Risks:** cross-tree approval bleed if per-worktree keying is imperfect (silent bypass — the exact class W1 exists to kill). `--git-common-dir` edge behavior under nested/detached worktrees, `--separate-git-dir`, submodules, or a `$GIT_COMMON_DIR` override could resolve to the wrong `.claude/`; fail-toward-enforcement must catch it without bricking the happy path. Seven-hook change surface risks recreating installed-copy drift (#5) in a new form — factor the resolution into one sourced helper.

## Rejected Alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Ungated + gate-at-merge | No mechanism blocks an in-worktree commit; merge can carry unreviewed commits. |
| Fail-closed default | Bricks the dogfood happy path; retained only as the ambiguity fallback. |
| Copy/symlink `.claude/` per worktree | Duplicates single-writer state; stale snapshots; no race-free creation hook. |
| Un-gitignore `.claude/` | Tracks/commits ephemeral state; committable approval sentinel is a security regression. |
| `/g-init --worktree` opt-in | Opt-in enforcement = the hole with extra steps. |
| "Not a host, by design" (ADR-003 mirror) | Hooks *can* fire and primary state *is* reachable — disarming an armable gate, opposite of ADR-003's basis. |

## Assumptions That Held

- **`git rev-parse --git-common-dir` reliably distinguishes a linked worktree from the primary and resolves the shared `.git` whose parent holds the primary `.claude/`.** Fragile: returns a relative path in the primary vs. absolute in a linked tree — the hook must normalize before deriving the parent, or the non-worktree path regresses. Nested-worktree / `--separate-git-dir` / submodule / `$GIT_COMMON_DIR`-override behavior must be pinned by fixtures before implementation.
- **Inheriting the primary gate is the correct semantics.** Fragile: right for tier/integration state, but for approval sentinels per-tree isolation is what prevents cross-tree bleed — so it holds only for part of `.claude/`, which is why the state partition is a follow-up.
- **Worktree commits should meet the same bar as main commits.** Fragile against the legitimate "ephemeral scratch that merges back" use case — mitigated by leaving an opt-out escape hatch as a follow-up rather than a default.
- **One primary is a single writer.** Fragile: parallel wave agents make concurrent writes to the one state dir the norm; harmless for counters, high-severity for a sentinel race — hence per-worktree keying.

## Constraints That Drove This Decision

- Portable POSIX shell only; the resolution + normalization must be pure POSIX across the seven hooks' cross-platform contract.
- Fail toward enforcement on ambiguity — unresolved/ambiguous worktree state gates or denies, never silently no-ops.
- Must not regress the non-worktree path (strictly additive/conditional) or the inert-in-non-G-Forge guarantee.
- Must compose with ADR-004 (same sentinel files; the key decision cannot contradict content-hash-binding or HEAD-staleness).
- Dogfooded immediately — must be correct under real parallel-agent load, not just a single-worktree demo.
- The gate must actually block — a gate that resolves to the wrong state and passes is the shipped-no-op bug (ADR-003 / Bug A lineage) under a new trigger.
