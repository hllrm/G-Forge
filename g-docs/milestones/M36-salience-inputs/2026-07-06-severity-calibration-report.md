# Severity Calibration Report — "Everything is DEFCON 1"

**Date:** 2026-07-06
**Trigger:** Developer observation: *"the system at this moment treats EVERYTHING as defcon 1."*
**Scope examined:** All 21 forecasts (premortems) in `g-docs/forecasts/`, all 35 retros, all 55 code-lead review documents, the pattern corpus (`g-docs/patterns-deferred.md`), the telemetry system (`g-docs/telemetry-metrics.md`, `g-docs/telemetry/2026-07-05.md`, `.claude/review-holds`), the checkpoint hook, and `ROADMAP.md` — with particular focus on the docs-translation arc (M11a-2 / M11a-3 / M11a-4b) as requested.

---

## Verdict

**The observation is correct, and it is measurable.** The detection layers (review, Tier 3, premortem gates) genuinely work — they have caught real bugs. What is broken is **severity calibration**: risk numbers are compressed into a single high band regardless of task size, alarms never stand down after resolution, review depth scales *inversely* with change size, and two telemetry metrics warn permanently about the framework's own designed behavior. The system has a ratchet up and no ratchet down.

---

## 1. The numbers

### 1a. Forecast miss-risk is a compressed high band with no dynamic range

All 21 forecasts ever produced:

| Milestone | Predicted miss-risk | Band |
|---|---|---|
| M11a-4c — read-only final lint gate | **37%** (corpus floor) | Moderate |
| M11a-2d — translate 3 markdown pages | 40% | Moderate |
| M11a-4a — Foundations page authoring | 45% | Moderate |
| M11a-2c — translate 3 markdown pages | 50% | Moderate |
| M11a-4b — translate 170 label fields | 50% | Moderate |
| M11b-1, M11b-3a | 50% | Moderate |
| fix-composer-ux | 55% | Elevated |
| M12-1, M12-3, M11b-4, M11b-3b, M13-1 | 60% | Elevated |
| M10, M11a-3, M13-2, M12-4 | 65% | Elevated |
| M12-2, **M13-3 — new interactive SVG canvas** | 70% | Elevated |
| **M11a-2e — translate 3 philosophy pages**, M11b-2 | **75%** (corpus max) | Elevated |

- **Floor 37%, ceiling 75%, mean 58%.** Nothing has *ever* been forecast below 37%.
- **14 of 21 (two-thirds) are "Elevated."** When two-thirds of all work is "Elevated risk," the label carries no information.
- **The scale cannot tell work types apart:** translating 3 markdown pages (M11a-2e, complexity 5/10) scored *higher* (75%) than building the project's first interactive drag-and-drop SVG canvas (M13-3, complexity 4/10 → 70%). A read-only lint gate scored 37%.
- **Actual outcome across all 21:** zero milestones missed, zero rollbacks, every review chain ended MERGE READY. Predicted ~58% average "miss-risk" vs. an observed milestone failure rate of 0%.

### 1b. Premortem scenarios: ~2/3 never happen; the ones that do are mostly the framework's own friction

Reconciled Outcome tables across the forecast corpus: **~43 "did not happen" rows vs. ~22 "happened" rows.** Of the ~22 that happened, nearly all are process friction, not product failure:

- QA-report-scope-mismatch — happened 5 consecutive times, impact trivial, mitigation "no process change needed" (yet re-scored and re-mitigated in every subsequent forecast)
- amber-context-at-review-handoff — 4+ occurrences (session management, not the work)
- agent-stall-needs-SendMessage-resume — several (dispatch mechanics)
- stale-handoff-at-resume — 3 occurrences, auto-caught 3/3 by the existing mitigation

Genuine product-risk scenarios that materialized: **~2 out of ~65 predicted** (the M11a-2e anchor-syntax catch being the standout — see §3).

### 1c. Reviews: 4 HOLDs in 55 review documents, all resolved same-day — yet the alarm never clears

