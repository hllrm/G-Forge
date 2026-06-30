# M33 — The Table (shared-doc interface: the human-facing communication layer)

**Status:** ⬜ Not started (scoped, awaiting go)
**Version:** ships its own minor when built
**Depends on:** **M29** (claim/lease register) for lanes/presence in shared mode. Degrades cleanly to today's solo, git-mediated flow when no Table is configured.
**Design note:** the multiplayer north star and surface ladder live in `g-docs/multi-session-coordination.md`. M29 is the *coordination substrate* (machine↔machine collision-avoidance); the provisional **M30–M32** arc (membership · handoff · reconciliation) is the *mechanics*. **M33 is the cooperation arc's communication *interface*** — the **harmonious cooperation layer**: the shared, human-facing surface that M30–M32 render on, where humans and their Claude sessions see the state of play, steer in plain language, and reach agreement before it hardens into the record. Because Phase A is valuable **solo** (no M29 needed), the Table can ship ahead of the rest of the arc, and it is the concrete shape the provisional M30–M32 sketch firms up into once M29 lands.

## Goal
Give G-Forge a real-time, human-facing **communication surface** — a shared Google Doc ("the Table") that is the live UI between developers, *non-programmers*, and their Claude sessions. The state of play is visible; humans steer in plain language; plans and decisions are shaped live, then **distilled into the durable record + action points** the existing engine executes. Triggerable; works **solo** (your own live surface) or **shared** (the multiplayer table).

## Position — M29's register and M33's Table are one surface, two faces
M29 uses a Google/Drive surface as a **register/log** (structured claim records: who holds what). M33 uses a Google **Doc** as the **Table** (where people and Claudes actually talk, plan, and decide). Same vendor surface, same MCP, two faces. The register keeps work *safe* (no collisions); the Table makes work *legible and shared*.

## Non-goals (inherits M29's, adds)
- **Working memory, not truth.** The Doc is the *live* surface; `g-docs/` (ROADMAP, ADRs, the `## Active Session` handoff) stays authoritative. The Table **writes through** to the record on a human nod — it is never a second source of truth.
- **Not always-on, not autonomous.** Triggerable, off by default. Humans orchestrate; the Table surfaces, records, and distills — it never dispatches a person or a session.
- **Surface-borrowed.** Rides a Doc the team already has, via a remote MCP. Ships no service.

