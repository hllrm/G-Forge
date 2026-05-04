---
description: G-Team workflow commands. Subcommands: init, kickoff, onboard, plan, execute, review, specialize, update.
argument-hint: <init|kickoff|onboard|plan|execute|review|specialize|update> [args]
---

Route to the correct G-Team skill based on the subcommand in $ARGUMENTS.

- If $ARGUMENTS starts with `init` → invoke skill `g-team:g-team-init`
- If $ARGUMENTS starts with `kickoff` → invoke skill `g-team:g-team-kickoff`
- If $ARGUMENTS starts with `onboard` → invoke skill `g-team:g-team-onboard`
- If $ARGUMENTS starts with `plan` → invoke skill `g-team:g-team-plan`
- If $ARGUMENTS starts with `execute` → invoke skill `g-team:g-team-execute` (pass any remaining args)
- If $ARGUMENTS starts with `review` → invoke skill `g-team:g-team-review`
- If $ARGUMENTS starts with `specialize` → invoke skill `g-team:g-team-specialize` (pass any remaining args)
- If $ARGUMENTS starts with `update` → invoke skill `g-team:g-team-update`

If any skill does not load (you only see "Launching skill" with no further instructions), use Glob to find `skills/g-team-<subcommand>/SKILL.md` inside `~/.claude/plugins/cache/g-team/g-team/` and read it directly, then follow its instructions exactly.
- If $ARGUMENTS is empty or unrecognized → list available subcommands:
  - `init` — scaffold CLAUDE.md, ROADMAP.md, milestones/, todo.md, and commit hooks
  - `kickoff` — interview about goals and stack; produce project_brief.md
  - `onboard` — onboard onto an existing codebase; produce project_brief.md
  - `plan` — decompose request into atomic tasks and parallel wave schedule
  - `execute [wave]` — dispatch parallel agents per wave; optionally resume from a specific wave number
  - `review` — run full review pipeline; issues MERGE READY or HOLD
  - `specialize [stack]` — auto-detect or apply a named stack profile
  - `update` — realign all g-team-managed files to the current plugin version
