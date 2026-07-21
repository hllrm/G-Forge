---
name: g-doctor
description: Health check for G-Forge project setup. Verifies all 7 hooks installed and registered in settings.json (and not double-registered by the plugin manifest), G-Forge Rules block in CLAUDE.md, G-RULES.md present and referenced, no stale sentinel, and no installed-copy drift (hashes the installed hooks against plugin source to catch silently stale copies). Also vets the .gitignore (runtime artifacts ignored, project record tracked), flags stray G-Forge documents living outside g-docs/, and checks CLAUDE.md for inline rules bloat. Reports ✓/✗/⚠ per check with fix instructions.
---

Announce: "Using g-doctor to check project health."

Run all 22 checks below against the current working directory, then output the report in the exact format specified. Checks 1–16 are required (✓/✗). Checks 17–21 are advisory (✓/⚠) — they surface improvement opportunities but do not count toward the pass/fail total. Check 22 (Roundtable security) is advisory/conditional — it only runs when a Roundtable is bound.

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

**10. No stale doc-approval sentinel**
Check if `.claude/g-forge-docs-approved` exists. It should NOT exist (it is written by `/g-doc-review` on DOCS READY and auto-cleared by `post-commit-cleanup.sh` after each commit). A leftover sentinel means the doc-review gate is stuck open.
- Pass (file absent): ✓ No stale doc-approval sentinel
- Fail (file present): ✗ Stale doc-approval sentinel found
  → A stale doc-approval sentinel exists — the doc gate is stuck open. Delete it: `rm .claude/g-forge-docs-approved`

**11. PreCompact hook installed and registered**
Check if `.claude/hooks/pre-compact.sh` exists AND `.claude/settings.json` contains a `PreCompact` hook entry pointing to `pre-compact.sh`.
- Pass: ✓ PreCompact hook installed and registered
- Fail (file missing): ✗ PreCompact hook script missing
  → Run `/g-init` or `/g-update` to install pre-compact.sh.
- Fail (not registered): ✗ PreCompact hook not registered in settings.json
  → Run `/g-init` or `/g-update` to register the PreCompact hook.

**12. SessionStart hook installed and registered**
Check if `.claude/hooks/session-start.sh` exists AND `.claude/settings.json` contains a `SessionStart` hook entry pointing to `session-start.sh`.
- Pass: ✓ SessionStart hook installed and registered
- Fail (file missing): ✗ SessionStart hook script missing
  → Run `/g-init` or `/g-update` to install session-start.sh.
- Fail (not registered): ✗ SessionStart hook not registered in settings.json
  → Run `/g-init` or `/g-update` to register the SessionStart hook.

**13. observer hooks installed and registered**
Check if `.claude/hooks/observe.sh` exists AND `.claude/settings.json` contains a `PostToolUse` hook entry pointing to `observe.sh` AND a `SessionStart` hook entry pointing to `observe.sh`.
- Pass: ✓ Observer hook installed and registered
- Fail (file missing): ✗ Observer hook script missing
  → Run `/g-init` or `/g-update` to install observe.sh.
- Fail (not registered): ✗ Observer hook not registered in settings.json
  → Run `/g-init` or `/g-update` to register the PostToolUse + SessionStart observer hooks.

**14. agent lifecycle hooks installed and registered**
Check if `.claude/hooks/agent-lifecycle.sh` exists AND `.claude/settings.json` contains a `SubagentStart` hook entry AND a `SubagentStop` hook entry pointing to `agent-lifecycle.sh`.
- Pass: ✓ Agent lifecycle hook installed and registered
- Fail (file missing): ✗ Agent lifecycle hook script missing
  → Run `/g-init` or `/g-update` to install agent-lifecycle.sh.
- Fail (not registered): ✗ Agent lifecycle hook not registered in settings.json
  → Run `/g-init` or `/g-update` to register the SubagentStart + SubagentStop hooks.

