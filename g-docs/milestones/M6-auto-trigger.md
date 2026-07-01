# M6 — Auto-trigger & Project Hygiene

## Goal
Eliminate manual workflow commands — Claude initiates plan/execute/review automatically. Add project health tooling.

## Scope
- [x] `workflow-checkpoint.sh` UserPromptSubmit hook — fires on every message, reports branch, active plan/wave, review state, Tier 3 listen mode
- [x] Auto-trigger rule in G-RULES.md and CLAUDE.md compact block — Claude detects non-trivial tasks and initiates `/g-plan` / `/g-execute` / `/g-review` without being asked
- [x] `/g-help` — context-aware skill; reads project state and tells the developer where they are and what to do next
- [x] `/g-status` — fast one-line snapshot: milestone, active wave, review gate, handoff line
- [x] `/g-brief` — incremental `project_brief.md` refresh; targeted Q&A, no full re-onboard
- [x] `/g-doctor` — 7-point health check: hooks installed, hooks registered in settings.json, G-Team Rules block, G-RULES.md present, no stale sentinel, milestone alignment
- [x] `g-team-review` auto-closes completed milestone tasks and updates ROADMAP.md on MERGE READY

## Done condition
Claude initiates plan/execute/review on non-trivial tasks without user typing commands. `/g-doctor` reports 7/7 on a freshly-init'd project.

## Status
✅ Complete (v0.6.0)
