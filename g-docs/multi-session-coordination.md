# Multi-session coordination — the "live shared surface" idea

> Status: **idea / exploration only** — not scoped, not scheduled. Elaborates the
> ROADMAP backlog candidate "Multi-session / multi-operator orchestration."
> Captured from a brainstorm. **Direction chosen:** ship three deliberately-spread
> surfaces — **Google (Gmail/Drive) · Confluence**, plus optional Discord — behind a
> common adapter, leading on official MCPs, extensible over
> time. The mechanism (claim protocol, schema) is not yet scoped.

## North star — multiplayer G-Forge (the real goal)

The ceiling here is **not** "stop two sessions colliding" — that's the floor. The goal
is **full cooperation on one project by multiple people**, each running their own
G-Forge + Claude, coordinating through a shared fabric. Call it **human orchestration,
powered by humans**: the people (and their AIs) do the orchestrating — deciding who
takes what, handing work off, reviewing each other — and G-Forge is the connective
tissue that makes it *shared, visible, and safe*. G-Forge does not become an AI boss
dispatching sessions; it becomes the **multiplayer layer a human team plays on**. This
is the M24 governance positioning scaled from one developer to a team — not a new
personality.

What the goal needs, beyond the claim/lease substrate:
- **Shared project state** — one roadmap / backlog / handoff every member reads and writes.
- **Assignment by person** — milestones / waves / tasks owned by *people*, not just claimed by a session. Who's on what.
- **Presence & visibility** — who's active, what they're touching, right now.
- **Cross-person handoff** — the `## Active Session` handoff generalizes from session→session to **person→person**; you can pick up a teammate's thread.
- **Cross-person review/gates** — the commit / doc gate can require a *teammate's* approval; review crosses people, not just sessions.
- **Reconciliation** — concurrent branches / waves from different people reconcile, with conflicts **surfaced** (never auto-merged behind anyone's back).

**The line that keeps it in the governance lane:** humans stay the orchestrators.
G-Forge proposes, enforces, and records — it never silently assigns work to a person,
never auto-dispatches another AI session without a human in the loop, and never runs
as an always-on hosted authority. That single boundary — *no autonomous
AI-orchestrating-AI* — is the only permanent non-goal.

The claim/lease primitive (**M29**) is **phase one**: the atomic substrate every
cooperation feature above is built on. Collision-avoidance first, because nothing else
is safe without it; the cooperation layer rides on top, as a milestone arc beyond M29.

## A whole framework, engaged on concurrency

G-Forge stays **single-player by default** — solo work is unchanged, zero overhead. The
moment **more than one session or user** is live on a project, a **multiplayer
framework** engages: shared register/log, presence, claims, cross-person handoff and
review, reconciliation. Concurrency is *detected* (an active claim or presence
heartbeat from another identity), and the cooperation rules switch on automatically —
the same way the integration tiers already gate behavior. It is not a separate
product; it is a **mode** of the same governance layer that activates exactly when it's
needed and gets out of the way when you're alone.

So the framework owns a coherent surface, not a pile of features:
- **Membership & identity** — who is on this project, each with a stable identity.
- **A shared source of truth** — the register / roadmap / handoff all members share.
- **A coordination protocol** — claim · release · heartbeat · assign · hand-off · request-review, recorded as an append-only log.
- **Activation rules** — when it turns on (concurrency detected), how it behaves per integration tier, and how it degrades back to single-player when everyone else leaves.

## The problem

G-Forge already does **sequential**, git-mediated multi-session handoff well: the
`## Active Session` block in `g-docs/ROADMAP.md` + `/g-resume` + the observer
journal are the primitives — one session ends, writes the handoff, the next picks
it up. The gap is **concurrent** sessions: two live at once, neither aware of the
other. Observed twice — sessions on different machines silently claimed the same
milestone number / branch / handoff block and had to be untangled by hand.

## The insight

Git is the wrong tool for *coordination* for **two independent reasons**:

1. **Propagation** — git only propagates on push+fetch, so there's always a window where
   two sessions both believe a milestone is unclaimed.
2. **Exposure** — a register committed to git is in the repo's *history*: public on a
   public repo, permanent, and replicated to every clone. That leaks who's working on
   what, member identity and presence, and (if anyone is careless) tokens. Live
   coordination state is exactly the kind of sensitive, ephemeral data that must never
   be written into version control.

What we want, then, is a surface that is:

- **always available** — writable from inside any session,
- **instantly visible** — a change is seen by every other session immediately, with
  no commit / push / merge,
- **off the repo** — the live state (and the secrets to reach it) live on the surface,
  never in git history; only a committed `.mcp.json` *pointer* sits in the repo, with
  credentials supplied via env-var, never committed,
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
| 2 | **Real-time chat bus** — Slack / Discord (bot / webhook / `@claude` app or MCP) | pinned message | channel scrollback | no | free workspace/server + a bot or app |
| 3 | **Shared doc** — Google Doc / Drive (Drive MCP) | yes | revision history (+ attribution) | no (revisions only) | a shared doc |
| 4 | **Confluence page** (Atlassian MCP) | yes | page history | **yes — version CAS** | a Confluence space |
| 5 | **Shared mailbox** — Gmail drafts (field) + emails-to-self (log) | yes (draft) | thread | no | one shared account |
| 6 | **Purpose-built scratchpad site with an MCP** | yes | yes | by design | a hosted service |
| 7 | **Your own tiny presence/lock server** (sessions mint a token w/ random password) | yes | yes | **yes** | run a server |
| 8 | **Peer-to-peer register over a VPN mesh** (WireGuard / Tailscale) | yes | gossiped | needs consensus | per-machine setup; peers must be online together |

### Push vs. poll — the third axis (and why the chat bus is special)

The doc/field/mailbox surfaces are **poll**: a session has to go *look* to learn a
claim changed. A **real-time chat bus (Slack / Discord)** is **push** — events
arrive, so a claim is seen the instant it's posted, which is closest to the original
"live field" instinct. The bus also hands you **native per-message identity** for
free (every message carries its author), which dissolves the "who wrote what" wrinkle
that a shared Gmail account reintroduces. Structure is built in too: channel per
milestone, pinned message = register, scrollback = append log.

Free tiers are sufficient for this volume: **Discord** — effectively unlimited
history, free bots/webhooks (most generous); **Slack free** — fine, but ~90-day
history retention (a non-issue for coordination, which never needs ancient claims)
and the cleanest first-party `@claude` mention flow. What the bus still does *not*
give you is a hard lock — pinned-message edits race and messages are an append log,
so simultaneous claims both land and you arbitrate by convention (timestamp /
first-message-wins). It is the best *convention* surface, not a *mutual-exclusion*
one; only the version-CAS surfaces (Confluence-style) give a real lock.

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

## Chosen direction — three spread surfaces (decided)

Ship support for **three** coordination surfaces, picked to be *maximally spread*
across audience and capability, behind a common adapter so more can be added later
without changing the protocol (the pattern is the asset; surfaces are pluggable):

| Surface | Who it's for | Modality | Identity | Atomic claim | MCP |
|---------|-------------|----------|----------|--------------|-----|
| **Google — Gmail / Drive** (labels or doc = register; threads / revisions = log) | anyone; zero-setup, universal | poll | per-edit (Drive) / shared + signed (Gmail) | no — convention | **official** |
| **Confluence** — page = register, page history = log | enterprise / teams | poll | native | **yes — version CAS** | **official (Atlassian)** |
| **Discord** — pinned msg = register, channel = log | indie / community / real-time | push | native per-author | no — convention | **community (unofficial)** |

The set is chosen for *spread*: **Google** is the **flow + floor** — lowest-friction,
official MCP, what almost everyone already has; **Confluence** is the **enterprise
lock** (real version-CAS mutual exclusion); **Discord** is the **real-time / community**
option. Between them they span poll↔push, convention↔CAS, and consumer↔enterprise.

**Prefer official MCPs.** The lead / reference adapter must ride an **official** MCP, so
the thing the whole layer depends on is trustworthy and maintained — that's why
**Google (Gmail/Drive)** leads and is the Phase-A reference, **not Discord** (whose MCP
is community-maintained). Discord stays a flagged, optional adapter behind the same
interface; add it when a team wants real-time and accepts the unofficial dependency.
*Implementation caveat:* the mutable-register mechanism depends on what the official MCP
actually exposes (Gmail **labels** vs draft-edit; Drive file-create vs revisions) —
confirming that is step one of the spike, not an assumption.

**Cross-surface requirement (from the surface-availability finding).** Each adapter
must reach its surface through a **remote HTTP/SSE MCP server declared in the repo's
`.mcp.json`** — a local stdio MCP would only coordinate local / Remote-Control
sessions, because Claude Code on the web, Slack-spawned, and GitHub Actions sessions
cannot see local stdio servers (only remote servers committed to the repo). This is
the same mechanism that lets G-Forge's *enforcement* travel at all: hooks fire on
every surface only because `/g-init` writes them into the **committed** project
`.claude/` (M28 deliberately kept `.claude/hooks/`, `settings.json`, `rules/`,
`agents/` tracked rather than ignored). Commit the config → governance and
coordination both follow you to the phone, the web, and CI.

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
- **Human orchestration, not autonomous AI orchestration (per M24).** The goal is
  multi-user cooperation — a human team playing on a shared fabric — which *is*
  governance, scaled to teams. The single permanent line: G-Forge never auto-dispatches
  a person or another AI session without a human in the loop, and never runs as an
  always-on hosted authority. Humans decide; G-Forge enforces and records.
- **Single-player by default.** Solo work carries zero overhead; the multiplayer
  framework engages only when concurrency is detected, and degrades back cleanly.
