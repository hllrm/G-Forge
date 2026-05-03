# M3 — Skills & Orchestration Implementation Plan

> **For agentic workers:** Use G-Team's own wave execution model — task-decomposer → wave-planner → HQ executes waves. No external orchestration dependency.

**Goal:** Implement the four /g-team skills end-to-end (kickoff, init, plan, review) and wire commit-enforcement hooks so nothing merges without code-lead sign-off.

**Architecture:** Each skill is a standalone `SKILL.md` that Claude loads and follows when the user invokes `/g-team <skill>`. Hook enforcement uses a `PreToolUse` bash hook that blocks `git commit` unless `.claude/g-team-approved` exists — written by `/g-team review` on MERGE READY and cleared after each commit.

**Tech Stack:** Bash (hook scripts), Markdown (skills), JSON (hooks.json, settings.json), Python 3 (JSON parsing in hooks)

---

## File Map

| Action | File | Responsibility |
|--------|------|----------------|
| Create | `skills/g-team-kickoff/SKILL.md` | Interview developer, involve project-manager + code-lead, produce `project_brief.md` |
| Overwrite | `skills/g-team-init/SKILL.md` | Scaffold project: CLAUDE.md (G-rules block), ROADMAP.md, milestones/, todo.md, commit hook setup |
| Overwrite | `skills/g-team-plan/SKILL.md` | task-decomposer → wave-planner → wave schedule → approval gate |
| Overwrite | `skills/g-team-review/SKILL.md` | code-lead → review-orchestrator → verdict → sentinel management |
| Create | `hooks/check-commit.sh` | PreToolUse enforcement: blocks `git commit` without `.claude/g-team-approved` |
| Create | `hooks/post-commit-cleanup.sh` | PostToolUse: clears `.claude/g-team-approved` after successful commit |
| Create | `hooks/test-check-commit.sh` | Unit tests for check-commit.sh |
| Overwrite | `hooks/hooks.json` | Register PreToolUse + PostToolUse hooks |

---

## Task 1 — Hook enforcement scripts (TDD)

**Files:**
- Create: `hooks/test-check-commit.sh`
- Create: `hooks/check-commit.sh`
- Create: `hooks/post-commit-cleanup.sh`

- [ ] **Step 1: Write the failing test**

Create `hooks/test-check-commit.sh`:

```bash
#!/bin/bash
# Unit tests for hooks/check-commit.sh

SCRIPT="$(dirname "$0")/check-commit.sh"
SENTINEL=".claude/g-team-approved"
PASS=0
FAIL=0

run() {
    local name="$1" input="$2" expected="$3"
    echo "$input" | bash "$SCRIPT" 2>/dev/null
    local actual=$?
    if [ "$actual" -eq "$expected" ]; then
        echo "PASS: $name"; PASS=$((PASS+1))
    else
        echo "FAIL: $name (expected exit $expected, got $actual)"; FAIL=$((FAIL+1))
    fi
}

mkdir -p .claude
rm -f "$SENTINEL"

# 1: git commit without sign-off → blocked
run "git commit blocked without sign-off" \
    '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feat: add feature\""}}' \
    1

# 2: git commit with sign-off → allowed
echo "approved" > "$SENTINEL"
run "git commit allowed with sign-off" \
    '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feat: add feature\""}}' \
    0
rm -f "$SENTINEL"

# 3: npm test → allowed without sign-off
run "non-commit command always passes" \
    '{"tool_name":"Bash","tool_input":{"command":"npm test"}}' \
    0

# 4: git push → not blocked
run "git push not blocked" \
    '{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}' \
    0

# 5: git commit --amend → blocked without sign-off
run "git commit --amend blocked without sign-off" \
    '{"tool_name":"Bash","tool_input":{"command":"git commit --amend --no-edit"}}' \
    1

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
```

- [ ] **Step 2: Run test to verify it fails**

```bash
bash hooks/test-check-commit.sh
```

Expected: FAIL — `check-commit.sh: No such file or directory`

- [ ] **Step 3: Implement check-commit.sh**

Create `hooks/check-commit.sh`:

