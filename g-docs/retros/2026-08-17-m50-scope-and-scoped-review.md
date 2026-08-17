# Retro — 2026-08-17 — M50 scoping, close swarm, and the first measured scoped review

## What was done

- **M47 close swarm discharged in full** — `/g-telemetry`, `/g-align`, `/g-wiki`, `/g-doctor` all run. The obligation had been outstanding since M47 shipped 2026-08-12.
- **M50 — Eval-Chain Integrity created and folded into v2.5**, sequenced third (M47 → M48 → **M50** → M45). ADR-012 amended a second time; build order now renders identically across five surfaces, verified mechanically.
- **M43 gained Wave 4 (governance cadence)** — the health passes become gating on the `full` tier, keyed on **run-recency**, never on a pass issuing a blocking verdict. Flagged as needing its own ADR before build.
- **n8n ingress contract** — portable-filename charset stated in both `skills/g-patterns/SKILL.md` and G-RULES §I; the slugify expression was handed to the developer for the n8n side, which is where the actual cure lives.
- **Hook banners de-emojied** — 10 four-byte emoji removed from two hooks; four test assertions re-anchored to marker + adjacent text.
- **Audit remainder (todo row 7) fully disposed** — every item now has an owning milestone. Row 1 (stale wiki) closed by the `/g-wiki` pass.
- **First measured scoped review gate**: 11 tool calls, 79k subagent tokens, 3m54s, one round, 1 major + 1 minor, both real.

## Decisions made

- **v2.5 gets the full M50 scope; no split to G-Proof** (developer override of a proposed split). 2.5 is a maintained freeze with real users, so "it gets rebuilt later" does not license shipping a release whose self-governance instruments don't measure what they claim. Recorded in the ADR-012 amendment because it inverts ADR-010's cost argument and a future reader would otherwise re-derive the split.
- **Derive-don't-type applies to code consumers only, never to prose.** A consumer that types a list goes *blind*; a document that types a count is merely occasionally wrong, and replacing the count with "consult the directory" is worse documentation. For prose the rule inverts: keep the concrete number, add a currency check.
- **Governance cadence gates on run-recency, not on verdicts.** Staleness is mechanical and falsifiable; a drift verdict is judgment. Only the first is safe to gate on — this preserves `/g-align`'s stated advisory contract and the brief's "not a replacement for the developer's judgment" non-goal.
- **Amber gate accepted knowingly** to run review + retro in-session, in exchange for the scoped-review datapoint.

## Patterns

### Worked well

- **Scoping the review gate by exclusion, not by file list.** The two biggest levers were forbidding suite re-runs (attested green as given) and forbidding architecture re-derivation, plus excluding three reviewer axes with zero surface. Cost fell from ~3h/~130k-killed to 11 calls/79k/one round **without losing recall** — it caught a genuine blocker.
- **HQ-sums-the-table** caught nothing new this pass because the runner was HQ itself; the suite table summed to 564 first time.
- **Asking the reviewer to check my own suspected defect.** I flagged that the amber marker I chose (`⚠`) collides with the Health line's glyph; the reviewer verified all four assertions independently rather than taking my word, and confirmed the anchors discriminate.

### Avoid / do differently

- **Scope the review by DEPENDENCY, not by AUTHORSHIP — run `/g-blast-radius` before dispatch.** The hand-written scope named 3 executable files and **1** test suite; blast radius found **6** suites exercising the same hooks, plus `pre-compact.sh` and `observe.sh` as consumers. More important, the only way the change could have broken something silently — a skill grepping the banner for the old markers, with no test covering skill prose — is a question authorship-scoping never asks. It was verified *after* dispatch, which is backwards. This is M45's stated design and skipping it was the pass's methodological error.
- **A mechanical check verifies the claim it tests, not the claim you care about.** The build-order strings were verified by grep and were correct; the **ordinal words** beside them ("M50 sequenced second" vs a build order putting it third) passed through unexamined and became the review's one major finding. Twice today the instrument was wrong for the claim: this, and `/g-doctor` Check 20's by-name `.gitignore` grep, which reported three false failures because this repo ignores `.claude/` wholesale (`git check-ignore` is the authoritative test).
- **Never declare a record lost without reading the disk.** Two audit findings were written off as unrecoverable because their reports are gitignored. Gitignored is not deleted — all seven reports sit in `g-docs/agent-output/audit/`, and one `ls` recovered them.
- **Sentinels bind to the STAGED tree (ADR-004) — stage first, then stamp, then commit.** Prose sentinels are unparseable by `gf_parse_stamp`; the gate denied correctly. The stamp is `commit_sentinel_ts=<write-tree> commit_sentinel_head=<HEAD> commit_sentinel_worktree=<toplevel>`.
- **The commit-message heredoc failed live** — todo row 10 reproducing exactly as documented. §C already mandates the Write tool for record files; that applies to commit messages too.
- **A nudge that can never clear trains the operator to filter the whole banner.** `/g-trim` has never completed here, so `.claude/last-trim` has never existed, so its weekly nudge has fired on every prompt indefinitely. Same alarm-fatigue shape as the forecast miss-risk figure.

## Cold-start context

**Branch:** main · **Head:** `5ba563d` (committed, **not yet pushed**)
**Active milestone:** v2.5 arc — M47 ✅ closed (swarm discharged today); **M48 next in build order**, then M50.
**Suite:** 564 / 18 / green, attested 2026-08-17 on a quiet tree (sequential run, no concurrency).
**Local state:** review-holds = 25 · voice `gian` · telemetry `cautious` · `/g-doctor` 16/16 required passed.

**Owed, in priority order:**
1. **ADR for the derive-don't-type boundary** (code consumers vs prose) — decided today, currently surviving only as one bullet inside M50's scope, which means it dies when M50 closes. `/g-adr` deliberately deferred to a fresh window per §C (high-branching deliberation poisons the context it runs in). **This is the fresh session's first task.**
2. Push `5ba563d`.
3. `/g-plan` M48 (carries suite-runtime + suite-ordering fixes, and the audit-7 rider added today).
4. M43 W4 governance-cadence ADR — before build, not now; the design (which passes, what windows, how it degrades) is undecided.
5. `/g-trim` — would clear a nudge that has never been clearable.
6. Carried: n8n slugify on the n8n side · the emoji decision for ROADMAP status markers (deliberately untouched — four skills read them) · `commands/g-forge.md:8` hardcodes an env-specific plugin-cache path (audit-4 N4, unscoped) · inbox trust-boundary ADR · M38 delivery decision · intake rows (a)–(h) · task 6 M45 rider · task 7 remainder.

**Evidence to carry into M45's design ADR:** scoped review = 11 tool calls / 79k tokens / 1 round / 1 real major, versus ~3h / ~130k tokens / killed unscoped, and 6 rounds on `/g-resume` Step 0. Third independent datapoint after Alter-G (reproduced twice) and the keyline field report.

## Journal basis

2026-08-17: 20 events — 8 agent · 6 commit · 4 push · 2 session. One scoped review dispatch (`code-lead`, 11 tool calls, 79,475 tokens, 233s).
