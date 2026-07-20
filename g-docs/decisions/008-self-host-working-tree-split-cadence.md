# ADR-008: Self-host from working-tree source, install cadence split by hook class

**Date:** 2026-07-19
**Status:** Accepted
**Reversibility:** two-way door (reversible — installs restorable from snapshot; the `/g-update` mechanism change revertible by commit; no data or external contract commits to it)
**Context:** G-Forge plugin source repo (dogfooding itself)

## Context

G-Forge claims to dogfood itself, but every runtime layer resolves to the *last released* version, not the working tree. Measured 2026-07-19: all 7 installed hooks in `.claude/hooks/` drift from canonical `hooks/`; `.claude/hooks/lib/` does not exist (installed copies predate W1.1); the native `pre-commit` is not installed; skills and agents resolve from the plugin cache at v2.2.1 and drift from source; `.claude/rules/` contains only the architecture rule — none of the ten g-rules section files, so `G-RULES.md`'s `@`-includes silently resolve to nothing and sections A–J never load. Net effect: the repo develops vN while running vN−1. All three field bugs to date (BUG-1, #21, #22) were found by consumer projects, not here — the canary is downstream of the coal mine. `/g-doctor` Check 16 exists to detect exactly this drift, is marked required, and is not run by any routine loop: a process gap, not a capability gap (finding #28; #27 is the verification blind spot).

## Decision

Self-host G-Forge from the working tree, with install cadence split by hook class:

1. **Non-gating components** (observe, agent-lifecycle, session-start, pre-compact, workflow-checkpoint, post-commit-cleanup, the 4 libs, the 10 g-rules section files, profile-installed agents) install **eagerly at slice close** — degrade-silent by design, cannot block work.
2. **Gating components** (`check-commit.sh`, native `pre-commit`) install only at a **verified checkpoint**, **clone-first**: exercised in a scratch clone against real commits before touching the live repo, behind the written rollback contract below.
3. **Mechanism:** `/g-update` (and `/g-init`) become **self-host-aware** — when the repo they run in is the plugin source itself (detection: `.claude-plugin/plugin.json` exists at repo root AND its `name` matches the plugin), the source root flips from the plugin cache to the working tree. Consumers are structurally unaffected (no root `plugin.json` → detection cannot fire). This removes the footgun where running `/g-update` here would install the stale cache over current source, and makes the install path itself dogfooded — no hand-copy protocol.
4. **Verification precedes installation:** finding #27 (drift detection extended to `.claude/rules/` and installed agents, with *missing* counted as drift) is a **prerequisite** — nothing installs until its state is checkable.
5. **Routine drift check:** `/g-review` Step 1 runs the installed-copy drift check and reports its result in the review record (visible, not blocking) — the only decay-proof element on a single-maintainer, no-CI project.
6. **The class split becomes enforced, not conventional:** a suite assertion pins that non-gating hooks never exit non-zero, so no future hook silently migrates across the class boundary.

**Scope ceiling (factual, not chosen):** shipped skills (38) and agents (19) are cache-pinned by construction — command routers hardcode the cache Glob, and plugin skills/agents occupy a `g-forge:` namespace project-local files cannot shadow. They are **not covered** by this decision and remain at the released version. Spike S1 (scoped in the W1.5g slice) resolves the platform-sanctioned dev-install path for that layer with two empirical questions: (a) does a local-marketplace install of `g-forge` replace or collide with the GitHub-marketplace install? (b) how do the command routers' cache Globs behave with multiple version directories present?

## Rollback contract (load-bearing — written before any install)

- **Before any install:** refresh the `.claude/` + git-hooks-dir snapshot (first snapshot taken 2026-07-19, scratchpad `claude-install-snapshot-2026-07-19`). Restore = one `cp -r`.
- **Gating-hook escape hatches (git-level, survive ADR-004 closing the PreToolUse hole):** `git commit --no-verify` bypasses the native hook; deleting the hook file removes it; both are ~10-second recoveries. A broken gate fails LOUD; the expensive failure is the silent one — which is the *status quo* this ADR ends, not a risk it introduces.
- **Gating installs are clone-first, always** — the live repo never receives an unexercised gate.

## Alternatives considered

