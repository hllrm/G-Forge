# M7 — Correctness, Validation & Polish

## Goal
Fill quality gaps: design patterns, game-dev architecture rules, per-project G-RULES.md, and a full alignment pass across all agents and skills.

## Scope
- [x] **G-RULES.md §F — Design Patterns**: 6 universal principles (composition over inheritance, explicit over implicit, YAGNI, fail fast, observer/event-driven, state machine for discrete modes) and 8 anti-patterns refused by default
- [x] **Game-dev profile rules**: object pooling and state machine architecture rules added to all 5 game-dev profiles (unity, godot-gdscript, godot-csharp, unreal, cpp-cmake)
- [x] **Per-project G-RULES.md**: `/g-init` now installs G-RULES.md per-project and adds `@G-RULES.md` to project CLAUDE.md; `/g-update` keeps it current
- [x] **SOLID in G-RULES.md §D**: full SOLID block with one actionable rule per principle (SRP, OCP, LSP, ISP, DIP)
- [x] **`/g-audit`**: code quality audit — SOLID violations, smells, dead code, coverage gaps; two-mode output (targeted inline / whole-codebase roadmap milestone)
- [x] **`/g-optimize`**: performance audit — O(n²), N+1, re-render waste, leaks, caching; same two-mode output
- [x] **`/g-refactor`**: guided refactor orchestration — pre-analysis, spec, human approval, wave execution, review gate
- [x] **`/g-docs`**: documentation audit and generation — JSDoc/docstrings gaps, README, env vars, CHANGELOG, ADRs
- [x] **`/g-adr`**: architectural decision record capture — 5-question interactive flow, writes `docs/decisions/NNN-title.md`
- [x] **G-RULES.md §G — Documentation Standards**: all documentation layers with currency rule and per-type requirements
- [x] **Astro island combo profiles**: astro-react, astro-vue, astro-svelte with island placement, serializable prop contract, cross-island state strategy, hydration directive defaults
- [x] **Agent alignment**: `code-reviewer` SOLID checklist, `architecture-enforcer` OCP/DIP checks, `review-orchestrator` conditional `doc-writer` dispatch, `spec-writer` documentation done conditions

## Done condition
`/g-doctor` reports 9/9. All agents have SOLID checks. All game-dev profiles have architecture rules. `/g-audit`, `/g-optimize`, `/g-refactor`, `/g-docs`, `/g-adr` are reachable via commands.

## Status
✅ Complete (v0.7.5)
