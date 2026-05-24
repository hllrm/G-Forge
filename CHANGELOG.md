# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.5.0] — 2026-05-24

### Added

- **Compact return architecture — all 15 dispatched agents** — every agent writes full output to disk and returns a five-line compact block to the calling session. The main session reads the detail file only on HOLD or BLOCKED. Per-agent context growth drops from ~1,500–3,000 tokens to ~70 tokens. `pr-writer` and `project-manager` are intentionally excluded — they are user-facing with no intermediate caller.
- **`/g-plan` Step 3d — wave dependency validation** — checks the wave schedule for same-wave file conflicts (parallel write race — blocking), missing source files for mutation tasks (blocking), and cross-wave output ordering violations (warning surfaced in approval gate under `### Dependency risks`). Runs after wave-planner returns, before the forecast handoff.
- **`/g-plan` Step 3c — context budget check** — estimates plan execution cost (`5 + waves×3 + agents×2 + tasks×1` exchanges) and compares against remaining session budget. Tight fit warns in Step 4. Over budget blocks and offers `/g-roadmap` split or explicit risk acceptance.
- **Session-start hook (`session-start.sh`)** — fires once per session open. Checks branch, uncommitted changes, stash count, ahead/behind vs remote, and feature branch drift behind `origin/main`. Resets the per-session prompt counter.
- **`docs/agent-output/` directory structure** — all wave and review agent output is written to `docs/agent-output/wave-N/<task-slug>.md` and `docs/agent-output/review/<agent>-YYYY-MM-DD.md`. Full audit trail on disk without main-session context cost.

### Changed

- **Context depth management** — `workflow-checkpoint.sh` classifies sessions as `implementation` (25 amber / 40 red) or `conversation` (35 amber / 55 red) from git signals. Amber explicitly warns the user and runs `/context`. Red enforces: no new scope, `/g-retro` auto-triggers, session end required.
- **G-RULES.md selective loading** — ten sections available as individual `@`-referenced files. Projects reference only the sections they need; minimal projects save ~5,400 tokens per session.
- **B-workflow.md slim** — core skills reference table trimmed to 8 entries with pointer to `/g-help` for full reference.
- **README** — added "How G-Forge works" conceptual primer (Skills vs Agents, wave model, commit gate, G-RULES.md, hooks) and "Token cost saving strategy" section documenting all six cost controls with concrete numbers.

## [1.3.6] — 2026-05-24

### Added

- **`/g-plan` Step 3d — wave dependency validation** — after wave-planner returns, validates the schedule structurally before execution: (1) same-wave file conflicts (two tasks in parallel writing the same file — halts until wave-planner resolves), (2) missing source files for mutation tasks (update/modify/refactor on a file that doesn't exist and no earlier wave creates it — blocking), (3) cross-wave output dependency ordering (task references another task's output but both are in the same wave — warning). Blockers halt the plan; warnings surface in the Step 4 approval gate under `### Dependency risks`.

### Changed

- **Compact return format — all agents** — the remaining 9 agents (`debugger`, `doc-writer`, `error-detective`, `refactor-executor`, `review-orchestrator`, `spec-writer`, `task-decomposer`, `test-writer`, `wave-planner`) now write full output to disk and return compact five-line summaries. All 17 agents now have `## Return format` sections. `pr-writer` and `project-manager` are intentionally excluded — they are user-facing and their inline output is the deliverable.

## [1.3.5] — 2026-05-24

### Changed

- **Agent compact return format** — all six review agents (`code-reviewer`, `security-auditor`, `architecture-enforcer`, `code-lead`, `performance-auditor`, `dependency-auditor`) now write full findings to a disk file and return a five-line compact block (`RESULT / ISSUES / SUMMARY / DETAIL`) to the calling session. Main session reads the detail file only on HOLD or BLOCKED — not on every run. Reduces main-session context growth from ~1,500–3,000 tokens per agent return to ~70 tokens.
- **`g-execute` compact dispatch template** — each wave task now receives a compact prompt including an `output_file:` path. Agents write implementation summaries to `docs/agent-output/wave-N/<task-slug>.md`. Wave completion gate parses compact `RESULT / SUMMARY / FILES / DONE_CONDITION / DETAIL`; the detail file is read only for BLOCKED tasks. Creates `docs/agent-output/wave-N/` directories before each wave.
- **`g-review` output file threading** — `code-lead` and `dependency-auditor` dispatched from g-review now receive an `output_file:` path (`docs/agent-output/review/code-lead-YYYY-MM-DD.md` and `docs/agent-output/review/dependency-auditor-YYYY-MM-DD.md`). g-review parses compact returns and reads the detail file only on HOLD or ESCALATE.

## [1.3.4] — 2026-05-23

### Added

- **`/g-plan` Step 3c — context budget check** — after wave-planner returns, estimates the plan's exchange cost using `5 + waves×3 + agents×2 + tasks×1`. Compares against remaining session budget (red threshold 40 − current depth). Three outcomes: fits (proceed), tight (warn in Step 4), or over budget (block and present split/proceed choice). Cost estimate appears in Step 4's approval block under a `### Budget` line.
- **Split path invokes `/g-roadmap`** — when the developer chooses to split, `/g-roadmap` is invoked with budget-per-sub-milestone context and produces a revised ROADMAP.md. The current `/g-plan` run stops; the developer re-plans on the first sub-milestone.

## [1.3.3] — 2026-05-23

### Changed

