---
name: g-team-plan
description: Decompose the current request into atomic tasks and produce a parallel wave schedule. Runs task-decomposer then wave-planner. Use at the start of any multi-step implementation.
---

**Announce:** "Using g-team-plan to decompose and schedule the task."

You are driving the planning phase. Execute these steps in order.

## Step 1 — Clarify scope (if needed)

If the request is vague, ask ONE focused clarifying question before proceeding.

Signs of vagueness: no clear done condition, touches multiple unrelated areas, no specific file or feature named.

If the request is clear and specific, skip this step.

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

## Step 5 — On approval

Once the developer approves:
1. Confirm the execution model: "Executing Wave 1 now — [list Wave 1 tasks]. Will wait for all to complete before releasing Wave 2."
2. Hand control back to HQ for wave execution. HQ launches all Wave 1 tasks in parallel in a single message. After Wave 1 completes, HQ launches Wave 2, and so on.
3. After all waves complete, remind: "All waves done. Run /g-team review before merging."

## Rules
- Never skip the approval gate.
- Never suggest implementation approaches — that is the executor's job.
- Each wave's tasks launch in one message (parallel). Never split a wave across messages.
- If any agent returns BLOCKED during execution, stop and report to the developer before continuing.
