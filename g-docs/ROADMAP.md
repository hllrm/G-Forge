# G-Forge

> Multi-agent Claude Code plugin — planned execution, production architecture, enforced review.

## Active Session

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HANDOFF — g-forge | branch: claude/g-doctor-gitignore-docs-1njpam | v2.2.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Done this pass:   · M28 shipped + merged to main as v2.2.0 (g-docs canonical tracking; /g-init .gitignore; /g-doctor Checks 19/20). · Brainstormed + SCOPED M29 — multi-session coordination: coordinate concurrent sessions through a shared MCP-reached surface (claim/lease register + append log), three pluggable backends chosen for spread (Gmail · Discord · Confluence) behind one adapter. Captured the design (g-docs/multi-session-coordination.md) and the buildable scope (g-docs/milestones/M29-multi-session-coordination.md); promoted from the backlog candidate. · Confirmed via claude-code-guide: hooks/MCP travel to web/mobile/Slack/Actions only when config is in committed .claude/ (validates M28) and coordination MCP must be remote+.mcp.json.
Next up:          · Await go on M29; start with Phase A (protocol core + Discord reference adapter) to test "is convention enough?" · M26 (deferred/spike-gated) · M25 (compute-gated).
Active context:   · branch claude/multi-session-coordination-idea, off main (v2.2.0). M29 scoped, status ⬜ awaiting go — non-goals fence it to collision-avoidance, not orchestration. Phasing A→B→C in the milestone file. Re-enter with /g-resume.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Milestones

### M1 — Foundation
**Status:** ✅ Complete
**Version:** v0.1.0
**Goal:** Repo, plugin.json, 16 agent stubs, skill dirs, hooks, profiles, milestone files

---

### M2 — Agent Roster
**Status:** ✅ Complete
**Version:** v0.2.0
**Goal:** Full system prompts for all 16 agents — mandates, output contracts, scope discipline

---

### M3 — Skills & Orchestration
**Status:** ✅ Complete
**Version:** v0.3.0
**Goal:** /g-kickoff, /g-init, /g-plan, /g-execute, /g-review — end-to-end with commit enforcement

---

### M4 — Stack Profiles
**Status:** ✅ Complete
**Version:** v0.4.0
**Goal:** /g-specialize + 44 profiles across web, mobile, desktop, game dev, and systems

---

### M5 — Publish
**Status:** ✅ Complete
**Version:** v0.5.0
**Goal:** README, docs/agents.md, docs/orchestration-patterns.md, marketplace listing

---

### M6 — Auto-trigger & Project Hygiene
**Status:** ✅ Complete
**Version:** v0.6.0
**Goal:** workflow-checkpoint hook, auto-trigger plan/execute/review, /g-help /g-status /g-brief /g-doctor

---

### M7 — Correctness, Validation & Polish
**Status:** ✅ Complete
**Version:** v0.7.0
**Goal:** Section F design patterns, game-dev profile rules, per-project G-RULES.md, full alignment pass

---

### M8 — Deploy & Use
**Status:** ✅ Complete
**Version:** v0.9.0
**Goal:** Self-host G-Forge on this repo; add claude-plugin profile; add skill-design and skill-validate vibecoding skills
**Scope:**
- Install G-Forge into this repo (CLAUDE.md, hooks, settings.json, milestone files)
- Create milestones/M6, milestones/M7 files (retroactive)
- claude-plugin stack profile — architect agent + architecture rules
- /g-skill-design skill — guided workflow for designing new skills/agents
- /g-skill-validate skill — validates SKILL.md and agent files against quality criteria
- Register skill-design and skill-validate in commands/g-forge.md router

**Depends on:** —

---

### M9 — Intelligence Foundation
**Status:** ✅ Complete
**Version:** v0.10.0
**Goal:** Structural substrate for agent context management and decision memory
**Scope:**
- **Rename pass** — project renamed from G-Team → G-Forge; update all display strings, doc references, CHANGELOG heading, README, plugin.json `name`/`display_name`, marketplace.json, and any in-file prose mentioning "G-Team" across the full repo
- Context profiles v1 — memory slice declared in skill/agent frontmatter
- Memory layer taxonomy — 6 tiers (Working / Task / Sprint / Architectural / Institutional / Human Preference) with lifetime + audience
- ADR lineage fields — rejected alternatives, assumptions that held, constraints that drove the decision

**Depends on:** M8

---