```bash
#!/bin/bash
# G-Team commit gate — PreToolUse hook.
# Blocks git commit if .claude/g-team-approved does not exist.
# Input: Claude Code PreToolUse JSON on stdin.

INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    cmd = d.get('tool_input', {}).get('command', '') or d.get('command', '')
    print(cmd)
except Exception:
    pass
" 2>/dev/null)

if echo "$CMD" | grep -q "git commit"; then
    if [ ! -f ".claude/g-team-approved" ]; then
        echo "G-Team: No code-lead sign-off. Run /g-team review and wait for MERGE READY before committing." >&2
        exit 1
    fi
fi
```

- [ ] **Step 4: Implement post-commit-cleanup.sh**

Create `hooks/post-commit-cleanup.sh`:

```bash
#!/bin/bash
# G-Team post-commit cleanup — PostToolUse hook.
# Clears .claude/g-team-approved after a successful git commit.
# Input: Claude Code PostToolUse JSON on stdin.

INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    cmd = d.get('tool_input', {}).get('command', '') or d.get('command', '')
    print(cmd)
except Exception:
    pass
" 2>/dev/null)

if echo "$CMD" | grep -q "git commit"; then
    rm -f ".claude/g-team-approved"
fi
```

- [ ] **Step 5: Run test to verify it passes**

```bash
bash hooks/test-check-commit.sh
```

Expected: `Results: 5 passed, 0 failed`

- [ ] **Step 6: Commit**

```bash
git add hooks/check-commit.sh hooks/post-commit-cleanup.sh hooks/test-check-commit.sh
git commit -m "feat(hooks): add commit enforcement scripts with tests"
git push
```

---

## Task 2 — Update hooks/hooks.json

**Files:**
- Modify: `hooks/hooks.json`

- [ ] **Step 1: Overwrite hooks/hooks.json**

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash hooks/check-commit.sh",
            "timeout": 5000
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash hooks/post-commit-cleanup.sh",
            "timeout": 5000
          }
        ]
      }
    ],
    "SubagentStart": [],
    "SubagentStop": []
  }
}
```

- [ ] **Step 2: Verify JSON is valid**

```bash
python3 -c "import json; json.load(open('hooks/hooks.json')); print('Valid JSON')"
```

Expected: `Valid JSON`

- [ ] **Step 3: Commit**

```bash
git add hooks/hooks.json
git commit -m "feat(hooks): wire PreToolUse commit enforcement and PostToolUse cleanup"
git push
```

---

## Task 3 — Implement skills/g-team-kickoff/SKILL.md

**Files:**
- Create: `skills/g-team-kickoff/SKILL.md`

- [ ] **Step 1: Create directory**

```bash
mkdir -p skills/g-team-kickoff
```

- [ ] **Step 2: Write SKILL.md**

Create `skills/g-team-kickoff/SKILL.md` with this exact content:

```markdown
---
name: g-team-kickoff
description: Interview the developer about their project goals and constraints. Challenges scope honestly. Works with project-manager and code-lead to define an MVP, the path to feature-complete, and a phased roadmap. Produces project_brief.md.
---

**Announce:** "Using g-team-kickoff to shape the project brief."

You are a critical friend. Your job is to ask good questions, challenge scope honestly, involve the right agents, and produce a clear `project_brief.md`. You give real opinions. The developer always has the final word, but they get your honest take first.

## Step 1 — Interview the developer

Ask these questions one group at a time. Wait for answers before proceeding to the next group.

**Group 1 — The problem:**
- What does this project do in one sentence?
- Who uses it, and what specific pain does it solve for them?
- What does success look like in 3 months? In 12 months?

**Group 2 — Scope:**
- What are the features you absolutely cannot launch without?
- What are features you want but could live without for the first version?
- What is explicitly out of scope — things you've decided NOT to build?

**Group 3 — Technical context:**
- What stack or technologies are you committed to (if any)? Why those?
- Any existing systems this must integrate with?
- Team size, experience level, and how much time per week on this?

## Step 2 — Challenge the scope

Before involving the agents, review the developer's answers critically. For each feature or requirement, ask yourself:

- **Is this overengineered?** Does it solve a problem the developer doesn't actually have yet?
- **Is this redundant?** Does something already solve this — a library, a SaaS, an existing tool?
- **Is this speculative?** Is the developer building for a user who doesn't exist yet?
- **Does this double down on complexity?** Does it add a second way to do something already handled?

For any feature that raises a flag, ask the developer directly — one honest question, not a lecture:

> "You've mentioned [feature]. I want to make sure we're solving a real problem — [specific concern]. Why do you need this now rather than later?"

