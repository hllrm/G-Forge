---
description: G-Forge workflow commands. Subcommands — help, status, resume, doctor, audit, init, kickoff, onboard, brief, roadmap, intake, plan, forecast, blast-radius, execute, review, doc-review, align, afk, specialize, update, skill-design, skill-validate, adr, docs, wiki, patterns, telemetry, identity, retro, listen, optimize, refactor, train, trim, tier, voice, roundtable.
argument-hint: <help|status|resume|doctor|audit|init|kickoff|onboard|brief|roadmap|intake|plan|forecast|blast-radius|execute|review|doc-review|align|afk|specialize|update|skill-design|skill-validate|adr|docs|wiki|patterns|telemetry|identity|retro|listen|optimize|refactor|train|trim|tier|voice|roundtable> [args]
---

Route to the correct skill file based on the subcommand in $ARGUMENTS.

For each subcommand, use Glob to find the corresponding SKILL.md inside `~/.claude/plugins/cache/g-forge/g-forge/` and read it, then follow its instructions exactly. This umbrella is the single command entry point (ADR-007: one command per skill — no standalone per-skill command files); each skill also registers directly from its SKILL.md as `g-forge:g-<name>`.

- `help`        → `skills/g-help/SKILL.md`  (remaining args: $ARGUMENTS)
- `status`      → `skills/g-status/SKILL.md`
- `resume`      → `skills/g-resume/SKILL.md`  (remaining args: $ARGUMENTS)
- `doctor`      → `skills/g-doctor/SKILL.md`
- `audit`       → `skills/g-audit/SKILL.md`  (remaining args: $ARGUMENTS)
- `init`        → `skills/g-init/SKILL.md`
- `kickoff`     → `skills/g-kickoff/SKILL.md`
- `onboard`     → `skills/g-onboard/SKILL.md`
- `brief`       → `skills/g-brief/SKILL.md`
- `roadmap`     → `skills/g-roadmap/SKILL.md`
- `intake`      → `skills/g-intake/SKILL.md`  (remaining args: $ARGUMENTS)
- `plan`        → `skills/g-plan/SKILL.md`
- `forecast`    → `skills/g-forecast/SKILL.md`  (remaining args: $ARGUMENTS)
- `blast-radius` → `skills/g-blast-radius/SKILL.md`  (remaining args: $ARGUMENTS)
- `execute`     → `skills/g-execute/SKILL.md`  (remaining args: $ARGUMENTS)
- `review`      → `skills/g-review/SKILL.md`
- `doc-review`  → `skills/g-doc-review/SKILL.md`  (remaining args: $ARGUMENTS)
- `align`       → `skills/g-align/SKILL.md`  (remaining args: $ARGUMENTS)
- `afk`         → `skills/g-afk/SKILL.md`
- `specialize`  → `skills/g-specialize/SKILL.md`  (remaining args: $ARGUMENTS)
- `update`      → `skills/g-update/SKILL.md`
- `skill-design` → `skills/g-skill-design/SKILL.md`
- `skill-validate` → `skills/g-skill-validate/SKILL.md`  (remaining args: $ARGUMENTS)
- `adr`         → `skills/g-adr/SKILL.md`  (remaining args: $ARGUMENTS)
- `docs`        → `skills/g-docs/SKILL.md`  (remaining args: $ARGUMENTS)
- `wiki`        → `skills/g-wiki/SKILL.md`  (remaining args: $ARGUMENTS)
- `patterns`    → `skills/g-patterns/SKILL.md`
- `telemetry`   → `skills/g-telemetry/SKILL.md`
- `identity`    → `skills/g-identity/SKILL.md`
- `retro`       → `skills/g-retro/SKILL.md`  (remaining args: $ARGUMENTS)
- `listen`      → `skills/g-listen/SKILL.md`
- `optimize`    → `skills/g-optimize/SKILL.md`  (remaining args: $ARGUMENTS)
- `refactor`    → `skills/g-refactor/SKILL.md`  (remaining args: $ARGUMENTS)
- `train`       → `skills/g-train/SKILL.md`
- `trim`        → `skills/g-trim/SKILL.md`
- `tier`        → `skills/g-tier/SKILL.md`  (remaining args: $ARGUMENTS)
- `voice`       → `skills/g-voice/SKILL.md`  (remaining args: $ARGUMENTS)
- `roundtable`  → `skills/g-roundtable/SKILL.md`  (remaining args: $ARGUMENTS)

If $ARGUMENTS is empty or unrecognized, print the bare subcommand tokens from the routing list above (tokens only — descriptions live in each skill's SKILL.md, per ADR-007) and suggest `/g-forge help` for a guided overview.
