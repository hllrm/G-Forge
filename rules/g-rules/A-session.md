## A · Session Rules

**A1 Model** — Haiku: explore / reads / search / format · Sonnet: implement / write · top tier (Opus, or any newer model above it such as Fable): only after 2 fails on same task. Never default to the top tier because a task "feels hard." If the session itself runs a top-tier model, the rule still applies to dispatched agents — delegation tiers are pinned per-agent, not inherited from the session.

**A2 Plan** — Atomic verifiable tasks before touching files. Log in `todo.md`. Identify Wave 1 (no blockers). Vague goals ("make it work") → ask before starting.

**A3 Execution workflow**
- Execute 1st pass only (no scope creep mid-wave)
- Before committing — mandatory gate: run the project's lint and test commands (check `package.json`, `Makefile`, `pyproject.toml`, or CI config for the right commands). Any red = stop, fix first.
- Business logic / public API / bug fix → tests required. Pure UI render → skip is OK, state why explicitly. Silence = not acceptable.
- Pure functions inside a component → extract to the project's lib/utils layer first, then test
- After each commit: update `todo.md` (remove closed rows + Details), append to `todo-done.md`, commit immediately — never leave either file dirty
- End of pass: rewrite `## Handoff` block in `todo.md` (replace, never append), commit, post the same block in chat

**A4 Token optimisation**
- Grep before Read — find line numbers, then read only those lines (`limit` + `offset`)
- No full-file reads on files >100 lines unless rewriting the whole file
- All independent tool calls in the same message (parallel)
- Cache `file:line` refs — never re-read the same file. Never re-Grep what an agent returned.
- Edit tool for partials; Write only for full rewrites. One logical change per commit.
- Don't refactor or optimise in the same pass as the feature/fix

**A5 Mindset** — State assumptions. No features / abstractions / error-handling beyond the ask. Every changed line traces to the request. Don't improve adjacent code. Remove imports made unused by your changes; leave pre-existing dead code alone and mention it.

**A6 Delivery** — Complete snippets with all imports. Explain WHY not what. Mark placeholders (`YOUR_API_KEY`). Flag security risks. No `TODO`/`FIXME` in delivered code.

**A7 Context gate** — The workflow checkpoint classifies the session as `implementation` (recent commits / dirty tree / active plan → thresholds 25/40) or `conversation` (clean / no plan → thresholds 35/55).

At 🟡 **amber**: run `/context` to read actual window percentage, then surface a direct warning to the user: *"Context is getting full — finish what's in flight, then run /g-retro before we start anything new."* If remaining capacity is < 50%, escalate to red immediately regardless of exchange count. The user still controls what happens next, but the warning must be explicit and visible — not buried in a status line.

At 🔴 **red**: enforce without waiting for the user. Accept no new scope. Complete only the task currently executing. When it finishes, automatically trigger `/g-retro`. After /g-retro completes, tell the user: *"Session context exhausted — open a fresh session and run `/g-resume` to continue."* The handoff block in `todo.md` must be written and committed before the session ends — this is non-negotiable.

**Auto-compaction is also a red trigger.** Context compression means the window actually overflowed — a stronger signal than the exchange count, and one the count can miss (the post-compaction `SessionStart` is *not* a fresh session, so the depth counter carries across it rather than resetting). `pre-compact.sh` records each compaction and `workflow-checkpoint.sh` surfaces the red reset off that count, so a session that compacts even once gets the same retro + fresh-session response. Do not treat a compaction as a clean slate — it carries the same residue a deep session does.

This reset has two sides. Promoting the clean record *out* — `/g-retro` + the handoff — is this side. Pulling the right slice back *in* is `/g-resume`, run on the first prompt of the fresh session: it selectively re-hydrates the new clean window from the durable record (relevant retro, in-force ADRs, journal, handoff) keyed to the first task, so the new session inherits the knowledge without the residue. `workflow-checkpoint.sh` nudges `/g-resume` automatically when a session opens with a pending handoff. The same `/g-resume` re-entry serves both triggers of the reset — the quantitative red gate here, and the semantic ADR-finalized trigger in §C.

**A8 Three-Strikes** — Same bug class × 3 attempts = STOP. Name the mechanism. List what failed and why. Find an alternative that bypasses it entirely. Escalate model before attempt 3, not after.
Warning signs: error message changes but bug class persists · you're explaining why *this* approach should work when the last one didn't · fix requires knowing internals of a platform component you don't control.
Three-Strikes is the ceiling on the single-use retry loop (§C). Each strike is a **fresh** agent with a *different* mechanism, seeded only by the prior attempts' distilled learnings — never the same context re-poked, which only poisons it further. After the third failed approach, stop and escalate to the human with the full learnings trail; do not deploy a fourth.
