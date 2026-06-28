---
description: Capture an architectural decision record. First triages whether the decision merits an ADR or just a one-line brief entry (keeping the corpus high-signal). Captures pre-deliberated reasoning or interviews from scratch, offloads the weighing to a throwaway deliberation subagent (keeps HQ's context clean), and writes g-docs/decisions/NNN-title.md. Runs a mandatory reversibility check + premortem before close so the developer has the full picture before building. On a consequential decision it closes the loop — runs /g-retro and recommends a fresh session that verifies the ADR first. Run when making a significant technical choice.
argument-hint: [short decision title]
---

Use Glob to find `skills/g-adr/SKILL.md` inside `~/.claude/plugins/cache/g-forge/g-forge/` and read it, then follow its instructions exactly. The user's argument (if any) is: $ARGUMENTS
