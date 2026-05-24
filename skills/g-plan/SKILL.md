---
name: g-plan
description: Decompose the current request into atomic tasks and produce a parallel wave schedule. Runs task-decomposer then wave-planner. Use at the start of any multi-step implementation.
context: [task, sprint, architectural]
---

**Announce:** "Using g-plan to decompose and schedule the task."

You are driving the planning phase. Execute these steps in order.

## Step 0a — Identify the task

Determine what is being planned before asking anything else:

1. **Check the triggering message.** If the developer's message describes a task, feature, or bug fix — use that. No question needed.
2. **If the message is just `/g-plan` with no description:** Read `ROADMAP.md` and `todo.md` (if present) to find the active milestone and next task.
   - If one active item is clearly next: announce "Planning: [item]" and proceed — do not ask.
   - If multiple items are equally valid: ask one specific question: "Should I plan [X] or [Y]?" Never ask an open-ended "what do you want to plan?"
3. **Proceed.** Once the task is established, continue to Step 0. Do not ask the developer to confirm what is already clear from context.

## Step 0 — Tier 3 DoD prerequisite

Ask the developer: "Does this project have a QA panel or structured manual test UI?"

**If yes:** Ask which groups or areas are impacted by this milestone's changes. Then ask what passing looks like for each in-scope group. Compile a QA scope document at `docs/qa-scope/<milestone-slug>.md` using the schema in the **QA Scope Format** section below. This becomes the Tier 3 DoD for the milestone.

**If no:** Ask the developer to state the Tier 3 DoD for this milestone in one or two sentences. Record it in the plan header under `> Tier 3 DoD:`.

Do not proceed to Step 1 until a Tier 3 DoD is defined and written down.

## Step 1 — Challenge the request (feature requests only)

**Skip this step entirely if the request is a bug fix or a refactor of existing behaviour (not a new capability) — go straight to Step 2.**

Dispatch the `project-manager` agent with the full feature request as described by the developer.

Tell project-manager:
> "A developer wants to build the following: [feature request]. Apply your Feature Challenge gate. Ask the three challenge questions, wait for the developer's answers, then return one of: SCOPE ACCEPTED — [one-line summary], or SCOPE CONCERN — [reason] — DEVELOPER OVERRIDE."

Present project-manager's questions to the developer verbatim. Wait for the developer's answers. Pass the answers back to project-manager to get its verdict.

- **If verdict is SCOPE ACCEPTED:** proceed to Step 2.
- **If verdict is SCOPE CONCERN — DEVELOPER OVERRIDE:** note the concern in the plan header as a risk, then proceed to Step 2.

## Step 2 — Dispatch task-decomposer

Dispatch the `task-decomposer` agent. Provide:
- The full feature request or task description
- Any known file paths or constraints
- Any done conditions already specified
- Whether the project has a QA panel (from Step 0) — if yes, instruct task-decomposer that any task adding or changing user-facing surface must include "QA panel updated" as an explicit done condition

Wait for the task list before proceeding. Do not proceed if task-decomposer returns any "Clarify:" items — resolve those with the developer first.

## Step 2a — Dependency scan for planned additions

Scan the task list returned by task-decomposer for any task that explicitly mentions installing, adding, or integrating a new external package or library — e.g. "add Stripe SDK", "install redis-py", "integrate the OpenAI client", "add [package name] dependency".

If any such tasks are found, dispatch `dependency-auditor` **in parallel with Step 3** (wave-planner dispatch). Provide it the identified package names and the project stack context.

If dependency-auditor returns any HIGH severity findings for a planned new package:
- Add a `⚠ Dependency risk: [package] — [issue]` line to the plan header before the wave schedule
- The developer sees this in the Step 4 approval gate alongside the wave schedule and forecast
- If the developer approves despite the warning, record it as an accepted risk in the plan file header

MEDIUM and LOW findings are included in the plan header as notes — informational, never blocking.

If no tasks mention new packages, skip silently.

## Step 3 — Dispatch wave-planner

Dispatch the `wave-planner` agent with the complete task list from task-decomposer.

Wait for the wave schedule before proceeding.

## Step 3c — Context budget check

Estimate whether this plan fits within the remaining session context budget.

**Calculate estimated cost in exchanges:**

```
base              = 5    (plan/review infrastructure constant)
per wave          = 3    (dispatch + result collection)
per agent         = 2    (each agent slot across all waves)
per task          = 1    (file reads, edits, and tool calls per task)

estimated = 5 + (wave_count × 3) + (total_agent_slots × 2) + (task_count × 1)
```

Use the wave schedule from Step 3 for `wave_count` and `total_agent_slots`. Use the task list from Step 2 for `task_count`.

**Read remaining budget:**

Read `.claude/session-prompt-count` for the current depth. Once a plan is executing, the session is always `implementation` mode → red threshold = 40. `remaining = 40 − current_depth`.

