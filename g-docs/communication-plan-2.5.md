# Communication Plan — G-Forge 2.5 (final feature release)

> **Status:** **DRAFT — copy approved 2026-07-28, scope not yet recorded.** Publish at 2.5.0 release, not before.
> **Owner:** HQ. Changes to the copy below are a developer decision, not an editing pass.
> **Anchors:** [ADR-010](decisions/010-full-rebuild-on-current-platform.md) (rebuild + version identity: G-Proof ships as 1.0, there is no G-Forge 3.0).
>
> ⚠ **Read §7 before using this file.** The 2.5 scope described in §3c was agreed in session on 2026-07-28 and is **not yet in `ROADMAP.md`**, which still assigns four of those items to v2.6.0–v2.15.0 and records "only M41" as the v2.5 candidate. The roadmap re-scope pass closes that gap. Until it runs, this document states intent, not record.

---

## 1. What this plan says

G-Forge 2.5 is the **last feature release**. From there the project is maintenance-only, deliberately, so the developer can build its successor (**G-Proof**) on a stable base while continuing to run G-Forge on four other live projects.

Three things must land together or the message reads wrong:

1. **The freeze is a choice, not a wind-down.** The reason is honest and specific: the intended direction needs a rework deep enough that stable releases and predictable maintenance could not be promised while it was underway.
2. **Maintenance is a real commitment**, backed by a real reason (the developer depends on it daily) and a real channel (`/g-report`).
3. **G-Proof is tangible but unpromised.** Three named directions, an explicit "there's more I'm not describing", no date, no feature list.

**The freeze paragraph does not justify itself.** The "What's next" block does. Publish them adjacent, in that order.

---

## 2. Audience

| Audience | Cares about | Reads |
|---|---|---|
| Existing users (few, dogfooding) | Am I stranded? Do my bugs get fixed? | README freeze + maintenance commitment, `/g-report` |
| Prospective users | Is it worth adopting something frozen? | "What's in 2.5" concrete list, maintenance commitment |
| The developer, later | Why was this decided this way | This file + ADR-010 |

Nobody in this set wants marketing. Plain, specific, no hype.

---

## 3. Approved copy

Lift verbatim. Sub-headings are part of the copy.

### 3a — The freeze (README, announcement)

> **G-Forge 2.5 is the last feature release.** From here it's maintenance, and that's deliberate.
>
> Where I want to take this next needs a rework deep enough that I couldn't honestly promise stable releases or predictable maintenance while it was underway. Quietly destabilising something people rely on is worse than drawing a clean line, so this is the line.
>
> Frozen isn't abandoned. I run G-Forge on four other projects, so its bugs are my bugs and they'll keep getting fixed. That's what `/g-report` is for: when something breaks or gets in your way, it writes a scrubbed report you can send me. Reasonable feature feedback travels the same route.
>
> And 2.5 is the version I'll build the next thing with. That's the real reason for freezing it. You want something stable under your feet while you're building its successor.

### 3b — What's next (README, immediately after 3a)

> Three things G-Forge kept running into and can't reach from where it stands.
>
> **Knowing how much something matters.** Every part of the system currently judges importance on its own, mostly by feel. Priority, severity, impact and relevance should be one shared idea the whole system reasons with.
>
> **Memory that behaves like memory.** Today the record is a well-organised pile of documents. It should be something a session can walk and follow, pulling exactly the slice the task needs.
>
> **More than one of you.** One project, several people or several sessions, working at once without silently colliding.
>
> Each of those is a layer that has to run through everything the system does, and you don't retrofit that. That's the rebuild, and it's called G-Proof. There's more to it than these three, and it isn't ready to be described. No date.

### 3c — What's in 2.5 (release notes, CHANGELOG intro)

> **Lighter where you feel it most.** The review gate runs before every commit, and today it's one enormous pass that costs a fortune and starts losing the thread by the time it reaches the last thing it checks. 2.5 splits it into small parallel passes with a cheap assembly step at the end. Same verdict, a fraction of the cost, and it stops going vague on long reviews.
>
> **Planning that doesn't invent work.** Task breakdown currently splits jobs that belong together and hands each fragment to its own agent. 2.5 fixes the sizing, so you stop paying for coordination you never needed.
>
> **Every setting in one place you can see.** `/g-settings` lists every variable that governs G-Forge's behaviour: what it's set to, what writes it, and what it changes. Safe edits go through it. No more hidden files quietly deciding how your sessions run.
>
> **A way to tell me when it breaks.** `/g-report` fires when something actually goes wrong, or whenever you call it. It asks what you want to report, writes it against an incident template, scrubs your project's specifics out, and hands you a file to send. Bugs and reasonable feature requests travel the same route.
>
> **Gates that stop misfiring.** A passing review could fail to unlock the commit gate on some machines, which reads as G-Forge being broken. Committed reference material a project builds against was getting blocked as though G-Forge owned it. Both fixed. Plan-time risk percentages get recalibrated too, because a number you've learned to ignore is worse than no number at all.
>
> **Documentation that can't quietly rot.** The health check now flags anything in your CLAUDE.md that's a hand-typed fact rather than one sourced from a file. That's how those facts go stale without anyone noticing.
>
> **Releases in one step.** Cutting a release stops being a manual walk through several files that has to be remembered correctly every time.

---

## 4. Placement

| Surface | Carries | Note |
|---|---|---|
| `README.md` | 3a then 3b, adjacent and in that order | 3b is what makes 3a land |
| `CHANGELOG.md` under `## [2.5.0]` | 3c, then the itemised entries | Keep-a-Changelog format below the prose |
| Release announcement (wherever it goes) | 3a + 3c, 3b condensed to its closing paragraph | |
| `.claude-plugin/marketplace.json` description | Neither. One line, unchanged in tone | Not a place for the freeze story |

