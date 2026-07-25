# G-Forge Rebuild Report — v2, repo-grounded
**Date:** 2026-07-25 · **Supersedes** [2026-07-modernization-report.md](2026-07-modernization-report.md) (external hypothesis set, kept as received-input record) for all planning purposes.
**Ground:** repo tree at v2.4.0 · CLI 2.1.218 installed, changelog to 2.1.220 · every §5 version gate of the original cleared · live-doc verify + full llms.txt coverage sweep run 2026-07-25.

## 1. Frame — the developer's directive

This is **not** feature integration. The question is: *if G-Forge were built today, on the 2.1.220 platform, what would it be?* Unit of analysis is the G-Forge component, not the platform feature. Per component: does a native feature **or combination** now do the job? If yes, the component dies or transforms and the cascade follows the blast radius — massive change is in-scope. Nothing is grandfathered because it exists.

The original report's own thesis survives and sharpens: **the opinions are the product; the mechanisms are rented time.** What v2 changes is the default posture — the original said "add native features alongside"; v2 says "native is the foundation, G-Forge keeps only what the platform cannot say."

## 2. What G-Forge is, post-rebuild (the SURVIVES set)

The product, stated positively — everything below has **no native equivalent** and is untouched or strengthened:

1. **The gate** — commit blocked without a review verdict; MERGE READY/HOLD; no partial merges; sentinel consumed per commit; mandatory human sign-off (Tier 3). Hardened by `Tool(param:value)` permission rules (GF-71) and, strategically, a CI-side companion (GF-43).
2. **Project-scoped discipline** — PM interface, brief, roadmap, intake/challenge, milestone sequencing, version planning. Native planning is task-scoped; this whole layer is uncontested.
3. **Three-tier testing ownership** — author/runner split, attested runs, Tier-3 human verdict. Gains a sharp new edge: Tier 1/2 criteria compile into `/goal` conditions, Tier 3 becomes the hard stop that ends unattended runs (GF-25).
4. **The context-hygiene seam** — retro → handoff → resume; single-use agents; spec contracts; ADR hygiene. The *policy* survives; its estimator dies (below).
5. **Doc/test/spec contracts** — doc-writer, test-writer, spec-writer, doc-reviewer, currency rule.

## 3. What dies or transforms (the mechanism layer)

Full per-component table: [2026-07-rebuild-map.md](2026-07-rebuild-map.md). Summary:

| Subsystem | Verdict | Native ground | The residue G-Forge keeps |
|---|---|---|---|
| Review swarm (review-orchestrator + 5 reviewer agents) | DIES (swarm) / TRANSFORMS (code-lead) | /code-review incl. ultra + vuln-scan plugins + advisor | code-lead becomes gate adjudicator: done-conditions vs milestone, Tier-1 attestation, verdict, sentinel. Reviewer lenses fold into rules content native review reads via CLAUDE.md (verify inheritance — GF-23) |
| Wave engine (wave-planner, five-line returns, conflict validator, g-execute mechanics) | DIES / TRANSFORMS | Dynamic workflows + schema returns + worktrees + background subagents | /g-plan emits an approved **workflow script** as the plan artifact; holds become script barriers; spec-writer feeds agent() prompts. Gated on GF-20 spike |
| Context estimator (prompt counter, threshold offsets, plan-time exchange math) | DIES | Statusline + /context + 1M-context Opus 5 default (GF-30/76) | The A7 *policy* (no new scope when filling, retro at red, handoff before end) on real measurement |
| Unattended control (g-afk loop logic, deny-strings) | TRANSFORMS | /goal + sandbox + auto mode + StopFailure hook (GF-25/26/10) | QA-scope → goal compilation with Tier-3 hard stop; deny-strings demoted to documented Windows fallback |
| Telemetry collection | DIES (collection) | OTel + /usage (GF-33) | The 8 derived metrics + adaptive orchestration profile |
| Update/distribution machinery (curl poll, restart-to-land) | DIES | Plugin dependency constraints + reloadSkills + native surfacing (GF-42/12) | Staleness-preflight opinion inside /g-update |
| Session bookkeeping (counter files, PreCompact-only handoff write) | SHRINKS | SessionEnd hook, CLAUDE_ENV_FILE, sessions surface (GF-10/12/72) | Handoff content + retro synthesis; clean exits finally covered |

