# Rebuild Map — G-Forge components vs the 2.1.220 platform

**Date:** 2026-07-25
**Frame (developer directive):** this is not integrating features into G-Forge — it is rebuilding G-Forge **on and with** the current Claude Code feature set. Unit of analysis is the G-Forge component. Per component: does a native feature **or combination of features** now do this job? If yes, the component dies or transforms and the cascade follows the blast radius — massive change is acceptable. Nothing is grandfathered.
**Verdicts:** SURVIVES (no native equivalent — a G-Forge opinion) · SHRINKS (native covers part; residue stays) · TRANSFORMS (job remains, mechanism rebuilt on native substrate) · DIES (native combo subsumes it).
**Status:** triage-grade hypotheses feeding the roadmap gate. DIES ≠ delete today — every DIES/TRANSFORMS row is gated on the GF-46 language ADR and, where marked, the GF-20 spike evidence. GF-IDs cite the evidence rows in [2026-07-modernization-triage.md](2026-07-modernization-triage.md).

---

## Worked example — code-lead (the developer's own test case)

Native combo that overlaps it: **/code-review** (5 effort levels, ultra cloud swarm) + **advisor** (stronger model consulted at decision points — a merge verdict is exactly a decision point) + **/goal evaluator** (independent done-condition judgment) + **/doctor** (env health).

What that combo does NOT do: verify done conditions against a *milestone's* scope; demand an attested Tier-1 run and refuse a confabulated total; issue MERGE READY/HOLD with no-partial-merge semantics; write the gate sentinel; assess milestone feasibility for the PM.

**Verdict: TRANSFORMS.** code-lead stops being a diff-reviewer-plus-orchestrator and becomes the *gate adjudicator*: consumes native review output (delegated swarm), runs done-condition + Tier-1 attestation checks (its real opinion), issues the verdict, writes the sentinel. Its diff-reading duplicate of the swarm dies.
**Cascade:** /g-review SKILL rewrite · review-orchestrator (below) · G-RULES §H Tier-1 wording · telemetry review-catch-rate metric source · ADR-008 cadence untouched (gate semantics survive whole).

---

## Agents (19 + 1 template-instantiated)

| Component | Verdict | Native ground | What remains / cascade |
|---|---|---|---|
| code-lead | TRANSFORMS | /code-review + advisor + goal (combo above) | Gate adjudicator: done-conditions, Tier-1 attestation, MERGE READY/HOLD, sentinel. Cascade: g-review, §H |
| review-orchestrator | DIES | /code-review ultra (multi-agent swarm) or workflow script fan-out | Was a dispatch workaround; both native paths orchestrate. Cascade: g-review, README:342 depth-0 note (GF-21) |
| code-reviewer | DIES | /code-review effort levels | Lens survives only as prompt/rules content the native review reads via CLAUDE.md (GF-23 deeper — verify inheritance) |
| security-auditor | DIES | Anthropic vuln-scan plugins + /security-review (GF-74) | OWASP lens folds into rules content; fallback prompt kept per compat matrix |
| performance-auditor | SHRINKS | /code-review partially | Perf-budget opinion + estimated-impact format stay as review-rules content |
| architecture-enforcer | SURVIVES* | Nothing enforces layer maps | *If ultra inherits CLAUDE.md rules (GF-23 deeper), TRANSFORMS into rules-content + spot-verifier |
| dependency-auditor | SHRINKS | Native security surface partially | License/unused-deps opinion stays |
| doc-reviewer | SURVIVES | No native doc-currency gate | Currency rule is an opinion (§G) |
| task-decomposer | SHRINKS | Workflow script structure holds the decomposition | Atomic-verifiable-task discipline folds into /g-plan itself |
| wave-planner | DIES | pipeline()/parallel() in workflow scripts IS the schedule (GF-20) | Gated on GF-20 spike. Cascade: forecasts, §C wave model, telemetry wave metrics |
| spec-writer | SURVIVES | Nothing native writes airtight executor contracts | Core seam discipline (§C) — feeds workflow agent() prompts instead |
| feature-implementer / stack implementers / claude-plugin-implementer | SHRINKS | workflow agent() calls, background subagents, worktree isolation | Single-use one-attempt contract + stack idioms survive as agent definitions invoked BY workflows |
| refactor-executor | SHRINKS | Same as implementers | Executes specs verbatim — survives as workflow-invoked agent |
| test-writer | SURVIVES | No native equivalent of author-only + attested-runner split | §H ownership model intact |
| debugger / error-detective | SURVIVES | Advisor overlaps slightly (API-only, experimental) | Three-strikes learnings loop is an opinion |
| doc-writer | SURVIVES | Nothing native writes WHY-docs by contract | §G ownership rule intact |
| pr-writer | SHRINKS | Native PR flows generate descriptions | Keep only if G-Forge verdict-context adds value |
| project-manager | SURVIVES | Native planning is task-scoped, not project-scoped | The product. Untouched by platform |

## Skills (38)