Publish nothing before 2.5.0 ships. A freeze announced ahead of the release that justifies it reads as abandonment.

---

## 5. Boundaries — what this plan does not say

- **No date for G-Proof.** Not "soon", not "next year", not "after 2.5". None.
- **No G-Proof feature list.** The three directions in 3b are hints. Everything else stays undescribed, and 3b says so explicitly. Do not extend the list because a fourth item seems safe.
- **No claim about how G-Proof gets built.** Whether the dogfooding pattern repeats is undecided. It is not mentioned publicly either way.
- **No G-Forge 3.0, ever.** Per ADR-010 the 2.x line simply ends and versioning **restarts** under the new name: a first release of a differently-named product does not inherit the predecessor's major. A 3.0 here would make the successor's 1.0 read as a downgrade.
- **No promise of feature work after 2.5.** Maintenance means fixes. `/g-report` accepts feature feedback; accepting it is not committing to it.
- **No apology framing.** The freeze is a decision with a reason, delivered once, not hedged or revisited.

---

## 6. Why the message is shaped this way

Two failure modes drove the wording.

**"Frozen" reads as "dead" unless maintenance is concrete.** Abstract reassurance does not survive contact with a user deciding whether to adopt. The specifics carry it: four live projects, so the bugs are the developer's own, and a named channel that ships in the same release.

**A freeze with no visible successor reads as giving up.** Hence 3b sitting directly under 3a. The three directions are chosen to be individually understandable and to make the same point in three ways: each is a layer that runs through everything, which is precisely what a rework of the current body cannot deliver. That argument justifies the freeze better than the freeze paragraph does.

The 2.5 feature copy is deliberately concrete rather than thematic. An earlier draft summarised the release as "costs less, lies less, reports its own failures" — true, and useless to someone deciding whether to upgrade. Every item in 3c names the thing that was wrong and what changes.

---

## 7. Record status and open decisions

This file was gated by `/g-doc-review` on 2026-07-28: **DOCS HOLD, 3 blocking · 8 warning**. The blocking three all reduce to one cause — the 2.5 scope lives in session context, not in the committed record — and all three close when the roadmap re-scope pass runs. The copy itself was not the problem; §3b's three G-Proof directions, the ADR-010 freeze premise, and five of §3c's seven items all verified clean against the repo.

The arithmetic below is coincidental, not a mapping: of the eight warnings returned, one (the "reserves the next major" mechanism error) was **fixed in place** rather than carried, and the §2-vs-§4 mismatch was split out of the §4 finding into a row of its own. Eight returned, eight open, different eights.

**Closed by the roadmap re-scope pass (blocking until then):**

1. **§3c scope vs `ROADMAP.md`.** The roadmap assigns M45 → v2.6.0, M38 → v2.12.0, M40 → v2.14.0, M43 → v2.15.0, and carries no record of task-decomposer optimization at all; `ROADMAP.md:750` (M44 supersession stamp), `ROADMAP.md:799` (Version Plan) and `project_brief.md:68` all still read "only M41" for v2.5. Record the agreed scope and sequence there, then re-gate this file.
2. **M38 redesign unrecorded.** §3c's `/g-report` copy describes hook-triggering and a report-type menu, neither of which is in the recorded M38 scope. **Also reconcile delivery:** the approved copy says "hands you a file to send" while the redesign was briefed as delivery via git. One of the two is wrong and the record decides which.
3. **No inbound reference.** Nothing pointed at this file when it was written. The `## Active Session` handoff now does; the roadmap 2.5 entry and a precondition line in `g-docs/milestones/M41.md` should too, so the session that cuts the release actually finds it.

**Developer decisions, carried open:**

- **"Four other projects" (§3a).** The repo cannot arbitrate the count, and one enumerable candidate (`alveria`) is recorded as a third-party adopter's fork rather than a project the developer runs. The sentence is load-bearing for the maintenance commitment, so the number should be one the developer can stand behind.
- **Freeze cause set (§1).** `ADR-010:41` records three causes the announcement should be honest about — drift from platform capability, genuine overlap, real improvement opportunity. The approved copy carries the third only. Either restore the set or record the narrowing here as deliberate.
- **Announcement block order (§4).** The announcement row orders 3a + 3c then 3b, which breaks the adjacency rule §1 and §6 both call load-bearing; and "3b condensed to its closing paragraph" leaves "Each of those is a layer…" without an antecedent. Needs either a standalone form of that paragraph or a different order.
- **§2 vs §4.** §2 tells prospective users they read the "What's in 2.5" list, but §4 never places 3c on the README.

**Re-verify at publish time (claims that outrun their evidence today):**

- **"Same verdict, a fraction of the cost" (§3c).** M45 treats verdict-equivalence as unproven and keeps the monolith as fallback until an A/B proves it. If the fallback is still live at release, this sentence asserts a property the milestone has not returned.
- **"Risk percentages get recalibrated" (§3c).** The recorded field report offers two fixes: a cheap relabel that changes no number, and genuine calibration from ground truth. Only the second earns the word "recalibrated".
- **Check 24 description (§3c).** Accurate for BARE-PROSE, imprecise for DECLARED-LOCAL: content inside a local-only block is hand-typed and not file-sourced, and is counted rather than flagged.
- **§3b vs R0 (§5).** ADR-010 authorizes R0 only and states no rebuild roadmap is published with it. Three named directions are the closest this plan comes to the public commitment the ADR exists to avoid; the "no date, not ready to describe" hedges are what keep it on the right side.
