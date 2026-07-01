# M10 — Organizational Learning Loop

**Status:** ✅ Complete
**Version:** v0.11.0
**Branch:** feat/m10-organizational-learning-loop

## Goal

G-Forge detects recurring failure patterns across session history and proposes self-corrections to its own profile and rules. The system becomes auditable: every milestone leaves a retro, retros accumulate into a corpus, and a skill mines that corpus for systemic failure modes — surfacing them as concrete rule edits, not abstract reports.

## Scope

### 1 — `/g-patterns` skill

A maintenance skill that mines `docs/retros/` (every retro's `Patterns → Avoid / do differently` section) and `todo-done.md` (rework markers, revert chains, repeated bug classes) for recurring failure modes. Output is a systemic-health report grouped by frequency:

- ✓ **Isolated** — pattern observed once
- ⚠ **Emerging** — pattern observed twice
- ✗ **Systemic** — pattern observed ≥3 times

Patterns are attributed to the retro filenames that surfaced them, so traceability is preserved.

**Done condition:** running `/g-patterns` on this repo produces a non-empty report listing every pattern across all retros and todo-done entries, with frequency bucket and source citations.

---

### 2 — Self-evolution: rule-edit suggestions

For every pattern at the **Emerging** (≥2) or **Systemic** (≥3) tier, the skill maps the failure mode to a candidate fix location:

- `G-RULES.md` (sections A–I) — for cross-cutting discipline failures
- `.claude/rules/architecture-<stack>.md` — for stack-specific drift
- An installed agent's system prompt — for agent-behaviour failures
- A skill's `## Rules` section — for workflow guard failures

The skill proposes a concrete edit (specific section, specific wording) for each ≥2-occurrence pattern. The developer picks: **apply** (skill edits the file), **defer** (logged for next pass), or **dismiss** (no action). No edit is ever auto-applied.

**Done condition:** for any pattern at ≥2 frequency, the skill prints a specific proposed edit naming the target file, target section, and exact text to add or change.

---

## Done Conditions (milestone)

- [x] `skills/g-patterns/SKILL.md` exists with frontmatter, Announce line, numbered steps, and Rules section
- [x] `commands/g-patterns.md` exists and routes to the SKILL.md
- [x] `/g-patterns` registered in `commands/g-team.md` router and in `G-RULES.md` Section B maintenance table
- [ ] Running `/g-patterns` on this repo produces a non-empty report with at least one pattern detected (deferred — verified at Tier 3 by developer)
- [ ] For any ≥2-occurrence pattern, the report includes a concrete proposed rule edit (deferred — verified at Tier 3)
- [x] `plugin.json` and `marketplace.json` both at v0.11.0
- [x] CHANGELOG entry for [0.11.0] added
- [x] README skill list and roadmap table updated to reflect M10 and `/g-patterns`
- [x] M10 status marked ✅ Complete in ROADMAP.md

## Tier 3 DoD

Developer runs `/g-patterns` interactively on this repo. The skill produces a readable report that:
1. Cites at least one source retro by filename
2. Buckets patterns by frequency
3. For any pattern at ≥2 occurrences, names a specific target file and proposed edit
4. Asks for apply/defer/dismiss per suggestion

Acceptable if the corpus only surfaces isolated patterns — the report must still print, and the apply/defer/dismiss prompt is only required when ≥2-frequency patterns exist.

**Empty-corpus case:** if `docs/retros/` is empty, `todo-done.md` is missing, and git history is shorter than 10 commits, `/g-patterns` correctly stops with the "corpus too thin" message — that is a pass for the empty case, not a failure. On a fresh project, the skill is expected to bail until enough history accumulates.

## Depends on

M9 (complete) — memory taxonomy and context profiles in place so the skill can declare its memory tier needs.
