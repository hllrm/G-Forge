---
name: g-doctor
description: Health check for G-Forge project setup. Verifies all 7 hooks installed and registered in settings.json (and not double-registered by the plugin manifest), G-Forge Rules block in CLAUDE.md, G-RULES.md present and referenced, no stale sentinel. Also checks CLAUDE.md for inline rules bloat. Reports ✓/✗/⚠ per check with fix instructions.
---

Announce: "Using g-doctor to check project health."

Run all 16 checks below against the current working directory, then output the report in the exact format specified. Checks 1–14 are required (✓/✗). Checks 15–16 are advisory (✓/⚠) — they surface improvement opportunities but do not count toward the pass/fail total.

## Checks

**1. commit hook**
Check if `.claude/hooks/check-commit.sh` exists.
- Pass: ✓ commit hook installed
- Fail: ✗ commit hook missing
  → Run `/g-init` to install hooks.

**2. workflow hook**
Check if `.claude/hooks/workflow-checkpoint.sh` exists.
- Pass: ✓ workflow hook installed
- Fail: ✗ workflow hook missing
  → Run `/g-init` or `/g-update` to install the workflow checkpoint hook.

**3. post-commit hook**
Check if `.claude/hooks/post-commit-cleanup.sh` exists.
- Pass: ✓ post-commit hook installed
- Fail: ✗ post-commit hook missing
  → Run `/g-init` or `/g-update` to install the post-commit cleanup hook.

**4. PreToolUse registered**
Read `.claude/settings.json` and check if it contains a `PreToolUse` hook entry pointing to `check-commit.sh`.
- Pass: ✓ PreToolUse hook registered
- Fail: ✗ PreToolUse hook not registered
  → Run `/g-init` or `/g-update` to register the commit gate hook.

**5. UserPromptSubmit registered**
Read `.claude/settings.json` and check if it contains a `UserPromptSubmit` hook entry pointing to `workflow-checkpoint.sh`.
- Pass: ✓ UserPromptSubmit hook registered
- Fail: ✗ UserPromptSubmit hook not registered
  → Run `/g-init` or `/g-update` to register the workflow checkpoint hook.

**6. G-Forge Rules block**
Read `CLAUDE.md` and check if it contains the string `<!-- G-Forge Rules`.
- Pass: ✓ G-Forge Rules block present in CLAUDE.md
- Fail: ✗ G-Forge Rules block missing from CLAUDE.md
  → Run `/g-init` to inject G-Forge rules into CLAUDE.md.

**7. G-RULES.md present**
Check if `G-RULES.md` exists at the project root.
- Pass: ✓ G-RULES.md present
- Fail: ✗ G-RULES.md missing
  → Run `/g-init` or `/g-update` to install G-RULES.md.

**8. @G-RULES.md referenced in CLAUDE.md**
Read `CLAUDE.md` and check if it contains `@G-RULES.md`.
- Pass: ✓ @G-RULES.md reference present in CLAUDE.md
- Fail: ✗ @G-RULES.md reference missing from CLAUDE.md
  → Run `/g-init` or `/g-update` to add the @G-RULES.md reference.

**9. No stale sentinel**
Check if `.claude/g-forge-approved` exists. It should NOT exist (it is auto-cleared after each commit).
- Pass (file absent): ✓ No stale approval sentinel
- Fail (file present): ✗ Stale approval sentinel found
  → A stale approval sentinel exists. Delete it: `rm .claude/g-forge-approved`

**10. PreCompact hook installed and registered**
Check if `.claude/hooks/pre-compact.sh` exists AND `.claude/settings.json` contains a `PreCompact` hook entry pointing to `pre-compact.sh`.
- Pass: ✓ PreCompact hook installed and registered
- Fail (file missing): ✗ PreCompact hook script missing
  → Run `/g-init` or `/g-update` to install pre-compact.sh.
- Fail (not registered): ✗ PreCompact hook not registered in settings.json
  → Run `/g-init` or `/g-update` to register the PreCompact hook.

**11. SessionStart hook installed and registered**
Check if `.claude/hooks/session-start.sh` exists AND `.claude/settings.json` contains a `SessionStart` hook entry pointing to `session-start.sh`.
- Pass: ✓ SessionStart hook installed and registered
- Fail (file missing): ✗ SessionStart hook script missing
  → Run `/g-init` or `/g-update` to install session-start.sh.
- Fail (not registered): ✗ SessionStart hook not registered in settings.json
  → Run `/g-init` or `/g-update` to register the SessionStart hook.

**12. observer hooks installed and registered**
Check if `.claude/hooks/observe.sh` exists AND `.claude/settings.json` contains a `PostToolUse` hook entry pointing to `observe.sh` AND a `SessionStart` hook entry pointing to `observe.sh`.
- Pass: ✓ Observer hook installed and registered
- Fail (file missing): ✗ Observer hook script missing
  → Run `/g-init` or `/g-update` to install observe.sh.
- Fail (not registered): ✗ Observer hook not registered in settings.json
  → Run `/g-init` or `/g-update` to register the PostToolUse + SessionStart observer hooks.

