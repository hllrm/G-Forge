---
name: g-intake
description: Proactive feature-drop triage. When the developer drops a feature idea mid-stream, classify it against the brief (on-brief / scope-creep / out-of-scope), propose where it belongs (existing milestone, new milestone, or backlog) with a version impact and a one-line risk hint — then ask before writing anything. The fast front-end to /g-roadmap for single ideas.
context: [task, sprint]
---

**Announce:** "Using g-intake to triage that feature against the plan."

A dropped feature is a fork in the road, and the cost of taking it silently is scope creep nobody decided on. The old behavior routed every feature idea straight into `/g-roadmap`'s four-phase planning — too heavy for a single "oh, can we also add X." This skill is the lightweight, proactive triage that fires the moment an idea lands: it reads the idea against the brief and the roadmap, tells the developer honestly where it fits and what it costs, and **then** asks what to do. It never writes the roadmap on its own.

Use this for a **single feature idea dropped mid-stream**. For a full feature dump / re-plan, hand off to `/g-roadmap`.

## Step 1 — Capture the idea

The idea is in `$ARGUMENTS` or the developer's last message. Restate it in one plain sentence and confirm you've got it right — but do not stop the flow waiting; proceed to analysis and let the developer correct if needed:

> "Heard: **[feature in one line]**. Triaging against the brief and roadmap…"

## Step 2 — Read the anchors

Read in parallel:
- `project_brief.md` — **Goals**, **Non-goals**, **MVP**, **Roadmap**, **Tech decisions**. (If absent, note it — triage continues against the roadmap alone, and classification falls back to on-roadmap / not-on-roadmap.)
- `ROADMAP.md` — active milestone (🔄/🚧), unstarted milestones (⬜), and the backlog.
- Current manifest version (`.claude-plugin/plugin.json`, `package.json`, `pyproject.toml`, `Cargo.toml`).

## Step 3 — Classify

Place the idea in exactly one bucket, with the evidence:

- **On-brief** — it advances a stated **Goal** or is already implied by the MVP/Roadmap. It belongs; the only question is *when*.
- **Scope-creep** — plausibly useful and not forbidden, but it is **not** traceable to any Goal/MVP/Roadmap item. This is the dangerous middle: easy to wave through, and the usual source of drift. Flag it as such explicitly.
- **Out-of-scope** — it contradicts a declared **Non-goal**, or pulls the project toward something the brief deliberately excluded. Say so directly and cite the non-goal.

## Step 4 — Propose placement, version impact, and risk

Propose, don't impose:

- **Where it belongs:**
  - On-brief and fits the active milestone's theme → name that milestone.
  - On-brief but distinct → propose a **new milestone** with a one-line goal and a sequence position (and what it depends on / blocks).
  - Scope-creep → recommend the **backlog** by default, with a one-line "promote it if…" condition.
  - Out-of-scope → recommend **decline or override**, and state what overriding would cost.
- **Version impact** — per semver: new user-facing capability → **minor**; fix/polish → **patch**; breaking change → **major**. State `v[current] → v[target]` if it became its own milestone.
- **Risk hint** — one line seeded from what you can see cheaply: blast surface ("touches auth + the API layer"), dependency on unfinished work, or a `/g-patterns`-style recurrence if an obvious one applies. This is a hint, not a `/g-forecast` — name it as such.

## Step 5 — Present and ask (the gate)

Present the triage compactly:

```
━━━ Feature triage ━━━
Idea:     [one line]
Class:    [On-brief | Scope-creep | Out-of-scope]   — [evidence: goal/non-goal/roadmap item]
Fits:     [active milestone M# | new milestone proposal | backlog | decline]
Version:  [impact, e.g. "minor — v1.6.0 → v1.7.0 if its own milestone"]
Risk:     [one-line hint]
━━━━━━━━━━━━━━━━━━━━━━━
```

Then ask one question and **wait**:

> "What do you want to do?
> **(a)** add to the roadmap now (I'll open /g-roadmap to slot + sequence it),
> **(b)** drop it in the backlog for later,
> **(c)** start it now (I'll open /g-plan — only if it fits the active milestone),
> **(d)** decline it.
> — a / b / c / d"

Mid-milestone guard: if a wave is currently executing, say so and steer away from (c) — "A wave is running; (c) would inject scope mid-flight. I'd queue it instead." Never inject into an active wave.

## Step 6 — Act on the choice (only now do anything persist)

- **(a)** → invoke `/g-roadmap` (Glob `skills/g-roadmap/SKILL.md`), carrying this idea and the proposed placement/version as the starting context, so its phases confirm and write `ROADMAP.md`. g-roadmap owns the write.
- **(b)** → append one bullet to the `## Backlog` section of `ROADMAP.md` (the single low-risk write this skill makes directly), then confirm: `Backlogged: [idea].` If `ROADMAP.md` has no Backlog section, add one.
- **(c)** → invoke `/g-plan` (Glob `skills/g-plan/SKILL.md`) for the idea, but only after confirming it fits the active milestone. Its own challenge gate and approval still apply.
- **(d)** → record nothing in the roadmap. If the idea was a recorded override of a non-goal, note in the reply that declining stands. Confirm: `Declined — not added.`

## Rules
- **Triage proactively, write reactively.** Steps 1–5 run on a dropped feature without being asked; Step 6 persists nothing until the developer picks (a)–(d). The plugin's approve-before-write philosophy is the whole point.
- Single idea only. A full feature dump → defer to `/g-roadmap` and say so.
- Name the bucket honestly — especially **scope-creep**. The value of this skill is calling drift before it ships, not laundering every idea into the plan.
- Never inject a feature into an executing wave. Queue it.
- Version impact and risk are quick reads, not a full `/g-forecast` / `/g-blast-radius` — label them as hints. Offer to run the real thing if the idea is large.
- Auto-trigger condition (full tier only): the developer mentions a **single** new feature idea mid-stream (a "New capability" message per G-RULES §B). For an explicit multi-feature dump or "re-plan everything," go straight to `/g-roadmap`.
