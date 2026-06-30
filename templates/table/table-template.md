# 🪑 The Table — [Project Name]

> The live communication layer. **Working memory, not truth** — the repo (ROADMAP, ADRs, decisions) is authoritative. Nothing here is "decided" until it's distilled into the record on a human nod (`/g-table close`).
> **Restricted, never public.** No credentials, secrets, or tokens on this Doc.

---

## Living state
*(small by design — resolved items get archived to the feed by `/g-table close`)*

### Now / Lanes
*Who (person + session) is working on what, right now. In shared mode, lanes come from the M29 register so two sessions don't collide.*

- _[person/session]_ → _[area / wave / file-set]_

### Decided
*Decisions that have hardened. Each becomes an ADR or a brief-row at close.*

- _[decision]_ — _[one-line why]_

### Open questions
*Unresolved — needs a human (or another session) to answer.*

- _[question]_ — _[who's blocked on it]_

### Asks
*Direct requests addressed to a person or a session. Cleared when answered.*

- → _[to whom]_: _[the ask]_

---

## Feed — what just happened
*Append-only. Newest at the bottom. Salient deltas only — decisions, wave start/finish, questions answered, asks raised. Not a command log.*

- `[YYYY-MM-DD HH:MM]` _[salient event]_
