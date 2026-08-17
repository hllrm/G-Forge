# Done — archive of closed tasks and pass reports

## 2026-08-12 — M47 Planning-Pipeline Honesty shipped (merge `6590b60`)

Full pass in one session off /g-resume: /g-plan M47 (8 tasks -> 4 slots via M47's own sizing rule) -> 2 waves -> 4 review rounds: r1-r3 dual-axis (code-lead + cautious reviewer, all HOLD; r2's critical was a fix-minted stale fallback), r4 a code-lead-only delta round -> MERGE READY, then a pre-commit 6-minor sweep. The M47 commit itself carried no doc sentinel — doc coverage ran as the cautious reviewer's in-review backstop (recorded in its r1-r3 records). Suite 564/564 attested twice (quiet machine; one load-flake pair mid-pass, re-run green x2). Live same-day reproduction of the decomposer empty-return bug during its own fix pass. Records: g-docs/agent-output/review/*2026-08-12*.md; retro g-docs/retros/2026-08-12-m47-planning-honesty.md; forecast (committed, now formula input) g-docs/forecasts/m47-planning-pipeline-honesty.md. Close swarm deferred to next session (context gate).

## STEP 2 — Whole-system audit at top-tier reasoning (task 2, closed 2026-08-11)

**Pass report (2026-08-11):** Developer-requested 2026-07-28, executed as 7 parallel Fable auditors (enumerations · cross-refs · hook contracts · structure · dead paths · ADRs-vs-tree · test blind spots), each single-use, findings-only, interrupted once by a platform session limit and resumed intact. **80 findings summed from the reports' own declared totals: 11 blocking · 29 warning · 40 note** (an earlier hand count said 79/39 — one "recorded-clean" note in audit-4 was silently excluded; corrected here, derive-don't-exclude). Full reports: `g-docs/agent-output/audit/audit-{1..7}-*.md` — **local-only, gitignored, expensive to regenerate**. Enforcement spine (ADRs 004/005/007/008/009/011) verified implemented to the letter. Keyline journal mystery settled with captured payloads (harness sends empty agent_type; task name recoverable from SubagentStop but unread). Remediation triaged into `g-docs/todo.md` tasks 3–7; the original task text (scope shape, four recurring classes, sequencing history) is preserved in `g-docs/todo.md`'s git history (last at the 2026-08-10 re-scope commit) and superseded by the executed reports.

---

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

## 2026-08-11 — Audit Wave A+B remediation (tasks 3+4, merge 29e4a98)

| # | Task | Outcome |
|---|------|---------|
| 3 | Audit Wave A — doc/enum one-liners (10 items, audit reports 1/2/4/6) | Shipped: g-specialize table 4 wrong paths fixed **+ 4 missing rows the review caught** (flask/pygame/xamarin/frontend-data-flow — table now bijective with profiles/) · telemetry roster 19 both sites · README two-layer bypass · §I/§J heading letters · ADR-009/010 back-stamps · severity-contract rule derived from test-review-severity pins (incl. security-auditor native-scale carve-out) · rust-architect name · M28 renumber · M1/M2 archive links |
| 4 | Audit Wave B — code fixes (8 conditions, 11–18 in the gate record `code-lead-2026-08-11.md`; audit reports 3/5/7) | Shipped: check-commit bounded shim (no blocking cat) + KNOWN FAIL-OPEN doc, all 5 shim bodies byte-identical `${1:-5}` (11) · post-commit-cleanup shim (INPUT="" left gate stuck open) + explicit exit 0 (12) · g-plan session-keyed counter + derived threshold, 45−offset floor 25, was stale literal 40 (13) · g-afk training-mode block, g-train's canonical string (14) · STDIN_GUARD_WINDOW_MS=20000 on both abandoned-stdin cases (15) · g-doctor Check 25 governing-tier guard, worktree-aware — 25 checks = 16+9 (16) · g-init gitignore globs the keyed counter `session-prompt-count*`, closing audit-5 F-6's counter leg (17) · CHANGELOG [Unreleased] entries for every shipped-surface fix (18) |
| — | Gate: 4 review rounds (code-lead r1 1M/4m + cautious code-reviewer 7M/12m parallel → r2 3M/1m → r3 1M/1m → r4 MERGE READY 0M/2m, minors fixed pre-commit). One reviewer Major refuted with hash evidence (installed copies WERE synced). Suite 564/18 attested green twice by g-forge-dev, totals summed from per-suite table both times | Recurring reviewer catch: my own count half-sweeps (CHANGELOG "three"→"five" left trailing site; case-25 comment swapped one false claim for another) — same typed-enumeration disease the audit hunts. Fix that stuck: derive the sentence from ground truth (test pins + agent files) before writing it |
| 8 | `tests/test-stdin-read.sh:80` timing bound too tight for MSYS (asserted `<2000ms` on its own 1s timeout; reproduced red at 2876ms loaded / 2588ms idle, 2026-08-16) | Shipped 2026-08-16 as part of a wider fix: all three of the suite's abandoned-pipe/lib-read bounds were extracted to a single shared declaration, `tests/lib/timing-bounds.sh` — `GF_LIB_READ_WINDOW_MS=6000` (2× the 2876ms worst observed) and `GF_HOOK_STDIN_GUARD_MS=65000` (2× the 31.9s worst observed). The root finding was duplication, not the number: the hook-guard bound had been widened in `test-class-split-invariant.sh` and not in its twin `test-check-commit.sh`, and that suite went red on the next run (20919ms/20955ms vs 20000ms). A cross-referencing comment was tried first and rejected in favour of a single definition — "a comment saying keep these in step does not enforce; a single definition does". All three suites now source the lib; zero duplicated timing literals remain in `tests/`. CHANGELOG `[Unreleased] → Fixed` entry shipped in the same changeset |
