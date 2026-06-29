# M28 — g-docs as the canonical home for all G-Forge documents

## Goal
Make `g-docs/` the single canonical home for every G-Forge-generated document — including the project-tracking files that currently live at the repo root — and give `/g-doctor` the checks to keep it that way: vet the `.gitignore` that `/g-init` now writes, detect and relocate stray g-forge docs, and confirm every skill writes under `g-docs/`.

## Why
Today G-Forge scatters its outputs: operational records land under `g-docs/` (retros, decisions, plans, telemetry…) while project tracking sits at the root (`ROADMAP.md`, `todo.md`, `todo-done.md`, `milestones/`, `project_brief.md`). Two homes means two places to look, two things to gitignore correctly, and an easy way for a doc to end up "stray." One canonical home — `g-docs/` — makes the layout learnable, the `.gitignore` decidable, and drift mechanically checkable.

## Scope boundary — what moves vs. what stays

**Moves into `g-docs/`:**
| Old path | New path |
|----------|----------|
| `ROADMAP.md` | `g-docs/ROADMAP.md` |
| `todo.md` | `g-docs/todo.md` |
| `todo-done.md` | `g-docs/todo-done.md` |
| `milestones/` | `g-docs/milestones/` |
| `project_brief.md` | `g-docs/project_brief.md` |

**Stays at root (tooling/convention requires it):**
- `CLAUDE.md` — Claude Code loads it from the project root.
- `G-RULES.md` — `@`-referenced from `CLAUDE.md`; the `.claude/rules/` section files are unaffected.
- `CHANGELOG.md`, `README.md`, `LICENSE` — conventional root files, not G-Forge tracking artifacts.
- `g-wiki/` — committed human-facing content, already its own tracked home (never gitignored).

**Not rewritten (historical records, left as written):** `g-docs/retros/`, `g-docs/archive/`, CHANGELOG history entries, and the M23 audit kickoff paste block in the roadmap.

## Tasks

- [x] **T1 — Migrate tracking docs into `g-docs/`.** `ROADMAP.md` `git mv`'d to `g-docs/ROADMAP.md`; `g-docs/milestones/` + `g-docs/todo.md` established. Every *live* reference (skills, hooks `workflow-checkpoint.sh`/`pre-compact.sh`, rules, agents, commands, templates, README, live `g-docs/` doctrine docs) rewritten to the `g-docs/` path. Historical records left untouched.
- [x] **T2 — `/g-init` defines the project `.gitignore`.** New Step 5a writes/merges the `.gitignore` (runtime artifacts ignored, project record + shared `.claude/` config tracked). Idempotent merge. This repo's own `.gitignore` updated so the migrated `g-docs/` tracking is committed.
- [x] **T3 — `/g-doctor` vets the `.gitignore`.** New advisory Check 19 — runtime exclusions present, no tracked-by-design path ignored (incl. over-broad bare patterns).
- [x] **T4 — `/g-doctor` finds + relocates stray g-forge docs.** New advisory Check 20 — scans root + non-`g-docs/` doc folders, reports each stray with a `git mv` fix, offers to move.
- [x] **T5 — Confirm every skill writes under `g-docs/`.** Audited; canonical `g-docs/` subpath map encoded in `g-rules-I-project-tracking`.
- [x] **T6 — Sync the record.** CHANGELOG `[Unreleased]` entry added; README paths migrated; `grep` confirms zero live references to old root paths (only historical records + the g-doctor stray-detector name them). Version bump to v2.2.0 deferred to release (developer's call).

## Done condition
`grep -rn` for the old root tracking paths returns only historical records (retros/archive/CHANGELOG-history/M23-block); `/g-init` writes a correct `.gitignore`; `/g-doctor` has the three new checks (gitignore vet, stray-doc relocation, writes-under-g-docs) and reports green on this repo; CHANGELOG + README reflect the new canonical layout.

## Status
✅ Built — pending release (version bump deferred to next tagged release)