**13. agent lifecycle hooks installed and registered**
Check if `.claude/hooks/agent-lifecycle.sh` exists AND `.claude/settings.json` contains a `SubagentStart` hook entry AND a `SubagentStop` hook entry pointing to `agent-lifecycle.sh`.
- Pass: ✓ Agent lifecycle hook installed and registered
- Fail (file missing): ✗ Agent lifecycle hook script missing
  → Run `/g-init` or `/g-update` to install agent-lifecycle.sh.
- Fail (not registered): ✗ Agent lifecycle hook not registered in settings.json
  → Run `/g-init` or `/g-update` to register the SubagentStart + SubagentStop hooks.

**14. No duplicate / double-firing hook registration**
G-Forge hooks must be registered in exactly ONE place — `.claude/settings.json` — with one entry per script per event. A hook registered twice fires twice (the context-depth counter double-increments, the commit gate runs twice, the journal gets double entries). Check both ways it can happen:
- Read `.claude/settings.json`. For each G-Forge script (`check-commit.sh`, `post-commit-cleanup.sh`, `observe.sh`, `agent-lifecycle.sh`, `pre-compact.sh`, `session-start.sh`, `workflow-checkpoint.sh`), count the entries referencing it under the same event key. More than one is a duplicate.
- Read the plugin manifest `hooks/hooks.json` from the plugin cache (Glob `~/.claude/plugins/cache/g-forge/g-forge/*/hooks/hooks.json`). Its `hooks` object must be empty `{}`. If it registers any hook that is ALSO in `.claude/settings.json`, that hook double-fires — the manifest fires it globally in every session AND the project fires it.
- Pass: ✓ No duplicate hook registration (settings.json is the single registrar)
- Fail (in-settings duplicate): ✗ [script] registered [N]× under [Event] in settings.json — will double-fire
  → Run `/g-update` to de-duplicate, or delete the extra entr(y/ies) from `.claude/settings.json`.
- Fail (manifest + project): ✗ [script] registered by BOTH the plugin manifest and settings.json — double-fires every session
  → Update the plugin (`/g-update`, or reinstall) so the manifest registers no hooks; `.claude/settings.json` is the single registrar.

**15. CLAUDE.md architecture rules format** (advisory)
Read `CLAUDE.md`. For each `<!-- G-Forge [stack] Architecture Rules` block, count the non-empty lines between the opening and closing markers. If any block has more than 3 lines of content, it is using the legacy inline format.
- Pass: ✓ CLAUDE.md architecture rules compact (@reference format)
- Advisory: ⚠ CLAUDE.md has [N] inline architecture block(s) — legacy format
  → Run `/g-update` to extract inline rules to `.claude/rules/` and compact CLAUDE.md automatically.

**16. CLAUDE.md total size** (advisory)
Count the total lines in `CLAUDE.md`.
- Pass (≤150 lines): ✓ CLAUDE.md compact ([N] lines)
- Advisory (>150 lines): ⚠ CLAUDE.md is [N] lines — may contain inline rules content
  → Run `/g-update` to migrate inline rules to `.claude/rules/` files.

**Note:** Milestone alignment is no longer a numbered check — it is contextual and covered by `/g-status`. Doctor focuses on hook and rules infrastructure only.

## Output format

Print the report exactly as shown:

```
G-Forge Doctor ─────────────────────────────────
  [✓/✗ line for check 1]
  [✓/✗ line for check 2]
    [→ fix instruction if failed]
  [✓/✗ line for check 3]
    [→ fix instruction if failed]
  [✓/✗ line for check 4]
    [→ fix instruction if failed]
  [✓/✗ line for check 5]
    [→ fix instruction if failed]
  [✓/✗ line for check 6]
    [→ fix instruction if failed]
  [✓/✗ line for check 7]
    [→ fix instruction if failed]
  [✓/✗ line for check 8]
    [→ fix instruction if failed]
  [✓/✗ line for check 9]
    [→ fix instruction if failed]
  [✓/✗ line for check 10]
    [→ fix instruction if failed]
  [✓/✗ line for check 11]
    [→ fix instruction if failed]
  [✓/✗ line for check 12]
    [→ fix instruction if failed]
  [✓/✗ line for check 13]
    [→ fix instruction if failed]
  [✓/✗ line for check 14]
    [→ fix instruction if failed]

  Advisory
  [✓/⚠ line for check 15]
    [→ fix instruction if advisory]
  [✓/⚠ line for check 16]
    [→ fix instruction if advisory]
────────────────────────────────────────────────
[N/14 required checks passed]
```

Fix instructions are indented with four spaces and prefixed with `→ `, and appear only on failing or advisory checks.

After the summary count line, add one blank line, then:
- If all 14 required checks passed and no advisories: `All checks passed. Project is healthy.`
- If all 14 required checks passed but advisories exist: `Required checks passed. Address advisories above to keep CLAUDE.md compact.`
- If any required check failed: `Fix the issues above, then re-run /g-doctor.`
