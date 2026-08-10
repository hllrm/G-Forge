# G-Forge feedback — from an extended session on `keyline`

For Gianmarco, maintainer of G-Forge. Written from inside a Claude Code session that has been running G-Forge on the `keyline` project since its kickoff (roughly M1 through M4c, ~60 retros deep). This isn't a bug report for one crash — it's a pattern report: things that recurred enough times across the project's history to be worth fixing at the tool level rather than re-discovering per-session.

Everything below is sourced from `g-docs/retros/*.md`, `g-docs/patterns-deferred.md`, and one flagship incident from this session that cost "more than half a day" and is the reason this report exists.

---

## TL;DR

1. **The dominant recurring failure across the whole project: a fix pass, correcting a reviewer's cited finding, introduces a new small inaccuracy nearby.** 20+ occurrences across the corpus, self-flagged as "needs `/g-patterns`" at least 4 times before anyone actually ran it. One milestone this session needed **10 review rounds** just to get past the pre-commit gate, then **~11 more** to close out its own retro. The fix that finally worked wasn't "review harder" — it was structural: stop repeating a volatile fact in prose, consolidate it into one place everything else points to.
2. `/g-plan`'s Step 3c budget formula prices implementation cost but not review-chain cost, which has repeatedly run 3–10x the implementation estimate and driven unnecessary milestone fragmentation.
3. A class of test — "guard/negative assertion passes whether or not the guard exists" — recurred 5+ times with an existing mitigation that isn't mechanically enforced.
4. The observer journal (`.claude/journal/`) missed this entire session's work outright, and separately has a long-standing data-quality gap in agent-dispatch entries.
5. `/g-resume` trusts the ROADMAP handoff without cross-checking the active plan's own progress record, which has twice caused a fresh session to under-estimate completed work.
6. Smaller items: a cwd-drift bug that misroutes file writes in nested-directory projects, and inconsistent sentinel-write denials from the environment's safety classifier.

---

## 1. The big one: "a fix introduces a new inaccuracy inside its own correction"

### The corpus evidence

This is the single most expensive recurring pattern in the project's history — 20+ retro sources, spanning M3d through this session, including at least one milestone (M4b-4a-3) that hit **6 consecutive rounds** of it and triggered G-Forge's own Three-Strikes escalation (`G-RULES §A8`). It was flagged as "worth a `/g-patterns` pass" in at least 4 separate retros over the course of the project and never actually run until this session, triggered directly by the incident below.

### The flagship incident, in numbers

One milestone (M4c-3, a fixture + verification gate for a token-singleton claim) went through:

- **7 `code-lead` review rounds** before reaching MERGE READY. Round 1 found the only genuine *code* defect. Rounds 2 through 6 were each a fix pass correcting the previous round's cited finding while introducing a new small inaccuracy nearby — a Minor count restated wrong in a second location, a line-length figure a same-pass code change had already invalidated, a stale forward-looking claim, an over-broad invariant statement.
- **3 more rounds** of `/g-doc-review` on the same commit.
- After round 5's HOLD (4 consecutive rounds of the identical defect class), we escalated to the developer per Three-Strikes rather than continuing to patch — the developer chose a full structural rewrite over a 6th incremental fix.
- That rewrite (see below) worked — it took only 2 more rounds to reach MERGE READY.
- Then the **close-out commit** — writing the retro, reconciling the forecast, refreshing the handoff, and landing two rule edits derived from this very incident — needed **5 more `/g-doc-review` rounds** and **4 more `/g-review` rounds**, because the retro describing the pattern kept exhibiting the pattern while describing it. One round caught a self-contradiction where "Worked well" said an intervention succeeded and "Avoid / do differently" — three lines below, same file — said it didn't. Another round caught a citation to a write-up file that was never written. Another caught a plain `git add` silently re-sweeping unrelated pre-existing changes into a commit after they'd been deliberately isolated out via `git add -p` — a real scope-drift mistake, not just a wording nit.

Total: on the order of **20 separate review-agent dispatches** to land one milestone's code and its own closing documentation.

### What actually stopped it (this is the useful part)

