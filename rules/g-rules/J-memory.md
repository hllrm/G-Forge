## I · Memory Layers

G-Forge uses a 6-tier memory layer taxonomy. Full definitions, ownership rules, and eviction policy are in `g-docs/memory-taxonomy.md`.

| Layer | Lifetime | Scope |
|-------|----------|-------|
| Working | Current session | Agent-scoped |
| Task | Single task / wave | HQ-scoped |
| Sprint | Current milestone | Team-scoped |
| Architectural | Project lifetime | HQ + architect |
| Institutional | Cross-project | Org-scoped |
| Human Preference | Cross-project | User-scoped |

Skills and agents declare which layers they need via `context:` in their YAML frontmatter (e.g. `context: [task, sprint]`). Orchestrators must load all declared layers before invoking the skill.