### M10 — Organizational Learning Loop
**Status:** ✅ Complete
**Version:** v0.11.0
**Goal:** G-Forge detects recurring failure patterns and proposes self-corrections
**Scope:**
- /g-patterns skill — mines retros + todo-done for recurring failure modes; surfaces systemic health report
- Self-evolution — detected systemic pattern surfaces suggested fix to architecture profile rules, not just a report

**Depends on:** M9, accumulated retro/todo-done history

---

### M11 — Planning Intelligence
**Status:** ✅ Complete
**Version:** v0.12.0
**Goal:** /g-plan and /g-roadmap gain forecast, premortem, and in-flight health tracking
**Scope:**
- /g-forecast skill — scope realism analysis, complexity scoring, quantified risk estimate ("X% likely to miss target")
- Premortem wired into /g-forecast — ranked failure scenarios before plan approval, seeded by /g-patterns history
- Feedback loop closed — /g-patterns → premortem → /g-retro → /g-patterns
- Milestone health live monitoring — in-flight signal: blocker count, rework rate, review churn; surfaces via /g-help or hook

**Depends on:** M10 (/g-patterns must exist to seed premortem scenarios)

---

### M12 — Reliability & Adaptive Systems
**Status:** ✅ Complete
**Version:** v0.13.0
**Goal:** Instrument agent performance; system adapts its behavior based on measured reliability
**Scope:**
- 8-metric reliability telemetry: hallucination rate, review catch rate, regression frequency, rework rate, spec deviation, escalation frequency, token efficiency, retry dependency
- Adaptive orchestration — telemetry scores drive model selection and conditional reviewer spawning
- Governance intelligence — adaptive review gates by project stability and zone risk

**Depends on:** M11 (planning workflows must be instrumented before measuring them)

---

### M13 — Profile Additions
**Status:** ✅ Complete
**Version:** v0.14.0
**Goal:** Expand stack coverage and deepen existing frontend profiles
**Scope:**
- flask profile
- pygame profile
- xamarin profile
- dependency-auditor agent
- `frontend-data-flow` supplementary profile — rules + architect agent implementing the two-network model (read/write), dead-end component rule, and V1–V4 violation patterns; installed alongside any component-framework profile by `/g-specialize`
  - **Implementation note:** `/g-specialize` detection logic must be updated to auto-install `frontend-data-flow` whenever a component-framework stack is detected (vue-pinia, react, nuxt, next-js, sveltekit, angular, remix, astro, and composites). The profile is supplementary — it lives in its own directory and must be explicitly wired into the specialize skill's profile map; it will not activate automatically just by existing.

**Depends on:** M8 (independent of intelligence milestones; slots here as pacing break between M12 and M14)

---

### M14 — Advanced Production Modeling
**Status:** ✅ Complete
**Version:** v0.15.0
**Goal:** PM layer reasons about feature dependencies, costs, and long-term project trajectory
**Scope:**
- Dependency intelligence — feature-level dependency graph, blast radius analysis, volatility scoring; surfaces before execution ("this touches 4 high-volatility systems")
- Economic reasoning — token cost estimates, system impact counts, strategic deferral suggestions
- Temporal project cognition — persistent operational identity from accumulated signals: recurring risks, architectural personality, delivery patterns

**Depends on:** M12 (telemetry data), M10 (pattern history), M11 (blast radius feeds /g-forecast)

---

### M15 — Hook / Behavioral Integration Pass
**Status:** ✅ Complete — v1.0.0 shipped
**Version:** v1.0.0
**Goal:** G-Forge becomes a coherent production intelligence system, not a collection of additions
**Scope:**
- Full hook audit and behavioral flow wiring end-to-end
- Health surfaces in /g-help; premortem auto-runs in /g-plan; pattern suggestions feed /g-retro output
- UX tuning across the full system — flows feel cohesive, not additive

**Depends on:** M14 (all capabilities must be in place before the integration pass)

---

### M19 — Ambient Proactivity
**Status:** ✅ Complete
**Version:** v1.6.0
**Goal:** G-Forge watches continuously, stays anchored to the brief, and reacts to feature drops — less command-driven, more ambient
**Scope:**
- Silent observer (`hooks/observe.sh` + `hooks/agent-lifecycle.sh`) — passive `.claude/journal/` activity log; `/g-retro` reworked to synthesize from it (no interview)
- `/g-align` — brief-deviation check vs `project_brief.md`; auto-runs at milestone close, nudged between milestones; advisory
- `/g-intake` — proactive feature-drop triage (classify against brief → propose placement + version + risk → ask before writing)
- Hardened the JSON-parse cascade across all hooks (no fail-open on the Windows python3 stub)

