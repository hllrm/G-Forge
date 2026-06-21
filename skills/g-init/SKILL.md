---
name: g-init
description: Scaffold a new project with CLAUDE.md (compact G-rules injected), ROADMAP.md, milestones/, todo.md, and commit enforcement hooks. Run once in a new project after installing G-Forge.
---

**Announce:** "Using g-init to scaffold the project."

You are initializing a G-Forge project. Execute these steps in order. Do not skip any step.

## Step 1 — Confirm project root

The project root is the current working directory. If uncertain, ask the developer to confirm before creating any files.

## Step 2 — Create or update CLAUDE.md

Check if `CLAUDE.md` exists at the project root.

**If it does not exist:**
1. Glob the plugin cache for `templates/CLAUDE.md` — pattern: `~/.claude/plugins/cache/g-forge/g-forge/*/templates/CLAUDE.md`. Use the highest version found.
2. Read the template file.
3. Replace `[Project Name]` with the actual project name (use the directory name, or ask if unclear).
4. Write the result to `CLAUDE.md` at the project root.
5. Tell the developer: "Fill in the project description, stack table, and conventions sections in CLAUDE.md before proceeding."
6. Report: `✓ CLAUDE.md — created from template`

**If it exists:** Read it. If the text `<!-- G-Forge Rules` is not present, append this block at the end of the file:

```
<!-- G-Forge Rules — injected by /g-init. Do not edit manually. -->
<!-- (rules loaded via @G-RULES.md at top of file) -->
<!-- End G-Forge Rules -->
```

Report: `✓ CLAUDE.md — verified`

## Step 2a — Install G-RULES.md and rule section files

The plugin root is `~/.claude/plugins/cache/g-forge/g-forge/` (use Glob to confirm the exact path).

1. Copy `[plugin-root]/G-RULES.md` to the project root as `G-RULES.md`. Overwrite if it exists — G-Forge managed.

2. Create `.claude/rules/` directory if it does not exist.

3. For each file in `[plugin-root]/rules/g-rules/`, copy it to `.claude/rules/` prefixed with `g-rules-`. Overwrite if it exists — G-Forge managed.

   | Source | Destination |
   |--------|-------------|
   | `rules/g-rules/A-session.md` | `.claude/rules/g-rules-A-session.md` |
   | `rules/g-rules/B-workflow.md` | `.claude/rules/g-rules-B-workflow.md` |
   | `rules/g-rules/C-agent-discipline.md` | `.claude/rules/g-rules-C-agent-discipline.md` |
   | `rules/g-rules/D-code-quality.md` | `.claude/rules/g-rules-D-code-quality.md` |
   | `rules/g-rules/E-architecture-gate.md` | `.claude/rules/g-rules-E-architecture-gate.md` |
   | `rules/g-rules/F-design-patterns.md` | `.claude/rules/g-rules-F-design-patterns.md` |
   | `rules/g-rules/G-documentation.md` | `.claude/rules/g-rules-G-documentation.md` |
   | `rules/g-rules/H-testing.md` | `.claude/rules/g-rules-H-testing.md` |
   | `rules/g-rules/I-project-tracking.md` | `.claude/rules/g-rules-I-project-tracking.md` |
   | `rules/g-rules/J-memory.md` | `.claude/rules/g-rules-J-memory.md` |

4. Ensure `CLAUDE.md` contains `@G-RULES.md` near the top (after the title, before any other content):
   ```
   @G-RULES.md
   ```

Report:
```
✓ G-RULES.md — installed
✓ .claude/rules/g-rules-*.md — 10 rule section files installed
```

## Step 2b — Create context.md (ubiquitous language) and reference it

`context.md` is the project's durable domain glossary — the shared language that keeps code, UI labels, filenames, and conversation aligned on one word per concept. It loads into every session via `@context.md` in CLAUDE.md.

1. Ensure `CLAUDE.md` contains `@context.md` directly under the `@G-RULES.md` line (add it if missing — both the freshly-templated and the pre-existing CLAUDE.md paths must end up with this reference).

