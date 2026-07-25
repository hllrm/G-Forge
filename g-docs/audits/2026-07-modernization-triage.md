# 2026-07 Modernization Report — Triage

**Date:** 2026-07-25
**Source:** [2026-07-modernization-report.md](2026-07-modernization-report.md) (hypothesis set, written without repo access against a stale README)
**Ground truth at triage time:** Claude Code CLI **2.1.218** (clears every §5 version gate) · plugin v2.4.0 · 8 hook scripts + hooks.json + 6 libs · 19 agents · 38 skills · single router `commands/g-forge.md` (ADR-007) · 56 profile dirs · /g-doctor 23 checks · SubagentStart/Stop registered (`agent-lifecycle.sh`) · platform: native Windows (sandbox-unsupported host — GF-26/GF-45 directly relevant)
**Live-doc verify (§0.3):** ran 2026-07-25 against code.claude.com. All report evidence HOLDS except: **NESTED** — default-on subagent nesting ended at v2.1.216, now off by default behind `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`; no "spawn classifier v2.1.178" exists. **CHECKPOINT** — native checkpointing does not restore subagent edits (except foreground `context: fork`) or bash-command changes. **WORKFLOWS** nondeterminism clause unconfirmed (not contradicted).

Verdicts: ADOPT / PARTIAL / REJECT / ALREADY-DONE / DEFER. "Target" = the report's candidate clusters M-A…M-F, kept as evidence only — superseded by the R0–R6 re-cut in [2026-07-rebuild-report.md](2026-07-rebuild-report.md) §8; real placement is decided at the pending roadmap gate (seven inputs — see the ROADMAP handoff), not here.

## Triage table

