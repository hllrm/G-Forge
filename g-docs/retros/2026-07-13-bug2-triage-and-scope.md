# Retro: bug2-triage-and-scope — 2026-07-13

## What was done
- Synced this machine to the cloud session's state — fast-forward pull of 6 commits to `a192670` (M40, ADR-004/005, test-writer #20 fix, manifest revert to v2.2.1); dropped this machine's superseded parallel ADR-004/005 drafts and the stashed local ROADMAP handoff edit after confirming the cloud versions supersede them.
- Triaged a 5-bug report from the G-Tools retro corpus into the M-audit-2026-07 ledger: #21 (BUG-2, W1), #22 (BUG-3, W2), #23 (BUG-4, W3), #24 (BUG-5, W3), and 1f (BUG-1 field note).
- Established BUG-1 was **not** a source defect — the doc-sentinel leak is already fixed in source (`f55ccdb`); G-Tools hit a stale installed hook, so its remediation is `/g-update` (a live field instance of drift-finding #5).
- Reproduced BUG-2 live three times during routine record-keeping and documented three distinct surfaces on finding #21: substring-anywhere detection, chained pre-execution state, and commit-message-body tokenized as pathspecs.
- Scoped an executable argv-parse fix spec for #21 into the tracked ledger — folded into the ADR-004 implementation pass with a Wave 1 coordination note (shared detection routine, atomic `/g-update` rollout, no downstream hand-patching) and a fail-before/pass-after test plan.
- Three docs-only commits, all pushed to `origin/main`: `4d4a16f` (triage), `dc61fbd` (third surface), `60230b1` (fix spec). Zero code touched.

## Decisions made
- Deleted this machine's untracked parallel ADR-004/005 drafts and dropped the ROADMAP stash after developer confirmation (git rm + stash drop; cloud versions are authoritative and more resolved).
- Folded BUG-2 (#21) into the ADR-004 implementation pass rather than an independent patch — the two edit the same file and concept, so a standalone fix would risk the double-patch divergence the coordination note guards against.
- Chose "quick-scope only, no code" for the #21 fix this session (evidence: AskUserQuestion answer) given gate-self-modification risk plus the context-compaction threshold.
- Embedded the #21 fix spec in the tracked ledger instead of `g-docs/plans/` after discovering that directory is gitignored (a plan file would not survive to a fresh session).

## Patterns
### Worked well
- The doc gate ran on every docs commit and issued DOCS READY each time; the sentinel auto-cleared after each commit (no stale-sentinel carryover).
- The doc-reviewer agent caught a real accuracy defect before it landed — the Surface #1 example (`…git commit"`) that the post-`f55ccdb` regex does not actually fire on — and it was corrected pre-commit.
- Clean sync with no data loss: the blocked `git pull` was resolved via stash + fast-forward, and every superseded local artifact was verified against origin before deletion.

### Avoid / do differently
- BUG-2's false-positives taxed the workflow directly: the commit gate blocked routine commands three times, forcing path-free commit messages and split-out `git add`/`git commit` calls. The gate's own bug obstructed recording the bug.
- The observer journal logged all 187 agent events this session as `unknown start`/`unknown stop` (BUG-3 / finding #22), so this retro could not synthesize any agent-level signal from the journal — agent activity was reconstructed from git and the working transcript instead. The learning-loop evidence base is degraded exactly as #22 describes.

## Cold-start context
**Branch:** main
**Active milestone:** M-audit-2026-07 — Forge Integrity (🔄 in progress; Wave 1 next)
**Next up:** verify ADR-004 (sentinel↔tree binding) and ADR-005 (worktree enforcement) against the repo, then implement Wave 1 code — #8/#9/#10 plus #21 (the argv-parse commit-detection routine, shared with ADR-004's pre-commit hook) — each with fail-before/pass-after tests, through /g-review; then Sub-plan B test coverage (#11); then close for v2.2.2.
**Key files touched:** ROADMAP.md, M-audit-2026-07.md
**Carry-over context:** main; v2.2.2 ships when M-audit W1 closes (now gated on ADR-004/005 + #21 implementation). Arc: M-audit-2026-07 → M29 → M35 → M37 → M33 B–D → M34 → M30–M32 → M38 → M39; M36 slots early, gates M37. This repo is both plugin source and a self-hosted consumer — verify skill/hook behavior against this repo's own source, not the lagging plugin cache. Finding #19 still paused pending the hllrm/G-Cash live-install check.

## Journal basis
187 agent (all `unknown` — unusable, BUG-3/#22) · 3 commit · 3 push · 6 session · 0 test · 0 revert
