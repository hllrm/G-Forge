---
name: g-patterns
description: Mine docs/retros/ and todo-done.md for recurring failure patterns. Surface a systemic-health report bucketed by frequency and propose concrete profile-rule edits for any pattern observed ≥2 times.
context: [sprint, institutional, architectural]
---

**Announce:** "Using g-patterns to mine recurring patterns from session history."

You are running an organisational-learning pass: read every retro and the closed-task archive, group recurring failure modes, surface what is systemic, and propose concrete rule-edits the developer can apply, defer, or dismiss.

## Step 1 — Gather inputs

Read in parallel:

- All files in `docs/retros/` — every `.md` file
- All files in `docs/forecasts/` if the directory exists — used in Step 2e for forecast-outcome mining (closes the loop with `/g-forecast` and `/g-retro`)
- `todo-done.md` — the full file if it exists (optional source)
- `G-RULES.md` — full file (needed in Step 4 for edit-target mapping)
- `git log --oneline -100` via Bash — used in Step 2 to detect rework commits
- The list of installed architecture rules: `Glob .claude/rules/architecture-*.md`
- The list of installed agents: `Glob .claude/agents/*.md`

If `docs/retros/` is empty or missing AND `todo-done.md` is missing AND the git log is shorter than 10 commits:
```
✗ Corpus too thin to mine patterns. Run /g-retro at the end of sessions and accumulate
  closed tasks in todo-done.md to build the corpus.
```
Stop.

If `docs/retros/` is empty but `todo-done.md` exists or git history is non-trivial, continue — the skill operates on whatever corpus is available and notes the gap in the report.

## Step 2 — Extract failure-mode signals

### 2a — Retro signals

From each retro, extract every bullet under:
- `## Patterns → ### Avoid / do differently`
- `## Patterns → ### Worked well` (positive signals — kept for the report but never produce rule edits)

**Sentinel filter:** discard any bullet whose verbatim text is one of `None recorded.`, `None.`, `(none)`, an empty bullet, or a section that contains only such placeholders. These are explicit "no signal" markers written by `/g-retro` when the developer answered "none" — they must never become pattern candidates.

For each surviving bullet, record:
- Source retro filename
- Verbatim text
- A short normalised label (3–6 words) capturing the failure class — e.g. `commit-without-tests`, `mocked-db-divergence`, `wave-split-across-messages`, `agent-given-write-tool`

### 2b — todo-done signals (optional, only if file present and parseable)

If `todo-done.md` exists, scan for the following concrete signals:
- **Duplicate task titles** — two or more closed task entries whose titles share ≥3 normalised tokens (e.g. both contain "fix login redirect")
- **Repeated file targets** — the same file path appearing in ≥3 closed-task entries within a 30-entry window

If `todo-done.md` exists but follows no parseable structure (free-form prose), note `todo-done.md present but unstructured — skipped` in the report and move on. Never invent signals from unstructured text.

### 2c — Git-log signals

Scan the git log gathered in Step 1 for rework commit markers:
- Commit subjects matching (case-insensitive) `^revert:`, `^fix-of-fix`, `take 2`, `retry`, `another attempt`, `^revert "`, `re-do`
- Commits that revert a commit from the same branch within the same 20-commit window

For each match, record: commit short SHA, subject, and a normalised label derived from the reverted change's subject.

### 2d — Forecast-outcome signals (if `docs/forecasts/` exists)

For each forecast file, read the `## Outcome` table populated by `/g-retro`. A row marked `Actually happened? = yes` is a **predicted-and-hit** signal — it is a high-confidence pattern because both the premortem and the retro confirmed it. A row marked `partial` is a medium-confidence signal. Rows marked `no` are negative evidence and are not patterns — discard them.

For each `yes` or `partial` row, record a signal with `source_kind = forecast`, the scenario label, and the forecast filename as `source_id`. Confidence weight: `yes` counts as weight 2 (since both prediction and reality confirmed it), `partial` counts as weight 1.

### 2e — Output of Step 2

The output of this step is a single flat list of signal records, each with: `{source_kind, source_id, verbatim, label, weight}` where `source_kind` is one of `retro` / `todo-done` / `git-log` / `forecast`. `weight` defaults to 1; forecast `yes` rows are weight 2, forecast `partial` rows are weight 1. This flat list is the input to Step 3 — bucketing consumes the `weight` field, not raw signal count.

## Step 3 — Bucket by frequency

Group all extracted signals by their normalised label. For each group, compute its weighted count: sum the `weight` field of every signal in the group, treating distinct source files as distinct contributions (two signals from the same source file collapse to one — count by source, weighted). Forecast `yes` signals contribute weight 2, forecast `partial` signals contribute weight 1, and all other source kinds contribute weight 1. This boosts patterns that were both predicted and observed (forecast `yes`) into the Systemic bucket faster than corpus-only signals.

Bucket by weighted count:

