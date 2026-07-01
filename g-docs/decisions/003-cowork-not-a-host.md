# ADR-003: Claude Cowork is not a G-Forge host — it doesn't fire `.claude/` hooks, so enforcement is inert

**Date:** 2026-07-01
**Status:** Accepted
**Reversibility:** two-way door (easily reversible) — this is a "not yet" gated on an external capability, not a design commitment. Re-probe and reverse when the trigger below fires; nothing in G-Forge is built *against* Cowork, so reversing costs only a re-test.
**Context:** Evaluating Claude Cowork (GA, mid-2026) as a possible runtime/host for G-Forge, prompted by "Cowork is out — check it can run G-Forge, and if so switch off the CLI."

## Context

Cowork is Claude's persistent workspace app (files/context/tasks that outlive a chat; knowledge-worker framing; Team/Enterprise). The open question was whether G-Forge could *run* in Cowork — and if so, whether Cowork should replace the CLI as the primary surface.

G-Forge's value is not its markdown; it is **enforcement that travels**. The entire model (M28's "committed config travels", M29/M33's cross-surface reach) rests on one mechanism: hooks fire from a project's **committed `.claude/`** on every client. Concretely G-Forge depends on:
- a **`PreToolUse` commit gate** that blocks a non-conforming commit via exit-2 / deny-JSON (the headline differentiator — see the alveria-report Bug A fix, ADR/CHANGELOG),
- a **`SessionStart`** re-hydration hook (`/g-resume` seam),
- a **checkpoint heartbeat** (`Stop`/`PostToolUse`) driving the Roundtable/register.

So the make-or-break test is single and concrete: **does a `PreToolUse`-denied commit actually get blocked inside Cowork?**

## Decision

**Do not treat Cowork as a G-Forge host. The CLI (plus Claude Code on the web and GitHub Actions) remains the primary runtime. Do not deprecate the CLI.**

Research verdict (sourced, 2026-07-01): **Cowork does not implement the `.claude/settings.json` hook pipeline at all.** `PreToolUse`, `PostToolUse`, `SessionStart`, `Stop`, `PreCompact` do **not** fire; a `PreToolUse` that exits 2 does **not** block a tool call because the hook never runs; Cowork does **not** read a cloned repo's committed `.claude/` (hooks/settings/rules/agents). Root cause is architectural, not a config gotcha: the agent runs in a Linux sandbox while hook scripts would run host-side, and Anthropic has not decided which side executes them — so neither does. Tracked as open feature requests (anthropics/claude-code #63360, #40495), i.e. not implemented and not a quick fix.

Therefore G-Forge in Cowork today is **inert governance**: skills may invoke as plain prompts, but nothing *enforces* — no commit gate, no review-gate teeth, no re-hydration. That is G-Forge with its spine removed, so Cowork cannot be the host, and "switch off the CLI" is rejected: dropping the CLI would drop the enforcement layer entirely and would also abandon the headless CI/Actions surface Cowork can never cover.

**What survives:** Cowork remains viable as a *future native shared surface* for the M29 register / M33 Roundtable — that bet needs only Cowork's files/sharing, not its hooks, and is untouched by this decision. Cowork-as-**surface** is alive; Cowork-as-**host** is a no-go for now.

## Alternatives considered

| Option | Why rejected |
|--------|-------------|
| **Adopt Cowork as host, deprecate CLI** | The premise — Cowork runs G-Forge — is false: hooks don't fire, enforcement is inert. Also strands headless CI/Actions sessions, which are never Cowork, and narrows the heterogeneous-client diversity the M29 arc is designed around. |
| **Run G-Forge in Cowork "advisory only" (skills as prompts, no enforcement)** | Ships the label without the product. A commit gate that doesn't block is exactly the alveria-report Bug A failure mode we just fixed — do not reintroduce a no-op gate under a new client. |
| **Wait / do nothing, no record** | The "why not just move to Cowork?" question will recur every session; leaving it unrecorded invites re-litigation. Hence this ADR + an explicit re-probe trigger. |
| **Build a Cowork-side shim to fire hooks host-side** | Speculative, depends on internals Anthropic hasn't settled (#63360); premature. Revisit only after they choose the execution side. |

## Consequences

- **Easier:** the recurring "should we abandon the CLI for Cowork?" question is settled with a sourced answer; the M29/M33 build session inherits "CLI/web/Actions primary" without re-deciding.
- **Harder / constrained:** G-Forge users who live in Cowork get no governance there today; the two worlds don't share enforcement.
- **Follow-up (re-probe trigger):** re-run the make-or-break test when **any** of these ships — (a) anthropics/claude-code #63360 (Cowork honors Claude Code hooks) is closed/implemented, (b) Cowork reads a repo-committed `.claude/`, or (c) Anthropic documents `PreToolUse` blocking in Cowork. The re-test is one probe: bind a repo whose `.claude/` denies a test commit and confirm the commit is actually blocked.
- **Unaffected:** Cowork-as-future-shared-surface (M29/M33 backend) and Agent-Teams-as-local-tier remain live and are out of this ADR's scope.

## Constraints that drove this decision

- Enforcement-travels-via-committed-`.claude/`-hooks is G-Forge's spine (M28); a host that doesn't fire hooks cannot carry the product.
- The commit gate must *actually block* — a non-blocking gate is a shipped bug (alveria Bug A), not an acceptable degraded mode.
- Cross-surface reach (CLI + web + CI/Actions) is a structural requirement of the multiplayer arc, not a preference.

## Assumptions that held (with fragility)

- **Cowork does not fire `.claude/` hooks.** *Confirmed* via Anthropic's own issue tracker (#63360, #40495), converging across issues. *Fragile because* it is issue-tracker-sourced and dated ~May–Jul 2026, not a formal "won't support" statement, and Cowork is evolving fast — hence the explicit re-probe trigger rather than a permanent "never."
- **The CLI (and web/Actions) will remain a supported Claude Code surface** where committed hooks fire. *Holds today*; if that ever changed, G-Forge's whole travel model would need rework independent of Cowork.
- **Plugin/skill/MCP loading in Cowork is genuinely unconfirmed** and did not affect this decision — the enforcement gap alone is dispositive, so the unknowns don't change the verdict.
