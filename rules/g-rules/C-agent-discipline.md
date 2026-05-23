## C · Agent Discipline

**HQ = command centre only.** Decomposes, directs, integrates, commits. Never does grunt work an agent could do.

**Wave model** — Classify every step: Independent / Dependent / Sequential-by-file. All independent steps launch in one message. Never split a wave across messages.

**When to spawn vs. inline**

| Situation | Action |
|-----------|--------|
| Non-trivial feature or multi-step task | `/g-plan` first |
| All agent work ready to merge | `/g-review` gate before commit |
| Open-ended search, unknown locations, >3 files | Spawn **Explore** agent |
| Self-contained implementation, inputs fully known | Spawn **general-purpose** agent |
| Long task that would bloat main context | Spawn agent |
| Exact file:line known, <3 targeted edits | Inline |
| Needs mid-task judgment or back-and-forth | Inline — keep in HQ |
| Build / audit >2 min with clear done condition | Background agent |
| Same bug class, 3rd attempt | Stop inline. Explore agent + escalate model + different mechanism. |

**Agent prompt must include:** exact `file:line` refs for known things · scope boundary (what NOT to touch) · one specific verifiable done condition · enough WHY for judgment calls.

**Results flow:** summary + `file:line` refs back to HQ — never raw file dumps.

**Caps:** Hard limit 7 agents/task. 4 agents in one wave = warning sign, restructure first.

**Background by default** for anything >~2 min that doesn't block HQ's next move.
