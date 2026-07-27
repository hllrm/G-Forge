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

## Pass report — 2026-07-28 — Check 24 injection-rule detector (ADR-011 build)

| # | Task | Outcome |
|---|------|---------|
| 1 | Check 24 in `/g-doctor` (four buckets, five riders, count 23→24) | Shipped `91a36b8` — advisory, read-only, injection-hardened |
| 2 | `/g-trim` Step-1 import-follow (T1 sunset visibility) | Shipped — line-initial, path-gated, project-owned targets only |
| 3 | Count sweep (g-doctor SKILL, README ×3, g-wiki/usage.md:222) | Repo-wide absence-grep caught g-wiki — forecast scenario 1 hit as predicted |
| 4 | CLAUDE.md voice-profile local-only wrap | Declared-local count 0→1, tripwire baseline armed (local edit, gitignored) |
| 5 | CHANGELOG `[Unreleased]` + record currency (ADR-011, transitional-rules) | Shipped in same commit |
| 6 |  Gate: 4 HOLD rounds (code-lead r1 6M/3m → orchestrator axes 1C/11M/11m → security-auditor 3M/4m → code-lead r2 1M/2m), each fixed and re-verified → SECURITY: PASS 7/7 → MERGE READY | 1C/21M/20m findings total (awk-summed from code-lead-2026-07-28-check24-r2.md:138), all fixed, none deferred |
