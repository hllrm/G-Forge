# M15 — Hook / Behavioral Integration Pass

**Status:** ✅ Complete — v1.0.0 shipped
**Version:** v1.0.0
**Branch:** feat/m15-cohesion-pass

## Goal

Make G-Forge feel like a single coherent system, not a collection of fifteen additions. Two new dimensions of configurability give the developer the controls they didn't know they needed: how present the toolkit is (integration tier) and how it talks (voice profile). Plus a cohesion pass over `/g-help` and `/g-retro` so the parts wired up in M9–M14 actually feed each other in the developer's daily flow.

## Scope

### 1 — Three integration tiers

`full` / `balanced` / `light` selected via `/g-tier` and stored in `.claude/integration-tier`. The hooks and the auto-trigger rule honor the tier. `light` disables the commit gate; this requires explicit confirmation and a clear warning. Spec lives in `docs/integration-tiers.md`.

**Done condition:** `/g-tier` skill + command exist; both hooks (`workflow-checkpoint.sh`, `check-commit.sh`) read `.claude/integration-tier` and branch on its value; the `Tier:` line is emitted by `workflow-checkpoint.sh` on every prompt.

---

### 2 — Three voice profiles

`dev` / `mid` / `eli5` selected via `/g-voice` and stored in `.claude/voice-profile`. Changes rendering across every G-Forge skill — never facts or verdicts. Spec lives in `docs/voice-profiles.md`.

**Done condition:** `/g-voice` skill + command exist; the new G-RULES Voice rule references the profile; `/g-init` first-chat onboarding writes both files on first run; `/g-tier` confirmation messages render in the active voice.

---

### 3 — `/g-init` first-chat onboarding (Step 7a)

`/g-init` Step 7a asks two questions on first run: which voice profile and which integration tier. Resolves answers to bare-word values and writes both files. Defaults are `dev` and `full` (the historical behaviour) on any unrecognised answer.

**Done condition:** `skills/g-init/SKILL.md` Step 7a present with both questions, default handling, and report-line additions for both new files.

---

### 4 — `/g-help` cohesion overhaul

`/g-help` now surfaces the project's full configuration and recent intelligence: tier, voice, telemetry health profile, last telemetry snapshot date, last forecast slug, identity-file presence. Commands are grouped by purpose (Setup / Per-task loop / Intelligence / Configuration / Hygiene / Audit-refactor / Skill-development).

**Done condition:** `skills/g-help/SKILL.md` Steps 2 and 5 updated to read the new state files and surface Configuration + Recent intelligence blocks; command list grouped by purpose.

---

### 5 — `/g-retro` pattern-signal feed (Step 6)

After writing a retro, `/g-retro` runs a lightweight pattern mine across all retros and surfaces any normalised label that reached ≥2 source files with this session's contribution. Surface only — never modifies rule files. Closes the loop with `/g-patterns` without forcing a second invocation.

**Done condition:** `skills/g-retro/SKILL.md` Step 6 added; reuses the `/g-patterns` sentinel filter and label-normalisation; prints nothing when no label reaches ≥2.

---

### 6 — Tier-aware auto-trigger rule

`G-RULES.md` §B updated: the auto-trigger rule fires `/g-plan`, `/g-execute`, `/g-review` only when the `Tier:` line in `workflow-checkpoint.sh` output reads `full`. `balanced` and `light` disable auto-trigger; the developer invokes skills manually. New Voice rule documents that every output honors the active voice profile.

**Done condition:** `G-RULES.md` §B contains the tier-scoped Auto-trigger rule and the new Voice rule.

---

## Done Conditions (milestone)

- [x] `skills/g-tier/SKILL.md` + `commands/g-tier.md` exist; valid plugin structure
- [x] `skills/g-voice/SKILL.md` + `commands/g-voice.md` exist; valid plugin structure
- [x] `docs/integration-tiers.md` and `docs/voice-profiles.md` published
- [x] `hooks/workflow-checkpoint.sh` reads `.claude/integration-tier`, emits `Tier:` line, exits early on `light`
- [x] `hooks/check-commit.sh` short-circuits on `light` tier (commit gate off)
- [x] `skills/g-init/SKILL.md` Step 7a asks voice + tier on first run
- [x] `skills/g-help/SKILL.md` surfaces Configuration + Recent intelligence blocks; commands grouped
- [x] `skills/g-retro/SKILL.md` Step 6 surfaces ≥2-occurrence labels after writing the retro
- [x] `G-RULES.md` §B tier-scoped Auto-trigger rule + new Voice rule
- [x] `commands/g-team.md` router includes `tier` and `voice` subcommands
- [x] `G-RULES.md` §B maintenance table includes `/g-tier` and `/g-voice` rows
- [x] `plugin.json` and `marketplace.json` both at v1.0.0; description updated with the three tiers and three voice profiles; skill count 30
- [x] CHANGELOG `[1.0.0]` entry with the "first stable release" header
- [x] README updated for v1.0.0 ship
- [x] M15 marked ✅ in ROADMAP.md with "v1.0.0 shipped" annotation; version plan reflects ship

## Tier 3 DoD

Developer types `/g-voice eli5` and runs `/g-review` on a stub change — the output renders in plain-language form without losing the MERGE READY/HOLD verdict.

Developer types `/g-tier balanced` — the next `workflow-checkpoint.sh` output prints `Tier: balanced — no auto-triggers; invoke skills manually`, and Claude no longer auto-invokes `/g-plan` on a non-trivial task.

Developer types `/g-tier light` — gets the confirmation prompt; on `y`, the commit gate becomes a no-op for that project (`echo approved > .claude/g-team-approved` is no longer required to `git commit`).

Developer runs `/g-help` — sees Configuration block (tier · voice · health), Recent intelligence block (last telemetry / forecast / identity), and the grouped command list.

## Depends on

M14 (the full intelligence chain — `/g-help` surfaces all of it; `/g-retro` Step 6 builds on M10's sentinel filter; the tier rule was anticipated since M6 but only deliverable once the full surface area existed).

## What v1.0.0 means

The toolkit is no longer just "a collection of skills." It is a configurable workflow you can crank from heavy rails to opt-out, and adapt to your audience from terse-engineer to plain-language. Every intelligence skill from M10–M14 feeds the others; every hook respects the developer's chosen presence; every output respects the developer's chosen voice. The shape is stable.