**Depends on:** M18 (compact-return + plan-derisking foundation)

> Note: M16–M18 shipped between M15 and M19 (see CHANGELOG and README roadmap table for v1.2.0 / v1.3.3 / v1.5.0) — this file tracks the headline milestones.

---

### M20 — Single-Use Agent Doctrine
**Status:** ✅ Complete
**Version:** v1.7.0
**Goal:** Make context poisoning structurally impossible — agents are single-use; retries live at HQ via clean learnings reports, not inside a degrading executor context
**Scope:**
- Single-use agent doctrine in G-RULES §C — one approach, one attempt; names and prevents context poisoning
- `FAILED` agent outcome + `LEARNINGS:` field in the return contract, distinct from `BLOCKED`
- `/g-execute` redeploy loop — HQ analyzes learnings and deploys a fresh agent with a different mechanism, bounded by Three-Strikes (§A8), then escalates to the human
- Doctrine note in `docs/orchestration-patterns.md` framing it as the automatable form of the deliberation/execution split

**Depends on:** M18 (compact-return contract this extends)

---

### M21 — Decision Hygiene Loop
**Status:** ✅ Complete
**Version:** v1.8.0
**Goal:** Apply the single-use doctrine to HQ's own deliberation and close the loop — high-stakes thinking happens off-context, and the session resets after a decision is finalized
**Scope:**
- `/g-adr` offloads the weighing to a throwaway deliberation subagent; HQ promotes only the finalized draft (HQ window stays clean)
- Decision-hygiene reset reuses the §A7 context-gate path on a semantic trigger — `/g-retro` + handoff (`verify ADR-NNN` first) + fresh-session recommendation
- G-RULES §C extended with HQ deliberation hygiene; orchestration-patterns doctrine section extended

**Depends on:** M20 (single-use agent doctrine this generalizes to HQ)

---

### M22 — Session Re-entry
**Status:** ✅ Complete
**Version:** v1.9.0
**Goal:** Make "start a fresh session" cheap — the read side of the reset seam, so a clean window re-hydrates the right slice of the durable record instead of inheriting a poisoned one
**Scope:**
- `/g-resume` — selective re-hydration: pulls the relevant retro cold-start, in-force ADRs, journal tail, and handoff first-task into a clean window, keyed to branch/milestone/first-task; offers the clean-slate ADR verification when one was handed off
- First-prompt `/g-resume` nudge in `workflow-checkpoint.sh` when a handoff is pending
- §A7 reframed as a two-sided reset (promote out via `/g-retro`; re-hydrate in via `/g-resume`); orchestration-patterns doctrine extended with the read side

**Depends on:** M19 (observer journal), M20–M21 (the reset path `/g-resume` re-enters from)

---

### M23 — G-Forge 2.0 (Production-Readiness Audit)
**Status:** ✅ Complete
**Version:** v2.0.0
**Depends on:** all prior milestones (this audits the whole surface).

Self-contained kickoff — paste the block below into a fresh session (or open cold and run `/g-resume`, which points here):