| ID | Verdict | Rationale | Effort | Target |
|---|---|---|---|---|
| GF-01 | ADOPT | Zero `disable-model-invocation` across 38 skills; auto-trigger loop IS model-invoked (G-RULES §B reads the Tier line), so the GF-40 split must be decided first | S | M-B |
| GF-02 | ADOPT | Zero `context: fork`; whole-codebase scanners (g-audit, g-optimize, g-patterns, g-trim…) run inline today; caveat: forked-skill edits are the one subagent case checkpointing DOES restore | S/skill | M-B |
| GF-03 | ALREADY-DONE | ADR-007: per-skill shims retired, single umbrella router `commands/g-forge.md`; no skill/command name collisions possible | — | — |
| GF-04 | ADOPT | Zero `allowed-tools` anywhere; `paths` piece feeds GF-44; `!`-injection could offload part of workflow-checkpoint's every-prompt cost | M | M-B |
| GF-10 | PARTIAL | Report table stale: SubagentStart/Stop already registered. Real gaps: **StopFailure** (afk correctness, P0), SessionEnd, PostToolUseFailure, InstructionsLoaded, PermissionRequest | S each | M-A (StopFailure) + M-D (rest) |
| GF-11 | ALREADY-DONE | check-commit.sh blocks via stdout JSON deny + exit 2, contract documented in-file as load-bearing; pinned by test-check-commit.sh + class-split invariant suite (ADR-008) | — | — |
| GF-12 | ADOPT | Unused, confirmed live (plus extras: `initialUserMessage`, `watchPaths`); `reloadSkills` removes /g-update's restart requirement | S | M-D |
| GF-13 | ALREADY-DONE | No SessionStart matcher registered; session-start.sh branches on `source` internally. Rider: guard `model`-field reads, note `fork` source value | — | rider |
| GF-20 | DEFER | Spike only, gated on GF-46 ADR; workflows live at 2.1.218. Hybrid (/g-plan emits workflow script as approved artifact) is the variant to spike first | L | M-E |
| GF-21 | PARTIAL | Report wrong per live docs: nesting now OFF by default (post-2.1.216, env-gated). Depth-0 constraint stands on default config — reword README:342 to cite the platform default + env override, no architecture reopening | S | M-A |
| GF-22 | PARTIAL | Advisor experimental + Anthropic-API-only → watch, don't depend. `CLAUDE_CODE_SUBAGENT_MODEL` roster default worth taking; keep explicit tiering for review pipeline (G-RULES A1) | S | backlog |
| GF-23 | PARTIAL | Keep gate semantics (the product), make swarm pluggable: delegate option to /code-review ultra. Note: ultra is user-triggered only (disable-model-invocation), billed, needs git repo — delegation is offered, never auto | M | M-E |
| GF-25 | ADOPT | /goal confirmed; machine-demonstrable vs judgment-required split maps 1:1 onto Tier 1/2 vs Tier 3 — genuine G-Forge contribution on top of native primitive | M | M-C |
| GF-26 | ADOPT | Layer sandbox + auto mode + deny-list as depth. Hard caveat: THIS host is native Windows = sandbox unsupported + fails open → feature-detect, keep deny-list as documented Windows fallback; revise README:622 `--dangerously-skip-permissions` tip | M | M-C |
| GF-27 | ADOPT | Worktree-isolated /g-execute mode, conflict validator demoted to non-worktree fallback; repo already has worktree-resolve lib + linked-worktree test coverage as a base | M | M-E |
| GF-30 | ADOPT | Policy stays, estimator goes. Report's threshold numbers stale (A7 is now lenient-baseline + auto-calibrating offset, not fixed 25/40) but proxy critique stands; statusline = visible differentiator | M | M-B |
| GF-31 | PARTIAL | Goal right, mechanism wrong per live docs: native checkpointing does NOT restore subagent edits — wave work is exactly that. Recovery = git snapshot before wave (stash/ref), not /rewind | M | M-C |
| GF-32 | PARTIAL | Diff §J taxonomy vs native auto memory; shrink overlap, keep the layer-declaration contract (`context:` frontmatter) | M | backlog |
| GF-33 | PARTIAL | Keep the 8 derived metrics (differentiator); source token-efficiency + retry-dependency inputs from OTel//usage instead of hand-counting | M | M-F |
| GF-40 | ADOPT | Confirmed verbatim at v2.1.196+. Decide the split (gated-user-invoked vs ungated-scheduled-reporter) BEFORE GF-01; record as ADR; document in G-RULES §B | S decide / M implement | M-B (ADR first) |
| GF-41 | ADOPT | Add `--safe-mode` bisect + feature detection to /g-doctor; native /doctor is now detect+fix (w28) — namespacing already distinct | S | M-D |
| GF-42 | PARTIAL | Adopt plugin dependency constraints + relevance block; evaluate retiring the daily curl poll (workflow-checkpoint.sh:449) once native surfacing proves out | M | M-F |
| GF-43 | ADOPT | CI-side gate companion = highest strategic leverage in report; README:276 documents the local bypass today. Solo-dev honest scope until then | L | M-F |
| GF-44 | DEFER | 56 profile dirs; path-triggered rules only if GF-02/GF-04 measurements show global rule loading is a material context cost | L | backlog |
| GF-45 | ADOPT | This very host proves it (Windows: no sandbox, silent fail-open). Feature-detect in /g-doctor + README compatibility table + degradation path per adopted feature | M | M-C |
| GF-46 | ADOPT (decision) | Language-surface ADR (shell-only vs optional JS/Bun tier vs migrate) gates GF-20/33/60/61 — run /g-adr before any M-E work | decision | pre-M-E ADR |
| GF-60 | DEFER | Experimental, env-gated, known limitations; too aligned to ignore — watch + prototype note only | L | watch |
| GF-61 | DEFER | Research preview + Bun + Anthropic-auth-only; revisit after GF-46 ADR | L | watch |
| GF-62 | ADOPT | `.claude/loop.md` G-Forge maintenance default — small, on-brand; payload must respect GF-40 (only ungated skills) | S | M-B rider |
| GF-63 | PARTIAL | Line-items: prompt-caching note into /g-update docs (S, adopt); output styles vs /g-voice (verify-then-decide); structured outputs + artifacts ride GF-46; rest watch | S–M | scattered |

## Platform deltas since report evidence (w27–w29, v2.1.195 → v2.1.212)

Unaudited by the report; relevant to planning:

- **Subagents background by default** (v2.1.198) — wave dispatch semantics: `background` frontmatter pin available.
- **Hyphenated hook matchers now exact-match** (w27) — our only matcher is `"Bash"`, unaffected; note for future matchers.
- **Session-wide caps**: 200 subagent spawns / 200 WebSearches per session, `CLAUDE_CODE_MAX_SUBAGENTS_PER_SESSION` tunable (v2.1.212) — /g-afk long runs must budget this.
- **/doctor is detect+fix** (v2.1.205) — flags slow hooks, unused skills/plugins; overlaps /g-doctor's advisory lane, reinforces GF-41 namespacing.
- `/fork` spawns background session; in-session fork renamed `/subtask` (w29).
- Explore agent inherits session model, capped at Opus (w27).
- MCP calls >2 min auto-background (w29).

