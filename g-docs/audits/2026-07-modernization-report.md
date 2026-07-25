> **G-FORGE RECORD NOTE (2026-07-25) — read before trusting this file.**
> This is a **received-input record**: an externally-authored report, written **without repo access**, pasted verbatim below (only this banner was added). It is **superseded for all planning purposes** by [2026-07-rebuild-report.md](2026-07-rebuild-report.md). Its §0.1 claim that `[EVIDENCE]` findings are "safe to treat as true" did **not** survive live-doc verification for at least: subagent-nesting default (GF-21 evidence — falsified; nesting is off by default post-v2.1.216) and checkpoint-based wave recovery (GF-31 — falsified; checkpointing does not restore subagent edits). Full corrections: [2026-07-modernization-triage.md](2026-07-modernization-triage.md). Where it writes `docs/audits/` paths, the canonical location here is `g-docs/audits/` (M28).

# G-Forge Modernization & Optimization Report

**Prepared:** 2026-07-25
**Target repo:** `hllrm/G-Forge`
**Intended reader:** a Claude Code session running *inside* the G-Forge repo, with full read access to `agents/`, `commands/`, `skills/`, `hooks/`, `profiles/`, `rules/`, `templates/`, `docs/`, `CHANGELOG.md`, `ROADMAP.md`, `G-RULES.md`.
**Subject:** what in G-Forge is now redundant, under-built, or wrong relative to current Claude Code capability — and what to do about each.

---

## 0. How to use this document

### 0.1 This report is a hypothesis set, not a task list

It was produced **without repo access**. Every finding was derived from the public README plus current Claude Code documentation. That means:

- Findings marked **[VERIFY]** may already be implemented. Confirm against the tree before acting.
- Findings marked **[EVIDENCE]** are grounded in official docs and are safe to treat as true, subject to the version gates in §5.
- Findings marked **[MEASURE]** are hypotheses about cost or performance that require a real comparison run. Do not act on them on faith.

**Known staleness signal:** the README fetched in full describes **5 hooks**, root-level `docs/` paths, **17 agents / 32 skills**. A newer README variant surfaced in search describing **7 hooks**, `g-docs/`-prefixed paths, a `/g-doc-review` gate, and **19 agents / 38 skills / 48 profiles**. The audit was written against the former. Expect drift.

### 0.2 Required first pass — establish ground truth

Run these before reading §2 onward. They take two minutes and will invalidate several findings outright.

```bash
claude --version                      # gates half this document (see §5)
cat CHANGELOG.md | head -60           # what shipped since the audited README
grep -n "Version" ROADMAP.md | head   # current + planned semver
ls hooks/                             # 5 or 7?
ls agents/ | wc -l                    # 17 or 19?
ls skills/ commands/                  # which layer are commands actually in?
ls -d profiles/*/ | wc -l
```

Then, per finding, run its **Repo check** block before its **Action** block.

### 0.3 Verify-against-live-docs protocol

Documentation moves weekly. Before implementing any finding, re-read its cited page. The index is at:

```
https://code.claude.com/docs/llms.txt
```

Fetch that first, then the specific page. Several pages in this report were last confirmed within days of 2026-07-25; the `whats-new/` weekly digests are the fastest way to spot anything shipped since.

For any finding where the doc and this report disagree, **the doc wins and this report is wrong**.

### 0.4 Expected output from this pass

Produce a triage table with one row per finding ID, in this shape, and write it to `docs/audits/2026-07-modernization-triage.md`:

| ID | Verdict | Rationale | Effort | Target milestone |
|---|---|---|---|---|
| GF-01 | ADOPT / PARTIAL / REJECT / ALREADY-DONE / DEFER | one line | S/M/L | M19… |

Then feed the ADOPT rows into `/g-roadmap` as a feature dump. This report is deliberately structured so that G-Forge can be pointed at itself: findings are scoped, independently landable, and carry blast-radius notes so `/g-blast-radius` and `/g-forecast` have something to chew on.

### 0.5 Going deeper

Where a finding says **Deeper**, that's a research question this report could not close. Pursue it with repo access plus a live doc fetch. These are the highest-value follow-ups, not optional garnish — several of them decide whether a finding is worth an hour or a milestone.

---

## 1. Orientation: where G-Forge stands

G-Forge was architected against a Claude Code with: flat non-nesting subagents, shell-only hooks, no native completion-condition control, no native orchestration-as-code, and no native multi-agent reviewer. **All five of those premises are now false.**

The consequence is not that G-Forge is obsolete. It's that the plugin currently spends maintenance budget in two very different places, and only one of them is still yours:

| Layer | Nature | Status |
|---|---|---|
| Commit gate, mandatory human sign-off, MERGE READY/HOLD semantics | Opinion | **Uncontested.** Nothing native does this. |
| Roadmap discipline, scope challenge, milestone sequencing, version planning | Opinion | **Uncontested.** Native planning is task-scoped, not project-scoped. |
| Three-tier testing model, QA scope as a merge prerequisite | Opinion | **Uncontested.** |
| Wave scheduling, agent dispatch, compact returns | Mechanism | **Overtaken** — see GF-20. |
| Context-depth estimation | Mechanism | **Overtaken** — see GF-30. |
| Unattended loop control and safety net | Mechanism | **Overtaken** — see GF-25, GF-26. |
| Reviewer swarm | Mechanism | **Partially overtaken** — see GF-23. |
| Model tier assignment | Mechanism | **Partially overtaken** — see GF-22. |
| Telemetry collection | Mechanism | **Overtaken** — see GF-33. |

**Strategic framing for the triage:** every mechanism G-Forge maintains that Anthropic now ships is a recurring tax with no differentiation return. Deleting mechanism is not a loss of surface area — it's a transfer of maintenance to a party with more engineers. The opinions are the product.

---

## 2. Findings by subsystem

Format: **claim → evidence → repo check → action → effort/risk → deeper**.

---

### A. Skills & command layer

#### GF-01 — Skills are missing invocation control **[EVIDENCE]**

**Claim.** G-Forge's side-effecting commands can be invoked by the model, not just the user. `/g-review` writes the merge sentinel. `/g-execute` dispatches agents. `/g-afk` runs unattended. If Claude can decide to run these, the gate is advisory.

**Evidence.** Skills support `disable-model-invocation: true`, which the docs describe for exactly this case — workflows with side effects, or where you want to control timing, naming `/commit` and `/deploy` as examples.
https://code.claude.com/docs/en/skills

**Repo check.**
```bash
rg -l "disable-model-invocation" skills/ commands/
rg -n "^---" -A8 skills/g-review/SKILL.md 2>/dev/null || head -20 commands/g-review.md
```

