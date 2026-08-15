# M25 pilot — result (2026-08-13)

The pilot protocol in [`benchmark.md`](benchmark.md) §"Pilot protocol", executed. This is the
record, including the parts that don't flatter the product.

**Verdict against the pilot gate: do not fund the n ≥ 20 run on this design.** H2 satisfies gate branch 1 (hygiene metrics are clearly better); the override: the benchmark instrument itself is broken. Mechanical scoring requires a pre-registered contract; writing that contract is most of what the planning layer produces. The control arm received the treatment's principal output for free, so any H1 result measures spec quality, not model capability. The gate evaluated on a broken instrument is void — fix the instrument first, then re-run the pilot.

---

## What was run

| | |
|---|---|
| **Model** | `claude-sonnet-5`, pinned, identical across both arms |
| **Arm A** | plain Claude Code; every plugin suppressed via settings override; no CLAUDE.md, no rules, no hooks, no gate |
| **Arm B** | same model; G-Forge loaded from this repo's working tree (`--plugin-dir`, current `main` — ahead of the 2.4.0 marketplace cache); project pre-installed with G-RULES, `.claude/rules`, all 7 hooks, the `python-cli` profile, `g-docs/` skeleton, `full` tier, native `pre-commit` gate verified blocking before launch |
| **Driving** | one prompt per run, `--permission-mode bypassPermissions`, no operator intervention after dispatch |
| **Scoring** | mechanical. Agent source run against pristine originals + a hidden suite it never saw; agent-authored tests excluded from scoring |
| **Pre-registration** | tasks, hidden suites, scoring rule and arm config frozen before execution (round 2 pre-registration details not retained in this record) |

### Deviation from the methodology doc

Three deviations from [`benchmark.md`](benchmark.md):

1. **Task count:** the doc specifies 3 tasks for the pilot (§"Pilot protocol", lines 71–74). This run executed 4: t1 (multi-file feature), t2 (bug fix w/ repro), t3 (trivial control), t4 (hard multi-file feature). The extra task was added to better assess task-class variability in cost.

2. **Task sourcing:** the doc prefers 3 public SWE-bench Lite instances. Not used: no Docker on the run machine, and SWE-bench Lite contains only single-repo bug fixes — it has **no multi-file-feature instances**, which is the one task class the pilot exists to test. Substituted a purpose-built, stdlib-only Python fixture (`ledger`, 4 modules, 17 passing tests at seed) with hidden mechanically-scored suites. **This costs external credibility** and is recorded as a threat to validity, not smoothed over.

3. **Hygiene instrumentation:** the doc mandates the `/g-telemetry` 8-metric layer (§"Metrics", lines 40–41: regression frequency, rework rate, spec deviation, review catch rate, hallucination rate, escalation frequency, retry dependency, token efficiency). This run collected ad-hoc hygiene axes instead (tests authored, docs current, commits, defects caught pre-merge). The 8-metric layer was not integrated into the harness.

---

## Results

| Task | Class | Arm | Verdict | Cost | Wall | Commits | New tests | Hidden suite |
|------|-------|-----|---------|------|------|---------|-----------|--------------|
| t1 category budgets | multi-file feature | A | PASS | $0.48 | 90s | 0 | 0 | 14/14 |
| | | B | PASS | $11.68 | 4454s | 3 | 1 | 14/14 |
| t2 date-range boundary | bug fix w/ repro | A | PASS | $0.20 | 36s | 0 | 0 | 8/8 |
| | | B | PASS | $1.58 | 776s | 1 | 0 | 8/8 |
| t3 trailing space | trivial control | A | PASS | $0.22 | 37s | 0 | 0 | 4/4 |
| | | B | PASS | $7.92 | 2117s | 2 | 1 | 4/4 |
| t4 recurring entries | hard multi-file feature | A | PASS | $0.69 | 143s | 0 | 0 | 27/27 |
| | | B | PASS | $16.53 | 5181s | 2 | 2 | 27/27 |
| **Total** | | **A** | **4/4** | **$1.59** | **306s** | **0** | **0** | 53/53 |
| | | **B** | **4/4** | **$37.71** | **12528s** | **8** | **4** | 53/53 |

**H1 (success-rate lift): 0 percentage points.** Both arms passed everything.

**H3 (above its weight): not testable.** Arms C/D were skipped per the pilot protocol, and with the
weak model already at ceiling there is no gap for process to close.

---

## H1 is unmeasurable here, and that is the finding

Arm A did not scrape through. It passed the hard task — t4's 27 hidden assertions cover month-end
clamping (31 → 30, → Feb 28, → Feb 29 in a leap year), four inclusive range bounds, month-level
suppression keyed on category while ignoring amount, and a stable sort placing real entries before
generated ones on a shared day — in 143 seconds for 69 cents.

The cause is structural, not luck:

> Mechanical scoring requires a precise, pre-registered contract. **A precise contract is most of
> what the planning layer produces.** Writing `TASK.md` well enough to score without grader judgment
> handed the control arm the treatment's principal output for free.

The control was never a control. It was the treatment minus the gate. Any benchmark built this way
measures spec quality and reports it as model capability — so **§Design and §Task set of
`benchmark.md` are wrong as written**, and the n ≥ 20 build would have inherited the flaw at 20×
the cost. The pilot did its job: it killed a design before the harness was funded. That is exactly
what [`benchmark.md`:88](benchmark.md) says the pilot is for.

