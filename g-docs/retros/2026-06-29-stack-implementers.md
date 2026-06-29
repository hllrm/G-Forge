# Retro: stack-implementers — 2026-06-29

## What was done
- Fixed the bug where wave execution deployed non-specialized (`general-purpose`) agents instead of G-Forge agents — wave tasks now dispatch as named implementers. (c475710)
- Added stack-native implementers: `/g-specialize` now installs a `<stack>-implementer` beside each `<stack>-architect` (write-side counterpart, preloads `architecture-<stack>`), plus a shipped generic `feature-implementer` fallback and a `templates/stack-implementer.md` source template. (c475710)
- Wired routing end-to-end: `wave-planner` tags each task with its executor → the plan wave schedule persists the `(agent: …)` tag → `g-execute` dispatches that `subagent_type`; the `C-agent-discipline` ad-hoc-dispatch rule and `/g-update` resync were updated to match. (c475710)
- Added deterministic glob-based routing: `/g-specialize` derives an `owns:` glob list per implementer from its architecture-rules layer map; `wave-planner` matches a task's files against those globs (most-specific wins; ties fall back to `feature-implementer`). (c571989)
- Cut release 2.0.1: bumped `plugin.json` + `marketplace.json`, restructured CHANGELOG `[Unreleased]` into a dated `[2.0.1]` section (Fixed / Added / Changed), and updated the shipped agent count 17 → 18 across README, `g-docs/agents.md`, `g-telemetry`, and `marketplace.json`. (b0266b8)

## Decisions made
- Chose stack-tuned implementers over fixed cosmetic "flavour" agents (developer steer). Specialization is sourced from the existing `architecture-<stack>` skills, not renamed general-purpose agents; an in-progress flavour-shell approach was superseded and its files removed before commit.
- Chose layer-map-derived `owns:` globs over per-profile hand-authored lists — near-zero added maintenance, reuses the architecture rules as the single source of truth for where each stack's code lives.
- Scoped 2.0.1 to include all pending `[Unreleased]` work (developer's call), headlined as the agent-dispatch bug fix.

## Patterns
### Worked well
- Verified before relying: ran the hook test suites green (6/6 + 14/14) before cutting the release, and validated the `owns:` glob derivation against four real profiles (react / fastapi / django / rust-axum) before wiring `wave-planner` to it.
- Design forks (generic vs. flavour vs. stack implementers; `owns:` derivation source) were resolved by explicit developer decisions *before* generating durable artifacts.

### Avoid / do differently
- Generated flavour-shell agent files (`bugfix-implementer`, `integration-implementer`, then a generic `feature-implementer`) before the roster architecture was settled; two were deleted when the design pivoted to stack implementers. Settle the agent-roster architecture before writing agent files.

## Cold-start context
**Branch:** claude/g-resume-b9fqqf
**Active milestone:** none in progress — 2.0.1 was an unplanned hotfix; M27 (Documentation Review Gate, v2.2.0) is the next buildable.
**Next up:** Merge `claude/g-resume-b9fqqf` (2.0.1) into main; then M27 — Documentation Review Gate.
**Key files touched:** wave-planner.md, feature-implementer.md, stack-implementer.md, SKILL.md (g-specialize / g-execute / g-plan / g-update / g-telemetry), C-agent-discipline.md, README.md, agents.md, CHANGELOG.md, plugin.json, marketplace.json
**Carry-over context:** 2.0.1 lives on the branch, not yet merged to main (main is still 884e0d5 / v2.0.0). The new `(agent: <name>)` wave-schedule tag → `subagent_type` dispatch is the routing layer; a future **M26 (Provable Wave Dispatch)** workflow engine must preserve this tag→`subagent_type` mapping to keep parity with the prose path.

## Journal basis
No journal — git + ROADMAP only (this is the plugin source repo; the silent observer does not run here).