- **55 code-lead review documents** produced since 2026-06-29 (~8 days). **4 HOLDs total (~7%)**: M11a-2a (translation broke heading auto-slug anchors — genuine, 3 Major), M11b-1 fix round ([code-lead-2026-07-04-fix-3.md](g-docs/agent-output/review/code-lead-2026-07-04-fix-3.md)), M11a close-swarm (2 hallucinations in the wiki architecture page — genuine), M12-3 (schema invariant + placeholder). **All four fixed and re-reviewed to MERGE READY the same day.**
- Yet `workflow-checkpoint.sh:169-182` prints **`Health: ⚠ 4 holds` on every single prompt, today and forever** — `.claude/review-holds` is an all-time counter with no decay and no notion of "resolved."
- The corpus also contains reviews of paperwork about paperwork: [code-lead-2026-07-02-retro3-forecast-reconciliation.md](g-docs/agent-output/review/code-lead-2026-07-02-retro3-forecast-reconciliation.md) is a full code-lead dispatch verifying that a retro's forecast-outcome tables were factually accurate. Its one finding: a Minor — a note said "11 passing pages" where the arithmetic implied 12.

### 1d. Review depth scales inversely with change size (M13-3, current milestone)

- Process artifacts for M13-3 so far: **6,477 words** (plan 305 + forecast 472 + 3 wave reports 2,347 + 2 reviews 2,482 + planning retro 871 — excluding handoff/todo/qa-scope edits and the still-unwritten execution retro).
- Delivered code: **291 insertions, 1 deletion.**
- The round-2 review ([code-lead-2026-07-06-m13-3-round2.md](g-docs/agent-output/review/code-lead-2026-07-06-m13-3-round2.md)) spent **1,376 words on a one-line CSS fix** (`overflow-y: auto`) — including a five-paragraph mechanism analysis weighing it against z-index, `overflow: hidden`, and flex-basis alternatives. That is 25% *more* words than round 1 spent reviewing the other 290 lines.

### 1e. The translation arc specifically (the requested case study)

M11a-2 — translating **15 markdown pages** IT→EN — was split into **6 sub-milestones** because `/g-plan` estimated the full ceremony at ~77 exchanges, exceeding a session's context budget. Each 3-page batch then received: its own plan, its own 4–5-scenario premortem, wave dispatch reports, a code-lead review (M11a-2a took **three rounds**), a Tier 3 smoke round, a retro, and a forecast-outcome reconciliation — which itself was then code-lead-reviewed (§1c).

The single sharpest fact in the whole record: the pattern corpus's top systemic entry (`context-boundary-at-review-tier3-handoff`, weight 7) says a full plan→execute→review cycle "reliably consumes almost an entire session's context budget." **The system's own #1 recorded risk is the cost of the system itself** — and that risk is then fed back into every forecast as the top scenario, raising every risk score, justifying more ceremony.

---

## 2. Root causes — four ratchets, no decay

**R1 — Append-only pattern corpus seeds every premortem.** `g-docs/patterns-deferred.md` weights only ever grow (context-boundary is at 7). It alone injects a likelihood-5 × impact-4 = 20 scenario into every new forecast — which is why M13-3, complexity 4/10, carries 70%. Nothing retires a pattern.

**R2 — "Miss-risk" conflates "some scenario will occur" with "the milestone will miss."** Two of M13-3's four scored scenarios aren't events at all: *"no /context tool exists"* is a permanent environmental fact (predicting it "yes" is a tautology), and *"session is already amber"* was a known present-state fact at plan time. Constants scored as risks inflate every forecast by a fixed amount. Worse, the headline number doesn't respond to mitigation: M13-3's 70% was "driven almost entirely by scenario 1," the mitigation (execute in a fresh session) was accepted on the spot — and the number stayed 70%.

**R3 — The hold counter is deadlocked by design.** Per [telemetry-metrics.md](g-docs/telemetry-metrics.md): `.claude/review-holds` increments on every HOLD (unconditional) and resets **only** when the profile derives `stable`. But the counter itself feeds rework-rate (+4), which keeps rework ⚠, which keeps warn_ratio > 0, which blocks `stable`, which blocks the reset. The 4 long-resolved holds are permanent: permanent ⚠ banner, permanent extra reviewer.

**R4 — Two telemetry metrics warn about the framework's own designed behavior, and the snapshots admit it.** The [2026-07-05 snapshot](g-docs/telemetry/2026-07-05.md):
- *Rework rate 40% ⚠* = (13 fix-after-feat commits + 4 holds) / 43 feat commits. The snapshot's own caveat: *"much of this signal is code-lead re-review cycles after fixing HOLD findings (the commit-gate discipline working as designed), not implementation quality decay."* Tier-3 fix rounds are **mandated** by the process; the metric then reads each mandated fix commit as decay. The same caveat appears in the 2026-06-30 retro ("benign-inflated by the normal G-Forge review-then-fix-in-branch flow"). **Diagnosed twice, never fixed.**
- *Token efficiency 38 ⚠* penalizes commits averaging >360 changed lines — but milestone-close commits bundle the ceremony's own g-docs artifacts (retros, forecasts, review reports), so **the paperwork inflates the metric that prescribes more paperwork.**
- Consequence: profile `cautious` at the *exact inclusive boundary* (2/8 = 0.25) → extra reviewer on every review. At M11b's close it briefly derived `defensive`, and M12-1 was dispatched at Opus tier with strict-scope clauses — model escalation driven by structurally-stuck metrics.
- Cost datapoint: M12-4's `/g-patterns` close-swarm dispatch burned **~360k tokens across 2 failed attempts with zero deliverable** (ROADMAP Backlog). M13-3's entire implementation was budgeted at 15–44k. The meta-analysis cost ~10× the feature.