2. **If `context.md` does not exist** at the project root, create it with this starter content. **If it already exists, leave it untouched — it is developer-authored content, never overwrite it.**

   ```markdown
   # Project Context — Ubiquitous Language

   > Durable domain glossary, loaded into every session via `@context.md` in CLAUDE.md.
   > One word per concept. Keep these terms aligned across code, UI labels, filenames, and conversation.
   > Add a term when a new domain concept enters the project; update one when its meaning shifts.

   ## Glossary

   | Term | Means | Avoid calling it | Appears in |
   |------|-------|------------------|------------|
   | [Term] | [one-sentence definition in domain language] | [synonyms that cause confusion] | [code path / UI label / table] |

   ## Domain rules & invariants

   - [A business rule that must always hold, stated in domain language — not implementation terms]

   ## Actors & boundaries

   - [Key user roles and external systems, and the exact name each is referred to by]
   ```

   If `project_brief.md` exists, read it and pre-fill any obvious domain terms, actors, and rules already stated there — do not invent terms the project hasn't established.

Report:
```
✓ context.md — created (ubiquitous-language glossary)   [or: ✓ context.md — already present, left as-is]
✓ CLAUDE.md — @context.md reference ensured
```

## Step 3 — Create ROADMAP.md

Create `ROADMAP.md` if it does not exist:

```
# Roadmap

## Current Milestone
- **M1** — [Define milestone name] — 🚧 In progress

## Backlog
- M2 — [Define next milestone]

## Done
(none yet)
```

If a `project_brief.md` exists, read it and use the project goals to fill in M1 and M2 with meaningful content.

## Step 4 — Create milestones/M1.md

Create the `milestones/` directory if it does not exist.
Create `milestones/M1.md` if it does not exist:

```
# M1 — [Milestone Name]

## Goal
[One sentence describing what this milestone delivers]

## Scope
- [ ] Task 1
- [ ] Task 2

## Done condition
[Specific, mechanically checkable condition]

## Status
🚧 In progress
```

## Step 5 — Create todo.md

Create `todo.md` if it does not exist:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HANDOFF — [project] | branch: [branch]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Done this pass:   · (nothing yet)
Next up:          · Define M1 scope in milestones/M1.md
Active context:   · Fresh project, just initialized
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Tasks
| # | Task | Notes |
|---|------|-------|
| 1 | Define M1 scope | Update milestones/M1.md |

## Details
```

## Step 6 — Set up commit enforcement hooks

Create `.claude/hooks/` directory if it does not exist.

All four hook scripts are **copied verbatim from the plugin cache** rather than inlined here, so a fresh `/g-init` installs the same canonical hook bodies that `/g-update` and `hooks/*.sh` in the plugin source ship. Inlining them here previously caused divergence — new projects ran the pre-M15 hooks until `/g-update` was run.

Plugin hooks directory: use Glob to find the highest-versioned entry under `~/.claude/plugins/cache/g-forge/g-forge/*/hooks/`. Call this `<plugin-hooks>`.

For each of the following five hook files, copy from `<plugin-hooks>/<filename>` to `.claude/hooks/<filename>`. If the file already exists at the destination, overwrite it — these scripts are g-forge managed and must stay in sync with the plugin cache.

| Hook | Source | Destination |
|------|--------|-------------|
| `check-commit.sh` | `<plugin-hooks>/check-commit.sh` | `.claude/hooks/check-commit.sh` |
| `post-commit-cleanup.sh` | `<plugin-hooks>/post-commit-cleanup.sh` | `.claude/hooks/post-commit-cleanup.sh` |
| `pre-compact.sh` | `<plugin-hooks>/pre-compact.sh` | `.claude/hooks/pre-compact.sh` |
| `session-start.sh` | `<plugin-hooks>/session-start.sh` | `.claude/hooks/session-start.sh` |
| `workflow-checkpoint.sh` | `<plugin-hooks>/workflow-checkpoint.sh` | `.claude/hooks/workflow-checkpoint.sh` |

After copying each file, ensure it is executable: `chmod +x .claude/hooks/<filename>` (best effort — on Windows, file mode bits may not apply but Claude Code still runs the script via bash).

Report:
```
  ✓ .claude/hooks/check-commit.sh — installed (canonical from plugin cache)
  ✓ .claude/hooks/post-commit-cleanup.sh — installed (canonical from plugin cache)
  ✓ .claude/hooks/pre-compact.sh — installed (canonical from plugin cache)
  ✓ .claude/hooks/session-start.sh — installed (canonical from plugin cache)
  ✓ .claude/hooks/workflow-checkpoint.sh — installed (canonical from plugin cache)
```

If the plugin cache does not contain any of the five scripts, stop and report:
```
✗ Plugin cache missing hook file: <plugin-hooks>/<filename>
  Reinstall the plugin: /plugin install g-forge
