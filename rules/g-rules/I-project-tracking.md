## Project Tracking

### File hierarchy

| File | Written by | Purpose |
|------|-----------|---------|
| `g-docs/project_brief.md` | `/g-kickoff` | Project goals, constraints, stack decisions |
| `g-docs/ROADMAP.md` | `/g-roadmap`, HQ | Milestone plan (current, backlog, done) **+ the `## Active Session` handoff** — the single canonical cold-start (Done this pass / Next up / Active context), rewritten each pass |
| `g-docs/milestones/M*.md` | `/g-roadmap`, `/g-plan` | Per-milestone scope, tasks, done conditions |
| `g-docs/todo.md` | HQ | Active task ledger — Tasks + Details (tactical; the handoff lives in `g-docs/ROADMAP.md`) |
| `g-docs/todo-done.md` | HQ | Archive of closed tasks and pass reports |
| `g-docs/decisions/NNN-title.md` | `/g-adr` | Architectural Decision Records — rationale behind significant technical choices |
| `g-docs/env-vars.md` | `doc-writer`, `/g-docs` | Environment variable reference — name, purpose, required/optional, example |
| `CHANGELOG.md` | HQ, `doc-writer` | Version history — features, fixes, breaking changes, deprecations |
| `g-wiki/` | `/g-wiki` | Human-facing project wiki — narrative architecture + how-to. **Committed** project content (not a runtime artifact); refreshed at each milestone close. Distinct from `g-docs/` (operational records) and `/g-docs` (code-level doc hygiene). |

### Working memory vs. the durable record — the Roundtable (M33)

`/g-roundtable` can bind the session to **the Roundtable** — a shared live Doc that is the human-facing communication layer (see `g-docs/milestones/M33-the-roundtable.md`). The Roundtable is **working memory, not truth**: the live surface where humans and sessions talk, plan, and decide. The files above are the **durable record** — authoritative. The Roundtable writes through to the record only on a human nod (`/g-roundtable close` → handoff + ADRs + todo). Nothing is "decided" until it is in the record.

- **Bind record:** `.claude/roundtable` (gitignored — never committed; holds the surface ref, never a credential).
- **Off by default:** no `.claude/roundtable` ⇒ every `/g-roundtable` path is a no-op and behaviour is **byte-identical** to the git-mediated flow. The Roundtable is opt-in, triggerable, never autonomous.
- **Surface-agnostic** per ADR-001: the skill talks to a four-op adapter (`bind`/`read_section`/`append_feed`/`write_living_state`), never an MCP directly. Link-restricted, never public; no secrets on the Roundtable.

### `g-docs/` is the canonical home for every G-Forge document

All G-Forge-generated documents — project tracking included — live under `g-docs/`. Nothing G-Forge writes belongs at the project root except `CLAUDE.md` (Claude Code loads it there), `G-RULES.md` (`@`-referenced config), and `CHANGELOG.md`. Every skill writes into one of these canonical subpaths:

| Subpath | Written by | Holds |
|---------|-----------|-------|
| `g-docs/ROADMAP.md` · `g-docs/todo.md` · `g-docs/todo-done.md` · `g-docs/milestones/` · `g-docs/project_brief.md` | `/g-roadmap`, `/g-plan`, `/g-kickoff`, HQ | Project tracking |
| `g-docs/decisions/` | `/g-adr` | ADRs |
| `g-docs/retros/` | `/g-retro` | Session retrospectives |
| `g-docs/forecasts/` · `g-docs/plans/` | `/g-forecast`, `/g-plan`, `/g-execute` | Plans + wave forecasts |
| `g-docs/blast-radius/` | `/g-blast-radius` | Change-impact maps |
| `g-docs/telemetry/` · `g-docs/telemetry-metrics.md` | `/g-telemetry` | Usage telemetry |
| `g-docs/alignment/` | `/g-align` | Brief-drift checks |
| `g-docs/agent-output/` · `g-docs/qa-scope/` | `/g-execute`, `/g-review` | Raw agent output (regenerable) |
| `g-docs/env-vars.md` · `g-docs/identity.md` · `g-docs/patterns-deferred.md` | `/g-docs`, `/g-identity`, `/g-patterns` | Reference docs |

**Tracked vs. ignored:** the `g-docs/` project record is **committed** (it *is* the project) — except `g-docs/agent-output/` (and any local `g-docs/plans/` scratch), which is regenerable and gitignored. The `.gitignore` `/g-init` writes (Step 5a) draws this line; `/g-doctor` Check 19 keeps it honest, and Check 20 flags any G-Forge document that strays outside `g-docs/`.

### Commit gate infrastructure

Three hook scripts installed by `/g-init` under `.claude/hooks/`:

- **`check-commit.sh`** (PreToolUse) — blocks `git commit` if `.claude/g-forge-approved` is absent. `/g-review` writes the sentinel after issuing MERGE READY.
- **`post-commit-cleanup.sh`** (PostToolUse) — deletes `.claude/g-forge-approved` after each successful commit. The gate resets automatically.
- **`workflow-checkpoint.sh`** (UserPromptSubmit) — reads branch, milestone, review state, and Tier 3 listen mode on every prompt. Output appears as a system reminder at the top of each turn.

Never bypass the commit gate with `--no-verify` or by manually writing the sentinel. Never chain verification commands onto a gated commit invocation — a failed trailing step makes PostToolUse skip, leaving the commit unjournaled.

### The handoff lives in g-docs/ROADMAP.md

There is **one** handoff, and it lives in `g-docs/ROADMAP.md` under a `## Active Session` heading — not in `g-docs/todo.md`. `g-docs/ROADMAP.md` is committed, so a fresh session (or a fresh clone) has exactly one document to target for "where am I / what's next," with no redirect to a second file. The handoff is rewritten (replaced, never appended) each pass and committed; the same block is posted in chat (chat is for paste, the file is the persistent record).

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

### g-docs/todo.md structure

**`g-docs/todo.md`** — two sections only (tactical task ledger, no handoff):
1. `## Tasks` — `| # | Task | Notes |` table. Notes column: `*` when a Details section exists.
2. `## Details` — `### N — Title` subsections for asterisked rows only.

**`g-docs/todo-done.md`** — archive. All closed tasks, pass reports, and summaries. Never inflate `g-docs/todo.md` with history.

Rules: closing a task = remove row + Details from `g-docs/todo.md`, append to `g-docs/todo-done.md`. Both files committed every session. Every edit to either file commits immediately — never left dirty.
