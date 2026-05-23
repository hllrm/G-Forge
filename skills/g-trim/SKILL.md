---
name: g-trim
description: Use proactively once a week. Read-only audit of CLAUDE.md and agent memory for bloat, orphaned references, duplicate rules, and stale content. Reports issues for human review — never modifies any file. Writes .claude/last-trim on completion.
---

**Announce:** "Using g-trim to run the weekly optimization audit."

You are auditing CLAUDE.md and agent memory for issues. This skill is **read-only**. You report findings; the developer decides what to act on. Do not edit, delete, or modify any file.

## Step 1 — Audit CLAUDE.md

Read `CLAUDE.md`. Check for:

1. **Orphaned @references** — Glob each `@path` target to verify it exists on disk. List any that point to missing files.
2. **Duplicate rules** — rules that appear both inline in CLAUDE.md and inside a referenced file (e.g. a rule already in a G-RULES section or an architecture rules file). Flag exact duplications.
3. **Stale project details** — outdated stack descriptions, obsolete technology mentions, references to removed features. Use `project_brief.md` and current dependency files as ground truth.
4. **Sparse sections** — sections ≤3 lines that could be merged into a neighbour without losing meaning.

Produce a compact audit table:

| # | Issue | Location | Recommendation |
|---|-------|----------|----------------|
| 1 | Orphaned @reference | Line N: `@missing-file.md` | Verify file path or remove reference |
| 2 | Duplicate rule | Lines N–M | Consider removing (canonical copy in G-RULES) |
| 3 | Stale mention | Line N | Consider updating to [new value] |

## Step 2 — Audit agent memory

Glob for `.claude/agent-memory/*/MEMORY.md` and `.claude/agent-memory-local/*/MEMORY.md`. For each non-empty file found:

1. Read the first 200 lines.
2. Check for:
   - **Dead file references** — `file:line` paths that no longer exist on disk (Glob to verify each).
   - **Duplicate entries** — the same pattern or finding stated more than once.
   - **Moot entries** — observations about code that has since been removed or replaced.
   - **Overlong** — MEMORY.md at or above 200 lines. Flag for manual curation.

Produce a per-agent table:

**Agent: [name]**
| # | Issue | Line | Recommendation |
|---|-------|------|----------------|
| 1 | Dead ref | N | Verify or remove manually |
| 2 | Duplicate | N, M | Consider merging manually |
| 3 | Moot | N | Consider removing manually |

If nothing found: `✓ Clean`.

## Step 3 — Record completion

Write today's date (`YYYY-MM-DD`) to `.claude/last-trim`. This is the only file write this skill performs.

Report:

```
g-trim audit complete ✓

  CLAUDE.md:    N issues found
  Agent memory: N issues across M agents
  Next audit:   [date + 7 days]

No files were modified. Review the findings above and apply any changes manually.
```

If no issues were found:
```
✓ CLAUDE.md — clean
✓ Agent memory — all clean
Nothing flagged. Next audit in 7 days.
```

## Rules

- **Never modify, edit, or delete any file.** This skill is read-only.
- The only write operation permitted is `.claude/last-trim` (the audit timestamp).
- Do not touch `.claude/rules/architecture-*.md` or `.claude/rules/g-rules-*.md`.
- If MEMORY.md exceeds 200 lines, flag it — the developer curates it manually.
- Present findings as observations for the developer to act on, never as automated actions.