## The shape
- **The Table** = a structured Doc: *living-state* up top (**Now/Lanes · Decided · Open questions · Asks**) + an append-only **"what just happened"** feed at the bottom.
- **Heartbeat:** sessions read the Table at turn/wave boundaries (via `workflow-checkpoint`), write only *what counts* (salience gate); a **human nod** distills live decisions → ADRs/ROADMAP and live plans → action points. *Distillation quality is the make-or-break — see premortem.*
- **Solo vs shared:** solo = your own live surface (and your future self's); shared = lanes/presence from the M29 register stop two sessions touching the same area.

## Scope / tasks

### Phase A — Solo Table (prove the heartbeat with one person)
- [ ] **A1 — Trigger + setup.** `/g-table start|sync|close`; bind a session to a Doc (create-from-template or attach-by-URL) via the Google Docs MCP; token by env-var expansion, **never committed**.
- [ ] **A2 — Templates.** A committed starter Doc template (living-state sections + feed) under `g-docs/templates/`; plus the **session-rules** and **end-of-session-summary** templates.
- [ ] **A3 — Session rules.** Read-the-Table at turn/wave boundaries; write-what-counts salience gate — codified as the `/g-table` skill + the `workflow-checkpoint` hook.
- [ ] **A4 — End-of-session distill.** `/g-table close` → distill the live Doc into the `## Active Session` handoff + ADRs + an action list, **human nod required.** This is the loop; prove it solo before any multiplayer.

### Phase B — Shared Table (two+ human+AI pairs)
- [ ] **B1 — Join.** A collaborator binds their session to the same Doc (**link-restricted**, permissioned — not public).
- [ ] **B2 — Lanes / presence** via the M29 register: who owns what, live, so two sessions don't collide on the same area.
- [ ] **B3 — Cross-person catch-up.** A session re-hydrates *"what your collaborator established since you last synced"* — cross-person `/g-resume`.
- [ ] **B4 — Person→person handoff/asks** on the Table (the `## Active Session` block generalizing session→session to person→person; ties into the cooperation arc).

### Phase C — Maintenance, setup, hardening
- [ ] **C1 — Maintenance / grooming.** A "groom the Table" routine: archive resolved items off the live Doc into the record; keep living-state small; prevent the swamp.
- [ ] **C2 — Setup + health.** `/g-init` opt-in ("set up a Table? none|solo|shared"); `/g-doctor` advisory check (Doc reachable, template present, **not world-readable**, token not committed).
- [ ] **C3 — Templates per context** (game / app / PM-coordination).
- [ ] **C4 — Degradation + docs.** No Table configured → behavior byte-identical to today (git-mediated handoff). Doc unreachable → warn + fall back, **never block work.** Update `g-rules-I` + README.

### Phase D — Propagation (make the surface lane/Table-aware) — *part of "done," not optional*
A cross-cutting primitive (lanes, the Table) is not done as an isolated component. Every skill/hook/rule that *assigns, plans, executes, reviews, resumes, or reports* must respect it, or the feature is an island. Enumerate with `/g-blast-radius`; the architecture gate verifies completeness. Touchpoints:

| Surface | Becomes lane/Table-aware — how |
|---|---|
| `/g-roadmap` | read lanes before assigning a milestone #; surface the plan/decisions on the Table |
| `/g-plan` | check lanes for the file-set before a wave; claim it; post action points to the Table |
| `/g-execute` · `/g-afk` | claim the wave's lane, heartbeat, post progress/done, release on complete |
| `/g-review` · `/g-doc-review` | cross-person review of another's lane; post MERGE READY/HOLD; release on merge |
| `/g-resume` | read the Table + collaborator deltas (cross-person catch-up) |
| `/g-retro` | distill the Table → record; release lanes at close |
| `/g-adr` | decisions surface on the Table, then promote to the ADR record |
| `/g-status` · `/g-help` | show current lanes + Table state/link |
| `workflow-checkpoint` · `session-start` · `pre-compact` | surface others' lanes, heartbeat own claim, snapshot the Table pointer |
| `/g-init` · `/g-doctor` · `/g-update` | setup, health checks, keep template + config in sync |
| `g-rules-A / -B / -I` | "read the Table," "claim before work," Table-as-record-fabric |

## Done condition
- **Solo:** `/g-table start` binds a structured Doc; the session reads it each boundary and writes only salient deltas; `/g-table close` distills to handoff + ADRs + action list on a human nod. With **no** Table configured, behavior is byte-identical to today.
- **Shared:** two people on one Doc see each other's lanes (via the M29 register), catch up on deltas, and hand off person→person without colliding — and the Doc is never the source of truth.
- A **non-programmer** can read the Table and steer by typing into it.
- **Propagation complete:** every touchpoint in the Phase-D matrix is wired, and the architecture-review gate confirms none was missed. *A Table that works in isolation but that `/g-roadmap`, `/g-plan`, and the hooks don't respect is **not done.***

## Premortem (per `/g-roadmap` Step 3b)
- **Distillation quality is the whole game.** Lossy ⇒ intent drifts; noisy ⇒ the Doc swamps. *Mitigate:* human nod gates every distill; salience filter on writes; the C1 grooming step; keep living-state small.
- **🔴 "Public" doc = data leak.** A *public* Google Doc is world-readable — project intent/decisions/secrets exposed. *Mitigate:* default **link-restricted, not public**; never put credentials on the Table; `/g-doctor` flags world-readable; document the policy.
- **Read-cadence token cost.** Reading the Doc every turn burns tokens. *Mitigate:* read deltas/sections, not the whole Doc; on boundaries only; tier-gated (off on `light`).
- **Two sources of truth.** *Mitigate:* Doc = working memory, repo = truth; nothing is "decided" until it's in the record.
- **Concurrent-write clobber.** *Mitigate:* Google Docs' native concurrent-edit merge + append-only feed + section ownership via M29 lanes.
- **MCP availability divergence.** Same as M29 — remote MCP requirement + `/g-doctor` reachability check.
- **Scope creep into autonomous orchestration.** *Mitigate:* the non-goals — the Table surfaces and records; humans orchestrate.
- **Propagation forgotten** (the island risk). *Mitigate:* Phase D + the §B cross-cutting propagation rule + the gate completeness check.

## Sequencing
**Phase A ships as a standalone spike** — valuable solo, and it proves the make-or-break (the distill loop). **Phase B depends on M29's register** being available for lanes. **Phase D runs alongside B/C** (you propagate as you add the shared behavior), and gates "done." Dogfood on this repo.