- **A7 context gate: amber warns, red enforces** — amber now requires surfacing an explicit user-facing message ("Context is getting full — finish what's in flight, then run /g-retro before we start anything new"). Red is fully enforced: no new scope accepted, `/g-retro` auto-triggers when the current task finishes, session end is mandated.
- `workflow-checkpoint.sh` amber/red messages updated to match: amber says "warn user", red says "ENFORCED".

## [1.3.2] — 2026-05-23

### Changed

- **Context depth: mode-aware thresholds** — `workflow-checkpoint.sh` now classifies each session as `implementation` (recent commits, dirty tree, or active plan files present) or `conversation` (clean). Implementation thresholds: 25 amber / 40 red. Conversation thresholds: 35 amber / 55 red. Mode is shown in the warning line.
- **Amber action protocol in `A-session.md`** — at amber, run `/context` to read actual window percentage. ≥ 50% remaining: continue current task only. < 50% remaining: treat as red. Removes the fixed prompt-count assumption in favour of informed assessment.

## [1.3.1] — 2026-05-23

### Added

- **Context depth counter in `workflow-checkpoint.sh`** — tracks prompt count since session open. 🟡 Amber warning at ~30 exchanges (~75K tokens): complete current task before starting new work. 🔴 Red warning at ~50 exchanges (~125K tokens): finish task in flight, run `/g-retro`, start a fresh session.
- **Counter reset in `session-start.sh`** — writes `.claude/session-prompt-count` = 0 on each session open so the counter is always session-scoped.
- **A7 Context gate in `A-session.md`** — rule encoding amber/red behaviour: PM must not start a new `/g-plan` at red; handoff block in `todo.md` is the continuity contract.

## [1.3.0] — 2026-05-23

### Added

- **`session-start.sh` hook (SessionStart event)** — fires once per session open. Runs `git fetch` in the background while checking local state, then reports: branch name, uncommitted changes, stashed work, commits behind/ahead vs remote, and whether a feature branch has drifted behind `origin/main`. Zero latency on local checks; fetch runs concurrently with a 5-second hard cap. Prints `✓ Clean and in sync with remote` when nothing to flag.
- **Wired into `/g-init`** — session-start.sh is now copied from the plugin cache and registered as the `SessionStart` hook alongside the existing four hooks.
- **Wired into `/g-update`** — session-start.sh is synced on every update; missing registration is auto-added.
- **Wired into `/g-doctor`** — new required check 11: `session-start.sh` installed and `SessionStart` registered. Required check count 10 → 11.
- **Selective loading presets in G-RULES.md** — added a project-type table (Minimal / + architecture / + design / + docs / + testing / Full) mapping to the specific section files to @-reference. Replaces the narrative hint with an actionable lookup.

### Changed

- **B-workflow.md skills table slimmed** — the 32-row full-reference table trimmed to 8 core skills (g-update, g-brief, g-status, g-help, g-doctor, g-listen, g-retro, g-trim). Specialist skills removed from always-loaded context (~600 token/prompt saving); available via `/g-help`.

## [1.2.0] — 2026-05-23

### Added

- **`/g-trim` skill** — weekly read-only audit of `CLAUDE.md` and agent memory files. Surfaces orphaned `@references`, duplicate rules, stale content, dead file refs in MEMORY.md entries, and overlong memory files — all flagged for human review. **Never modifies any file.** The only write is `.claude/last-trim` (timestamp). `workflow-checkpoint.sh` nudges once per 7 days when the stamp is absent or stale.
- **G-RULES.md decentralization** — the 480-line monolith split into 10 per-topic section files under `rules/g-rules/` (`A-session` through `J-memory`). `G-RULES.md` becomes a thin `@`-reference index that loads all 10. Projects can reference individual files in `CLAUDE.md` to reduce per-session token cost. All 10 files are installed by `/g-init` and synced by `/g-update`.
- **`/g-specialize` skills preloading** — after installing a stack architect agent, g-specialize creates a companion `.claude/skills/architecture-<stack>/SKILL.md` containing the architecture rules and injects a `skills:` entry into the agent frontmatter. The architect gets its rule set at startup without depending on the CLAUDE.md `@`-reference chain.
- **Agent frontmatter hardening** — all 17 agents now use the full Claude Code subagent spec: `effort: max` on review agents, `memory: project` on agents needing persistent context across sessions, `background: true` on non-interactive read-only agents, `isolation: worktree` on `refactor-executor`, and `color` coded by role.
- **Description routing triggers** — all 17 agent descriptions rewritten to "Use proactively when..." phrasing so Claude auto-delegates to the right agent rather than waiting for explicit invocation.
- **Weekly g-trim nudge in `workflow-checkpoint.sh`** — surfaces once after 7 days since `.claude/last-trim`.

### Fixed

- **`permissionMode` removed from all agents** — plugin subagents silently ignore `permissionMode` in their frontmatter; the field had no effect and has been removed.
- **`code-lead` review chain flattened** — subagents cannot spawn other subagents (depth limit: 1). `code-lead` was declaring `review-orchestrator` as a nested dispatch target — a dead declaration. `code-lead` now performs direct review (logic, security, performance, code quality). `review-orchestrator` is documented as depth-0-only: spawn from the main session or a skill, never from another subagent.

### Changed

- Skill count: 31 → 32
- G-RULES.md sections: 7 → 10 (added G-Documentation, H-Testing, I-Project-Tracking, J-Memory as standalone section files; original G-Testing Protocol renumbered to H)

## [1.0.0] — 2026-05-19

