---
name: g-table
description: Bind the session to "the Table" — a shared live Doc that is the human-facing communication layer between you, non-programmers (PMs, collaborators), and the session. start binds a Doc (create-from-template or attach-by-URL); sync reads the Table at a boundary and writes only salient deltas; close distills the live Doc into the durable record (handoff + ADRs + action list) on a human nod. Works solo or shared. Off by default — when no Table is configured every path is a no-op and behaviour is byte-identical to today.
argument-hint: "start [doc-url] | sync | close"
---

**Announce:** "Using g-table to [start|sync|close] the Table."

The **Table** is a real-time, human-facing **communication surface** — a shared Doc that is the live UI between you, non-programmers, and the session. The state of play is visible; humans steer in plain language; live decisions and plans are shaped on the Doc, then **distilled into the durable record** the engine executes. This is M33 Phase A (Solo Table): prove the heartbeat — read the Table, write what counts, distill on close — with one person before any multiplayer.

> **Working memory, not truth.** The Table is the *live* surface. `g-docs/` (ROADMAP, ADRs, the `## Active Session` handoff) stays authoritative. The Table **writes through** to the record on a human nod — it is never a second source of truth. Nothing is "decided" until it is in the record.

## The surface adapter (per ADR-001)

The Table never talks to an MCP directly. It uses a four-operation **surface adapter** so the skill is identical across Google Docs/Drive, Confluence, or any future surface — and a **null adapter** (no Table configured) makes every op a no-op:

| Op | Meaning |
|----|---------|
| `bind(ref)` | Attach the session to a Doc — `create-from-template` or `attach-by-URL`. Records the handle in `.claude/table`. |
| `read_section(name)` | Read one living-state section or the feed tail — **sections/deltas, never the whole Doc** (token control). |
| `append_feed(entry)` | Append one timestamped line to the append-only feed. |
| `write_living_state(name, body)` | Replace one living-state section's body (the only structured-state write; section-scoped). |

**Bind record** — `.claude/table` (gitignored), the presence of which *is* the "Table configured" flag:

```
surface=<google-drive|confluence|...>
ref=<file-id or page-id or URL>
title=<doc title>
created=<YYYY-MM-DD>
```

**Surface resolution.** At `start`, resolve an available surface MCP via tool discovery (e.g. Google Drive `create_file`/`read_file_content`, Confluence `createConfluencePage`/`updateConfluencePage`). If none is reachable, say so in one line and stop — do **not** fabricate a Table. Token/credentials are read from the environment at run time and **never** written to `.claude/table` or committed.

## Step 0 — Resolve the subcommand

Parse the argument: `start` · `sync` · `close`. No argument → if `.claude/table` exists, default to `sync`; otherwise explain the three subcommands and stop.

**No-Table guard (all paths):** if the operation needs a bound Table and `.claude/table` is absent, the null adapter applies — print `No Table configured — nothing to do (behaviour unchanged).` and exit. Never block, never fabricate.

## Step 1 — `start` (bind + setup)

1. **Pick the bind mode:**
   - `start <url>` or `start <file-id>` → **attach-by-URL** to the existing Doc.
   - `start` with no ref → **create-from-template**: instantiate the Table from `templates/table/table-template.md` (read it from the plugin cache via Glob) into a new Doc on the resolved surface.
2. **Resolve the surface** (above). If none reachable, stop with the one-line message.
3. **Security gate (the 🔴 data-leak risk):**
   - The Doc must be **link-restricted, never public/world-readable.** On create, set restricted sharing; on attach, check the permission and **warn + refuse to proceed** if it is public (offer to continue only on explicit override, recorded).
   - Never write a credential onto the Table. Never commit the token.
4. **Write the bind record** to `.claude/table`.
5. **Confirm:** print the Table title + link (restricted) and the living-state section names. State the read cadence: *"I'll read the Table at turn/wave boundaries and write only what counts; run `/g-table close` to distill it into the record."*

## Step 2 — `sync` (the heartbeat: read what's there, write what counts)

This is what the `workflow-checkpoint` hook nudges at boundaries; it is also runnable on demand.

1. **Read** the living-state sections that changed and the feed tail via `read_section` — sections/deltas, **not** the whole Doc. Surface to the user: what a collaborator (or your past self) established, open questions, and any **Asks** addressed to this session.
2. **Write what counts** — the **salience gate.** Append to the feed (`append_feed`) or update a living-state section (`write_living_state`) **only** for things that change the state of play: a decision reached, a wave started/finished, a question answered, an ask raised. Routine tool calls, file reads, and chatter do **not** go on the Table. When unsure, don't write — the Doc swamps far faster than it starves.
3. **Tier-aware:** on the `light` tier the Table heartbeat is off (the hook does not nudge it). Honor that.

## Step 3 — `close` (distill into the durable record — the make-or-break)

`close` is the loop that justifies the whole feature: the live Table becomes the durable record. **Distillation quality is the whole game** — lossy drifts intent, noisy swamps the record — so a **human nod gates every write-through.**

1. **Read** the full living-state (all sections) + the session's feed since `start`/last close.
2. **Distill — propose, do not auto-commit:**
   - **Handoff** → rewrite the `## Active Session` block in `g-docs/ROADMAP.md` (delegate the actual write to `/g-retro` Step 5b / the §I format — don't re-implement it here). Done this pass / Next up / Active context, drawn from the Table.
   - **Decisions** → for each decision that hardened on the Table, propose an ADR via `/g-adr` (it triages ADR vs brief-row vs nothing — keep the corpus high-signal). Never mint an ADR without the triage.
   - **Action points** → extract open Asks and Next-up items into `g-docs/todo.md` tasks.
3. **Human nod required.** Present the proposed handoff + ADR candidates + action list and wait for explicit approval. On approval, write through (handoff, ADRs, todo). On "not yet," leave the record untouched — the Table keeps the live state for next time.
4. **Groom (light):** once distilled, mark resolved items on the Table as archived (move them out of living-state into the feed or a "Resolved" area) so living-state stays small. Full grooming is Phase C; keep this minimal.
5. **Do not unbind by default.** `close` distills; the Table stays bound for the next session. (A future `/g-table end` can unbind — out of Phase A scope.)

## Rules

- **Off by default.** No `.claude/table` ⇒ every path is a no-op and behaviour is byte-identical to today. The Table is opt-in, triggerable, never autonomous.
- **Working memory, not truth.** Repo = truth, Table = live surface. Nothing is decided until it is in the record (handoff/ADR/todo) on a human nod.
- **Salience gate on writes.** Only state-of-play changes reach the Table. When unsure, don't write.
- **Sections/deltas, never whole-Doc.** Read and write section-scoped (token cost + concurrency).
- **Security is non-negotiable.** Link-restricted, never public. No credentials on the Table. Token via env, never committed. `/g-doctor` enforces both.
- **Distill on a human nod, every time.** `close` proposes; the human approves; only then does the record change.
- **Surface-agnostic.** Talk to the adapter, never an MCP directly (ADR-001). A new surface is a new adapter, not a skill change.