| Count | Bucket | Symbol |
|------|--------|--------|
| 1 | Isolated | ✓ |
| 2 | Emerging | ⚠ |
| ≥3 | Systemic | ✗ |

Patterns from `Worked well` go into a separate **Reinforced patterns** bucket — they are never proposed for rule edits, only surfaced as positive signals. Reinforced patterns are listed without frequency filtering: every distinct `Worked well` bullet appears in the report regardless of count, since positive signals reinforce regardless of recurrence.

## Step 4 — Map ≥2-frequency patterns to fix locations

For every pattern in the Emerging or Systemic bucket, determine the most appropriate fix target. Choose from:

| Pattern class | Likely target |
|---------------|---------------|
| Cross-cutting discipline failure (planning, review gate, commit flow, agent dispatch) | `G-RULES.md` — name the section letter |
| Stack-specific drift (layer boundary, import direction, framework idiom) | `.claude/rules/architecture-<stack>.md` if installed; otherwise flag as "no stack profile installed — install via `/g-specialize`" |
| Agent behaviour (wrong tool used, scope creep, missing output) | The specific agent's system prompt in `.claude/agents/<agent>.md` |
| Workflow guard failure (skill skipped step, missed gate) | The specific skill's `## Rules` section |

For each Emerging/Systemic pattern, draft a concrete proposed edit:
- Target file path
- Target section heading (where to insert/modify)
- Exact text to add or replace (one to three lines max, in the style of existing rules)
- One-line rationale citing the source retros

If a pattern has no clear fix target, mark it `Needs human judgment — flagged for review` and do not propose an edit.

## Step 5 — Print systemic-health report

Output exactly this structure:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
G-FORGE SYSTEMIC HEALTH — [YYYY-MM-DD]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Corpus: [N retros] · [M todo-done entries] · [C CHANGELOG versions]

✗ Systemic patterns (≥3 occurrences)
  [for each: label · count · source filenames · proposed edit summary]

⚠ Emerging patterns (2 occurrences)
  [for each: label · count · source filenames · proposed edit summary]

✓ Isolated observations (1 occurrence)
  [compact list: label · source filename — no edit proposed]

★ Reinforced patterns (worked well)
  [compact list: label · source filename]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If no patterns reach ≥2 frequency, state explicitly:
```
No emerging or systemic patterns detected. Corpus may be too small or signals too varied.
Continue running /g-retro at milestone close to build the corpus.
```

## Step 6 — Offer apply/defer/dismiss per ≥2-frequency edit

For each proposed edit in the Emerging and Systemic buckets, present:

```
Pattern: [label] · Bucket: [⚠ Emerging / ✗ Systemic] · Sources: [filenames]

Proposed edit:
  File:    [target path]
  Section: [target heading]
  Change:  [exact text to add or replace]
  Why:     [one-line rationale]

apply / defer / dismiss?
```

Wait for the developer's choice.

- **apply** — read the target file, locate the target section, perform the edit, confirm written. Step 4 will already have flagged missing target files (e.g. no stack profile installed) and marked those patterns `Needs human judgment`, so by Step 6 the target file is guaranteed to exist.
- **defer** — log the suggestion to `docs/patterns-deferred.md` (append; create file if missing) with date, pattern label, target, and proposed change. Move on.
- **dismiss** — no action. Note in the session output that the developer dismissed the pattern.

Continue until every Emerging/Systemic pattern has been triaged. Isolated patterns and Reinforced patterns are surfaced only — no triage prompt.

## Step 7 — Final summary

After triage, print a one-block summary:

```
PATTERN MINING COMPLETE

Applied:   [count] edits to [list of files touched]
Deferred:  [count] entries logged to docs/patterns-deferred.md
Dismissed: [count]

Next:      [if any edits were applied] Review the changes, run /g-review before commit.
           [else] No file changes — corpus snapshot recorded for next pass.
```

If any rule files were edited, leave the working tree as-is — never commit from inside this skill. The developer runs `/g-review` and commits when ready.

## Rules

- Read-only on `docs/retros/`, `todo-done.md`, and `CHANGELOG.md` — these are historical records and must never be modified by this skill
- Never auto-apply an edit — every proposed change requires explicit `apply` from the developer
- Never propose edits to G-RULES.md sections A–I core rules without surfacing them clearly as cross-cutting changes; favour stack rules and agent prompts first
- Always cite source retros by filename in the proposed edit's rationale — traceability is the whole point
- One retro counts as one source even if multiple bullets in that retro map to the same pattern label — count by distinct source file, not by raw bullet count
- If `docs/retros/` is empty, stop immediately and instruct the developer to build the corpus via `/g-retro` — never fabricate patterns from a thin corpus
- Reinforced patterns (worked well) are surfaced but never converted to rule edits — they are evidence of healthy behaviour, not a defect to fix
- When multiple ≥2-frequency patterns target the same file, present them one at a time and let the developer triage each independently — never batch-apply