**🚀 First stable release.** G-Forge becomes a coherent production-intelligence system — not a collection of additions. M15 — Hook / Behavioral Integration Pass — wires every prior milestone into a unified experience the developer can tune to their preferences and project phase.

### Added
- **Three integration tiers** — `.claude/integration-tier` selects how present G-Forge is in your project. `full` (default) fires all hooks, auto-triggers `/g-plan`/`/g-execute`/`/g-review`, and runs telemetry-driven adaptive orchestration. `balanced` keeps state hooks but never auto-triggers a workflow — you invoke skills manually; the commit gate stays on. `light` is the opt-out mode — workflow-checkpoint fires for branch info only, the commit gate is **off**, and G-Forge stays silent until you call it. Switch with `/g-tier full|balanced|light`. Switching to `light` requires confirmation because it disables the commit gate. Full spec in `docs/integration-tiers.md`.
- **Three voice profiles** — `.claude/voice-profile` selects how G-Forge talks to you. `dev` (default) is terse and jargon-dense — what every G-Forge skill has always sounded like. `mid` adds one explanatory sentence per major result, jargon defined inline. `eli5` is plain language, conversational, no jargon — designed for non-engineer collaborators or revisiting unfamiliar areas. Profile changes **rendering** only; same facts, same verdicts. Switch with `/g-voice dev|mid|eli5`. Full spec in `docs/voice-profiles.md`.
- **`/g-tier` skill** — read or switch the integration tier. Read mode shows current tier + what hooks fire + commit-gate state. Switch mode confirms before destructive changes (light disables commit gate).
- **`/g-voice` skill** — read or switch the voice profile. Read mode shows the current profile plus side-by-side samples of all three so the developer can compare.
- **First-chat onboarding in `/g-init`** — new Step 7a asks the developer which voice and which tier they want, writes both `.claude/voice-profile` and `.claude/integration-tier`. Subsequent skills honor the choices immediately.
- **Tier-aware `workflow-checkpoint.sh`** — emits a new `Tier:` line on every prompt. `light` exits after Branch + Tier; `balanced` emits all state lines but signals "no auto-triggers"; `full` is the historical full output.
- **Tier-aware `check-commit.sh`** — short-circuits to exit 0 when tier is `light`. The commit gate is genuinely off in light mode.
- **`/g-help` cohesion overhaul** — surfaces Configuration block (tier · voice · telemetry health profile) and Recent intelligence block (last telemetry snapshot date, last forecast slug, identity-file presence). All commands grouped by purpose: Setup / Per-task loop / Intelligence / Configuration / Hygiene / Audit-refactor / Skill-development.
- **`/g-retro` Step 6 — pattern signal feed** — after writing a retro, runs a lightweight pattern mine across all retros and surfaces any normalised label that just reached ≥2 source files. Closes the loop with `/g-patterns` without requiring a separate invocation. Surface only — never modifies rule files.
- **Auto-trigger rule scoped to `full`** — `G-RULES.md` §B updated: auto-triggers fire only when the tier is `full`. The LLM reads the `Tier:` line in `workflow-checkpoint.sh` output and honors the rule.

### Changed
- Self-update URL in `workflow-checkpoint.sh` migrated from `hllrm/g-team` to `hllrm/G-Forge` to match the renamed GitHub repository.
- Hook output header renamed from `[G-Team Workflow Checkpoint]` to `[G-Forge Workflow Checkpoint]` for consistency with the post-M9 G-Forge rename.

## [0.15.0] — 2026-05-19

### Added
- **`/g-blast-radius [file|plan|feature]`** — dependency-impact skill. Given a target (file path, plan slug, or feature label), computes forward references (what the target depends on), reverse references (what depends on the target), and per-file volatility from git history (commits-in-last-50 × 2, clamped 0–10). Aggregates to a single rating: ✓ Narrow / ⚠ Moderate / ✗ Wide. Persists report to `docs/blast-radius/<slug>.md` and surfaces top reverse-dependency files plus hot zones.
- **`/g-identity`** — temporal-cognition skill. Synthesises the project's operational personality from accumulated retros, forecasts, telemetry snapshots, ADRs, blast-radius reports, CHANGELOG, ROADMAP, and git history. Produces a 5-section narrative (what this project is / how it ships / what it does well / where it struggles / what it's becoming) written to `docs/identity.md`. Qualitative complement to `/g-telemetry`'s quantitative snapshot. Refuses to run on a thin corpus.
- **`/g-forecast` Step 2b: blast-radius integration** — when `docs/blast-radius/<plan-slug>.md` exists, the rating is folded into the complexity score (+0 Narrow / +1 Moderate / +2 Wide). Complexity remains clamped to 0–10. Surfaces in the Step 7 report as `+ blast-radius adjustment`.
- **`/g-forecast` Step 2c: economic reasoning** — every forecast now includes an estimated token-cost band derived from agent-dispatch count, expected diff size, and review overhead. Expressed as `low – high` with a size tag: Small / Medium / Large / Very Large. Advisory — never blocks approval. Surfaces in the Step 7 report alongside complexity and miss-risk.

## [0.14.0] — 2026-05-19

