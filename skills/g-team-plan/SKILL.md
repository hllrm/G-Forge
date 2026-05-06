---
name: g-team-plan
description: Decompose the current request into atomic tasks and produce a parallel wave schedule. Runs task-decomposer then wave-planner. Use at the start of any multi-step implementation.
---

**Announce:** "Using g-team-plan to decompose and schedule the task."

You are driving the planning phase. Execute these steps in order.

## Step 0 — QA Panel prerequisite

Check for `docs/qa-panel.md`.

**If it exists:** read it. Confirm with the developer that it reflects the current milestone goals. If it is stale or the milestone has changed, ask what has changed and update the file before proceeding.

**If it does not exist:** ask the developer the following questions, wait for answers, then compile and write `docs/qa-panel.md` using the schema in the **QA Panel Format** section below:
1. What is this milestone trying to deliver? (one or two sentences)
2. What are the 3–5 things that must work correctly for this milestone to be considered done?
3. Are there any always-true criteria — core flows that must never break regardless of milestone?

Do not proceed to Step 1 until `docs/qa-panel.md` exists and is confirmed current.

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

Wait for the task list before proceeding. Do not proceed if task-decomposer returns any "Clarify:" items — resolve those with the developer first.

## Step 3 — Dispatch wave-planner

Dispatch the `wave-planner` agent with the complete task list from task-decomposer.

Wait for the wave schedule before proceeding.

## Step 4 — Present plan and wait for approval

Present the full output to the developer:

```
## Plan: [feature name]

[task list table from task-decomposer]

[wave schedule from wave-planner]

---
Ready to execute? Reply 'approved' to begin, or describe changes.
```

**Do not proceed without explicit developer approval.** If the developer requests changes, update the plan and re-present. Repeat until approved.

## Step 4a — Save approved plan to disk

Once the developer approves, immediately write the plan to `docs/plans/<feature-slug>.md` using the schema defined in the **Plan File Format** section below. Slugify the feature name for the filename (e.g. `user-auth-flow.md`). Create the `docs/plans/` directory if it does not exist. Do this before handing off to g-team-execute.

## Step 5 — On approval

Once the developer approves, use Glob to find `skills/g-team-execute/SKILL.md` inside `~/.claude/plugins/cache/g-team/g-team/` and read it, then follow its instructions to run the waves.

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

## QA Panel Format

Written to `docs/qa-panel.md`. Updated at the start of every milestone.

````markdown
# QA Panel

> Milestone: [milestone name]
> Updated: [date]

## Milestone Goals
[one or two sentences describing what this milestone delivers]

## Milestone DoD
Must pass before this milestone is done:
- [ ] [criterion]

## Always-True Criteria
Core flows that must never break regardless of milestone:
- [ ] [criterion]
````

## Rules
- Never skip Step 0. No QA panel = milestone not started.
- Never skip the approval gate.
- Never suggest implementation approaches — that is the executor's job.
- Wave execution always goes through g-team-execute — never inline, never via superpowers.
- If any agent returns BLOCKED during execution, stop and report to the developer before continuing.
