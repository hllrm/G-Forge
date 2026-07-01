# ADR-002: The Roundtable has one human orchestrator seat (the PM role), rotatable by handoff

**Date:** 2026-06-30
**Status:** Accepted
**Reversibility:** one-way door (hard to reverse) — M34's suggestion-routing, the "who owns `main`" answer, and the shared-roadmap write model all build on a single authority. Removing it later means reworking the coordination model.
**Context:** G-Forge M33 (the Roundtable) + M34 (cross-session orchestration) — the multiplayer cooperation model.

## Context

A shared Roundtable with N equal seats and no designated authority **degenerates**, predictably:
- **No tie-breaker** — two people disagree on the Roundtable and nothing converges (design-by-committee stall).
- **No integration owner** — "who owns `main`?" is unanswered; this is exactly M32's hardest open question and M34's Phase-D risk.
- **Roadmap forks** — two sessions distill contradictory decisions into the record and the single source of truth splits.

A flat Roundtable therefore fails. But G-Forge's spine is **human empowerment, no machine authority** ("the human is the most valuable part of the loop"; no autonomous AI-dispatches-AI; no hosted authority — M29/M33 non-goals). So the hierarchy the Roundtable needs must be **human** hierarchy, not a machine master.

## Decision

**Every Roundtable has exactly one orchestrator seat, and it is a human role — the PM role from G-RULES §B.** The machine (sessions) surfaces state and *suggests*; the seat *decides*. Specifically the seat owns:

- **Roadmap writes** — the shared plan. Everyone else *proposes* changes via Asks.
- **Tie-breaks / final decision authority** on Roundtable decisions.
- **`main` + integration order** — this is the concrete answer to "who owns `main`" (M32/M34).
- **The final nod** on `/g-roundtable close` distillation into the durable record.
- M34's **pull/push/coordinate suggestions route to the seat** for anything touching shared state.

The seat is **a role, not a fixed person**, and **rotates via the M33 Phase-B person→person handoff** (passing the gavel). Solo, the sole user is trivially the chair. Shared, **exactly one** seat is orchestrator at any instant.

**Never co-chairs.** No splitting the seat by area (frontend-owner + backend-owner). Co-chairs reintroduce the exact failure the seat exists to prevent: a cross-area tie has no breaker, and "who owns `main`" becomes ambiguous again. One gavel, held by one person, handed off atomically.

## Alternatives considered

| Option | Why rejected |
|--------|-------------|
| **Flat / leaderless** (consensus by convention) | The failure mode above — no tie-break, no integration owner, forking roadmap. The user's own read: "Roundtable without hierarchy likely fails." |
| **A machine/session as orchestrator** | Violates the empowerment spine — AI becomes the master, "swapping humans for gbrains." Sessions may *act as the seat's instrument* (surface, draft integration order) but never hold the authority. |
| **Co-chairs by area** (frontend seat + backend seat) | More flexible, but a cross-area tie has no breaker and `main` ownership goes ambiguous. Explicitly rejected by the user: "never co-chairs." |
| **Fixed permanent chair** (no rotation) | Brittle — the lead goes offline and the Roundtable stalls. The handoff (M33 Phase B) makes the seat a rotatable role, keeping flexibility without flatness. |

## Consequences

- **Easier:** "who owns `main`" is answered (the seat); reconciliation (M32/M34-D) routes to one authority; roadmap writes have a single owner so the record can't fork; M34's suggestions have a clear addressee.
- **Harder / constrained:** the seat is a single point of coordination — if the holder is absent, work needing a decision waits until the gavel is handed off. Mitigated by cheap, explicit handoff.
- **Follow-up:** the handoff protocol (M33 Phase B) must transfer the seat **atomically** (no window with zero or two chairs); handoff itself is a Roundtable-claimed resource (M29) to avoid a race.
- **Risks:** a stale seat (holder vanished without handoff) blocks decisions → the seat, like any M29 claim, decays with its lease; on expiry the Roundtable flags "no orchestrator — claim the seat."

## Constraints that drove this decision

- The empowerment spine — no machine authority (human holds the gavel).
- The concrete "who owns `main`" gap left open by M32/M34.
- The user's explicit calls: hierarchy is required; the chair is singular; never co-chairs.

## Assumptions that held (with fragility)

- **One decider is enough** for a single project's Roundtable. *Holds* for one repo/Roundtable; a program spanning many repos would run many Tables, each with its own seat — not co-chairs on one Roundtable.
- **Handoff is cheap and frequent enough** that a single seat isn't a bottleneck. *Fragile if* handoff is heavyweight — keep it a one-line gavel-pass on the Roundtable.
- **The seat maps cleanly onto the §B PM role.** *Holds* — the PM interface rule already makes one human the project's decision authority; the Roundtable just makes the seat explicit and shared.