```

## Step 7 — Register hooks in .claude/settings.json

Read `.claude/settings.json` if it exists. If it does not exist, start with `{}`.

Add the following hook entries under the `hooks` key. If `hooks` already exists, merge — do not overwrite existing hooks.

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'bash \"$(git rev-parse --git-common-dir)/../.claude/hooks/workflow-checkpoint.sh\"'",
            "timeout": 5000
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'bash \"$(git rev-parse --git-common-dir)/../.claude/hooks/check-commit.sh\"'",
            "timeout": 5000
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'bash \"$(git rev-parse --git-common-dir)/../.claude/hooks/post-commit-cleanup.sh\"'",
            "timeout": 5000
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'bash \"$(git rev-parse --git-common-dir)/../.claude/hooks/pre-compact.sh\"'",
            "timeout": 5000
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'bash \"$(git rev-parse --git-common-dir)/../.claude/hooks/session-start.sh\"'",
            "timeout": 8000
          }
        ]
      }
    ]
  }
}
```

Write the merged result back to `.claude/settings.json`.

## Step 7a — First-chat onboarding (voice + tier)

Ask the developer two short questions to set up `.claude/voice-profile` and `.claude/integration-tier`. Ask one at a time, wait for each answer.

**Question 1 (voice):**
> "How should I talk to you?
>   1) **dev** — terse, assumes you know the jargon (default)
>   2) **mid** — same info, one sentence of context per major result
>   3) **eli5** — plain language, no jargon, conversational
>
> Pick one (default: dev). You can change anytime with /g-voice."

Wait for the answer. Map `1`/`d`/`dev` → `dev`; `2`/`m`/`mid` → `mid`; `3`/`e`/`eli5` → `eli5`; anything else or empty → `dev`. Write the resolved value to `.claude/voice-profile`.

**Question 2 (integration tier):**
> "How present should G-Forge be?
>   1) **full** — all hooks fire; /g-plan, /g-execute, /g-review auto-trigger (default)
>   2) **balanced** — state info only; you invoke skills manually; commit gate still on
>   3) **light** — workflow-checkpoint only; commit gate off (opt-out mode)
>
> Pick one (default: full). You can change anytime with /g-tier."

Wait for the answer. Map `1`/`f`/`full` → `full`; `2`/`b`/`balanced` → `balanced`; `3`/`l`/`light` → `light`; anything else or empty → `full`. Write the resolved value to `.claude/integration-tier`.

If the developer chose `light` for the tier, surface the consequence in the active voice profile:
- `dev`: `⚠ Light tier — commit gate off. Manual mode.`
- `mid`: `⚠ Light tier selected — the commit gate is off. You can git commit without /g-review.`
- `eli5`: `Got it. You picked the minimal mode. I won't block your commits and I won't auto-suggest steps. You're driving; I'll be available when you call me.`

Report:
```
  ✓ .claude/voice-profile — [resolved]
  ✓ .claude/integration-tier — [resolved]
```

## Step 8 — Report

After all steps, report:

```
G-Forge initialized ✓

  ✓ CLAUDE.md — G-Forge rules injected
  ✓ G-RULES.md — installed
  ✓ .claude/rules/g-rules-*.md — 10 rule section files installed
  ✓ context.md — ubiquitous-language glossary created (or left as-is)
  ✓ ROADMAP.md — stub created (or already existed)
  ✓ milestones/M1.md — created (or already existed)
  ✓ todo.md — created (or already existed)
  ✓ .claude/hooks/ — check-commit.sh, workflow-checkpoint.sh, post-commit-cleanup.sh, pre-compact.sh, and session-start.sh installed
  ✓ .claude/settings.json — hooks registered
  ✓ .claude/voice-profile — [chosen voice]
  ✓ .claude/integration-tier — [chosen tier]

Next: run /g-plan with your first feature request, or edit milestones/M1.md to define your scope.

**Recommended MCPs** — install these in Claude Code for best results with G-Forge:
- `context7` — pulls current library docs into context, eliminates stale-training hallucinations
- `github` — read PRs, diffs, issues directly from chat
- `supabase` — SQL, migrations, schemas from chat (install if your project uses Supabase)

To install: Claude Code → Settings → MCP Servers, or add to `~/.claude/settings.json` under `mcpServers`.
```

## Rules
- Never create a file that already exists without reading it first.
- If project_brief.md exists at the project root, use its content to pre-fill ROADMAP.md, milestones/M1.md, and context.md.
- `context.md` is developer-authored — create the starter only if absent, never overwrite an existing one. (`/g-update` leaves it alone for the same reason.)
- Settings.json merge must never drop existing hooks — read before writing.
