---
name: g-resume
description: Re-hydrate a fresh session with the right slice of the durable record. The read-side counterpart to /g-retro — selectively retrieves the relevant retro, ADRs, journal, and handoff keyed by the current branch/milestone/first-task, and assembles a focused re-entry briefing. Loads distilled context into a clean window, not a poisoned transcript. Auto-nudged on the first prompt of a session when a handoff is pending.
context: [task, sprint, architectural]
---

**Announce:** "Using g-resume to re-hydrate context for this session."

This is the read side of the seam. `/g-retro` and the §A7 context gate **promote** the clean record *out* of a finishing session (retros, ADRs, journal, handoff). `/g-resume` **pulls the right slice back in** when a new session starts — so a fresh, clean window picks up the knowledge without inheriting the previous session's poisoned context. It is the counterpart that makes "start a fresh session" cheap: you lose the residue, not the memory.

Retrieval here is selective and honest — there is no vector store. It is deterministic candidate-gathering (grep/glob the durable record by the current task's keys) followed by relevance judgment (you decide which candidates actually matter), loading only **distilled sections**, never whole histories. The point is a clean window: pull what *this* task needs and nothing more.

## Step 1 — Establish the re-entry keys

Gather, in parallel:
- **Branch** — `git branch --show-current`. If it matches `feat/<slug>` / `fix/<slug>` / `refactor/<slug>` / `chore/<slug>`, extract `<slug>`.
- **Active milestone** — the milestone marked 🔄 / 🚧 in `ROADMAP.md` (name + scope).
- **Handoff** — the `## Active Session` block in `ROADMAP.md` (the "Next up" and "Active context" lines). Also read `.claude/compact-state.md` if it exists (the PreCompact snapshot) — it is the same block captured mid-session before a compaction.
- **First task** — the lead item of "Next up". Watch specifically for a `verify ADR-NNN` task (written by `/g-adr`'s decision-hygiene reset) — that is a first-class re-entry signal.
- **Recently touched files** — `git log --name-only -n 10 --pretty=format:` (unique basenames) — used to match decisions to the active work.

If neither `ROADMAP.md` nor `.claude/compact-state.md` exists, this isn't a G-Forge project mid-flight — say so in one line and stop: `Nothing to re-hydrate — no handoff or roadmap found.`

## Step 2 — Retrieve the relevant slice (selective)

Gather candidates deterministically, then judge relevance — load only what serves the first task.

1. **The first task's anchor.** If the handoff names `verify ADR-NNN` (or any specific ADR), load that ADR file from `g-docs/decisions/` — its **Decision**, **Consequences**, and **Assumptions That Held** sections. This is the task; it gets full weight. (Verifying it against ground truth is exactly why the previous session handed it over rather than trusting it from memory.)
2. **The carry-over retro.** In `g-docs/retros/`, find the most recent retro whose slug matches the branch `<slug>` or the active milestone; else the single most recent retro. Load only its **Cold-start context** and **Avoid / do differently** sections — not the whole file.
3. **Decisions touching this work.** `grep` `g-docs/decisions/` for the branch slug and the recently-touched file basenames. From the matches, load the **Decision** line of the top 1–3 most relevant ADRs (constraints the fresh session must not re-litigate). List the rest as pointers only.
4. **The alignment anchor.** `project_brief.md` — the **Goals** list and the active milestone's **Scope**. One-line each. This is what the work is *for*; it keeps the fresh session from drifting (same anchor `/g-align` uses).
5. **Recent activity.** The latest `.claude/journal/*.jsonl` (last ~15 events) and `git log --oneline -5` — the texture of what just happened.

Cap it: if a category has many matches, take the most relevant few and leave the rest as `(N more — see <dir>)` pointers. Re-hydration that dumps everything just re-poisons the window.

## Step 3 — Assemble the re-entry briefing

Present a single focused briefing — distilled, scannable, pointer-rich:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Re-entry — [branch] · [milestone or "—"]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
First task:    [lead "Next up" item — e.g. "Verify ADR-007 against the repo"]
Where we are:  [1–2 lines from handoff "Active context" + recent commits]

Decisions in force:
  · ADR-NNN — [Decision line]            [+ N more in g-docs/decisions/]
Carry-over (do differently):
  · [from the relevant retro's "Avoid / do differently", or "—"]
Anchored to:   [brief goal(s) the active milestone serves]
Recent:        [last commit + last few journal events, one line]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Optionally write the same briefing to `.claude/reentry.md` (overwrite) so it is available without re-running.

## Step 4 — Hand off to the first task

End by pointing at the first task — do not start it unprompted unless it is a pure verification:

- **If the first task is `verify ADR-NNN`:** offer to run it now — "First task is verifying ADR-NNN against the actual repo. Want me to check the decision still matches ground truth before we build on it? (y/n)". On yes, read the ADR's Decision/Consequences and confirm each against the current code/config/deps, reporting `holds` / `drifted — [what changed]` per claim. This is the clean-slate check the decision-hygiene loop exists to force.
- **Otherwise:** state the single next action and stop, the way `/g-help` does — e.g. "Resume Wave 2 with `/g-execute 2`," or "Run `/g-plan` for the next milestone scope."

## Rules
- Selective, not exhaustive. Load distilled sections (retro Cold-start, ADR Decision/Consequences) and pointers — never whole files or full histories. A clean window is the entire point.
- Read-only retrieval. `/g-resume` assembles context and may write `.claude/reentry.md`; it changes nothing else and triggers no other skill on its own.
- Relevance is judged, not dumped — gather candidates by keys (grep/glob), then keep only what serves the first task. When unsure, prefer the pointer over the paste.
- Never re-litigate a decision that an in-force ADR already settled — surface it as a constraint, not an open question. (Verifying an ADR named in the handoff is the one exception, and that is the task itself.)
- If the durable record is thin (no retros/ADRs yet), re-hydrate from the handoff + roadmap + journal alone and say so — degrade gracefully.
- Auto-trigger condition (full tier only): the **first prompt of a session** when a handoff is pending (`ROADMAP.md` `## Active Session` handoff or `.claude/compact-state.md` present) — `workflow-checkpoint.sh` surfaces the nudge.
