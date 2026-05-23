## Project Tracking

### File hierarchy

| File | Written by | Purpose |
|------|-----------|---------|
| `project_brief.md` | `/g-kickoff` | Project goals, constraints, stack decisions |
| `ROADMAP.md` | `/g-roadmap` | Milestone plan — current, backlog, done |
| `milestones/M*.md` | `/g-roadmap`, `/g-plan` | Per-milestone scope, tasks, done conditions |
| `todo.md` | HQ | Active task ledger — Handoff + Tasks + Details |
| `todo-done.md` | HQ | Archive of closed tasks and pass reports |
| `docs/decisions/NNN-title.md` | `/g-adr` | Architectural Decision Records — rationale behind significant technical choices |
| `docs/env-vars.md` | `doc-writer`, `/g-docs` | Environment variable reference — name, purpose, required/optional, example |
| `CHANGELOG.md` | HQ, `doc-writer` | Version history — features, fixes, breaking changes, deprecations |

### Commit gate infrastructure

Three hook scripts installed by `/g-init` under `.claude/hooks/`:

- **`check-commit.sh`** (PreToolUse) — blocks `git commit` if `.claude/g-team-approved` is absent. `/g-review` writes the sentinel after issuing MERGE READY.
- **`post-commit-cleanup.sh`** (PostToolUse) — deletes `.claude/g-team-approved` after each successful commit. The gate resets automatically.
- **`workflow-checkpoint.sh`** (UserPromptSubmit) — reads branch, milestone, review state, and Tier 3 listen mode on every prompt. Output appears as a system reminder at the top of each turn.

Never bypass the commit gate with `--no-verify` or by manually writing the sentinel.

### todo.md structure

**`todo.md`** — three sections only:
1. `## Handoff` — one block, replaced (never appended) each pass. Cold-start context.
2. `## Tasks` — `| # | Task | Notes |` table. Notes column: `*` when a Details section exists.
3. `## Details` — `### N — Title` subsections for asterisked rows only.

**`todo-done.md`** — archive. All closed tasks, pass reports, and summaries. Never inflate `todo.md` with history.

Rules: closing a task = remove row + Details from `todo.md`, append to `todo-done.md`. Both files committed every session. Every edit to either file commits immediately — never left dirty.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HANDOFF — <project> | branch: <branch>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Done this pass:   · <item>
Next up:          · <item>
Active context:   · <file:line, state, in-flight logic>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Same content in both the committed file and the chat message — chat is for paste, file is the persistent record.
