# Multi-session coordination — the "live shared surface" idea

> Status: **idea / exploration only** — not scoped, not scheduled. Elaborates the
> ROADMAP backlog candidate "Multi-session / multi-operator orchestration."
> Captured from a brainstorm so it doesn't evaporate. No decision made.

## The problem

G-Forge already does **sequential**, git-mediated multi-session handoff well: the
`## Active Session` block in `g-docs/ROADMAP.md` + `/g-resume` + the observer
journal are the primitives — one session ends, writes the handoff, the next picks
it up. The gap is **concurrent** sessions: two live at once, neither aware of the
other. Observed twice — sessions on different machines silently claimed the same
milestone number / branch / handoff block and had to be untangled by hand.

## The insight

Git is the wrong tool for *coordination* because it only propagates on push+fetch —
there's always a window where two sessions both believe a milestone is unclaimed.
What we want is a surface that is:

- **always available** — writable from inside any session,
- **instantly visible** — a change is seen by every other session immediately, with
  no commit / push / merge,
- and ideally **atomic** — two sessions can't both "win" the same claim.

The realization: **Claude already has MCP tools for exactly such surfaces.** We don't
need to build coordination infrastructure — we need to pick a shared mutable surface
that has an MCP and write a thin convention on top of it.

## The portable pattern (surface-agnostic)

Whatever surface you choose, the shape is the same:

- **A mutable field = the live register.** "Who is working on what right now."
  Edited in place; reading it tells any session the current claims.
- **An append-only log = the history.** Every claim / release / handoff is an
  immutable event. Gives an audit trail and a cold-start record.
- **A claim convention = the protocol.** Before starting a milestone/branch/file-set,
  a session reads the register, and if the target is free, writes a claim (with its
  identity + a timestamp). `/g-roadmap` and `/g-plan` consult the register before
  assigning a number.

The surface is **interchangeable**. The pattern is the asset.

## The surface ladder (cheapest → most control)

| Rung | Surface | Mutable field | Log | Atomic claim? | Infra |
|------|---------|---------------|-----|---------------|-------|
| 1 | **GitHub issue body / pinned comment / Projects v2 field** (github MCP) | yes | comments / events | no | none — already wired in |
| 2 | **Shared doc** — Google Doc / Drive (Drive MCP) | yes | revision history (+ attribution) | no (revisions only) | a shared doc |
| 3 | **Confluence page** (Atlassian MCP) | yes | page history | **yes — version CAS** | a Confluence space |
| 4 | **Shared mailbox** — Gmail drafts (field) + emails-to-self (log) | yes (draft) | thread | no | one shared account |
| 5 | **Purpose-built scratchpad site with an MCP** | yes | yes | by design | a hosted service |
| 6 | **Your own tiny presence/lock server** (sessions mint a token w/ random password) | yes | yes | **yes** | run a server |
| 7 | **Peer-to-peer register over a VPN mesh** (WireGuard / Tailscale) | yes | gossiped | needs consensus | per-machine setup; peers must be online together |

## The two axes the brainstorm uncovered

1. **Central arbiter vs. distributed register.** Rungs 1–6 are centralized — one
   source of truth everyone polls; easy to answer "who won." Rung 7 is peer-to-peer —
   no host, most private/self-contained, but reintroduces **consensus** (tiebreak
   rule needed) and requires peers to be **online together** (presence becomes a
   precondition, not a feature).
2. **Convention vs. real mutual exclusion.** Most surfaces give "everyone sees
   everyone instantly" but *not* a hard lock — two simultaneous claims can both land,
   and you need a tiebreak. The exception worth noting:

   **Compare-and-swap is the free lock.** Any surface that requires the *current
   version / etag* on write gives optimistic concurrency = a genuine atomic claim.
   Confluence's update call requires the page version, so two sessions bumping
   v7→v8 will have exactly one succeed and the other bounce (and re-read). That is a
   real lock with zero code. The general rule: **prefer a surface whose MCP supports
   conditional/versioned writes** — that, not the specific vendor, is the property
   that matters.

## Open question (the actual decision, deferred)

Do we need genuine mutual exclusion, or is **"everyone can see everyone instantly,
coordinate by convention"** enough? The cheapest rungs answer "convention is enough";
only build toward a hard lock if convention demonstrably fails in practice. A
shared-log prototype on rung 1 or 2 is the way to *find out* before building anything.

## Design constraints to honor when this is scoped

- **Tool-agnostic.** Confluence gives the cleanest atomic claim, but it's a specific
  product many teams won't adopt. The mechanism must let a project choose its own
  surface — selection criterion: *a shared surface with an MCP, ideally one that
  supports conditional/versioned writes; otherwise accept convention-only.* No single
  vendor may be a hard dependency.
- **Degrade gracefully.** With no coordination surface configured, G-Forge must fall
  back to today's sequential git-mediated handoff — unchanged.
- **Stay in the governance lane (per M24).** This is collision *avoidance* and shared
  *visibility* — a rule with teeth — not a session-to-session dispatch/orchestration
  engine. Resist growing a second personality.