**15. No duplicate / double-firing hook registration**
G-Forge hooks must be registered in exactly ONE place — `.claude/settings.json` — with one entry per script per event. A hook registered twice fires twice (the context-depth counter double-increments, the commit gate runs twice, the journal gets double entries). Check both ways it can happen:
- Read `.claude/settings.json`. For each G-Forge script (`check-commit.sh`, `post-commit-cleanup.sh`, `observe.sh`, `agent-lifecycle.sh`, `pre-compact.sh`, `session-start.sh`, `workflow-checkpoint.sh`), count the entries referencing it under the same event key. More than one is a duplicate.
- Read the plugin manifest `hooks/hooks.json` from the plugin cache (Glob `~/.claude/plugins/cache/g-forge/g-forge/*/hooks/hooks.json`). Its `hooks` object must be empty `{}`. If it registers any hook that is ALSO in `.claude/settings.json`, that hook double-fires — the manifest fires it globally in every session AND the project fires it.
- Pass: ✓ No duplicate hook registration (settings.json is the single registrar)
- Fail (in-settings duplicate): ✗ [script] registered [N]× under [Event] in settings.json — will double-fire
  → Run `/g-update` to de-duplicate, or delete the extra entr(y/ies) from `.claude/settings.json`.
- Fail (manifest + project): ✗ [script] registered by BOTH the plugin manifest and settings.json — double-fires every session
  → Update the plugin (`/g-update`, or reinstall) so the manifest registers no hooks; `.claude/settings.json` is the single registrar.