**Action.** Add `disable-model-invocation: true` to every skill that mutates state or issues a verdict: `/g-review`, `/g-execute`, `/g-afk`, `/g-init`, `/g-update`, `/g-refactor`, `/g-specialize`, and anything touching `.claude/g-forge-approved`. Leave read-only reporters (`/g-status`, `/g-help`, `/g-doctor`) model-invocable.

**Effort:** S. **Risk:** low, but **read GF-40 first** — this interacts with scheduling in a non-obvious way.

**Deeper.** G-RULES §B documents auto-triggering of `/g-plan`, `/g-execute`, `/g-review` based on hook state. If those auto-triggers rely on *model* invocation, gating them breaks the auto-trigger loop. Determine whether the trigger path is (a) Claude reading hook stdout and choosing to invoke, or (b) a deterministic hook-side mechanism. If (a), the auto-trigger design and invocation gating are in direct conflict and you must pick one. **This is the single most important question in section A.**

---

#### GF-02 — Verbose skills run inline and inflate HQ context **[EVIDENCE]**

**Claim.** The README states skills "run in the main Claude session." For read-heavy skills that is exactly the context bloat the compact-return architecture was built to avoid — the discipline is applied to agents but not to skills.

**Evidence.** Skill frontmatter supports `context: fork`, executing the skill in a forked subagent rather than inline.
https://code.claude.com/docs/en/skills

**Repo check.**
```bash
rg -l "context:\s*fork" skills/
wc -l skills/*/SKILL.md | sort -rn | head -15   # biggest skills first
```

**Action.** Fork the whole-codebase scanners and synthesizers: `/g-audit`, `/g-optimize`, `/g-docs`, `/g-patterns`, `/g-identity`, `/g-trim`, `/g-blast-radius`, `/g-onboard`. Keep inline anything whose value is conversational (`/g-help`, `/g-status`, `/g-kickoff`, `/g-roadmap` — these need dialogue with the user).

**Effort:** S per skill. **Risk:** low. Forked skills lose conversational context, so any skill that asks questions must stay inline.

**Deeper.** Measure before/after with `/context` on a representative session. If forking `/g-audit` alone reclaims meaningful window, that reorders the rest of §G.

---

#### GF-03 — Commands directory is the legacy surface **[VERIFY]**

**Claim.** If G-Forge still ships `commands/*.md` rather than `skills/*/SKILL.md`, it's on the compatibility path and forgoes directory bundling, frontmatter control, and auto-loading.

**Evidence.** Custom commands have been merged into skills; `.claude/commands/deploy.md` and `.claude/skills/deploy/SKILL.md` both create `/deploy` and work the same way; existing command files keep working but skills are the recommended path, and on a name collision the skill wins.
https://code.claude.com/docs/en/skills

**Repo check.**
```bash
ls commands/ | wc -l ; ls skills/ | wc -l
# any name present in both? that collision resolves to the skill:
comm -12 <(ls commands/ | sed 's/\.md$//' | sort) <(ls skills/ | sort)
```

**Action.** If both directories exist with overlapping names, resolve the duplication — it's a silent-precedence bug waiting to confuse users. Migrate remaining commands to skills to unlock `allowed-tools`, `paths`, `context: fork`, bundled scripts, and `${CLAUDE_SKILL_DIR}`.

**Effort:** M (mechanical but broad). **Risk:** medium — router wiring and `/g-help`'s command reference both need updating in lockstep.

---

#### GF-04 — Unused frontmatter: `allowed-tools`, `paths`, `user-invocable` **[EVIDENCE]**

**Claim.** Per-skill tool scoping and path-based triggering are available and unused.