**Evaluate:**

- `estimated ≤ remaining × 0.8` → budget fine. Add `> Cost estimate: ~[N] exchanges` to the plan header and proceed to Step 3a.
- `estimated > remaining × 0.8` and `estimated ≤ remaining × 1.2` → tight fit. Add `> ⚠ Cost estimate: ~[N] exchanges (~[remaining] remaining — tight)` to the plan header. Warn the developer in Step 4 but proceed.
- `estimated > remaining × 1.2` → plan exceeds budget. Stop. Do not proceed to Step 3a. Present:

```
⚠ Context budget exceeded

  Estimated cost:   ~[N] exchanges
  Remaining budget: ~[M] exchanges  (red threshold 40 − current depth [C])
  Shortfall:        ~[N−M] exchanges

  Running this plan would push the session into red mid-execution,
  forcing an incomplete-wave handoff.

  Options:
  1. Split — invoke /g-roadmap to break this milestone into
     sub-milestones that each fit within ~[floor(M × 0.7)] exchanges.
  2. Proceed — accept the mid-plan handoff risk. Execution will pause
     at red and require a fresh session to resume incomplete waves.

  Which would you prefer?
```

**If the developer chooses option 1:**

Use Glob to find `skills/g-roadmap/SKILL.md` inside `~/.claude/plugins/cache/g-team/g-team/` and read it. Run `/g-roadmap` with the following framing passed as context:

> "The current milestone task list is [task list]. The session context budget is ~[M] exchanges per sub-milestone. Split this milestone into sub-milestones where each sub-milestone's estimated cost (base 5 + waves×3 + agents×2 + tasks×1) does not exceed [floor(M × 0.7)] exchanges. Produce a revised ROADMAP.md with the sub-milestones sequenced in dependency order."

After `/g-roadmap` completes, stop the current `/g-plan` run. Tell the developer: "ROADMAP.md updated with sub-milestones. Run /g-plan on the first sub-milestone to begin."

**If the developer chooses option 2:**

Add `> ⚠ Risk: estimated ~[N] exchanges exceeds session budget — mid-plan handoff likely` to the plan header. Proceed to Step 3d.

## Step 3d — Wave dependency validation

Before writing the forecast handoff, validate that the wave schedule is internally safe to execute. Run these three checks using Glob, Grep, and Read — do not dispatch an agent for this.

### Check 1 — Same-wave file conflicts

For each wave, compare the `Files in scope` lists across all tasks in that wave. If two tasks in the same wave declare the same file, they would run in parallel and write to the same file simultaneously.

Flag each collision:
```
⚠ Parallel write conflict — Wave [N]: [Task A] and [Task B] both scope [file]
```

For each collision, ask wave-planner to split the conflicting tasks into sequential waves. Do not proceed to Step 3a until wave-planner has revised the schedule and the conflict is resolved.

### Check 2 — Missing source files for mutation tasks

For each task whose description contains an action word that implies an existing file (`update`, `modify`, `extend`, `refactor`, `fix`, `edit`, `change`), use Glob to verify the scoped files exist on disk.

If a scoped file does not exist:

- **If an earlier wave in the schedule creates it** (task description contains `create`, `generate`, `scaffold`, `add`, `write`, or `init` for that filename) — ordering is correct, no action.
- **If no earlier wave creates it** — flag as a blocker:
  ```
  ✗ Missing source — [task name]: [file] does not exist and no prior wave creates it
  ```

Blockers must be resolved before proceeding. Present them to the developer with two options: (a) add a prerequisite task to the wave schedule, or (b) confirm the file will exist at execution time (developer override — recorded in plan header as accepted risk).

### Check 3 — Cross-wave output dependency ordering

For tasks that reference another task's output by name or file path in their description (e.g. "using the schema generated in the previous task", "after [task name] completes"), verify the referenced task is in an earlier wave. If it is in the same wave or a later wave, flag it:
```
⚠ Ordering risk — [task name] references output from [other task] but both are in Wave [N]
```

Surface ordering risks to wave-planner for a schedule revision. These are not hard blockers — if the developer is confident the tasks are independent, they may override.

### Validation summary

After all three checks, report inline:

```
Wave dependency check:
  ✓ No parallel write conflicts
  ✓ All source files present (or creation-ordered)
  ✓ No cross-wave ordering violations

  — or —

  ✗ [N] blocker(s) — listed above. Resolve before proceeding.
  ⚠ [M] warning(s) — listed above. Carried forward to approval gate.
```

Blockers halt the plan. Warnings are included in the Step 4 approval gate under a `### Dependency risks` line so the developer sees them before approving.

Once all blockers are resolved (either fixed or explicitly overridden), proceed to Step 3a.

## Step 3a — Write the pending-forecast handoff

