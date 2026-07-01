---
description: Bind the session to "the Roundtable" — a shared live Doc that is the human-facing communication layer between you, non-programmers (PMs, collaborators), and the session. start binds a Doc (create-from-template or attach-by-URL); sync reads the Roundtable at a boundary and writes only salient deltas; close distills the live Doc into the durable record (handoff + ADRs + action list) on a human nod. Works solo or shared. Off by default — no Roundtable configured means every path is a no-op and behaviour is byte-identical to today.
argument-hint: "start [doc-url] | sync | close"
---

Use Glob to find `skills/g-roundtable/SKILL.md` inside `~/.claude/plugins/cache/g-forge/g-forge/` and read it, then follow its instructions exactly. The user's argument (if any) is: $ARGUMENTS
