# Retro: m27-doc-review-gate — 2026-06-29

## What was done
- Built M27 — the Documentation Review Gate — across 3 parallel waves (11 implementer agents): new read-only `doc-reviewer` agent, `/g-doc-review` standalone gate skill + command + router registration, a file-set classifier in `hooks/check-commit.sh` (code/doc/mixed) with a second `.claude/g-forge-docs-approved` sentinel, dual-sentinel cleanup in `post-commit-cleanup.sh`, a backstop-deferral note in `code-reviewer`, the §G two-gate model, a `/g-doctor` Check 10, and 8 new hook tests (14/14 green).
- Ran the full review pipeline: code-lead returned MERGE READY (classifier verified fail-safe in every branch; code-only path byte-identical), then dogfooded the new `/g-doc-review` gate → DOCS READY on its own first use.
- Resolved a multi-session collision: `v2.0.1` had shipped from another machine (6 commits, added `feature-implementer`). Rebased M27 onto it, resolved 4 conflicts (marketplace, CHANGELOG, README, agents.md), and re-derived true counts (19 agents / 37 skills / 38 commands).
- Closed out and released `v2.1.0` (commit 2098d4a): bumped both manifests in sync, dated the CHANGELOG, marked M27 ✅ in ROADMAP, updated the README commit-gate narrative to the two-gate model. Merged to `main` and pushed.

## Decisions made
- Doc review promoted from a `code-reviewer` sub-check to a first-class gate with its own verdict and sentinel; `code-reviewer` keeps a public-export backstop that defers when the doc gate ran (commit 76a9e03, §G two-gate model).
- Consolidated the 18-task plan into 11 agent slots across 3 waves to respect the §C agent cap and fit a tight context budget (developer chose proceed-with-wave-boundary-handoff over splitting the milestone).
- M27 released as `v2.1.0`, not the originally-planned `v2.2.0` — `v2.0.1` had already absorbed M24/M25's positioning work from the parallel session, so M27 is the next minor (M26 reassigned to v2.2.0).
- Integrated the parallel session via rebase (not merge) for linear history and to sidestep the merge-commit gate.

## Patterns
### Worked well
- Every wave gated on its tests before proceeding; both hook suites stayed 14/14 green throughout; no reverts, no agent re-dispatches (all single-use agents returned DONE first try).
- The dual-gate dogfooded itself: the mixed M27 commit and the release commit both correctly required both sentinels and passed only with both present — the feature validated on its own first real use.

### Avoid / do differently
- A concurrent session shipped `v2.0.1` on `main` while this session built M27 off a stale base, forcing a mid-merge rebase + count re-derivation and a version-plan correction. There is no claim/lock primitive for concurrent multi-session work — exactly the backlog "concurrent multi-session orchestration" gap. Before starting milestone work, `git fetch` and check `origin/main` divergence.

## Cold-start context
**Branch:** main
**Active milestone:** M27 — Documentation Review Gate ✅ Complete (v2.1.0)
**Next up:** M26 — Provable Wave Dispatch (v2.2.0): deferred, feasibility-spike-gated. · M25 — reliability benchmark pilot (compute-gated). · Backlog: concurrent multi-session orchestration (claim/lock primitive) — this pass hit the exact collision it describes; strong candidate to promote.
**Key files touched:** check-commit.sh, post-commit-cleanup.sh, doc-reviewer.md, code-reviewer.md, g-doc-review/SKILL.md, g-doc-review.md, g-forge.md, g-doctor/SKILL.md, g-help/SKILL.md, g-init/SKILL.md, g-rules-G-documentation.md, test-check-commit.sh, agents.md, README.md, CHANGELOG.md, ROADMAP.md, marketplace.json, plugin.json
**Carry-over context:** main = v2.1.0; M1–M27 shipped except M25/M26. The doc-review gate is LIVE and self-hosting — this repo's own commits now pass through it. Counts: 19 agents · 37 skills · 38 commands · 56 profiles. Re-enter with /g-resume.

## Journal basis
50 events today — 37 agent · 6 commit · 4 push · 1 merge · 1 branch · 1 session (spans this M27 session and the parallel 2.0.1 session that landed on main)
