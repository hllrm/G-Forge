# ADR-001: The Table rides a surface-agnostic adapter, Google Docs as the reference surface

**Date:** 2026-06-30
**Status:** Accepted
**Reversibility:** two-way door (reversible) — the adapter is an internal seam; swapping or adding a surface behind it touches one contract, not the skill.
**Context:** G-Forge M33 — The Table (shared-doc communication layer), Phase A (Solo Table).

## Context

M33 Phase A needs a live Doc surface that a Claude session binds to, reads at turn/wave boundaries, and writes salient deltas into — the "Table." The user's intended primary surface is **Google Docs** (connected via the official Google MCP). Two constraints shaped the decision:

1. **The Google MCP is not reachable in every session.** An MCP connected in the client app does not reach an already-running remote container (cloned fresh at session start); it is picked up by a *new* session. So Phase A code cannot assume a specific MCP is live, and must build/test without blocking on one.
2. **M29 already committed to surface-agnostic adapters** (Google / Confluence / Discord behind a common contract). The Table is "the same surface, two faces" as M29's register — it must not re-introduce a hard Google dependency that M29 deliberately avoided.

## Decision

The Table talks to its surface through a **single internal adapter contract**, never to an MCP directly. The contract is four operations:

| Op | Meaning |
|----|---------|
| `bind(ref)` | Attach the session to a Doc — `create-from-template` (new Doc from `g-docs/templates/table-template.md`) or `attach-by-URL` (existing Doc). Returns a stable handle. |
| `read_section(name)` | Read one living-state section (`Now/Lanes`, `Decided`, `Open Questions`, `Asks`) or the feed tail — **deltas/sections, never the whole Doc** (token-cost control). |
| `append_feed(entry)` | Append one timestamped line to the "what just happened" feed (append-only; concurrent-safe). |
| `write_living_state(name, body)` | Replace one living-state section's body (the only mutating write to structured state; section-scoped to bound the blast radius of a concurrent edit). |

**Google Docs is the reference adapter** — the contract is shaped to what the official Google Docs MCP can actually do (read a doc, patch a range/section, append). A **null adapter** (no Table configured) makes every op a no-op so the no-Table path is byte-identical to today. The spike validates the contract live against Google Docs once that MCP is reachable; until then the skill, templates, hook, and tests are built and unit-tested against the contract with the null adapter.

**Token policy:** any surface credential is read from an environment variable at run time and **never committed**. `/g-doctor` gains a check that the token is not in the repo and the bound Doc is not world-readable (the 🔴 data-leak risk). Default Doc visibility is **link-restricted, never public.**

## Alternatives considered

| Option | Why rejected |
|--------|-------------|
| **Bind directly to the Google Docs MCP** (no adapter) | Hard-couples Phase A to one MCP that isn't always live; blocks all build/test on env setup; contradicts M29's surface-agnostic doctrine; re-binds the whole arc to Google. |
| **Confluence as the spike surface** (the available Doc-like MCP) | The user explicitly wants Google ("just connected google stuff"). Confluence would prove the loop but against the wrong surface, risking a contract shaped to Confluence's quirks. Kept only as a *possible* second adapter, not the reference. |
| **Miro `doc_create` (design-tool doc) as the surface** | It's a board artifact, not a collaborative text Doc with section-addressable edits; wrong primitive for living-state + feed. |
| **Whole-Doc read/replace each turn** (no section ops) | Token cost scales with Doc size every boundary; concurrent-write clobber on the whole Doc. Section-scoped ops are the mitigation, so they belong in the contract. |
| **Design-only this pass, build later** | Most of Phase A (skill, templates, hook, docs, tests) needs no live MCP. Deferring all of it wastes the open budget; only T7's live validation actually blocks on the MCP. |

## Consequences

- **Easier:** build and unit-test all of Phase A now against the null adapter; add Confluence/Discord adapters later with zero skill changes; the Table and M29's register share one adapter layer.
- **Harder / constrained:** the contract must be the *intersection* of what real surfaces support — a Google-only capability can't leak into the skill. Section addressing must map onto each surface's edit model.
- **Follow-up decisions:** exact Google Docs MCP mapping for `write_living_state` (named-range vs heading-anchored patch) — resolved when the MCP is live, behind the contract. Whether the M29 register and the M33 Table share one bound handle or two.
- **Risks:** the live Google mapping turns out lossy (e.g. no stable section anchors) → handled behind the adapter without touching the skill; surfaced by the deferred live-validation task.

## Constraints that drove this decision

- The Google MCP's non-presence in running sessions (forces no-hard-dependency).
- M29's existing surface-agnostic adapter commitment (forces one shared seam).
- The 🔴 data-leak premortem (forces token-via-env + link-restricted default + a `/g-doctor` check).
- Read-cadence token cost (forces section/delta ops, not whole-Doc reads).

## Assumptions that held (with fragility)

- **The Google Docs MCP exposes section/range-addressable reads and edits.** *Fragile* — if it only offers whole-doc replace, `write_living_state` degrades to read-modify-write with a concurrency cost; the contract still holds, the adapter absorbs it.
- **Append-only feed + section ownership is enough concurrency control for Phase A (solo).** *Holds for solo*; shared mode (Phase B) leans on M29 lanes, out of scope here.
- **A new session will pick up the Google MCP.** *Fragile to environment* — if not, the spike validates against an alternate adapter; the decision still stands.
