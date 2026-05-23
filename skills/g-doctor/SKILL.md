---
name: g-doctor
description: Health check for g-team project setup. Verifies all 4 hooks installed, all hooks registered in settings.json, G-Forge Rules block in CLAUDE.md, G-RULES.md present and referenced, no stale sentinel. Also checks CLAUDE.md for inline rules bloat. Reports ✓/✗/⚠ per check with fix instructions.
---

Announce: "Using g-doctor to check project health."

Run all 12 checks below against the current working directory, then output the report in the exact format specified. Checks 1–10 are required (✓/✗). Checks 11–12 are advisory (✓/⚠) — they surface improvement opportunities but do not count toward the pass/fail total.

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
Check if `.claude/g-team-approved` exists. It should NOT exist (it is auto-cleared after each commit).
- Pass (file absent): ✓ No stale approval sentinel
- Fail (file present): ✗ Stale approval sentinel found
  → A stale approval sentinel exists. Delete it: `rm .claude/g-team-approved`

**10. PreCompact hook installed and registered**
Check if `.claude/hooks/pre-compact.sh` exists AND `.claude/settings.json` contains a `PreCompact` hook entry pointing to `pre-compact.sh`.
- Pass: ✓ PreCompact hook installed and registered
- Fail (file missing): ✗ PreCompact hook script missing
  → Run `/g-init` or `/g-update` to install pre-compact.sh.
- Fail (not registered): ✗ PreCompact hook not registered in settings.json
  → Run `/g-init` or `/g-update` to register the PreCompact hook.

**11. CLAUDE.md architecture rules format** (advisory)
Read `CLAUDE.md`. For each `<!-- G-Forge [stack] Architecture Rules` block, count the non-empty lines between the opening and closing markers. If any block has more than 3 lines of content, it is using the legacy inline format.
- Pass: ✓ CLAUDE.md architecture rules compact (@reference format)
- Advisory: ⚠ CLAUDE.md has [N] inline architecture block(s) — legacy format
  → Run `/g-update` to extract inline rules to `.claude/rules/` and compact CLAUDE.md automatically.

**12. CLAUDE.md total size** (advisory)
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

  Advisory
  [✓/⚠ line for check 11]
    [→ fix instruction if advisory]
  [✓/⚠ line for check 12]
    [→ fix instruction if advisory]
────────────────────────────────────────────────
[N/10 required checks passed]
```

Fix instructions are indented with four spaces and prefixed with `→ `, and appear only on failing or advisory checks.

After the summary count line, add one blank line, then:
- If all 10 required checks passed and no advisories: `All checks passed. Project is healthy.`
- If all 10 required checks passed but advisories exist: `Required checks passed. Address advisories above to keep CLAUDE.md compact.`
- If any required check failed: `Fix the issues above, then re-run /g-doctor.`
