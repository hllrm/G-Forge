# G-Forge Memory Layer Taxonomy

G-Forge agents operate across multiple contexts — a single session, a long-running milestone, a shared codebase, an organisation's conventions, and a specific developer's preferences. Memory layers formalise this by assigning every piece of information a lifetime, an audience, and a home. Agents declare which layers they need so orchestrators and developers can reason about what context will be loaded, mutated, or persisted for any given skill invocation.

---

## The layer has two halves: storage and retrieval

A memory taxonomy that only says *where things live* is a glossary, not a system. The six tiers below are the **storage** half — they give every piece of information a lifetime, an audience, and a home. The half that makes them useful is **retrieval**: pulling the right slice of the durable record back into a clean window when a fresh session, agent, or wave needs it. In G-Forge the retriever is `/g-resume` (with narrower lookups in `/g-align`'s brief check and `/g-patterns`' retro mining). Storage without retrieval is a filing cabinet no one opens — the two halves are one layer.

This is the same shape as retrieval-augmented generation (RAG): a corpus too large for the context window, queried for the relevant fragments, which are loaded into the prompt before generation. The mapping is exact —

| RAG concept | G-Forge equivalent |
|---|---|
| Corpus / knowledge base | The durable record: retros, ADRs, the observer journal, `g-docs/todo.md`, milestone files, the `## Active Session` handoff |
| Chunk | A distilled section — a retro's *Cold-start context*, an ADR's *Decision* — never a whole file |
| Query | The re-entry keys: current branch slug, active milestone, first task, recently-touched files |
| Retriever | `/g-resume` — gather candidates by key (grep/glob), judge relevance, load only what serves the first task |
| Augmented prompt | The clean window the briefing is loaded into |
| Embedding / vector index | **Deliberately absent** — see "Why there is no vector store" below |

The discipline RAG enforces is the one G-Forge already lives by: don't stuff the whole corpus into the window — retrieve the relevant slice and nothing more. A re-hydration that dumps everything just re-poisons the context it was meant to keep clean (G-RULES §A7).

---

## How each tier is retrieved

Retrieval differs by tier, because lifetime and audience set how the slice is found:

- **Working** — never retrieved across the seam; it dies with the session by design. Promoting anything from here into a durable tier is an explicit act (a commit, an ADR, a handoff line), not a query.
- **Task / Sprint** — retrieved by *key*: the `## Active Session` handoff and the active milestone in `g-docs/ROADMAP.md`, keyed to the current branch and first task. Exact-match lookup, not relevance search.
- **Architectural** — retrieved by *topic overlap*: `/g-resume` greps `g-docs/decisions/` for the branch slug and recently-touched filenames; in-force ADRs surface as constraints, not re-opened questions.
- **Institutional / Human Preference** — retrieved by *always-on inclusion*: org standards and developer preferences are small and load every session (via `@`-referenced rules and `CLAUDE.md`), so they need no query.

The weak seam is **topic-overlap retrieval** (the Architectural tier): keying on the branch slug and touched filenames misses a record that is relevant by *subject* but happens to share no slug or filename — e.g. a caching ADR that never named the file you are now editing. That is the honest analogue of "no semantic search." The in-scope fix is sharper keys — topic tags on records plus a light index — **not** embeddings; it is scoped in `g-docs/milestones/memory-layer-retrieval-upgrade.md`.

---

## Why there is no vector store

The question "should G-Forge embed the record and retrieve by vector similarity?" is settled and recorded in **ADR-001** (`g-docs/decisions/001-no-vector-store-for-memory-retrieval.md`). In short: G-Forge ships as markdown + shell with no runtime process to host an embedding model or vector index, and its enforcement must travel to web / mobile / Slack / Actions surfaces where a local store would be invisible. The durable record is also small and high-signal by design (ADRs are kept rare; retros are distilled), so deterministic key-plus-grep retrieval over it is sufficient, auditable, and free of an external dependency. The upgrade path is sharper keys, not a vector DB.

---

## Tier 1 — Working

**Lifetime:** Current session only. Discarded when the session ends.

**Audience:** The individual agent that created it.

**What belongs here:**
Ephemeral reasoning state that is only meaningful within one continuous execution: intermediate results, scratch-pad analysis, tentative hypotheses not yet promoted to a decision, and in-flight variable bindings.

**Example content:**
- "I found `useFoo.ts` at line 42 — holding this ref while I check the caller"
- "Candidate approach: extract the transform to `lib/formatters.ts`; not confirmed yet"
- "Current pass: reading three files before proposing edits"

---

## Tier 2 — Task