---

## 3. What the ceremony has actually earned (fairness section)

The complaint is *not* that the checks are useless. Confirmed genuine catches:

- **M11a-2a HOLD (translation):** heading translation broke Nuxt auto-slug fragment links — 3 Major, exactly the class of bug a translation review should catch.
- **M11a-2e premortem scenario 1 (translation):** predicted that `{#funzionale-oop}` custom-anchor syntax might not render; the premortem-inserted verification gate confirmed it was inert markdown *before* 5 backlinks were rewritten against it. **This is the one premortem in the corpus that demonstrably paid for itself.**
- **M11a close-swarm HOLD:** the cautious-profile stricter pass caught 2 hallucinated components in the wiki architecture page on a docs-only diff "most reviewers would wave through."
- **M12-3 HOLD:** node id/key schema invariant.
- **M10 pre-review:** 6× invalid `rgb(var(--…))` CSS caught before merge.
- **M13-3 Tier 3:** the overflow-behind-QA-panel bug — found by the human smoke test exactly as the tiered protocol intends.

Detection works. Calibration doesn't: the same alarm level dresses a 3-page translation, a 1-line CSS fix, and a novel canvas component.

---

## 4. Recommendations (small, targeted; mostly G-Forge plugin/rule changes → upstream channel, same as the two items already flagged in patterns-deferred.md)

1. **Reset `.claude/review-holds` at each milestone close** (add to the close swarm), or split the display into `open holds` vs `resolved holds` in `workflow-checkpoint.sh`. A hold that ended in same-day MERGE READY is not health-relevant three milestones later. This also breaks the R3 deadlock without touching the stable-reset rule.
2. **Fix the rework metric to measure rework:** count only `fix:` commits landing *after* a merge (post-merge defects), not in-branch pre-merge fix rounds the process itself mandates. Promote the snapshot's own twice-written caveat into the formula.
3. **Exclude `g-docs/**` from the token-efficiency diff-size input** so ceremony artifacts stop feeding the metric that prescribes ceremony.
4. **Premortem hygiene:**
   a. Score only *events*. Environmental constants ("no /context tool") and known present-states ("already amber") move to an unscored "standing constraints" line.
   b. **Retire a scenario after 2 consecutive "did not happen" reconciliations** — the Outcome tables already collect exactly this data (43 no / 22 yes); the loop just never prunes. The stale-sentinel scenario (one papercut on 07-02, formally re-mitigated in 5+ forecasts since, zero recurrences) is the poster child.
   c. **Recompute the headline miss-risk after accepted mitigations.** M13-3 should have read ~20%, not 70%, the moment "execute in a fresh session" was adopted.
5. **Re-band or rename the risk scale** against the observed base rate (0 missed milestones, ~7% HOLD rate). If the floor is 37% and two-thirds of items are "Elevated," either the bands shift or the label becomes "expected process friction" — which is what it actually measures.
6. **Proportional re-review:** after a MERGE READY, scope round-2 to the delta. The byte-identity check in M13-3 round 2 was right and cheap; the 1,376-word essay on one CSS line was not. Cap re-review depth by delta size.
7. **Add decay to pattern weights:** halve at each milestone close without recurrence; below weight 2, a pattern stops seeding premortems (stays in the file as history).

---

## 5. Meta-note

CLAUDE.md states this project exists to test "how G-Forge prevents drift." This report is therefore a first-class test result, not a complaint log: **G-Forge prevents drift effectively, and its detection layers catch real defects — but its severity machinery only escalates and never de-escalates.** Every input to the alarm system (pattern weights, hold counters, premortem corpora, rework signals) is append-only or deadlocked, so perceived risk rises monotonically over the project's life while actual observed risk has stayed near zero. Left as-is, the endpoint is a framework that treats a typo fix and a rewrite identically — which is the state the developer just reported.