```
G-Forge 2.0 — production-readiness audit. The bar: "no shit." Ruthless pass for
consistency, clarity, and shippability. No half-measures, no leftover cruft, no
stale docs, no claims the repo doesn't back up. Fix what you find; don't just report.

Work on a fresh branch (e.g. claude/g-forge-2.0-audit). Do NOT push to main without
explicit approval. Use G-Forge's own tooling where it fits (/g-audit, /g-docs,
/g-doctor, /g-review). Keep CHANGELOG.md AND README in sync as part of "done" for
every change — standing rule, not an afterthought.

EXPLICIT DELIVERABLES
1. .gitignore — review and tighten. Confirm it excludes everything generated
   (.claude/ runtime, scratch, agent-output, journals, sentinels, OS files) and
   nothing that is real plugin content. (Current file uses legacy "G-Team" wording.)
2. Clean the repo — remove dead/stray files; decide what should not ship. Known:
   hooks/test-check-commit.sh and hooks/test-observe.sh ship in hooks/ — move to a
   tests/ dir or exclude. Sweep orphaned references, dead links, placeholder files.
3. Agents <> hooks reconciliation — every agent a skill references exists (17
   present); every hook in hooks/hooks.json matches g-init's install table AND
   g-doctor's checks (paths, names, registration); nothing referenced-but-missing
   or installed-but-unregistered.
4. README v2 — rewrite from scratch (don't patch). Start under a PLACEHOLDER project
   name; keep the real name out until content is approved, then swap it in one pass.

CONSISTENCY / CLARITY SWEEP (seeded findings — start here, don't stop here)
- Legacy "G-Team" strings still in: hooks/hooks.json, hooks/pre-compact.sh,
  hooks/check-commit.sh, hooks/post-commit-cleanup.sh, hooks/workflow-checkpoint.sh,
  ROADMAP.md. Rename to G-Forge (leave historical retros untouched).
- Count claims vs reality: marketplace.json says "17 agents, 35 skills" but there
  are 37 commands and 35 skill dirs. Reconcile everywhere they appear (marketplace.json,
  README, CHANGELOG, /g-help) against ground truth.
- Docs vs recent behavior: /g-adr is now a 9-step flow (entry triage, capture mode,
  reversibility + premortem); the §A7 context gate now prevents compaction
  (auto-calibrating thresholds, amber active-monitoring, wave /context checks). Check
  every doc that describes these (README, G-RULES, docs/orchestration-patterns.md,
  skill/command descriptions) for stale step numbers / thresholds.
- One voice: descriptions, headers, terminology consistent across commands/, skills/,
  agents/, rules/, docs/.

VERSION: major — bump to 2.0.0 only when the audit is genuinely complete and you'd
stake "production ready" on it. Developer approves the bump.

DONE = repo clean; .gitignore correct; agents<>hooks fully reconciled; zero legacy
naming; all counts/claims true; README v2 approved and named; CHANGELOG + docs in
sync; /g-doctor green. If something can't be made production-ready in scope, say so
plainly with the reason — don't paper over it.
```

---

### M24 — Positioning & Reliability Methodology
**Status:** ✅ Complete
**Version:** v2.1.0 (docs-only; ships with the next release)
**Goal:** State what G-Forge actually is, and define how to prove it.
**Scope:**
- [x] Reposition README + marketplace + plugin descriptions around "educated, enforced project management" (governance layer, not another agent orchestrator) — grounded in the 107-agent landscape research.
- [x] `g-docs/benchmark.md` — reproducible reliability-benchmark methodology (model + G-Forge vs. raw, scored on success rate + the 8 `/g-telemetry` metrics).

**Depends on:** M23. *(Committed on `claude/m23-release-u3rx0d` (`8a20f92`); lands on `main` with the next merge.)*

---

### M25 — Run the Reliability Benchmark
**Status:** ⬜ Not started
**Version:** v2.1.0 (or whenever the number ships)
**Goal:** Turn "punch above its weight" from a claim into a defensible, published number.
**Scope:**
- [ ] **Pilot first** — run the 2–3 task B-vs-A pilot in `g-docs/benchmark.md` to shake out the harness and check for signal on a multi-file / architecture-touching task.
- [ ] **Gate:** only fund the full run if the pilot shows a lift; a null result on a task class is recorded honestly and stops the spend.
- [ ] Full benchmark (n ≥ 20, arms A–D), blind mechanical scoring, the chart + 8-metric table.

**Premortem (per `/g-roadmap` Step 3b — this milestone was added, so it ran):**
- *Harness is the real cost, not the run* — automating the G-Forge arm headless (plan→execute→review) is eval engineering; mitigate by piloting on 2–3 tasks before building the full runner.
- *Operator confound* — the G-Forge arm must be driven by a fresh model session executing the plugin, never hand-simulated, or the result is meaningless.
- *Task-class dependence* — lift concentrates on multi-file/architecture work; report per-class, never a single blended number.
- *Skeptical market* — a sloppy number is net-negative (87% distrust accuracy); do not publish until n and scoring are defensible.

**Depends on:** M24 (methodology), and a session/compute budget allocated to run it.

**Re-prioritization:** M25 sits after M24 and is gated on a pilot — it does not block any other planned work; the run happens when compute is deliberately allocated.

---