| Component | Verdict | Native ground | What remains / cascade |
|---|---|---|---|
| g-review | TRANSFORMS | Delegated swarm (ultra user-triggered + billed — offered, never auto) | Verdict semantics + sentinel + no-partial-merge applied over native output; own swarm = compat fallback |
| g-execute | TRANSFORMS | Dynamic workflows + background subagents + worktrees (GF-20/27) | /g-plan emits workflow script as the approved artifact; wave-boundary holds become script barriers; five-line return contract DIES (schema returns); same-wave conflict validator DIES (worktrees). Gated on GF-20 spike + GF-46 ADR |
| g-plan | TRANSFORMS | Workflow scripts as plan artifact | Opinionated decomposition + human approval survive; output format changes. Cascade: g-forecast, g-blast-radius inputs |
| g-afk | TRANSFORMS | /goal + sandbox/auto-mode + scheduled surfaces + Remote Control (GF-25/26) | QA-scope→goal compilation with Tier-3 hard stop = the new core; deny-strings → Windows fallback; StopFailure hook fixes complete-vs-rate-limited (GF-10) |
| g-listen | SHRINKS now, TRANSFORMS later | Channels (preview, Bun — GF-61 watch) | Listen-mode discipline survives; intake channel when out of preview |
| g-telemetry | TRANSFORMS | OTel + /usage (GF-33) | 8 derived metrics + adaptive profile survive; hand-counting dies |
| g-doctor | TRANSFORMS | --safe-mode, native /doctor detect+fix, feature-availability (GF-41/45/70) | Becomes THE compat/feature-detect authority: Git Bash presence, sandbox, Bun, API surface + drift checks |
| g-update | SHRINKS | reloadSkills, plugin dependency constraints, native update surfacing (GF-12/42) | Staleness preflight opinion stays; restart requirement + curl poll die |
| g-status / g-help | SHRINKS | /context, /usage, statusline | Project-state synthesis stays; raw numbers from native |
| g-resume / g-retro | SURVIVES | sessions page overlaps mechanically (GF-72 verify), auto memory adjacent | The promote-out/pull-in seam is the context-poisoning opinion — nothing native distills |
| g-roadmap / g-intake / g-align / g-brief / g-kickoff / g-onboard | SURVIVES | Nothing project-scoped native | The product |
| g-adr | SURVIVES | — | Decision-hygiene loop is an opinion |
| g-forecast / g-blast-radius / g-patterns / g-identity | SURVIVES | OTel gives better inputs | Re-point at workflow-shaped plans after GF-20 |
| g-audit / g-optimize / g-docs / g-trim | SHRINKS | context: fork (GF-02), native /doctor overlaps g-trim partially | Same audits, forked execution; g-trim's CLAUDE.md dedup overlaps native /doctor — check |
| g-doc-review | SURVIVES | No native doc gate | — |
| g-wiki | SURVIVES | Artifacts as optional render target (GF-63) | — |
| g-specialize | SHRINKS | paths-triggered skills (GF-44, measured) | Profile content survives; global-append delivery may die |
| g-init | SHRINKS | Native Setup hook (`--init`/`--init-only`) + documented `.claude` directory layout (the scaffold-layout diff named in the source report's GF-32 action) | Scaffold *content* (brief, roadmap, gate files, tier) is the opinion and stays; provisioning mechanics move toward the Setup hook; scaffold must match the documented layout |
| g-refactor | SHRINKS | Same substrate as the other executors (workflow-invoked refactor-executor, worktrees) | Spec-first refactor discipline survives; its wave mechanics follow g-execute's transform |
| g-voice | SHRINKS? | Output styles (GF-63 — verify overlap first) | If output styles cover rendering, keep only the 2-question intake |
| g-tier / g-train / g-skill-design / g-skill-validate / g-roundtable | SURVIVES | Roundtable: MCP transport candidate per ADR-001 (mcp page) | Opinions / already surface-agnostic |

## Hooks (8 + 6 libs)

| Component | Verdict | Native ground | What remains / cascade |
|---|---|---|---|
| check-commit.sh + pre-commit (native) + post-commit-cleanup.sh | SURVIVES | Nothing native gates commits on review verdicts | The product. Hardened: Tool(param:value) rules (GF-71) + CI companion (GF-43). `claude project purge` caveat (GF-73) |
| workflow-checkpoint.sh | TRANSFORMS | Statusline + /context (GF-30/76) + skill !-injection (GF-04) | Depth counter/threshold-offset estimator DIES; state banner slims; update poll dies (GF-42); nudges stay |
| session-start.sh / pre-compact.sh | SHRINKS | SessionEnd hook (GF-10), CLAUDE_ENV_FILE (GF-12), sessions surface | Handoff write moves to SessionEnd (clean exits covered — today only PreCompact writes); counter machinery follows checkpoint estimator out |
| observe.sh / agent-lifecycle.sh | SHRINKS | OTel events + SubagentStart/Stop already registered | Journal as distilled /g-retro input survives; raw collection may ride OTel |
| libs (stdin-read, semver-compare, worktree-resolve, sentinel-read…) | FOLLOWS HOSTS | — | Live/die with their consumers; semver-compare survives (ADR-009); worktree-resolve grows if GF-27 lands |

---

## Shape of the rebuild

- **SURVIVES cluster = the product:** gate + sign-off semantics, PM/roadmap discipline, three-tier testing ownership, retro/resume seam, spec/doc/test contracts, ADR hygiene. Matches report §7 exactly — and it's the smaller half of the tree.
- **DIES/TRANSFORMS cluster = most of the mechanism layer:** review swarm, wave engine, context estimator, unattended loop control, telemetry collection, update polling. Per the tables above: 4 agents die outright (review-orchestrator, code-reviewer, security-auditor, wave-planner), 1 transforms (code-lead), ~6 shrink; the heaviest skills (plan/execute/review/afk, plus telemetry/doctor) transform, most other mechanism skills shrink.
- **Two decisions unlock everything:** GF-46 language ADR (workflow scripts are JS) and GF-40 invocation/scheduling split. GF-20 spike is the evidence gate for the biggest deletions.
- **Compat floor:** every DIES verdict keeps a documented fallback where the native ground is platform-gated (Windows/no-sandbox/no-Bun hosts — GF-45/70). Fallback ≠ parallel implementation; it's the degraded path, stated honestly.