The existing mitigation — `G-RULES §A3`'s "a fix pass is never self-evidently safe, dispatch one more independent check" — was already in force and was *followed* every round. It still didn't work, because "re-check" is a vigilance instruction: a reviewer re-reading a paragraph tends to re-verify the sentence that was cited and skim its neighbors. Two structural changes, not more vigilance, are what actually broke the loop:

1. **Grep the literal fact, don't re-read the prose.** Instead of "re-check the fix," the working version of the rule is: extract the specific fact being corrected (a number, a count, a line range, an ordinal, a forward-looking claim like "next"/"pending") and grep the *whole file* for every other occurrence of it — not just near the cited line.
2. **Collapse repeated facts into one source of truth once a document hits its 3rd+ round on the same finding class.** The milestone's review-chain narrative had accreted into four separate "Review round N" prose sections, each restating the same handful of facts in slightly different words. Rewriting that into one table plus a single current-state paragraph — with every other sentence pointing at the table instead of restating it — is what took the loop from 4 unresolved rounds to 2 more and done.
3. **For a fact describing a process still in flight (e.g. "how many rounds has this review taken so far," "how many commits ahead of origin"), no specific number is ever stable — delete it.** Several rounds went in circles trying to keep a round-count or commit-count current inside a document that was itself part of the process being counted. The number was stale the moment it was read. The fix that actually held was replacing the number with a monotone, pointer-based claim ("recurred again, repeatedly — see the authoritative table for the current count") rather than continuing to chase a moving target.

### Suggested action for G-Forge

- Bake the grep-sweep step directly into `/g-review` and `/g-doc-review`'s own instructions as a required step before accepting a fix as closing a finding — not just a project-level `G-RULES.md` bullet a session has to remember to apply. Right now this depends on the rule being present in the specific project's rule files; it would be more robust as part of the skill itself.
- Consider a "volatile fact" heuristic baked into `doc-reviewer`'s own checklist: any claim about round counts, commit-ahead counts, or "rounds so far" inside a document under active review is a smell — prefer pointer language over a hardcoded number, by default.
- The "consolidate once you hit round 3 on the same finding class" trigger could plausibly be a mechanical checkpoint `/g-review`/`/g-doc-review` surfaces automatically ("this is round 3 on this finding class — consider consolidating instead of patching") rather than something a reviewer has to notice and recommend organically.

---

## 2. `/g-plan`'s Step 3c budget formula doesn't price review-chain cost

The formula (`base + waves×3 + agents×2 + tasks×1`) estimates implementation cost only. Across the corpus, the review chain that follows implementation has repeatedly cost 3–10x more than the waves it gates — one milestone's review chain alone ran ~15 cumulative rounds for what the formula estimated as a handful of exchanges. This under-pricing has a second-order effect: because splitting a milestone shrinks the *estimated* cost but not the *actual* review-chain cost (which scales with code touched, not wave count), the project repeatedly split milestones for budget reasons that didn't help — one lineage re-split 3 levels deep (10+ sub-milestones from one original unit), each split citing the identical diagnosis without ever asking whether splitting was the right lever.

We landed a local patch (`estimated = base + waves×3 + agents×2 + tasks×1 + 20` — a flat review-chain tax — plus a split-depth cap: once a milestone ID already carries a split suffix, "split further" is no longer offered as an option). This felt like working around a gap in the shipped tool rather than a project-specific tuning choice — the review-chain-dominates-cost pattern doesn't seem `keyline`-specific.

---

## 3. Vacuous / inert guard-test assertions

A "disabled X does nothing" or "guard prevents Y" test that passes regardless of whether the guard exists, because the test framework or DOM platform short-circuits the interaction before the component's own code runs. Recurred 5+ times across the corpus, including one case where the *replacement* for a caught inert assertion was itself still inert and needed a second independent review to catch.

The mitigation (temporarily delete the guard, confirm the test goes red, restore it) works every time it's applied — the problem is it lives only in reviewer memory, so it has to be rediscovered each time. We just landed a project-level convention requiring the check be recorded as a one-line in-file comment (`// falsifiability: guard deleted, test confirmed red, restored — <date>`) directly above the assertion, so a missing comment is itself a visible gap rather than something a reviewer has to remember to ask about. This seems like a genuinely reusable pattern for any G-Forge project with a test suite — might be worth a first-class rule rather than something each project reinvents.