### M26 — Provable Wave Dispatch (Workflow-script execution engine)
**Status:** ⬜ Not started
**Version:** v2.3.0
**Goal:** Make `/g-execute`'s fan-out *provable* rather than instructed — without G-Forge becoming "another agent orchestrator." This enforces the existing orchestration contract; it does not add a new one.
**Scope (additive opt-in — prose dispatch stays the default and the fallback):**
- [ ] Feasibility spike + design note (`g-docs/g-execute-engine-design.md`) — Workflow-tool availability detection from a skill, plugin-shipped `scriptPath` invocation, wave-plan→`args` contract, and where the per-wave `/context` capacity gate relocates once the loop is backgrounded. **Gates the build.**
- [ ] `skills/g-execute/wave-runner.workflow.js` — deterministic `parallel()` fan-out, per-wave barrier, `RESULT`-block parsing, and journal/Progress/agent-output writes **identical to the prose path**.
- [ ] Script retry/BLOCKED control flow — attempt counter, Three-Strikes ceiling, escalation-log; the §A8 "different mechanism" choice stays a model `agent()` callback (loop in script, *judgment stays model-made*).
- [ ] `skills/g-execute/SKILL.md` Step 3 opt-in branch + `.claude/execution-engine` sentinel + `/g-doctor` surfacing; prose path byte-for-byte unchanged when opt-out.
- [ ] Dual-execution-model docs + parity runbook.

**Tier 3 DoD:** Parity run — a 3-task wave (one forced-FAILED) through *both* paths yields identical FILES, `.claude/journal` + Progress-table writes, commit-gate behavior, and retry-ceiling stop.

**Forecast (advisory):** Complexity 7/10 · Miss-risk ~50% (Elevated) — risk concentrated in the spike; clean spike drops it to Moderate. Top scenarios: spike fails (→ reshape to "document the pattern"), orphaned capacity gate, parity drift, retry degradation, two-path maintenance tax.

**Depends on:** M23. Independent of M24/M25.

