# Done — archive of closed tasks and pass reports

## 2.5 bug sweep — slot 1: `/g-init` installed 4 of 6 `hooks/lib` scripts

**Pass report (2026-08-07, `ec9bf8a` on `fix/g-init-lib-install`, merged `--no-ff` to `main`):** A field report, verified against the repo, found `/g-init` installing four of the six `hooks/lib/` scripts. `stdin-read.sh` appeared in **zero** skill files despite being sourced by all seven top-level hooks; `semver-compare.sh` was likewise absent. Three skills and six README sites carried the same stale hand-maintained enumeration, so a fresh `/g-init` produced a broken install, `/g-update` would not heal it, and `/g-doctor` Check 16 would not flag it — all three read the same list. Shipped broken in v2.4.0. Found by a human hand-walking the install list, because the defect was never in a diff.

| # | Task | Outcome |
|---|------|---------|
| 1 | Correct every install-list enumeration | `g-init` (table, report block, 4→6, eleven→thirteen), `g-update` (table + lead-in, incl. `hooks/pre-commit` in the sourced-by column), six README sites. Skills and README moved in the same commit. |
| 2 | Guard the two unguarded `gf_read_stdin_timeout` call sites | `session-start.sh` + `workflow-checkpoint.sh` now carry the define-once shim; the two comments describing a guard that ran *after* the failing call are corrected. Shim body bounded at all three shim sites (`observe.sh` pulled in) rather than falling back to an unbounded `cat`. Measured: 6s exit against a 25s cap with stdin held open. |
| 3 | Durable test — assert installed ⊇ actually-sourced | `tests/test-lib-install-completeness.sh`, 41 assertions. Derives the lib set from what the hooks source and what is on disk, asserts every document agrees in both directions, matches count claims by shape rather than line number, and hard-aborts if ground truth cannot be derived. Negative-tested four ways. |
| 4 | `/g-doctor` Check 16 derives instead of enumerating | Enumerates `hooks/lib/*.sh` from disk; new sub-check greps the *installed* hooks for lib references and asserts each is installed — the consumer-side detection the repo's own suite cannot provide. Reports inconclusive, never Pass, when it derives nothing. |
| 5 | Stale check-number cross-references | Four sites corrected (`g-doctor:252`, G-RULES §I, `g-roundtable:37`, ADR-001) from the `40ccbeb` Check-16 insertion that renumbered advisory checks and was never swept downstream. Six ADR-011 line cites re-resolved. Completed-milestone records deliberately left frozen. |

**Suite:** 18 suites, 564 passed, 0 failed (was 523/17). **Gates:** MERGE READY (`code-lead`, 6 rounds) + DOCS READY (`doc-reviewer`, 3 rounds). Both verdicts predate two post-gate edits made in the same commit — the ADR-001 check-number fix and its CHANGELOG bullet — which were verified against the tree but not re-gated.

**Process finding — feed to `/g-patterns`, and it is the strongest argument yet for todo task 2 (whole-system audit).** Nine review rounds (6 `code-lead` + 3 `doc-reviewer`); seven found a defect, and the fix-reviewing rounds repeatedly surfaced *new* defects introduced by the previous round's fix. Four recurring classes, all inside a changeset whose subject was drift: **count drift** (5) — hand-typed counts in CHANGELOG, a test header, `CLAUDE.md`, and a "three non-gating hooks" claim against a six-hook class; **stale/false cross-references** (4) — a check renumbering never swept downstream, plus ADR line cites invalidated by this changeset's own insertions; **partial-enumeration fixes** (3) — correcting one instance of a duplicated claim and leaving its twin, which is the original bug committed inside its own fix; **blind-spot derivations** (2) — `hooks/pre-commit` has no `.sh` extension and fell out of a `hooks/*.sh` sweep, producing two wrong rows. Two defects were introduced *after* a MERGE READY verdict, which is why the loop kept running. The durable lesson: a claim about a file's whole surface must be re-derived from the tree, and a fix to a duplicated claim must sweep the claim's string class, never the line the reviewer named.

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