Before invoking `/g-forecast`, write the in-memory task list and wave schedule to `docs/plans/.pending-forecast.md` using the same Plan File Format defined later in this skill. This is a temporary handoff file — `/g-forecast` Step 1 reads it preferentially when present, so the forecast targets *this* plan (which has not yet been approved or saved as the official `<slug>.md`) and not a stale older plan.

Delete `docs/plans/.pending-forecast.md` at the end of Step 4 — whether the developer approves, edits, or rejects the plan. It must never persist past the approval gate.

## Step 3b — Run `/g-forecast` for scope-realism and premortem

Use Glob to find `skills/g-forecast/SKILL.md` inside `~/.claude/plugins/cache/g-team/g-team/` and read it, then follow its instructions. `/g-forecast` will pick up `docs/plans/.pending-forecast.md` per its Step 1 case 1.

The forecast returns: a complexity score (0–10), a miss-risk percentage with risk tag, and a ranked top-5 premortem of likely failure scenarios with mitigations. It is **advisory** — it never blocks the approval gate. Its job is to surface risk so the developer can decide whether to proceed, mitigate, or re-scope.

Carry the forecast summary forward into Step 4 so the developer sees it alongside the plan.

If `/g-forecast` returns High risk (≥75%), surface this prominently in Step 4 and add a one-line recommendation that the developer consider re-scoping — but do not block. The developer's approval is still authoritative.

## Step 4 — Present plan and wait for approval

Present the full output to the developer:

```
## Plan: [feature name]

[task list table from task-decomposer]

[wave schedule from wave-planner]

### Budget

Context cost: ~[N] exchanges   Remaining: ~[M]   [✓ fits / ⚠ tight / from plan header]

### Forecast (advisory)

Complexity: [X/10]   Miss-risk: [P]% — [Low / Moderate / Elevated / High]

Top premortem scenarios:
  1. [scenario] — mitigation: [one line]
  2. [scenario] — mitigation: [one line]
  3. [scenario] — mitigation: [one line]

[if High risk] ⚠ This plan exceeds the 75% miss-risk threshold. Consider re-scoping before approval. (Advisory only — your approval is still authoritative.)

### Dependency risks

[omit this section if Step 3d found no warnings]
⚠ [warning text from Step 3d — one line per warning]

---
Ready to execute? Reply 'approved' to begin, or describe changes.
```

**Do not proceed without explicit developer approval.** If the developer requests changes, update the plan and re-present. Repeat until approved.

When the developer responds (approval, edit, or reject), delete `docs/plans/.pending-forecast.md` if it exists — the handoff file from Step 3a must never persist past this gate.

## Step 4a — Save approved plan to disk

Once the developer approves, immediately write the plan to `docs/plans/<feature-slug>.md` using the schema defined in the **Plan File Format** section below. Slugify the feature name for the filename (e.g. `user-auth-flow.md`). Create the `docs/plans/` directory if it does not exist. Do this before handing off to g-execute.

## Step 5 — On approval

Once the developer approves, use Glob to find `skills/g-execute/SKILL.md` inside `~/.claude/plugins/cache/g-team/g-team/` and read it, then follow its instructions to run the waves.

## Plan File Format

All plans produced by this skill are saved to `docs/plans/<feature-slug>.md` immediately after developer approval (before execution begins). Use the feature name slugified as the filename (e.g. `user-auth-flow.md`).

### Schema

````markdown
# Plan: [Feature Name]

> Created: [date]

## Tasks

| # | Task | Scope | Done condition |
|---|------|-------|----------------|
| 1 | [task name] | [files/area] | [verifiable condition] |
| 2 | ... | ... | ... |

## Wave Schedule

### Wave 1
- Task 1 — [task name]
- Task 2 — [task name]

### Wave 2
- Task 3 — [task name]

## Progress

| Wave | Status | Notes |
|------|--------|-------|
| 1 | pending | |
| 2 | pending | |
````

## QA Scope Format

Written to `docs/qa-scope/<milestone-slug>.md`. One file per milestone, compiled through conversation with the developer.

````markdown
# QA Scope: [Milestone Name]

> Updated: [date]
> Tier 3 DoD: all in-scope groups reach ✓ pass or ~ partial with no blocking fails

## In-Scope Groups

### [Group Name]
- What changed: [brief description of what this milestone touches in this group]
- Must pass: [specific behaviours that must reach ✓]
- Acceptable partial: [behaviours where ~ is OK for this milestone]

### [Group Name]
...

## Always-True (never regress regardless of milestone)
- [core flow that must always pass]
````

## Rules
- Never skip Step 0. No Tier 3 DoD defined = milestone not started.
- Never skip the approval gate.
- Never suggest implementation approaches — that is the executor's job.
- Wave execution always goes through g-execute — never inline, never via superpowers.
- If any agent returns BLOCKED during execution, stop and report to the developer before continuing.
