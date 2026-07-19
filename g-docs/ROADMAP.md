# G-Forge

> Multi-agent Claude Code plugin — planned execution, production architecture, enforced review.

## Active Session

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HANDOFF — g-forge | branch: main | W1.5a–W1.5d SHIPPED (all reviewed MERGE READY, committed) @ v2.2.1 (v2.3.0 pending milestone close — upgraded from v2.2.2, developer 2026-07-18)
⚠ FIRST: **`/g-plan` W1.5e** — skill-layer edits (g-review Step 6 ↔ Step 2 reconciliation + Step 1 test-runner generalization; g-init `<git-hooks-dir>` warning fix; post-commit-cleanup.sh:3 header fix) — then W1.5f guard-idiom + terminal attestation (slices in the M-audit section; standing rule: new minors route to W1.6/W2, never back into a slice) → W1.6 (tests for W1.3+W1.4; observe.sh sed escaped-quote item; carried minors: W1.5a newline-boundary + glued-pathspec-fidelity tests; W1.5b shadowed `.md` dir-arm fixtures + invariant grep missing `hooks/pre-commit`; NEW from W1.5d: case-(b) malformed-partial-stamp advisory-delta test + wave-agent doc-writer overreach structural note; ⚠ oversized, expect split) → W1.7 (live verify incl. FIRST REAL RUN of the stamped-sentinel + native pre-commit path — the native hook is still not installed LOCALLY until /g-update runs here, W1.7 territory; NOTE: local install now copies 4 libs incl. sentinel-read.sh). Do NOT re-plan/re-implement W1.1–W1.5d. **ADR-006 implementation stays a POST-M-audit slice.** stash@{0} confirmed superseded — droppable, developer's call.
LATEST (2026-07-18e): **Roadmap restructured — rebrand becomes the capstone (developer decision).** Three linked calls made at the approval gate: (1) **M-audit ships v2.3.0, not v2.2.2** — W1 is new capability (native pre-commit site, 4 libs, 12-file install set, 187 tests), not a patch; the release pass at close now also ships the first README **status strip** (version badge + CHANGELOG link + ROADMAP link, high on the page) + the `[2.3.0]` CHANGELOG cut — **standing README/CHANGELOG currency convention starts here**. (2) **M41 split:** release machinery (/g-changelog + /g-release + doctor version-consistency + currency enforcement) stays at v2.4.0 right after M-audit; the **G-Proof rebrand + full persuasion-ordered README restyle moved to NEW M44 — the capstone, sequenced dead last, shipping as G-Proof 1.0** (versioning restarts under the new name; rationale: consumers keep a stable name through the heavy middle, no mid-arc 3.x renumbering, "proof" claimed only when M38/M39 self-governance can back it). (3) **Downstream renumbered back into 2.x** (M42 v2.5.0 … M43 v2.13.0; Version Plan block rewritten). M41.md rewritten + new M44.md carries the rename waves. ADR-worthy (naming/version strategy) — capture via /g-adr when next touched. **NEXT: unchanged — see FIRST (W1.5e).**
LATEST (2026-07-18d): **W1.5d shipped — the riskiest slice, sandwich closed clean.** Plan: 12 tasks / 4 waves (fail-before suite ∥ 4-surface doc propagation → fail-before attest [hard gate] → coupled extraction → pass-after attest + consistency sweep; forecast 80% High with the calibration caveat ON the forecast doc — first one written under the new information-not-paranoia presentation; note the formula DOES discriminate: 55 W1.5c vs 80 this). Executed: suite 16 assertions (fail-before 0/16 attested with the 4 inline extraction lines enumerated → pass-after 16/16); `gf_parse_stamp` → `hooks/lib/sentinel-read.sh` byte-identical, both call sites converted, validator untouched; 187/187 across 10 files + fixture 35/35. **Forecast scenarios 1–2 both fired and were caught:** (1) mid-wave the extraction agent's doc-writer child RETRO-EDITED the shipped W1.4 CHANGELOG entry (11→12 — falsified history; single line, HQ-reverted, attested intact) — contained scope overreach, structural note → W1.6/W2; (2) the case-(b) malformed-partial-stamp advisory delta surfaced exactly as predicted — documented+quantified by the implementer instead of silently picked, accepted by code-lead as bounded (advisory-only; gate still denies). Review MERGE READY (0c/0M/2m). Records: plan (gitignored local) + forecast `g-docs/forecasts/w1-5d-sentinel-read-extraction.md` + review `code-lead-2026-07-18-w15d.md` + agent output `g-docs/agent-output/wave-w15d/`. **NEXT: see FIRST (W1.5e).**
LATEST (2026-07-18c): **W1.5c shipped — cleanest slice of the split.** Plan: 8 tasks / 2 waves (wave-planner's initial 7-wave same-file serialization consolidated to one implementer dispatch + one attestation; forecast 55% Elevated). Wave 1 DONE first attempt: fixture 19→35 assertions (scenarios j1/j2/j3 doc-only class, k conflicted-index with standalone write-tree canary rc=128, l separate-git-dir with resolver-reject canary rc=1/empty); no hook bugs; counter integrity verified (35 parent-shell checks = 35 printed lines). Wave 2 ATTESTED-GREEN (g-forge-dev: 35/35 + suite 171/171). Review MERGE READY — **zero findings, all axes PASS** (code-lead-2026-07-18-w15c.md). **Developer field feedback captured at the approval gate (intake-approved):** (1) /g-forecast miss-risk has NEVER read <50% (all 8 on record 55–90%) → alarm fatigue, number ignored; (2) /g-plan context budget is a static exchange-count snapshot, never reconciled with live /context. Direction: "information not paranoia" — risk on the CHANGE (files-to-change complexity, not project complexity); salience layer (M36/M37) as scenario-selection mechanism. Logged: `g-docs/milestones/M36-salience-inputs/2026-07-18-forecast-calibration-feedback.md` (placement: M38/M39 primary, M36 input, rename/split pull-forward eligible). Records: forecast `g-docs/forecasts/w1-5c-pre-commit-gate-fixtures.md` + review `code-lead-2026-07-18-w15c.md`. **NEXT: see FIRST (W1.5d).**
LATEST (2026-07-18b): **W1.5b shipped — full /g-plan→forecast→execute→review cycle in-session.** Plan: 8 tasks + 2 conditional riders / 4 waves (forecast 65% Elevated; scenarios 1, 2 AND the rider class all fired and were caught — forecast earning its keep). Both riders fired on fail-before evidence: **7a** whitespace-only classify FAIL → HQ adjudicated header-wrong-not-body-wrong (inline loop `9688e95` byte-identical; fail-toward-deny stays; comment-only lib fix + test flip, #26 polarity precedent); **4a** worktree-suite fixture bug (`-c` after subcommand) → flag-order fix, which then surfaced a latent **false-green counter trap** (subshell-lost counters → `Results: 0/0` always-exit-0) → restructured to parent-shell counting + CANARY PROOF (corrupted copy reports 24/1 exit 1). Probe-first discipline held (agent probe + HQ spaced-path gap-fill; fixture note: spaced worktrees need explicit `-b`). Final: **171/171 across 9 suites** (baseline 104/7 + classify 42 + worktree 25), worktree list untouched. Review MERGE READY (0c/0M/3m; minors 1–2 → W1.6, minor 3 fixed pre-stamp). Doc gate + stamped sentinels + commit this pass. Records: plan (gitignored local) + forecast `g-docs/forecasts/w1-5b-worktree-classify-suites.md` + review `code-lead-2026-07-18-w15b.md`. **NEXT: see FIRST (W1.5c).**
LATEST (2026-07-18): **W1.5a shipped after a live HOLD→fix→MERGE READY cycle.** Re-dispatched the killed review fresh: code-lead **r1 HOLD (1 Critical)** — glued-operator chains (`x&&git commit`, `true\|git commit`, `echo hi;git commit`) bypassed the new segment splitter (operators glued between words survive xargs tokenization as one token; every chain fixture used spaced operators, so 35/35 stayed green — the exact evasion class #25 targets, live fail-open until W1.7). HQ probe-confirmed the bypass empirically before presenting. Developer chose **fix in-slice** over route-to-W1.7: single-point raw-string sed normalization (pad bare `&`/`\|`/`;` pre-tokenization; quoted operators re-unified by xargs so commit messages never split) + `KNOWN-BUG-glued-chains` fixtures + 2 regression pins. Implementer single-use redeploy; HQ re-probed (all 6 glued/spaced forms DETECTED, guards hold, quoted-msg pathspec empty) + attested **104/104 across 7 suites** (new suite 43/43). code-lead re-verified the delta independently → **r2 MERGE READY** (0c/0M/2m; both axes PASS). Two fail-safe minors → W1.6 (quoted-filename operator pathspec fidelity — traced through classify-changeset, unmatched ⇒ CODE = stricter gate; newline-boundary dedicated test); env -S glued residual re-characterized NOT a fail-open (env -S doesn't interpret shell operators). Ledger row `25i+26i` added; plan Progress updated. Note: g-forge-dev attestation dispatch was killed by a session limit mid-run — HQ ran the attestation directly instead (suite output verbatim in-session). review-holds counter now 3 (r1 HOLD recorded). **NEXT: see FIRST.**
LATEST (2026-07-17): **ADR-006 verified against repo (5/5 claim groups hold — surfaces registered, ADR-004/005 coherent, no wave-code contradictions, hash-object round-trip + gc window + stash residue all as recorded) → W1.3 committed `45c0c98`** (gate caught the missing doc sentinel on the mixed commit; /g-doc-review DOCS HOLD→READY added the missing CHANGELOG W1.3 entry; both sentinels consumed on commit — live proof of W1.3's dual-sentinel primary clear). **Then full W1.4 cycle in-session: /g-plan (9 tasks → 1 wave / 4 file-disjoint agents; forecast 65% Elevated, top mitigations folded in) → /g-execute (4/4 DONE first attempt, wave-close integrity clean, no collisions) → /g-review MERGE READY (0c/0M/2m) + doc gate (2 count-drift blockers found+fixed, DOCS READY on re-check) → committed `1fdf016` with ADR-004 STAMPED sentinels (first stamped-format write: `commit_sentinel_ts/head/worktree`).** Forecast scenario 2 (count drift beyond scoped files) hit twice and was caught both times by the doc gate — the gate is earning its keep; scenario 1 (collision) did not occur; reconcile the w1-4 forecast Outcome table at retro. Suite 61/61 (new: sed-tier fail-before/pass-after). Records: plan `g-docs/plans/w1-4-install-wiring-drift-detection.md` · forecast `g-docs/forecasts/w1-4-install-wiring-drift-detection.md` · reviews `g-docs/agent-output/review/{code-lead,doc-reviewer}-2026-07-17.md`. **NEXT: see FIRST.**
LATEST (2026-07-16b): **W1.3 /g-review → MERGE READY (fresh session, full headroom) + ADR-006 recorded.** Suite attested 60/60; code-lead verified all 9 done conditions (0 critical, 0 major, 4 minor → W1.4/W1.5/W1.6); phantom W2/W3/W6 re-confirmed absent; Tier-3 satisfied by the sandbox model per no-manual-QA doctrine; sentinel written, ledger row `11i–18i` added. Then `/g-patterns` (post-milestone mining): `parallel-agent-file-collision` weighted **Systemic** (retro + forecast predicted-and-hit) → triage escalated into doctrine instead of a prompt band-aid → **ADR-006 — Adopt optimistic wave concurrency: collisions absorbed, not prevented** (Accepted, two-way door). Mechanism: wave-open baseline sweep + flight recorder (`git hash-object -w` + append-only log, common-git-dir-resolved) + owner-aware wave-close integrity check with report-first restore + `NEEDS_GLOBAL`→HQ + solo-wave rule + frozen 3-verb friction deny; worktree isolation **off-doctrine** behind a defined trigger (absorption cost >5% of wave tokens, rolling 5 waves). Off-context deliberation caught 3 real design holes (untracked-file coverage, ownership-blind compare, restore-over-human-edits) — all folded in; all 8 stress-test weaknesses closed with explicit dispositions. Pattern triage logged to `g-docs/patterns-deferred.md`. W1.3-forecast Outcome table reconciled (1–3 did not happen; 4 yes→ADR-006; 5 unverified). Retro: `g-docs/retros/2026-07-16-adr-006-optimistic-waves.md`. Zero commits this pass (W1.3 commit deliberately left to the fresh session after ADR verify). **NEXT: see FIRST.**
─── prior pass (2026-07-16a) ───
LATEST (2026-07-16): **W1.3 Wave 2 verification PASSED (HQ-confirmed) + G-Proof rebrand docs reconciled.** Ran `/g-execute W1.3 Wave 2`: dispatched `claude-plugin-implementer` for consolidated verification; it flagged W2/W3 (`agent-lifecycle.sh`) + W6 (`observe.sh` corruption) as bugs — **HQ independently re-ran and refuted all three as phantom** (agent read a stale mid-restore snapshot; correction appended to `g-docs/agent-output/wave-2/consolidated-verification.md`). HQ-confirmed done condition: suite 60/60, single-classifier grep 0 matches, all six hooks activate from a linked worktree (`wt`-tagged PRIMARY writes for observe/agent-lifecycle; primary sentinel clear for post-commit-cleanup; light-tier skip honored; banners for session-start/pre-compact/workflow-checkpoint), primary paths byte-identical; Wave 2 marked complete. **Finding #21 reproduced live** (commit gate false-fired on a sandbox Bash string containing `git commit` → worked around via a script file); **finding #22 live** (journal logs agents as "unknown"). **Also: G-Proof rebrand (v3.0.0) docs fully reconciled** — decision made in another session; this pass cleaned `M41.md`'s draft tail (+ added M43 to the cascade), reconciled the whole version plan across `ROADMAP.md` 2.x→3.x (M41 v3.0.0 … M43 v3.9.0), synced the ROADMAP M41 section body to M41.md's full 4-wave rebrand scope, fixed M41.md's `/g-changelog` git-log-vs-ledger conflict, and ran a clean name-collision check (no `g-proof` product/npm/repo). Retro: `g-docs/retros/2026-07-16-w13-verify-gproof-rebrand.md`. Zero commits (all uncommitted doc/record edits; `stash@{0}` still pending, droppable once the working tree is confirmed authoritative). **NEXT: `/g-review` W1.3 in a FRESH session → MERGE READY → commit → W1.4→W1.7; v2.2.2 at milestone close; M41 (G-Proof) immediately after.**
─── prior pass (2026-07-15) ───
LATEST (2026-07-15): **W1.2 shipped** — `check-commit.sh` fully swapped onto `hooks/lib/{commit-detect,worktree-resolve,classify-changeset}.sh` (last one NEW this pass — single-classifier invariant now structural, #21 surfaces 1+3 dead in the PreToolUse site); native **`hooks/pre-commit`** built per ADR-004/005 (write-tree+HEAD+worktree stamp verify, first-commit both-empty match only, mixed needs both sentinels, consume-on-pass; deny = stderr + exit 1 — NOT installed anywhere yet, W1.4 owns install/registration); `g-doc-review` Step 1 staged-union flip (8d residual closed). Review: code-lead r1 HOLD (Major: stamp's terminal worktree field truncated at first space → spaced Windows paths permanently denied; fixed + fail-before/pass-after fixture), r2 MERGE READY; 2 minors → W1.5/W2 (g-review SKILL Step 6 literal-HEAD wording gap; architecture-rule note: native git hooks vs PreToolUse hook classes). 60/60 suite green throughout. ⚠ Anomaly: W1.2 content reached main as raw-terminal commit `1621a70 "seed"` DURING the session (ungated — PreToolUse can't see terminal commits, native hook not yet installed: the exact hole W1.2 closes; content fully reviewed post-hoc, kept). Tier-3 note: developer confirmed there is NO manual QA path — model is sandbox fixtures + release-and-dogfood + consumer field reports (G-Cash/G-Tools, a company-adopted derived g-forge); don't hold gates on hands-on smoke tests. **Also this pass:** repo-local never-shipped `g-forge-dev` runner agent + `g-dev/fixtures/` harness scaffolded, reviewed (r3, zero findings), committed `c91fe2f` (83/83 attested on its debut; /g-review Step-1 delegation seam → W1.5 scope). **M41 pulled forward to v2.3.0** (developer, 2026-07-15) and expanded: `/g-changelog` (Wave 0 — draft `[Unreleased]` from ledger/review record, human nod) + optional README currency pass in the close-out swarm (Wave 0b); downstream minors shifted +1 again (M42 v2.4.0 … M40 v2.11.0). **Also: M43 — Operator Controls added** (developer, same day): `/g-settings` (visibility + safe access to every operative variable, distinct from /g-doctor) + inspection cadence (`.claude/inspection-cadence`, ONE g-init question, hard hold at /g-execute wave boundaries for code-reading developers, M39 G-tweak reassess hook); tailed v2.12.0, parallel-friendly/pull-forward eligible. **NEXT: W1.3 (see FIRST), then W1.4→W1.7 in order; v2.2.2 at milestone close; M41 immediately after.**
─── prior pass (2026-07-14) ───
LATEST (2026-07-14): **W1.1 — Shared foundations shipped (`9688e95`).** ADR-004 and ADR-005 verified live on this repo (git-common-dir relative-vs-absolute confirmed via a real linked worktree; write-tree confirmed working on Windows/git-bash) before coding. Resolved ADR-004's one open follow-up — review-flow alignment — via a Resolution section added to the ADR: `/g-review`'s primary diff target flips to `--staged` + unstaged-tracked union, `main...HEAD` demoted to fallback; recorded on the M-audit ledger's 8r+9r row. Decomposed the full W1 scope (37 tasks / 8 waves) via `/g-plan`, hit the context-budget gate (est. ~124 vs. ~31 remaining), and split it into 7 budget-scoped sub-milestones **W1.1–W1.7** in this roadmap (sequenced, each meant to be its own `/g-plan` run — W1.3 and W1.6 are flagged oversized and expected to split further). Ran W1.1 end-to-end: implemented `hooks/lib/commit-detect.sh` (argv-based commit detection, fixes both surfaces of finding #21/BUG-2) + `hooks/lib/worktree-resolve.sh` (verified live against a real linked worktree) + the `/g-review` stamp-format/diff-target update; code-lead returned MERGE READY (0 critical, 0 major, 4 minor carry-forwards to W1.5); committed `9688e95`. Then closed the doc loop: `/g-doc-review` caught a real currency contradiction (this roadmap still described W1.1 as a `/g-plan` target after it had shipped) — fixed inline, this paragraph is that fix. **NEXT: `/g-plan` W1.2** (commit gate swap + native pre-commit hook) — see the FIRST line above.
─── prior pass (2026-07-13) ───
LATEST (2026-07-13): **Synced this machine to the cloud session's state** (`a192670` — M40 + ADR-004/005 pulled; manifest reverted to v2.2.1; this machine's stale parallel ADR-004/005 drafts + superseded handoff edit dropped after confirming the cloud versions supersede them). **Triaged a 5-bug report from the G-Tools retro corpus** into the M-audit ledger: **#21 (BUG-2, W1 — reproduced LIVE)** the commit gate false-*fires* on any command whose string merely contains `git commit` (a non-committing `grep`/`for` test string was denied; regex confirms `… && git commit -m z` fires) — the false-**positive** counterpart to #6/#7, un-fixable by loosening the regex; **folded into the ADR-004 pass** with the coordination note above. A **third surface** then fired live while committing the triage itself — the classifier tokenizes the commit-*message body* as pathspecs, so a doc commit whose message merely cites code+doc paths is misclassified "mixed" and blocked by its own description (fix must parse argv, not string-slice); recorded on #21. **#22 (BUG-3, W2)** the observer journals every agent as `unknown start/stop` — no `subagent_type`/task/RESULT — degrading /g-retro + /g-patterns. **#23 (BUG-4, W3)** g-doctor Check 21 stray-doc scan uses too narrow a dir allowlist. **#24 (BUG-5, W3)** computer-use `request_access` can't grant unregistered running binaries → doc-gap fallback in g-rules-H for native Tauri Tier-3 tests. **BUG-1 was NOT a source bug** — the doc-sentinel leak is already fixed in `f55ccdb`; G-Tools hit a **stale installed hook** → its fix is `/g-update` (live field instance of drift-finding #5, logged as 1f). All triage ledger edits **committed + pushed** (`4d4a16f`). Then reproduced **BUG-2 live 3× while committing the triage itself** (path-free commit messages + split `git add`/`commit` calls were needed to work around it), documented all three surfaces on #21, and **scoped the fix** into the tracked ledger — the `### #21 fix spec` subsection: an argv-parse `commit-detect.sh` routine that kills surfaces #1/#3 (shared with ADR-004's future `pre-commit` hook, which owns surface #2), plus a fail-before/pass-after test plan. Chosen **quick-scope-only (no code)** given gate-self-modification risk + context threshold. Retro: `g-docs/retros/2026-07-13-bug2-triage-and-scope.md`. 3 docs-only commits pushed (`4d4a16f`/`dc61fbd`/`60230b1`); zero code touched. **NEXT unchanged: verify ADR-004/005, then write the W1 code — #21 (argv-parse detection) rides that same pass, each fix with fail-before/pass-after tests through /g-review.**
─── prior pass (2026-07-12b) ───
LATEST (2026-07-12b): **M-audit W1 design items #8/#9/#10 ADR'd.** Ran `/g-adr` with off-context deliberation subagents (per doctrine) → **ADR-004** (sentinel lifecycle — #9 folded into #8) and **ADR-005** (worktree enforcement), both **Accepted**, both two-way doors. Decisions: **#8** enforcement moves to a native git `pre-commit` hook (index authoritative — survives `commit -a`/`-p` and raw-terminal commits, natively covering #9), PreToolUse kept only for the model-facing deny; `/g-review` stamps `git write-tree`+HEAD sha, hook re-derives and denies on mismatch/HEAD-advance; canonical hash = `git write-tree` of the index, anchor = HEAD sha (not mtime/diff). **#10** inherit primary state via `--git-common-dir` + **per-worktree-keyed sentinels** (`show-toplevel`) to kill cross-tree approval bleed; deny only when primary state unreachable, never silently no-op a gated worktree. The spike found the original PreToolUse-hashing framing unsound (PreToolUse fires before git stages → hashes the wrong tree) — that's why the site moved to `pre-commit`. Also captured **finding #20** (test-writer returns false `DONE` — it has no `Bash` tool, cannot run the suite it writes; recommend fix A+C: relabel DONE⇒UNVERIFIED + enforce a green run with pasted evidence at the review gate). Milestone findings #8r/#9r/#10r + #20 recorded. **NEXT after ADR verify: write the W1 code for #8/#9/#10 (resolve the ADR-004 review-flow follow-up first), then Sub-plan B test coverage (#11), then close for v2.2.2.**
─── prior pass (2026-07-12a) ───
LATEST (2026-07-12): Roadmap — added **M40 — Reference Convention** (recognize-and-vet external `reference/` material — new marker-gated REFERENCE classifier class so reference-only commits stop demanding a code MERGE READY; g-doctor provenance advisory; intake questions; optional `g-adr` `Derives from:` field. 3 waves; **Wave 1 = gate safety, a pull-forward candidate to a v2.2.x patch** since the reference-only mis-gate is a live enforcement fail-open) + backlog **Unified Provenance Primitive** (reference/ SNAPSHOT.md and the alveria fork's al-docs/UPSTREAM.md independently invented the same pinned-source+provenance-note shape — ADR-worthy to name once). Sourced from Francesco/CryusFrey's reference-folder advisory (2026-07-11). Committed `afb2b75`, **merged to main (ff), pushed; no version bump** (docs-only). **Re-entry correction:** the prior "NEXT: run /g-update here" is a **local-machine step ONLY** — /g-update is the host-sync tool (pulls the plugin cache → realigns a *consumer's* `.claude/`). This remote source clone has **no `.claude/` install and no plugin cache**, so there is nothing to sync and the commit gate is simply **not installed** in this checkout — that (not a drift) is why the M40 merge was ungated. Do NOT re-surface /g-update as the first task from a clean clone. **Real next work: M-audit W1 design items #8–10 (sentinel-lifecycle spike/ADR before code) → W2 → W3, then close for v2.2.2.**
─── prior pass (2026-07-06) ───
LATEST (2026-07-06): M-audit W1 mechanical (#5/#6/#7/#11) **MERGED to `main`** — fix `f55ccdb`, merge `7e9d9af`; reviewed **MERGE READY** (code-lead round 2, all axes PASS); **60/60 tests green on main**. Fixes shipped this pass: **#5** /g-doctor required **Check 16** (installed-copy drift — hashes installed `.claude/hooks/` vs canonical `hooks/`, portable cascade sha256sum→shasum→cksum; advisories renumbered →17–22, total N/16); **#6** commit-detection hardened for `-C`/`-c` global flags across `check-commit.sh` + `post-commit-cleanup.sh` + `observe.sh` (shared canonical regex); **#7** staged-set classifier now unions `-a`/`--all` modified-tracked files AND explicit pathspec args. Every fix pinned by a fail-before/pass-after test; new `tests/test-post-commit-cleanup.sh` + `tests/test-g-doctor-drift.sh`. Plan (all 5 waves complete): `g-docs/plans/m-audit-w1-enforcement-fixes.md`. Forecast: `g-docs/forecasts/m-audit-w1-enforcement-fixes.md` (90% High — scenario #1 "commit-gate self-modification regression" DID fire and was caught by the tests; recovered). Backup patch: `scratchpad/wave-a-backup.patch`. ⚠ **LIVE FINDING:** on the merge commit the installed `.claude/hooks/` **did not fire** (commit gate never ran; sentinel had to be cleared by hand) — the Windows-matcher / installed-copy-drift fail-open this milestone targets, demonstrated on our own repo. The fixes are in `main` source `hooks/` but this repo's INSTALLED copies are stale/inert. **NEXT: run `/g-update` here to re-sync installed hooks + settings registration (Check 16 would now flag this drift), then push if desired.** THEN W1 design items **#8–10** (spike/ADR) → **W2** (finding #19 `hllrm/G-Cash` live-install) → **W3** + new **#6b** (full `.git/config` alias resolution). THEN **Sub-plan B (tasks 16–21: baseline coverage for pre-compact/session-start/agent-lifecycle + workflow-checkpoint + runner wire-up)** via `/g-plan`. **v2.2.2 ships at milestone close, not on this partial.** Locked W1 decisions: Check 16 additive-required · hash cascade · commit-detection `-C`/`-c` flags only (full `.git/config` alias resolution DEFERRED — log a new M-audit finding). ⚠ A Wave-1 process crash reverted 3 files mid-run (observe.sh / post-commit-cleanup.sh / test-observe.sh); recovered from the agent-output trail. If re-entering and tests fail, diff those 3 against `scratchpad/wave-a-backup.patch`. A new M36 input was captured: `g-docs/milestones/M36-salience-inputs/2026-07-06-severity-calibration-report.md` (severity-calibration field report — strong evidence for the salience layer; triage via /g-intake against M36 when convenient).
─── prior pass ───
HANDOFF — g-forge | branch: main | main @ v2.2.1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Done this pass:   · **Released v2.2.1** (alveria-forge fixes #25/#26 versioned; full gate cycle self-hosted). · **Root-stray cleanup:** M1–M15 milestone files → `g-docs/milestones/` (only surviving record of M6–M15 drift); legacy brief + todo → `g-docs/archive/root-legacy/`; M27 retro committed. · **Full 3-agent audit** (structure / enforcement / consistency — ~49 findings triaged into M-audit-2026-07). **Headline: two stacked fail-opens found LIVE** — (1) hook matchers were `Bash`-only, so on Windows (PowerShell tool) the gate/cleanup/observer never fired; (2) installed `.claude/hooks/` copies had drifted pre-M27 (Bug A still active locally, doc sentinel never cleared) and nothing could detect it. · **Quick wins merged (`4158ffa`, W0 of M-audit):** matchers → `Bash\|PowerShell` in g-init/g-update + tests 17–18; /g-update Step 6a now syncs the 10 g-rules sections; count → 38. Local hooks realigned + gate loop proven live (deny unsigned → deny same-call smuggle → pass earned → auto-clear). **Downstream projects must run /g-update.** · **Roadmap resequenced (approved):** M-audit-2026-07 (v2.2.2) inserted first; **M35 Memory Forge** (v2.4.0 — linked/layered memory, real `context:` loader, graph-walk /g-resume, opt-in Obsidian) slotted after M29, before M33-B, so shared-state milestones build on the memory substrate. **Bug A (critical):** the commit gate was a NO-OP — `check-commit.sh` used `exit 1` on block paths, but PreToolUse only blocks on `exit 2`/JSON deny, so commits ran anyway (the headline differentiator, broken through v2.2.0, invisible because the test asserted exit 1). Now: `deny()` → deny JSON on stdout + exit 2; test asserts real blocking. **Bug B (high):** review pipeline failed open — a security `High` mapped to no orchestrator bucket → PASS → MERGE READY. Now: orchestrator normalizes (security High→Critical) + any-axis-HOLD⇒FAIL + `AXES:` line honored by code-lead. **Bug C:** auditor return-scales aligned to bodies. New `tests/test-review-severity.sh` (9) pins the contract. **The enforcement layer actually enforces now.** · **M33 — the Roundtable** BUILT (Phase A) + dual-surface validated LIVE (Confluence in-place v1→v2 · Gmail floor draft-and-nod · Drive eliminated). · **ADR-001** (surface adapter + tiers) · **ADR-002** (one HUMAN orchestrator seat, never co-chairs, owns `main`). · **M34 scoped** (cross-session dependency tracking + pull/push, suggest-not-act). · Table→Roundtable rename; cross-cutting propagation rule (g-rules-B + /g-roadmap/g-plan); `/g-resume` polish; project_brief.md created. (10 PRs merged: #17–#26.) · **M29 spec refined + de-risked (master seat, on `claude/g-resume-dogfood-0vu50d`):** A4 step-one **confirmed LIVE** — the official Gmail MCP exposes labels as a mutable register field (`list_labels`/`create_label`/`label_thread`/`unlabel_*`) → build commits to the **Gmail-labels variant** (Drive-doc fallback); two gaps pinned to design — no-CAS (A1 tiebreak+re-read is load-bearing) · shared-account identity (holder/session id lives *in* the claim payload, per A2). Fixed M29 premortem inconsistency ("ship Discord first" → ship official Google first; Discord is community/unofficial, never the reference). · **ADR-003 — Cowork is NOT a G-Forge host** (evaluated on GA): Cowork doesn't fire `.claude/` hooks (#63360/#40495), so the commit gate + enforcement are inert there → CLI/web/Actions stay primary, CLI not deprecated. Cowork-as-future-shared-*surface* (M29/M33 backend) survives; re-probe when Cowork honors hooks.
Next up:          · **M-audit-2026-07 Wave 1 (P0 enforcement integrity)** — /g-doctor installed-copy drift check (resolved: required, not advisory), commit-detection hardening, sentinel lifecycle design (items 8–10 spike/ADR first), hook test coverage. Then ship v2.2.2. **`/g-plan` in progress on Wave 1's mechanical items (#5/#6/#7/#11):** task-decomposer produced 17 tasks; wave-planner not yet run; paused mid-plan (see below). · **Then M29 Phase A — the register.** Start FRESH. A4's mutable-field question answered (Gmail labels ✓); Phase A proves: is convention (tiebreak + re-read, no CAS) enough? A1 schema → A2 identity/lease → A3 adapter → A4 Gmail-labels adapter over remote MCP, then the two-session collision test. · **NEW (2026-07-14): M42 — Planning Cold-Start Integrity (v2.3.0) sequenced between M-audit and M29** (G-Cash field report: planning gates have no human cold-start representation; kickoff grill + fixture-as-crutch detector + reachability gate); downstream minors shifted +1. · Then M35 Memory Forge (v2.5.0) → **M37 salience propagation (v2.6.0)** → M33 B–D (v2.7.0) → M34 → M30–32; then **M38 G-Report (v2.8.0) → M39 G-tweak (v2.9.0)**. **M36 salience approach/ADR** slots early, parallel-friendly, gates M37. · M26 (deferred) · M25 (compute-gated).
Active context:   · main @ v2.2.1 + quick-wins merge (`4158ffa`); **v2.3.0 ships when M-audit W1 closes** (upgraded from v2.2.2 — developer, 2026-07-18; release pass includes the first README status strip + CHANGELOG cut, starting the standing currency convention). Arc sequence (restructured 2026-07-18): **M-audit-2026-07 (v2.3.0) → M41 (Release Machinery + README Currency, v2.4.0 — REBRAND SPLIT OUT) → M42 (v2.5.0) → M29 (v2.6.0) → M35 (v2.7.0) → M37 (v2.8.0, salience propagation) → M33 B–D (v2.9.0) → M34 → M30–M32; then self-improvement track: M38 (v2.10.0) → M39 (v2.11.0); M40 v2.12.0 + M43 v2.13.0 tail/pull-forward; then **M44 — G-Proof 1.0, the rebrand capstone, THE last release of the arc** (versioning restarts under the new name; no mid-arc 3.0.0). M36 (salience approach/ADR) slots early, parallel-friendly, gates M37.** M-audit 🔄 (W0 done, W1 next — items 8–10 need spike/ADR before code); M29 + M34 ⬜ specs in g-docs/milestones/; M35 spec written this pass. Cleanup queue unchanged: Confluence page 109314050 + Drive doc + stale `g-table` Gmail labels — delete or keep as fixtures. Windows note: hook matchers + installed-copy drift were fail-open here — see memory `windows-hook-gotchas`. **New finding #19 (this pass):** every skill's description is hand-authored in up to 3 places (`commands/<name>.md`, `skills/<name>/SKILL.md`, `commands/g-forge.md`'s subcommand line) and has drifted repo-wide (confirmed: g-adr, g-retro, g-review, g-audit, g-plan, g-execute) — a real behavioral disagreement on g-adr, not just wording. Proposed fix (retire standalone command shims, SKILL.md sole source) escalated to `/g-adr` but **paused**: unconfirmed whether two files = two visible entries, a duplicate registration, or Claude Code's inherent short-alias+`plugin:name` pair for one registration regardless of file count — the last reading would mean the fix doesn't reduce visible entries at all. Verifying against a live install in `hllrm/G-Cash` (pulled locally by the developer) before resuming `/g-adr` Step 2. Re-enter with /g-resume.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Milestones

### M1 — Foundation
**Status:** ✅ Complete
**Version:** v0.1.0
**Goal:** Repo, plugin.json, 16 agent stubs, skill dirs, hooks, profiles, milestone files

---

### M2 — Agent Roster
**Status:** ✅ Complete
**Version:** v0.2.0
**Goal:** Full system prompts for all 16 agents — mandates, output contracts, scope discipline

---

### M3 — Skills & Orchestration
**Status:** ✅ Complete
**Version:** v0.3.0
**Goal:** /g-kickoff, /g-init, /g-plan, /g-execute, /g-review — end-to-end with commit enforcement

---

### M4 — Stack Profiles
**Status:** ✅ Complete
**Version:** v0.4.0
**Goal:** /g-specialize + 44 profiles across web, mobile, desktop, game dev, and systems

---

### M5 — Publish
**Status:** ✅ Complete
**Version:** v0.5.0
**Goal:** README, docs/agents.md, docs/orchestration-patterns.md, marketplace listing

---

### M6 — Auto-trigger & Project Hygiene
**Status:** ✅ Complete
**Version:** v0.6.0
**Goal:** workflow-checkpoint hook, auto-trigger plan/execute/review, /g-help /g-status /g-brief /g-doctor

---

### M7 — Correctness, Validation & Polish
**Status:** ✅ Complete
**Version:** v0.7.0
**Goal:** Section F design patterns, game-dev profile rules, per-project G-RULES.md, full alignment pass

---

### M8 — Deploy & Use
**Status:** ✅ Complete
**Version:** v0.9.0
**Goal:** Self-host G-Forge on this repo; add claude-plugin profile; add skill-design and skill-validate vibecoding skills
**Scope:**
- Install G-Forge into this repo (CLAUDE.md, hooks, settings.json, milestone files)
- Create milestones/M6, milestones/M7 files (retroactive)
- claude-plugin stack profile — architect agent + architecture rules
- /g-skill-design skill — guided workflow for designing new skills/agents
- /g-skill-validate skill — validates SKILL.md and agent files against quality criteria
- Register skill-design and skill-validate in commands/g-forge.md router

**Depends on:** —

---

### M9 — Intelligence Foundation
**Status:** ✅ Complete
**Version:** v0.10.0
**Goal:** Structural substrate for agent context management and decision memory
**Scope:**
- **Rename pass** — project renamed from G-Team → G-Forge; update all display strings, doc references, CHANGELOG heading, README, plugin.json `name`/`display_name`, marketplace.json, and any in-file prose mentioning "G-Team" across the full repo
- Context profiles v1 — memory slice declared in skill/agent frontmatter
- Memory layer taxonomy — 6 tiers (Working / Task / Sprint / Architectural / Institutional / Human Preference) with lifetime + audience
- ADR lineage fields — rejected alternatives, assumptions that held, constraints that drove the decision

**Depends on:** M8

---

### M10 — Organizational Learning Loop
**Status:** ✅ Complete
**Version:** v0.11.0
**Goal:** G-Forge detects recurring failure patterns and proposes self-corrections
**Scope:**
- /g-patterns skill — mines retros + todo-done for recurring failure modes; surfaces systemic health report
- Self-evolution — detected systemic pattern surfaces suggested fix to architecture profile rules, not just a report

**Depends on:** M9, accumulated retro/todo-done history

---

### M11 — Planning Intelligence
**Status:** ✅ Complete
**Version:** v0.12.0
**Goal:** /g-plan and /g-roadmap gain forecast, premortem, and in-flight health tracking
**Scope:**
- /g-forecast skill — scope realism analysis, complexity scoring, quantified risk estimate ("X% likely to miss target")
- Premortem wired into /g-forecast — ranked failure scenarios before plan approval, seeded by /g-patterns history
- Feedback loop closed — /g-patterns → premortem → /g-retro → /g-patterns
- Milestone health live monitoring — in-flight signal: blocker count, rework rate, review churn; surfaces via /g-help or hook

**Depends on:** M10 (/g-patterns must exist to seed premortem scenarios)

---

### M12 — Reliability & Adaptive Systems
**Status:** ✅ Complete
**Version:** v0.13.0
**Goal:** Instrument agent performance; system adapts its behavior based on measured reliability
**Scope:**
- 8-metric reliability telemetry: hallucination rate, review catch rate, regression frequency, rework rate, spec deviation, escalation frequency, token efficiency, retry dependency
- Adaptive orchestration — telemetry scores drive model selection and conditional reviewer spawning
- Governance intelligence — adaptive review gates by project stability and zone risk

**Depends on:** M11 (planning workflows must be instrumented before measuring them)

---

### M13 — Profile Additions
**Status:** ✅ Complete
**Version:** v0.14.0
**Goal:** Expand stack coverage and deepen existing frontend profiles
**Scope:**
- flask profile
- pygame profile
- xamarin profile
- dependency-auditor agent
- `frontend-data-flow` supplementary profile — rules + architect agent implementing the two-network model (read/write), dead-end component rule, and V1–V4 violation patterns; installed alongside any component-framework profile by `/g-specialize`
  - **Implementation note:** `/g-specialize` detection logic must be updated to auto-install `frontend-data-flow` whenever a component-framework stack is detected (vue-pinia, react, nuxt, next-js, sveltekit, angular, remix, astro, and composites). The profile is supplementary — it lives in its own directory and must be explicitly wired into the specialize skill's profile map; it will not activate automatically just by existing.

**Depends on:** M8 (independent of intelligence milestones; slots here as pacing break between M12 and M14)

---

### M14 — Advanced Production Modeling
**Status:** ✅ Complete
**Version:** v0.15.0
**Goal:** PM layer reasons about feature dependencies, costs, and long-term project trajectory
**Scope:**
- Dependency intelligence — feature-level dependency graph, blast radius analysis, volatility scoring; surfaces before execution ("this touches 4 high-volatility systems")
- Economic reasoning — token cost estimates, system impact counts, strategic deferral suggestions
- Temporal project cognition — persistent operational identity from accumulated signals: recurring risks, architectural personality, delivery patterns

**Depends on:** M12 (telemetry data), M10 (pattern history), M11 (blast radius feeds /g-forecast)

---

### M15 — Hook / Behavioral Integration Pass
**Status:** ✅ Complete — v1.0.0 shipped
**Version:** v1.0.0
**Goal:** G-Forge becomes a coherent production intelligence system, not a collection of additions
**Scope:**
- Full hook audit and behavioral flow wiring end-to-end
- Health surfaces in /g-help; premortem auto-runs in /g-plan; pattern suggestions feed /g-retro output
- UX tuning across the full system — flows feel cohesive, not additive

**Depends on:** M14 (all capabilities must be in place before the integration pass)

---

### M19 — Ambient Proactivity
**Status:** ✅ Complete
**Version:** v1.6.0
**Goal:** G-Forge watches continuously, stays anchored to the brief, and reacts to feature drops — less command-driven, more ambient
**Scope:**
- Silent observer (`hooks/observe.sh` + `hooks/agent-lifecycle.sh`) — passive `.claude/journal/` activity log; `/g-retro` reworked to synthesize from it (no interview)
- `/g-align` — brief-deviation check vs `project_brief.md`; auto-runs at milestone close, nudged between milestones; advisory
- `/g-intake` — proactive feature-drop triage (classify against brief → propose placement + version + risk → ask before writing)
- Hardened the JSON-parse cascade across all hooks (no fail-open on the Windows python3 stub)

**Depends on:** M18 (compact-return + plan-derisking foundation)

> Note: M16–M18 shipped between M15 and M19 (see CHANGELOG and README roadmap table for v1.2.0 / v1.3.3 / v1.5.0) — this file tracks the headline milestones.

---

### M20 — Single-Use Agent Doctrine
**Status:** ✅ Complete
**Version:** v1.7.0
**Goal:** Make context poisoning structurally impossible — agents are single-use; retries live at HQ via clean learnings reports, not inside a degrading executor context
**Scope:**
- Single-use agent doctrine in G-RULES §C — one approach, one attempt; names and prevents context poisoning
- `FAILED` agent outcome + `LEARNINGS:` field in the return contract, distinct from `BLOCKED`
- `/g-execute` redeploy loop — HQ analyzes learnings and deploys a fresh agent with a different mechanism, bounded by Three-Strikes (§A8), then escalates to the human
- Doctrine note in `docs/orchestration-patterns.md` framing it as the automatable form of the deliberation/execution split

**Depends on:** M18 (compact-return contract this extends)

---

### M21 — Decision Hygiene Loop
**Status:** ✅ Complete
**Version:** v1.8.0
**Goal:** Apply the single-use doctrine to HQ's own deliberation and close the loop — high-stakes thinking happens off-context, and the session resets after a decision is finalized
**Scope:**
- `/g-adr` offloads the weighing to a throwaway deliberation subagent; HQ promotes only the finalized draft (HQ window stays clean)
- Decision-hygiene reset reuses the §A7 context-gate path on a semantic trigger — `/g-retro` + handoff (`verify ADR-NNN` first) + fresh-session recommendation
- G-RULES §C extended with HQ deliberation hygiene; orchestration-patterns doctrine section extended

**Depends on:** M20 (single-use agent doctrine this generalizes to HQ)

---

### M22 — Session Re-entry
**Status:** ✅ Complete
**Version:** v1.9.0
**Goal:** Make "start a fresh session" cheap — the read side of the reset seam, so a clean window re-hydrates the right slice of the durable record instead of inheriting a poisoned one
**Scope:**
- `/g-resume` — selective re-hydration: pulls the relevant retro cold-start, in-force ADRs, journal tail, and handoff first-task into a clean window, keyed to branch/milestone/first-task; offers the clean-slate ADR verification when one was handed off
- First-prompt `/g-resume` nudge in `workflow-checkpoint.sh` when a handoff is pending
- §A7 reframed as a two-sided reset (promote out via `/g-retro`; re-hydrate in via `/g-resume`); orchestration-patterns doctrine extended with the read side

**Depends on:** M19 (observer journal), M20–M21 (the reset path `/g-resume` re-enters from)

---

### M23 — G-Forge 2.0 (Production-Readiness Audit)
**Status:** ✅ Complete
**Version:** v2.0.0
**Depends on:** all prior milestones (this audits the whole surface).

Self-contained kickoff — paste the block below into a fresh session (or open cold and run `/g-resume`, which points here):

```
G-Forge 2.0 — production-readiness audit. The bar: "no shit." Ruthless pass for
consistency, clarity, and shippability. No half-measures, no leftover cruft, no
stale docs, no claims the repo doesn't back up. Fix what you find; don't just report.

Work on a fresh branch (e.g. claude/g-forge-2.0-audit). Do NOT push to main without
explicit approval. Use G-Forge's own tooling where it fits (/g-audit, /g-docs,
/g-doctor, /g-review). Keep CHANGELOG.md AND README in sync as part of "done" for
every change — standing rule, not an afterthought.

EXPLICIT DELIVERABLES
1. .gitignore — review and tighten. Confirm it excludes everything generated
   (.claude/ runtime, scratch, agent-output, journals, sentinels, OS files) and
   nothing that is real plugin content. (Current file uses legacy "G-Team" wording.)
2. Clean the repo — remove dead/stray files; decide what should not ship. Known:
   hooks/test-check-commit.sh and hooks/test-observe.sh ship in hooks/ — move to a
   tests/ dir or exclude. Sweep orphaned references, dead links, placeholder files.
3. Agents <> hooks reconciliation — every agent a skill references exists (17
   present); every hook in hooks/hooks.json matches g-init's install table AND
   g-doctor's checks (paths, names, registration); nothing referenced-but-missing
   or installed-but-unregistered.
4. README v2 — rewrite from scratch (don't patch). Start under a PLACEHOLDER project
   name; keep the real name out until content is approved, then swap it in one pass.

CONSISTENCY / CLARITY SWEEP (seeded findings — start here, don't stop here)
- Legacy "G-Team" strings still in: hooks/hooks.json, hooks/pre-compact.sh,
  hooks/check-commit.sh, hooks/post-commit-cleanup.sh, hooks/workflow-checkpoint.sh,
  ROADMAP.md. Rename to G-Forge (leave historical retros untouched).
- Count claims vs reality: marketplace.json says "17 agents, 35 skills" but there
  are 37 commands and 35 skill dirs. Reconcile everywhere they appear (marketplace.json,
  README, CHANGELOG, /g-help) against ground truth.
- Docs vs recent behavior: /g-adr is now a 9-step flow (entry triage, capture mode,
  reversibility + premortem); the §A7 context gate now prevents compaction
  (auto-calibrating thresholds, amber active-monitoring, wave /context checks). Check
  every doc that describes these (README, G-RULES, docs/orchestration-patterns.md,
  skill/command descriptions) for stale step numbers / thresholds.
- One voice: descriptions, headers, terminology consistent across commands/, skills/,
  agents/, rules/, docs/.

VERSION: major — bump to 2.0.0 only when the audit is genuinely complete and you'd
stake "production ready" on it. Developer approves the bump.

DONE = repo clean; .gitignore correct; agents<>hooks fully reconciled; zero legacy
naming; all counts/claims true; README v2 approved and named; CHANGELOG + docs in
sync; /g-doctor green. If something can't be made production-ready in scope, say so
plainly with the reason — don't paper over it.
```

---

### M24 — Positioning & Reliability Methodology
**Status:** ✅ Complete
**Version:** v2.1.0 (docs-only; ships with the next release)
**Goal:** State what G-Forge actually is, and define how to prove it.
**Scope:**
- [x] Reposition README + marketplace + plugin descriptions around "educated, enforced project management" (governance layer, not another agent orchestrator) — grounded in the 107-agent landscape research.
- [x] `g-docs/benchmark.md` — reproducible reliability-benchmark methodology (model + G-Forge vs. raw, scored on success rate + the 8 `/g-telemetry` metrics).

**Depends on:** M23. *(Committed on `claude/m23-release-u3rx0d` (`8a20f92`); lands on `main` with the next merge.)*

---

### M25 — Run the Reliability Benchmark
**Status:** ⬜ Not started
**Version:** v2.1.0 (or whenever the number ships)
**Goal:** Turn "punch above its weight" from a claim into a defensible, published number.
**Scope:**
- [ ] **Pilot first** — run the 2–3 task B-vs-A pilot in `g-docs/benchmark.md` to shake out the harness and check for signal on a multi-file / architecture-touching task.
- [ ] **Gate:** only fund the full run if the pilot shows a lift; a null result on a task class is recorded honestly and stops the spend.
- [ ] Full benchmark (n ≥ 20, arms A–D), blind mechanical scoring, the chart + 8-metric table.

**Premortem (per `/g-roadmap` Step 3b — this milestone was added, so it ran):**
- *Harness is the real cost, not the run* — automating the G-Forge arm headless (plan→execute→review) is eval engineering; mitigate by piloting on 2–3 tasks before building the full runner.
- *Operator confound* — the G-Forge arm must be driven by a fresh model session executing the plugin, never hand-simulated, or the result is meaningless.
- *Task-class dependence* — lift concentrates on multi-file/architecture work; report per-class, never a single blended number.
- *Skeptical market* — a sloppy number is net-negative (87% distrust accuracy); do not publish until n and scoring are defensible.

**Depends on:** M24 (methodology), and a session/compute budget allocated to run it.

**Re-prioritization:** M25 sits after M24 and is gated on a pilot — it does not block any other planned work; the run happens when compute is deliberately allocated.

---

### M26 — Provable Wave Dispatch (Workflow-script execution engine)
**Status:** ⬜ Not started (deferred — re-slot after the M-audit → M29 → M35 arc)
**Version:** TBD when re-slotted (v2.3.0 reassigned to M29 in the 2026-07-01 resequence)
**Goal:** Make `/g-execute`'s fan-out *provable* rather than instructed — without G-Forge becoming "another agent orchestrator." This enforces the existing orchestration contract; it does not add a new one.
**Scope (additive opt-in — prose dispatch stays the default and the fallback):**
- [ ] Feasibility spike + design note (`g-docs/g-execute-engine-design.md`) — Workflow-tool availability detection from a skill, plugin-shipped `scriptPath` invocation, wave-plan→`args` contract, and where the per-wave `/context` capacity gate relocates once the loop is backgrounded. **Gates the build.**
- [ ] `skills/g-execute/wave-runner.workflow.js` — deterministic `parallel()` fan-out, per-wave barrier, `RESULT`-block parsing, and journal/Progress/agent-output writes **identical to the prose path**.
- [ ] Script retry/BLOCKED control flow — attempt counter, Three-Strikes ceiling, escalation-log; the §A8 "different mechanism" choice stays a model `agent()` callback (loop in script, *judgment stays model-made*).
- [ ] `skills/g-execute/SKILL.md` Step 3 opt-in branch + `.claude/execution-engine` sentinel + `/g-doctor` surfacing; prose path byte-for-byte unchanged when opt-out.
- [ ] Dual-execution-model docs + parity runbook.

**Tier 3 DoD:** Parity run — a 3-task wave (one forced-FAILED) through *both* paths yields identical FILES, `.claude/journal` + Progress-table writes, commit-gate behavior, and retry-ceiling stop.

**Forecast (advisory):** Complexity 7/10 · Miss-risk ~50% (Elevated) — risk concentrated in the spike; clean spike drops it to Moderate. Top scenarios: spike fails (→ reshape to "document the pattern"), orphaned capacity gate, parity drift, retry degradation, two-path maintenance tax.

**Depends on:** M23. Independent of M24/M25.

**Re-prioritization:** Deferred to v2.3.0 behind M27 (developer's call). Internal orchestration mechanism, spike-gated; nothing depends on it, so it slots last among non-completed milestones.

---

### M27 — Documentation Review Gate (separate from code review)
**Status:** ✅ Complete
**Version:** v2.1.0
**Goal:** Make documentation review its own gate with its own verdict — distinct from code review in trigger, lens, and process. Today doc review is a sub-check of `code-reviewer`; this promotes it to a first-class gate that can run **even when there are no code commits**.
**Scope:**
- [x] New **`doc-reviewer`** agent (read-only: Read/Glob/Grep). Lens: accuracy-vs-code, **currency** (docs that contradict the code), completeness (public exports, README sections, env vars, ADR/CHANGELOG coverage), clarity. Output: BLOCKING / WARNING / PASS → **DOCS READY / DOCS HOLD**. (17 → 18 agents)
- [x] New **`/g-doc-review`** standalone gate skill — own verdict, own cadence. (36 → 37 skills · 37 → 38 commands)
- [x] **File-set-keyed enforcement** *(the hard part)* — gate triggers on the changed file set, not on the presence of a code diff: docs touched (incl. **no-code-commit** changes — wiki, README, ADRs) **|** public/exported surface changed **|** milestone close. Doc-only commits must require a doc-review sentinel (e.g. `.claude/g-forge-docs-approved`); mixed commits require **both** gates; code-only commits are unaffected.
- [x] **Defense-in-depth split** — `code-reviewer` keeps its "missing public-export doc = Major" as a fast **backstop**; `doc-reviewer` owns the deep review. Define precedence so the two don't double-report (backstop defers when the doc gate ran).
- [x] **Blocking on public, advisory on internal** — public-API/exported doc gaps + docs that *contradict code* → DOCS HOLD; internal-only gaps + clarity/terseness → WARNING.
- [x] Clean boundary vs. `/g-docs` (audit+**generate**/write) and `doc-writer` (fills gaps): `/g-doc-review` only **judges & gates** — read-only, may *recommend* `/g-docs`, never writes. Update G-RULES §G to document the two-gate model; update `check-commit.sh` + tests.
- [x] Version bump to v2.1.0 — update plugin.json and marketplace.json version fields in one commit (developer commits at milestone close)

**Tier 3 DoD:** A doc-only change (stale README section + a `g-wiki/` edit) with **no code commit** triggers `/g-doc-review`, the gate blocks the commit until DOCS READY, and a public-export doc gap yields DOCS HOLD; a code+doc PR runs both gates; a code-only PR is untouched by the doc gate (code backstop still catches a missing public-export doc).

**Premortem (per `/g-roadmap` Step 3b):**
- *No-code trigger is the real engineering* — gating doc-only changes means the commit hook must classify the file set (code / doc / mixed), not ask "is this a code commit." Mitigate with an explicit doc-path globset + a `tests/` case per class.
- *Two-sentinel collision* — code and doc approvals can race or misclassify a mixed commit. Mitigate: mixed ⇒ both required; precedence rules; hook tests.
- *Overlap with `/g-docs`* — audit/generate vs. review/gate blur into duplicated logic. Mitigate: `/g-doc-review` is strictly read-only verdict; writing stays in `/g-docs`/`doc-writer`.
- *Backstop double-report* — retained code-reviewer doc check + doc-reviewer flag the same gap, noisy. Mitigate: backstop fires only when the doc gate was skipped.
- *"Stale" is judgment-heavy* — false HOLDs on terse-but-correct docs create friction. Mitigate: block only on contradicts-code or missing-public-surface; clarity = WARNING.

**Depends on:** M23 (review infrastructure). Independent of M24/M25/M26.

**Re-prioritization:** Promoted to the next buildable milestone (v2.2.0) — strongest fit for the M24 governance positioning and actively in design. Sits ahead of the deferred M26. (M25 is compute-gated and runs on a parallel track.)

---

### M28 — g-docs as the canonical home for all G-Forge documents
**Status:** ✅ Built — pending release (v2.2.0)
**Goal:** Make `g-docs/` the single home for every G-Forge document — including the project-tracking files (`ROADMAP.md`, `todo.md`, `todo-done.md`, `milestones/`, `project_brief.md`) that live at the root today — and give `/g-doctor` the checks to keep it that way.
**Scope:**
- [x] **Migrate tracking into `g-docs/`** — `git mv`'d the root tracking paths under `g-docs/`; updated every *live* reference (skills, hooks, rules, agents, commands, templates, README, live `g-docs/` doctrine docs) to the new path. Historical records (retros, archive, CHANGELOG history, the M23 kickoff block) untouched.
- [x] **`/g-init` defines the `.gitignore`** — new Step 5a writes/merges a project `.gitignore` that **ignores** runtime/dev artifacts (OS files, `.env*`, `.worktrees/`, ephemeral `.claude/` state + sentinels + journal, `g-docs/agent-output/`) and **tracks** the software code plus the project-tracking value (`g-docs/` records, `g-docs/ROADMAP.md`, `g-docs/todo.md`, `g-docs/milestones/`, `g-wiki/`, `CLAUDE.md`, `G-RULES.md`) and shared `.claude/` config. Idempotent merge.
- [x] **`/g-doctor` vets the `.gitignore`** — new advisory Check 19: runtime-artifact exclusions present, nothing tracked-by-design ignored (incl. over-broad bare patterns).
- [x] **`/g-doctor` finds + relocates stray g-forge docs** — new advisory Check 20: scans root + non-`g-docs/` doc folders, reports each with a `git mv` fix, offers to move.
- [x] **Confirm every skill writes under `g-docs/`** — audited; canonical `g-docs/` subpath map encoded in `g-rules-I-project-tracking`.
- [x] Sync CHANGELOG + README to the new layout; grep-clean of old root paths. Version bump deferred to release (developer's call).

**Scope boundary:** `CLAUDE.md` (Claude Code reads it at root), `G-RULES.md` (`@`-referenced config), and `CHANGELOG.md`/`README.md`/`LICENSE` stay at the root. Full breakdown in `g-docs/milestones/M28-g-docs-canonical-tracking.md`.

**Depends on:** nothing — touches scaffolding/docs/hooks paths only. Independent of M25/M26.

---

### M-audit-2026-07 — Forge Integrity (technical debt audit)
**Status:** 🔄 In progress (Wave 0 shipped as the audit-quick-wins merge)
**Version:** v2.3.0 (upgraded from the original v2.2.2 patch — developer call, 2026-07-18: W1 ships genuinely new capability, not fixes — the native pre-commit enforcement site, 4 shared libs, the 12-file install set, 187-test suite. **Release pass at close:** ship v2.3.0 with the first README **status strip** — version badge + "What's new" → CHANGELOG.md + "Where this is going" → this roadmap, placed high on the page — and the CHANGELOG `[Unreleased]` → `[2.3.0]` cut. This starts the standing README/CHANGELOG maintenance convention (developer, 2026-07-18): both stay current from every release onward; M41's `/g-release` later bakes the currency check into the release gate itself.)
**Goal:** Resolve the 2026-07-01 three-agent audit findings — enforcement layer provably enforces, drift detectable. Full prioritised tables in `g-docs/milestones/M-audit-2026-07.md`.
**Scope:**
- W0 ✅ quick wins: Windows matcher fail-open, /g-update g-rules sync gap, skill count (merged `4158ffa`)
- W1 (P0): ADR-004 (sentinel↔tree binding) + ADR-005 (worktree enforcement) implementation + finding #21 fold-in — 37 tasks / 8 waves, split into budget-scoped sub-parts (each sized to fit a session's `/g-plan` context-budget gate; sequenced 1→7, run `/g-plan` on each in order):
  - **W1.1 — Shared foundations ✅ Complete (`9688e95`):** `hooks/lib/commit-detect.sh`, `hooks/lib/worktree-resolve.sh`, `/g-review` stamp-format + diff-target flip (tasks 1, 2, 9+10). Reviewed MERGE READY by code-lead (0 critical, 0 major, 4 minor carry-forwards to W1.5). Depends on: —
  - **W1.2 — Commit gate + native pre-commit hook ✅ Complete (`1621a70` + fix commit):** `check-commit.sh` swapped onto shared libs (+ new `hooks/lib/classify-changeset.sh` so the classifier exists once), new native `hooks/pre-commit` (write-tree/HEAD/worktree stamp verify, first-commit fail-toward-deny, sentinel consume), g-doc-review Step 1 diff-target flip (ledger 8d residual). Reviewed MERGE READY by code-lead round 2 after one Major fix (worktree stamp field truncated at first space — spaced Windows paths permanently denied); 2 minors carried to W1.5/W2. Sandbox-proven per Tier 3 DoD (19/19 + 6/6 fixture assertions); live verification stays in W1.7. Depends on: W1.1
  - **W1.3 — Remaining hook worktree integrations ✅ Reviewed MERGE READY (2026-07-16, pending commit):** `post-commit-cleanup.sh`, `observe.sh`, `pre-compact.sh`, `session-start.sh`, `workflow-checkpoint.sh`, `agent-lifecycle.sh` (tasks 11+12, 13+14, 15, 16, 17, 18) — all six resolve primary state from a linked worktree, non-gating per ADR-005, primary paths byte-identical, single-classifier grep 0 across `hooks/`. Reviewed MERGE READY by code-lead (0 critical, 0 major, 4 minor → W1.4/W1.5/W1.6: post-commit-cleanup sed command-field-extraction parity gap, observe.sh sed escaped-quote awareness, W4 guard-idiom variance, W5 duplicate stamp reader). Sandbox-proven per Tier 3 DoD; live verification stays in W1.7. Depends on: W1.1. ⚠ oversized estimate handled without further split
  - **W1.4 — Install wiring + drift detection ✅ Complete (`1fdf016`):** `/g-init`/`/g-update` install/realign the 11-file set (7 hooks + 3 libs into `.claude/hooks/`, native `pre-commit` into the git hooks path via `--git-path hooks` with a `G-Forge commit gate`-marker clobber guard — foreign hooks preserved); `/g-doctor` Check 16 extended to libs + pre-commit (missing/stale/foreign distinguished, no renumbering); post-commit-cleanup sed-tier parity fix pinned by fail-before/pass-after test (tasks 20+21, 22, 19 + W1.3 minor). Reviewed MERGE READY (0c/0M/2m: g-init warning text hardcodes `.git/hooks` path — W1.5; cheat-sheet pre-commit line optional); doc gate DOCS HOLD→READY twice caught count drift (forecast scenario 2 hit: README ×3 + g-update lib-sourcing rows). Suite 61/61. Depends on: W1.2
  - **W1.5 — Foundation + gate tests — SPLIT 2026-07-17 into W1.5a–f** (decomposed to 25 tasks / ~84 est. exchanges, far over one session's budget; approved split below — each slice is its own `/g-plan` run, sized ≤26 est. exchanges; the fail-before → fix → attest sandwich stays intact inside each slice; every test-writer suite is followed by a `g-forge-dev` attestation task per finding #20; standing rule: minors found during W1.5x reviews route to W1.6/W2, never back into a W1.5 slice):
    - **W1.5a — commit-detect suite + hardening** (~24): `tests/test-commit-detect.sh` incl. failing global-flag + failing `env -S` cases and the xargs-malformed-quote pin; fix the global-flag walk (`--no-pager`, `-p`, `--git-dir`, `--work-tree`, `--namespace`) + env-S re-tokenization (clarify-resolution: behavior fix, not comment-only — developer-approved 2026-07-17); attested run. Closes W1.1 minors 2–4. Depends on: —
    - **W1.5b — worktree-resolve + classify-changeset suites** (~23): `tests/test-worktree-resolve.sh` (both public functions, relative/absolute `--git-common-dir`, reject paths) + `tests/test-classify-changeset.sh` (every bucket rule, sourced not re-implemented, single-classifier invariant grep); attested runs. Depends on: —
    - **W1.5c — pre-commit gate fixtures ✅ Complete (2026-07-18):** `g-dev/fixtures/pre-commit-gate-verify.sh` extended 19→35 assertions (doc-only-class pass/deny/consume ×3, conflicted-index write-tree-failure deny with standalone write-tree canary, ambiguous-worktree-resolution deny with resolver-reject canary on the separate-git-dir construction); attested green via g-forge-dev (35/35 fixture + 171/171 suite). Reviewed MERGE READY (0c/0M/0m — zero findings). No hook bugs surfaced. Depends on: —
    - **W1.5d — sentinel-read extraction + install propagation ✅ Complete (2026-07-18):** fail-before/pass-after sandwich closed clean (suite 0/16 exit 1 attested pre-extraction → 16/16 after; full suite 187/187 across 10 files; fixture 35/35 through the real hook). `gf_parse_stamp` moved byte-identical into new `hooks/lib/sentinel-read.sh`, both call sites converted, single-reader invariant now grep-pinned; validator unchanged. 4 install surfaces propagated 11→12 (attested consistent, zero stale/over-bump). Reviewed MERGE READY (0c/0M/2m → W1.6/W2: case-(b) advisory-delta note; wave-agent doc-writer overreach — retro-edited the shipped W1.4 CHANGELOG entry, caught+reverted by HQ, history intact). Depends on: —
    - **W1.5e — skill-layer edits** (~21): g-review Step 6 stamp-source ↔ Step 2 union reconciliation (W1.1 minor 1 + W1.2 literal-HEAD wording, one coherence task) + **generalize `/g-review` Step 1** — project-local test-runner agent convention `.claude/agents/<name>-dev.md`, delegate suite run, attested output, inline fallback (developer-directed 2026-07-15; dogfooded by the never-shipped `g-forge-dev` + `g-dev/` harness; done condition includes convention-text-is-generic check); g-init Step 6a `<git-hooks-dir>` warning fix; post-commit-cleanup.sh:3 dual-sentinel header fix; [optional → W2 #18] architecture-rule native-git-hook class note. Depends on: —
    - **W1.5f — guard-idiom normalization + terminal attestation** (~18): normalize the worktree-guard idiom across the six W1.3 hooks to one canonical structure; then the full-suite `g-forge-dev` regression sweep (≥61 + all new assertions, 0 FAIL). Depends on: W1.5d, W1.5e (edits the same files)
  - **W1.6 — Remaining hook tests + drift test:** tests for W1.3 + W1.4 (tasks 27, 28, 29, 30, 31, 32, 33). Depends on: W1.3, W1.4. ⚠ oversized estimate — expect `/g-plan` to split further
  - **W1.7 — Suite run + live verification + ledger close:** full suite green, real gated commit through primary tree, real gated commit through a linked worktree, M-audit ledger sign-off (tasks 34, 35, 36, 37; HQ-executed, not delegated). Depends on: W1.5a–f, W1.6
- W2 (P1): SKILL.md conformance (argument-hint ×9, Announce ×3, Rules ×3, Steps ×2); architecture-enforcer verdict alignment; /g-forge router roundtable row; agent-class taxonomy + `context:` carve-out in the claude-plugin architecture rules
- W3 (P2, deferrable): 10 minors

**Depends on:** —

---

### M29 — Multi-session coordination (claim/lease for concurrent sessions)
**Status:** ⬜ Not started (scoped, awaiting go)
**Version:** v2.6.0 (minor — the register is a new capability; renumbered back into the 2.x line 2026-07-18 — rebrand moved to the M44 capstone)
**Goal:** Stop concurrent sessions from silently colliding on milestone numbers, branches, and the handoff — by coordinating through a shared, MCP-reached surface, with three pluggable backends behind one adapter, degrading cleanly to today's git handoff when none is configured.
**Scope (phased):**
- [ ] **Phase A — core + first adapter:** surface-agnostic claim protocol + register schema (resource = milestone/branch/wave; claim = holder/session/ts/lease/status), session identity + signed writes + lease/heartbeat + stale-claim reclaim, a capability-flagged adapter interface (`push|poll`, `cas|convention`, identity), and the **Google (Gmail/Drive)** reference adapter — official MCP, the flow+floor — to answer "is convention enough?" (ships as a standalone gating spike; rest of the arc proceeds on its verdict)
- [ ] **Phase B — workflow integration:** collision check in `/g-roadmap` + `/g-plan` (fetch + warn + offer alternatives before assigning), hook surfacing of others' active claims + heartbeat in `workflow-checkpoint.sh`/`session-start.sh`, release on milestone close. Honors tiers (off on `light`).
- [ ] **Phase C — setup, health, more adapters:** **Confluence** adapter (version-CAS = real lock) + optional **Discord** adapter (real-time, **community/unofficial MCP — flagged**), `/g-init` opt-in setup wiring a **remote MCP into `.mcp.json`** (tokens via env-var, never committed) + `/g-doctor` reachability check, graceful degradation + docs.

**Position:** phase one of **multiplayer G-Forge** — full multi-user cooperation on one project ("human orchestration, powered by humans"), a framework that engages whenever >1 session/user is live and degrades to single-player when alone. M29 is the claim/lease substrate; **assignment-by-person, cross-person handoff, cross-person review, and reconciliation** are later phases of the arc (not cut). Permanent line: humans orchestrate — no autonomous AI-dispatches-AI, no hosted authority.

**Cross-surface requirement:** each adapter's MCP must be **remote HTTP/SSE in `.mcp.json`** so cloud / Slack / GitHub-Actions sessions can reach it (local stdio servers are invisible to those surfaces). Same property that makes G-Forge enforcement travel — committed config follows you everywhere.

**Premortem + done condition:** full breakdown in `g-docs/milestones/M29-multi-session-coordination.md` (top risks: credential leakage · convention races on Gmail/Discord · local-vs-remote MCP divergence · stale claims · scope creep). Promoted from the backlog candidate below; this is the milestone version of it.

**Re-prioritization:** promoted to the **next buildable milestone** (v2.3.0 at the time of that decision; now v2.6.0 after the M42 + M41 insertions — the 2026-07-18 restructure moved the G-Proof rebrand to the M44 capstone, so the line stays 2.x), ahead of the deferred M26 — M26 is spike-gated with nothing depending on it, while M29 is buildable now and strategically central (governance scaled to teams, per M24). Its Phase A doubles as the **de-risking spike for the whole arc** — it answers "is convention enough?" before M30–M32 commit. (M25 stays a parallel compute-gated track.)

---

### M30 — Membership, presence & assignment  *(multiplayer arc — sketch)*
**Status:** ⬜ Sketch (provisional — firms up after M29 ships)
**Goal:** Know who's on the project, and let work be owned by *people*. The layer where the multiplayer framework's identity and activation live.
**Scope (sketch):**
- Membership roster + stable per-member identities (built on M29's session identity).
- Live **presence** / heartbeat → "who's active, and on what."
- **Assignment:** an owner on milestones / waves / tasks; `/g-roadmap` + `/g-plan` can assign to a person.
- **Activation rules:** the framework engages when >1 identity is present, is tier-gated, and degrades back to single-player when alone.

**Premortem (sketch-level):**
- *Session-identity vs person-identity conflated* (med) — a person across machines/sessions must map to **one** identity or presence + assignment fragment. → Make person-identity primary in M30; session-ids map onto it (carried deliberately from M29).
- *Presence flap* (med) — noisy/stale heartbeats toggle the framework on/off. → TTL + debounce on presence; activation **hysteresis** (don't switch on a single missed beat).
- *Toothless or rigid assignment* (med) — "owned by X" is either a meaningless label or a hard block. → Assignment = advisory claim with logged override (reuse M29 claim semantics), not a lock.

**Depends on:** M29 (identity, register, heartbeat).

---

### M31 — Cross-person handoff & review  *(multiplayer arc — sketch)*
**Status:** ⬜ Sketch (provisional)
**Goal:** Make handoff and review cross *people*, not just sessions.
**Scope (sketch):**
- **Person→person handoff:** the `## Active Session` block generalizes from session→session to person→person; `/g-resume` can re-hydrate from a teammate's handoff.
- **Cross-person review gate:** `/g-review` / `/g-doc-review` can require approval from a *different* member; the approval sentinel is keyed to approver identity.
- **Notifications** via the chosen surface ("@you — review requested on wave-3").

**Premortem (sketch-level):**
- *Cross-person review deadlock* (high) — A needs B's approval, B is offline → work stalls. → Timeout + logged self-approve fallback (tier-gated); async notify; cross-approval never unconditionally mandatory.
- *Handoff race reintroduces the M29 collision* (med) — concurrent person→person edits to the one `## Active Session` block. → Per-member handoff lanes, or treat the handoff itself as an M29-claimed resource.
- *Untrustworthy identity-keyed sentinels* (low–med) — approver identity in the gate sentinel must be forgeable-proof. → Signed approvals tied to M30 identity.

**Depends on:** M30 (identity/assignment), M29 (register/log).

---

### M32 — Reconciliation of concurrent work  *(multiplayer arc — sketch)*
**Status:** ⬜ Sketch (provisional — hardest phase; spike-gate before building)
**Goal:** When people work concurrently, reconcile branches / waves with conflicts **surfaced**, never auto-merged behind anyone's back.
**Scope (sketch):**
- Detect overlapping file-sets / waves across members (uses M29's claim granularity).
- Conflict surfacing + **guided** reconciliation — who integrates, in what order.
- A team convention for "who owns `main`" and ordered integration.

**Premortem (sketch-level):**
- *Scope blow-up into a full merge/consensus engine* (high) — "who owns `main`" distributed coordination is the hard part and easy to overbuild past the governance lane. → Spike-gate; ship "surface conflicts + recommend an integration order," **never auto-merge**; auto-resolution is an explicit non-goal.
- *Fuzzy done condition* (high) — "reconcile concurrent work" is vague. → Done = overlapping file-sets/waves across members are **detected and surfaced with a recommended order**, not auto-resolved.
- *Weak overlap detection from coarse claims* (med) — if M29/M30 file-set claims aren't granular, conflict detection is blind. → Validate claim granularity upstream before M32; spike.

**Depends on:** M30, M31. This is the genuinely distributed part — feasibility-spike it before committing.

**Re-prioritization (arc):** M30→M31→M32 kept in strict dependency order; **M32 stays last and spike-gated** (highest likelihood + fuzziest done condition). The whole arc is provisional behind M29 — building M29 Phase A first is the deliberate de-risking move. **M26** (Provable Wave Dispatch) is pushed behind the arc's first release onto its own spike-gated track (nothing depends on it); **M25** unchanged (compute-gated, parallel).

> *The M30–M32 split is a **provisional sketch** of the multiplayer arc, not a commitment — the exact boundaries, sequence, and contents are expected to change once M29 is built and we learn whether convention-based coordination is sufficient. North star + framework in `g-docs/multi-session-coordination.md`.*

---

### M33 — The Roundtable (shared-doc communication layer)  *(multiplayer arc — scoped)*
**Status:** ⬜ Not started (scoped, awaiting go) — full spec in `g-docs/milestones/M33-the-roundtable.md`
**Version:** v2.9.0 (minor — Phase A shipped un-versioned; ships when Phase B lands. Follows M37 per the version plan; shared digests build on the memory substrate. Renumbered back into the 2.x line 2026-07-18 — rebrand moved to the M44 capstone.)
**Goal:** Give G-Forge a real-time, human-facing **communication surface** — a shared Google Doc ("the Roundtable") that is the live UI between developers, *non-programmers* (PMs, friends vibecoding a game), and their Claude sessions. State of play is visible; humans steer in plain language; live decisions/plans **distill to the durable record + action points** on a human nod. Triggerable; works **solo** or **shared**. This is the **harmonious cooperation layer** — the interface the M30–M32 mechanics render on.
**Scope (phased):** A — Solo Roundtable (`/g-roundtable start|sync|close`, templates, session rules, end-of-session distill; proves the make-or-break distill loop with one person, no M29 needed). B — Shared Roundtable (link-restricted join, lanes/presence via M29, cross-person catch-up + handoff). C — Maintenance/grooming, `/g-init` opt-in + `/g-doctor` health, templates, clean degradation. **D — Propagation** (every skill/hook/rule that assigns, plans, executes, reviews, resumes, or reports becomes lane/Roundtable-aware — per the §B cross-cutting propagation rule; gated by the architecture-review completeness check).

**Premortem (top risks — full set in the spec):**
- *Distillation quality is the whole game* (high) — lossy ⇒ intent drifts, noisy ⇒ the Doc swamps. → human nod gates every distill; salience filter on writes; the C grooming step; keep living-state small.
- *🔴 "Public" doc = data leak* (high) — a public Google Doc is world-readable. → default **link-restricted, never public**; no credentials on the Roundtable; `/g-doctor` flags world-readable.
- *Propagation forgotten — the island risk* (med) — the Roundtable works alone but `/g-roadmap`/`/g-plan`/hooks ignore it. → Phase D + the §B propagation rule + the gate completeness check. **A Roundtable the engine doesn't respect is not done.**

**Depends on:** M29 (register) for shared-mode lanes/presence; Phase A is standalone. **Relation to the arc:** M33 is the *interface* the provisional M30–M32 sketch (membership · handoff · reconciliation) renders on — when M29 ships and the sketch firms up, expect M30–M32 to reconcile against (and partly fold into) the Roundtable.

---

### M34 — Cross-session dependency tracking & pull/push orchestration  *(multiplayer arc — scoped)*
**Status:** ⬜ Not started (scoped, awaiting go) — full spec in `g-docs/milestones/M34-cross-session-orchestration.md`
**Goal:** Make G-Forge's single-session orchestration work across **many sessions/users** — surface a live **who-depends-on-whom** graph and turn it into **git coordination suggestions** (pull / push / coordinate), all **advised, never automated**. The "super important" part: the orchestration *is* the product; the Roundtable is where it becomes visible.
**Scope (phased):** A — Dependency declaration & graph (extend the M29 claim with `depends-on`; `/g-status` renders blocked-by/blocking — the spike). B — Pull/push suggestion engine (graph + git ahead/behind → advisories at boundaries, salience-gated). C — Roadmap-update propagation (a roadmap change surfaces to everyone's Roundtable; shared re-prioritization). D — Overlap + cycle detection (coordinate warnings; never auto-resolve).

**Premortem (top risks — full set in the spec):**
- *Suggestion spam* (high) — advisories every boundary become noise. → salience gate: suggest only on a state change; tier-gated; dedupe.
- *Overreach into auto-merge* (med) — the tempting next step is "just pull for them." → hard non-goal; suggest-only, the human runs every git command (inherits M32).
- *Coarse claims blind overlap detection* (med, carried from M32) → validate M29 claim granularity upstream before Phase D; spike.

**Depends on:** **M29** (claims = the substrate) + **M33** (Roundtable = the surface). **Relation to the arc:** dependency tracking is the **spine** the provisional M30–M32 mechanics (assignment · handoff · reconciliation) hang off — they are consequences of the graph M34 builds and likely **fold under** it. Degrades to single-session (no deps) when neither substrate is configured.

**Re-prioritization (arc):** M34 slots **immediately after M29**, ahead of and largely absorbing the provisional **M30–M32** sketch — assignment/handoff/reconciliation presuppose the dependency graph, so the graph is built first. Sequence within the arc: **M29 (register) → M33 Phase A (Roundtable, standalone, already built) → M34 Phase A (dependency graph spike) → M34 B–D + M33 B–D + the M30–M32 mechanics reconciled against M34**. M34 is spike-gated on its Phase A (prove the graph is legible with two sessions before the suggestion engine). M26/M25 unchanged (spike-/compute-gated parallel tracks).

---

### M35 — Memory Forge (deep memory layer + optional Obsidian surface)
**Status:** ⬜ Not started — full spec in `g-docs/milestones/M35-memory-forge.md`
**Version:** v2.7.0 (minor — new capability; renumbered back into the 2.x line 2026-07-18 — rebrand moved to the M44 capstone)
**Goal:** The distilled record becomes a linked, layered, queryable memory that `/g-resume` hydrates task-specifically — wikilink + frontmatter conventions (`g-docs/` *is* the vault), a real `context:`-layer loader (implement or retire the paper contract), graph-walk hydration, memory hit-rate telemetry, and a strictly opt-in `.obsidian/` scaffold ("viewer, never dependency" — ADR at Phase C).
**Sequence:** after M29, before M33 B–D — shared-state milestones (M33-B digests, M34 dependency records) build *on* this substrate rather than inventing their own record shapes.
**Depends on:** M29 (shared-layer design only), M-audit-2026-07

---

### M36 — Salience Layer: Approach (priority / severity / impact / relevance)
**Status:** ⬜ Not started
**Version:** design/decision (ADR outcome — no standalone bump; the M37 build carries the minor)
**Goal:** Decide the approach for a **system-wide salience model** — how G-Forge scores **priority / severity / impact / relevance** — so every planning and governance skill reasons about "how much does this matter" instead of hand-waving it. This is the *whole layer* (roadmaps, plans, review, forecast, patterns, the arc's salience gates, G-tweak's de-gate safety), not an ADR- or G-tweak-scoped feature.
**Scope:**
- ADR (via `/g-adr`) defining the model: the four dimensions, how each is derived, and a **deterministic, documented rubric** — the model *proposes*, the human overrides, it **never auto-acts** on a score.
- First-consumer contract anchored to concrete consumers (`/g-roadmap` prioritization, `/g-plan`, the M33-B/M34 salience gates) — not designed in a vacuum.
- Positioning vs existing scoring (`/g-forecast` risk %, `/g-telemetry` reliability, `/g-review` adaptive intensity, `/g-patterns` frequency buckets): define how salience absorbs, defers to, or complements each so M37 integrates rather than duplicates.

**Depends on:** M-audit-2026-07 (enforcement integrity must be sound before layering a cross-cutting substrate). Independent of M29 — design-only, can run in parallel. Gates M37.

**Premortem:**
- *Analysis paralysis on a "grand unified" model* (med) → timebox to an approach decision + first-consumer contract; the model can evolve.
- *Deciding in a vacuum* (med) → anchor to the named consumers, not abstraction.

---

### M37 — Salience Layer: Propagation
**Status:** ⬜ Not started
**Version:** v2.8.0 (minor — the salience substrate + its cross-system wiring; renumbered back into the 2.x line 2026-07-18 — rebrand moved to the M44 capstone)
**Goal:** Implement the M36 salience model and **weave it across the system** so priority/severity/impact/relevance is one shared layer, not per-skill guesswork.
**Scope (phased — do not require all consumers in one milestone):**
- Model implementation + highest-value consumers first: `/g-roadmap` (milestone prioritization), `/g-plan` (task/wave priority), and the arc's salience gates (M33-B digests, M34 suggestion salience).
- Then propagate to the rest: `/g-forecast`, `/g-review`, `/g-patterns`, `/g-adr`.
- **Cross-cutting propagation (G-RULES §B):** run `/g-blast-radius` to enumerate every skill/hook/rule that must become salience-aware; fold each touchpoint into scope; **done condition is incomplete until the architecture-review completeness gate confirms none was missed.**
- Rubric is deterministic and documented; salience **proposes**, the human overrides — never auto-acts.

**Depends on:** M36 (the approach decision). Inserted **before M33-B** so the arc consumes one real model instead of hand-rolling gates.

**Premortem:**
- *Boiling the ocean* (high) → phase it (model + 2–3 consumers first); propagate the rest after.
- *Forgotten-consumer / island risk* (high) → the §B blast-radius + architecture-review completeness gate is the mitigation, not optional.
- *Collision with existing scoring* (med) → M36's ADR defines the boundaries; M37 integrates, not duplicates.
- *Subjective-score drift* (med) → documented rubric; propose-not-act.

---

### M38 — G-Report (outbound incident/feedback reporter)
**Status:** ⬜ Not started
**Version:** v2.10.0 (minor — new skill; renumbered back into the 2.x line 2026-07-18 — rebrand moved to the M44 capstone)
**Goal:** Prepare **scrubbed, project-agnostic `.md` incident/feedback reports** destined for the G-Forge author — the outbound surface G-tweak calls, also invocable standalone.
**Scope:**
- Report template(s); project-agnostic scrub mode for sensitive data.
- **Local-`.md`-first floor:** the guaranteed job is to *prepare* the report; the human sends it. **No automation on any user data.**
- Opt-in, consent-gated send (Gmail draft-and-nod / GitHub issue on `hllrm/G-Forge`) reusing existing MCP surfaces + ADR-001 draft-and-nod discipline; degrade gracefully (prepared `.md`, you send it) when no MCP is configured.
- `/g-doctor` leak check — no secrets/tokens/absolute paths in the report.
- Boundary vs the inward reporters (`/g-retro`, `/g-telemetry`, `/g-patterns`): G-Report is strictly **outbound-to-author, incident/feedback only.**

**Depends on:** — (leaf).

**Premortem:**
- *Privacy / exfiltration* (high) → local-first floor + consent-gated send + scrub default + `/g-doctor` check.
- *Transport MCP absent on a surface* (med) → degrade to "prepared `.md`, you send it"; never block.

---

### M39 — G-tweak (periodic self-feedback + safe self-tune)
**Status:** ⬜ Not started
**Version:** v2.11.0 (minor — new skill; Phase A ships it, B/C fold in as they land; renumbered back into the 2.x line 2026-07-18 — rebrand moved to the M44 capstone)
**Goal:** Every N milestones, **offer (never enforce)** an interview on how G-Forge is serving the user — what's working (to *protect*) and what's friction (gating / overplanning / bottlenecks / poor performance) — then optionally self-tune and/or report out.
**Scope (phased):**
- **Phase A — Interview core:** offered every N (3–5, configurable) milestones; asks **both poles**; on decline it self-schedules (resurface in X milestones) or deactivates; **deactivation is flagged by `/g-doctor`** — allowed, never silent. Depends on nothing.
- **Phase B — Report-out:** action-(b) **calls G-Report** (M38).
- **Phase C — Safe self-tune:** action-(a) proposes local tweaks, **structurally barred from the commit gate / enforcement sentinels**; uses the M37 salience layer to distinguish needless bureaucracy from load-bearing enforcement; every tweak approve-before-write. Includes the **M43 inspection-cadence reassess hook** (added 2026-07-15): read the operator's cadence setting + observed hold behavior and propose adjustments (always-waved-through ⇒ suggest `off`; friction reports ⇒ suggest `every-wave`), approve-before-write like every tweak.
- **No automation on any user data**, ever.

**Depends on:** M38 (Phase B), M37 (Phase C). Phase A is standalone.

**Premortem:**
- *De-gating drift erodes the differentiator* (high) → action-(a) barred from enforcement; gated on M37; approve-before-write.
- *Reintroduces the interview M19 removed* (med) → offered-not-enforced + self-schedule/deactivate; framed as meta-feedback, distinct from session retro.
- *Silent deactivation* (low, mitigated) → `/g-doctor` flags it.

---

### M40 — Reference Convention (recognize-and-vet external material)
**Status:** ⬜ Not started
**Version:** v2.12.0 (minor — new recognized folder class + classifier arm + doctor advisory + intake questions + optional ADR field; renumbered back into the 2.x line 2026-07-18 — rebrand moved to the M44 capstone)
**Goal:** Name the one committed-content class the taxonomy can't see — human-curated external material a project builds *against* but never *from* (pinned corpora, design handoffs, spec copies) — stop the commit gate mis-gating it, and let `/g-doctor` vet its provenance discipline. **Recognize-and-vet, never own-and-generate.**

**Origin:** the `reference/` convention already runs in the wild in `keyline` (root `reference/`, `SNAPSHOT.md`/`NOTE.md` provenance notes) and was independently reinvented — divergently — in `omnibook` (same corpus, squatting inside `g-docs/`). Two projects, two placements → no rule exists. Full evidence + options in the reference-folder report (advisory, Francesco / CryusFrey, 2026-07-11).

**Scope (waved):**
- **Wave 1 — Gate safety** (the load-bearing fix; independently shippable):
  - `hooks/check-commit.sh`: new **REFERENCE** classifier class (not DOC — a frozen snapshot has no code-it-describes), **exempt-with-advisory** and **marker-gated** — a `reference/*` path is exempt only if its top-level bundle carries a `SNAPSHOT.md`/`NOTE.md`; unmarked paths fall through to CODE, real code under `reference/` still gates.
  - `rules/g-rules/I-project-tracking.md`: one taxonomy row — root `reference/` = **external + human-ported + frozen** (all three or it doesn't go in), git-tracked, **never machine-written**.
  - `skills/g-init/SKILL.md` Step 5a + `.gitignore`: "never ignore `reference/`".
  - Tests: marked reference-only commit passes without a code sentinel; unmarked `reference/` path still gates; code-extension file under `reference/` still gates.
- **Wave 2 — Visibility & non-contamination:**
  - `skills/g-doctor/SKILL.md` advisory: every top-level bundle carries a note; flag code-extension files under `reference/`; **flag reference-like bundles squatting inside `g-docs/`** (turns omnibook's state into a detectable finding).
  - Scope guard: one "skip `reference/` unless explicitly pointed at it" line in `/g-audit`, `/g-optimize`, `/g-refactor`, and Explore-style deep reads (stops scanners reporting SOLID violations in frozen material — the machine-write corruption vector).
  - Intake: one question in `g-onboard` + `g-kickoff` — *"Any specs, design handoffs, or reference corpora this project builds against?"*
- **Wave 3 — Provenance link:**
  - `skills/g-adr/SKILL.md`: optional `Derives from:` field (path to a `reference/` artifact + snapshot edition) + one back-link confirmation step — closes the ADR↔snapshot loop that already broke once in keyline.
  - `SNAPSHOT.md`/`NOTE.md` template blurb: a **License / permission-to-commit** line (Chromium `README.chromium` precedent) + the **external+human-ported+frozen** inclusion test.

**Explicitly out of scope:** scaffolding an empty `reference/` into every project, a `/g-reference` skill, delta-check machinery, and any default read or write of `reference/` by any skill or agent (YAGNI — keyline ran the whole pattern with zero plugin support).

**Depends on:** M-audit-2026-07 (v2.3.0) — shares `check-commit.sh` + `g-doctor`; land after the enforcement-integrity fixes, not concurrent. Otherwise independent of the memory/salience/multiplayer arc.

**Sequencing note:** slotted at the tail (now v2.12.0 — renumbered back into the 2.x line by the 2026-07-18 restructure; the rebrand lives in the M44 capstone) originally to avoid renumbering the planned M29→M39 lane (a rationale since overtaken, position unchanged). **Wave 1 is a pull-forward candidate** — the reference-only mis-gate is a live enforcement fail-open, thematically M-audit's own territory, and could ship as a `v2.3.x` patch ahead of the arc if the developer wants the gate honest sooner.

**Premortem:**
- *Gate softening leaks* (med) → REFERENCE exemption becomes a code-smuggling path. Mitigation in scope: marker-gated exemption (unmarked → CODE) + doctor flags code-extension files under `reference/`.
- *Taxonomy scope creep* (med — the named failure mode) → one class implies a doctor check implies g-update handling implies docs. Mitigation: hard-scope to the three waves; Phase-4 primitive stays backlog; no scaffold/skill; re-confirm at each wave close that nothing crept.
- *Name collision on onboarded repos* (low) → `reference/` is a common dir with unrelated semantics. Mitigation: doctor check is **opt-in by marker** (bundle note present, or CLAUDE.md declares the convention); g-onboard asks, never assumes.

**Cross-cutting propagation (G-RULES §B):** the REFERENCE classifier class is a shared primitive the gate, doctor, intake, and scanning skills must all respect — that is why Wave 2's scope-guard line and doctor check are folded *into* this milestone, not left as follow-ups. Run `/g-blast-radius` at Wave 1 close to confirm no reader (skill, hook, or rule) was missed.

---

### M41 — Release Machinery + README Currency (gated release pipeline)
**Status:** ⬜ Not started
**Version:** v2.4.0 (minor — new release commands + skills + a `/g-doctor` version-consistency check. **RESTRUCTURED 2026-07-18 (developer):** the G-Proof rebrand + full README restyle were split OUT of this milestone into **M44 — the G-Proof 1.0 capstone, sequenced dead last** — the roadmap runs its whole natural life as G-Forge 2.x, then restarts clean as G-Proof 1.0. What stays here is the release machinery and the standing README/CHANGELOG *currency* convention, which starts even earlier — at the v2.3.0 release (see M-audit's release pass). `g-docs/milestones/M41.md` is the source of truth for `/g-plan`.)
**Goal:** Make cutting a release a **single gated step** instead of a manual, multi-file, error-prone ritual — and make README/CHANGELOG currency a structural property of every release, not a memory-dependent chore. Distribution is straight off `main` (no tags, no CI) — the version field in `plugin.json` **is** the "latest available" signal that `/g-update` and the daily `workflow-checkpoint.sh` check advertise to every installed project — so a wrong or premature bump ships immediately. `/g-release` owns that bump with preconditions and consistency.

**Origin:** observed pain, not hypothetical. Six releases in ~2 weeks (2.0.0→2.2.1), each hand-editing the version in **three places** (`plugin.json`, `marketplace.json`, README counts) + cutting CHANGELOG `[Unreleased]`→dated + (always skipped) tagging. On 2026-07-12 a v2.2.2 bump was made mid-milestone and had to be reverted precisely because nothing gated "is this a coherent, complete release?" — the exact failure `/g-release` prevents. On 2026-07-18 the developer flagged the GitHub README as visibly stale — the currency convention is the structural answer.

**Scope (waved — full task breakdown + done conditions in `g-docs/milestones/M41.md`):**
- **Wave 1 — Release tooling (`/g-changelog` + `/g-release`):** `/g-changelog` **drafts** `[Unreleased]` from the **curated durable record** (milestone-ledger rows, review verdicts, plan done-conditions) — **never raw `git log`** (ledger rows are already human-curated signal; commits are not); Keep-a-Changelog buckets inferred from row type; **draft + human nod** before any write. `/g-release` gates the cut: preconditions (active milestone ✅ closed, full suite green on a **real run** with pasted evidence per finding #20, gate self-hosted clean, no orphaned `[Unreleased]`; refuse on a partial milestone), one-shot version bump across **every** manifest, `[Unreleased]` → dated `## [x.y.z]`, annotated `v{x.y.z}` tag (closes the tagging gap the alveria adopter works around with pinned SHAs). Adds a `/g-doctor` **version-consistency check** (manifests agree; README counts match the `agents/`+`skills/`+`profiles/` inventory) as the standing backstop against a hand bump.
- **Wave 2 — README currency machinery:** `/g-release` verifies the README **status strip** (version badge · "What's new" → CHANGELOG.md · "Where this is going" → ROADMAP — first shipped at v2.3.0 by M-audit's release pass) is current as a release precondition; the lighter `/g-review` Step-6 close-out README-currency mechanism (optional, behavior-change-gated) becomes the reusable per-milestone pass. **The full persuasion-ordered README restyle (gate GIF, positioning narrative, before/after table, FAQ) is NOT here — it ships with M44/G-Proof 1.0.**

**Explicitly out of scope:** the G-Proof rename and everything branded (→ M44); publishing pipelines/CI, signing, changelog generation **from raw commits** (`git log` is never a source), auto-deciding the semver bump (the developer states major/minor/patch; `/g-release` enforces consistency, not the decision), auto-applied README rewrites (always drafted + nodded).

**Depends on:** — (independent; composes with `/g-roadmap`'s milestone close and finding #20's "green run with evidence"). Sequenced immediately after M-audit-2026-07 closes, before M42 — release machinery is most valuable *before* the long release train M42→M43, not after.

**Premortem:**
- *Becomes a rubber stamp* (med) → if the preconditions are advisory not blocking, it just automates a bad bump. Mitigation: milestone-closed + green-run are hard gates; refuse, don't warn.
- *Version drift across files reappears* (low) → the `/g-doctor` consistency check is the standing backstop even when someone bumps by hand.
- *Tag/manifest divergence* (low) → tag is cut from the same run that writes the manifest; never a separate step.
- *Currency convention decays without enforcement* (med) → that's why the strip check is a `/g-release` precondition, not a habit; the doc gate already covers CHANGELOG on every mixed/doc commit.

**Cross-cutting propagation (G-RULES §B):** the version number is a shared primitive read by `/g-update`, `workflow-checkpoint.sh` (daily update nudge), `/g-doctor`, and the manifests — `/g-release` must be the single writer, and the `/g-doctor` check the single verifier. Run `/g-blast-radius` at Wave 1 close.

---

### M42 — Planning Cold-Start Integrity
**Status:** ⬜ Not started
**Version:** v2.5.0 (minor — new planning capability + gate; renumbered back into the 2.x line 2026-07-18 — the G-Proof rebrand moved to the M44 capstone, so no mid-arc 3.0.0)
**Goal:** No planning gate can green-light a product unusable from an empty state — the human cold-start becomes a represented, probed dimension of kickoff, roadmap, and review.

**Origin:** field report from **G-Cash** (first from-scratch G-Forge consumer), 2026-07-13. A top-tier `/g-roadmap` pass shipped M1–M5 all-green (MERGE READY); the first human smoke test found **no way for a user to create their household, accounts, pots, salaries, or savings goals** — the only creator of standing-config entities was `fixture_seed.sql`. Root-cause chain: ingestion-first brief → `/g-kickoff` never forced the cold-start question → `/g-roadmap` absorbed the gap via fixture-satisfied done-conditions → no gate represents the empty state (`/g-align` is brief-relative; the gap was *in* the brief). Systemic theme: **AI planning optimizes to its own done-conditions; no gate represents the human's first five minutes.** The Tier-3 human gate held — nothing shipped. Source brief: G-Cash scratchpad `gforge-patch-brief.md`.

**Scope (waved):**
- **Wave 1 — front line (P0):**
  - **Cold-start grill in `/g-kickoff`** — a relentless one-question-at-a-time interview against the draft brief: depth-first over the plan's dependency tree, every question carries a recommended answer + rationale, concludes at shared understanding. **Seeded with the fixed cold-start probe set** (fires regardless of what the brief mentions): (1) *cold start / empty state* — brand-new user, empty DB, day one: what do they see and do; (2) *entity-creation path* — for every domain entity: manual / imported / derived, and where is the surface; (3) *first-run reachability* — every planned feature reachable from zero data; (4) *fixture-leaning done conditions* — any milestone "done" standing in for a real user path. Mechanism prior art: the external "grill-me" skill — **implemented natively, no third-party dependency**.
  - **Fixture-as-crutch detector in `/g-roadmap`** — any milestone done-condition satisfiable only by seed/fixture data is surfaced as an open question at the buy-in gate, never absorbed into "done".
  - Probe set **single-sourced** (one shared rules/reference location); kickoff + roadmap reference it, never copy it.
- **Wave 2 (P1): reachability gate** — brief-independent check: *from an empty DB, can a real user reach every shipped feature?* Home undecided (new standalone gate vs `/g-align` extension vs a review-pipeline axis) — decide first (mini-ADR if contested), then implement. Output = per-entity creation matrix (entity → create surface? → evidence) + advisory verdict **with evidence** — never a bare green stamp.
- **Wave 3 (P1/P2):** `/g-patterns` seed rule — "planning omits the human first-run path"; `/g-align` blind-spot doc — brief-relative checks cannot catch requirements missing from the brief itself (why the reachability gate is not redundant). *(The brief's secondary signal — test-writer false DONE ≥4× — was appended to M-audit finding #20 at triage, not scoped here.)*

**Depends on:** M-audit-2026-07 (sequencing only — prose-only skill edits, touches no hooks or enforcement code).

**Sequencing note:** ID tailed at M42, but **sequenced early — after M41 (which the 2026-07-15 pull-forward slotted directly behind M-audit), before M29** — field-validated by the first real consumer's first smoke test, cheap (skill prose, no enforcement code), and it protects every project *birth*: the blind spot compounds worst at kickoff. Takes **v2.5.0** (renumbered back into the 2.x line by the 2026-07-18 restructure; see version plan).

**Premortem:**
- *Kickoff friction / interview bloat* (high) — a relentless grill makes `/g-kickoff` exhausting; users rubber-stamp to escape and the probe's value dies. → Fixed, small probe set (4 categories); recommended answer on every question; concludes at shared understanding, hard-capped; the grill surfaces, never blocks.
- *Reachability gate becomes theater* (med) — "every feature reachable" is judgment-heavy; a checkbox version is false confidence. → The gate must emit the evidence (the entity→create-surface matrix, exactly the table the G-Cash brief hand-built) and stays advisory-with-evidence.
- *Probe-set copy drift* (med — finding #19's exact failure mode) → single source, referenced not copied by kickoff / roadmap / gate / patterns; `/g-blast-radius` at Wave 1 close.
- *External-skill coupling* (med, pre-mitigated) — adopting grill-me as a runtime dependency couples kickoff to unversioned third-party content. → Native implementation; prior-art credit only.

**Cross-cutting propagation (G-RULES §B):** the cold-start probe set is a shared primitive consumed by `/g-kickoff`, `/g-roadmap`, the reachability gate, and `/g-patterns` — run `/g-blast-radius` at Wave 1 close; the done condition is incomplete until the architecture-review completeness gate confirms no consumer was missed.

---

### M43 — Operator Controls (/g-settings + inspection cadence)
**Status:** ⬜ Not started (scoped 2026-07-15, developer)
**Version:** v2.13.0 (minor — new skill + new operative variable; renumbered back into the 2.x line 2026-07-18 — rebrand moved to the M44 capstone. **Parallel-friendly / pull-forward eligible** — independent of the multiplayer arc, touches only g-init/g-execute skill prose + a new skill; slots into any gap on developer request, like M36.)
**Goal:** Give the operator **visibility and control over G-Forge's setup and operative variables**, and give actual programmers (non-vibe-coders) a first-class way to *read the code* at wave boundaries instead of only meeting it at the review verdict.
**Scope (waved):**
- **Wave 1 — `/g-settings`:** one skill that surfaces every G-Forge state variable with current value, owner (which skill/hook writes it), and effect — `integration-tier`, `voice-profile`, `telemetry-profile`, `inspection-cadence` (Wave 2), Roundtable binding, plus read-only diagnostics (`review-holds`, `milestone-count`, `session-prompt-count`, `escalation-log`, `last-trim`). Safe edits routed through it (validated values only); gate-relevant changes (tier) get an explicit are-you-sure with consequences. **Distinct from `/g-doctor`** — doctor validates *health/state*, settings shows and sets *intent*. Registered in the `/g-forge` router.
- **Wave 2 — Inspection cadence (the programmer's wave-boundary hold):** new variable `.claude/inspection-cadence` ∈ `every-wave` | `every-milestone` | `off` (default `off`). `/g-init` gains ONE intake question ("Do you want to personally inspect the code at wave boundaries?" — framed for experienced devs; decline = off, no friction for vibe-coders). `/g-execute`'s wave-completion gate honors it as a **hard hold**: present the wave's diff summary + changed-file list, dispatch nothing further until the developer nods (consistent with gates-gate; an ignorable pause is not an inspection gate). `every-milestone` holds only before the final wave's `/g-review` handoff.
- **Wave 3 — Propagation (G-RULES §B):** `/g-voice` cross-references (voice = how it *talks*, settings = how it *runs* — the intake flows must not duplicate questions); `/g-doctor` gains a check that `inspection-cadence` holds a valid value; **M39 G-tweak reassess hook** — the Phase A interview reads the cadence + observed behavior (holds always waved through ⇒ suggest `off`; frequent post-merge complaints ⇒ suggest `every-wave`) and proposes changes approve-before-write.

**Premortem (sketch):**
- *Settings sprawl* (med) — /g-settings becomes a junk drawer as every future milestone adds variables. → Registry table in the skill is THE inventory; adding a variable without registering it = a `/g-doctor` advisory (mirrors finding #19's single-source lesson).
- *Hold fatigue* (med) — `every-wave` on a 7-wave milestone = 7 interrupts; the developer stops reading and nods blind. → G-tweak reassess hook exists precisely for this; the hold prompt shows diff *size* so the developer can calibrate; switching cadence is one /g-settings command away.
- *Second intake question creep on g-init* (low) — init interview bloats one question at a time (M42's kickoff-friction premortem, same failure). → Hard rule: ONE question, recommended default, decline = silent off.

**Depends on:** — (standalone; the M39 hook activates whenever both ship, order-independent).

---

### M44 — G-Proof 1.0 (rebrand capstone — THE LAST RELEASE OF THE ARC)
**Status:** ⬜ Not started (scope carved out of the pre-2026-07-18 M41; sequenced dead last by design)
**Version:** **G-Proof 1.0** — versioning restarts under the new name. The 2.x line ends where this begins; no mid-arc 3.0.0 ever ships.
**Goal:** Rebrand **G-Forge → G-Proof** as the *conclusion* of the roadmap — the name lands when the product can fully back it: enforcement provably enforcing (M-audit), releases gated (M41), memory + salience live (M35–M37), the multiplayer arc shipped (M29/M33/M34), and self-governance measuring itself honestly (M38/M39 + the 2026-07-18 calibration item). "Proof" is a claim; this milestone ships it as a demonstrated property, not a promise.
**Rationale for capstone placement (developer decision, 2026-07-18):** consumers (G-Cash, an external consumer, the alveria fork) keep a stable name/URL through the heaviest milestones; the awkward 3.x mid-arc renumbering disappears; the rebrand becomes a single, complete story ("G-Proof 1.0") instead of a mid-flight costume change. GitHub's rename redirect keeps the mechanical cost of renaming late identical to renaming early.
**Scope (waves carried over from the pre-split M41 — full task detail in `g-docs/milestones/M44.md`):**
- **Wave 1 — Rename & manifest:** repo `hllrm/g-forge` → `hllrm/g-proof` (GitHub auto-redirects); `plugin.json` + `marketplace.json` name/display-name/description + version → **1.0.0** under the new name; sweep internal `g-forge` → `g-proof` (CLAUDE.md, skill frontmatter, hook headers) — **historical retros + dated ADRs left as-written** (rename globset excludes them); CHANGELOG heading + G-Proof 1.0 anchor with an explicit version-lineage note (G-Forge 2.x → G-Proof 1.0).
- **Wave 2 — Full README restyle (persuasion-ordered, G-Proof-branded):** ~250–300 lines (from ~700); tagline ("Claude Code is powerful. It's also optimized for velocity, not reliability. But you can G-Proof it."), producer's-seal analogy, **gate GIF** (commit blocked → `/g-review` → MERGE READY → commit passes; fallback animated-SVG/mermaid/text), before/after table, 5-minute install, FAQ, roadmap table. The status strip (shipped v2.3.0, maintained since) carries over restyled. Uses M41's `/g-release` + `/g-doctor` consistency machinery — by this point both are long-shipped.
- **Wave 3 — Field communication:** migration notes + announcement for known installs (`hllrm/G-Cash`, an external consumer, marketplace listing) — repo renamed, plugin name changed, **run `/g-update` to resync**; version-lineage explanation front and center (1.0 = rename + maturity marker, same enforcement model); flag Confluence `109314050` / Drive refs for cleanup. Done = consumers notified + confirmed able to `/g-update`; no broken links.

**Premortem (carried from the pre-split M41 where applicable):**
- *Rename churn / broken clones* (med) → GitHub auto-redirects; no force-push; field installs resync via `/g-update`.
- *Downstream fork breakage* (med) → migration notes + tested `/g-update` path; done condition includes "consumer can resync," not just "announced."
- *Version-lineage confusion* (med — HIGHER than the old v3.0.0 plan's "culture shock" risk, since 2.13 → 1.0 reads as a downgrade to the unbriefed) → the announcement + CHANGELOG lineage note lead with it; `/g-update` compares (name, version) pairs, not bare numbers — verify this explicitly in Wave 1.
- *Gate GIF can't be captured* (low) → fallback to animated SVG / mermaid / text sequence.

**Depends on:** everything — that's the point. Hard prerequisites: M41 (release machinery cuts this release), M38/M39 (the self-governance story the name claims).

---

## Backlog

### Candidate — Multi-session / multi-operator orchestration ("orchestrating humans")
G-Forge orchestrates *agents* inside one session today. It already does **sequential, git-mediated** multi-session handoff — the ROADMAP `## Active Session` block + `/g-resume` + the observer journal are the primitives; this very session ran that way across two machines. The open question is **concurrent** coordination: can HQ in one session treat *other live sessions* (human or agent, same or different machine) as dispatchable units?

The motivating failure is concrete and already observed: a session began planning **M24** while another session had already claimed **M24/M25** — multi-session work has no **claim/lock** primitive, so parallel sessions silently collide on milestone numbers, branches, and the handoff block.

Possible scope when promoted to a milestone:
- A claim/lease primitive (e.g. `.claude/claims/` or a remote-backed lock) so a session can reserve a milestone number / wave / file-set before work starts.
- Collision detection in `/g-roadmap` and `/g-plan` (fetch + check before assigning a milestone number).
- A handoff/merge protocol for *concurrent* (not just sequential) sessions — who owns `main`, how waves from different operators reconcile.
- Decide the honest boundary: is this "orchestrating humans," or just safer git-mediated coordination? (Aligns with the M24 positioning — governance, not orchestration-for-its-own-sake.)

A brainstormed approach — coordinate through an always-available, instantly-visible **shared surface reached via an MCP** rather than git, which only propagates on push/fetch — is captured in `g-docs/multi-session-coordination.md`. Direction chosen: ship spread surfaces behind a common, extensible adapter, **leading on official MCPs** — **Google (Gmail/Drive)** as flow+floor, **Confluence** as the enterprise lock, **Discord** optional (community MCP). Scoped as M29.

*Status: **the goal is now explicit — multiplayer G-Forge** (full multi-user cooperation on one project; "human orchestration, powered by humans"). The concurrent claim/lease is **M29** (phase one, scoped, awaiting go); the cooperation layer — assignment, cross-person handoff/review, reconciliation — is the milestone arc beyond it. North star + framework captured in `g-docs/multi-session-coordination.md`.*

---

### Candidate — Unified Provenance Primitive (decide, don't build)
Two independent inventions describe the same shape: **a pinned external source + a provenance note + the rule that change lives in the decision layer, not a silent swap.** M40's `reference/` `SNAPSHOT.md` (source pin + deriving-ADR + delta-not-swap rule) and the alveria-forge fork's `al-docs/UPSTREAM.md` (pinned upstream commit + PORTED/DROPPED/DIVERGED ledger + on-release review checklist) each reinvented it — one for external corpora, one for upstream lineage. Worth an ADR to **name the primitive once** so both share a template, instead of solving provenance twice. **YAGNI on tooling** — no skill, no scaffold; the decision is whether it's one named g-forge concept. Gated behind M40 shipping (it needs one concrete instance in-tree first).

---

## Version Plan

```
v0.8.1 → v0.9.0 (M8) → v0.10.0 (M9) → v0.11.0 (M10) → v0.12.0 (M11)
       → v0.13.0 (M12) → v0.14.0 (M13) → v0.15.0 (M14) → **v1.0.0 (M15) ✅ shipped**
       → **v2.0.0 (M23) ✅** → **v2.0.1 (M24 + stack implementers) ✅** → **v2.1.0 (M27 — doc-review gate) ✅** → **v2.2.0 (M28 — g-docs canonical tracking) ✅**
       → **v2.3.0 (M-audit-2026-07 — Forge Integrity; upgraded from v2.2.2 — W1 is new capability, not fixes; ships the first README status strip + starts the CHANGELOG/README currency convention)** → **v2.4.0 (M41 — Release Machinery + README Currency: /g-release + /g-changelog + /g-doctor version-consistency; rebrand split out 2026-07-18)** → **v2.5.0 (M42 — Planning Cold-Start Integrity; sequenced early despite tail ID — G-Cash field report)** → v2.6.0 (M29 — multiplayer phase one) → v2.7.0 (M35 — Memory Forge) → **v2.8.0 (M37 — Salience Layer propagation; M36 approach/ADR is design-only, gates M37, slots early)** → **v2.9.0 (M33 B–D — the Roundtable)** → M34 (cross-session dependency tracking + pull/push orchestration, arc spine) → M30–M32 mechanics reconcile against M34 → **v2.10.0 (M38 — G-Report)** → **v2.11.0 (M39 — G-tweak)** → **v2.12.0 (M40 — Reference Convention)** → **v2.13.0 (M43 — Operator Controls: /g-settings + inspection cadence; parallel-friendly, pull-forward eligible)** → **G-Proof 1.0 (M44 — rebrand capstone; versioning restarts under the new name — THE last release of the arc)** · M26 (Provable Wave Dispatch) deferred to its own minor when its spike clears · M25 benchmark ships its number when run
```

MVP cut: M9 + M10 + M11 — context structure + failure detection + intelligent planning with premortems.