| Option | Why rejected |
|--------|-------------|
| Status quo — install at milestone close | Empirically produced the failure: 7/7 hooks drifted, 0/4 libs, 0/10 rules files, native hook absent; silent and unbounded staleness — the worst failure shape available |
| Eager install of everything incl. gating hooks | Gate self-modification hazard: every mid-edit intermediate state becomes the live gate on its own fix (v2.2.1 `exit 1` no-op precedent, whose test encoded the bug) |
| Symlink `.claude/hooks/` → `hooks/` | Collapses into eager-everything; makes Check 16 tautologically green (uninformative); unreliable symlink semantics on the Windows/git-bash host |
| Consumer projects as primary canary | Latency is a release cycle, cost is externalized, and the signal reports on vN−1 by construction (BUG-1 was itself a drift artifact). Retained as secondary channel |
| Per-layer cadence instead of per-class | No risk differentiation within the non-gating class; reopens the half-updated-set hazard. *Can this block work* is the smallest split tracking the real risk boundary |
| Scratch clone as a standing third sandbox tier | Duplicates fixture coverage while omitting the thing being bought — real unscripted commits on the real host. Clone-first is retained for the gating class's discrete checkpoints only |
| Check 16 as blocking pre-wave gate, cadence unchanged | Treats the alarm, not the fault: forces the same install at maximum friction; blind to two-thirds of the drifted surface until #27. Adopted as routine-loop complement instead |
| Hand-written dev version dir in the plugin cache | Fights the platform's package manager; untracked, unversioned, invisible to every drift check. Superseded by Spike S1's local-marketplace question |
| Defer the four implementation forks to W1.7 planning | All four are evidence-determined two-way doors with no new information pending; deferral costs context reconstruction and buys nothing |

## Consequences

**Easier:** Bugs in non-gating hooks, libs, and session doctrine surface here within one slice instead of a release cycle later in a consumer repo. G-RULES sections A–J actually load — every session to date has run without the doctrine the project believes it enforces; this is the single largest concrete win and is entirely in the eagerly-installed class. Check 16 regains two possible states (a permanently-red required check is functionally disabled). The dogfooding claim becomes literally true for hooks + rules + profile agents. The #22 fix finally attributes this repo's own agents.
**Harder / constrained:** `/g-update` + `/g-init` acquire a detection branch (shipped change, reviewed like any slice). Slice-close diffs to non-gating hooks change live session behavior immediately — the intended trade, but a new source of mid-session surprise. Consumer field reports lose some independence as this repo's install converges on source.
**Follow-up decisions:** Spike S1 (skills/agents dev-install path — the remaining majority of the product surface). Whether the routine drift check ever graduates from visible to blocking.
**Risks:** Fixture adequacy for gating installs is asserted, not proven — v2.2.1's no-op survived a green suite that encoded the bug; clone-first exists precisely because 35 assertions is a count, not a coverage argument. Windows/git-bash remains the historically fail-open host: fixture-green does not imply host-enforced; the W1.7 live verify is the real proof. Manual-step decay is only defended by the routine drift check — if that check is ever removed from `/g-review`, the decay path reopens silently.

## Rejected Alternatives

| Alternative | Deciding factor |
|-------------|-----------------|
| Milestone-close installs (status quo) | Measured 7-drift, 0-lib, 0-rules outcome; silent, unbounded |
| Eager gating installs | Bootstrapping hazard; v2.2.1 no-op precedent |
| Symlinks | Check 16 tautology + Windows semantics |
| Consumer canary as primary | Reports on vN−1 by construction |
| Fork deferral to W1.7 | Evidence-determined two-way doors; deferral = pure loss |

## Assumptions That Held

- **Git-level escape hatches remain available** (`--no-verify`, hook-file deletion). Fragility: low — these are git's own semantics, independent of anything G-Forge ships. Note: the *PreToolUse-blindness* hatch is deliberately NOT relied on — it is the enforcement hole ADR-004 closes; risk pricing rests only on the git-level hatches.
- **`.claude/` stays gitignored here** — local installs touch zero shipped content. Fragility: low; confirmed in `.gitignore` and CLAUDE.md. (Inversion noted: the same isolation let seven drifts persist unnoticed — which is what the routine check now covers.)
- **Non-gating hooks are degrade-silent** — held by design and W1.3 review; now to be *enforced* by the never-exit-nonzero suite assertion rather than assumed.
- **Check 16's hash comparison treats the working tree as canonical on this repo** — true by construction here (`hooks/` IS source); the self-host detection makes `/g-update` consistent with it.

## Constraints That Drove This Decision

- Single maintainer, no CI — every unautomated step eventually gets skipped; the mechanism must live in the tools, not a checklist.
- No manual QA path (release-and-dogfood doctrine) — the install itself is the smoke test, which is exactly what this ADR formalizes.
- Windows/git-bash host, historically fail-open for hooks — rules out symlinks; makes clone-first + live-verify non-negotiable for gates.
- Gate self-modification hazard — this repo develops the gate that gates it; generates the class split.
- Skills/agents are cache-pinned by construction — a hard platform ceiling on scope, resolvable only via the platform's own install path (Spike S1).
