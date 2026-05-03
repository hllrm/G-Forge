# G-Team

> A managed multi-agent Claude Code plugin — specialized agents for code quality, production architecture, and planned execution.

---

## What it is

G-Team is a Claude Code plugin that replaces generic AI assistance with a team of narrow-mandate specialists. Instead of one model doing everything, you get:

- **Planners** that decompose work into verifiable tasks and parallel wave schedules
- **Reviewers** (Opus) that catch logic errors, architecture violations, and security issues
- **Executors** (Haiku) that generate tests, write docs, and run refactors from specs
- **Orchestrators** that coordinate pipelines without touching code themselves

Every agent has one job. Model tiers are enforced in frontmatter — not by convention.

---

## Install

```bash
/plugin marketplace add hllrm/g-team
/plugin install g-team
```

Then specialize for your stack:

```bash
/g-team specialize
```

G-Team detects your stack and writes native agents directly into `.claude/agents/` — after that they're project-native and don't require the plugin to function.

---

## Commands

| Command | What it does |
|---|---|
| `/g-team init` | Scaffold `CLAUDE.md`, `ROADMAP.md`, and `milestones/` for a new project |
| `/g-team plan` | Decompose the current request into a parallel wave schedule |
| `/g-team review` | Run the full review pipeline on the current branch diff |
| `/g-team specialize [stack]` | Detect stack and install specialized agents into `.claude/agents/` |

---

## Agents

### Planning — Sonnet

| Agent | Does |
|---|---|
| `task-decomposer` | Breaks requests into atomic tasks with verifiable done conditions |
| `wave-planner` | Maps dependencies, produces parallel wave execution schedule |
| `spec-writer` | Writes implementation specs precise enough for Haiku execution |

### Quality — Opus

| Agent | Does |
|---|---|
| `code-reviewer` | Logic errors, code smells, DRY violations, edge cases |
| `architecture-enforcer` | Layer boundary integrity, import directions, SRP |
| `security-auditor` | OWASP Top 10, injection, secrets exposure, auth flaws |

### Reasoning — Sonnet

| Agent | Does |
|---|---|
| `performance-auditor` | O(n²), N+1 queries, hot-path waste |
| `debugger` | Root cause analysis and fix strategy (no implementation) |
| `error-detective` | Log/stack trace analysis, error pattern recognition |

### Execution — Haiku

| Agent | Does |
|---|---|
| `test-writer` | Unit tests from spec or function signature |
| `pr-writer` | PR description from git diff |
| `doc-writer` | Inline docs and README sections (explains WHY, not WHAT) |
| `refactor-executor` | Executes refactor specs exactly — no scope creep |

### Orchestration — Sonnet

| Agent | Does |
|---|---|
| `dev-orchestrator` | Full feature pipeline: plan → spec → implement → test → review → PR |
| `review-orchestrator` | Full review pipeline: code + arch + security + performance in parallel |

---

## Orchestration patterns

### Feature build (`/g-team plan`)

```
task-decomposer  →  wave-planner  →  spec-writer
                         ↓ Wave 1 (parallel)
               [stack agents implement per spec]
                         ↓ Wave 2 (parallel)
               test-writer  +  doc-writer
                         ↓ Wave 3
               review-orchestrator  →  pr-writer
```

### Full review (`/g-team review`)

```
review-orchestrator
  ↓ parallel
code-reviewer + security-auditor + performance-auditor
  ↓ conditional
architecture-enforcer [if layer-boundary files touched]
```

### Debug

```
error-detective  →  debugger  →  test-writer (regression)
```

### Planned refactor

```
spec-writer  →  architecture-enforcer  →  refactor-executor  →  code-reviewer
```

---

## Stack profiles

`/g-team specialize` writes stack-specific agents into your project's `.claude/agents/`. Available at launch:

| Profile | Stack |
|---|---|
| `vue-pinia` | Vue 3 + Pinia — layer rules, SFC conventions, store ownership |
| `node-ts` | Node.js + TypeScript — module boundaries, async patterns |
| `fastapi` | FastAPI + Pydantic — route structure, dependency injection |

Planned: `react`, `tauri`, `django`, `rails`, `svelte`

---

## Model tier design

Models are assigned by what each agent actually does — not by escalation:

| Model | Used for | Agents |
|---|---|---|
| **Opus** | Critical judgment: find bugs, catch vulnerabilities, enforce architecture | code-reviewer, security-auditor, architecture-enforcer |
| **Sonnet** | Complex reasoning: plan, design, orchestrate, diagnose | task-decomposer, wave-planner, spec-writer, performance-auditor, debugger, error-detective, dev-orchestrator, review-orchestrator |
| **Haiku** | Deterministic execution: generate from spec, write tests, run ops | test-writer, pr-writer, doc-writer, refactor-executor |

---

## Project tracking

G-Team scaffolds a `ROADMAP.md` dashboard and `milestones/` directory. The roadmap is your project controller — milestones link to technical specs that agents execute against.

```
ROADMAP.md          ← human-readable dashboard, you control this
milestones/
  M1-foundation.md  ← fully specced (agent-executable)
  M2-feature.md     ← fully specced
  M3-next.md        ← goal defined, specced when M2 closes
```

---

## Design principles

- **One agent, one mandate.** No swiss-army agents.
- **Orchestrators never execute.** They dispatch and integrate — never touch files.
- **Output contracts.** Every agent returns summary + `file:line` refs + a verifiable done condition.
- **Scope discipline.** Agents flag adjacent issues but never act on them.
- **Not a fork.** Informed by [wshobson/agents](https://github.com/wshobson/agents) — built independently with a different philosophy.

---

## License

GPL-3.0 — see [LICENSE](LICENSE)
