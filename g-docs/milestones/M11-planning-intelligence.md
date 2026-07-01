# M11 — Planning Intelligence

**Status:** ✅ Complete
**Version:** v0.12.0
**Branch:** feat/m11-planning-intelligence

## Goal

Make planning forward-looking. `/g-plan` is solid at decomposing tasks but it has no opinion on whether the plan is realistic. M11 adds a complexity score, a quantified miss-risk percentage, and a premortem seeded by `/g-patterns` history — so the developer sees where the plan is most likely to fail before approving it. A milestone-health line is added to the workflow checkpoint so in-flight signals (blockers, rework) surface continuously, not only at retro time.

## Scope

### 1 — `/g-forecast` skill

New maintenance skill. Inputs: the current plan (in-memory from `/g-plan` or a saved plan file). Outputs: complexity score (0–10), miss-risk percentage with risk tag (Low / Moderate / Elevated / High), and a ranked premortem of the top 5 failure scenarios. Each scenario carries likelihood × impact, a concrete mitigation, and a source citation back to the retros or git history that surfaced the pattern.

**Done condition:** `skills/g-forecast/SKILL.md` exists with frontmatter, Announce, numbered steps, Rules; running `/g-forecast <plan-slug>` produces the structured report and writes `docs/forecasts/<plan-slug>.md`.

---

### 2 — Premortem wired into `/g-forecast`, seeded by `/g-patterns` corpus

Premortem is not a separate skill — it is Steps 3–6 of `/g-forecast`. The same retro corpus and `docs/patterns-deferred.md` that `/g-patterns` reads is the seed for predicted failure scenarios. Each prediction cites its source.

**Done condition:** `/g-forecast` reads the same sources as `/g-patterns`, applies the same `None recorded.` sentinel filter, and emits at least one scenario when corpus has any signal; on cold-start corpus, emits a single `cold-start — no history yet` scenario with low confidence.

---

### 3 — Feedback loop closed: `/g-patterns` → `/g-forecast` → `/g-retro` → `/g-patterns`

`/g-forecast` writes its premortem to `docs/forecasts/<plan-slug>.md` with an intentionally empty `Outcome` table. `/g-retro` is updated to ask one new question after the patterns interview: "Did any of the predicted premortem scenarios actually happen?" and fills in the Outcome table. `/g-patterns` reads `docs/forecasts/*.md` as an additional signal source — predicted-and-hit scenarios become high-confidence systemic patterns.

**Done condition:** `/g-retro` includes the premortem-accuracy question in its interview when a forecast file exists for the current plan; `/g-patterns` Step 1 reads `docs/forecasts/` as a signal source; both behaviours documented in their respective SKILL.md files.

---

### 4 — Milestone health live monitoring in `workflow-checkpoint.sh`

Extend the existing `UserPromptSubmit` hook to emit a one-line milestone-health signal on every prompt. The line reports: count of revert/fix-of-fix commits on the current branch since `main`, presence of `BLOCKED` markers in `todo.md` or active plan file, and number of HOLD verdicts encountered this session (best-effort — counted from `.claude/review-holds` if the file exists).

Output line format:
```
  Health: ✓ clean   (or: ⚠ N rework commits · M blocked · K holds)
```

**Done condition:** `hooks/workflow-checkpoint.sh` emits the Health line on every prompt; the line shows `✓ clean` when there are no signals; counts increment as rework commits land on the branch.

---

## Done Conditions (milestone)

- [x] `skills/g-forecast/SKILL.md` exists with frontmatter (`context:` declared), Announce line, numbered Steps 1–9, Rules section
- [x] `commands/g-forecast.md` exists and routes to SKILL.md
- [x] `/g-forecast` registered in `commands/g-team.md` router and in `G-RULES.md` §B maintenance table
- [x] `skills/g-plan/SKILL.md` updated — Step 3a writes pending-forecast handoff; Step 3b calls `/g-forecast`; Step 4 cleans up handoff
- [x] `skills/g-retro/SKILL.md` updated — premortem-accuracy question added with deterministic plan-slug derivation
- [x] `skills/g-patterns/SKILL.md` updated — Step 1 reads `docs/forecasts/*.md`; Step 2d ingests outcomes with weighting; Step 3 consumes the weight
- [x] `hooks/workflow-checkpoint.sh` emits the Health line; reads stdin payload; numeric counters sanitised via `to_int`
- [x] `plugin.json` and `marketplace.json` at v0.12.0; skill count 25
- [x] CHANGELOG `[0.12.0]` entry added
- [x] README skill list, command reference, skill count, and roadmap table reflect M11 + `/g-forecast`
- [x] M11 marked ✅ Complete in ROADMAP.md

## Tier 3 DoD

Developer runs `/g-forecast m10-organizational-learning-loop` (a closed plan with history). The skill produces a forecast report with: a complexity score, a miss-risk percentage with risk tag, at least one premortem scenario seeded from the M9/M10 retros, and a persisted `docs/forecasts/m10-organizational-learning-loop.md` file. The next time `/g-patterns` runs, it reads the forecasts directory and references it.

Workflow checkpoint emits the Health line on the next prompt after at least one revert/fix commit is on the branch.

## Depends on

M10 (complete) — `/g-patterns` corpus mining and `docs/patterns-deferred.md` format are the seeds for premortem.