**16. Installed-copy drift**
The plugin source (`hooks/`) is the canonical copy of each hook script; `/g-init` and `/g-update` copy it into `.claude/hooks/`. If the installed copy drifts from the canonical source (e.g. a manual edit, or an update that didn't get re-synced), the project silently runs stale hook logic. For each of the 7 canonical hook scripts (`check-commit.sh`, `workflow-checkpoint.sh`, `post-commit-cleanup.sh`, `pre-compact.sh`, `session-start.sh`, `observe.sh`, `agent-lifecycle.sh`) in `hooks/` (plugin source), hash-compare against its installed counterpart in `.claude/hooks/`. Use a portable hash cascade — try `sha256sum`, fall back to `shasum -a 256`, fall back to `cksum`:
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
- Pass (per file): installed copy exists AND its hash matches the canonical source in `hooks/`.
- Pass (overall): ✓ Installed hooks match plugin source (no drift)
- Fail (per file): ✗ [script] installed copy differs from plugin source (drift)
  → Run `/g-update` to re-sync hooks/ into .claude/hooks/.

This check also covers two related canonical-vs-installed surfaces that hook drift can hide in — the shared `hooks/lib/` scripts, and the native git `pre-commit` hook:

- **`hooks/lib/` drift.** For each of the 4 canonical lib scripts (`commit-detect.sh`, `worktree-resolve.sh`, `classify-changeset.sh`, `sentinel-read.sh`) in `hooks/lib/` (plugin source), check for an installed counterpart at `.claude/hooks/lib/<file>` and hash-compare using the same `hash_file` cascade above.
  - Pass (per file): installed lib file exists AND its hash matches the canonical source in `hooks/lib/`.
  - Fail (missing): ✗ hooks/lib/[file] missing from installed copy (drift)
    → Run `/g-update` to re-sync hooks/ into .claude/hooks/.
  - Fail (hash mismatch, file present): ✗ hooks/lib/[file] installed copy differs from plugin source (drift)
    → Run `/g-update` to re-sync hooks/ into .claude/hooks/.

- **Native `pre-commit` git hook drift.** Resolve the installed git hooks directory with `git rev-parse --git-path hooks` (do not assume `.git/hooks` — it can be relocated, e.g. worktrees) and look for `<hooks-dir>/pre-commit`. Before comparing, check whether it is a G-Forge-managed pre-commit: read its first few lines for the literal marker `G-Forge commit gate`.
  - Pass: `<hooks-dir>/pre-commit` exists, carries the `G-Forge commit gate` marker, AND its hash matches the canonical `hooks/pre-commit` (same `hash_file` cascade).
  - Fail (missing): ✗ pre-commit missing from installed git hooks dir (drift)
    → Run `/g-update` to re-sync hooks/ into .claude/hooks/.
  - Fail (G-Forge pre-commit present but hash differs): ✗ pre-commit installed copy differs from plugin source (drift)
    → Run `/g-update` to re-sync hooks/ into .claude/hooks/.
  - Advisory, not a failure (marker absent — a foreign, non-G-Forge pre-commit occupies the slot; the /g-init·/g-update clobber guard preserves it rather than overwriting it): ⚠ foreign pre-commit present (gate not installed — advisory, run /g-update to see options)

This check also covers the g-rules section files and the `.claude/agents/` surface — agents differ from hooks/lib/rules in that not every installed agent has a byte-canonical source, so the three classes below get distinct pass/fail/advisory wording rather than one shared rule:

- **`g-rules` section-file drift.** For each of the 10 canonical g-rules section files in `rules/g-rules/` (plugin source), hash-compare against its installed counterpart in `.claude/rules/`, using the same flat-rename mapping CLAUDE.md's own `@` references use — `rules/g-rules/X-name.md` (source) → `.claude/rules/g-rules-X-name.md` (installed):
  - `rules/g-rules/A-session.md` → `.claude/rules/g-rules-A-session.md`
  - `rules/g-rules/B-workflow.md` → `.claude/rules/g-rules-B-workflow.md`
  - `rules/g-rules/C-agent-discipline.md` → `.claude/rules/g-rules-C-agent-discipline.md`
  - `rules/g-rules/D-code-quality.md` → `.claude/rules/g-rules-D-code-quality.md`
  - `rules/g-rules/E-architecture-gate.md` → `.claude/rules/g-rules-E-architecture-gate.md`
  - `rules/g-rules/F-design-patterns.md` → `.claude/rules/g-rules-F-design-patterns.md`
  - `rules/g-rules/G-documentation.md` → `.claude/rules/g-rules-G-documentation.md`
  - `rules/g-rules/H-testing.md` → `.claude/rules/g-rules-H-testing.md`
  - `rules/g-rules/I-project-tracking.md` → `.claude/rules/g-rules-I-project-tracking.md`
  - `rules/g-rules/J-memory.md` → `.claude/rules/g-rules-J-memory.md`
  - Pass (per file): installed copy exists AND its hash matches the canonical source in `rules/g-rules/` (same `hash_file` cascade above).
  - Fail (missing): ✗ g-rules-[X-name].md missing from installed copy (drift)
    → Run `/g-update` to re-sync rules/g-rules/ into .claude/rules/.
  - Fail (hash mismatch, file present): ✗ g-rules-[X-name].md installed copy differs from plugin source (drift)
    → Run `/g-update` to re-sync rules/g-rules/ into .claude/rules/.

- **Installed-agents drift.** `.claude/agents/` mixes three provenance classes. For each file found in `.claude/agents/`, classify it first, then apply that class's rule — never the same rule for all three:
  1. **Profile-copied** agents (e.g. `claude-plugin-architect.md`) — a byte-canonical source exists under `profiles/<stack>/agents/<name>.md`, installed verbatim by `/g-specialize`. Hash-compare using the `hash_file` cascade above.
     - Pass: ✓ [agent].md matches profile source (no drift)
     - Fail (hash mismatch): ✗ [agent].md installed copy differs from profile source (drift)
       → Run `/g-specialize` to re-sync the architect agent from its profile source.
     - Fail (canonical source missing, e.g. the profile that installed it was renamed or removed upstream): ✗ [agent].md has no matching profile source — cannot verify (drift)
       → Run `/g-update` to check for a renamed or removed profile.
  2. **Template-instantiated** agents (e.g. `claude-plugin-implementer.md`) — generated per-project by `/g-specialize` from `templates/stack-implementer.md` with per-stack substitutions ({{IMPLEMENTER_NAME}}, {{ARCHITECT_NAME}}, {{STACK_LABEL}}, etc.); no byte-canonical per-stack source exists to hash against. This class is advisory-only and must never Fail — it mirrors the foreign-pre-commit precedent above, where the absence of a comparable canonical copy rules out a hash-based verdict.
     - Advisory: ⚠ [agent].md is template-instantiated (no canonical source — not checked for drift)
  3. **Project-local** agents matching `*-dev.md` (e.g. `g-forge-dev.md`) are never shipped by the plugin and are excluded entirely from this check (zero drift output) — they are neither Pass, Fail, nor Advisory; skip them before classification even runs.

**17. CLAUDE.md architecture rules format** (advisory)
Read `CLAUDE.md`. For each `<!-- G-Forge [stack] Architecture Rules` block, count the non-empty lines between the opening and closing markers. If any block has more than 3 lines of content, it is using the legacy inline format.
- Pass: ✓ CLAUDE.md architecture rules compact (@reference format)
- Advisory: ⚠ CLAUDE.md has [N] inline architecture block(s) — legacy format
  → Run `/g-update` to extract inline rules to `.claude/rules/` and compact CLAUDE.md automatically.

**18. CLAUDE.md total size** (advisory)
Count the total lines in `CLAUDE.md`.
- Pass (≤150 lines): ✓ CLAUDE.md compact ([N] lines)
- Advisory (>150 lines): ⚠ CLAUDE.md is [N] lines — may contain inline rules content
  → Run `/g-update` to migrate inline rules to `.claude/rules/` files.

**19. No leftover legacy `g-team` plugin** (advisory)
G-Forge was formerly named `g-team`; the rename created a new plugin rather than replacing the old one, so a leftover `g-team` install duplicates every `/g-*` command. Check `~/.claude/plugins/cache/g-team` and any `"g-team"` entry in `~/.claude/plugins/config.json`.
- Pass (absent): ✓ No legacy g-team plugin — commands are g-forge only
- Advisory (present): ⚠ Legacy g-team plugin still installed — every /g-* command is duplicated
  → Remove it via `/plugin` → Installed → g-team → Uninstall (then re-run `/g-update`).

**20. `.gitignore` vets G-Forge artifacts** (advisory)
The `.gitignore` is the boundary between the project record (tracked) and runtime/dev artifacts (ignored). `/g-init` writes it; this check confirms it still holds. Read `.gitignore`.
- It must **ignore** the runtime artifacts: the commit-gate sentinels (`.claude/g-forge-approved`, `.claude/g-forge-docs-approved`), the observer journal (`.claude/journal/`), and the regenerable agent output (`g-docs/agent-output/`).
- It must **not ignore** anything tracked-by-design: `g-docs/ROADMAP.md`, `g-docs/todo.md`, `g-docs/milestones/`, `g-docs/decisions/`, `g-docs/retros/`, or `g-wiki/`. (Watch for over-broad bare patterns — e.g. a literal `todo.md` or `milestones/` line will wrongly ignore the `g-docs/` copies.)
- Pass: ✓ .gitignore vets G-Forge artifacts (runtime ignored, project record tracked)
- Advisory (missing): ⚠ No .gitignore — runtime artifacts (sentinels, journal, agent-output) may be committed
  → Run `/g-init` (Step 5a) to write the project `.gitignore`.
- Advisory (runtime not ignored): ⚠ .gitignore does not ignore [artifact] — it may be committed
  → Add the missing runtime-artifact pattern(s) (see `/g-init` Step 5a).
- Advisory (tracked path ignored): ⚠ .gitignore ignores [path] — project record won't be committed
  → Remove or scope the over-broad pattern so the `g-docs/` project record stays tracked.

**21. No stray G-Forge documents** (advisory)
Every G-Forge document belongs under `g-docs/` (project record) or `g-wiki/` (human-facing). This check finds strays that drifted elsewhere — usually tracking files left at the project root from before the `g-docs/` migration, or ADR/retro folders created in the wrong place. Look for:
- `ROADMAP.md`, `todo.md`, `todo-done.md`, or `project_brief.md` at the **project root** (canonical home is `g-docs/`).
- A `milestones/` directory at the **project root** (canonical home is `g-docs/milestones/`).
- `decisions/`, `retros/`, `forecasts/`, `telemetry/`, `blast-radius/`, or `alignment/` directories anywhere **outside** `g-docs/` (e.g. a root `decisions/`, or `docs/decisions/`).
```bash
# strays at root
for f in ROADMAP.md todo.md todo-done.md project_brief.md; do [ -f "$f" ] && echo "stray: $f"; done
[ -d milestones ] && echo "stray: milestones/"
# g-forge doc folders living outside g-docs/
find . -type d \( -name decisions -o -name retros -o -name forecasts -o -name telemetry -o -name blast-radius -o -name alignment \) \
  -not -path './g-docs/*' -not -path './.git/*' -not -path '*/node_modules/*' 2>/dev/null
```
- Pass (none found): ✓ No stray G-Forge documents — all tracking lives under g-docs/
- Advisory (strays found): ⚠ [N] stray G-Forge document(s) outside g-docs/: [list]
  → Move each into `g-docs/` preserving history, then re-run /g-doctor:
    `git mv ROADMAP.md g-docs/ROADMAP.md` · `git mv milestones g-docs/milestones` (etc.)
  → Offer to run the moves now. After moving, update any references with `/g-update`, and confirm nothing still points at the old root path.

**22. Roundtable security** (advisory — only when a Roundtable is bound)
Runs only if `.claude/roundtable` exists (the M33 Roundtable bind record). Guards the two failure modes from ADR-001's premortem: a leaked credential and a world-readable Doc.
```bash
[ -f .claude/roundtable ] || echo "no Roundtable bound — skip"
# (a) bind record + credentials must be gitignored, never committed
git check-ignore -q .claude/roundtable 2>/dev/null && echo "ignored ✓" || echo "TRACKED ✗"
git ls-files --error-unmatch .claude/roundtable >/dev/null 2>&1 && echo "COMMITTED ✗"
# (b) a token-looking line must never be in the bind record (token belongs in env)
grep -qiE '^(token|secret|password|api[_-]?key)=' .claude/roundtable 2>/dev/null && echo "SECRET-IN-BIND ✗"
```
- Pass: ✓ Roundtable security — bind record gitignored, no credential in it (confirm the Doc is link-restricted, not public)
- Advisory (bind record tracked/committed): ⚠ `.claude/roundtable` is tracked — the bound surface ref (and any creds near it) could be pushed
  → Add `.claude/` to `.gitignore` (it should already be — see Check 19) and `git rm --cached .claude/roundtable`.
- Advisory (secret in bind record): 🔴 A credential is stored in `.claude/roundtable` — move it to an environment variable and remove the line. Never commit a token.
- Advisory (always, reminder): the bound Doc must be **link-restricted, never public** — `/g-roundtable` enforces this at bind, but confirm sharing hasn't been widened since.

**Note:** Milestone alignment is no longer a numbered check — it is contextual and covered by `/g-status`. Doctor focuses on hook, rules, and document-layout infrastructure only.

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
  [✓/✗ line for check 15]
    [→ fix instruction if failed]
  [✓/✗ line for check 16]
    [→ fix instruction if failed]

  Advisory
  [✓/⚠ line for check 17]
    [→ fix instruction if advisory]
  [✓/⚠ line for check 18]
    [→ fix instruction if advisory]
  [✓/⚠ line for check 19]
    [→ fix instruction if advisory]
  [✓/⚠ line for check 20]
    [→ fix instruction if advisory]
  [✓/⚠ line for check 21]
    [→ fix instruction if advisory]
  [✓/⚠ line for check 22]
    [→ fix instruction if advisory]
────────────────────────────────────────────────
[N/16 required checks passed]
```

Fix instructions are indented with four spaces and prefixed with `→ `, and appear only on failing or advisory checks.

After the summary count line, add one blank line, then:
- If all 16 required checks passed and no advisories: `All checks passed. Project is healthy.`
- If all 16 required checks passed but advisories exist: `Required checks passed. Address advisories above to keep CLAUDE.md compact and the document layout clean.`
- If any required check failed: `Fix the issues above, then re-run /g-doctor.`