---

## H2 is where the difference actually lives

None of the following is visible to a pass/fail scorer.

**Arm A wrote zero tests. On all four tasks.** Including t1 and t4, each of which added a new public
module and new CLI commands. Arm A's work passes only because the hidden suite tests it *for* them —
in a real repo that coverage does not exist. Arm B wrote 4 test files: `test_budgets.py`,
`test_cli.py`, `test_recurring.py`, plus CLI coverage on t3 (filename not recorded).

**Arm A committed nothing. On all four tasks.** Every run ended as a dirty working tree. Arm B made
8 commits across feature branches with `--no-ff` merges, each through the gate.

**The review gate held twice, and one of them mattered.**

- *t1* — code-lead issued **HOLD** on 4 Major documentation-currency findings: `README.md` still
  advertised three CLI commands after a fourth was added, and `CLAUDE.md`'s layer map omitted the new
  `ledger/budgets.py`. MERGE READY only after the fix. It additionally flagged a reachable nonsense
  state that arm A shipped silently — `budget set food -5.00` stores a negative limit, after which
  every spend reports `over`.
- *t4* — code-lead issued **HOLD** on a **Critical**: global options placed before the subcommand
  were silently overwritten by subparser defaults, so `--file` was ignored and `total` returned
  `Total: 0.00`. **The hidden suite would have failed on this.** The gate caught it, the fix landed,
  and the scored result is PASS.

### The honest reading of that last one

The Critical was a defect **the wave-based process itself introduced** — arm A's single-pass
implementation never had it. So the correct statement is not "the gate beat the baseline." It is:

> The gate caught a defect that the process's own parallelism created, and converted what would have
> been a FAIL back into a PASS. Net against arm A on t4: a draw, at 24× the cost.

A review layer that pays for the failure mode of the execution layer it ships with is a real
property, but it is not the same claim as "discipline makes a weak model ship better than it would
raw." Do not market it as the latter.

**H2 verdict: GATE BRANCH 1 CONDITIONS MET.** B's hygiene metrics are demonstrably clearer — zero tests vs. four, zero commits vs. eight, zero defects caught pre-merge vs. two holds. By the pilot gate's branch 1 criterion ([`benchmark.md:84`](benchmark.md#L84)), this evidence would fund the n ≥ 20 run.

---

## Cost — the number nobody wants on the slide

**23.7× cost, 40.9× wall-clock, for zero success-rate lift.**

| Task | Cost ratio B:A | Wall ratio B:A |
|---|---|---|
| t1 multi-file feature | 24.3× | 49.5× |
| t2 bug fix | 7.9× | 21.6× |
| t3 **trivial control** | **36.0×** | **57.2×** |
| t4 hard feature | 24.0× | 36.2× |

Ratios computed from the rounded costs in the results table above.

The trivial control behaved exactly as `benchmark.md` §"Threats to validity" predicted — process
overhead on an easy task is pure cost — but the magnitude was not predicted: **35 minutes and $7.92
to delete a trailing space**, against 37 seconds and 22 cents. That is the strongest empirical case
the `light` tier has ever had, and it belongs in the tier guidance as a measured number.

---

## What to fix before funding n ≥ 20

1. **Stop pre-specifying the contract.** Give both arms the vague goal a developer actually types
   ("add budgets so I can see if I'm overspending"). This breaks mechanical scoring, which is the
   real problem to solve — score behaviour through a stable public surface, or accept blind human
   grading, but stop handing the control a spec.
2. **Make hygiene a primary metric, not a supplement.** The `/g-telemetry` 8-metric layer mandated by the methodology was not collected in this run; ad-hoc hygiene axes were used instead. The full 8-metric set (regression frequency, rework rate, spec deviation, review catch rate, hallucination rate, escalation frequency, retry dependency, token efficiency) must be instrumented before the n ≥ 20 run. Hygiene is the only axis that separated the arms, and the current design treats it as a footnote to success rate.
3. **Raise task difficulty until the baseline fails.** A benchmark whose control scores 100% has no
   resolution. Candidates: tasks with genuine ambiguity, cross-cutting changes, or a repo large
   enough that context selection matters.
4. **Report per-task-class always.** t2's 7.9× against t3's 36.0× is a 4.6× spread inside one pilot.
5. **Add "task ceiling" to the threats list** in `benchmark.md` — it is not there, and it is the
   threat that actually fired.

## Threats to validity in this run

- **n = 4, single trial per cell.** No variance estimate. Signal, not a result.
- **Internal fixture.** Zero external credibility versus a public harness.
- **Self-approval.** Headless, arm B approved its own `/g-plan` and `/g-review` gates. The commit
  gate itself was not self-served — the native `pre-commit` hook blocked until the sentinel existed.
- **Ceiling effect dominates.** Every H1 conclusion here is about the tasks, not the process.
- **Budget caps** ($6 arm A, $25 arm B per run) were not hit; no run was truncated.

## Artifacts

Harness, pre-registrations, per-run session JSON, review records and scored trees lived in the session scratchpad and were not retained or committed. This was a single trial; re-running would be a new trial at comparable cost ($25–35 per arm).