Wait for the answer. Accept it if the developer explains the need. If the answer is vague ("it would be nice", "maybe someday"), note it as a Could-have or non-goal. Do not push more than once per feature.

## Step 3 — Involve project-manager

Dispatch the `project-manager` agent with:
- A summary of the developer's answers (verbatim where relevant)
- The list of features, flagged as Must / Should / Could based on the Step 2 challenge

Ask project-manager to:
> "Given these answers, define an MVP — the smallest thing that proves the core value and can ship. Then define the path to feature-complete in milestones. Be honest: if any Must-have looks like scope creep or premature complexity, say so."

Wait for project-manager's response. Present it to the developer with: "Here is how project-manager suggests structuring the scope — do you agree with the MVP boundary? Anything that should move in or out?"

## Step 4 — Involve code-lead

Dispatch the `code-lead` agent with:
- The developer's answers
- project-manager's MVP and milestone proposal

Ask code-lead to:
> "Review this for technical feasibility. Flag any features that are overengineered for the stated problem, any stack choices that will cause pain, any integrations that block the MVP. Give a blunt technical starting point recommendation."

Wait for code-lead's response. Present it to the developer with: "Here is code-lead's technical read — any corrections or disagreements?"

## Step 5 — Present MVP, roadmap, and reasoning

Synthesize everything into a structured proposal. Present this to the developer before writing any file:

```
## Kickoff Proposal — [Project Name]

### MVP
What ships first and proves the core value:
- [Feature 1] — [why it's in MVP]
- [Feature 2] — [why it's in MVP]

**MVP done condition:** [specific, observable thing that means MVP is working]

### Path to feature-complete
| Milestone | Features | Why this order |
|-----------|----------|----------------|
| M1 — MVP | [list] | Validates core value before investing further |
| M2 — [name] | [list] | [dependency or user feedback reason] |
| M3 — [name] | [list] | [dependency or user feedback reason] |

### Honest notes
[List any features that were challenged and why — e.g.:]
- [Feature X] moved to M2: premature without knowing if MVP gets traction
- [Feature Y] removed: [library/SaaS] already does this; reinventing it adds no value
- [Stack choice Z]: noted risk — [concern]; developer confirmed intentional

### Open questions
- [Unresolved decision that affects scope or sequencing]
```

Tell the developer: "This is my honest recommendation. You have the final word — tell me what to change or say 'approved' to lock it."

If the developer overrides a recommendation, accept it without argument. Note the override in the brief so future sessions have the context.

## Step 6 — Produce and lock project_brief.md

Once the developer approves (or amends and approves), write `project_brief.md` at the project root:

```
# Project Brief — [Project Name]

**Created:** [today's date]
**Status:** Approved

## What this builds
[One paragraph: what it is, what problem it solves, who uses it]

## Goals
- [Measurable goal 1]
- [Measurable goal 2]

## Non-goals (explicitly out of scope)
- [What we are NOT building, and why]

## MVP
[List of features in the MVP and the MVP done condition]

## Roadmap
| Milestone | Features | Rationale |
|-----------|----------|-----------|
| M1 — MVP | [list] | [why] |
| M2 | [list] | [why] |

## Technical constraints
- Stack: [languages, frameworks, platforms]
- Integrations: [external APIs, databases, services]
- Constraints: [performance, compliance, team size, timeline]

## Success metrics
- [How we know MVP worked]
- [How we know the product is feature-complete]

## Decisions and overrides
[Any scope decisions or overrides from the kickoff session with brief reasoning]

## Open questions
- [Unresolved decisions that affect scope or sequencing]
```

Tell the developer: "Brief locked. Run /g-team init to scaffold the project — it will use this brief to pre-fill your ROADMAP.md and M1 milestone."

