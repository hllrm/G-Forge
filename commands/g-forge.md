---
description: G-Forge workflow commands. Subcommands — help, status, resume, doctor, audit, init, kickoff, onboard, brief, roadmap, intake, plan, forecast, blast-radius, execute, review, align, afk, specialize, update, skill-design, skill-validate, adr, docs, wiki, patterns, telemetry, identity, retro, listen, optimize, refactor, train, trim, tier, voice.
argument-hint: <help|status|resume|doctor|audit|init|kickoff|onboard|brief|roadmap|intake|plan|forecast|blast-radius|execute|review|align|afk|specialize|update|skill-design|skill-validate|adr|docs|wiki|patterns|telemetry|identity|retro|listen|optimize|refactor|train|trim|tier|voice> [args]
---

Route to the correct skill file based on the subcommand in $ARGUMENTS.

For each subcommand, use Glob to find the corresponding SKILL.md inside `~/.claude/plugins/cache/g-forge/g-forge/` and read it, then follow its instructions exactly. Every standalone `/g-<name>` command maps to the same skill as `/g-forge <name>` — this umbrella is just a single entry point, not a second copy.

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

If $ARGUMENTS is empty or unrecognized, list available subcommands:
  - `help [topic]` — current project state + next action; with a topic/question, answer it and point at the right archive
  - `status` — quick one-line workflow snapshot (milestone, plan, review gate)
  - `resume` — re-hydrate a fresh session: pull the relevant retro, ADRs, journal, and handoff into a clean window, then point at the first task
  - `doctor` — validate project setup health (hooks, settings, CLAUDE.md, duplicate/legacy installs)
  - `audit [scope]` — code-quality audit (SOLID, smells, drift, dead code, coverage); whole-codebase scope → roadmap milestone
  - `init` — scaffold CLAUDE.md, ROADMAP.md (incl. the Active Session handoff), milestones/, todo.md, and commit hooks
  - `kickoff` — interview about goals and stack; produce project_brief.md
  - `onboard` — onboard onto an existing codebase; produce project_brief.md
  - `brief` — refresh project_brief.md as the project evolves
  - `roadmap` — intake features, cluster and sequence into milestones, write ROADMAP.md (runs a premortem + re-prioritization when a milestone is added or changed)
  - `intake [idea]` — triage a single dropped feature against the brief, propose placement + version + risk, ask before writing
  - `plan` — decompose request into atomic tasks and a parallel wave schedule
  - `forecast [plan-slug]` — premortem + scope-realism: complexity score, miss-risk %, ranked failure scenarios
  - `blast-radius [file|plan|feature]` — forward + reverse dependency graph, per-file volatility, aggregate rating
  - `execute [wave]` — dispatch parallel agents per wave; optionally resume from a wave number
  - `review` — run the full review pipeline; issues MERGE READY or HOLD
  - `align [milestone]` — brief-deviation check; ALIGNED / DRIFTING with evidence (advisory)
  - `afk` — autonomous milestone executor: runs all waves + review unattended; requires an approved plan
  - `specialize [stack]` — auto-detect or apply a named stack profile
  - `update` — realign all G-Forge-managed files to the current plugin version (and flag a stale legacy install)
  - `skill-design` — design a new skill from scratch (SKILL.md, command file, router entry)
  - `skill-validate [name]` — validate a skill or agent against G-Forge structural rules
  - `adr [title]` — capture an architectural decision record (triage → off-context deliberation → reversibility + premortem)
  - `docs [scope]` — documentation audit + generation (stale code docs, README gaps, env vars, CHANGELOG, missing ADRs)
  - `wiki [area]` — build/maintain the human-facing project wiki in g-wiki/ (narrative architecture + how-to; queued each milestone)
  - `patterns` — mine g-docs/retros/ and todo-done.md for recurring failure patterns; propose rule edits
  - `telemetry` — compute 8 reliability metrics and derive a health profile; drives adaptive orchestration
  - `identity` — narrative synthesis of the project's operational personality; written to g-docs/identity.md
  - `retro` — synthesize a session retrospective from the journal; refreshes the ROADMAP handoff
  - `listen` — listen mode: collect reports without acting, then synthesize and triage when you say done
  - `optimize [scope]` — performance audit (complexity, N+1, re-render waste, leaks, caching)
  - `refactor [target]` — guided refactor: identify → spec → approve → execute → review (safe-by-default)
  - `train` — training mode: PM becomes a mentor that explains each step and runs post-wave check-ins
  - `trim` — read-only weekly audit of CLAUDE.md + agent memory for bloat and stale content
  - `tier [full|balanced|light]` — switch integration tier
  - `voice [dev|mid|eli5]` — switch voice profile