**Lifetime:** Single task or wave. Cleared after the task closes or the wave completes.

**Audience:** HQ and any agents dispatched within the task.

**What belongs here:**
The shared context for one atomic unit of work: the task spec, inputs agreed at wave start, intermediate agent results before HQ integrates them, and the done condition being tracked.

**Example content:**
- Wave 2 inputs: `{ filesToEdit: ["src/store/auth.ts", "src/composables/useSession.ts"], goal: "extract token refresh into a composable" }`
- Agent A result: "Found 3 call sites for `refreshToken` — refs: `auth.ts:88`, `login.ts:34`, `interceptor.ts:12`"
- Done condition being evaluated: "All three call sites delegate to `useTokenRefresh`; no direct fetch calls remain in components"

---

## Tier 3 — Sprint (Milestone)

**Lifetime:** Current milestone. Survives across multiple sessions until the milestone closes.

**Audience:** The full team: HQ, all dispatched agents, and the architect reviewer.

**What belongs here:**
Milestone-scoped state that must survive session restarts: active task ledger, wave schedules, partial results, QA scope, and decisions made during the milestone that have not yet been promoted to ADRs.

**Example content:**
- `g-docs/todo.md` Handoff block: tasks done, next up, active `file:line` context
- QA scope file `g-docs/qa-scope/m9-memory-layers.md` listing impacted test groups
- "Decided mid-sprint: `context:` field is declaration-only — no runtime enforcement until M10"

---

## Tier 4 — Architectural

**Lifetime:** Project lifetime. Updated intentionally; never discarded while the project exists.

**Audience:** HQ and the architect agent installed by `/g-specialize`.

**What belongs here:**
Durable technical decisions and structural rules that govern the entire codebase: ADRs, architecture rules files, layer maps, import direction constraints, state ownership rules, and the project brief.

**Example content:**
- `g-docs/decisions/004-memory-taxonomy.md` — ADR capturing why six tiers were chosen over a flat key-value store
- `.claude/rules/architecture-vue-pinia.md` — layer map, import direction table, state ownership rules
- `g-docs/project_brief.md` — stack decisions, constraints, agreed MVP scope

---

## Tier 5 — Institutional

**Lifetime:** Cross-project, organisation-scoped. Persists as long as the organisation uses G-Forge.

**Audience:** All projects and agents within the organisation.

**What belongs here:**
Conventions, standards, and shared knowledge that apply across every project in the org: coding standards not captured per-project, shared utility libraries, org-wide security policies, approved dependency lists, and team norms.

**Example content:**
- "All API calls must use the org's shared `httpClient` wrapper — direct `fetch` is not permitted in product code"
- "Approved state-management libraries: Pinia (Vue), Zustand (React). Redux requires architecture review."
- "PR merge requires at least one human reviewer in addition to the automated review gate"

---

## Tier 6 — Human Preference

**Lifetime:** Cross-project, permanent. Follows the user across all projects and sessions.

**Audience:** The specific developer — read by agents to personalise behaviour.

**What belongs here:**
Stable individual preferences that shape how G-Forge behaves for this developer: communication style, tool choices, workflow shortcuts, known expertise areas, and any standing instructions the developer has set.

**Example content:**
- "Always push immediately after committing — never leave a commit unpushed"
- "Preferred commit style: imperative mood, 50-char subject, no period"
- "User is expert in TypeScript/Vue; skip explaining basic syntax; go straight to the architectural reasoning"

---

## Frontmatter Usage

Skills and agents can declare a `context:` field in their YAML frontmatter. This is a **declaration of intent** — it tells orchestrators and developers which memory slices are relevant to this skill. The runtime does not automatically inject or enforce these layers; the declaration exists so skill authors communicate their assumptions and so future tooling can use it for context loading decisions.

**Format:**

```yaml
context: [tier1, tier2, ...]
```

Use lowercase tier names:

| Name | Frontmatter value |
|------|------------------|
| Working | `working` |
| Task | `task` |
| Sprint / Milestone | `sprint` |
| Architectural | `architectural` |
| Institutional | `institutional` |
| Human Preference | `human-preference` |

**Example — a skill that needs task and sprint context:**

```yaml
---
name: g-execute
description: Dispatch parallel agents per wave from an approved plan. Holds wave boundary until each wave completes.
context: [task, sprint]
---
```

This tells anyone reading the skill (and future orchestrators) that `g-execute` reads the active task spec from Tier 2 and the milestone ledger from Tier 3. It does not read architectural rules or user preferences directly — those are the responsibility of the agents it dispatches.