Net roster effect (hypothesis, gate decides — counts per the rebuild map's tables): 4 agents die outright, 1 transforms (code-lead), ~6 shrink; the four heaviest skills (plan/execute/review/afk) all transform; hooks thin to gate + slim state banner + lifecycle relays.

## 4. Corrections to the original (live-doc verified — doc wins)

- **Nesting:** default-on subagent nesting **ended at v2.1.216**; now opt-in via `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`. No "spawn classifier v2.1.178" exists. Depth-0 constraint on review-orchestrator **stands on default config** — README:342 needs reword (cite platform default + env override), not retraction. Moot anyway if review-orchestrator dies (§3).
- **Checkpointing:** does **not** restore subagent edits (except foreground `context: fork`) or bash-command changes. Wave/workflow recovery must be **git-snapshot-before-dispatch**, not /rewind (GF-31).
- **Already done in-repo, contra report:** exit-2 gate contract (GF-11, ADR-008-pinned), single-router commands (GF-03, ADR-007), matcher-less SessionStart branching on `source` (GF-13), SubagentStart/Stop registration (GF-10 partial).

## 5. What the original never saw (coverage sweep, GF-70…78)

- **GF-70 — material:** w18 — Windows without Git Bash runs **PowerShell as the shell tool**; all 8 bash hooks silently dead on such hosts. /g-doctor feature-detect + hard README requirement + degradation story.
- **GF-76 — material:** v2.1.219 (Jul 24) — **Opus 5 default, 1M context**. A7 thresholds and the A1 tier table predate this; recalibrate.
- GF-71 `Tool(param:value)` permission matching — gate defense-in-depth + native A1 enforcement lever.
- GF-73 `claude project purge` wipes `.claude` (sentinels, journal, counters) — data-loss caveat.
- GF-72 native sessions surface (branch/fork/`--teleport`) — cross-check /g-resume assumptions.
- GF-74 Anthropic vuln-scan plugins — folds into the review delegation.
- GF-77 plugin authoring/marketplace/hints guides unaudited — ride the distribution pass.
- GF-78 15 weekly digests unaudited (w13–w23, w25, w27–w29) — backfill once, then the standing weekly sync (§7).

## 6. Decision gates — nothing structural moves before these

1. **GF-46 — language surface. DECIDED 2026-07-25: FULL REBUILD** — developer confirmed in direct Q&A (recorded in [2026-07-triage-review.md](2026-07-triage-review.md)); remaining work is the ADR capture via /g-adr, not the decision. Option set retained for the ADR record: shell-only (small adoption set) / optional JS tier with degradation / migrate-rebuild ← chosen. Gates §3 rows 1–2 and everything in the original's §G.
2. **GF-40 — invocation × scheduling split ADR.** `disable-model-invocation` skills can't be scheduled payloads (v2.1.196+). Split: gated-user-invoked (verdicts, gate mutation) vs ungated-scheduled-reporter (reads state, escalates). Also resolves the §B auto-trigger conflict — auto-triggers are model-invoked today.
3. **GF-20 — spike evidence.** Re-run one closed milestone as a workflow script vs the wave record: tokens, wall-clock, HQ context, induced-failure behavior. The deletion of the wave engine is priced by this, not by faith.

## 7. Standing process — weekly platform sync

The original was stale in weeks; the sweep found 15 unaudited digests. Institutionalize: weekly, fetch the latest `whats-new/` digest, cross-reference against the **rebuild map as the living feature-map**, file deltas as intake rows. Nudged by the checkpoint hook at ≥7 days, /g-trim rhythm. One-time backfill of the 15 digests first (GF-78).

## 8. Candidate milestone shapes (rebuild-cut — replaces the original's additive M-A…M-F)

Raw material for the gate; order and survival of the *existing* queued milestones (M26/M35/M29/M33/M43…) are decided there too.

- **R0 · Decisions:** GF-46 ADR · GF-40 ADR · GF-21 retest + README rewords · GF-20 spike. *Everything else is priced by these.*
- **R1 · Floor:** compat matrix + feature detection in /g-doctor (GF-45/70) · StopFailure (GF-10) · purge caveat (GF-73) · README corrections (:276 :342 :622).
- **R2 · Context truth:** estimator out, statusline in (GF-30) · GF-76 recalibration · `context: fork` + `allowed-tools` hygiene (GF-02/04) · SessionEnd handoff (GF-10).
- **R3 · Execution rebuild:** plan-emits-workflow · worktree isolation · schema returns · git-snapshot recovery (GF-20/27/31/63). *Gated on R0.*
- **R4 · Review rebuild:** delegated swarm + code-lead as adjudicator (GF-23/74) · Tool(param:value) hardening (GF-71).
- **R5 · Unattended rebuild:** /goal compilation + sandbox layering + honest-unattended docs (GF-25/26).
- **R6 · Reach:** CI-side gate (GF-43) · distribution (GF-42/77) · OTel inputs (GF-33).
- **Watch:** agent teams (GF-60) · channels (GF-61) · profile restructuring (GF-44) · advisor (GF-22).

## 9. Relationship to the M44 question

Developer signal stands: 2.x line plausibly ends at the rebuild; M44 (G-Proof rebrand) may pull forward to land right after it. That reversal needs its own ADR + the three conscious calls already recorded in the handoff. The rebuild strengthens the case: post-rebuild G-Forge is a different, smaller, sharper artifact — rebranding *that* is more honest than rebranding the current tree.
