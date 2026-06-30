## I · Memory Layers

G-Forge uses a 6-tier memory layer taxonomy. Full definitions, ownership rules, eviction policy, and the **retrieval model** are in `g-docs/memory-taxonomy.md`.

The layer has two halves: **storage** (the six tiers below — where information lives) and **retrieval** (pulling the right slice back into a clean window). The retriever is `/g-resume`; the durable record is the corpus. This is RAG in shape — retrieve the relevant slice, never dump the whole corpus (re-poisoning the window it was meant to keep clean). There is deliberately **no vector store** — see ADR-001 (`g-docs/decisions/001-no-vector-store-for-memory-retrieval.md`).

| Layer | Lifetime | Scope |
|-------|----------|-------|
| Working | Current session | Agent-scoped |
| Task | Single task / wave | HQ-scoped |
| Sprint | Current milestone | Team-scoped |
| Architectural | Project lifetime | HQ + architect |
| Institutional | Cross-project | Org-scoped |
| Human Preference | Cross-project | User-scoped |

Skills and agents declare which layers they need via `context:` in their YAML frontmatter (e.g. `context: [task, sprint]`). Orchestrators must load all declared layers before invoking the skill.
