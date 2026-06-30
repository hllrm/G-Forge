# ADR-001: No vector store for memory retrieval — keep deterministic key+grep retrieval

**Date:** 2026-06-30
**Status:** Accepted
**Reversibility:** two-way door (reversible) — retrieval is encapsulated in `/g-resume`; a store could be added later behind the same skill without touching the storage tiers.
**Context:** G-Forge memory layer (retrieval half)

## Context

G-Forge's memory layer has a storage half (the 6-tier taxonomy) and a retrieval half (`/g-resume`, which re-hydrates a clean window from the durable record — retros, ADRs, journal, handoff). Retrieval today is deterministic: gather candidates by key (branch slug, active milestone, recently-touched filenames) with grep/glob, judge relevance, load only distilled sections. The recurring suggestion is to make this "real RAG" — embed the record and retrieve by vector similarity (pgvector / Pinecone / a local index). This ADR records why G-Forge does **not** adopt a vector store, so the choice is not re-litigated each time embeddings come up.

## Decision

Keep retrieval deterministic — key-plus-grep over the durable record, with model-judged relevance. Do **not** add an embedding model or vector index. The upgrade path for retrieval quality is sharper keys (topic tags on records, a light index), not vector similarity.

## Alternatives considered

| Option | Why rejected |
|--------|-------------|
| Embeddings + vector DB (pgvector/Pinecone/Weaviate) | G-Forge is markdown + shell with no runtime process to host a model or index; adds an external service + API key + network dependency that must work identically on web/mobile/Slack/Actions surfaces, where a local store is invisible. Cost far exceeds the benefit over a small, high-signal corpus. |
| Local on-disk vector index (e.g. embed to a committed file) | Embedding still needs a model call at write *and* query time; the index drifts from the record unless regenerated; no runtime owns regeneration. Re-introduces the dependency without the managed-service upside. |
| Sharper deterministic keys — topic tags + a light index over the existing record | **Chosen direction for future work** (see milestone). Captures most of the "relevant by topic, not by filename" gain with zero new runtime, zero external dependency, and fully auditable retrieval. |
| Do nothing | Acceptable today (the corpus is small), but leaves the topic-overlap blind spot in `/g-resume` unaddressed; the milestone tracks closing it without a store. |

## Consequences

**Easier:** Retrieval stays portable across every Claude Code surface; no external service, API key, cost, or network failure mode; retrieval is fully auditable (you can read the grep that produced the slice); no index-vs-record drift.
**Harder / constrained:** Retrieval cannot find a record that is relevant by *subject* but shares no key (slug/filename) with the current task — the topic-overlap blind spot. Mitigated by sharper keys, not by similarity search.
**Follow-up decisions:** How to add topic keys to records (tag vocabulary, where the index lives, who writes it) — deferred to `g-docs/milestones/memory-layer-retrieval-upgrade.md`.
**Risks:** If the durable record ever grows large and low-signal enough that grep returns too many candidates to judge, this decision should be revisited — that is the trip-wire for reopening it.

## Rejected Alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Managed vector DB | Runtime + external dependency G-Forge has no place to host; breaks surface portability. |
| Local embedded index | Embedding model calls + index drift with no runtime to own regeneration. |

## Assumptions That Held

- The durable record stays small and high-signal — ADRs are kept rare by `/g-adr`'s triage; retros are distilled, not raw transcripts. (Fragile if record hygiene slips; that is the revisit trigger.)
- G-Forge continues to ship as committed markdown/shell config with no bundled runtime process. (Fragile if a future milestone adds a runtime — e.g. M26's workflow-script engine — that could *also* host an index; revisit then.)
- Model-judged relevance over grep candidates is good enough to substitute for similarity ranking on a corpus this size. (Fragile at scale.)

## Constraints That Drove This Decision

- **Surface portability** — enforcement and tooling must travel to web/mobile/Slack/Actions; a local store is invisible there.
- **No runtime** — the plugin is markdown + shell; nothing hosts a model or index.
- **Auditability** — a governance tool's retrieval should be inspectable, not an opaque nearest-neighbour lookup.
- **Dependency minimalism** — no external service, key, or cost for a corpus that grep handles.
