## Tasks
| # | Task | Notes |
|---|------|-------|
| 1 | Refresh g-wiki for M46 (v2.4.0) **+ the 2.5 freeze/fork re-scope** — wiki still names M46→M41→M45→M42 and M29–M34 as the live roadmap, now contradicting the README freeze section | deferred 2026-07-23 · widened 2026-08-10 (doc-review) |
| 2 | Whole-system audit, top-tier reasoning | * developer-requested 2026-07-28 · next up — decomposer intake closed 2026-08-10 (M47/M48 roadmapped, ADR-012) |

## Details

### 2 — Whole-system audit at top-tier reasoning

Developer-requested 2026-07-28: run a full audit of the entire system at the highest reasoning tier available (Fable, xHigh/max effort), not the per-changeset review the gate already performs. The stated precondition was "after the 2.5 bug sweep closes"; slot 1 of that sweep closed 2026-08-07 and the handoff now sequences this as STEP 2, after the task-decomposer intake — see **Sequencing** below.

**Why now and not earlier.** The `/g-init` 4-of-6 lib bug (closed 2026-08-07, `ec9bf8a`) was found by a human hand-walking an install list, not by any check in this repo — and it had survived every gate, every doctor run, and a full release. That is a detection gap this project cannot close by reviewing diffs, because the defect was never in a diff: it was in an enumeration that drifted from what the code actually does.

**Sharpened by the fix pass itself — read this before scoping.** Closing that bug took **six `code-lead` rounds and three `doc-reviewer` rounds**; seven of the nine found a defect, and the fix-reviewing rounds repeatedly surfaced *new* defects introduced by the previous round's fix. The recurring classes, all in a changeset whose subject was drift:
- **Count drift** (5 instances) — hand-typed counts in CHANGELOG, a test header, `CLAUDE.md`, and a "three non-gating hooks" claim against a six-hook class.
- **Stale/false cross-references** (4 instances) — a check-number renumbering (`40ccbeb`, Check 16 insertion) never swept downstream, surviving in `g-doctor`, G-RULES §I, `g-roundtable`, and ADR-001; plus six ADR-011 line cites invalidated by this changeset's own insertions.
- **Partial-enumeration fixes** (3 instances) — correcting one instance of a duplicated claim and leaving its twin, twice caught by review. This is the same failure mode as the original bug, committed inside its fix.
- **Blind-spot derivations** (2 instances) — `hooks/pre-commit` has no `.sh` extension and fell out of a `hooks/*.sh` sweep, producing two wrong "sourced by" rows.

**Scope to settle at planning time**, but the shape is: every hand-maintained enumeration versus what the code actually references · every cross-file line cite and check-number reference versus its target · hook contract conformance across both hook classes · skill/agent/router structural conformance · dead or unreachable paths · the assumptions in force in ADRs 001-012 checked against the tree rather than against each other. Scope also against the keyline field report's recurring classes (`g-docs/field-reports/2026-08-10-keyline-francesco.md`) — independent confirmation of the same fix-loop disease.

**Sequencing:** the bug sweep's slot 1 is closed. The original intent was audit-before-re-scope; the developer pulled the re-scope forward and executed it 2026-08-10 (ADR-012) — if the audit surfaces something that changes what 2.5 must contain, it amends ADR-012 rather than blocking on it. Audit runs next, before M47 planning.
