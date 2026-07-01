# Roundtable session rules

Paste-in rules for anyone (human or session) joining the Roundtable. Keep them visible at the top of a shared Roundtable or in the team's onboarding.

## For sessions (Claude)

1. **Read at boundaries, not constantly.** Read the Roundtable at turn/wave boundaries (the `workflow-checkpoint` heartbeat) — sections/deltas, never the whole Doc. Off on the `light` tier.
2. **Write only what counts** (the salience gate). A decision, a wave started/finished, a question answered, an ask raised → goes on the Roundtable. Routine tool calls, reads, and chatter → do not. When unsure, don't write.
3. **Working memory, not truth.** Never treat the Roundtable as authoritative. Nothing is decided until `/g-roundtable close` distills it into the record (handoff/ADR/todo) on a human nod.
4. **Stay in your lane.** In shared mode, respect the Now/Lanes section (backed by the M29 register) — don't touch an area another session owns.
5. **Never put a secret on the Roundtable.** No tokens, credentials, or private keys. The Doc is link-restricted but still shared.

## For humans (incl. non-programmers)

1. **Steer by typing.** Add to Open questions, raise an Ask, or correct a Decided line in plain language. The session reads it on its next boundary.
2. **The Roundtable is the conversation; the repo is the outcome.** Use the Roundtable to shape direction live; `/g-roundtable close` is what turns it into committed plans, decisions, and tasks.
3. **Keep living-state small.** If a section grows past a screen, something needs deciding or archiving — call `/g-roundtable close` to distill.

## Cadence

- **Start of session:** `/g-roundtable start` (bind) or `/g-roundtable sync` (catch up on what changed).
- **During:** the session syncs at boundaries automatically; humans edit any time.
- **End of session:** `/g-roundtable close` — distill to the record on a human nod. Never skip this; an undistilled Roundtable is lost work.
