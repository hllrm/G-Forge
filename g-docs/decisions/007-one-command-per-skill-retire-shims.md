# ADR-007: One command per skill — retire the standalone command shims

**Date:** 2026-07-19
**Status:** Accepted
**Reversibility:** two-way door (reversible — restoring the shim files from git history is cheap at any point; nothing accrues against them)
**Context:** G-Forge plugin structure — `commands/` vs `skills/` layers (finding #19, M-audit-2026-07 Wave 2)

## Context

Every skill's description was hand-authored in up to three places — `commands/<name>.md` frontmatter (a thin router shim), `skills/<name>/SKILL.md` frontmatter, and `commands/g-forge.md`'s subcommand one-liner — and they drifted repo-wide: 6 pairs confirmed (g-adr, g-retro, g-review, g-audit, g-plan, g-execute), including a real behavioral disagreement on g-adr's triage semantics. A live consumer-install verification (`hllrm/G-Cash`, cache v2.2.1, 2026-07-19) established the registration facts: two files produce **two independent visible entries** per skill (same `g-forge:<name>` display name, different description text, each tracing verbatim to its source file); the bare `/g-<name>` slash alias is sourced only from the shim; the umbrella adds one entry of its own and no per-skill third entry. The plugin has no build step — any keep-in-sync answer would be enforcement (tests, hooks, validators), the exact guarantee class whose silent rot triggered the M-audit.

## Decision

Delete all standalone `commands/<name>.md` shims. `skills/<name>/SKILL.md` becomes the **sole authored source** of each skill's behavior and description — one skill, one file, one visible entry (`g-forge:g-<name>`). `commands/g-forge.md` remains the single router file, its subcommand list trimmed to **bare tokens** (no per-skill prose), eliminating the third description surface. Invocation paths after the change: the skill entry directly, or `/g-forge <name>` via the umbrella. Migration rides the versioned plugin cache: the release that deletes the shims ships a cache directory without them — no consumer-side cleanup, no `/g-update` involvement (shims were never installed into project `.claude/`).

## Alternatives considered

| Option | Why rejected |
|--------|-------------|
| Synced stubs — keep shims, enforce byte-identical descriptions via test/validator/`/g-update` rewrite | Guarantee rests on enforcement that can rot silently — this repo's M-audit is the precedent; full duplicate-entry context cost and same-name/different-text listing confusion survive |
| Generated stubs — a hook rewrites shim frontmatter from SKILL.md on commit | Same enforcement-rot exposure concentrated in a hook (the M-audit's worst class: silent hook failure); duplicate entries survive |
| Pointer stubs — keep shims for the bare alias, description reduced to a fixed non-behavioral pointer | Preserves the alias, but keeps 2 entries per skill, ~40 stub files, and a residual template-conformance invariant to police — another sync layer on top of a duplication that shouldn't exist. Rejected on the core criterion: one command per thing, no added mechanism |
| Status quo + one-time re-sync | Already failed in the field — the finding exists because 6 pairs drifted with no detection; recurrence certain |

## Consequences

**Easier:** One authored description per skill — the g-adr class of behavioral disagreement between sources cannot recur. Skill listing sheds ~40 duplicate entries in every consumer session (context cost roughly halves). Skill authoring and maintenance touch one file. The `commands/` layer collapses to a single file with one invariant.
**Harder / constrained:** The bare `/g-<name>` slash aliases disappear; invocation is the skill entry or `/g-forge <name>`. Every doc, handoff, and CLAUDE.md reference to `/g-<name>` forms needs a sweep, and consumer muscle memory breaks — a typed `/g-review` silently not existing reads as breakage until users adjust. `commands/g-forge.md` remains the one hand-maintained routing surface (bare tokens only — re-adding prose there re-opens a drift axis).
**Follow-up decisions:** Sequence matters — `/g-skill-validate` (Steps 3–4 currently *require* a command file) and `/g-skill-design` (creates the companion command file) and `.claude/rules/architecture-claude-plugin.md` (`commands/` layer definition mandates the shim pattern) must all be amended **before** the shims are deleted, or the plugin's own validation loop breaks on day one. Docs sweep for `/g-<name>` references rides the same change. Consider a `/g-help` catch for typed bare forms. Implementation slotted with finding #19's wave (M-audit W2 / skill-layer work), not into a running slice.
**Risks:** Registration behavior is verified on one install and one Claude Code version — a platform change (entry dedup, or skills auto-deriving slash commands) reopens the decision in either direction. The versioned-cache-replacement migration assumption is high-confidence but unverified at release scale — confirm at the first post-release consumer update that only the new version's entries register.

## Rejected Alternatives

| Alternative | Deciding factor |
|-------------|-----------------|
| Synced stubs | Enforcement-shaped guarantee in the repo whose audit exists because enforcement rotted |
| Generated stubs | Same, concentrated in a silently-failable hook |
| Pointer stubs | Best of the keep-shim options, but still a maintained sync layer + 2 entries per skill — fails "one command per thing, one only" |
| Status quo + re-sync | Empirically failed already |

## Assumptions That Held

- Two files → two independent visible entries, descriptions independently sourced (live-verified on G-Cash v2.2.1 + this repo's dev install; fragility: single Claude Code version — platform registration changes reopen this).
- Bare `/g-<name>` is sourced only from the shim; the umbrella adds no per-skill entry (same verification; same fragility).
- Plugin releases replace the cache per version directory, so file deletions propagate with the version bump and shims never exist in consumer repos (high confidence from cache layout; verify on first post-release update).

## Constraints That Drove This Decision

- No build step / no package manager — sync-at-build is unavailable; the only choices were structure (delete the copy) or enforcement (police the copy).
- G-Forge doctrine: structural impossibility beats enforced discipline; M-audit counter-lesson: silent enforcement failure is the worst bug class — together they disqualify every keep-and-sync option.
- Context-window economy is a first-class product goal — duplicate descriptions were a per-session, every-session cost.
- Developer's core criterion (2026-07-19): one command per thing, one only; no added layers.
