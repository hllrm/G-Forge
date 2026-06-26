---
description: Capture an architectural decision record. Gathers context interactively, offloads the weighing to a throwaway deliberation subagent (keeps HQ's context clean), and writes docs/decisions/NNN-title.md. On a consequential decision it closes the loop — runs /g-retro and recommends a fresh session that verifies the ADR first. Run when making a significant technical choice.
argument-hint: [short decision title]
---

Use Glob to find `skills/g-adr/SKILL.md` inside `~/.claude/plugins/cache/g-forge/g-forge/` and read it, then follow its instructions exactly. The user's argument (if any) is: $ARGUMENTS