### Added
- **`flask` stack profile** — architect agent + architecture rules. Covers app factory pattern (no module-level `Flask(__name__)`), blueprint-only route registration, service-layer framework-agnosticism (no `flask.request`/`g`/`current_app` below the route boundary), repository pattern over `Model.query`, and Marshmallow/Pydantic schema discipline. Auto-detected by `/g-specialize` from `flask` in `requirements.txt` or `pyproject.toml`.
- **`pygame` stack profile** — architect agent + architecture rules. Covers single-site `pygame.event.get()` discipline, `dt`-based motion (no frame-count motion), scene/entity/system separation, asset lifecycle (load at scene transitions, never per-frame), frame-time budget (16.6ms at 60 FPS), and the universal state-machine / object-pooling rules from G-RULES §F. Auto-detected from `pygame` in dependency files.
- **`xamarin` stack profile (legacy)** — architect agent + architecture rules for Xamarin.Forms projects. Covers MVVM discipline, view-model framework-agnosticism, `DependencyService` boundary for platform features, async/await UI-thread marshalling, and `OnPropertyChanged(nameof(...))`. Flags Xamarin.Forms end-of-support (May 2024) and recommends MAUI for new work. Auto-detected from `Xamarin.Forms` in `.csproj` when `Microsoft.Maui` is absent.
- **`dependency-auditor` agent** — 17th general-purpose agent. Audits 9+ manifest types (npm/yarn/pnpm/bun, pip, Cargo, Go, Gem, Composer, pubspec, .NET, JVM) for: known security advisories (Critical), deprecated and unmaintained packages (Major), license conflicts (Major), unused declarations (Minor), duplicate versions (Minor), and major-version drift (Minor). Read-only — never upgrades. Sonnet tier; tools: Read, Glob, Grep.
- **`frontend-data-flow` supplementary profile wired into `/g-specialize`** — the pre-existing `profiles/frontend-data-flow/` (covering the two-network model and the four canonical frontend violations: HTTP in components, shadow-state ref sync, watch-as-dispatch, caller-follows-truck) now auto-installs alongside any component-framework stack: `react`, `vue-pinia`, `nuxt`, `next-js`, `sveltekit`, `angular`, `remix`, `astro`, or any astro-* combo. Supplementary — never replaces the per-framework architect.

### Changed
- `/g-specialize` supported-stacks list, detection rules, and interactive prompt now include flask, pygame, xamarin, and the supplementary frontend-data-flow.
- Marketplace description updated: 17 agents, 26 skills, 48 stack profiles, 7 combo profiles, 1 supplementary profile.

## [0.13.0] — 2026-05-19

### Added
- **8 reliability metrics defined** — `docs/telemetry-metrics.md` documents hallucination rate, review catch rate, regression frequency, rework rate, spec deviation, escalation frequency, token efficiency, and retry dependency. Each metric carries its observable source, computation formula, expected range, ⚠ threshold, and the downstream skill that consumes it. Profile-derivation table maps `⚠ count` to one of four health profiles: `stable` / `cautious` / `defensive` / `recovery`.
- **`/g-telemetry` skill** — computes the 8 metrics from accumulated history (retros, git log, escalation log, forecast outcomes), derives the health profile, writes `.claude/telemetry-profile` (single-line bare-word value), and persists a structured snapshot to `docs/telemetry/YYYY-MM-DD.md`. Applies the same `None recorded.` sentinel filter as `/g-patterns` and `/g-forecast`. Bootstrapping projects (<3 retros AND <30 commits) skip computation and default to `stable` with a `cold-start` note.
- **Adaptive orchestration in `/g-execute`** — Step 0 reads the telemetry profile and applies dispatch adjustments: `defensive` caps waves at 3 agents and bumps Sonnet → Opus; `recovery` forces serial dispatch (1 agent/wave) and Opus on every dispatch. Adds a profile-specific extra clause to every agent prompt under `defensive` and `recovery`. The developer-approved plan is never silently rewritten — wave size is adjusted at dispatch time only.
- **Governance intelligence in `/g-review`** — Step 0 reads the same profile and scales reviewer count: `cautious` adds one extra `code-reviewer`; `defensive` adds `code-reviewer` + `architecture-enforcer` and a `debugger` pre-pass; `recovery` runs the full reviewer set unconditionally plus `debugger` + `error-detective` pre-passes. HOLD verdicts under `defensive`/`recovery` increment `.claude/review-holds` — this counter feeds back into the next telemetry snapshot, closing the adaptive loop.

## [0.12.0] — 2026-05-19

### Added
- **`/g-forecast [plan-slug]`** — scope-realism and premortem skill. Runs against an approved or pending plan. Outputs a complexity score (0–10), a quantified miss-risk percentage with risk tag (Low / Moderate / Elevated / High), and a ranked top-5 premortem of likely failure scenarios. Each scenario carries likelihood × impact, a concrete mitigation, and a source citation back to the retros or git history that surfaced the pattern. Advisory — never blocks plan approval. Persists `docs/forecasts/<plan-slug>.md` with an empty `Outcome` table that `/g-retro` fills in to close the feedback loop.
- **Premortem wired into `/g-plan`** — new Step 3b dispatches `/g-forecast` after wave-planner and surfaces the forecast summary in the Step 4 approval block. High-risk plans (≥75% miss-risk) get a one-line ⚠ recommendation to re-scope, but the approval gate is unchanged.
- **Feedback loop closed** — `/g-retro` Step 3 includes a conditional premortem-accuracy question when a forecast file exists for the active plan; answers populate the `Outcome` table in `docs/forecasts/<plan-slug>.md`. `/g-patterns` Step 1 now reads `docs/forecasts/*.md` as a signal source; predicted-and-hit scenarios are weighted as high-confidence patterns (weight 2). The four-step loop is now wired: `/g-patterns` → `/g-forecast` → `/g-retro` → `/g-patterns`.
- **Milestone health in workflow checkpoint** — `hooks/workflow-checkpoint.sh` now emits a `Health:` line on every prompt. Shows `✓ clean` when there are no signals, or `⚠ N rework · M blocked · K holds` when rework commits, BLOCKED markers, or HOLD verdicts are present on the current branch.