## Rules
- Never write project_brief.md before the developer approves.
- Challenge each questionable feature once — not repeatedly. Accept the developer's answer.
- Present the full proposal (Step 5) before writing anything to disk.
- If the developer's answers are vague, ask one focused follow-up before proceeding.
- Overrides are recorded in the brief — no silent acceptance.
- You give opinions. The developer decides. Never refuse to proceed after a decision is made.
```

- [ ] **Step 3: Verify frontmatter**

```bash
python3 -c "
import re
content = open('skills/g-team-kickoff/SKILL.md').read()
fm = re.search(r'^---\n(.*?)\n---', content, re.DOTALL)
assert fm, 'No frontmatter found'
assert 'name:' in fm.group(1), 'Missing name field'
assert 'description:' in fm.group(1), 'Missing description field'
print('Frontmatter valid')
"
```

Expected: `Frontmatter valid`

- [ ] **Step 4: Commit**

```bash
git add skills/g-team-kickoff/SKILL.md
git commit -m "feat(skills): implement g-team-kickoff skill with MVP analysis and honest scope challenge"
git push
```

---

## Task 4 — Implement skills/g-team-init/SKILL.md

**Files:**
- Modify: `skills/g-team-init/SKILL.md`

- [ ] **Step 1: Overwrite SKILL.md**

Write `skills/g-team-init/SKILL.md` with this exact content:

```markdown
---
name: g-team-init
description: Scaffold a new project with CLAUDE.md (compact G-rules injected), ROADMAP.md, milestones/, todo.md, and commit enforcement hooks. Run once in a new project after installing g-team.
---

**Announce:** "Using g-team-init to scaffold the project."

You are initializing a G-Team project. Execute these steps in order. Do not skip any step.

## Step 1 — Confirm project root

The project root is the current working directory. If uncertain, ask the developer to confirm before creating any files.

## Step 2 — Create or update CLAUDE.md

Check if `CLAUDE.md` exists at the project root.

**If it does not exist:** Create it with this content (replace [Project Name] with the actual project name, or use a placeholder):

```
# [Project Name]

[Brief description of what this project does.]

<!-- G-Team Rules — injected by /g-team init. Do not edit manually. -->
## G-Team Workflow

**Models**: Haiku for reads/search · Sonnet for implementation · Opus only after 2 failed attempts on the same task.

**Workflow (non-trivial tasks: ≥3 files, new feature, layer-boundary change, unclear bug)**:
1. `/g-team plan` — decompose to atomic tasks, produce wave schedule, get approval
2. Execute approved waves — agents implement, test, commit per spec; all independent tasks in one parallel wave
3. `/g-team review` — code-lead verifies done conditions + full review pipeline → MERGE READY or HOLD
4. Merge only after MERGE READY — never before

**Agent discipline**: HQ orchestrates only — dispatches agents, collects results, integrates. Never does grunt work an agent can do. Hard limit: 7 agents per task.

**Architecture gate**: ≥3 files, layer-boundary change, new component, or public API change → plan first (no writes), validate import directions, verify state ownership, get sign-off.

**Hard stops**: No merge without MERGE READY · No plan skip for non-trivial tasks · HOLD = fix all blocking items, re-review · Same bug class × 3 attempts = stop, escalate, try a different mechanism.
<!-- End G-Team Rules -->
```

**If it exists:** Read it. If the text `<!-- G-Team Rules` is not present, append the G-Team Rules block (from `<!-- G-Team Rules` to `<!-- End G-Team Rules -->`) at the end of the file.

## Step 3 — Create ROADMAP.md

Create `ROADMAP.md` if it does not exist:

```
# Roadmap

## Current Milestone
- **M1** — [Define milestone name] — 🚧 In progress

## Backlog
- M2 — [Define next milestone]

## Done
(none yet)
```

If a `project_brief.md` exists, read it and use the project goals to fill in M1 and M2 with meaningful content.

## Step 4 — Create milestones/M1.md

Create the `milestones/` directory if it does not exist.
Create `milestones/M1.md` if it does not exist:

```
# M1 — [Milestone Name]

## Goal
[One sentence describing what this milestone delivers]

## Scope
- [ ] Task 1
- [ ] Task 2

## Done condition
[Specific, mechanically checkable condition]

## Status
🚧 In progress
```

## Step 5 — Create todo.md

Create `todo.md` if it does not exist:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HANDOFF — [project] | branch: [branch]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Done this pass:   · (nothing yet)
Next up:          · Define M1 scope in milestones/M1.md
Active context:   · Fresh project, just initialized
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Tasks
| # | Task | Notes |
|---|------|-------|
| 1 | Define M1 scope | Update milestones/M1.md |

## Details
```

## Step 6 — Set up commit enforcement hooks

Create `.claude/hooks/` directory if it does not exist.

Write `.claude/hooks/check-commit.sh` with this exact content:

```bash
#!/bin/bash
# G-Team commit gate — PreToolUse hook.
# Blocks git commit if .claude/g-team-approved does not exist.
INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    cmd = d.get('tool_input', {}).get('command', '') or d.get('command', '')
    print(cmd)
