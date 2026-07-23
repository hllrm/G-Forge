# G-Forge Wiki

**What:** G-Forge is a Claude Code plugin that installs an educated, enforced project-management layer into any project. It layers a PM that challenges scope, parallel execution waves, and an unskippable commit gate — making discipline non-optional, not advisory.

**Current state:** v2.3.0 released. M-audit closed. Next: M46 Update Integrity → M41 Release Machinery → M45 Review Pipeline Rework → M42 Cold-start (see [ROADMAP](../g-docs/ROADMAP.md)).

**This wiki covers the architecture, workflows, and operations behind G-Forge.** Start with [Getting Started](usage.md) if you're new; use [Commit Gate](commit-gate.md) if you need to understand enforcement; refer to [Architecture](architecture.md) for design decisions and data flow.

---

## Contents

| Page | What's in it |
|------|-------------|
| [**Getting Started**](usage.md) | Install, project lifecycle, per-task workflows, integration tiers, session rhythm, voice profiles |
| [**Commit Gate**](commit-gate.md) | How the review enforcement works, sentinel flow, hook architecture, context depth management |
| [**Architecture**](architecture.md) | Design decisions, layer model, skill vs agent distinction, memory taxonomy, single-use agents, wave dispatch |

---

**G-Forge is shipped as a Claude Code plugin.** Install via `/plugin marketplace add hllrm/g-forge` + `/plugin install g-forge` — see [README](../README.md) for full install instructions.

Full project documentation lives in `g-docs/` — milestones in `g-docs/milestones/`, architectural decisions in `g-docs/decisions/`, operational tracking in `g-docs/ROADMAP.md` and `g-docs/todo.md`.