## [0.11.0] — 2026-05-19

### Added
- **`/g-patterns`** — organisational-learning skill. Mines `docs/retros/` and `todo-done.md` for recurring failure modes, buckets them by frequency (✓ isolated · ⚠ emerging · ✗ systemic), and proposes concrete profile-rule edits for any pattern observed ≥2 times. Per-suggestion apply/defer/dismiss flow — no edits applied without explicit developer choice. Deferrals logged to `docs/patterns-deferred.md`. Surfaces reinforced "worked well" patterns as a separate positive-signal bucket.
- **Self-evolution: rule-edit suggestions** — for every Emerging or Systemic pattern, the skill maps the failure class to a candidate fix target (G-RULES section, stack architecture rules, agent system prompt, or skill Rules section) and drafts a concrete edit: target file, target section, exact text, and a one-line rationale citing source retros.

## [0.10.0] — 2026-05-19

### Added
- **Rename: G-Forge** — project renamed from G-Team to G-Forge across all display strings, docs, and manifest name fields
- **Memory layer taxonomy** — `docs/memory-taxonomy.md` defining 6 tiers (Working, Task, Sprint, Architectural, Institutional, Human Preference) with lifetime, audience, and example content
- **Context profiles v1** — `context:` frontmatter field for skills and agents; g-plan, g-execute, g-review, and g-retro updated with appropriate tier declarations
- **ADR lineage fields** — `/g-adr` now captures rejected alternatives, assumptions, and constraints that drove the decision; template updated with corresponding sections; pre-M9 ADRs are pre-lineage
- **Memory taxonomy in G-RULES** — new § I · Memory Layers section referencing the taxonomy and the `context:` convention

## [0.9.0] — 2026-05-19

### Added

- **G-Forge self-hosting** — the g-team plugin repo now runs on its own tooling. `CLAUDE.md`, `G-RULES.md`, hooks (`check-commit.sh`, `post-commit-cleanup.sh`, `workflow-checkpoint.sh`, `pre-compact.sh`), and `settings.json` are installed and active on the repo itself.
- **`pre-compact.sh` installed** — PreCompact hook wired into `.claude/hooks/` and registered in `.claude/settings.json`. Fires before context compression; writes `.claude/compact-state.md` with branch, last 5 commits, and the Handoff block from `todo.md`.
- **Retroactive milestone files** — `milestones/M6-auto-trigger.md` and `milestones/M7-correctness.md` added to complete the milestone file history (M1–M8 now all present).
- **`claude-plugin` stack profile** — architect agent (`profiles/claude-plugin/agents/claude-plugin-architect.md`) validates skill structure, command routing, agent format, hook design, and manifest; architecture rules (`profiles/claude-plugin/rules/architecture.md`) cover all 6 layers with explicit Skill, Agent, Command, and Version rules. Profile is auto-detected by `/g-specialize` via `.claude-plugin/plugin.json` presence.
- **`/g-skill-design`** — 7-step skill for designing new g-team skills from scratch: gather requirements, check for existing similar skills, draft and confirm step outline, write SKILL.md, write command file, update router, report.
- **`/g-skill-validate [name]`** — 6-step validation skill: full ✓/✗ checklist across SKILL.md format, command file Glob+Read pattern, router registration, and agent frontmatter; issues VALID or NEEDS FIXES verdict.

## [0.8.1] — 2026-05-15

### Added

- **Versioning & release flow rules** in `G-RULES.md` §D — codifies the project's existing semver conventions: `MAJOR.MINOR.PATCH[a]` format, dual version source rule (`plugin.json` + `marketplace.json`), milestone-scoped bumps, hotfix `a` suffix convention, 7-step release commit sequence, mid-milestone scope-creep policy, and git tag stance.

## [0.8.0] — 2026-05-12

### Added

- **`/g-retro`** — session retrospective skill. After any non-trivial session, saves a structured retro to `docs/retros/YYYY-MM-DD-topic.md` capturing: what was done, decisions made, patterns that worked/failed, and a cold-start context block (branch, active milestone, next up, key files touched, carry-over context). Interactive: infers the topic from `todo.md` + `git log`, confirms with the developer, interviews for decisions and patterns, then writes and surfaces the file.
- **`pre-compact.sh` hook (`PreCompact` event)** — fires before Claude context compression. Writes `.claude/compact-state.md` containing the current branch, last 5 commits, and the Handoff block from `todo.md` at the moment of compaction. Exits 0 always — never blocks compression. Registered in `hooks/hooks.json` and wired into per-project `settings.json` by `/g-init`.
- **MCP recommendations in `/g-init`** — Step 8 report now lists recommended MCPs (`context7`, `github`, `supabase`) with descriptions and installation guidance.
- **PreCompact hook check in `/g-doctor`** — new check 10 verifies that `.claude/hooks/pre-compact.sh` is installed and `PreCompact` is registered in `settings.json`.

## [0.7.5] — 2026-05-11

### Added