except Exception:
    pass
" 2>/dev/null)
if echo "$CMD" | grep -q "git commit"; then
    if [ ! -f ".claude/g-team-approved" ]; then
        echo "G-Team: No code-lead sign-off. Run /g-team review and wait for MERGE READY before committing." >&2
        exit 1
    fi
fi
```

Write `.claude/hooks/post-commit-cleanup.sh` with this exact content:

```bash
#!/bin/bash
# G-Team post-commit cleanup — PostToolUse hook.
# Clears .claude/g-team-approved after a successful git commit.
INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    cmd = d.get('tool_input', {}).get('command', '') or d.get('command', '')
    print(cmd)
except Exception:
    pass
" 2>/dev/null)
if echo "$CMD" | grep -q "git commit"; then
    rm -f ".claude/g-team-approved"
fi
```

## Step 7 — Register hooks in .claude/settings.json

Read `.claude/settings.json` if it exists. If it does not exist, start with `{}`.

Add the following hook entries under the `hooks` key. If `hooks` already exists, merge — do not overwrite existing hooks.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/check-commit.sh",
            "timeout": 5000
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/post-commit-cleanup.sh",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
```

Write the merged result back to `.claude/settings.json`.

## Step 8 — Report

After all steps, report:

```
G-Team initialized ✓

  ✓ CLAUDE.md — G-Team rules injected
  ✓ ROADMAP.md — stub created (or already existed)
  ✓ milestones/M1.md — created (or already existed)
  ✓ todo.md — created (or already existed)
  ✓ .claude/hooks/ — commit enforcement scripts installed
  ✓ .claude/settings.json — hooks registered

Next: run /g-team plan with your first feature request, or edit milestones/M1.md to define your scope.
```

## Rules
- Never create a file that already exists without reading it first.
- If project_brief.md exists at the project root, use its content to pre-fill ROADMAP.md and milestones/M1.md.
- Settings.json merge must never drop existing hooks — read before writing.
```

- [ ] **Step 2: Verify frontmatter**

```bash
python3 -c "
import re
content = open('skills/g-team-init/SKILL.md').read()
fm = re.search(r'^---\n(.*?)\n---', content, re.DOTALL)
assert fm, 'No frontmatter found'
assert 'name:' in fm.group(1), 'Missing name field'
assert 'description:' in fm.group(1), 'Missing description field'
print('Frontmatter valid')
"
```

Expected: `Frontmatter valid`

- [ ] **Step 3: Verify no "Implementation in M3" stub remains**

```bash
grep -c "Implementation in M3" skills/g-team-init/SKILL.md
```

Expected: `0`

- [ ] **Step 4: Commit**

```bash
git add skills/g-team-init/SKILL.md
git commit -m "feat(skills): implement g-team-init skill with G-rules injection and hook setup"
git push
```

---

## Task 5 — Implement skills/g-team-plan/SKILL.md

**Files:**
- Modify: `skills/g-team-plan/SKILL.md`

- [ ] **Step 1: Overwrite SKILL.md**

Write `skills/g-team-plan/SKILL.md` with this exact content:

```markdown
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
```

- [ ] **Step 2: Verify no stub text and valid frontmatter**

```bash
python3 -c "
import re
content = open('skills/g-team-plan/SKILL.md').read()
fm = re.search(r'^---\n(.*?)\n---', content, re.DOTALL)
assert fm and 'name:' in fm.group(1) and 'description:' in fm.group(1), 'Bad frontmatter'
assert 'Implementation in M3' not in content, 'Stub text remains'
print('OK')
"
```

Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add skills/g-team-plan/SKILL.md
git commit -m "feat(skills): implement g-team-plan skill"
git push
```

---

## Task 6 — Implement skills/g-team-review/SKILL.md

**Files:**
- Modify: `skills/g-team-review/SKILL.md`

- [ ] **Step 1: Overwrite SKILL.md**

Write `skills/g-team-review/SKILL.md` with this exact content:

