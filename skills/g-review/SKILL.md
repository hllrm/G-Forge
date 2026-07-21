---
name: g-review
description: Run the full review pipeline on the current branch diff. Dispatches code-lead which verifies done conditions and runs review-orchestrator. Issues MERGE READY or HOLD.
context: [task, sprint, architectural]
---

**Announce:** "Using g-review to run the full review pipeline."

You are running the merge gate. Execute these steps in order.

## Step 0 — Read telemetry profile (adaptive review intensity)

Read `.claude/telemetry-profile` if it exists. Treat the contents as one of `stable`, `cautious`, `defensive`, or `recovery`. Missing or malformed → treat as `stable`.

Apply the following review adjustments throughout this skill:

| Profile | Reviewer adjustment | Pre-review additions |
|---------|---------------------|----------------------|
| `stable` | Default reviewer set (code-reviewer, security-auditor when auth/external IO touched, architecture-enforcer when layer-boundary changes, performance-auditor when hot-path changes) | None |
| `cautious` | +1 additional `code-reviewer` pass with stricter instructions | None |
| `defensive` | +1 `code-reviewer`, +1 `architecture-enforcer` regardless of diff | Dispatch `debugger` pre-review on the diff for root-cause sanity check |
| `recovery` | Full reviewer set regardless of diff (`code-reviewer`, `security-auditor`, `architecture-enforcer`, `performance-auditor`) | Dispatch `debugger` + `error-detective` pre-review |

Pass the active profile to code-lead in Step 4 so its dispatch of review-orchestrator applies the adjustments. Announce the profile once at the top of the run:
```
Telemetry profile: [profile] — review intensity adjusted accordingly
```

## Step 1 — Run the test suite

**Installed-copy drift check (routine, visible-only — ADR-008 clause 5).** Before anything else, do a one-shot hash comparison of the installed `.claude/hooks/` copy (plus `.claude/hooks/lib/`) against the canonical `hooks/` source in this repo — the same comparison `/g-doctor` Check 16 performs:
```bash
hash_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    cksum "$1" | awk '{print $1, $2}'
  fi
}
```
For each top-level script in `hooks/` and each lib script in `hooks/lib/*.sh`, compare `hash_file` of the canonical source against its installed counterpart at `.claude/hooks/<file>` and `.claude/hooks/lib/<file>` respectively. A missing installed file counts as drift, same as Check 16. Skip this check silently (report `Installed-copy drift: not applicable — no canonical hooks/ in this checkout`) if `hooks/` does not exist at the repo root, so /g-review stays usable outside this repo's own dogfooded copy.

Report the result as one line, verbatim, in the review record:
- Clean: `Installed-copy drift: clean`
- Drifted: `Installed-copy drift: N file(s) drifted — run /g-update ([file], [file], ...)`

**This result NEVER gates the MERGE READY / HOLD verdict.** It is reported for visibility only — carry the line forward unchanged into Step 4's dispatch to code-lead and into the verdict presented in Step 6, but do not let drift (of any degree) turn a MERGE READY into a HOLD, and do not ask code-lead to treat it as a finding.

Before reviewing any code, verify the test suite passes.

