## H · Testing Protocol

**Three tiers — different owners, different rules.**

**Tier 1 — Automated Gates** (Claude owns · blocking on every commit)
Lint · type-check · unit tests · build verification. Any red = stop, do not commit, report and fix first.
An agent reporting tests "written" or "done" is **not** evidence they pass — `test-writer` has no execution tool; it authors, it never verifies. Tier-1 green requires an **actual run with pasted output** (framework + pass/fail counts); MERGE READY is blocked until a real run is green. Whoever holds the execution tool runs the suite and owns the verdict (M-audit finding #20).

**Tier 2 — Tooling-Assisted** (Claude runs when infrastructure exists)
E2E, integration, contract tests. If infrastructure is missing and the task touches a critical path, flag the gap explicitly — never silently skip.

**Tier 3 — Human-Driven** (user owns the verdict · Claude never infers pass from output)
Smoke tests · acceptance · design review · business logic correctness. User exercises the real app and reports findings in chat. Claude cannot substitute judgement here.

---

**Tier 3 Instrument — QA Panel or Test Plan**

Tier 3 requires a testing instrument. Which one depends on the project:

- **QA panel present** — a structured in-app testing UI. G-Forge integrates it from the start, not as an afterthought.
  - At milestone planning: identify which test groups are impacted. Compile `g-docs/qa-scope/<milestone-slug>.md` mapping each in-scope group to what must pass.
  - QA panel currency: any task adding/removing user-facing surface must include "QA panel updated" as a done condition. MERGE READY is blocked if the panel is stale.
- **No QA panel** — at milestone planning, generate a test plan and print it in chat. The test plan lists scenarios to exercise, grouped by feature area, derived from the milestone scope. The developer uses this as their checklist during Tier 3. No file saved — it is a live prompt artifact.

The instrument is established at milestone start. Tier 3 without an instrument (no QA panel and no generated test plan) is not valid.

---

**Tier 3 Protocol — Listen Mode**

Run `/g-listen` to enter listen mode. It writes the state file, prints the instrument, and enforces the collect-only discipline automatically.

Manual protocol (if `/g-listen` is unavailable):

1. Print the instrument: QA panel scope (from `g-docs/qa-scope/<milestone-slug>.md`) or the test plan generated at milestone start.
2. Prompt: `Ready for smoke test? Work through the list above and report each finding in chat — say "done this round" when finished.`
3. Claude enters **listen mode** — no fixes, no suggestions, no edits. Acknowledge each report only:
   > `Bug N logged — <bug area>`
4. User declares **"done this round"**
5. Claude triages the full batch:
   - Same class ≥ 2 occurrences → **systemic**: grep all instances, treat as one wave
   - Single occurrence, known location → **isolated**: inline fix
6. Systemic waves execute first, then isolated fixes
7. Tier 1 gates run after fixes before next round begins
8. Next Tier 3 round → back to listen mode
9. Repeat until user declares DoD met

**Hard stops during listen mode:** No file edits. No mid-round fixes. No "quick suggestions." Collect and triage only — never act on a single report in isolation.

**Listen mode state file — `.claude/tier3-active`**
- When entering listen mode: write `0` to `.claude/tier3-active`
- After each bug is acknowledged: increment the count in `.claude/tier3-active`
- After triage and fix wave completes: delete `.claude/tier3-active`
- The workflow-checkpoint hook reads this file and surfaces listen mode status on every prompt