**Evidence.** Frontmatter supports `allowed-tools` (per-skill tool permissions), `paths` (path-based triggering), and `user-invocable: false` (reference content Claude loads but users don't invoke). Skills also support dynamic context injection via `!`-prefixed shell output in the body, and bundled files addressed through `${CLAUDE_SKILL_DIR}`.
https://code.claude.com/docs/en/skills

**Action.**
- `allowed-tools` on every skill — a documentation skill has no business holding Bash.
- `paths` on stack-profile rules so they trigger on the code they govern instead of loading globally (see GF-51).
- `user-invocable: false` for any G-RULES section that is reference material rather than a command.
- `!`-shell injection can replace part of what `workflow-checkpoint.sh` computes on every message — moving state gathering from every-prompt to on-demand.

**Effort:** M. **Risk:** low. **Deeper.** Quantify the token cost of `workflow-checkpoint.sh` firing on *every* UserPromptSubmit versus injecting the same state only into the skills that need it.

---

### B. Hook layer

#### GF-10 — You are using ~5 of ~27 hook events, and 1 of 5 handler types **[EVIDENCE]**

**This is the highest value-to-effort ratio in the report.**

**Claim.** G-Forge registers SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, PreCompact — all `command` type, all shell. The platform surface is far larger and several unused events map onto problems G-Forge currently solves badly or not at all.

**Evidence.** Hooks are user-defined shell commands, HTTP endpoints, MCP tools, or LLM prompts firing at lifecycle points; the reference documents async hooks, HTTP hooks, prompt hooks, and MCP tool hooks. Handler types: `command`, `http`, `mcp_tool`, `prompt`, `agent`. Per-handler options include `async`, `once: true`, an `if:` permission-rule filter, `timeout`, and `statusMessage`.
https://code.claude.com/docs/en/hooks · https://code.claude.com/docs/en/hooks-guide

Unused events with direct G-Forge relevance:

| Event | Why G-Forge needs it |
|---|---|
| **StopFailure** | Turn ended on an API error, with matchers including `rate_limit`, `overloaded`, `billing_error`. **`/g-afk` currently cannot distinguish "milestone complete" from "rate-limited and stopped."** This is a correctness bug in unattended mode, not an enhancement. |
| **SubagentStart / SubagentStop** | Per-agent lifecycle. BLOCKED detection, the attempt ledger, and wave bookkeeping belong here — deterministic, not dependent on HQ noticing. |
| **PostToolUseFailure** | Tool-level failure, distinct from task-level BLOCKED. Feeds `error-detective` automatically. |
| **PostToolBatch** | Fires after a batch — natural wave-boundary hook. |
| **PermissionRequest / PermissionDenied** | Programmatic approve/deny. Replaces `/g-afk`'s `permissions.allow` pre-configuration with something auditable. |
| **SessionEnd** | Handoff currently only written on PreCompact; a clean exit writes nothing. |
| **Setup** (`--init`, `--init-only`, `--maintenance`) | `/g-init` does provisioning work at conversation cost. `--init-only` is CI-friendly and exits after the hook. |
| **InstructionsLoaded** | Fires after CLAUDE.md/rules load and can modify or filter them — the native lever for G-RULES selective loading. |
| **ConfigChange / CwdChanged / FileChanged** | Drift detection. `/g-doctor` only runs when asked; drift is continuous. |
| **TaskCreated / TaskCompleted / TeammateIdle** | Agent-teams lifecycle (see GF-60). |
| **WorktreeCreate** | Non-git VCS support for worktree isolation (see GF-27). |

**Repo check.**
```bash
rg -o '"(SessionStart|UserPromptSubmit|PreToolUse|PostToolUse|PreCompact|Stop|StopFailure|SubagentStop|SessionEnd|Setup|InstructionsLoaded)"' templates/ hooks/ | sort -u
rg -n "exit 1" hooks/          # see GF-11
rg -n '"type":\s*"command"' templates/ | wc -l
```

**Action.** Prioritized: (1) StopFailure, (2) SubagentStop, (3) SessionEnd, (4) InstructionsLoaded, (5) PermissionRequest. Add incrementally — each is independently landable.

**Effort:** S each, M total. **Risk:** low. **Blast radius:** `/g-init` scaffold, `/g-doctor`'s check count (currently 11 — will need to grow), `/g-update` sync list.

**Deeper.** The `prompt` handler type is what `/goal` is built on (see GF-25) — a model-evaluated hook. And the `agent` handler dispatches an agent directly from a lifecycle event. Together these could replace parts of G-Forge's skill-mediated dispatch with hook-mediated dispatch, which is deterministic rather than model-dependent. Evaluate whether the review pipeline should be triggered by a hook rather than by Claude choosing to run `/g-review`.

---

#### GF-11 — Exit-code semantics **[VERIFY]**

**Claim.** Only exit code 2 blocks. Every other non-zero is a *non-blocking* error. A hook using exit 1 for enforcement is not enforcing anything.

**Evidence.** Exit 2 is blocking (stderr fed back to Claude); any other non-zero is a non-blocking error. This is documented as the single most common implementation bug.
https://code.claude.com/docs/en/hooks

**Repo check.**
```bash
rg -n "exit [013-9]" hooks/ templates/hooks/ 2>/dev/null
```

**Action.** Audit `check-commit.sh` first — if the commit gate ever exits non-2 on a block path, the gate leaks. Add this as a `/g-doctor` check.

**Effort:** S. **Risk:** this is a correctness issue on your headline feature. Treat as P0.

---

#### GF-12 — `CLAUDE_ENV_FILE` and `reloadSkills` are unused **[EVIDENCE]**

**Claim.** SessionStart hooks have capabilities G-Forge isn't using.

**Evidence.** SessionStart, CwdChanged, and FileChanged hooks receive `CLAUDE_ENV_FILE`; anything appended becomes available in all subsequent Bash commands in the session. A SessionStart hook can return `{"reloadSkills": true}` to trigger an in-session skill re-scan (same action as `/reload-skills`), and `hookSpecificOutput.sessionTitle` to set the session title.

**Action.** Use `reloadSkills` in `/g-update` so a plugin sync takes effect without a restart. Use `sessionTitle` to surface the active milestone in the session title. Use `CLAUDE_ENV_FILE` to export project state (milestone, wave, branch) as env vars instead of re-deriving them in every hook.

**Effort:** S. **Risk:** low. **Value:** `/g-update` currently requires a restart to fully land; this removes that.

---

#### GF-13 — SessionStart matcher reliability **[EVIDENCE]**

**Claim.** If any G-Forge hook group uses `"matcher": "clear"`, it silently never fires in the VS Code extension.

**Evidence.** Open bug: in the VS Code native UI, `/clear` fires SessionStart with `source: "startup"` instead of `"clear"`, so a `matcher: "clear"` group never matches. The terminal CLI behaves correctly.
https://github.com/anthropics/claude-code/issues/26794

Also relevant: `/clear` issues a new session ID and a new transcript file; `/compact` keeps the same ID. The `model` field is present in `startup` and `compact` payloads but absent in `clear` and `resume`.

**Repo check.**
```bash
rg -n '"matcher":\s*"(clear|compact|resume|startup|fork)"' templates/ hooks/
```

**Action.** Register SessionStart with no matcher and branch on `source` inside the script. Guard any read of the `model` field. Note `fork` as a fifth source value.

**Effort:** S. **Risk:** low. Cross-surface correctness fix.

---

### C. Agent roster & orchestration

#### GF-20 — The wave engine is now a platform primitive **[MEASURE]**

**Claim.** `task-decomposer` + `wave-planner` + `/g-execute` + the compact-return architecture reimplement, in prompt-space, what dynamic workflows do in code.

**Evidence.** A dynamic workflow is a JavaScript script that orchestrates subagents at scale; Claude writes it, a runtime executes it in the background, and the session stays responsive. The docs state the design goal in G-Forge's own terms: *the script holds the loop, the branching, and the intermediate results itself, so Claude's context holds only the final answer*. It also ships a quality pattern G-Forge doesn't have — independent agents adversarially reviewing each other's findings before anything is reported. Caps: 16 concurrent, 1000 total agents per run.
https://code.claude.com/docs/en/workflows

**What this would delete if adopted:** 2 agents (`task-decomposer`, `wave-planner`), 1 skill (`/g-execute`), the `docs/agent-output/` five-line return contract, the wave-boundary hold logic, and `/g-plan` Step 3d's same-wave conflict validation.

**What it would not delete:** the approval gate, the project-manager challenge, QA scope prerequisite, forecast/blast-radius integration. Those are the opinions.

**Action.** **Spike, don't migrate.** Take one completed milestone from `ROADMAP.md`, re-run it both ways, and compare: total tokens, wall-clock, context consumed in the main session, and behavior on an induced failure. Only then decide.

**Effort:** L. **Risk:** high — this is load-bearing architecture and a language-surface change (the plugin is currently 100% Shell). **Blast radius:** wide.

**Caveats to design around:** the runtime journals calls for deterministic resume, so nondeterministic functions throw inside the script — pass timestamps in as args and vary agent behavior by index. Resume works within a session; exiting mid-run means the next session restarts the workflow fresh. Requires v2.1.154+; on Pro it must be enabled in `/config`.

**Deeper.** The interesting hybrid is not all-or-nothing: keep `/g-plan` (opinionated planning, human approval) and emit *a workflow script* as the approved artifact instead of a wave schedule. The plan becomes executable and rerunnable, and `docs/plans/` becomes a directory of scripts rather than prose. Evaluate this specifically — it may be the highest-leverage change available to G-Forge.

---

#### GF-21 — The depth-0 constraint is probably obsolete, and it's documented as a hard rule **[VERIFY]**

**Claim.** The README states `review-orchestrator` must run in the main session or from a skill (depth-0), because spawning it as a nested subagent silently blocks reviewer dispatch. That constraint dates from the era when subagents could not nest.

**Evidence.** Subagents can now spawn their own subagents, capped at five levels deep, with a subagent panel showing the full tree and each row's descendant count plus a path back to main. v2.1.178 added a spawn classifier that blocks redundant or duplicative launches.
https://code.claude.com/docs/en/whats-new/2026-w24

**Repo check.**
```bash
rg -n "depth-0\|depth 0\|nested subagent\|main session" agents/review-orchestrator.md docs/ README.md
```

**Action.** **Re-test empirically**, then correct the README, the agent file, and G-RULES §C. Wrong documentation in a workflow plugin is worse than missing documentation, because users architect around it. If the constraint is gone, an entire class of orchestration designs reopens.

**Effort:** S to test, M to propagate the correction. **Risk:** low. **Priority:** high — this claim is currently published and probably false.

**Related gotcha.** Inside a subagent definition, a `tools: Agent(...)` allowlist is reportedly ignored at runtime; it only enforces when the agent runs as the main thread via `claude --agent`. **If G-RULES §C's "agent caps" depend on that, they may not bind.** Verify.

---

#### GF-22 — Model tiering: partially superseded **[EVIDENCE]**

**Claim.** G-Forge assigns Haiku/Sonnet/Opus per agent across the roster. Two native mechanisms now cover part of this more cheaply.

**Evidence.** The advisor tool pairs a fast main model with a stronger advisor consulted at decision points — before committing to an approach, when stuck on a recurring error, before declaring a task complete. The advisor receives the full conversation including every tool call and result. Because it's called at decision points rather than every turn, fast-main + strong-advisor typically costs less than running the strong model throughout, and toggling `/advisor` mid-session does not invalidate the main model's prompt cache.
https://code.claude.com/docs/en/advisor

Separately, `CLAUDE_CODE_SUBAGENT_MODEL` sets a default subagent tier, making per-agent overrides exceptions rather than the rule.

**Action.** Keep explicit tiering for the review pipeline where a missed finding is expensive. Consider the advisor for `code-lead`'s merge verdict specifically — that's a decision point, which is the shape the advisor is built for. Set a roster-wide default via env and prune redundant per-agent declarations.

**Effort:** S. **Risk:** low.

**Hard constraint:** the advisor is experimental and **requires the Anthropic API** — unavailable on Bedrock, Claude Platform on AWS, Google Cloud's Agent Platform, and Microsoft Foundry. If G-Forge claims to work anywhere, this must be optional and feature-detected. See GF-45.

---

#### GF-23 — Review pipeline overlaps native review **[EVIDENCE]**

**Claim.** Six of the seventeen agents constitute a reviewer swarm. Anthropic now ships one.

**Evidence.** `/code-review` is a bundled skill with five effort levels from a quick local pass up to multi-agent cloud analysis, plus `--comment` (post to the PR) and `--fix` (apply findings to the working tree). `/code-review ultra` runs the deep cloud review — multiple reviewer agents in a sandbox, each attacking from a different angle, reporting only independently reproduced and verified bugs — without consuming local context.
https://code.claude.com/docs/en/code-review · https://code.claude.com/docs/en/ultrareview

**Action.** Do **not** delete the pipeline wholesale. The separable pieces are:
- **The swarm** (parallel reviewers finding issues) — increasingly commodity.
- **The gate** (MERGE READY / HOLD, no partial merges, sentinel consumed per commit, Tier 3 human smoke test) — entirely yours and uncontested.

Consider making the swarm pluggable: `/g-review` orchestrates its own agents *or* delegates to `/code-review ultra`, then applies G-Forge's verdict semantics to whatever comes back. That preserves the differentiator while outsourcing the expensive part.

**Effort:** M. **Risk:** medium — verdict mapping between two systems needs care. **Note:** `/code-review` is marked `disable-model-invocation`, which has scheduling consequences (GF-40).

**Deeper.** Ultrareview reads CLAUDE.md — reviewers honor project rules stated there. Since `/g-init` already injects G-rules into CLAUDE.md, a delegated review may already inherit G-Forge's architectural constraints for free. Verify; if true, the delegation is much cheaper than it looks.

---

### D. Unattended execution & safety

#### GF-25 — `/g-afk` should not hand-roll completion detection **[EVIDENCE]**

**Claim.** `/g-afk` runs waves then review and stops on BLOCKED or safety violation. It has no evaluator — nothing independently judges whether the milestone's objective was actually met.

**Evidence.** `/goal` sets a completion condition; after each turn a small fast model (Haiku by default) evaluates whether it holds and starts another turn if not. It is implemented as a session-scoped prompt-based Stop hook. Conditions want one measurable end state, a stated check, constraints, and a bound such as `or stop after 20 turns`; up to 4,000 characters. It works headless — `claude -p "/goal <condition>"` runs the loop to completion in one invocation — and through Remote Control. `/goal` with no argument reports turns, tokens, and the evaluator's most recent reason. A goal active at session end is restored on `--resume`/`--continue`, though the turn count, timer, and token baseline reset.
https://code.claude.com/docs/en/goal

**Critical constraint — design around this or it will silently lie to you.** The evaluator does not run commands or read files. It judges only what Claude has surfaced in the conversation. `"npm test exits 0"` works because the result lands in the transcript. **A Tier 3 criterion that requires a human looking at a screen cannot be a goal condition, and a plausible-sounding claim in the transcript will satisfy the evaluator.**

**Action.** Restructure the QA scope compilation in `/g-plan` Step 0 to classify every criterion as:
- **machine-demonstrable** → compiles into the `/goal` condition,
- **judgment-required** → becomes a hard stop that ends the unattended run and escalates.

That classification is a genuine G-Forge contribution and slots directly into the existing three-tier testing model: Tier 1/2 are goal-eligible, Tier 3 is not.

**Effort:** M. **Risk:** medium — this changes what "unattended" means and must be documented honestly.

**Requirements:** `/goal` needs a trusted workspace (the evaluator is part of the hooks system) and is unavailable if `disableAllHooks` is set in managed policy.

---

#### GF-26 — Deny-strings are the wrong safety primitive **[EVIDENCE]**

**Claim.** `/g-afk` configures `permissions.deny` to block `git push`, `rm -rf`, publish commands, and writes outside the project. That's pattern matching on command text — bypassed by any command shape not anticipated.

**Evidence.** The sandboxed Bash tool provides OS-level enforcement (Seatbelt on macOS; bubblewrap + socat on Linux/WSL2): write access defaults to the working directory and session `$TMPDIR`, read access to the system except denied paths, no network domains pre-allowed. Auto mode adds a two-stage classifier with documented hard blocks around `curl | bash`, production deploys, destructive shared-infrastructure changes, and force-pushing main, plus a prompt-injection probe that screens tool results before the agent sees them. The layers compose: sandbox auto-allow approves Bash because the boundary contains it; auto mode classifies actions; explicit deny rules still apply on top; PreToolUse hooks can still block with exit 2.
https://code.claude.com/docs/en/sandboxing · https://code.claude.com/docs/en/auto-mode-config · https://www.anthropic.com/engineering/claude-code-auto-mode

**Two configuration traps to fix on adoption:**
1. The default sandbox read policy permits reading `~/.aws/credentials` and `~/.ssh/`. The docs themselves recommend adding both to `sandbox.filesystem.denyRead` before long unattended runs.
2. **The sandbox fails open.** Missing dependencies, unsupported platform → warning, then commands run *unsandboxed*. Set `sandbox.failIfUnavailable: true` for anything calling itself a safety net.

**Action.** Rewrite `/g-afk`'s safety configuration to layer sandbox + auto mode + a minimal explicit deny list, rather than relying on deny strings alone. Keep the deny list as defense in depth, not as the mechanism.

**Effort:** M. **Risk:** low downside, large upside. **Platform note:** not supported on native Windows or WSL1 — needs a documented fallback (GF-45).

**Deeper.** The README's tip recommends `claude --dangerously-skip-permissions` for fully unattended mode. Given sandbox + auto mode now exist, that recommendation is outdated and arguably irresponsible to publish. Revisit it. Note also that bypass mode auto-approves MCP tool calls — if a user has MCP servers touching databases or deploys, those run unattended.

---

#### GF-27 — Worktrees dissolve the same-wave conflict problem **[EVIDENCE]**

**Claim.** `/g-plan` Step 3d blocks on same-wave file conflicts. That's policing a constraint that can be removed.

**Evidence.** Worktrees (`--worktree`) isolate parallel sessions in separate git worktrees so changes don't collide, with `.worktreeinclude` for carrying gitignored files across, subagent isolation, cleanup handling, and a `WorktreeCreate` hook for non-git VCS. Multi-agent guidance is explicit that teams of four or more should give each worker its own worktree.
https://code.claude.com/docs/en/worktrees

**Action.** Offer worktree-isolated execution as a `/g-execute` mode. Demote the conflict validator to a fallback for the non-worktree path. This also raises the viable wave width, which is your primary cost lever.

**Effort:** M. **Risk:** medium — merge-back is new surface area and needs a failure story.

---

### E. Context, memory, and recovery

#### GF-30 — The context-depth counter is a proxy for a number you can now read **[EVIDENCE]**

**Claim.** `.claude/session-prompt-count` counts exchanges and applies hardcoded thresholds (25/40 implementation, 35/55 conversation). `/g-plan` Step 3c estimates cost as `5 + waves×3 + agents×2 + tasks×1` exchanges. Both are proxies, and both mispredict in *both* directions: one large file read blows the budget at exchange three; forty terse exchanges consume almost nothing.

**Evidence.** The statusline can display live context-window usage; `/context` shows what's loaded and what each piece costs; `/usage` breaks down token usage and what's driving plan limits, including which skills, subagents, and MCP servers contribute. There is also an interactive doc on how the context window fills during a session.
https://code.claude.com/docs/en/statusline · https://code.claude.com/docs/en/context-window · https://code.claude.com/docs/en/debug-your-config

**Action.** Keep the *policy* — stop taking new scope when the window is filling, auto-`/g-retro` at red, write handoff before ending. Replace the *estimator* with the real measurement. Ship a G-Forge statusline showing milestone · wave · gate · real context %.

**Effort:** M. **Risk:** low. **Value:** removes an entire class of "G-Forge told me I was fine and then I ran out" failures. **Bonus:** a statusline is a visible, differentiating surface for the plugin.

---

#### GF-31 — No recovery story for a half-written BLOCKED task **[EVIDENCE]**

**Claim.** When a wave task fails mid-write, G-Forge surfaces a blocker and a fix strategy but has no mechanism to restore the tree.

**Evidence.** Checkpointing tracks, rewinds, and summarizes Claude's edits and conversation; the Agent SDK exposes file checkpointing to restore files to any previous state. Separately, as of week 26 (June 22–26, 2026), `/rewind` can resume a conversation from *before* a `/clear`.
https://code.claude.com/docs/en/checkpointing · https://code.claude.com/docs/en/whats-new/2026-w26

**Action.** Wire checkpoint-before-wave into `/g-execute` and offer rewind-to-wave-start as a recovery option in the BLOCKED cycle-break report. This is a genuinely missing capability, not a redundancy.

**Effort:** M. **Risk:** low. **Priority:** high — it converts a hard failure into a recoverable one.

---

#### GF-32 — Memory taxonomy may be a parallel system **[VERIFY]**

**Claim.** G-RULES §J defines a six-tier memory taxonomy and `/g-trim` audits it. Native memory now covers persistent CLAUDE.md instructions *plus* auto memory, where Claude accumulates learnings automatically.

**Evidence.** https://code.claude.com/docs/en/memory · https://code.claude.com/docs/en/claude-directory

**Action.** Diff §J against native auto memory. Where they overlap, defer to native and shrink §J. Also diff `/g-init`'s scaffold against the documented `.claude` directory layout — that page documents exactly where Claude Code reads CLAUDE.md, settings, hooks, skills, commands, subagents, workflows, rules, and auto memory. A scaffold that fights the documented layout will keep breaking.

**Effort:** M. **Risk:** medium — memory is where user-visible behavior regressions hide.

---

#### GF-33 — Telemetry collection is reinvented; the metrics are not **[EVIDENCE]**

**Claim.** `/g-telemetry` computes eight reliability metrics and writes `.claude/telemetry-profile`, which `/g-execute` and `/g-review` read to scale wave size, model tier, and reviewer count. The *derived metrics* are a real contribution. The *collection layer* is not.

**Evidence.** OpenTelemetry export of traces, metrics, and events is supported for both Claude Code and the Agent SDK; `/usage` provides per-surface attribution; there's an analytics dashboard and a Claude Code Analytics API.
https://code.claude.com/docs/en/monitoring-usage · https://code.claude.com/docs/en/analytics

**Action.** Keep hallucination rate, review catch rate, regression rate, rework, spec deviation, escalation — those are yours and nothing native computes them. Source token efficiency and retry dependency from OTel/`/usage` instead of hand-counting. Adaptive orchestration is a strong, differentiated feature; give it better inputs.

**Effort:** M. **Risk:** low. **Deeper.** With OTel wired, `/g-identity` and `/g-patterns` get quantitative grounding rather than retro-mining alone.

---

### F. Scaffolding, profiles, distribution

#### GF-40 — Scheduling and invocation gating are in direct tension **[EVIDENCE]** ⚠️

**Read this before implementing GF-01.**

**Claim.** Gating skills with `disable-model-invocation` makes them unschedulable.

**Evidence.** As of v2.1.196, a scheduled fire only runs skills Claude is allowed to invoke on its own. Built-in commands such as `/permissions`, `/model`, or `/clear` reach Claude as plain text instead of executing — **and so do skills marked `disable-model-invocation: true`**, including the bundled `/verify` and `/code-review`, as well as skills withheld by a `skillOverrides` setting or a Skill deny rule.
https://code.claude.com/docs/en/scheduled-tasks

**Consequence.** The skills you most want to gate (`/g-review`, `/g-execute`, `/g-afk`) are exactly the ones that cannot be a `/loop` payload.

**Action.** Split the surface deliberately:
- **Gated, user-invoked:** anything issuing a verdict or mutating the gate.
- **Ungated orchestrator:** a thin scheduled entry point that *reads state and reports*, escalating rather than executing.

Document this explicitly in G-RULES §B so the design intent survives contact with future contributors.

**Effort:** S to decide, M to implement. **Risk:** getting this wrong either leaves the gate model-invocable (unsafe) or breaks scheduled automation (silently — the skill arrives as plain text and nothing happens).

---

#### GF-41 — `/g-doctor` should incorporate native diagnostics **[EVIDENCE]**

**Evidence.** `--safe-mode` (or `CLAUDE_CODE_SAFE_MODE`) launches with all customizations disabled — CLAUDE.md, skills, plugins, hooks, MCP servers, custom commands and agents — while keeping auth, model selection, built-in tools, and permissions. There's a dedicated page on diagnosing why CLAUDE.md, settings, hooks, MCP servers, or skills aren't taking effect, using `/context`, `/doctor`, `/hooks`, and `/mcp`. `/doctor` itself is a bundled skill.
https://code.claude.com/docs/en/debug-your-config · https://code.claude.com/docs/en/whats-new/2026-w24

**Action.** `--safe-mode` is **the definitive bisect for "is G-Forge the problem?"** — put it in `/g-doctor`'s output and the troubleshooting docs. Have `/g-doctor` call `/hooks` and `/context` rather than inferring registration from settings.json alone. Rename or namespace to avoid confusion with the bundled `/doctor`.

**Effort:** S. **Risk:** low. **Support value:** high.

---

#### GF-42 — Distribution and update machinery is hand-rolled **[EVIDENCE]**

**Claim.** `workflow-checkpoint.sh` polls GitHub daily; `/g-update` git-pulls the cache and re-syncs files.

**Evidence.** The platform provides plugin dependency version constraints (so a plugin survives an upstream breaking change), marketplaces, plugin relevance blocks (Claude suggests your plugin when a user's work matches), plugin hints (a one-line CLI marker prompting installation), loading plugins from `.zip` archives and URLs, and `/plugin list`.
https://code.claude.com/docs/en/plugin-dependencies · https://code.claude.com/docs/en/plugin-relevance · https://code.claude.com/docs/en/plugins-reference · https://code.claude.com/docs/en/discover-plugins

**Action.** Declare dependency version constraints — G-Forge is the *most* version-sensitive kind of plugin, since half this report is version-gated. Add a relevance block for discovery. Consider whether the daily GitHub poll is still worth its complexity given native update surfacing. Pair with GF-12's `reloadSkills` so `/g-update` lands without a restart.

**Effort:** M. **Risk:** low. **Growth value:** relevance blocks and hints are distribution levers a 3-star repo should be using.

---

#### GF-43 — The commit gate is locally deletable **[EVIDENCE]**

**Claim.** The README documents the bypass: `rm .claude/hooks/check-commit.sh`. A gate that the gated party can delete is a convention, not enforcement — which is *fine* for a solo local workflow, but it caps G-Forge's addressable use case at "developer disciplining themselves."

**Evidence.** Claude Code GitHub Actions and GitLab CI/CD integrations exist, as does managed Code Review for pull requests, plus `allowManagedHooksOnly` for enterprise administrators to block user, project, and plugin hooks (with plugins force-enabled in managed settings exempt).
https://code.claude.com/docs/en/github-actions · https://code.claude.com/docs/en/gitlab-ci-cd · https://code.claude.com/docs/en/hooks

**Action.** Offer a CI-side companion that enforces the same verdict server-side. This is the single clearest path from "personal workflow plugin" to "team-adoptable process," and it strengthens the one thing G-Forge has that nothing native does.

**Effort:** L. **Risk:** medium. **Strategic value:** highest in the report.

---

#### GF-44 — Stack profiles vs. native large-codebase guidance **[VERIFY]**

**Claim.** 48 profiles + 7 combos + 1 supplementary is a large, manually maintained surface. Some of it may be better expressed natively.

**Evidence.** There's dedicated guidance for monorepos and large codebases covering nested CLAUDE.md files, sparse worktrees, code intelligence, and per-package skills so Claude stays focused on the code being worked in. Skills support `paths` for path-based triggering.
https://code.claude.com/docs/en/large-codebases

**Action.** Evaluate expressing architecture rules as path-triggered skills rather than globally-appended CLAUDE.md rules. In a monorepo, the current global-append model loads every stack's rules everywhere — path triggering fixes that and reduces per-session tokens.

**Effort:** L (48 profiles). **Risk:** medium. **Do this only if** GF-02/GF-04 measurements show rule loading is a material context cost.

---

#### GF-45 — G-Forge now needs a compatibility matrix **[EVIDENCE]**

**Claim.** The README's promise is "any Claude Code project." Adopting the best of this report breaks that promise silently on some platforms.

**Evidence.** Advisor: Anthropic API only. Channels: not on Bedrock/Vertex/Foundry, requires Bun, needs org enablement on Team/Enterprise. Dynamic workflows: Pro must enable in `/config`. Sandbox: not on native Windows or WSL1. Agent teams: off by default behind an env var. There is a feature-availability page comparing what's available across subscription plans, Console, Bedrock, Claude Platform on AWS, Google Cloud's Agent Platform, and Microsoft Foundry.
https://code.claude.com/docs/en/feature-availability

**Action.** Add feature detection to `/g-doctor` and a compatibility table to the README. Every adopted feature needs a documented degradation path. **Silent degradation is the failure mode to avoid** — a user on Bedrock whose `/g-afk` safety net quietly isn't sandboxed is worse off than one who was told to configure differently.

**Effort:** M. **Risk:** low. **Priority:** rises with each feature adopted.

---

#### GF-46 — Language surface is about to change **[EVIDENCE]**

**Claim.** The repo is 100% Shell. Dynamic workflows are JavaScript. Channel plugins need Bun. Structured outputs need the SDK. Hooks support HTTP and MCP handlers. Adopting the strongest findings changes G-Forge's dependency footprint and install story.

**Action.** Decide this deliberately and early, because it constrains GF-20, GF-33, GF-60, and GF-61. Options: (a) stay shell-only and accept a smaller adoption set; (b) allow an optional JS/Bun tier with graceful degradation; (c) migrate wholesale. Record it as an ADR via `/g-adr` — this is exactly the kind of decision that page exists for.

**Effort:** decision only. **Risk:** deferring it means discovering it mid-implementation.

---

### G. New surfaces with no G-Forge equivalent

#### GF-60 — Agent teams: peer sessions, not subagents **[EVIDENCE]**

**Evidence.** One session acts as team lead; teammates are **full Claude Code sessions**, each with its own context window, coordinating through a shared task list and messaging each other directly without routing through the lead. Dependencies are respected; file locking prevents conflicts. Lifecycle hooks: `TeammateIdle`, `TaskCreated`, `TaskCompleted`. Experimental and **disabled by default** — set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`; without it no team is set up, no team directories are written, and Claude won't propose teammates. Documented known limitations around session resumption, task coordination, and shutdown.
https://code.claude.com/docs/en/agent-teams · https://code.claude.com/docs/en/agent-view

**Why it matters to G-Forge.** This is the fresh-context-per-worker model the wave architecture approximates with subagents. Practice guidance aligns well with the wave model: tasks sized at 5–15 minutes, explicit file ownership per teammate, worktrees beyond 3–4 teammates.

**Action.** Prototype only. Too experimental to depend on, too aligned with G-Forge's model to ignore. The `TaskCompleted` hook alone would give milestone bookkeeping for free.

**Effort:** L. **Risk:** high (experimental).

---

#### GF-61 — Channels close the Tier 3 and escalation loop **[EVIDENCE]**

**Evidence.** A channel is an MCP server that pushes events into a running session so Claude can react while you're away; it can be two-way. Documented patterns include a **webhook receiver** — a webhook from CI, an error tracker, or a deploy pipeline arrives where Claude already has your files open. Channel servers can declare a **permission relay** capability, forwarding permission prompts so you approve or deny remotely. Events only arrive while the session is open, so an always-on setup needs a background process or persistent terminal. In `-p` mode, tools needing terminal input (multiple-choice, plan approval) are disabled so the session never stalls.

Research preview, v2.1.80+, Anthropic auth only, Bun required, opt-in per session via `--channels`, sender allowlist, org toggle on Team/Enterprise.
https://code.claude.com/docs/en/channels · https://code.claude.com/docs/en/channels-reference

**Why it matters.** `/g-listen` collects Tier 3 findings by asking the user to type them. A channel lets CI failures push themselves in, and lets the human report a smoke-test bug from their phone into the session that has the files open. Permission relay is the missing piece for a run that's unattended but occasionally needs judgment.

**Action.** Evaluate a G-Forge channel for `/g-listen` intake and `/g-afk` escalation. Build-your-own is documented in the channels reference.

**Effort:** L. **Risk:** high (preview + Bun dependency, see GF-46).

---

#### GF-62 — Three scheduling surfaces, none used **[EVIDENCE]**

**Evidence.**
- **`/loop` + cron tools** (v2.1.72+): session-scoped. With an interval, Claude converts to a cron expression and returns a job ID; without one, Claude picks a delay between one minute and one hour after each iteration based on what it observed, printing the delay and its reason. Bare `/loop` runs a built-in maintenance prompt (continue unfinished work, tend the branch's PR, cleanup), overridable via `.claude/loop.md` or `~/.claude/loop.md`. 50 tasks per session; recurring loops expire after seven days; `--resume`/`--continue` restores unexpired ones. Underlying tools: `CronCreate`, `CronList`, `CronDelete`.
- **Desktop scheduled tasks:** persistent, and **each run fires a fresh session** with full access to files, MCP servers, skills, connectors, and plugins.
- **Routines:** run on Anthropic-managed cloud infrastructure, triggered by schedule, API call, or GitHub event.
https://code.claude.com/docs/en/scheduled-tasks · https://code.claude.com/docs/en/desktop-scheduled-tasks · https://code.claude.com/docs/en/routines

**Action.** `.claude/loop.md` is a notable free win: G-Forge could ship a project-level default that makes bare `/loop` do the *G-Forge* maintenance pass (check gate state, continue the active wave, run `/g-status`) instead of the generic one. Small, elegant, on-brand. **Subject to GF-40's constraint.**

**Effort:** S for the `loop.md` default. **Risk:** low.

---

#### GF-63 — Smaller opportunities worth a line each **[EVIDENCE]**

| Feature | G-Forge fit |
|---|---|
| **Artifacts** — publish session output as a live shareable page at a private claude.ai URL | `/g-afk` handoff reports, `/g-identity`, `/g-retro` output |
| **Structured outputs (SDK)** — JSON Schema / Zod / Pydantic validated returns | The five-line agent return contract is currently parse-and-hope |
| **Ultraplan** — plan in the CLI, draft on the web, execute remotely or locally | Overlaps `/g-plan`'s approval-gate shape |
| **Computer use (CLI) + Chrome integration** | The automatable half of Tier 3 smoke testing |
| **Deep links** (`claude-cli://`) | Launch a G-Forge session in the right repo from a runbook or alert |
| **Output styles** | Overlaps `/g-voice`'s dev/mid/eli5 profiles — check before extending |
| **Prompt caching behavior** | Documents why CLAUDE.md edits don't apply mid-session — directly relevant to `/g-update`'s sync model |
| **Remote Control** | The human-reachable escalation path for unattended runs |
| **Fast mode / `/effort` levels** | Another cost lever alongside model tiering |

---

## 3. Cross-cutting conflicts

1. **GF-01 vs GF-40** — invocation gating breaks schedulability. Resolve the split before implementing either.
2. **GF-01 vs G-RULES §B auto-triggers** — if auto-triggering depends on model invocation, gating kills it. Determine the mechanism first.
3. **GF-20 vs GF-46** — the workflow engine is JavaScript; the plugin is Shell. The language decision gates the architecture decision.
4. **GF-21 vs published docs** — the README currently states a constraint that is probably false. Users are architecting around it.
5. **GF-23 vs GF-40** — `/code-review` is itself `disable-model-invocation`, so a delegated review can't be scheduled either.
6. **GF-26 vs the README's `--dangerously-skip-permissions` tip** — that recommendation predates sandbox and auto mode and should be revised.
7. **GF-45 vs everything in §G** — each new-surface adoption narrows the platform matrix.

---

## 4. Suggested milestone structure

Independently landable, ordered by value density, shaped for `/g-roadmap` intake.

**M-A · Correctness pass (P0, small, no architecture change)**
GF-11 exit codes · GF-21 re-test and correct the depth-0 claim · GF-13 SessionStart matcher · GF-10 StopFailure hook only
*Rationale: these are bugs and wrong documentation, not enhancements.*

**M-B · Invocation & context hygiene**
GF-40 decide the split · GF-01 gating · GF-02 `context: fork` · GF-04 `allowed-tools` · GF-30 real context reporting + statusline
*Rationale: cheap, compounding, user-visible.*

**M-C · Safety and recovery**
GF-26 sandbox + auto mode · GF-31 checkpointing · GF-25 `/goal` with the machine/judgment split · GF-45 compatibility matrix
*Rationale: converts hard failures into recoverable ones and makes "unattended" an honest claim.*

**M-D · Hook layer expansion**
Remainder of GF-10 · GF-12 `reloadSkills`/`CLAUDE_ENV_FILE` · GF-41 `/g-doctor` + `--safe-mode`
*Rationale: moves enforcement from model-dependent to deterministic.*

**M-E · Architecture spike (gated on GF-46)**
GF-20 workflow-vs-wave measurement · GF-27 worktrees · GF-23 pluggable review swarm
*Rationale: potentially deletes three agents and two skills. Measure first, migrate never-before-measuring.*

**M-F · Reach and distribution**
GF-43 CI-side gate · GF-42 plugin dependencies/relevance · GF-33 OTel telemetry
*Rationale: strengthens the one uncontested differentiator and makes it team-adoptable.*

**Backlog / watch**
GF-60 agent teams · GF-61 channels · GF-44 profile restructuring · GF-62 `loop.md` default · GF-63 misc

---

## 5. Version and availability gates

| Capability | Gate |
|---|---|
| Scheduled tasks / `/loop` | v2.1.72+ |
| Scheduled-fire skill restrictions (GF-40) | v2.1.196+ behavior |
| Channels | v2.1.80+, research preview, Anthropic auth only, Bun, org toggle on Team/Enterprise |
| Agent teams | `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`, experimental (referenced from v2.1.32) |
| Dynamic workflows | v2.1.154+, research preview, paid plans; Pro enables via `/config` |
| Nested subagents | v2.1.172+ (depth 5); spawn classifier v2.1.178+ |
| Remote Control | research preview; off by default on Team/Enterprise until an Owner enables |
| Advisor tool | experimental, Anthropic API only — not Bedrock/AWS/GCP/Foundry |
| Sandbox | macOS Seatbelt; Linux/WSL2 bubblewrap + socat; **not** native Windows or WSL1 |
| `/goal` | trusted workspace required; unavailable if `disableAllHooks` in managed policy |
| `--bare` | **never use with G-Forge** — skips hooks, skills, plugins, MCP, and CLAUDE.md discovery |

Re-verify all of these against `https://code.claude.com/docs/llms.txt` and the `whats-new/` digests before planning around them.

---

## 6. Deeper investigation queue

Ordered by how much downstream design they unblock. Each needs repo access plus a live doc fetch.

1. **Does `review-orchestrator` still fail when nested?** Gates GF-21, GF-20, and the correction of published documentation.
2. **Is the auto-trigger loop model-invoked or hook-deterministic?** Gates GF-01, GF-40, and the coherence of G-RULES §B.
3. **Workflow vs. wave on a real milestone** — tokens, wall-clock, main-session context, induced-failure behavior. Gates M-E entirely.
4. **Does `tools: Agent(...)` actually cap subagents?** If not, G-RULES §C claims enforcement it doesn't have.
5. **Does a delegated `/code-review ultra` inherit G-rules via CLAUDE.md?** If yes, GF-23 gets dramatically cheaper.
6. **What does `workflow-checkpoint.sh` cost per prompt?** It fires on every message. Gates GF-04 and GF-30.
7. **How much context do stack-profile rules consume in a monorepo?** Gates GF-44's 48-profile restructure.
8. **Does `/g-init`'s scaffold still match the documented `.claude` layout?** Silent drift here breaks quietly.
9. **What's in `whats-new/2026-w27` onward?** This report's evidence ends around 2026-07-25. Anything newer is unaudited.

---

## 7. Honest summary

G-Forge's mechanisms are depreciating; its opinions are not. The wave engine, context estimator, safety net, telemetry collector, and reviewer swarm all now have first-party equivalents that are better-resourced and improving weekly. Maintaining parallel implementations of those is a recurring cost with no differentiation return.

What no one else ships: **a commit gate that cannot be opened without a full review verdict, a mandatory human sign-off on whether the thing actually works, and project-level roadmap discipline that challenges scope before committing to it.** That is the product. Every hour reclaimed from mechanism maintenance is an hour available to make that harder to argue with — and GF-43, making the gate enforceable outside one developer's laptop, is the highest-leverage item in this document.

---

## Appendix — primary sources

Index: `https://code.claude.com/docs/llms.txt`

`/en/workflows` · `/en/agent-teams` · `/en/agents` · `/en/agent-view` · `/en/sub-agents` · `/en/goal` · `/en/scheduled-tasks` · `/en/routines` · `/en/desktop-scheduled-tasks` · `/en/channels` · `/en/channels-reference` · `/en/hooks` · `/en/hooks-guide` · `/en/skills` · `/en/sandboxing` · `/en/sandbox-environments` · `/en/auto-mode-config` · `/en/permissions` · `/en/permission-modes` · `/en/worktrees` · `/en/checkpointing` · `/en/memory` · `/en/claude-directory` · `/en/statusline` · `/en/context-window` · `/en/debug-your-config` · `/en/code-review` · `/en/ultrareview` · `/en/ultraplan` · `/en/advisor` · `/en/monitoring-usage` · `/en/analytics` · `/en/plugins-reference` · `/en/plugin-dependencies` · `/en/plugin-relevance` · `/en/discover-plugins` · `/en/large-codebases` · `/en/feature-availability` · `/en/headless` · `/en/remote-control` · `/en/artifacts` · `/en/github-actions` · `/en/gitlab-ci-cd` · `/en/computer-use` · `/en/chrome` · `/en/deep-links` · `/en/prompt-caching` · `/en/whats-new/2026-w24` · `/en/whats-new/2026-w26`

Non-Anthropic: `https://github.com/anthropics/claude-code/issues/26794` (SessionStart `clear` matcher bug, VS Code), `https://www.anthropic.com/engineering/claude-code-auto-mode`
