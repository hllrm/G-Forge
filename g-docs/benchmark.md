# G-Forge Reliability Benchmark — "punch above its weight"

**Audience:** maintainer (this is a validation harness, not a per-project skill).
**Purpose:** convert G-Forge's core claim — *discipline lets a given model ship at a higher success and hygiene rate than it would raw* — from an assertion into a measured number. In a market where ~87% of developers distrust agent accuracy (Stack Overflow 2025), a reliability delta is the strongest possible pitch, and G-Forge already ships the instrument to measure it (`/g-telemetry`, the 8-metric layer).

## The claim, stated falsifiably

> **H1 (lift):** The same model, running a task through the full G-Forge process, achieves a higher task-success rate than the same model run raw (plain Claude Code, no plugin), on the same fixed task set.
>
> **H2 (hygiene):** Beyond pass/fail, the G-Forge condition produces materially better *hygiene* — fewer regressions, less rework, higher review-catch — measured by the existing telemetry metrics.
>
> **H3 (above its weight):** A cheaper/smaller model + G-Forge closes a meaningful fraction of the gap to a stronger model run raw — i.e. process substitutes for some of the capability difference.

If a run shows no significant lift on H1/H2, the claim is **wrong for that task class** and the README must not assert it. Report it anyway — a null result on a narrow task class is honest and still informative.

## Design

A within-model A/B (and one cross-model arm), same tasks, blind-scored.

| Arm | Model | Harness | Tests H |
|-----|-------|---------|---------|
| **A** raw-weak | cheaper model (e.g. Sonnet) | plain Claude Code | baseline |
| **B** forge-weak | same cheaper model | full G-Forge (`full` tier) | H1, H2 (vs A) |
| **C** raw-strong | stronger model (e.g. Opus) | plain Claude Code | H3 ceiling (vs B) |
| **D** forge-strong | stronger model | full G-Forge | upper bound |

The headline result is **B vs A** (lift from process, model held constant) and **B vs C** (does forge-weak approach raw-strong — "above its weight").

## Task set

- **N ≥ 20** fixed, pre-registered tasks spanning the work G-Forge targets: a multi-file feature, a bug fix with a failing repro, a refactor under test coverage, and an architecture-touching change (so the review/gate and PM layers actually engage — a one-file tweak won't exercise them).
- Each task ships with a **mechanically checkable done-condition** (tests pass, endpoint returns X, type-checks) so success is scored without judgment.
- Prefer a public harness where possible (SWE-bench-style instances) for external credibility; supplement with internal tasks that exercise the PM/gate path SWE-bench doesn't.
- **Pre-register the task list and scoring before running.** No post-hoc task selection.

## Metrics

**Primary — success rate:** fraction of tasks whose done-condition is met, by arm. This is the H1/H3 headline.

**Hygiene — reuse the `/g-telemetry` 8-metric layer** (don't invent new ones):
- regression frequency · rework rate · spec deviation · review catch rate · hallucination rate · escalation frequency · retry dependency · token efficiency.

**Cost:** total tokens + wall-clock per task per arm. The honest framing is *reliability per dollar*: if B costs 2× A in tokens but lands 2× the success rate with fewer regressions, that's the story — and C (raw-strong) is the cost ceiling B is trying to undercut.

## Controls (or the result is noise)

1. **Same tasks, same order-independent scoring**, both arms.
2. **Blind scoring** — the grader doesn't know which arm produced the diff. Mechanical done-conditions make this easy.
3. **Fixed model versions**, pinned, recorded.
4. **Clean repo per task** — each task starts from the same commit; no cross-task contamination.
5. **G-Forge arm runs the real process** — `/g-plan` → approve → `/g-execute` → `/g-review` gate — not a degenerate "plugin installed but bypassed" run. The gate must actually fire.
6. **n high enough to clear noise** — report per-task results and a simple significance check (even a sign test over 20 tasks beats a vibe).

## Reporting

The deliverable is one chart and one table:

- **Chart:** success rate by arm (A/B/C/D), with the B−A lift and the B-vs-C gap-closure annotated.
- **Table:** the 8 hygiene metrics, A vs B, with deltas.
- **One honest paragraph:** where the lift showed up, where it didn't, and the token cost it bought.

That chart — *"same model, +X% success and −Y% regressions with the gate on"* — is the entire marketing case, and it's defensible precisely because the instrument (telemetry) and the process (the gate) are the product.

## Pilot protocol (run this first — M25 gate)

Cheap, ~3-task dry run to (a) shake out the harness and (b) decide if a full benchmark is worth funding. Do **not** build the full runner before the pilot shows signal.

**Model:** one cheaper model (e.g. Sonnet), held identical across both arms.
**Arms:** A (raw Claude Code, no plugin) and B (G-Forge `full` tier). Skip C/D in the pilot.

**Tasks (pre-register before running):**
1. A **multi-file feature** with a failing-then-passing test (this is where lift should show — the gate + waves engage).
2. A **bug fix** with a provided failing repro (mechanical pass/fail).
3. A **one-line/trivial edit** (the *control* — expect ≈ no lift, possibly negative; this proves you're measuring honestly, not cherry-picking).

Prefer 3 public **SWE-bench Lite** instances so scoring is the instance's own `FAIL_TO_PASS`/`PASS_TO_PASS` test set — zero grader judgment, externally credible.

**Per task, per arm (start each from the same clean commit):**
- **Arm A:** a fresh plain Claude Code session, "fix this / implement this," one pass.
- **Arm B:** a fresh session with G-Forge installed, driven through the *real* process — `/g-init` if needed → `/g-plan` → approve → `/g-execute` → `/g-review` until MERGE READY. **The operator does not hand-hold past the skills** — if a fresh model session can't drive the plugin to green, that's a finding.
- Score = the task's done-condition (SWE-bench tests). Record tokens + wall-clock.

**Read of the pilot:**
- B passes the **multi-file** task where A fails (or B's hygiene metrics are clearly better) → **signal; fund the full n ≥ 20.**
- No difference on the multi-file task → the lift is narrower than hoped; **stop, record it, don't publish a headline.**
- B worse on the **trivial** task → expected (process overhead); it validates the honesty of the measurement and informs `light`-tier guidance.

The pilot is hours and a fresh session or two — not the multi-day full run. It exists so you never build the big harness on a hypothesis the cheap test could have killed.

## Why this should work (prior, not proof)

The mechanism is backed even though G-Forge's specific number isn't measured yet:
- LLMs **cannot reliably self-correct without external feedback** — performance can *degrade* after in-context self-correction (Huang et al., ICLR 2024). G-Forge's external review gate is exactly the external-feedback channel that paper says is required.
- Naive LLM chaining produces **cascading hallucinations / logic inconsistencies** that SOP-style decomposition mitigates (MetaGPT, ICLR 2024); multi-agent failure is a catalogued, empirical phenomenon (MAST, NeurIPS 2025).
- The demand is measured: a **48-point verification gap** between distrust and verification (Sonar 2026).

So the theory predicts a lift. This benchmark is what makes it a number instead of a citation.

## Threats to validity (state them, don't hide them)

- **Task-class dependence** — lift is likely largest on multi-file / architecture-touching work and smallest on trivial edits. Report per-class, never a single blended number that hides this.
- **Process overhead on easy tasks** — on a one-line fix, the gate + waves are pure cost. That's a real finding, not a bug to suppress; it informs the tier guidance (`light` exists for exactly this).
- **Grader leakage / harness familiarity** — mitigated by blind, mechanical scoring and pre-registration.
- **Small n** — 20 tasks is a signal, not a paper. Scale before claiming a headline percentage in marketing.