---

## 4. Observer journal gaps

Two distinct issues, different severity:

- **This entire session produced zero journal entries** despite extensive `Bash` tool use (`.claude/journal/` stops at the end of the *previous* session, before this session's work even started). Confirmed live: I ran a real Bash command mid-session and checked immediately after — no journal file appeared. The `PostToolUse` hook is correctly registered in `.claude/settings.json`; something downstream of that is silently not firing or not writing. I could not fully root-cause this from inside the session (would need harness-level visibility into whether the hook actually executes). There's a live suspect — this session's shell cwd was observed drifting to a subdirectory (`fixtures/nuxt-ssr`) after nearly every Bash tool call, a separately-confirmed bug that also caused at least one agent to write memory files to the wrong `.claude/` directory — but I verified the journal-writing hook's own directory-resolution logic is structurally robust to that drift (it falls back to `git rev-parse --git-common-dir`, which resolves correctly regardless of cwd), so the correlation is circumstantial, not proven.
- **Long-standing, lower-severity:** the journal's `agent`-kind entries carry no task name or agent-type detail (~10 retro sources over the project's history) — every dispatch shows up as an undifferentiated start/stop pair, which makes `/g-retro` synthesis unable to reconstruct which review round produced which finding without manually cross-referencing commit messages. Previously investigated: the extraction cascade in `agent-lifecycle.sh` already has the fallback logic a prior fix proposal assumed was missing — so either the harness doesn't pass a name field to this hook at all, or something else upstream is the actual gap.

---

## 5. `/g-resume` doesn't freshness-check the active plan against the handoff

Twice (two different milestones, different sessions), a prior session's already-completed work (waves finished, tasks closed) wasn't reflected in the `## Active Session` handoff a fresh session inherited — the gap was only caught by the fresh session's own independent verification, not by `/g-resume` itself. `/g-resume`'s Step 2 currently trusts the handoff as the source of truth; it would be more robust if it also read the named milestone's `g-docs/plans/<slug>.md` Progress table directly and surfaced a discrepancy if the two disagree.

---

## 6. Smaller / isolated items

- **cwd drift misrouting writes in nested-directory projects.** Confirmed again this session — agent-memory files got written to `fixtures/nuxt-ssr/.claude/agent-memory/` instead of the project root `.claude/agent-memory/`, matching a pattern already seen once before in this project's history. Worth a look at whatever causes the working directory to drift after Bash tool calls in this kind of workspace-with-nested-package-directories shape.
- **Commit-gate sentinel writes (`.claude/g-forge-approved` etc.) occasionally denied by the environment's own safety classifier**, inconsistently, across at least 3 sessions and 6 denials, with no reliable workaround ever found (not even switching from `Bash echo` to the `Write` tool held up consistently). This is likely more a host-environment classifier issue than a G-Forge issue directly, but it's a real, recurring block on a designed-in G-Forge workflow step (writing the sentinel is literally what `/g-review`/`/g-doc-review` are supposed to do at Step 6), so it seemed worth flagging rather than silently working around it project-by-project.
- **Stale `file:line` citations in docs describing a file still under active edit.** Partially mitigated by a "prefer symbol-name citations" convention, but the convention isn't self-enforcing — it was violated again this very session (twice) before being reapplied. Nothing currently greps for a new `file:line` citation landing in a doc that also touches the cited file in the same diff.

---

## What's already been handled locally, in case any of it's useful upstream

- Two rule edits landed in this project's `G-RULES.md` as a direct result of this session's incident: the grep-sweep + consolidate-on-3rd-round rule (item 1 above), and the in-file falsifiability comment (item 3 above).
- The Step 3c review-chain tax + split-depth cap (item 2).
- All of the above are recorded with full evidence trails in `g-docs/patterns-deferred.md` and `g-docs/retros/` if you want the raw material rather than this summary.
