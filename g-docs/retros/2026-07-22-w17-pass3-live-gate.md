# Retro: w17-pass3-live-gate — 2026-07-22

## What was done
- **W1.7 Pass 3 (Waves 8–12) executed end-to-end — W1.7 SHIPPED; the commit gate ran its first real commits and held every path.** Three gated commits: `1acd512` (Task 14, primary tree, 13 files — dual sentinels stamped, both live gates passed, both sentinels auto-consumed on normal argv), `a966d88` (Task 15, authored + committed from a linked worktree — ADR-005 live, per-worktree-keyed doc sentinel matched + consumed primary-side), `c3947dc` (Wave-12 ledger close, committed via stamped script indirection — Task 16 pass-half, native hook verified + consumed what PreToolUse never saw).
- **Task 16 deny-half:** unstamped script-indirection commit denied by the native hook (rc=1, HEAD unmoved) while PreToolUse passed the `bash` call — the exact hole (script commits bypassing both argv sites) that forced W1.5g/W1.6 manual sentinel clears is closed and live-proven both directions.
- **Pre-entry anomaly resolved:** stray empty commit `20ddfbe` ("filler", `t@t` fixture identity) — escaped a throwaway clone during Pass-1 fixture debugging, pre-dated gate install, invisible to observer/PreToolUse via script indirection. Dropped via `reset --soft` (tree-identical, unpushed, reflog-recoverable).
- Full review chain per commit: attestation GREEN 405/405 (15 suites) + fixtures 37/0 + 35/35 → code-lead MERGE READY 0c/0M/1m → three DOCS READY verdicts (0b/1w, 0/0, 0/0); all four minors/warnings fixed inline pre-stamp.
- Ledger closed: `W1.7i (partial)` + `W1.7ii (close)` rows; findings **#8/#9/#10/#25 CLOSED**, #21 argv surfaces closed (heredoc residual → W2); #22 attribution live-confirmed in journal.

## Decisions made
- **Release gate moved: v2.3.0 ships at FULL M-audit close (W1+W2+W3), superseding the 2026-07-18 at-W1-close call** (developer, this session — "one milestone, one version"; W2's shim retirement is user-visible and belongs inside the release). Recorded on W1.7i/W1.7ii rows + ROADMAP FIRST.
- **Non-blockers pulled into scope** (developer): W1.5g Spike S1 now gates W1 close; ADR-007 verify stays first task of the W2 session.
- Doc-only commits signal class via explicit pathspec argv at the PreToolUse site (unclassifiable⇒CODE fail-toward-deny is design, live-proven); commit bodies for gate probes are written via the Write tool, never Bash heredocs.

## Patterns
### Worked well
- Clone-first → install → live-commit 3-pass split: every live outcome matched clone evidence exactly; zero lockouts, zero escape-hatch use in anger.
- Review gates earned their keep again: code-lead independently proved the garbage-tier pin discriminates; doc gate caught the missing W1.7 CHANGELOG entry class pre-emptively (HQ) and precision-fixed the fixture header claim.
- First W1.x slice with zero attestation-runner kills (forecast scenario 4 finally did not fire).
- Anomaly discipline: unexplained commit investigated to root cause (fixture-identity + timing + install mtimes) before any state change; `reset --soft` chosen with tree-identity proof.
### Avoid / do differently
- **Never chain proof-steps into commit commands** — the trailing `ls` of consumed sentinels made both wrapper calls exit non-zero, and PostToolUse appears to skip on failed tool calls: both gated commits went unjournaled and argv-side cleanup never fired (native consume covered it). Characterize precisely in W2/W3.
- Bash heredocs whose BODY contains a commit line are denied by the PreToolUse multi-line walk (#21 heredoc residual, re-confirmed live twice this arc) — write such scripts via the Write tool.
- Fixture debugging that clones the real repo must guard against escaping commits: `20ddfbe` proves a probe can land on the real HEAD silently when run via script file pre-gate. Post-gate this class is now denied (Task 16), but keep probes in throwaway clones regardless.

## Cold-start context
**Branch:** main (3 gated commits ahead of the pass start; 5 total unpushed vs origin)
**Active milestone:** M-audit-2026-07 — Forge Integrity (🔄; W1.7 shipped; W1 closes after Spike S1; v2.3.0 at FULL milestone close)
**Next up:** W1.5g Pass 3 (Spike S1) in a FRESH session — `g-docs/plans/w1-5g-self-host-integrity.md` Waves 6–7, mandatory plugin-cache restore after; then ADR-007 fresh-window verify → /g-plan W2.
**Key files touched:** M-audit-2026-07.md, ROADMAP.md, CHANGELOG.md, clone-first-gate-verify.sh, w1-7 forecast, session-start.sh, workflow-checkpoint.sh, 7 test suites.
**Carry-over:** THE GATE IS LIVE — all commits here now require stamped sentinels; sandbox commit probes via Write-tool script files only; rollback snapshot `claude-install-snapshot-2026-07-22`; this retro + forecast Outcome table UNCOMMITTED, ride the next doc commit.

## Journal basis
~20 events this session (agent · merge · session) — typed agent attribution live (g-forge-dev, code-lead, doc-reviewer ×3, RESULT parsing). Known gap: the three gated commits absent from the journal (PostToolUse-on-error skip + script indirection — see Avoid). Forecast w1-7 Outcome table reconciled: scenario 3 happened (caught in-band, twice), 1/2/4/5 did not.