**Re-prioritization:** Deferred to v2.3.0 behind M27 (developer's call). Internal orchestration mechanism, spike-gated; nothing depends on it, so it slots last among non-completed milestones.

---

### M27 — Documentation Review Gate (separate from code review)
**Status:** ✅ Complete
**Version:** v2.1.0
**Goal:** Make documentation review its own gate with its own verdict — distinct from code review in trigger, lens, and process. Today doc review is a sub-check of `code-reviewer`; this promotes it to a first-class gate that can run **even when there are no code commits**.
**Scope:**
- [x] New **`doc-reviewer`** agent (read-only: Read/Glob/Grep). Lens: accuracy-vs-code, **currency** (docs that contradict the code), completeness (public exports, README sections, env vars, ADR/CHANGELOG coverage), clarity. Output: BLOCKING / WARNING / PASS → **DOCS READY / DOCS HOLD**. (17 → 18 agents)
- [x] New **`/g-doc-review`** standalone gate skill — own verdict, own cadence. (36 → 37 skills · 37 → 38 commands)
- [x] **File-set-keyed enforcement** *(the hard part)* — gate triggers on the changed file set, not on the presence of a code diff: docs touched (incl. **no-code-commit** changes — wiki, README, ADRs) **|** public/exported surface changed **|** milestone close. Doc-only commits must require a doc-review sentinel (e.g. `.claude/g-forge-docs-approved`); mixed commits require **both** gates; code-only commits are unaffected.
- [x] **Defense-in-depth split** — `code-reviewer` keeps its "missing public-export doc = Major" as a fast **backstop**; `doc-reviewer` owns the deep review. Define precedence so the two don't double-report (backstop defers when the doc gate ran).
- [x] **Blocking on public, advisory on internal** — public-API/exported doc gaps + docs that *contradict code* → DOCS HOLD; internal-only gaps + clarity/terseness → WARNING.
- [x] Clean boundary vs. `/g-docs` (audit+**generate**/write) and `doc-writer` (fills gaps): `/g-doc-review` only **judges & gates** — read-only, may *recommend* `/g-docs`, never writes. Update G-RULES §G to document the two-gate model; update `check-commit.sh` + tests.
- [x] Version bump to v2.1.0 — update plugin.json and marketplace.json version fields in one commit (developer commits at milestone close)

**Tier 3 DoD:** A doc-only change (stale README section + a `g-wiki/` edit) with **no code commit** triggers `/g-doc-review`, the gate blocks the commit until DOCS READY, and a public-export doc gap yields DOCS HOLD; a code+doc PR runs both gates; a code-only PR is untouched by the doc gate (code backstop still catches a missing public-export doc).

**Premortem (per `/g-roadmap` Step 3b):**
- *No-code trigger is the real engineering* — gating doc-only changes means the commit hook must classify the file set (code / doc / mixed), not ask "is this a code commit." Mitigate with an explicit doc-path globset + a `tests/` case per class.
- *Two-sentinel collision* — code and doc approvals can race or misclassify a mixed commit. Mitigate: mixed ⇒ both required; precedence rules; hook tests.
- *Overlap with `/g-docs`* — audit/generate vs. review/gate blur into duplicated logic. Mitigate: `/g-doc-review` is strictly read-only verdict; writing stays in `/g-docs`/`doc-writer`.
- *Backstop double-report* — retained code-reviewer doc check + doc-reviewer flag the same gap, noisy. Mitigate: backstop fires only when the doc gate was skipped.
- *"Stale" is judgment-heavy* — false HOLDs on terse-but-correct docs create friction. Mitigate: block only on contradicts-code or missing-public-surface; clarity = WARNING.

**Depends on:** M23 (review infrastructure). Independent of M24/M25/M26.

**Re-prioritization:** Promoted to the next buildable milestone (v2.2.0) — strongest fit for the M24 governance positioning and actively in design. Sits ahead of the deferred M26. (M25 is compute-gated and runs on a parallel track.)

---

### M28 — g-docs as the canonical home for all G-Forge documents
**Status:** ✅ Built — pending release (v2.2.0)
**Goal:** Make `g-docs/` the single home for every G-Forge document — including the project-tracking files (`ROADMAP.md`, `todo.md`, `todo-done.md`, `milestones/`, `project_brief.md`) that live at the root today — and give `/g-doctor` the checks to keep it that way.
**Scope:**
- [x] **Migrate tracking into `g-docs/`** — `git mv`'d the root tracking paths under `g-docs/`; updated every *live* reference (skills, hooks, rules, agents, commands, templates, README, live `g-docs/` doctrine docs) to the new path. Historical records (retros, archive, CHANGELOG history, the M23 kickoff block) untouched.
- [x] **`/g-init` defines the `.gitignore`** — new Step 5a writes/merges a project `.gitignore` that **ignores** runtime/dev artifacts (OS files, `.env*`, `.worktrees/`, ephemeral `.claude/` state + sentinels + journal, `g-docs/agent-output/`) and **tracks** the software code plus the project-tracking value (`g-docs/` records, `g-docs/ROADMAP.md`, `g-docs/todo.md`, `g-docs/milestones/`, `g-wiki/`, `CLAUDE.md`, `G-RULES.md`) and shared `.claude/` config. Idempotent merge.
- [x] **`/g-doctor` vets the `.gitignore`** — new advisory Check 19: runtime-artifact exclusions present, nothing tracked-by-design ignored (incl. over-broad bare patterns).
- [x] **`/g-doctor` finds + relocates stray g-forge docs** — new advisory Check 20: scans root + non-`g-docs/` doc folders, reports each with a `git mv` fix, offers to move.
- [x] **Confirm every skill writes under `g-docs/`** — audited; canonical `g-docs/` subpath map encoded in `g-rules-I-project-tracking`.
- [x] Sync CHANGELOG + README to the new layout; grep-clean of old root paths. Version bump deferred to release (developer's call).

**Scope boundary:** `CLAUDE.md` (Claude Code reads it at root), `G-RULES.md` (`@`-referenced config), and `CHANGELOG.md`/`README.md`/`LICENSE` stay at the root. Full breakdown in `g-docs/milestones/M28-g-docs-canonical-tracking.md`.

**Depends on:** nothing — touches scaffolding/docs/hooks paths only. Independent of M25/M26.

---

### M29 — Multi-session coordination (claim/lease for concurrent sessions)
**Status:** ⬜ Not started (scoped, awaiting go)
**Goal:** Stop concurrent sessions from silently colliding on milestone numbers, branches, and the handoff — by coordinating through a shared, MCP-reached surface, with three pluggable backends behind one adapter, degrading cleanly to today's git handoff when none is configured.
**Scope (phased):**
- [ ] **Phase A — core + first adapter:** surface-agnostic claim protocol + register schema (resource = milestone/branch/wave; claim = holder/session/ts/lease/status), session identity + signed writes + lease/heartbeat + stale-claim reclaim, a capability-flagged adapter interface (`push|poll`, `cas|convention`, identity), and the **Discord** reference adapter (real-time, free) to answer "is convention enough?"
- [ ] **Phase B — workflow integration:** collision check in `/g-roadmap` + `/g-plan` (fetch + warn + offer alternatives before assigning), hook surfacing of others' active claims + heartbeat in `workflow-checkpoint.sh`/`session-start.sh`, release on milestone close. Honors tiers (off on `light`).
- [ ] **Phase C — setup, health, rest of adapters:** **Confluence** adapter (version-CAS = real lock) + **Gmail** adapter (zero-setup floor), `/g-init` opt-in setup wiring a **remote MCP into `.mcp.json`** (tokens via env-var, never committed) + `/g-doctor` reachability check, graceful degradation + docs.

**Position:** phase one of **multiplayer G-Forge** — full multi-user cooperation on one project ("human orchestration, powered by humans"), a framework that engages whenever >1 session/user is live and degrades to single-player when alone. M29 is the claim/lease substrate; **assignment-by-person, cross-person handoff, cross-person review, and reconciliation** are later phases of the arc (not cut). Permanent line: humans orchestrate — no autonomous AI-dispatches-AI, no hosted authority.

**Cross-surface requirement:** each adapter's MCP must be **remote HTTP/SSE in `.mcp.json`** so cloud / Slack / GitHub-Actions sessions can reach it (local stdio servers are invisible to those surfaces). Same property that makes G-Forge enforcement travel — committed config follows you everywhere.

**Premortem + done condition:** full breakdown in `g-docs/milestones/M29-multi-session-coordination.md`. Promoted from the backlog candidate below; this is the milestone version of it.

---

## Backlog

### Candidate — Multi-session / multi-operator orchestration ("orchestrating humans")
G-Forge orchestrates *agents* inside one session today. It already does **sequential, git-mediated** multi-session handoff — the ROADMAP `## Active Session` block + `/g-resume` + the observer journal are the primitives; this very session ran that way across two machines. The open question is **concurrent** coordination: can HQ in one session treat *other live sessions* (human or agent, same or different machine) as dispatchable units?

The motivating failure is concrete and already observed: a session began planning **M24** while another session had already claimed **M24/M25** — multi-session work has no **claim/lock** primitive, so parallel sessions silently collide on milestone numbers, branches, and the handoff block.

Possible scope when promoted to a milestone:
- A claim/lease primitive (e.g. `.claude/claims/` or a remote-backed lock) so a session can reserve a milestone number / wave / file-set before work starts.
- Collision detection in `/g-roadmap` and `/g-plan` (fetch + check before assigning a milestone number).
- A handoff/merge protocol for *concurrent* (not just sequential) sessions — who owns `main`, how waves from different operators reconcile.
- Decide the honest boundary: is this "orchestrating humans," or just safer git-mediated coordination? (Aligns with the M24 positioning — governance, not orchestration-for-its-own-sake.)

A brainstormed approach — coordinate through an always-available, instantly-visible **shared surface reached via an MCP** rather than git, which only propagates on push/fetch — is captured in `g-docs/multi-session-coordination.md`. Direction chosen: ship three spread surfaces (**Gmail · Discord · Confluence**) behind a common, extensible adapter; mechanism not yet scoped.

*Status: **the goal is now explicit — multiplayer G-Forge** (full multi-user cooperation on one project; "human orchestration, powered by humans"). The concurrent claim/lease is **M29** (phase one, scoped, awaiting go); the cooperation layer — assignment, cross-person handoff/review, reconciliation — is the milestone arc beyond it. North star + framework captured in `g-docs/multi-session-coordination.md`.*

---

## Version Plan

```
v0.8.1 → v0.9.0 (M8) → v0.10.0 (M9) → v0.11.0 (M10) → v0.12.0 (M11)
       → v0.13.0 (M12) → v0.14.0 (M13) → v0.15.0 (M14) → **v1.0.0 (M15) ✅ shipped**
       → **v2.0.0 (M23) ✅** → **v2.0.1 (M24 + stack implementers) ✅** → **v2.1.0 (M27 — doc-review gate) ✅** → **v2.2.0 (M28 — g-docs canonical tracking) ✅** → v2.3.0 (M26, deferred) · M25 benchmark ships its number when run
```

MVP cut: M9 + M10 + M11 — context structure + failure detection + intelligent planning with premortems.