**Check for a project-local test-runner agent first.** Glob `.claude/agents/*-dev.md`. If exactly one file matches:
- Dispatch that agent to run the project's test suite (and any project-specific gate fixtures it is described as covering) and return its runner output verbatim.
- Its report must include real pass/fail counts and, on any failure, the actual failing lines from the runner output. A self-declared "tests pass" claim with no runner evidence attached is UNVERIFIED (finding #20 doctrine) and does not count as attested — treat a report with no verbatim runner output the same as a failed run below and stop until the developer resolves it.
- Include the agent's verbatim runner output as the attested test result passed to code-lead in Step 4.
- Apply the same pass/fail branching described below: on a fully green report, continue to Step 2; on any red or partial report, follow the **If any tests fail** branch below, substituting the agent's verbatim output for directly-captured output.
- If more than one `.claude/agents/*-dev.md` file matches, ask the developer which one to dispatch, then proceed as above.

**If no project-local test-runner agent exists, fall back to the following inline detect-and-run behavior.**

**Detect the test command** using this priority order:
1. Check `package.json` scripts for `"test"` — if found, use `npm test` (or `bun test` / `yarn test` based on lockfile)
2. Check for `pytest.ini`, `pyproject.toml` with `[tool.pytest]`, or `tests/` with `.py` files — use `pytest`
3. Check for `Makefile` with a `test` target — use `make test`
4. Check `g-docs/project_brief.md` Tests field for the framework name
5. If no test command can be detected: ask the developer — "What command runs your test suite?" — wait for answer

**Run the test command.** Capture the output.

**If all tests pass:**
- Report: `✓ Tests passed — proceeding to code review`
- Continue to Step 2

**If any tests fail:**
- Do NOT write `.claude/g-forge-approved`
- Report the failing tests verbatim
- Dispatch `error-detective` with the full test output and the current diff (`git diff main...HEAD`). Ask it to identify the root cause of each failure — file, line, pattern.
- After error-detective returns, dispatch `debugger` with error-detective's findings and the relevant source files. Ask for a concrete fix strategy.
- Present both diagnoses to the developer, then stop with verdict: `HOLD — tests failing. Diagnosis above. Fix all failures before re-running /g-review.`
- Do not proceed to Step 2.

**If the project has no tests** (no test directory, no test script, no test framework detected):
- Report: `⚠ No test suite detected`
- Ask the developer: "No tests found. Options: (a) dispatch test-writer to add an appropriate test suite now, (b) skip tests for this review (one-time override). Which do you prefer?"
- **If developer chooses (a):** dispatch the `test-writer` agent with the current diff and project stack context. Ask test-writer to write tests covering the changed code. Once tests are written and pass, continue to Step 2.
- **If developer chooses (b):** note `⚠ No tests — developer override` in the review output and continue to Step 2. Do not block.

## Step 2 — Gather the diff

The primary target is the tree the sentinel will bind to at commit time — the staged set unioned with unstaged-but-tracked modifications, the same union `hooks/check-commit.sh`'s `-a`/`--all` handling already computes:
```
git diff --staged
```
unioned with:
```
git diff --name-only
```
Combine both into the diff under review — this is what `git write-tree` will hash if the developer commits as-is (including via `git commit -a`), so reviewing it here is what makes the Step 6 sentinel binding coherent (ADR-004).

If that union is empty, fall back to `git diff main...HEAD` — this covers resuming review on a branch that already carries committed-but-unreviewed history (e.g. an interrupted multi-commit session). This fallback role is unchanged from before; only the priority is inverted.

If both are empty, ask the developer: "What branch or commit range should I review?"

After capturing the diff, check whether it includes changes to any dependency manifest: `package.json`, `requirements.txt`, `Cargo.toml`, `go.mod`, `Pipfile`, `pyproject.toml`, `pom.xml`, `build.gradle`. Set `manifest_changed: true` if any are present in the diff. This flag is used in Step 4 to dispatch `dependency-auditor` in parallel.

## Step 3 — Gather done conditions

Check for done conditions in this order:
1. The relevant plan file (check `g-docs/plans/` for the most recent `.md` file, or a spec mentioned by the developer)
2. The current milestone file in `g-docs/milestones/`
3. Ask the developer: "What are the done conditions for this implementation?"

If no done conditions can be found, note this — code-lead will flag it as a process gap.

## Step 4 — Dispatch code-lead

Dispatch the `code-lead` agent. Provide **all of the following** in the prompt so code-lead does not re-run already-completed checks. Code-lead uses the compact return format — parse its `RESULT:` field; on `HOLD` or `ESCALATE` read the `DETAIL:` file before presenting verdict to the developer.

- **Attested test result** — state explicitly: `"Tests: PASS (attested — exit 0, output below)"` and include the captured output from Step 1, OR `"Tests: skipped — developer override"` if the developer chose (b). If tests failed, you do not reach this step.
- **Attested type-check result** — if a type-checker was run (e.g. `vue-tsc --noEmit`, `tsc --noEmit`) in any prior step or by an implementing agent, include: `"Type-check: PASS (attested — exit 0)"`. If not run, omit this line.
- The `Installed-copy drift:` line from Step 1, verbatim. Tell code-lead explicitly: this is informational only, it must appear in the review record but must never factor into the MERGE READY / HOLD verdict.
- The full diff from Step 2
- The done conditions from Step 3
- The current branch name (from `git branch --show-current`)
- The task list (if known)
- `output_file: g-docs/agent-output/review/code-lead-[YYYY-MM-DD].md`

code-lead will verify remaining done conditions structurally (file checks, grep, read) and dispatch review-orchestrator internally. It must NOT re-run tests or type-check when attested results are provided. Pass the telemetry profile from Step 0 to code-lead so its dispatch of review-orchestrator scales reviewer count and pre-review additions accordingly.

If `manifest_changed` is true, dispatch `dependency-auditor` **in parallel** with code-lead. Provide it the changed manifest file(s), the diff context, and `output_file: g-docs/agent-output/review/dependency-auditor-[YYYY-MM-DD].md`. Wait for both to return, then include dependency-auditor's findings in the materials passed to code-lead for its final verdict (so any dependency risks are factored into MERGE READY / HOLD). If dependency-auditor returns `RESULT: HOLD` or any **CRITICAL or MAJOR** severity findings (its shared Critical/Major/Minor scale — a CRITICAL is a security advisory, a MAJOR is a deprecated/unmaintained or license-conflict dep), include them as blocking items in the HOLD verdict regardless of code-lead's position on other issues.

Wait for code-lead's complete verdict.

If code-lead returns HOLD, increment `.claude/review-holds` by 1 — this counter feeds the rework-rate telemetry metric (per `g-docs/telemetry-metrics.md` §4) regardless of the active profile. If the file does not exist, create it with value `1`. The increment is unconditional; only the *review-intensity adjustments above* depend on the profile. `/g-telemetry` resets the counter to `0` when a `stable` profile is derived.

## Step 5 — Tier 3 Smoke Test (MERGE READY path only)

If code-lead's verdict is **HOLD** or **ESCALATE**, skip to Step 6 — no smoke test needed until blocking issues are fixed.

If code-lead's verdict is **MERGE READY**:

1. Check whether `.claude/tier3-active` exists. If it does, a listen-mode session is already in progress — skip straight to Step 6.
2. Print the testing instrument:
   - Check for `g-docs/qa-scope/<milestone-slug>.md`. If it exists, read it and print the in-scope test groups.
   - If no QA scope doc: check whether the project has a QA panel (README, project docs). If it does, list the known affected test groups.
   - If no QA panel: retrieve or regenerate the test plan that was produced at milestone planning. Print it in full — the developer uses it as their checklist.
3. Prompt the developer:

   > "Code review passed. **Tier 3 — smoke test the changes.**
   > Work through the list above and report each finding in chat — say **'done this round'** when finished."

4. Write `0` to `.claude/tier3-active`.
5. **Listen mode is now active.** Rules while in listen mode:
   - Do NOT edit any files.
   - Do NOT suggest fixes or make comments about what might be wrong.
   - For each finding the developer reports, respond only with: `Bug N logged — <area>`
   - Increment the count in `.claude/tier3-active` after each acknowledgement.
6. When the developer says **"done this round"**:
   - Delete `.claude/tier3-active`.
   - If the count was **0** (no bugs reported): proceed to Step 6.
   - If any bugs were logged: triage the full batch (systemic vs. isolated), dispatch fix waves, re-run from Step 1 after fixes land. Do not proceed to Step 6 until a clean smoke-test round returns 0 bugs.

## Step 6 — Present verdict and manage sentinel

Present code-lead's verdict to the developer verbatim, followed by the `Installed-copy drift:` line from Step 1 — this is a visibility-only report and never changes the verdict above it, whatever it says.

**If verdict is MERGE READY:**
- Create `.claude/` directory if it does not exist
- Compute the sentinel stamp (binds the sentinel to the exact reviewed tree — ADR-004):
  - `commit_sentinel_ts`: for this to match the staged + unstaged-tracked union reviewed in Step 2, first stage any unstaged-but-tracked files that were part of that union (`git add -u`) so the index now holds exactly what was reviewed, then take `git write-tree` of the now-staged index — this reproduces the same tree `hooks/pre-commit`'s own `git write-tree` will hash at commit time (whether the developer commits with plain `git commit` or `git commit -a`), keeping the stamped tree and the committed tree identical. If Step 2 instead fell back to `git diff main...HEAD` (nothing staged or unstaged to review), the index already equals HEAD's tree and no extra staging is needed.
  - `commit_sentinel_head`: `git rev-parse --verify HEAD`
  - `commit_sentinel_worktree`: `git rev-parse --show-toplevel`
- Write `.claude/g-forge-approved` with content: `commit_sentinel_ts=<write-tree output> commit_sentinel_head=<rev-parse --verify HEAD output> commit_sentinel_worktree=<show-toplevel output>` (one line, space-separated `key=value` fields, exact field names — do not rename them)
- If this review covered doc/mixed changes and `.claude/g-forge-docs-approved` is also being written (see doc-review flows), write the identical stamp format there too, using the same tree+HEAD pair — on a mixed commit both sentinels bind to the one tree being committed.
- Tell the developer: "MERGE READY. Commit gate unlocked — you can now run git commit and merge."
- Ask once: "Would you like a PR description? (yes/no)" — if yes, dispatch `pr-writer` with the full diff from Step 2 and the done conditions from Step 3. Present the PR description. If no, continue silently.

**Milestone close-out (MERGE READY only):**

1. Read `g-docs/todo.md` — identify tasks marked as done or the tasks being reviewed in this session.
2. Read `g-docs/ROADMAP.md` — find the current active milestone (look for `🔄 In progress`).
3. Read the active milestone file from `g-docs/milestones/` (e.g. `g-docs/milestones/M1.md`). If the `g-docs/milestones/` directory does not exist or no matching tasks are found, skip silently — do not report anything.
4. For each task in the milestone's `## Scope` checklist that matches a completed task from this review, mark it `[x]`.
5. If ALL scope items in the milestone are now `[x]`:
   - Update the milestone status header to `✅ Complete`
   - Update the corresponding milestone entry in `g-docs/ROADMAP.md` from `🔄 In progress` to `✅ Complete`
   - Leave the completed milestone in place under `## Milestones` marked `✅ Complete` — there is no separate `## Done` section; completed milestones stay as history where they are (status key: ⬜ Not started · 🔄 In progress · ✅ Complete)
   - Report: `✓ Milestone [ID — Name] closed out`
   - **Version bump prompt:** Check the milestone entry in `g-docs/ROADMAP.md` for a `**Version:**` field. If present, use that as the target. If absent, detect the current version from (in order): `.claude-plugin/plugin.json`, `package.json`, `pyproject.toml`, `Cargo.toml`, and suggest a bump based on the milestone's nature (features → minor, fixes → patch, breaking → major).
   - Tell the developer:
     ```
     ✓ Milestone closed — version bump recommended
       Target version:  [from g-docs/ROADMAP.md Version field, or suggested]
       Run /g-update after bumping to sync project files.
     ```
   - Do not bump the version automatically — the developer decides and commits it separately.
   - **Auto-retro:** Immediately run `/g-retro` — use Glob to find `skills/g-retro/SKILL.md` inside `~/.claude/plugins/cache/g-forge/g-forge/` and read it, then follow its instructions. Use the milestone name as the topic slug (e.g. `M3-auth-refactor`). Do not wait for the developer to trigger it.
   - **Milestone close swarm:** Once the retro is written, dispatch the following concurrently — they are all read-only analysis and can run in parallel:
     - `/g-patterns` — mines the retro just written alongside previous retros. Use Glob to find `skills/g-patterns/SKILL.md` and follow its instructions.
     - `/g-telemetry` — refreshes reliability metrics now that the milestone is in the corpus. Use Glob to find `skills/g-telemetry/SKILL.md` and follow its instructions.
     - `/g-align` — brief-deviation check now that a milestone has closed: confirms the project is still serving `g-docs/project_brief.md` (goals, non-goals, MVP, tech decisions) rather than drifting. Use Glob to find `skills/g-align/SKILL.md` and follow its instructions. Advisory — surfaces ALIGNED or DRIFTING with a recommendation; never blocks the close-out. Skip silently if `g-docs/project_brief.md` does not exist.
     - **ADR prompt** — ask the developer once: "Were any significant architectural decisions made during this milestone that should be recorded as an ADR? (e.g. a new pattern adopted, a library chosen, a structural constraint introduced) — yes/no." If yes, run `/g-adr`. If no, continue.
   - **Wiki refresh (end-of-milestone task):** After the close swarm, run `/g-wiki` to update the human-facing project wiki (`g-wiki/`) for the milestone that just shipped — use Glob to find `skills/g-wiki/SKILL.md` and follow its instructions (incremental scope: document what this milestone built and reconcile existing pages against the code). The wiki is committed project content; refreshing it at each milestone close is what stops it going stale. If the developer would rather defer, note `Refresh g-wiki for [milestone]` as a pending task in `g-docs/todo.md` instead of running it now.
   - **Every-other-milestone health check:** Read `.claude/milestone-count` if it exists (contains an integer, default 0 if absent). Increment by 1. If the result is odd, run `/g-doctor` after the close swarm — use Glob to find `skills/g-doctor/SKILL.md` inside `~/.claude/plugins/cache/g-forge/g-forge/` and read it, then follow its instructions. Write the new count back to `.claude/milestone-count`.
6. If only some tasks are done:
   - Save the partial updates to the milestone file
   - Report: `✓ [N] milestone tasks checked off — [M] remaining`

**If verdict is HOLD — FIX REQUIRED:**
- Do NOT write `.claude/g-forge-approved`
- Tell the developer: "HOLD. Fix all blocking items listed above, then re-run /g-review."

**If verdict is ESCALATE:**
- Do NOT write `.claude/g-forge-approved`
- Present the escalation details and ask the developer for guidance before proceeding.

## Rules
- Never modify code-lead's verdict — present it exactly.
- The Step 1 installed-copy drift check is visible-only — it is always reported in the review record, but it never gates or downgrades the MERGE READY / HOLD verdict.
- Never write `.claude/g-forge-approved` for anything other than MERGE READY.
- Never skip Step 5 (Tier 3 smoke test) on a MERGE READY verdict — the sentinel must not be written until at least one clean smoke-test round completes.
- If code-lead is blocked by missing information, gather it and re-dispatch — do not guess.
- The sentinel is automatically cleared after the next `git commit` by the commit hook.
- In listen mode: zero edits, zero suggestions, acknowledgement only. Violations of listen mode reset the round.
