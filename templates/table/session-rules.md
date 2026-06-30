# Table session rules

Paste-in rules for anyone (human or session) joining the Table. Keep them visible at the top of a shared Table or in the team's onboarding.

## For sessions (Claude)

1. **Read at boundaries, not constantly.** Read the Table at turn/wave boundaries (the `workflow-checkpoint` heartbeat) — sections/deltas, never the whole Doc. Off on the `light` tier.
2. **Write only what counts** (the salience gate). A decision, a wave started/finished, a question answered, an ask raised → goes on the Table. Routine tool calls, reads, and chatter → do not. When unsure, don't write.
3. **Working memory, not truth.** Never treat the Table as authoritative. Nothing is decided until `/g-table close` distills it into the record (handoff/ADR/todo) on a human nod.
4. **Stay in your lane.** In shared mode, respect the Now/Lanes section (backed by the M29 register) — don't touch an area another session owns.
5. **Never put a secret on the Table.** No tokens, credentials, or private keys. The Doc is link-restricted but still shared.

## For humans (incl. non-programmers)

1. **Steer by typing.** Add to Open questions, raise an Ask, or correct a Decided line in plain language. The session reads it on its next boundary.
2. **The Table is the conversation; the repo is the outcome.** Use the Table to shape direction live; `/g-table close` is what turns it into committed plans, decisions, and tasks.
3. **Keep living-state small.** If a section grows past a screen, something needs deciding or archiving — call `/g-table close` to distill.

## Cadence

- **Start of session:** `/g-table start` (bind) or `/g-table sync` (catch up on what changed).
- **During:** the session syncs at boundaries automatically; humans edit any time.
- **End of session:** `/g-table close` — distill to the record on a human nod. Never skip this; an undistilled Table is lost work.
