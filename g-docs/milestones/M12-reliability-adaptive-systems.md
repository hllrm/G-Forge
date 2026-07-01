# M12 — Reliability & Adaptive Systems

**Status:** ✅ Complete
**Version:** v0.13.0
**Branch:** feat/m12-reliability-adaptive-systems

## Goal

Make G-Forge measurably reliable. Define 8 metrics that span the failure modes the project actually experiences, compute them from the corpus that earlier milestones started to accumulate, and use the resulting health profile to adapt orchestration in `/g-execute` and `/g-review`. Self-tuning, not self-rewriting — telemetry adjusts behavior; the developer-approved plan and the human review gate stay authoritative.

## Scope

### 1 — 8 reliability metrics defined

`docs/telemetry-metrics.md` documents the eight metrics in full: hallucination rate, review catch rate, regression frequency, rework rate, spec deviation, escalation frequency, token efficiency, retry dependency. Each metric carries its observable source, computation formula, expected range, ⚠ threshold, and which downstream skill consumes it.

**Done condition:** `docs/telemetry-metrics.md` exists with all 8 metrics fully specified plus the health-profile derivation table.

---

### 2 — `/g-telemetry` skill

New maintenance skill. Reads retros, todo-done, and git history; computes the 8 metrics per the spec file; classifies the project into one of four health profiles (`stable`, `cautious`, `defensive`, `recovery`); writes the profile to `.claude/telemetry-profile` and a structured snapshot to `docs/telemetry/YYYY-MM-DD.md`.

**Done condition:** `skills/g-telemetry/SKILL.md` exists with frontmatter, Announce, Steps 1–6, Rules; the skill applies the same `None recorded.` sentinel filter as `/g-patterns`; bootstrapping projects skip computation and default to `stable`.

---

### 3 — Adaptive orchestration in `/g-execute`

`/g-execute` Step 0 reads `.claude/telemetry-profile` and adjusts: wave-size cap, default model tier, and an extra prompt clause appended to every agent dispatch. `defensive` caps waves at 3 agents and bumps Sonnet → Opus; `recovery` forces serial dispatch (1 agent/wave) and Opus on every dispatch.

**Done condition:** `skills/g-execute/SKILL.md` Step 0 reads the profile, announces it, and applies the wave-cap / model-bump / prompt-clause rules per the table.

---

### 4 — Governance intelligence in `/g-review`

`/g-review` Step 0 reads the same telemetry profile and adjusts: reviewer count, pre-review additions (debugger, error-detective), and HOLD-counter increment for `recovery`/`defensive` projects. The HOLD counter feeds back into the next telemetry snapshot, closing the adaptive loop.

**Done condition:** `skills/g-review/SKILL.md` Step 0 reads the profile, passes it to code-lead in Step 4, and writes to `.claude/review-holds` on HOLD verdicts when the profile demands it.

---

## Done Conditions (milestone)

- [x] `docs/telemetry-metrics.md` exists with all 8 metric definitions and the profile-derivation table
- [x] `skills/g-telemetry/SKILL.md` exists with proper structure
- [x] `commands/g-telemetry.md` exists and routes correctly
- [x] `/g-telemetry` registered in `commands/g-team.md` router and `G-RULES.md` §B
- [x] `skills/g-execute/SKILL.md` Step 0 reads `.claude/telemetry-profile` and applies adjustments
- [x] `skills/g-review/SKILL.md` Step 0 reads `.claude/telemetry-profile` and applies adjustments
- [x] `plugin.json` and `marketplace.json` at v0.13.0; skill count 26
- [x] CHANGELOG `[0.13.0]` entry added
- [x] README skill list, command reference, skill count, and roadmap table reflect M12 + `/g-telemetry`
- [x] M12 marked ✅ Complete in ROADMAP.md

## Tier 3 DoD

Developer runs `/g-telemetry` interactively. The skill produces an 8-metric report, derives a profile (likely `stable` or `cautious` on this corpus since the project is small), and writes `.claude/telemetry-profile` plus a dated snapshot. The next time `/g-execute` runs, it announces the active profile in Step 0. The next time `/g-review` runs, it does the same.

**Empty-corpus case:** running `/g-telemetry` on a fresh project with <3 retros and <30 commits writes `stable` and emits `cold-start — telemetry deferred until corpus accumulates`. That is a pass.

## Depends on

M9 (memory taxonomy), M10 (`/g-patterns` corpus mining established the sentinel-filter pattern), M11 (`/g-forecast` outcome tracking provides one of the signal sources).
