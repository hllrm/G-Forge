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
surface=<confluence|gmail|google-docs>
ref=<page-id | thread-id-or-label | doc-id>      # the surface handle
title=<table title>
created=<YYYY-MM-DD>
watermark=<last-seen marker>                       # page version | message id/epoch (sync delta cursor)
# surface-specific (only what that surface needs):
cloudId=<atlassian cloud id>                       # confluence
spaceId=<confluence space id>                      # confluence
label=<gmail label id>                             # gmail
```

Never store a credential here — tokens come from the environment at run time. `/g-doctor` Check 21 enforces this.

**Surface resolution.** At `start`, resolve an available surface MCP by capability tier (ADR-001), best-first, via tool discovery:
1. **Confluence** (Tier 1, structured/in-place) — `getAccessibleAtlassianResources` succeeds → use the Confluence adapter.
2. **Google Docs API** (Tier 1) — a `documents.batchUpdate`-capable MCP is present → use it (reference adapter; not always connected).
3. **Gmail** (Tier 2, append-only floor) — `search_threads` succeeds → use the mailbox adapter.
4. **Google Drive only** → **refuse**: it is create+read-only (Tier 3), not a viable Table surface. Say so and stop.

If none is reachable, say so in one line and stop — do **not** fabricate a Table.

## Adapter implementations (per surface)

Each adapter maps the four ops to concrete MCP calls. The skill body (Steps 1–3) is surface-agnostic; it dispatches to the bound surface's row here. Discover exact tool schemas with ToolSearch when invoking.

### Confluence adapter (Tier 1 — full Table)
- **bind** — `getAccessibleAtlassianResources` → `cloudId`; `getConfluenceSpaces` → pick the space (`spaceId`); `createConfluencePage` (html body from `templates/table/table-template.md`) → record `ref`=pageId, `cloudId`, `spaceId`, `watermark`=version.number. Attach-by-URL: parse the page id, `getConfluencePage` instead of create.
- **read_section** — `getConfluencePage(contentFormat:html)`; slice the target `<h3>` section or the feed list from the returned HTML. Cheap because one page = the whole Table.
- **append_feed** / **write_living_state** — **read-modify-write in place:** `getConfluencePage` → splice the new feed `<li>` (or replace the section body) in the HTML → `updateConfluencePage(body, versionMessage)`; update `watermark`=new version.number. This is the op Drive could not do; Confluence does it natively.

### Gmail adapter (Tier 2 — feed-native floor)
- **bind** — `list_labels`→ find/`create_label` `g-table/<repo>`; the labeled thread is the Table. Solo = your own mailbox; shared = a Group/list address (never a shared login). Record `ref`=thread-id-or-label, `label`, `watermark`=latest message id.
- **read_section** (the sync scan) — `search_threads(query: "label:<id> newer_than:…", pageSize 5–10)` bounded by the `watermark`; `get_thread` for new messages only. **Classify each:** human `From:` → **Ask**; known session/agent `From:` or lane label → **multistream/M29 coordination**; `no-reply@`/system → **ignore**. Advance `watermark`.
- **append_feed** — `create_draft` a reply into the thread (a message = a feed entry). **The Gmail MCP cannot send — the human sends.** Draft-and-nod is the salience gate + human nod, native to the medium.
- **write_living_state** — no in-place edit (can't edit sent mail): `create_draft` a fresh `STATE:` message — **latest-wins**, the newest `STATE:` is canonical living-state. Lanes/status ride Gmail **labels** (`label_thread`).

## Step 0 — Resolve the subcommand

Parse the argument: `start` · `sync` · `close`. No argument → if `.claude/table` exists, default to `sync`; otherwise explain the three subcommands and stop.

**No-Table guard (all paths):** if the operation needs a bound Table and `.claude/table` is absent, the null adapter applies — print `No Table configured — nothing to do (behaviour unchanged).` and exit. Never block, never fabricate.

## Step 1 — `start` (bind + setup)

1. **Resolve the surface** (above) → pick the adapter. If none reachable (or Drive-only), stop with the one-line message.
2. **Pick the bind mode** and call the adapter's **`bind`** op (see the surface's row in *Adapter implementations*):
   - `start <url-or-id>` → **attach** to the existing page/thread.
   - `start` with no ref → **create-from-template**: `templates/table/table-template.md` (read from the plugin cache via Glob), instantiated on the surface.
3. **Security gate (the 🔴 data-leak risk):** the Table must be **permissioned, never public/world-readable.** On create, use a restricted space/personal mailbox; on attach, check the permission and **warn + refuse** if public (continue only on explicit, recorded override). Never write a credential onto the Table or into the bind record.
4. **Write the bind record** to `.claude/table` (surface, ref, title, `watermark`, and any surface-specific handle fields the adapter returned).
5. **Confirm:** print the Table title + link and the living-state section names. State the read cadence: *"I'll read the Table at turn/wave boundaries and write only what counts; run `/g-table close` to distill it into the record."*

## Step 2 — `sync` (the heartbeat: read what's there, write what counts)

This is what the `workflow-checkpoint` hook nudges at boundaries; it is also runnable on demand.

1. **Read since the watermark** via the adapter's `read_section` — only what arrived since the `watermark` in `.claude/table` (last-N as first-sync fallback), **not** the whole surface. On the mailbox surface, **classify** each new item (Gmail adapter row): human `From:` → **Ask**; known session/lane label → **multistream/M29 coordination**; system `no-reply@` → **ignore**. Surface to the user what a collaborator (or your past self) established, open questions, and any Asks. Then **advance the watermark**.
2. **Write what counts** — the **salience gate.** `append_feed` / `write_living_state` (per the adapter) **only** for state-of-play changes: a decision reached, a wave started/finished, a question answered, an ask raised. Routine tool calls and chatter do **not** go on the Table. When unsure, don't write — it swamps far faster than it starves. (Tier-2/mailbox: the write is a *draft* the human sends — the nod is native.)
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
