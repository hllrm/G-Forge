# Getting Started with G-Forge

## Install

### Prerequisites
- **Claude Code** — desktop app, CLI, or IDE extension
- **Git** — required for commit enforcement (the gate is pure POSIX bash; `jq`, `python3`, or `node` serve only as optional JSON-parser fallbacks, with a `sed` tier when none is present)

### Install the plugin

Via CLI:
```bash
claude
/plugin marketplace add hllrm/g-forge
/plugin install g-forge
```

All 19 agents, 38 skills, and 48+ stack profiles become globally available across all projects.

**Desktop / VS Code / JetBrains:** Use the CLI commands above; the plugin registers globally and will be available in all interfaces.

### First-time setup

In your project directory:
```bash
/g-forge init
```

`/g-init` detects what you have (new project vs. existing codebase) and scaffolds everything in one pass:
1. **Intake** — routes to `/g-kickoff` (new) or `/g-onboard` (existing)
2. **Scaffold** — creates CLAUDE.md (with G-rules), G-RULES.md, g-docs/, and commits hooks to `.claude/`
3. **Specialize** — detects your stack and installs architect + implementer agents

After `/g-init`, `git commit` is gated — it blocks until `/g-review` issues MERGE READY.

---

## Project Lifecycle

| Phase | Command | What it does |
|-------|---------|-------------|
| **New project** | `/g-forge kickoff` | Interview → scope challenge → stack deep dive → `g-docs/project_brief.md` |
| **Existing project** | `/g-forge onboard` | Read repo → present findings → interview → `g-docs/project_brief.md` |
| **Then both** | `/g-forge roadmap` | Feature dump → cluster → sequence → approve → `g-docs/ROADMAP.md` |
| **Stack-specific** | `/g-forge specialize` | Detect stack → install architect + implementer agents + rules |

For refinement later: `/g-forge brief` refreshes the brief incrementally as the project evolves.

---

## Per-Task Loop

**Auto-triggered.** The workflow-checkpoint hook fires on every message and Claude auto-triggers these steps when work is ready.

```
/g-forge plan        Task decomposition + wave scheduling → approval → saves to g-docs/plans/

/g-forge execute     Dispatch agents in parallel by wave
                     (Wave 1 finishes before Wave 2 starts)
                     Can resume mid-sequence: /g-forge execute 2

/g-forge review      Test suite → code-lead → full pipeline → smoke testing
                     Result: MERGE READY (unlocks commit gate) or HOLD (fix list)
```

You can invoke these manually if auto-trigger doesn't fire, but they're designed to trigger on their own based on project state.

---

## Integration Tiers

G-Forge adapts to how much automation you want. Set your tier once; Claude respects it automatically.

| Tier | Behavior |
|------|----------|
| **Full** (default) | All hooks + auto-triggers (`/g-plan`, `/g-execute`, `/g-review` trigger when work is ready); commit gate active; passive observer journal |
| **Balanced** | State info only (`workflow-checkpoint` reports status but no auto-triggers); commit gate active; observer off |
| **Light** | Opt-out mode — only `workflow-checkpoint` runs; commit gate off; observer off |

Switch tiers: `/g-forge tier full` (or `balanced` / `light`)

---

## Commands

All G-Forge commands use the umbrella form:
```bash
/g-forge <token> [args]
```

Tokens *(from `commands/g-forge.md`)*:

**Lifecycle:** `kickoff` · `onboard` · `init` · `roadmap` · `specialize` · `brief`

**Per-task:** `plan` · `execute` · `review` · `doc-review` · `afk` · `listen`

**Project state:** `help` · `status` · `doctor` · `resume` · `retro` · `update`

**Planning & analysis:** `intake` · `forecast` · `blast-radius` · `align` · `adr` · `patterns`

**Quality & docs:** `audit` · `optimize` · `refactor` · `docs` · `wiki` · `telemetry` · `identity`

**Configuration:** `tier` · `voice` · `train` · `trim`

**Advanced:** `skill-design` · `skill-validate` · `roundtable`

Each token routes to a SKILL.md that contains the full workflow. Run `/g-forge help` for guided context-aware suggestions.

---

## Session Rhythm

### Starting a fresh session

```bash
/g-forge resume
```

This re-hydrates you from the durable record: relevant retro, in-force ADRs, journal tail, and the handoff from the last session. Cleans up your context window while keeping you in sync.

### Ending a session

```bash
/g-forge retro
```

Synthesizes a session retrospective from the silent observer journal, git history, and `g-docs/todo.md`. You verify the output (no interview). The retrospective goes to `g-docs/retros/` and becomes re-entry context for `/g-resume`.

### The handoff

The canonical handoff lives in `g-docs/ROADMAP.md` under `## Active Session`. It contains:
- **Done this pass** — what closed
- **Next up** — what's coming
- **Active context** — current file:line state, in-flight logic

This is the single document a fresh session (even a fresh clone) needs to target for "where am I / what's next?"

---

## Voice Profiles

Control how G-Forge communicates — the same facts and verdicts, different rendering.

```bash
/g-forge voice
```

No argument = 2-question plain-language intake sets the right profile automatically.

| Profile | Style |
|---------|-------|
| `dev` | Terse, technical (default) |
| `mid` | One context sentence per major result |
| `eli5` | Plain language, conversational |

---

## Key Workflows

### Planning a feature

1. Describe what you want to build
2. Claude auto-triggers `/g-plan` if the task is non-trivial (≥3 files, unclear scope, or new capability)
3. Plan appears → you review + approve
4. Claude auto-triggers `/g-execute` once approved
5. Work completes → Claude auto-triggers `/g-review`
6. Review gate passes → MERGE READY unlocks `git commit`

### Debugging a bug

```
Error message or stack trace
  ↓
Dispatch error-detective to pattern-match the log
  ↓
Dispatch debugger with error-detective's findings + source
  ↓
Dispatch test-writer with the fix strategy
  ↓
Implement + /g-review → commit
```

### Auditing code quality

```
/g-forge audit [path]     Targets a specific file/folder (fast, inline report)
                    or    Full codebase audit (produces prioritised roadmap milestone)
```

### Documentation debt

```
/g-forge docs [path]      Scans for missing/stale docs + ADR gaps
                          Targeted: inline fixes via doc-writer
                          Full codebase: roadmap milestone
```

---

## Project Tracking

All operational records live in `g-docs/`:

| File | What it holds |
|------|---------------|
| `ROADMAP.md` | **Milestones + the Active Session handoff** — always start here |
| `todo.md` | Active task ledger (tactical) |
| `todo-done.md` | Archived closed tasks |
| `milestones/M*.md` | Per-milestone scope, tasks, done conditions |
| `decisions/` | Architectural Decision Records (captured via `/g-adr`) |
| `retros/` | Session retrospectives (from `/g-retro`) |

Read `ROADMAP.md` first — the `## Active Session` block has everything for a cold start.

---

## Emergency commands

| Need | Command |
|------|---------|
| Where am I? | `/g-forge status` (fast snapshot) or `/g-forge help` (with guidance) |
| Health check | `/g-forge doctor` (23-point verification) |
| Plugin update | `/g-forge update` (pull latest + realign project files) |
| Pause auto-triggers | `/g-forge tier balanced` (state info only, no auto-trigger) |
| Unattended run | `/g-forge afk` (all pending waves + review, no check-ins) |

---

For detailed workflows and design decisions, see [Architecture](architecture.md) and [Commit Gate](commit-gate.md). Full reference: [README](../README.md).
