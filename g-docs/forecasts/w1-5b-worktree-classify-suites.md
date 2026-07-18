# Forecast: M-audit W1.5b — worktree-resolve + classify-changeset suites

> Created: 2026-07-18
> Plan: g-docs/plans/w1-5b-worktree-classify-suites.md
> Mode: regular

## Complexity
- Score: 5/10
- Breakdown: files 2 (3–5 distinct incl. conditional hook targets → 2), waves 4 (→ 2), boundaries 1 (tests ↔ hooks/lib via conditional 4a/7a fixes), new surface 0, rule edits 0

## Miss-risk: 65% — Elevated

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | Suite asserts assumed-not-observed behavior — the classify suite (T5) has NO probe task preceding it, unlike the worktree suite; test-writer encodes the lib's header table instead of live behavior | 3 | 3 | 9 | T5 prompt must require reading the lib body (not just header) + the heredoc/no-pipe call convention; T7 attestation treats ANY divergence as fail-before evidence, never edits the lib to match the suite | W1.5a plan (attempt 1 discarded); finding #20 |
| 2 | Windows/git-bash platform quirks in worktree probes — relative-vs-absolute --git-common-dir, spaced paths, glob behaviors | 3 | 3 | 9 | T2 probe must include a spaced-path temp dir + both common-dir forms; reuse g-dev/fixtures/pre-commit-spaced-worktree-verify.sh idiom | W1.2 r1 Major (spaced worktree); ledger #26; memory windows-hook-gotchas |
| 3 | Session/usage-limit kill mid-slice — budget is tight (37 est vs 38 remaining); yesterday's limit killed a review AND a g-forge-dev attest | 3 | 3 | 9 | Single-message wave dispatches; commit promptly at MERGE READY; if a kill hits, treat partial agent output as VOID (W1.5a precedent) | 2026-07-17 session (two kills); handoff |
| 4 | Gate-self-modification regression via conditional 7a — invariant-test failure would trigger edits to check-commit.sh/pre-commit, the live gate | 2 | 4 | 8 | 7a fires only on fail-before evidence; full W1.5a-style probe + full-suite sweep before commit; treat hooks/ edits with the W1.5a hazard protocol | 2026-07-06 forecast scenario 1 (fired); W1.5a plan hazard note |
| 5 | Parallel-agent file collision in Wave 1 (3 concurrent tasks) | 2 | 3 | 6 | T5+T6 already collapsed to one dispatch; T1(HQ)/T2(scratchpad)/T5(new file) are file-disjoint; wave-close integrity check per ADR-006 doctrine | ADR-006 (Systemic pattern); retro 2026-07-16 |

## Recommendations

  Elevated — Apply at least the top-2 mitigations before approving. Consider splitting the largest wave.
  Applied at plan time: scenario 1 & 2 mitigations folded into the T5/T2 task prompts; scenario 5 pre-mitigated by the T5+T6 dispatch collapse. Scenario 3 is environmental — commit promptly, dispatch waves in single messages.
  (Forecast assumes the historical pattern set is representative.)

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | | |
| 2 | yes | | |
| 3 | yes | | |
| 4 | yes | | |
| 5 | yes | | |