- **SOLID principles as coding standards** — `G-RULES.md` §D now has a dedicated SOLID block with one concrete, actionable rule per principle (SRP, OCP, LSP, ISP, DIP), replacing the previous single SRP one-liner. `code-reviewer` gains a SOLID violations checklist with per-principle severity guidance (LSP = Critical, SRP/OCP/DIP = Major, ISP = Minor). `architecture-enforcer` gains OCP and DIP architectural checks covering type-switch dispatchers and wrong-direction imports from concrete adapters.
- **`/g-audit [path|all]`** — code quality audit skill. Grep-based parallel scanner covering SOLID violations, code smells, dead code markers, and test coverage gaps. Each finding is scored `(severity × impact) / change_risk` and bucketed into P0–P3 priority tiers. Targeted mode produces an inline report; whole-codebase mode writes a prioritised `milestones/M-audit-YYYY-MM.md` and appends a milestone entry to `ROADMAP.md`.
- **`/g-optimize [path|all]`** — performance audit skill. Detects O(n²) nested loops, N+1 queries, regex construction in hot functions, deep clones on state change, re-render waste (React inline object props, Vue whole-store subscriptions), listener/timer leaks without cleanup, and whole-library imports. Stack-aware: UI checks only run when a UI framework is detected; N+1 checks only when an ORM is detected. Same two-mode output and roadmap integration as `/g-audit`.
- **`/g-refactor [path|milestone]`** — guided refactor orchestration skill. Accepts a file/path scope or an audit/optimize milestone file. Pipeline: test coverage check (offers `test-writer` if thin) → parallel pre-analysis (`code-reviewer` + `architecture-enforcer`) → `spec-writer` dispatch → human approval gate → wave execution via `refactor-executor` with Tier 1 gates between waves → `/g-review` merge gate → milestone file updated if launched from an audit milestone.
- **Live stable/LTS research in `/g-specialize`** — new Step 2 runs `WebSearch` for each detected stack before installation. Scope is strict: stable and LTS releases only; alpha/beta/RC/canary/experimental results are ignored. Findings (confirmed version, material best-practice changes since prior major) are shown in the confirmation prompt and appended as a dated addendum to the installed architect agent file.
- **Astro island combo profiles** — three new combo profiles (`astro-react`, `astro-vue`, `astro-svelte`) covering patterns that emerge only when using island frameworks with Astro: island placement convention (`src/islands/` not `src/components/`), serializable prop contract, island isolation rules (React Context / Pinia instances don't cross island boundaries), cross-island state strategy (nanostores for React and Vue; native Svelte module-scope stores also work for Svelte islands), hydration directive defaults (`client:visible` not `client:load`), and the callout that `$app/*` SvelteKit APIs are unavailable in Astro context.

### Fixed

- **`next-js` architect agent filename** — `g-specialize` referenced `next-architect.md`; actual file is `next-js-architect.md`. Would have silently failed to install the Next.js architect on every project.
- **React Router v7 not detected** — Remix rebranded to React Router v7 (`react-router` package + `@react-router/dev` in devDependencies, or `react-router.config.ts` present). Added detection path mapping to the existing `remix` profile (file-based routing + loader/action architecture is identical).

- **`/g-docs [path|all]`** — documentation audit and generation skill. Scans for missing or stale JSDoc/docstrings, missing module headers, incomplete README sections, undocumented environment variables, CHANGELOG gaps, missing ADRs, and absent API reference docs. Targeted mode invokes `doc-writer` on each gap immediately. Whole-codebase mode produces a prioritised debt report (P0–P2) and optionally writes a `milestones/M-docs-YYYY-MM.md` roadmap entry.
- **`/g-adr [title]`** — architectural decision record skill. Interactive five-question flow (context, decision, alternatives, consequences, status) writes a standard ADR to `docs/decisions/NNN-title.md`. Auto-suggests follow-up actions (CLAUDE.md update, project_brief.md tech table, superseding previous ADRs). Auto-suggested by `spec-writer` when a task involves an architectural choice.
- **`G-RULES.md §G — Documentation Standards`** — new section covering all documentation layers: code-level (JSDoc/docstrings/doc comments, module headers, format by language), architecture-level (ADRs in `docs/decisions/`, currency rule), project-level (README completeness checklist, CHANGELOG currency, env var reference), API-level (OpenAPI spec, SDK reference), and operational-level (deployment guide, runbook). Currency rule: any PR that changes a signature, behaviour, or public API must update the corresponding docs in the same PR. Former §G (Testing Protocol) renumbered to §H.

### Changed

- `G-RULES.md` §B maintenance skills table updated with `/g-audit`, `/g-optimize`, `/g-refactor`, `/g-docs`, `/g-adr` entries.
- `G-RULES.md` Project Tracking file hierarchy updated with `docs/decisions/`, `docs/env-vars.md`, and `CHANGELOG.md` entries.
- `agents/code-reviewer.md`: added Documentation coverage checklist — missing public API docs (Major), stale docs (Major), missing README update (Major), missing CHANGELOG entry (Major), missing env var documentation (Major), missing ADR (Major), missing module header (Minor), redundant docs (Minor).
- `agents/review-orchestrator.md`: added conditional `doc-writer` dispatch when diff touches exported symbols — writes missing/stale JSDoc in the same review pass rather than issuing a HOLD.
- `agents/spec-writer.md`: added Documentation done conditions section — JSDoc for new exports, README for user-facing features, env var reference, ADR for architectural decisions, CHANGELOG entry for significant changes.
- `g-specialize` combo detection table and combo file mapping extended with the three Astro combos.
- README: skill count 17 → 22, combo profile count 4 → 7, command list updated.

---

## [0.3.5a] — 2026-05-08

### Fixed

- `g-team-init` Step 7: hook commands now use `bash -c 'bash "$(git rev-parse --git-common-dir)/../.claude/hooks/X.sh"'` instead of bare relative paths — resolves hook lookup failures when Claude Code runs inside a git worktree (worktree CWD ≠ main repo root where `.claude/hooks/` lives)

## [0.3.4] — 2026-05-06

### Added

- `G-RULES.md` Section G — Testing Protocol: three-tier test model (Tier 1 automated gates / Tier 2 tooling-assisted / Tier 3 human-driven); QA panel integration policy (scope doc per milestone, currency enforcement as a hard done condition); Tier 3 listen-mode protocol with `.claude/tier3-active` state file
- `g-team-plan` Step 0: Tier 3 DoD prerequisite — asks if project has a QA panel, compiles `docs/qa-scope/<milestone-slug>.md` mapping in-scope groups to pass criteria; no Tier 3 DoD = milestone not started
- `g-team-plan` Step 2: task-decomposer now receives QA panel context; any task adding or changing user-facing surface must include "QA panel updated" as an explicit done condition
- `workflow-checkpoint.sh`: surfaces Tier 3 listen mode status and logged bug count when `.claude/tier3-active` exists — fires on every prompt so listen mode is never invisible

### Changed

- README: G-RULES.md section count updated to seven; Section G added to table; `workflow-checkpoint.sh` description updated; `/g-team plan` description updated in Skills table and Playbook

## [0.3.3a] — 2026-05-05

### Fixed

- `g-team-specialize` Step 4: replaced fragile "go up two directory levels" path navigation with the same Glob-based plugin root discovery used by `g-team-update` — fixes profile lookup failures (affected tauri and all other profiles) when the plugin cache path structure differed from what the agent navigated manually

## [0.3.3] — 2026-05-05

### Added

- `claude-plugin` stack profile: architect agent (`profiles/claude-plugin/agents/claude-plugin-architect.md`) validates skill structure, command routing, agent format, hook design, and manifest; architecture rules (`profiles/claude-plugin/rules/architecture.md`) cover all 6 layers with explicit Skill, Agent, Command, and Version rules
- `/g-team skill-design` — 7-step skill for designing new skills from scratch: gather requirements, check for duplicates, draft and confirm step outline, write SKILL.md, write command file, update router, report
- `/g-team skill-validate [name]` — 6-step skill for validating skills and agents against structural rules: ✓/✗ checklist across SKILL.md, command file, router registration, and agent frontmatter; issues VALID or NEEDS FIXES verdict
- `g-team-specialize`: added `claude-plugin` to supported stacks list, detection via `.claude-plugin/plugin.json` or `plugin.json` schema field, and Step 4 file mapping

## [0.3.2] — 2026-05-05

### Added

- Branch discipline enforced: `G-RULES.md` Section D requires feature branches (`feat/`, `fix/`, `refactor/`, `chore/<slug>`) for non-trivial work; MERGE READY on a branch triggers merge/PR to main; direct main commits limited to hotfixes, docs, and version bumps
- `workflow-checkpoint.sh` now reports current branch name on every message; warns to stderr when on `main` or `master`
- `check-commit.sh` adds a non-blocking advisory when committing directly to `main` with approval
- `project-manager` agent gains a **Feature Challenge gate**: asks 3 questions before accepting any new feature scope; bug fixes and refactors are exempt; one round, one verdict, then proceeds
- `g-team-plan` Step 1 now dispatches project-manager challenge before task-decomposer fires (bug fixes/refactors skip it)
- `g-team-review` Step 1 now runs the full test suite before any code review; test failures produce immediate HOLD with no sentinel write; no-test-suite case requires explicit test-writer dispatch or one-time developer override
- `test-writer` agent expanded: now covers unit, integration, and e2e tests; chooses test type based on what is being tested; handles projects with no obvious test framework by asking the developer

### Fixed

- G-RULES.md Section D branch discipline replaced generic "never commit to main" with specific naming convention, MERGE READY flow, and main-branch exception list
- `skills/g-team-init/SKILL.md` hook templates synced with updated live scripts

## [0.3.1] — 2026-05-04

### Added

- `g-team-doctor` expanded from 7 to 9 checks: added `post-commit-cleanup.sh` hook check, `G-RULES.md` present check, `@G-RULES.md` referenced in `CLAUDE.md` check

### Fixed

- `g-team-update`: `post-commit-cleanup.sh` now created and registered if missing (previously skipped silently — pre-0.3.0 projects would never get it installed)
- `g-team-doctor` check 4 fix instruction: now correctly references `/g-team init` as well as `/g-team update`
- `g-team-doctor` check 5 fix instruction: corrected from "Run `/g-team update`" to "Run `/g-team init` or `/g-team update`"
- ROADMAP.md: updated to reflect M6-M8 milestones (was stale at M1-M5 only)

## [0.3.0] — 2026-05-04

### Added

- Section F — Design Patterns in `G-RULES.md`: 6 universal principles (composition over inheritance, explicit over implicit, YAGNI, fail-fast at boundaries, observer/event-driven, state machine for discrete modes) and 8 anti-patterns refused by default
- Object pooling and state machine architecture rules in all 5 game-dev profiles: `unity`, `godot-gdscript`, `godot-csharp`, `unreal`, `cpp-cmake`
- `G-RULES.md` now installed per-project by `/g-team init` (Step 2a) — `@G-RULES.md` reference added to `CLAUDE.md`
- `/g-team update` now refreshes per-project `G-RULES.md` from plugin (Step 3a)
- `/g-team doctor` — 7-point health check: hooks installed, all hooks registered in settings.json, G-Forge Rules block present, no stale sentinel, milestone alignment

### Fixed

- `g-team-kickoff` Step 7: removed false claim that `/g-team init` auto-triggers plan/execute/review in sequence
- `g-team-review` Step 2: fixed stale path `docs/superpowers/plans/*.md` → `docs/plans/`
- `g-team-plan` Step 5: removed user-facing reference to `superpowers:dispatching-parallel-agents`
- `code-reviewer` agent: added Section F anti-patterns to "What to look for" (god object, prop drilling, business logic in UI, mutable state, premature abstraction, magic values, catch-and-continue)
- `architecture-enforcer` agent: added circular dependency detection and god object violation checks
- `go-fiber` architect agent filename collision with `go-gin` profile (renamed to `go-fiber-architect.md`)
- `g-team-update` Step 7: now verifies and adds UserPromptSubmit hook in settings.json when `workflow-checkpoint.sh` already exists
- `marketplace.json`: corrected agent and skill counts

### Changed

- README fully rewritten for 0.3.0: G-RULES.md section, Section F callout, game-dev profile notes, all 3 commit hooks documented, complete skills and agents tables

## [0.2.8] — 2026-05-04

### Fixed

- `g-team-execute` Step 4: now immediately invokes `/g-team review` via Glob+Read after all waves complete (was previously a print suggestion only)
- `g-team-execute` rules: explicit prohibition on instructing subagents to run `git commit`
- `g-team-execute` Step 2: wave auto-detection now reads Progress table in plan file (4 rules: absent/all-pending→Wave1, all-complete→stop, in-progress→confirm, mix→auto-resume)
- G-RULES.md Section B: added commit prohibition to hard stops; updated auto-trigger language

## [0.2.7] — 2026-05-04

### Added

- `/g-team doctor` skill — 7-point health check with ✓/✗ per check and fix instructions
- CHANGELOG.md — change history tracking from 0.1.0

### Fixed

- `g-team-help`: added missing "Review pending" workflow phase; 7th source is git branch; `/g-team help` added to All commands table
- `g-team-brief`: added missing announce line; guard check moved to top of Step 1
- `g-team-plan`: Progress table initial values corrected to `pending`

## [0.2.6] — 2026-05-04

### Added

- `/g-team help` — context-aware state reader; detects workflow phase and outputs next action + full command reference
- `/g-team status` — fast structured snapshot: milestone, active plan/wave, review gate, handoff line
- `/g-team brief` — incremental project_brief.md refresh; targeted Q&A, no full re-onboard
- Plan file format schema: approved plans saved to `docs/plans/<feature-slug>.md` with Tasks, Wave Schedule, and Progress tables
- `workflow-checkpoint.sh` now parses plan file to report current wave number and total waves
- g-team-review auto-closes completed milestone tasks and updates ROADMAP.md on MERGE READY

### Fixed

- g-team-kickoff: aligned auto-trigger language with rest of plugin

## [0.2.5] — 2026-05-04

### Added

- `workflow-checkpoint.sh` UserPromptSubmit hook: fires on every message, reports active plan and review state
- plan/execute/review now auto-triggered — Claude initiates them without user typing commands
- G-Rules compact block updated with auto-trigger language
- `/g-team update` installs `workflow-checkpoint.sh` on existing projects and registers UserPromptSubmit hook

## [0.2.4] — 2026-05-04

### Fixed

- Compact G-Rules block (injected by `/g-team init`) now explicitly names `/g-team-execute` and prohibits `superpowers:dispatching-parallel-agents`
- `g-team-execute` SKILL.md gains authority assertion declaring it the sole wave dispatcher

## [0.2.3] — 2026-05-03

### Added

- `/g-team execute` skill for wave-based agent swarming
- `/g-team update` skill to realign installed project files to current plugin version
- G-RULES.md now tracked in git (was previously gitignored)

### Fixed

- Removed all `Skill(...)` tool invocations from all command and skill files — were causing infinite "Launching skill" loops with no content loaded
- All commands now use Glob+Read pattern on SKILL.md directly
- Removed `argument-hint` from SKILL.md frontmatter files (was preventing skill content from loading)

## [0.2.1] — 2026-05-03

### Added

- `/g-team onboard` — fully rewritten to handle mature projects; maturity classification (mature/early-stage/greenfield); resolves existing `.claude/rules`, `.claude/agents`, `CLAUDE.md` conflicts before interviewing; targeted interview for mature projects

## [0.2.0] — 2026-05-03

### Added

- 44 stack profiles (up from 3): covers Web Frontend, Node/Go/Rust Backend, Python/Ruby/PHP, JVM/.NET, Mobile/Desktop, Game Dev & Systems
- Each profile has a stack-specific architect agent and architecture rules
- Auto-detection from dependency files (`package.json`, `requirements.txt`, `Cargo.toml`, etc.)

## [0.1.0] — initial release

### Added

- Core plugin structure: `commands/`, `skills/`, `agents/`, `profiles/`, `hooks/`
- 16 specialist agents: task-decomposer, wave-planner, spec-writer, code-reviewer, security-auditor, architecture-enforcer, performance-auditor, debugger, error-detective, project-manager, review-orchestrator, code-lead, test-writer, doc-writer, pr-writer, refactor-executor
- Skills: kickoff, init, specialize, plan, review
- Commit enforcement: PreToolUse hook blocks git commit without `.claude/g-team-approved` sentinel
- G-RULES.md: full session discipline rules (models, workflow, agent discipline, code quality, architecture gate, project tracking)
- 3 initial stack profiles: vue-pinia, node-ts, fastapi
