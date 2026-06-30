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

## Addendum — live dogfood findings (2026-06-30)

First live bind run against the Google MCP that became reachable mid-build. Results, op by op:

| Adapter op | MCP tool | Result |
|---|---|---|
| `bind` (create-from-template) | `Google_Drive.create_file` (→ `application/vnd.google-apps.document`) | ✅ Real Doc created (`id 16FBXCWuKF5…`, restricted view URL returned). |
| `read_section` | `Google_Drive.read_file_content` | ✅ Content round-trips; Drive renders the Doc to text (markdown markers escaped, all sections + feed intact). |
| security gate | `Google_Drive.get_file_permissions` | ✅ Owner-only permission, no `anyone` entry — the link-restricted-never-public invariant holds on a real file. |
| `append_feed` / `write_living_state` | — | ❌ **No tool.** The Drive MCP is **create + read only** (`create_file·read_file_content·copy_file·search·get_metadata·get_permissions`); it exposes **no in-place content update.** |

**This is the flagged "section-addressable edits" assumption, resolved with data — and worse than feared:** the gap isn't *section* granularity, it's that the Drive MCP can't update Doc content *at all*. **Resolution (does not change the 4-op contract — constrains which MCP backs the Google adapter):**

- **For write-back, the Google adapter needs the Google *Docs* API** (`documents.batchUpdate` — insert/replace by range), not the Drive API. When a Docs-API MCP is connected, `write_living_state`/`append_feed` map onto `batchUpdate`; the contract is unchanged.
- **Drive-MCP-only is a valid *read-mostly* Table:** the session **reads** state and **humans write** (type into the Doc). That already supports the human-steers-in-plain-language flow; only the session's own salient-delta writes are blocked.
- **Rejected:** read-modify-recreate via `create_file` (a new file each write breaks the stable handle/URL and drops comments) — not acceptable for a bind handle.

**Status of the live `bind` from this run:** Doc retained; bound locally via `.claude/table` (gitignored). The heartbeat fires correctly in a managed project (verified). The session-writes-the-feed half of the solo loop waits on a Docs-API MCP.

### Surface capability tiers (the design model the dogfood produced)

The write gap isn't Drive-specific — it generalizes. Surfaces fall into **capability tiers**, and the same 4-op contract **degrades by tier** rather than requiring per-surface skills:

| Tier | Surfaces | `write_living_state` | `append_feed` | Table shape |
|---|---|---|---|---|
| **1 — structured, in-place** | Confluence (✅ **in-place write validated live** — page v1→v2 via `get`→splice→`updateConfluencePage`: feed append + section replace both landed), Google **Docs** API (`batchUpdate`) | native in-place section edit | native | **Full Table** — living-state sections + feed; session reads *and* writes. *Best case.* |
| **2 — append-only exchange** | Email/Gmail (✅ **validated live** — label `g-table/G-Forge` created (`bind`), STATE seed `create_draft` written + read back via `list_drafts`; **MCP cannot send → the human sends = the native nod**), Discord | **latest-wins snapshot** — post a fresh "state" message; newest is canonical (can't edit a sent message) | a message/post = a feed entry (native) | **Feed-native Table** — the thread *is* the feed; living-state reconstructed from the latest state-message. **Universal floor** — zero-setup, everyone has it; where non-programmers already are. |
| **3 — read-only** | Google **Drive** MCP (as connected) | ❌ none | ❌ none | **Not viable** as a Table surface. |

**Consequence for the adapter:** `bind`/`read_section`/`append_feed` are universal; only `write_living_state` varies, and its Tier-2 form (post-a-snapshot, latest-wins) is a clean degradation, not a special case. The skill is unchanged across tiers — exactly what ADR-001's surface-agnostic decision bought. **Confluence is the best-case proof; email is the floor that makes the Table reach the whole audience.**
