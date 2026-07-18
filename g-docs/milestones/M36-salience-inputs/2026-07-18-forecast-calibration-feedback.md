# Field report — forecast & budget numbers read high/static, get ignored (2026-07-18)

**Source:** developer (hllrm), live during the W1.5c approval gate on this repo. Logged via intake at developer request. Companion input to the 2026-07-06 severity-calibration report — same underlying gap.

## The two observations

1. **`/g-forecast` miss-risk has never read below 50%.** Verified against the corpus at report time: all 8 forecasts on record are 55–90%, all tagged Elevated/High — while ~7 of those plans shipped successfully, most in-session (observed plan-miss rate ≈ 0). The developer has rationally started ignoring the number: a metric that always says "elevated" and is always survived carries no information. Root causes identified: (a) the top-3-scenarios term saturates on any healthy retro corpus (~27–40 points before complexity enters — richer history ⇒ scarier forecasts, punishing exactly the record-keeping G-Forge enforces); (b) no mitigation credit — folding a scenario's mitigation into the plan as an explicit task does not lower its score, so engaging with the premortem never moves the number; (c) label/measure mismatch — the formula predicts "≥1 premortem scenario fires" (empirically accurate: W1.4, W1.5a, W1.5b all had predicted scenarios fire and be caught) but the label claims "plan misses its target" (empirically ~never).

2. **`/g-plan`'s context-budget check is a static snapshot in a proxy unit.** "Remaining ≈ 40 − `.claude/session-prompt-count`" is computed once at plan time, counts *exchanges* rather than consulting live `/context` token capacity, and is never re-estimated as waves actually burn context. A session at exchange depth 2 can already be token-heavy. Only `/g-execute`'s wave-boundary §A7 check looks at real capacity — and it is a backstop, not an estimate.

**Shared root cause:** self-governance numbers that are heuristic point estimates never reconciled against observable ground truth (live `/context`, the forecast Outcome tables) — in a tool whose brief says "quality measured, not asserted."

## The developer's design direction (verbatim intent)

> "What do we want from a premortem? **Information, not paranoia.** The risk assessment should be on the **change**, and complexity valued on the **number of files to change, not project complexity**. The salience layer should probably fill a gap in that sense."

Interpretation: a premortem's job is to tell you *what specifically is likely to bite on this change and what to do about it* — the ranked scenarios + mitigations are the product; the aggregate percentage is at best a headline and at worst noise. Risk should be scoped to the change surface (files touched, their volatility, their blast radius), not inflated by the project's accumulated history of unrelated failure modes. **Salience relevance (M36/M37):** scenario-matching is precisely a salience problem — which past failures are *salient to this diff* — and the current grep-the-whole-corpus approach is the crude stand-in a salience layer would replace. This makes forecast scenario-selection a candidate consumer of the M36 salience mechanism, alongside the severity-calibration case already on file.

## Improvement candidates (increasing effort)

1. **Split/rename** — report "scenario-fire likelihood" (current formula, empirically validated) separately from "plan-miss risk"; stop attaching the alarming word to the always-high number. One-file SKILL.md edit; pull-forward eligible as a patch.
2. **Mitigation credit** — a scenario whose mitigation is an explicit plan task/done-condition scores reduced (e.g. ×0.5); the premortem then visibly rewards being acted on.
3. **Change-scoped complexity** — weight the file-count/blast-radius of the *diff* (what `/g-blast-radius` already computes) over corpus-wide scenario matching; salience layer (M36/M37) as the eventual scenario-selection mechanism.
4. **Calibrate from ground truth** — fit the formula constants to the 7+ closed forecast Outcome tables (actual fire-rate vs. miss-rate); replace the exchange-count budget with a `/context`-anchored estimate re-checked at wave boundaries. Natural first customer for the M38 (G-Report) → M39 (G-tweak) self-improvement track.

## Placement

- Primary: **M38/M39** (self-improvement track) — calibration-from-history is their charter.
- Input to: **M36** (salience approach/ADR) — scenario-selection as a salience consumer.
- Pull-forward candidate: item 1 (rename/split) as a cheap patch any time.
