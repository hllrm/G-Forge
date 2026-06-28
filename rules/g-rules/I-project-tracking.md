## Project Tracking

### File hierarchy

| File | Written by | Purpose |
|------|-----------|---------|
| `project_brief.md` | `/g-kickoff` | Project goals, constraints, stack decisions |
| `ROADMAP.md` | `/g-roadmap`, HQ | Milestone plan (current, backlog, done) **+ the `## Active Session` handoff** — the single canonical cold-start (Done this pass / Next up / Active context), rewritten each pass |
| `milestones/M*.md` | `/g-roadmap`, `/g-plan` | Per-milestone scope, tasks, done conditions |
| `todo.md` | HQ | Active task ledger — Tasks + Details (tactical; the handoff lives in `ROADMAP.md`) |
| `todo-done.md` | HQ | Archive of closed tasks and pass reports |
| `g-docs/decisions/NNN-title.md` | `/g-adr` | Architectural Decision Records — rationale behind significant technical choices |
| `g-docs/env-vars.md` | `doc-writer`, `/g-docs` | Environment variable reference — name, purpose, required/optional, example |
| `CHANGELOG.md` | HQ, `doc-writer` | Version history — features, fixes, breaking changes, deprecations |

### Commit gate infrastructure

Three hook scripts installed by `/g-init` under `.claude/hooks/`:

- **`check-commit.sh`** (PreToolUse) — blocks `git commit` if `.claude/g-forge-approved` is absent. `/g-review` writes the sentinel after issuing MERGE READY.
- **`post-commit-cleanup.sh`** (PostToolUse) — deletes `.claude/g-forge-approved` after each successful commit. The gate resets automatically.
- **`workflow-checkpoint.sh`** (UserPromptSubmit) — reads branch, milestone, review state, and Tier 3 listen mode on every prompt. Output appears as a system reminder at the top of each turn.

Never bypass the commit gate with `--no-verify` or by manually writing the sentinel.

### The handoff lives in ROADMAP.md

There is **one** handoff, and it lives in `ROADMAP.md` under a `## Active Session` heading — not in `todo.md`. `ROADMAP.md` is committed, so a fresh session (or a fresh clone) has exactly one document to target for "where am I / what's next," with no redirect to a second file. The handoff is rewritten (replaced, never appended) each pass and committed; the same block is posted in chat (chat is for paste, the file is the persistent record).

```
## Active Session

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HANDOFF — <project> | branch: <branch>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Done this pass:   · <item>
Next up:          · <item>
Active context:   · <file:line, state, in-flight logic>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

`workflow-checkpoint.sh` reads the `Active context:` line on every prompt; `pre-compact.sh` snapshots the whole block; `/g-resume` re-hydrates from it; `/g-retro` refreshes it at session end. One writer-target, one read-target.

### todo.md structure

**`todo.md`** — two sections only (tactical task ledger, no handoff):
1. `## Tasks` — `| # | Task | Notes |` table. Notes column: `*` when a Details section exists.
2. `## Details` — `### N — Title` subsections for asterisked rows only.

**`todo-done.md`** — archive. All closed tasks, pass reports, and summaries. Never inflate `todo.md` with history.

Rules: closing a task = remove row + Details from `todo.md`, append to `todo-done.md`. Both files committed every session. Every edit to either file commits immediately — never left dirty.
