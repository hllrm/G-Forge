## Active Session

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HANDOFF — g-forge | branch: main | v2.4.0 · FIRST LIVE RESOLVE PASS — SKILL HARDENED, RULE TEXT PARKED · 2026-08-15
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Done this pass:   · **FIRST LIVE /g-patterns RESOLVE PASS. Outcome: the SKILL got hardened, all three rule fixes PARKED as DEFERRED — zero rule text shipped.** Report archived g-docs/patterns/latest.md → g-docs/patterns/2026-08-15.md; single-open-report invariant closed at that point; all three carried in g-docs/patterns-deferred.md with their full findings. (**Superseded twice later the same day** — first by a synthetic fixture published to latest.md, then by the developer hand-swapping the files for a second test. The third line of this block is the single authority on the tree's present state; nothing on this line asserts it.) · **Why they parked (developer decision after 3 code-gate rounds + 3 review axes):** the mined *evidence* is sound but the drafted *rule text* was not consumer-safe, and each fix round generated the next round's defect — §A8 three-strikes on one mechanism (authoring universal consumer-facing rule text from single-repo evidence, in-session, with no way to validate against consumer environments). Concrete defects, all carried in the deferred log: derived-counts rule bound its trigger to the restated figure rather than the underlying detail, so it could not fire on the stale-README case it was mined from · its §G→§H pointer is one-way while CHANGELOG and this block both claimed it mutual (this pass's own defect class), and §G/§H are independently-selectable presets so the pointer dangles on A–G · the quiet-machine timing rule is unsatisfiable on hosted CI/containers/shared executors and collides head-on with §H Tier 1 (suites block every commit), leaving removal-from-the-gate as the only compliant move. · **CRITICAL caught at the code-review axis:** static-risk-numbers was marked `RESOLVED — no longer applicable` on half its evidence. Its seed record (g-docs/milestones/M36-salience-inputs/2026-07-18-forecast-calibration-feedback.md) names TWO numbers — /g-forecast miss-risk (genuinely fixed by M47 Step 5b) and /g-plan's context-budget estimate (NOT fixed; M47 Step 3c added another *carried* constant, placement M38/M39). RESOLVED archives+deletes the open report, so a twice-recorded developer-raised governance item would have vanished with no trace to re-surface it. Corrected to DEFERRED. · **SKILL HARDENING SHIPPED (this is the pass's real deliverable):** skills/g-patterns/SKILL.md — Step 5 now resolves source-vs-installed explicitly (the table named only .claude/ paths, which are gitignored artifacts /g-update overwrites wholesale, so a fix applied there dies at resync and never reaches a consumer; this pass only avoided it by targeting source on instinct) · Step 13 now requires a RESOLVED verdict to clear the WHOLE seed record, not the first match (abstraction strips exactly the identifiers that reveal a multi-surface pattern) · Step 14 `apply` gained a doc-currency step WITH an existence contract (never creates CHANGELOG.md or the [Unreleased] heading, never touches a machine-generated changelog — reports the gap instead) and the `APPLIED — refined` distinction · `## Rules` reconciled to match. Plus currency: §I records /g-patterns as a third CHANGELOG writer, README states the write, /g-review's close-out states the full RESOLVE write set + ordering against the version-bump prompt. · **Inbox truth corrected:** the two committed g-docs/inbox/adversarial/ drops were developer placeholders, NOT external counter-reports — the n8n round-trip never completed and is UNVALIDATED; drops deleted, all six false round-trip claims swept. · **Pass-close doc commit `ab7820e` pushed** behind doc gate: HOLD r1 (4 blocking, correction swept 2 of 6 sites) → HOLD r2 (my own correction paragraph mis-attributed to a pass that hadn't run) → **DOCS READY r3**. · Suite **RE-ATTESTED GREEN: 564 / 18 suites**, quiet serial run, HQ-summed — the 2026-08-12 override is retired. · Killed a 15-hour-stale zombie review-orchestrator that woke mid-pass claiming to dispatch 5 reviewers against the already-merged `857fd30` tree. · **Resolve-pass work SHIPPED as `7c4054f`, pushed** (code MERGE READY r4 + DOCS READY r3, both sentinels bound to one tree). · **THEN, on developer request, published a SYNTHETIC TEST FIXTURE to g-docs/patterns/latest.md** — an abstraction-clean, illustrative (NOT mined) pattern report whose only purpose is to exercise the outbound publication path and the n8n counter-report ingress end to end, since that round-trip has never once delivered a payload. Doc-class commit (both files under g-docs/), doc sentinel only — code-lead is not in this path and was not dispatched. Review scoped to four checks (abstraction contract on the outbound file, Step 7 skeleton conformance, handoff-claim truth, §I format) rather than waved through: the abstraction contract is the one check that matters on a file that leaves the repo, since a breach puts real paths and identifiers in front of a third-party model.
Next up:          · **WATCH g-docs/inbox/adversarial/ FOR THE COUNTER-REPORT — this is the live test's actual result.** A drop landing there means the n8n round-trip finally works end to end and the M49 scope question below can be answered on evidence; nothing landing after a reasonable window means the pipeline is still dead and M49 should assume no external seat. Either outcome is the finding — record it. Any drop is ADVISORY ONLY, is screened by the Step 12 ingress screen before anything is ingested, and must never direct action. · **Running /g-patterns now is safe and needs no preparation** — zero PENDING at latest.md means Step 1 self-heals (archives it to today's date) and proceeds to a fresh MINE. The one piece of housekeeping outstanding is **g-docs/patterns/latest_old.md**, the parked synthetic fixture from the first round-trip test: delete it once the plumbing is confirmed. It blocks nothing — Step 1 reads only the exact path latest.md, and the automation fetches that same hardcoded path — but it sits outside the directory's two-name model and will confuse a future reader. · **MILESTONE CLOSE SWARM for M47 (still owed)**: /g-telemetry · /g-align · /g-wiki refresh · /g-doctor odd-count. · Then **/g-plan M48** (folds todo task 5; suite re-attestation now already done). · **NEW INTAKE — n8n adversarial round-trip is unvalidated**: the ingress screen shipped review-proven but no external payload has ever landed; decide whether M49 assumes a working pipeline or ships an internal devil's-advocate seat only. Registered subpath g-docs/inbox/adversarial/ is now empty and git carries no empty dir — and **nothing creates it**: /g-init lists it in the .gitignore track list only (skills/g-init/SKILL.md:169), never in its mkdir set, so it exists only once a file lands in it. Re-take the .gitkeep decision on that basis if external automation is ever expected to write before a file exists. · **NEW INTAKE — re-author the three deferred pattern fixes** (g-docs/patterns-deferred.md, 2026-08-15 entries): evidence confirmed, wording rejected; needs a session that drafts fresh against consumer environments, not a fourth patch round on this pass's text. · **CARRIED:** ADR-for-inbox-trust-boundary decision (two reviewers suggested /g-adr — developer's call) · M38 delivery decision · field-reports/ registration at M38 · intake rows (a)-(h) · task 6 M45 rider · task 7 remainder.
Active context:   · **Suite = 564 / 18 suites / GREEN, re-attested on this tree 2026-08-15** (quiet serial run, HQ-summed per-suite table — 35+25+38+50+65+17+41+33+6+22+9+5+16+43+26+10+81+42) — never accept a summary total without re-summing its own table. **Version identity: 2.5.0 last G-Forge release; G-Proof ships 1.0, never 3.0; this pass rode v2.4.0 working tree, no bump. ADR-012 scope = EIGHT milestones incl. M49; the complete amendment surface set is enumerated at 012:11 — sweep from it, never from memory.** main = **`7c4054f`** pushed clean — that commit carried the resolve-pass work through both gates (code MERGE READY r4: 0 critical/0 major, 7/7 done conditions · DOCS READY r3: 0 findings; mixed commit, both sentinels bound to one tree) and shipped: skills/g-patterns/SKILL.md (Steps 5/13/14 + Rules) · skills/g-review/SKILL.md (close-out write set + bump ordering) · rules/g-rules/I-project-tracking.md (CHANGELOG writer cell) · README.md (patterns row) · CHANGELOG.md (one Unreleased→Changed entry, skill hardening only — no rule text) · g-docs/patterns/2026-08-15.md (renamed from latest.md; all three rows now DEFERRED) · g-docs/patterns-deferred.md (three 2026-08-15 entries) · this block. **rules/g-rules/G-documentation.md and profiles/claude-plugin/rules/architecture.md were REVERTED to HEAD and their installed copies re-synced — confirm both read clean before trusting any claim that a rule shipped.** **PATTERNS DIR IS A DELIBERATE TEST SETUP — developer swapped the two files by hand (2026-08-15, second round-trip test).** Current state: `g-docs/patterns/latest.md` now holds the **REAL** mined report (title line 2026-08-14, three rows, **all DEFERRED, zero PENDING**) · the synthetic fixture from the first test is parked at `g-docs/patterns/latest_old.md` (2 PENDING) · `g-docs/patterns/2026-08-15.md` is deleted from the tree, its content being what now sits at latest.md, and its findings independently preserved in g-docs/patterns-deferred.md. **Consequence to know before running /g-patterns — this is the OPPOSITE of the previous setup:** with zero PENDING rows the Step 1 entry gate takes the **self-heal** branch (SKILL.md:19), renaming latest.md to today's date and continuing into a **fresh MINE** — it will NOT enter RESOLVE. `latest_old.md` is inert to BOTH consumers: Step 1 reads only the exact path `latest.md`, and **the n8n automation fetches that same hardcoded `latest.md` path (developer-confirmed 2026-08-15)** — so the stable-path contract is load-bearing for the automation, not merely internal tidiness, and a stray sibling file cannot be picked up by either side. It remains a filename outside the directory's two-name model (open = latest.md, archived = YYYY-MM-DD.md) and should be deleted once the plumbing is confirmed. Any counter-report the outbound path draws is advisory only and lands in g-docs/inbox/adversarial/. Review records LOCAL-ONLY gitignored: g-docs/agent-output/review/{doc-reviewer-2026-08-15*,code-lead-2026-08-15-resolve}.md; the three review axes (code×2 + architecture) returned INLINE and are NOT on disk — their findings survive only in patterns-deferred.md and this block. LOCAL STATE: review-holds = 20 (this pass's two code-gate HOLDs; 3 doc-gate rounds and 3 axis HOLDs tracked separately) · installed .claude/rules/ G-documentation + architecture-claude-plugin re-synced 2026-08-15 · voice `gian` · telemetry profile `cautious`. Format note: keep this line's leading label intact, use exactly the three section labels, replace this block **wholesale** each pass — never append a second generation, and never repeat this line's own leading label text anywhere else on it (workflow-checkpoint.sh strips with a greedy BRE through the LAST occurrence; pre-compact.sh uses awk block capture — the two consumers disagree when violated, observed live 2026-07-26).
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```


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
**Version:** v2.0.1 (shipped — this line previously read "v2.1.0 (docs-only; ships with the next release)", written before the cut; the work actually shipped in v2.0.1 per the Version Plan and CHANGELOG. Corrected 2026-08-10.)
**Goal:** State what G-Forge actually is, and define how to prove it.
**Scope:**
- [x] Reposition README + marketplace + plugin descriptions around "educated, enforced project management" (governance layer, not another agent orchestrator) — grounded in the 107-agent landscape research.
- [x] `g-docs/benchmark.md` — reproducible reliability-benchmark methodology (model + G-Forge vs. raw, scored on success rate + the 8 `/g-telemetry` metrics).

**Depends on:** M23. *(Committed on `claude/m23-release-u3rx0d` (`8a20f92`); lands on `main` with the next merge.)*

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

### M-audit-2026-07 — Forge Integrity (technical debt audit)
**Status:** ✅ Complete (W0–W3 + stdin-guard release rider; v2.3.0 released 2026-07-23, `9b2488e`)
**Version:** v2.3.0 (upgraded from the original v2.2.2 patch — developer call, 2026-07-18: W1 ships genuinely new capability, not fixes — the native pre-commit enforcement site, 4 shared libs, the 12-file install set, 187-test suite. **Release pass at close:** ship v2.3.0 with the first README **status strip** — version badge + "What's new" → CHANGELOG.md + "Where this is going" → this roadmap, placed high on the page — and the CHANGELOG `[Unreleased]` → `[2.3.0]` cut. This starts the standing README/CHANGELOG maintenance convention (developer, 2026-07-18): both stay current from every release onward; M41's `/g-release` later bakes the currency check into the release gate itself.)
**Goal:** Resolve the 2026-07-01 three-agent audit findings — enforcement layer provably enforces, drift detectable. Full prioritised tables in `g-docs/milestones/M-audit-2026-07.md`.
**Scope:**
- W0 ✅ quick wins: Windows matcher fail-open, /g-update g-rules sync gap, skill count (merged `4158ffa`)
- W1 (P0): ADR-004 (sentinel↔tree binding) + ADR-005 (worktree enforcement) implementation + finding #21 fold-in — 37 tasks / 8 waves, split into budget-scoped sub-parts (each sized to fit a session's `/g-plan` context-budget gate; sequenced 1→7, run `/g-plan` on each in order):
  - **W1.1 — Shared foundations ✅ Complete (`9688e95`):** `hooks/lib/commit-detect.sh`, `hooks/lib/worktree-resolve.sh`, `/g-review` stamp-format + diff-target flip (tasks 1, 2, 9+10). Reviewed MERGE READY by code-lead (0 critical, 0 major, 4 minor carry-forwards to W1.5). Depends on: —
  - **W1.2 — Commit gate + native pre-commit hook ✅ Complete (`1621a70` + fix commit):** `check-commit.sh` swapped onto shared libs (+ new `hooks/lib/classify-changeset.sh` so the classifier exists once), new native `hooks/pre-commit` (write-tree/HEAD/worktree stamp verify, first-commit fail-toward-deny, sentinel consume), g-doc-review Step 1 diff-target flip (ledger 8d residual). Reviewed MERGE READY by code-lead round 2 after one Major fix (worktree stamp field truncated at first space — spaced Windows paths permanently denied); 2 minors carried to W1.5/W2. Sandbox-proven per Tier 3 DoD (19/19 + 6/6 fixture assertions); live verification stays in W1.7. Depends on: W1.1
  - **W1.3 — Remaining hook worktree integrations ✅ Reviewed MERGE READY (2026-07-16, pending commit):** `post-commit-cleanup.sh`, `observe.sh`, `pre-compact.sh`, `session-start.sh`, `workflow-checkpoint.sh`, `agent-lifecycle.sh` (tasks 11+12, 13+14, 15, 16, 17, 18) — all six resolve primary state from a linked worktree, non-gating per ADR-005, primary paths byte-identical, single-classifier grep 0 across `hooks/`. Reviewed MERGE READY by code-lead (0 critical, 0 major, 4 minor → W1.4/W1.5/W1.6: post-commit-cleanup sed command-field-extraction parity gap, observe.sh sed escaped-quote awareness, W4 guard-idiom variance, W5 duplicate stamp reader). Sandbox-proven per Tier 3 DoD; live verification stays in W1.7. Depends on: W1.1. ⚠ oversized estimate handled without further split
  - **W1.4 — Install wiring + drift detection ✅ Complete (`1fdf016`):** `/g-init`/`/g-update` install/realign the 11-file set (7 hooks + 3 libs into `.claude/hooks/`, native `pre-commit` into the git hooks path via `--git-path hooks` with a `G-Forge commit gate`-marker clobber guard — foreign hooks preserved); `/g-doctor` Check 16 extended to libs + pre-commit (missing/stale/foreign distinguished, no renumbering); post-commit-cleanup sed-tier parity fix pinned by fail-before/pass-after test (tasks 20+21, 22, 19 + W1.3 minor). Reviewed MERGE READY (0c/0M/2m: g-init warning text hardcodes `.git/hooks` path — W1.5; cheat-sheet pre-commit line optional); doc gate DOCS HOLD→READY twice caught count drift (forecast scenario 2 hit: README ×3 + g-update lib-sourcing rows). Suite 61/61. Depends on: W1.2
  - **W1.5 — Foundation + gate tests — SPLIT 2026-07-17 into W1.5a–f** (decomposed to 25 tasks / ~84 est. exchanges, far over one session's budget; approved split below — each slice is its own `/g-plan` run, sized ≤26 est. exchanges; the fail-before → fix → attest sandwich stays intact inside each slice; every test-writer suite is followed by a `g-forge-dev` attestation task per finding #20; standing rule: minors found during W1.5x reviews route to W1.6/W2, never back into a W1.5 slice):
    - **W1.5a — commit-detect suite + hardening** (~24): `tests/test-commit-detect.sh` incl. failing global-flag + failing `env -S` cases and the xargs-malformed-quote pin; fix the global-flag walk (`--no-pager`, `-p`, `--git-dir`, `--work-tree`, `--namespace`) + env-S re-tokenization (clarify-resolution: behavior fix, not comment-only — developer-approved 2026-07-17); attested run. Closes W1.1 minors 2–4. Depends on: —
    - **W1.5b — worktree-resolve + classify-changeset suites** (~23): `tests/test-worktree-resolve.sh` (both public functions, relative/absolute `--git-common-dir`, reject paths) + `tests/test-classify-changeset.sh` (every bucket rule, sourced not re-implemented, single-classifier invariant grep); attested runs. Depends on: —
    - **W1.5c — pre-commit gate fixtures ✅ Complete (2026-07-18):** `g-dev/fixtures/pre-commit-gate-verify.sh` extended 19→35 assertions (doc-only-class pass/deny/consume ×3, conflicted-index write-tree-failure deny with standalone write-tree canary, ambiguous-worktree-resolution deny with resolver-reject canary on the separate-git-dir construction); attested green via g-forge-dev (35/35 fixture + 171/171 suite). Reviewed MERGE READY (0c/0M/0m — zero findings). No hook bugs surfaced. Depends on: —
    - **W1.5d — sentinel-read extraction + install propagation ✅ Complete (2026-07-18):** fail-before/pass-after sandwich closed clean (suite 0/16 exit 1 attested pre-extraction → 16/16 after; full suite 187/187 across 10 files; fixture 35/35 through the real hook). `gf_parse_stamp` moved byte-identical into new `hooks/lib/sentinel-read.sh`, both call sites converted, single-reader invariant now grep-pinned; validator unchanged. 4 install surfaces propagated 11→12 (attested consistent, zero stale/over-bump). Reviewed MERGE READY (0c/0M/2m → W1.6/W2: case-(b) advisory-delta note; wave-agent doc-writer overreach — retro-edited the shipped W1.4 CHANGELOG entry, caught+reverted by HQ, history intact). Depends on: —
    - **W1.5e — skill-layer edits ✅ Complete (2026-07-19):** g-review Step 6 ↔ Step 2 reconciled (`--verify HEAD` + explicit `git add -u` union staging, validated sound against the hook's write-tree re-derivation on all three commit paths) + Step 1 generalized to the project-local test-runner convention (`.claude/agents/<name>-dev.md` delegate + attested-output rule + inline fallback; convention-text-is-generic grep 0); g-init `<git-hooks-dir>` warning fixed; post-commit-cleanup dual-sentinel header fixed (comment-only, 6/6 held). 2 waves / 4 dispatches, all first-attempt; attested 187/187 + 35/35 + 4/4 (HQ-run — g-forge-dev dispatch killed by session limit, W1.5a precedent). Reviewed MERGE READY (0c/0M/1m → W1.6/W2: Step 6 run-on bullet split); DOCS READY (0 blocking). Bonus: CHANGELOG finding-#20 bullet header restored — lost in the W1.5d doc-writer overreach (damage exceeded what the retro recorded). [optional → W2 #18] architecture-rule native-git-hook class note. Depends on: —
    - **W1.5f — guard-idiom normalization + terminal attestation ✅ Complete (2026-07-19):** shared `gf_guard_claude_dir()` added to `hooks/lib/worktree-resolve.sh`; all six non-gating W1.3 hooks normalized to the identical canonical line, conformance-invariant-pinned (worktree suite 25→42); gating pair (`check-commit.sh`/`pre-commit`) deliberately excluded — fail-toward-deny keeps the raw resolver. **Finding #22 fixed in the same pass (pulled forward from W2, developer order):** real payload field `agent_type` + `agent_id` + RESULT token, verified against live-captured payloads, pinned by real-payload fixtures (observe suite 16→22); start/stop imbalance explained (internal agents), session-open multi-fire ruled registration-side (→W1.7 check). Terminal attestation 210/210 + fixture 35/35 + drift 3/3 (HQ-run per W1.5a precedent — 3rd session-limit kill on a long dispatch, this time an implementer, resumed to completion). Reviewed MERGE READY (0c/0M/3m → W1.6/W2: node-tier null→"null" mapping; retired-token scan file-list vs dir; quote-safety test line-2 gap). Depends on: W1.5d, W1.5e
  - **W1.5g — Self-Host Integrity ("the Fix slice" — finding #28 / ADR-008, inserted 2026-07-19):** ends the vN-develops/vN−1-runs dogfood gap for the installable layers. ⚠ ENTRY GATE: verify ADR-008 against the repo from a fresh window BEFORE planning (the ADR was authored in the same session that discovered the gap — clean-slate check per decision hygiene). Task sketch for `/g-plan`, in dependency order: **(1) #27 first — verification before installation:** extend `/g-doctor` Check 16 (or sibling required check) to `.claude/rules/g-rules-*.md` + installed agents vs canonical, missing = drift; fail-before evidence exists live (this machine: 0/10 rules files; `claude-plugin-architect` drifted). Agent surface is three-class (plan review 2026-07-20): profile-copied — hash-comparable vs `profiles/<stack>/agents/`; template-instantiated (e.g. `claude-plugin-implementer` from `templates/stack-implementer.md`) — no byte-canonical, needs a marker/provenance rule or advisory-only; project-local (e.g. `g-forge-dev` per the W1.5e runner convention) — no canonical, excluded. Rules mapping: install + check must share the `rules/g-rules/X-name.md` → `.claude/rules/g-rules-X-name.md` flat rename that `G-RULES.md`'s `@`-includes expect. **(2) Self-host-aware install mechanism:** `/g-update` + `/g-init` detect the-repo-IS-the-plugin-source (`.claude-plugin/plugin.json` at root, `name` match) → source root flips from plugin cache to working tree; consumers structurally unaffected; kills the /g-update-installs-stale-cache footgun. **(3) Routine drift check:** `/g-review` Step 1 runs the installed-copy drift check and reports in the review record (visible, not blocking) — the decay-proof element. **(4) Class-split invariant:** suite assertion that non-gating hooks never exit non-zero (split becomes enforced, not conventional). **(5) Non-gating install EXECUTED via the new mechanism** (6 non-gating hooks + 4 libs + 10 rules files + profile-installed agents — NOT `check-commit.sh`, which is gating class per ADR-008 §2 and stays W1.7 clone-first [corrected from "7 hooks" at plan review 2026-07-20]; refresh the `.claude/` snapshot first per the ADR rollback contract, to a durable location — the 2026-07-19 snapshot sits in a session-scoped temp scratchpad) → verified green by the extended Check 16; payoff: g-rules A–J load for the first time, #22 fix goes live locally (journal finally attributes). **(6) Spike S1 (skills/agents layer, the remaining 38+19 files):** two empirical questions — does a local-marketplace `g-forge` install replace or collide with the GitHub-marketplace install? how do command routers' cache Globs behave with multiple version dirs? Outcome = a decision input, not an install. **NOT in scope: gating hooks** (`check-commit.sh`, native `pre-commit`) — clone-first at the W1.7 checkpoint only. Depends on: W1.5f (shipped). Records: ADR-008, ledger #28, snapshot at scratchpad `claude-install-snapshot-2026-07-19`.
  - **W1.6 — Remaining hook tests + drift test:** tests for W1.3 + W1.4 (tasks 27, 28, 29, 30, 31, 32, 33). Depends on: W1.3, W1.4. ⚠ oversized estimate — expect `/g-plan` to split further
  - **W1.7 — Gating-hook install checkpoint + live verification + ledger close (RESCOPED 2026-07-19 per ADR-008):** clone-first exercise of `check-commit.sh` + native `pre-commit` against real commits in a scratch clone → then live install with the rollback contract active (snapshot refreshed; git-level hatches: `--no-verify`, hook-file delete) → full suite green, real gated commit through primary tree, real gated commit through a linked worktree — the FIRST live run of the stamped-sentinel + native path, now on source-current hooks (non-gating layer already live since W1.5g) → residual checks: session-open multi-fire (registration-side, from #22), journal attribution live-confirmed → M-audit ledger sign-off (HQ-executed, not delegated). Local `/g-update` is no longer a W1.7 task — the non-gating install happens in W1.5g via the new mechanism. Depends on: W1.5a–g, W1.6
- W2 (P1) — planned 2026-07-22 (`g-docs/plans/m-audit-w2-shim-retirement-conformance.md`, 24 tasks / 6 waves / 4-pass split): **finding #19 / ADR-007 implementation** (amend g-skill-validate + g-skill-design + architecture rule commands/-definition FIRST, then delete all 38 command shims; umbrella g-forge.md → bare tokens + roundtable row; teaching-docs-only sweep for retired `/g-<name>` forms + g-help unknown-token catch — both developer-approved 2026-07-22); SKILL.md conformance vs amended rules (argument-hint ×9, Announce ×3, Rules ×3, Steps ×2); architecture-enforcer verdict alignment; architecture rule additions (#18 hook-class note, three-class agent taxonomy, `context:` carve-out) + ADR-008 eager install of the amended rule copy; W1.7-routed residuals (#21 heredoc-content false-positive characterize/fix, journal SessionStart `source` field, PostToolUse-skip-on-error characterization); post-release ADR-007 migration check gets a release-checklist owner line. (#22 shipped in W1.5f — no longer W2 scope.)
- W3 (P2, deferrable): 10 minors

**Depends on:** —

---

### M38 — G-Report (outbound incident/feedback reporter)
**Status:** ⬜ Not started
**Version:** v2.5.0 (re-stamped per [ADR-012](decisions/012-g-forge-2.5-final-release-scope.md), 2026-08-10 — rides the final release; was v2.12.0. The freeze story's maintenance channel — §3a of the communication plan leans on `/g-report` existing. Delivery reconciliation ("hands you a file" vs via-git) is open, decided at this milestone's plan gate — see comms plan §7 item 2.)
**Goal:** Prepare **scrubbed, project-agnostic `.md` incident/feedback reports** destined for the G-Forge author — the outbound surface G-tweak calls, also invocable standalone.
**Scope:**
- Report template(s); project-agnostic scrub mode for sensitive data.
- **Local-`.md`-first floor:** the guaranteed job is to *prepare* the report; the human sends it. **No automation on any user data.**
- Opt-in, consent-gated send (Gmail draft-and-nod / GitHub issue on `onlygian/G-Forge`) reusing existing MCP surfaces + ADR-001 draft-and-nod discipline; degrade gracefully (prepared `.md`, you send it) when no MCP is configured.
- `/g-doctor` leak check — no secrets/tokens/absolute paths in the report.
- Boundary vs the inward reporters (`/g-retro`, `/g-telemetry`, `/g-patterns`): G-Report is strictly **outbound-to-author, incident/feedback only.**

**Depends on:** — (leaf).

**Premortem:**
- *Privacy / exfiltration* (high) → local-first floor + consent-gated send + scrub default + `/g-doctor` check.
- *Transport MCP absent on a surface* (med) → degrade to "prepared `.md`, you send it"; never block.

---

### M40 — Reference Convention (recognize-and-vet external material)
**Status:** ⬜ Not started
**Version:** v2.5.0 (re-stamped per [ADR-012](decisions/012-g-forge-2.5-final-release-scope.md), 2026-08-10 — rides the final release; was v2.14.0. New recognized folder class + classifier arm + doctor advisory + intake questions + optional ADR field.)
**Goal:** Name the one committed-content class the taxonomy can't see — human-curated external material a project builds *against* but never *from* (pinned corpora, design handoffs, spec copies) — stop the commit gate mis-gating it, and let `/g-doctor` vet its provenance discipline. **Recognize-and-vet, never own-and-generate.**

**Origin:** the `reference/` convention already runs in the wild in `keyline` (root `reference/`, `SNAPSHOT.md`/`NOTE.md` provenance notes) and was independently reinvented — divergently — in `omnibook` (same corpus, squatting inside `g-docs/`). Two projects, two placements → no rule exists. Full evidence + options in the reference-folder report (advisory, Francesco / CryusFrey, 2026-07-11).

**Scope (waved):**
- **Wave 1 — Gate safety** (the load-bearing fix; independently shippable):
  - `hooks/check-commit.sh`: new **REFERENCE** classifier class (not DOC — a frozen snapshot has no code-it-describes), **exempt-with-advisory** and **marker-gated** — a `reference/*` path is exempt only if its top-level bundle carries a `SNAPSHOT.md`/`NOTE.md`; unmarked paths fall through to CODE, real code under `reference/` still gates.
  - `rules/g-rules/I-project-tracking.md`: one taxonomy row — root `reference/` = **external + human-ported + frozen** (all three or it doesn't go in), git-tracked, **never machine-written**.
  - `skills/g-init/SKILL.md` Step 5a + `.gitignore`: "never ignore `reference/`".
  - Tests: marked reference-only commit passes without a code sentinel; unmarked `reference/` path still gates; code-extension file under `reference/` still gates.
- **Wave 2 — Visibility & non-contamination:**
  - `skills/g-doctor/SKILL.md` advisory: every top-level bundle carries a note; flag code-extension files under `reference/`; **flag reference-like bundles squatting inside `g-docs/`** (turns omnibook's state into a detectable finding).
  - Scope guard: one "skip `reference/` unless explicitly pointed at it" line in `/g-audit`, `/g-optimize`, `/g-refactor`, and Explore-style deep reads (stops scanners reporting SOLID violations in frozen material — the machine-write corruption vector).
  - Intake: one question in `g-onboard` + `g-kickoff` — *"Any specs, design handoffs, or reference corpora this project builds against?"*
- **Wave 3 — Provenance link:**
  - `skills/g-adr/SKILL.md`: optional `Derives from:` field (path to a `reference/` artifact + snapshot edition) + one back-link confirmation step — closes the ADR↔snapshot loop that already broke once in keyline.
  - `SNAPSHOT.md`/`NOTE.md` template blurb: a **License / permission-to-commit** line (Chromium `README.chromium` precedent) + the **external+human-ported+frozen** inclusion test.

**Explicitly out of scope:** scaffolding an empty `reference/` into every project, a `/g-reference` skill, delta-check machinery, and any default read or write of `reference/` by any skill or agent (YAGNI — keyline ran the whole pattern with zero plugin support).

**Depends on:** M-audit-2026-07 (v2.3.0) — shares `check-commit.sh` + `g-doctor`; land after the enforcement-integrity fixes, not concurrent. Otherwise independent of the memory/salience/multiplayer arc.

**Sequencing note (historical — superseded by ADR-012, rides v2.5.0 per the Version line):** slotted at the tail (v2.12.0 at the time — renumbered back into the 2.x line by the 2026-07-18 restructure; the rebrand lives in M44 (⚠ "capstone" framing retired by ADR-010 — M44 is the rebuild's release vehicle)) originally to avoid renumbering the planned M29→M39 lane (a rationale since overtaken, position unchanged). **Wave 1 is a pull-forward candidate** — the reference-only mis-gate is a live enforcement fail-open, thematically M-audit's own territory, and could ship as a `v2.3.x` patch ahead of the arc if the developer wants the gate honest sooner.

**Premortem:**
- *Gate softening leaks* (med) → REFERENCE exemption becomes a code-smuggling path. Mitigation in scope: marker-gated exemption (unmarked → CODE) + doctor flags code-extension files under `reference/`.
- *Taxonomy scope creep* (med — the named failure mode) → one class implies a doctor check implies g-update handling implies docs. Mitigation: hard-scope to the three waves; Phase-4 primitive stays backlog; no scaffold/skill; re-confirm at each wave close that nothing crept.
- *Name collision on onboarded repos* (low) → `reference/` is a common dir with unrelated semantics. Mitigation: doctor check is **opt-in by marker** (bundle note present, or CLAUDE.md declares the convention); g-onboard asks, never assumes.

**Cross-cutting propagation (G-RULES §B):** the REFERENCE classifier class is a shared primitive the gate, doctor, intake, and scanning skills must all respect — that is why Wave 2's scope-guard line and doctor check are folded *into* this milestone, not left as follow-ups. Run `/g-blast-radius` at Wave 1 close to confirm no reader (skill, hook, or rule) was missed.

---

### M46 — Update Integrity: detect / diagnose / fix split
**Status:** ✅ Complete (shipped v2.4.0, 2026-07-23 — work commit `e3d9d71`; plan `g-docs/plans/m46-update-integrity.md`, forecast `g-docs/forecasts/m46-update-integrity.md`)
**Version:** v2.4.0 (minor — contract change across two skills + one hook; inserted 2026-07-23 ahead of M41, developer call: small, high impact over time — every consumer walks the update path at every release)
**Goal:** The update path can never silently realign a project from a stale plugin cache, and exactly one skill writes while exactly one diagnoses. Three verbs, three owners, one writer: **detect** (`workflow-checkpoint.sh`, direction-aware) → **diagnose** (`/g-doctor`, read-only, recommends the vector) → **fix** (`/g-update`, sole writer, staleness-preflight-guarded).
**Origin:** live G-Cash incident 2026-07-23 — `/g-update` run before the manual `/plugins` cache update "realigned" from the stale 2.2.1 cache while presenting as an update; plus the backwards "update available: 2.3.0 → 2.2.1" checkpoint banner on this repo (check not direction-aware). Full scope, done conditions, and premortem in `g-docs/milestones/M46-update-integrity.md`.
**Scope sketch:** Wave 1 — `/g-update` staleness preflight (stale cache ⇒ stop, write nothing, advise `/plugins` first) + checkpoint semver direction fix (both shipped-bug fixes, test-pinned fail-before/pass-after). Wave 2 — contract split: doctor absorbs version-lag diagnosis (shared compare lib, single implementation), update sheds diagnostic overlap, docs sweep rides.
**Depends on:** — (independent). Ahead of M41: release machinery only compounds traffic on a path that misleads consumers today.

---

### M41 — Release Machinery + README Currency (gated release pipeline)
**Status:** ⬜ Not started
**Version:** v2.5.0 (renumbered 2026-07-23 — M46 Update Integrity inserted ahead at v2.4.0; minor — new release commands + skills + a `/g-doctor` version-consistency check. **RESTRUCTURED 2026-07-18 (developer) — ⚠ the version-arc half of this note is RETIRED by ADR-010 (2026-07-26): the 2.x line ends at v2.5 and M44 is the rebuild's release vehicle, not this arc's capstone; the split-out itself stands. See the ADR-010 stamps on M44 (moved to `g-docs/g-proof-roadmap.md` per ADR-012) and `g-docs/milestones/M41.md`.** Sequenced LAST in the 2.5 build order (ADR-012) — `/g-release` cuts v2.5.0 itself. **Precondition: the session cutting the release reads `g-docs/communication-plan-2.5.md` first** (approved copy, placement rules, open §7 decisions). the G-Proof rebrand + full README restyle were split OUT of this milestone into **M44 — the G-Proof 1.0 capstone, sequenced dead last** — the roadmap runs its whole natural life as G-Forge 2.x, then restarts clean as G-Proof 1.0. What stays here is the release machinery and the standing README/CHANGELOG *currency* convention, which starts even earlier — at the v2.3.0 release (see M-audit's release pass). `g-docs/milestones/M41.md` is the source of truth for `/g-plan`.)
**Goal:** Make cutting a release a **single gated step** instead of a manual, multi-file, error-prone ritual — and make README/CHANGELOG currency a structural property of every release, not a memory-dependent chore. Distribution is straight off `main` (no tags, no CI) — the version field in `plugin.json` **is** the "latest available" signal that `/g-update` and the daily `workflow-checkpoint.sh` check advertise to every installed project — so a wrong or premature bump ships immediately. `/g-release` owns that bump with preconditions and consistency.

**Origin:** observed pain, not hypothetical. Six releases in ~2 weeks (2.0.0→2.2.1), each hand-editing the version in **three places** (`plugin.json`, `marketplace.json`, README counts) + cutting CHANGELOG `[Unreleased]`→dated + (always skipped) tagging. On 2026-07-12 a v2.2.2 bump was made mid-milestone and had to be reverted precisely because nothing gated "is this a coherent, complete release?" — the exact failure `/g-release` prevents. On 2026-07-18 the developer flagged the GitHub README as visibly stale — the currency convention is the structural answer.

**Scope (waved — full task breakdown + done conditions in `g-docs/milestones/M41.md`):**
- **Wave 1 — Release tooling (`/g-changelog` + `/g-release`):** `/g-changelog` **drafts** `[Unreleased]` from the **curated durable record** (milestone-ledger rows, review verdicts, plan done-conditions) — **never raw `git log`** (ledger rows are already human-curated signal; commits are not); Keep-a-Changelog buckets inferred from row type; **draft + human nod** before any write. `/g-release` gates the cut: preconditions (active milestone ✅ closed, full suite green on a **real run** with pasted evidence per finding #20, gate self-hosted clean, no orphaned `[Unreleased]`; refuse on a partial milestone), one-shot version bump across **every** manifest, `[Unreleased]` → dated `## [x.y.z]`, annotated `v{x.y.z}` tag (closes the tagging gap the alveria adopter works around with pinned SHAs). Adds a `/g-doctor` **version-consistency check** (manifests agree; README counts match the `agents/`+`skills/`+`profiles/` inventory) as the standing backstop against a hand bump.
- **Wave 2 — README currency machinery:** `/g-release` verifies the README **status strip** (version badge · "What's new" → CHANGELOG.md · "Where this is going" → ROADMAP — first shipped at v2.3.0 by M-audit's release pass) is current as a release precondition; the lighter `/g-review` Step-6 close-out README-currency mechanism (optional, behavior-change-gated) becomes the reusable per-milestone pass. **The full persuasion-ordered README restyle (gate GIF, positioning narrative, before/after table, FAQ) is NOT here — it ships with M44/G-Proof 1.0 (fork-bound, `g-docs/g-proof-roadmap.md`).**

**Explicitly out of scope:** the G-Proof rename and everything branded (→ M44, fork-bound in `g-docs/g-proof-roadmap.md`); publishing pipelines/CI, signing, changelog generation **from raw commits** (`git log` is never a source), auto-deciding the semver bump (the developer states major/minor/patch; `/g-release` enforces consistency, not the decision), auto-applied README rewrites (always drafted + nodded).

**Depends on:** — (independent; composes with `/g-roadmap`'s milestone close and finding #20's "green run with evidence"). Sequenced **LAST** in the 2.5 build order per [ADR-012](decisions/012-g-forge-2.5-final-release-scope.md) — `/g-release` cuts v2.5.0 itself, so M47, M48, M45, M38, M40, M43, M49 all precede it. *(The earlier "immediately after M-audit, before M42" ordering is retired — M42 is fork-bound.)*

**Premortem:**
- *Becomes a rubber stamp* (med) → if the preconditions are advisory not blocking, it just automates a bad bump. Mitigation: milestone-closed + green-run are hard gates; refuse, don't warn.
- *Version drift across files reappears* (low) → the `/g-doctor` consistency check is the standing backstop even when someone bumps by hand.
- *Tag/manifest divergence* (low) → tag is cut from the same run that writes the manifest; never a separate step.
- *Currency convention decays without enforcement* (med) → that's why the strip check is a `/g-release` precondition, not a habit; the doc gate already covers CHANGELOG on every mixed/doc commit.

**Cross-cutting propagation (G-RULES §B):** the version number is a shared primitive read by `/g-update`, `workflow-checkpoint.sh` (daily update nudge), `/g-doctor`, and the manifests — `/g-release` must be the single writer, and the `/g-doctor` check the single verifier. Run `/g-blast-radius` at Wave 1 close.

---

### M45 — Review Pipeline Rework (code-lead takes seat in HQ)
**Status:** ⬜ Not started
**Version:** v2.5.0 (re-stamped per [ADR-012](decisions/012-g-forge-2.5-final-release-scope.md), 2026-08-10 — rides the final release; was v2.6.0. `/g-review` restructure + reviewer/agent contract changes; sequenced after M48's cheap hardening of the current pipeline, before M38/M40/M43/M41.)
**Goal:** Replace the monolithic code-lead review (200k+ tokens on a smallish repo, §C context poisoning by the fourth axis) with an HQ-embodied code-lead **role** dispatching scoped parallel reviewer waves and a cheap synthesis step — one 200k monolith becomes ~5 small disposable contexts + findings-only verdict assembly.
**Origin:** developer field feedback at the W3 review gate (2026-07-22), `g-docs/milestones/M36-salience-inputs/2026-07-22-review-cost-scaling-feedback.md`. Root cause confirmed against frontmatter: `code-lead` has no Agent tool; `review-orchestrator` degrades when nested; so the whole review runs in one context. Two live stall incidents on the record-write path (W3 r1, v2.3.0 release code-lead).
**Scope:**
- **Design ADR first** (via `/g-adr`): does `code-lead` survive as an agent or fold into the `/g-review` SKILL (ADR-007 one-thing-one-home spirit suggests fold); verdict/HOLD adjudication ownership; telemetry-profile composition (`cautious`/`defensive` reviewer adds vs partitioned waves); record-write structural answer (Write grant per g-forge-dev precedent vs HQ-writes-records convention — 2 stall occurrences).
- `/g-review` restructure: HQ embodies the code-lead role (same pattern as the PM interface rule); dispatches partitioned reviewer waves (per-cluster: gating libs / hooks / skills-docs / tests, or per-axis), each a small disposable context returning compact findings only; synthesis emits MERGE READY / HOLD off findings blocks — never re-reads the diff.
- **Depth-selection slot** built into the partition step, defaulting to flat-deep — the change-class → depth selector is M37's salience consumer, not built here (M36/M37 fork-bound per ADR-012; M36 names review-depth as a first-consumer contract).
- Attestation seam unchanged: g-forge-dev runner + header-vs-runner reconcile (finding #20 doctrine untouched).
- First slice runs with the monolith path still available as fallback (telemetry `recovery` profile) until the partitioned shape proves verdict-equivalent.
- **Cross-cutting propagation (§B):** review verdicts feed the sentinels, telemetry counts holds, `/g-afk` auto-reviews — run `/g-blast-radius` at the design wave; scope incomplete until the completeness gate confirms no consumer missed.

**Depends on:** — (sequenced **third** in the 2.5 build order per [ADR-012](decisions/012-g-forge-2.5-final-release-scope.md): after M48's hardening of the current pipeline, before M38/M40/M43/M41. *The 2026-07-15 "release machinery first" ordering is retired — M41 now cuts the release last.*) Independent of M36/M37, both fork-bound in `g-docs/g-proof-roadmap.md` (ships flat-depth; the depth selector arrives, if ever, with G-Proof's salience layer).

**Premortem:**
- *Synthesis-verdict regression — findings-block verdict misses what a whole-diff read catches* (med) → A/B on the first slice; monolith fallback stays; HOLD adjudication human-visible.
- *Nesting-limit surprises* (low-med) → "directly from a skill in the main session" is explicitly permitted by review-orchestrator's contract; doc-reviewer dispatches from `/g-doc-review` prove the shape.
- *Premature depth-selection* (med) → defaults flat-deep; selector arrives, if ever, with M37 (fork-bound, `g-docs/g-proof-roadmap.md`).

---

### M43 — Operator Controls (/g-settings + inspection cadence)
**Status:** ⬜ Not started (scoped 2026-07-15, developer)
**Version:** v2.5.0 (re-stamped per [ADR-012](decisions/012-g-forge-2.5-final-release-scope.md), 2026-08-10 — rides the final release; was v2.15.0. **Parallel-friendly** — independent of the other 2.5 items, touches only g-init/g-execute skill prose + a new skill. Position is pinned sixth by the ADR-012 build order; the old free-floating "pull-forward eligible, like M36" framing is retired — M36 is fork-bound, `g-docs/g-proof-roadmap.md`.)
**Goal:** Give the operator **visibility and control over G-Forge's setup and operative variables**, and give actual programmers (non-vibe-coders) a first-class way to *read the code* at wave boundaries instead of only meeting it at the review verdict.
**Scope (waved):**
- **Wave 1 — `/g-settings`:** one skill that surfaces every G-Forge state variable with current value, owner (which skill/hook writes it), and effect — `integration-tier`, `voice-profile`, `telemetry-profile`, `inspection-cadence` (Wave 2), Roundtable binding, plus read-only diagnostics (`review-holds`, `milestone-count`, `session-prompt-count`, `escalation-log`, `last-trim`). Safe edits routed through it (validated values only); gate-relevant changes (tier) get an explicit are-you-sure with consequences. **Distinct from `/g-doctor`** — doctor validates *health/state*, settings shows and sets *intent*. Registered in the `/g-forge` router.
- **Wave 2 — Inspection cadence (the programmer's wave-boundary hold):** new variable `.claude/inspection-cadence` ∈ `every-wave` | `every-milestone` | `off` (default `off`). `/g-init` gains ONE intake question ("Do you want to personally inspect the code at wave boundaries?" — framed for experienced devs; decline = off, no friction for vibe-coders). `/g-execute`'s wave-completion gate honors it as a **hard hold**: present the wave's diff summary + changed-file list, dispatch nothing further until the developer nods (consistent with gates-gate; an ignorable pause is not an inspection gate). `every-milestone` holds only before the final wave's `/g-review` handoff.
- **Wave 3 — Propagation (G-RULES §B):** `/g-voice` cross-references (voice = how it *talks*, settings = how it *runs* — the intake flows must not duplicate questions); `/g-doctor` gains a check that `inspection-cadence` holds a valid value; **M39 G-tweak reassess hook** — *(narrowed per ADR-012: M39 is fork-bound, so the interview itself cannot ship from this repo. The 2.5 deliverable is only the documented hook point — the cadence variable readable + the reassess contract written down; the Phase A interview that consumes it lands, if ever, in G-Proof.)*

**Premortem (sketch):**
- *Settings sprawl* (med) — /g-settings becomes a junk drawer as every future milestone adds variables. → Registry table in the skill is THE inventory; adding a variable without registering it = a `/g-doctor` advisory (mirrors finding #19's single-source lesson).
- *Hold fatigue* (med) — `every-wave` on a 7-wave milestone = 7 interrupts; the developer stops reading and nods blind. → G-tweak reassess hook exists precisely for this; the hold prompt shows diff *size* so the developer can calibrate; switching cadence is one /g-settings command away.
- *Second intake question creep on g-init* (low) — init interview bloats one question at a time (the kickoff-friction premortem lesson from M42, fork-bound per ADR-012 — same failure). → Hard rule: ONE question, recommended default, decline = silent off.

**Depends on:** — (standalone. The M39 reassess hook is fork-bound per ADR-012 and cannot activate from this repo — Wave 3's deliverable narrows to the documented hook point above.)

---

### M47 — Planning-Pipeline Honesty (decomposer + calibration)
**Status:** ✅ Complete (shipped 2026-08-12 — merge `6590b60`, 4-round review + parallel cautious reviewer, MERGE READY r4; suite 564/564 attested)
**Version:** v2.5.0 (rides the freeze release — patch-class process fixes, no separate bump)
**Goal:** Plans sized and priced so their numbers get believed and their tasks match how the work actually executes.
**Scope:**
- `task-decomposer`: sizing rule — never split a serial single-file chain across agents (evidence: 2026-07-28 session, 11 tasks collapsed to 1 by wave-planner)
- Reliable result return across the decomposer seam (evidence: same session, empty final message needed a resume to recover the task list)
- Forecast miss-risk calibration derived from recorded forecasts-vs-outcomes, not a static constant (standing complaint: number reads high/static, gets ignored)
- `/g-plan` Step 3c: review-chain cost term + split-depth cap (field-reported by keyline, `g-docs/field-reports/2026-08-10-keyline-francesco.md` §2 — review chain ran 3–10x the implementation estimate and drove a 3-level-deep milestone re-split; their flat-tax constant gets re-derived from both corpora, not copied)

**Premortem:**
- *Over-correction — decomposer under-splits into context-blowing mega-tasks* (med) → sizing rule keyed on file-seriality, not task count; validate against the recorded 11→1 case.
- *Seam contract change ripples to wave-planner / g-execute consumers* (med) → additive output contract only; blast-radius the seam at plan time.
- *Calibration lands but the number still gets ignored* (med) → done condition = number moves with recorded evidence, not another constant.

**Depends on:** —

---

### M48 — Review-Pipeline Hardening (fix-loop killers)
**Status:** ⬜ Not started (2.5 bug-sweep slot 3 — intake 2026-08-10)
**Version:** v2.5.0 (rides the freeze release)
**Goal:** A fix pass can't silently mint the next defect. Field-proven twice independently: keyline's flagship incident (~20 review dispatches for one milestone, `g-docs/field-reports/2026-08-10-keyline-francesco.md` §1) and this repo's own `ec9bf8a` pass (9 rounds, 7 found defects, 2 after clean verdicts).
**Scope:**
- Grep-the-literal-fact sweep as a **required** `/g-review` + `/g-doc-review` step before accepting a fix as closing a finding — sweep output recorded in the review record, checkable, not advisory
- Round-3-same-finding-class consolidation checkpoint ("round 3 on this class — consolidate the repeated facts into one source of truth instead of patching") — surfaced note, never a block
- `doc-reviewer` volatile-fact heuristic: claims about in-flight process counts (round counts, commits-ahead) inside a document under review are a smell — pointer language over hardcoded numbers
- Falsifiability comment rule for guard/negative tests (G-RULES §H, scoped to projects with a suite): guard deleted, test confirmed red, restored — recorded as an in-file one-line comment

**Premortem:**
- *Regression in the gate degrades every future review* (med) → additive steps only; exercised on a scratch changeset before merge; `test-review-severity` stays green.
- *New steps decay into skipped prose — the vigilance trap this milestone fixes* (med) → grep-sweep output must appear in the review record; absence is itself a findable gap.
- *Rule bloat for no-test projects* (low) → falsifiability rule suite-scoped.

**Depends on:** — (sequenced after M47; no hard dependency. Both fed the whole-system audit's scope; the audit ran 2026-08-11 — its Wave C findings fold back into M48's plan as todo task 5. Relationship to M45: M48 is the cheap field-proven hardening of the *current* pipeline, landing before M45's structural rework rebuilds it — per the ADR-012 build order.)

---

### M49 — Devil's-Advocate Agent (internal adversarial pattern review)
**Status:** ⬜ Not started (folded into 2.5 by developer decision 2026-08-14 at /g-patterns lifecycle intake — amends the ADR-012 milestone list)
**Version:** v2.5.0 (rides the freeze release)
**Goal:** The adversarial seat in the `/g-patterns` resolve phase gets an internal occupant. The two-phase pattern lifecycle (shipping ahead of this milestone as a standalone 2.5 rider) reads external counter-reports from `g-docs/inbox/adversarial/` — currently other models via n8n automation, advisory-only. This milestone adds a G-Forge reviewer agent that argues *against* each PENDING pattern resolution from inside the repo, with full source access the external models deliberately don't get.
**Scope:**
- New reviewer-class agent `devils-advocate` (Read/Glob/Grep, findings only) — receives the PENDING resolutions from the saved pattern report and argues against each: is the pattern real, is the proposed rule edit the right fix, what does the edit break
- `/g-patterns` resolve phase dispatches it alongside the external-inbox read; both feed the same triage — internal findings and external counter-reports are suggestions, the human weighs them, neither blocks
- Registration ride-alongs: README agent count, doctor drift-class listing, `test-review-severity` untouched (no shared-ladder verdict — findings list only)

**Premortem:**
- *Agent anchors on the report and rubber-stamps* (med) → prompt contract is refute-first: it must state the strongest case against each resolution before any agreement; agreement without an attempted refutation is a malformed report.
- *Redundant with the external inbox, double noise* (med) → different evidence classes: external models see only the principle-level report; the internal agent sees source. Findings that merely repeat an external counter-report are deduped in triage.
- *Scope creep into a general review agent* (low) → scoped to pattern resolutions only; `/g-review` pipeline untouched.

**Depends on:** the `/g-patterns` two-phase lifecycle rider (report persistence + inbox read) being merged first.

---

## Backlog

*Emptied 2026-08-10 ([ADR-012](decisions/012-g-forge-2.5-final-release-scope.md)): both candidates (multi-session orchestration, unified provenance) are fork-bound and moved to `g-docs/g-proof-roadmap.md` — a **local-only, gitignored** file (developer choice). If that file is missing on this machine, it was lost the way gitignored files get lost — its content is only recoverable from this repo's git history (ROADMAP.md as of any commit before the 2026-08-10 re-scope). Carrying it to the G-Proof fork by hand is a named fork-checklist item.*

## Version Plan

```
v0.8.1 → v0.9.0 (M8) → v0.10.0 (M9) → v0.11.0 (M10) → v0.12.0 (M11)
       → v0.13.0 (M12) → v0.14.0 (M13) → v0.15.0 (M14) → **v1.0.0 (M15) ✅ shipped**
       → **v2.0.0 (M23) ✅** → **v2.0.1 (M24 + stack implementers) ✅** → **v2.1.0 (M27 — doc-review gate) ✅** → **v2.2.0 (M28 — g-docs canonical tracking) ✅**
       → **v2.3.0 (M-audit-2026-07 — Forge Integrity; upgraded from v2.2.2 — W1 is new capability, not fixes; ships the first README status strip + starts the CHANGELOG/README currency convention)** → **v2.4.0 (M46 — Update Integrity: /g-update staleness preflight + checkpoint direction fix + detect/diagnose/fix split; inserted 2026-07-23 — G-Cash stale-cache incident)** → **v2.5.0 — THE FINAL G-FORGE RELEASE** ([ADR-012](decisions/012-g-forge-2.5-final-release-scope.md), 2026-08-10 — full announced scope, one release vehicle, no v2.6+ ever ships from this repo). Build order: **M47** (Planning-Pipeline Honesty) → **M48** (Review-Pipeline Hardening) → **M45** (Review Pipeline Rework) → **M38** (G-Report) → **M40** (Reference Convention) → **M43** (Operator Controls) → **M49** (Devil's-Advocate Agent — folded in 2026-08-14, amends ADR-012 scope) → **M41** (Release Machinery — cuts the release, sequenced last). Already shipped into 2.5: Check 24 injection detector, `/g-init` lib-install fix (`ec9bf8a`). After v2.5.0: this repo freezes (maintenance-only), the tree forks, and **G-Proof 1.0 ships from the fork as the rebuild's release vehicle** (ADR-010 — versioning restarts; no G-Forge 3.0). Everything fork-bound (M25, M26, M29–M37, M39, M42, M44 + both backlog candidates) lives in `g-docs/g-proof-roadmap.md` — local-only, gitignored, carried to the fork by hand per ADR-012. Release comms: `g-docs/communication-plan-2.5.md` (copy approved 2026-07-28; README publication happened 2026-08-10 by recorded developer override of its §4 timing rule — the remaining surfaces publish at release).
```

MVP cut: M9 + M10 + M11 — context structure + failure detection + intelligent planning with premortems.
