---
name: g-trim
description: Use proactively once a week. Audits CLAUDE.md and agent memory files for bloat, orphaned references, duplicate rules, and stale content. Proposes a compact trim with user approval. Writes .claude/last-trim on completion.
---

**Announce:** "Using g-trim to run the weekly optimization pass."

You are auditing CLAUDE.md and agent memory for bloat and stale content. Read first, propose second, act only on approval. Do not modify any file until the developer confirms.

## Step 1 — Audit CLAUDE.md

Read `CLAUDE.md`. Check for:

1. **Orphaned @references** — Glob each `@path` target to verify it exists on disk. List any that point to missing files.
2. **Duplicate rules** — rules that appear both inline in CLAUDE.md and inside a referenced file (e.g. a rule already in a G-RULES section or an architecture rules file). Flag exact duplications.
3. **Stale project details** — outdated stack descriptions, obsolete technology mentions, references to removed features. Use `project_brief.md` and current dependency files as ground truth.
4. **Sparse sections** — sections ≤3 lines that could be merged into a neighbour without losing meaning.

Produce a compact audit table:

| Issue | Location | Proposed action |
|-------|----------|-----------------|
| Orphaned @reference | Line N: `@missing-file.md` | Remove |
| Duplicate rule | Lines N–M | Remove from CLAUDE.md (canonical copy in G-RULES) |
| Stale mention | Line N | Update to [new value] or remove |

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
| Issue | Line | Proposed action |
|-------|------|-----------------|
| Dead ref | N | Remove |
| Duplicate | N, M | Merge |
| Moot | N | Remove |

If nothing found: `✓ Clean`.

## Step 3 — Confirm with developer

Present the full findings. If nothing was found:
```
✓ CLAUDE.md — clean
✓ Agent memory — all clean
Nothing to trim. Next check in 7 days.
```

If issues were found, present the summary and ask:
> "Apply these changes? (y/n) — or list the numbers you want to skip."

Wait for confirmation before touching any file.

## Step 4 — Apply approved changes

For each approved change, use Edit with precise `old_string` → `new_string`. After each edit, confirm the change landed.

## Step 5 — Record completion

Write today's date (`YYYY-MM-DD`) to `.claude/last-trim`.

Report:
```
g-trim complete ✓

  CLAUDE.md:    N changes applied
  Agent memory: N changes across M agents
  Next trim:    [date + 7 days]
```

## Rules
- Never delete a rule or memory entry without developer confirmation.
- If a rule exists in both CLAUDE.md inline and a G-RULES section file, remove it from CLAUDE.md — the G-RULES file is authoritative.
- If MEMORY.md exceeds 200 lines, flag it but do not auto-truncate — the developer curates it manually.
- Do not touch `.claude/rules/architecture-*.md` or `.claude/rules/g-rules-*.md` — those are managed by `/g-specialize` and `/g-update`.
