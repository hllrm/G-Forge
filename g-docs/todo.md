## Tasks
| # | Task | Notes |
|---|------|-------|
| 1 | Refresh g-wiki for M46 (v2.4.0 — update-path contract split) | deferred at milestone close 2026-07-23 |
| 2 | Whole-system audit, top-tier reasoning | * developer-requested 2026-07-28 · precondition was bug-sweep slot 1, closed 2026-08-07 |

## Details

### 2 — Whole-system audit at top-tier reasoning

Developer-requested 2026-07-28: run a full audit of the entire system at the highest reasoning tier available (Fable, xHigh/max effort), not the per-changeset review the gate already performs. The stated precondition was "after the 2.5 bug sweep closes"; slot 1 of that sweep closed 2026-08-07 and the handoff now sequences this as STEP 2, after the task-decomposer intake — see **Sequencing** below.

**Why now and not earlier.** The `/g-init` 4-of-6 lib bug (closed 2026-08-07, `ec9bf8a`) was found by a human hand-walking an install list, not by any check in this repo — and it had survived every gate, every doctor run, and a full release. That is a detection gap this project cannot close by reviewing diffs, because the defect was never in a diff: it was in an enumeration that drifted from what the code actually does.

**Sharpened by the fix pass itself — read this before scoping.** Closing that bug took **six `code-lead` rounds and three `doc-reviewer` rounds**; seven of the nine found a defect, and the fix-reviewing rounds repeatedly surfaced *new* defects introduced by the previous round's fix. The recurring classes, all in a changeset whose subject was drift:
- **Count drift** (5 instances) — hand-typed counts in CHANGELOG, a test header, `CLAUDE.md`, and a "three non-gating hooks" claim against a six-hook class.
- **Stale/false cross-references** (4 instances) — a check-number renumbering (`40ccbeb`, Check 16 insertion) never swept downstream, surviving in `g-doctor`, G-RULES §I, `g-roundtable`, and ADR-001; plus six ADR-011 line cites invalidated by this changeset's own insertions.
- **Partial-enumeration fixes** (3 instances) — correcting one instance of a duplicated claim and leaving its twin, twice caught by review. This is the same failure mode as the original bug, committed inside its fix.
- **Blind-spot derivations** (2 instances) — `hooks/pre-commit` has no `.sh` extension and fell out of a `hooks/*.sh` sweep, producing two wrong "sourced by" rows.

**Scope to settle at planning time**, but the shape is: every hand-maintained enumeration versus what the code actually references · every cross-file line cite and check-number reference versus its target · hook contract conformance across both hook classes · skill/agent/router structural conformance · dead or unreachable paths · the assumptions in force in ADRs 001-011 checked against the tree rather than against each other.

**Sequencing:** the bug sweep's slot 1 is closed. Deliberately before the roadmap re-scope commits 2.5's full content, since a wide audit is the one thing likely to change what 2.5 must contain.
