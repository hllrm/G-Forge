## Tasks
| # | Task | Notes |
|---|------|-------|
| 1 | Refresh g-wiki for M46 (v2.4.0 — update-path contract split) | deferred at milestone close 2026-07-23 |
| 2 | BUG — `/g-init` installs 4 of 6 `hooks/lib` scripts; `stdin-read.sh` in no skill file | * field report, verified 2026-07-28 · slot 1 of the 2.5 bug sweep |
| 3 | Whole-system audit, top-tier reasoning, after the bug sweep closes | * developer-requested 2026-07-28 |

## Details

### 2 — BUG: `/g-init` installs 4 of 6 `hooks/lib` scripts

Field report (`gforgeissue.md`, 2026-07-28), **verified against the repo** — accepted with one correction. Affects v2.4.0 as shipped.

**Bug A — the install list is short (report confirmed in full, and it under-counts the sites).** `hooks/lib/` ships six scripts; three skills **and the README** enumerate four. `stdin-read.sh` appears in **zero** skill files across all 38, and all seven top-level hooks source it. `semver-compare.sh` is likewise absent from the install list; it appears in `g-doctor`/`g-update` only as plugin-root self-sourcing for their own version ordering (ADR-009), which is why the omission survived to 2.4.0 — nothing asserts *installed ⊇ actually-sourced*.

Sites, all confirmed present:
- `skills/g-init/SKILL.md` — table `:248-251` · "the four `lib/` files" `:253` · report block `:266-269` · "any of the **eleven** files above" `:272` · "7 hooks + **4** lib/ scripts installed" `:469`
- `skills/g-update/SKILL.md` — "The **four** `lib/` scripts below" `:257` · table rows from `:270`
- `skills/g-doctor/SKILL.md` — "For each of the **4** canonical lib scripts" `:136` (Check 16)
- `README.md` — **six sites the field report missed and this entry originally missed too**: `:165` "four shared lib scripts" · `:246` "seven event hooks plus four shared lib scripts" · `:300` "7 hooks + 4 lib scripts" · `:307` "seven event hooks, four lib scripts" · `:503-506` (names the four installed libs, one per line) · `:561` "7 hooks + 4 lib". The rider this entry sharpens had **already named README as a co-site** — `g-docs/retros/2026-07-23-m46-update-integrity.md:35` reads "README '4 lib scripts' mirrors the skill, fix both together" — and it was dropped when this entry was first written. Caught by the doc gate. CHANGELOG `:37`/`:51` are historical release notes and correctly stay frozen.

**Bug B — unguarded call sites: TWO, not the four the report claims.** The report's audit missed `observe.sh:29-30`, which defines a fallback shim (`if ! command -v gf_read_stdin_timeout … gf_read_stdin_timeout() { cat 2>/dev/null; return 0; }`), so both of its call sites are covered by a define-once pattern rather than check-at-callsite. Genuinely unguarded, both confirmed shim-free:
- `hooks/session-start.sh:23`
- `hooks/workflow-checkpoint.sh:29`

Both carry a comment claiming the missing lib "degrades to an unset/empty `_STDIN_PAYLOAD` via the guard below" — the guard is `: "${_STDIN_PAYLOAD:=}"`, which runs *after* the call has already failed. The documented degradation does not exist.

Guarded and needing no change: `agent-lifecycle.sh:62`, `check-commit.sh:96` (`command -v` + blocking-`cat` fallback — this is why the commit gate stays safe), `post-commit-cleanup.sh:57`, `pre-compact.sh:18` (`[ -f … ] &&`), `observe.sh` (shim).

**Corrected impact.** Stderr noise on every prompt (`workflow-checkpoint`) and every session start (`session-start`), **not** on tool calls — the three hooks that fire on tool calls (`check-commit.sh` PreToolUse, `post-commit-cleanup.sh` and `observe.sh` PostToolUse, all on the `Bash|PowerShell` matcher, so shell calls only) are each guarded or shimmed. In those two hooks stdin is never drained, losing exactly the broken-pipe protection the comments were added to provide. A fresh `/g-init` produces the broken install, `/g-update` will not heal it, and `/g-doctor` will not flag it, because all three carry the same hand-maintained list.

**Relationship to existing riders.** Sharpens two carried backlog items rather than replacing them, both first recorded **2026-07-23**: "g-doctor Check-16 lib enumeration stale" (`g-docs/retros/2026-07-23-m46-update-integrity.md:35`, which already named both missing libs *and* the README co-site) and "`command -v` hardening" (`g-docs/retros/2026-07-23-m-audit-close-v230.md:35`). Both described a *detection* gap. The new and more serious half is that `/g-init` itself installs short, which was recorded nowhere.

**Fix, three parts:**
1. Add `stdin-read.sh` and `semver-compare.sh` to all three skill lists **and the six README sites**; bump every count (4→6, eleven→thirteen, "four `lib/` files"→"six"). Skills and README must move in the same commit: bumping the skills alone leaves README asserting four, which turns a consistent-but-wrong document into one that contradicts shipped behaviour.
2. Wrap `session-start.sh:23` and `workflow-checkpoint.sh:29` in `check-commit.sh`'s `command -v` pattern (or `observe.sh`'s shim — pick one and use it consistently), and correct the two comments that describe a guard that isn't there.
3. **The durable one.** A `tests/` assertion that greps `hooks/*.sh` for `lib/[a-z-]*\.sh` and asserts every hit appears in g-init's Step 6 table. These lists are hand-derived from an enumeration nobody re-checks; this is the same derive-don't-type doctrine [ADR-011](decisions/011-inject-claude-md-from-committed-sources.md) applied to CLAUDE.md, pointed at the install list. Without it the next lib added repeats this exactly.

**Found by** hand-scaffolding G-Forge into a cloud session with no plugin install, following `skills/g-init/SKILL.md` step by step and then verifying each installed hook actually ran. The by-hand path exercises precisely the file list the skill specifies, which is what made the omission visible — worth remembering as a review technique, since no automated path in the repo walks that list as a list.

### 3 — Whole-system audit at top-tier reasoning

Developer-requested 2026-07-28: after the 2.5 bug sweep closes, run a full audit of the entire system at the highest reasoning tier available (Fable, xHigh/max effort), not the per-changeset review the gate already performs.

**Why now and not earlier.** Task 2 was found by a human hand-walking an install list, not by any check in this repo — and it had survived every gate, every doctor run, and a full release. The riders that half-knew about it were recorded **2026-07-23** and the report landed **2026-07-28**, five days, and `stdin-read.sh` itself shipped in that same 2026-07-23 pass, so the defect is no older than the lib. The span is short; what matters is that nothing in the repo could close it. One rider even named the README co-site explicitly and the connection to a broken *install* was still never made by any automated path. That is a detection gap this project cannot close by reviewing diffs, because the defect was never in a diff: it was in an enumeration that drifted from what the code actually does.

**Scope to settle at planning time**, but the shape is: every hand-maintained enumeration versus what the code actually references (the class task 2 belongs to) · hook contract conformance across both hook classes · skill/agent/router structural conformance · every cross-file count and cite · dead or unreachable paths · the assumptions in force in ADRs 001-011 checked against the tree rather than against each other.

**Sequencing:** strictly after the bug sweep, so the audit reads a tree with the known defects already gone and every finding is genuinely new. Deliberately before the roadmap re-scope commits 2.5's full content, since a wide audit is the one thing likely to change what 2.5 must contain.
