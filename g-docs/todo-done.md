# Done — archive of closed tasks and pass reports

## M28 — g-docs as the canonical home for all G-Forge documents

**Pass report (built, pending release):** Made `g-docs/` the single home for every G-Forge document. Moved the project-tracking files off the root into `g-docs/` and rewrote every live reference; added a `.gitignore`-defining step to `/g-init` and two new `/g-doctor` advisory checks (gitignore vet · stray-doc relocation). Closed:

| # | Task | Outcome |
|---|------|---------|
| 1 | Migrate tracking docs into `g-docs/` + update all live references | `ROADMAP.md → g-docs/ROADMAP.md`; `g-docs/{todo,todo-done}.md` + `g-docs/milestones/` established. 472 refs across the live set rewritten; historical records untouched. |
| 2 | `/g-init` defines the project `.gitignore` | New Step 5a — idempotent merge, runtime ignored / project record + shared `.claude/` config tracked. |
| 3 | `/g-doctor` vets the `.gitignore` | New advisory Check 19. |
| 4 | `/g-doctor` finds + relocates stray g-forge docs | New advisory Check 20 (`git mv` fixes, offers to move). |
| 5 | Confirm every skill writes under `g-docs/`; document the subpath map | Audited; canonical subpath map added to `g-rules-I-project-tracking`. |
| 6 | Sync CHANGELOG + README; verify grep-clean | CHANGELOG `[Unreleased]` entry; README paths migrated; grep confirms only historical records + the g-doctor stray-detector name the old root paths. Version bump deferred to release. |