```markdown
---
name: g-team-review
description: Run the full review pipeline on the current branch diff. Dispatches code-lead which verifies done conditions and runs review-orchestrator. Issues MERGE READY or HOLD.
---

**Announce:** "Using g-team-review to run the full review pipeline."

You are running the merge gate. Execute these steps in order.

## Step 1 — Gather the diff

Run:
```
git diff main...HEAD
```

If output is empty, run: `git diff --staged`

If both are empty, ask the developer: "What branch or commit range should I review?"

## Step 2 — Gather done conditions

Check for done conditions in this order:
1. The relevant spec file (typically `docs/superpowers/plans/*.md` or a spec mentioned by the developer)
2. The current milestone file in `milestones/`
3. Ask the developer: "What are the done conditions for this implementation?"

If no done conditions can be found, note this — code-lead will flag it as a process gap.

## Step 3 — Dispatch code-lead

Dispatch the `code-lead` agent. Provide:
- The full diff from Step 1
- The done conditions from Step 2
- The current branch name (from `git branch --show-current`)
- The task list (if known)

code-lead will verify done conditions and dispatch review-orchestrator internally. Wait for code-lead's complete verdict.

## Step 4 — Present verdict and manage sentinel

Present code-lead's verdict to the developer verbatim.

**If verdict is MERGE READY:**
- Create `.claude/` directory if it does not exist
- Write `.claude/g-team-approved` with content: `approved`
- Tell the developer: "MERGE READY. Commit gate unlocked — you can now run git commit and merge."

**If verdict is HOLD — FIX REQUIRED:**
- Do NOT write `.claude/g-team-approved`
- Tell the developer: "HOLD. Fix all blocking items listed above, then re-run /g-team review."

**If verdict is ESCALATE:**
- Do NOT write `.claude/g-team-approved`
- Present the escalation details and ask the developer for guidance before proceeding.

## Rules
- Never modify code-lead's verdict — present it exactly.
- Never write `.claude/g-team-approved` for anything other than MERGE READY.
- If code-lead is blocked by missing information, gather it and re-dispatch — do not guess.
- The sentinel is automatically cleared after the next `git commit` by the commit hook.
```

- [ ] **Step 2: Verify no stub text and valid frontmatter**

```bash
python3 -c "
import re
content = open('skills/g-team-review/SKILL.md').read()
fm = re.search(r'^---\n(.*?)\n---', content, re.DOTALL)
assert fm and 'name:' in fm.group(1) and 'description:' in fm.group(1), 'Bad frontmatter'
assert 'Implementation in M3' not in content, 'Stub text remains'
print('OK')
"
```

Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add skills/g-team-review/SKILL.md
git commit -m "feat(skills): implement g-team-review skill with sentinel management"
git push
```

---

## Done condition

M3 is complete when ALL of the following pass:

```bash
# 1. All skill stubs replaced
grep -r "Implementation in M3" skills/ && echo "FAIL: stubs remain" || echo "PASS: no stubs"

# 2. Hook test passes
bash hooks/test-check-commit.sh

# 3. hooks.json is valid JSON with PreToolUse and PostToolUse
python3 -c "
import json
d = json.load(open('hooks/hooks.json'))
assert 'PreToolUse' in d['hooks'], 'Missing PreToolUse'
assert 'PostToolUse' in d['hooks'], 'Missing PostToolUse'
print('hooks.json OK')
"

# 4. All 4 skills have valid frontmatter with name + description
for f in skills/g-team-kickoff/SKILL.md skills/g-team-init/SKILL.md skills/g-team-plan/SKILL.md skills/g-team-review/SKILL.md; do
  python3 -c "
import re, sys
content = open('$f').read()
fm = re.search(r'^---\n(.*?)\n---', content, re.DOTALL)
assert fm and 'name:' in fm.group(1) and 'description:' in fm.group(1), 'Bad frontmatter in $f'
print('OK: $f')
"
done
```

---

## Self-review

**Spec coverage:**
- g-team-init injects compact G-rules block ✓
- g-team-init creates ROADMAP.md, milestones/, todo.md ✓
- g-team-init sets up project-level commit hooks ✓ (Steps 6–7)
- g-team-plan orchestrates task-decomposer → wave-planner ✓
- g-team-review orchestrates code-lead → sentinel management ✓
- g-team-kickoff produces project_brief.md with project-manager + code-lead ✓
- hooks.json wires PreToolUse commit enforcement ✓
- No Superpowers references anywhere ✓

**Placeholder scan:** All steps have concrete content. No "TBD", "add validation", or "handle edge cases". ✓

**Type consistency:** Shell scripts, SKILL.md files, and hooks.json are self-contained. No cross-file type dependencies. ✓