## Coverage sweep — what the report missed (GF-70…GF-78)

Full llms.txt enumeration vs the report's appendix, run 2026-07-25. Newest digest = w29; changelog runs to **v2.1.220**; report's evidence stops at w26. Net-new findings, triaged same scale:

| ID | Verdict | Finding | Effort | Target |
|---|---|---|---|---|
| GF-70 | ADOPT | **w18: Windows without Git Bash falls back to PowerShell as the shell tool** — all 8 bash hooks silently dead on such hosts. Feature-detect in /g-doctor + hard README requirement (Git Bash) + degradation story. Report never saw it | M | M-A/M-C (correctness) |
| GF-71 | ADOPT | **w25: `Tool(param:value)` permission matching** — parameter-match `git commit` at the permission layer as gate defense-in-depth; `Agent(model:opus)` deny could enforce A1 tiering natively | S–M | M-B/M-D |
| GF-72 | PARTIAL | **sessions page**: native naming/branch/fork/`--from-pr`, `--teleport` web↔terminal — cross-check /g-resume + handoff assumptions against native session branching | S verify | backlog |
| GF-73 | ADOPT | **`claude project purge` wipes `.claude`** incl. sentinels, journal, counters — document as data-loss caveat; /g-doctor note | S | rider |
| GF-74 | PARTIAL | **Anthropic ships two vuln-scan plugins** — overlaps `security-auditor`; same pluggable-swarm treatment as GF-23 | M | M-E rider |
| GF-75 | DEFER | **costs page**: spend limits + native "preprocessing hooks" cost lever — A4 relevance, read before M-B context work | S read | backlog |
| GF-76 | ADOPT | **v2.1.219 (Jul 24): Opus 5 default model, 1M context** — A7 gate thresholds and A1 tier table both predate this; recalibrate against 1M-window reality | M | M-B (with GF-30) |
| GF-77 | PARTIAL | **plugins / plugin-marketplaces / plugin-hints** authoring guides never audited — fold into GF-42 distribution pass | S read | M-F rider |
| GF-78 | ADOPT | **15 weekly digests unaudited** (w13–w23, w25, w27–w29) — one-time backfill read + the standing weekly platform sync (below) | S/week | process |

Also from sweep, riders on existing rows: w27 hyphenated-matcher exact-match (18 of 19 agent names hyphenated — `debugger` is the single-word exception; matters the day agent-name matchers appear) · w28 /doctor flags slow hooks (GF-41) · w29 "always allow" persists across worktrees (GF-27) · output-styles page confirmed live (GF-63 verify item) · llms.txt fetch quirk: URLs need `en/` prefix.

**Proposed process (intake candidate):** weekly platform sync — fetch latest `whats-new/` digest, cross-ref against this document as the living feature map, file deltas as intake rows. Nudged by workflow-checkpoint when ≥7 days stale, same rhythm as /g-trim.

## Summary counts

Report rows: ADOPT 14 (incl. GF-46 decision-only) · PARTIAL 9 · ALREADY-DONE 3 · DEFER 4 (GF-60/61 = watch) · REJECT 0. Sweep rows: ADOPT 5 · PARTIAL 3 · DEFER 1. The report's §7 thesis (mechanisms depreciate, opinions don't) survives triage intact; its two factual misses (nesting default, checkpoint scope) both narrow adoption rather than expand it — but the sweep shows its coverage stopped short: GF-70 (PowerShell-fallback hosts) and GF-76 (Opus 5 default, 1M context) are both material and post-date its evidence.

**Feeds:** ADOPT/PARTIAL rows → the pending roadmap gate under the R0–R6 rebuild shapes ([2026-07-rebuild-report.md](2026-07-rebuild-report.md) §8 — the M-A…M-F clusters are retired evidence) · plus /g-intake ×3 · /g-patterns §G proposal · three-horizon re-scope · M44 pull-forward · client/cockpit candidate · weekly platform sync proposal. Pre-gate ADRs: GF-40 split · GF-46 (decided — full rebuild; ADR capture pending).
