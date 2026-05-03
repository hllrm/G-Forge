# G-Team

> Multi-agent Claude Code plugin — planned execution, production architecture, enforced review.

G-Team installs a structured development workflow into any Claude Code project: decompose tasks into waves, implement in parallel, gate every commit behind a code-lead review.

## Install

```bash
/plugin marketplace add hllrm/g-team
/plugin install g-team
```

## Skills

### `/g-team kickoff` — Define the project

Interviews you about goals, constraints, and scope. Challenges anything overengineered or speculative. Dispatches `project-manager` and `code-lead` agents to shape an MVP and phased roadmap. Produces `project_brief.md`.

### `/g-team init` — Scaffold the project

Run once in a new repo. Creates:
- `CLAUDE.md` with the G-Team workflow rules injected
- `ROADMAP.md`, `milestones/M1.md`, `todo.md`
- `.claude/hooks/` commit enforcement scripts
- `.claude/settings.json` hook registration

If `project_brief.md` exists, pre-fills ROADMAP and M1 from it.

### `/g-team plan` — Decompose and schedule

For any non-trivial task (≥3 files, new feature, layer-boundary change):
1. Dispatches `task-decomposer` → atomic task list
2. Dispatches `wave-planner` → parallel wave schedule
3. Presents the full plan and waits for your approval before anything executes

### `/g-team review` — Run the merge gate

Dispatches `code-lead` with the branch diff and done conditions. code-lead verifies all done conditions and runs `review-orchestrator` internally. Issues one of:

- **MERGE READY** — writes `.claude/g-team-approved`, unlocking the commit gate
- **HOLD — FIX REQUIRED** — blocks commit until all items are resolved

### `/g-team specialize [stack]` — Apply a stack profile

Detects your project stack from dependency files (or accepts an explicit stack arg) and installs a stack-specific architect agent into `.claude/agents/` and appends architecture rules to `CLAUDE.md`. After this runs, the agent is project-native — no plugin required to use it.

Supported stacks: `vue-pinia`, `node-ts`, `fastapi`

## Commit enforcement

Once `/g-team init` is run, `git commit` is blocked unless `.claude/g-team-approved` exists. That sentinel is written only by `/g-team review` on a MERGE READY verdict, and automatically cleared after the commit.

## Agents

15 specialized agents ship with G-Team:

| Agent | Role |
|-------|------|
| `project-manager` | MVP definition, milestone planning |
| `code-lead` | Technical sign-off, review orchestration |
| `task-decomposer` | Atomic task breakdown |
| `wave-planner` | Parallel wave scheduling |
| `review-orchestrator` | Coordinates full review pipeline |
| `code-reviewer` | Code quality and correctness |
| `security-auditor` | Security vulnerability review |
| `performance-auditor` | Performance and efficiency review |
| `architecture-enforcer` | Layer boundaries, import directions |
| `debugger` | Root cause analysis |
| `error-detective` | Error pattern investigation |
| `refactor-executor` | Safe, scoped refactoring |
| `test-writer` | Test coverage |
| `spec-writer` | Feature and API specs |
| `doc-writer` | Documentation |
| `pr-writer` | PR descriptions |

## Stack Profiles

Each profile installs a specialized architect agent and appends architecture rules to `CLAUDE.md`. Once installed, the agent is project-native.

| Profile | Agent | Stack |
|---------|-------|-------|
| `vue-pinia` | `vue-architect` | Vue 3, Pinia, Vite, TypeScript |
| `node-ts` | `node-architect` | Node.js, TypeScript, Express/Fastify |
| `fastapi` | `fastapi-architect` | FastAPI, Pydantic, SQLAlchemy, async Python |

Planned (M5+): `react`, `tauri`

## Workflow

```
/g-team kickoff     →   project_brief.md
/g-team init        →   scaffolded project + commit gate
/g-team specialize  →   stack architect agent + architecture rules
/g-team plan        →   approved wave schedule
execute waves       →   parallel agent implementation
/g-team review      →   MERGE READY or HOLD
git commit          →   gate clears, sentinel removed
```

## Roadmap

| Milestone | Status |
|-----------|--------|
| M1 — Foundation | ✅ Done |
| M2 — Agent Roster | ✅ Done |
| M3 — Skills & Orchestration | ✅ Done |
| M4 — Stack Profiles | ✅ Done |
| M5 — Publish | ⬜ Next |
