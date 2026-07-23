# Field feedback — review-pipeline cost scaling + code-lead orchestration shape

**Date:** 2026-07-22 (developer, at W3 review gate — mid code-lead run)
**Status:** TRIAGED 2026-07-23 (`/g-intake` → developer chose roadmap slot). Outcome: **new M45 — Review Pipeline Rework, v2.5.0, sequenced M41 → M45 → M42** (the M38/M39 hint below did not survive contact with their actual scopes — outbound reporter / interview skill, neither owns review mechanics). Depth-by-change-class routed to M36 first-consumer contract + M37 propagation; stdin-hang piece shipped v2.3.0; record-write structural answer = M45 design-ADR question. Downstream versions renumbered +1 minor (M42 v2.6.0 … M43 v2.14.0). *(Numbers as of triage date; superseded same day by the M46 insertion — M45 now v2.6.0, see ROADMAP Version Plan for current.)*
**Triage:** done — see ROADMAP M45 entry.

## The observation (developer, verbatim gist)

> code-lead passes get bigger and bigger — 200k+ tokens on a smallish project like g-forge. The code lead should "take seat" in HQ, dispatch review waves, then a final pass to process outcomes and emit the verdict. Are we over-reviewing? Will the salience layer help?

## Root cause (confirmed against agent definitions, 2026-07-22)

1. **`code-lead` has no `Agent` tool** (tools: Read, Glob, Grep, Bash). It cannot dispatch reviewers, sub-leads, or anyone. The `/g-review` SKILL's "code-lead dispatches review-orchestrator internally" is aspirational against the current frontmatter.
2. **`review-orchestrator` must run root-level** (its own description: spawning it as a nested subagent prevents it from dispatching reviewers — one-level nesting limit). Dispatched *under* code-lead it degrades.
3. Net effect: HQ dispatches code-lead as one subagent → the entire review (full diff + plan + evidence + every axis) runs in **one monolithic context**. A 25-file slice ≈ 200k+ tokens. This is a cost problem AND a quality problem — §C context poisoning applies to the reviewer too: by the fourth axis it conditions on its own accumulated notes.
4. Growth trend: review cost scales with slice size with no ceiling; W1.6 code-lead r1 ran ~34 min; W3's comparable.

## Second finding — depth-flat review (over-reviewing)

W3 was a P2-minors slice where every task already carried fail-before/pass-after fixtures + a green independent attestation. Full-depth all-axis review re-derived evidence the record already held. Review depth is **flat** across change classes:

- gating-adjacent lib (commit-detect.sh, classify-changeset.sh) → deep review justified;
- doc-only rhetorical-ref swap (grep-0 done condition) → structural verification of the done condition would suffice.

Same disease as the forecast feedback (severity-flat miss-risk): a self-governance number/process that doesn't discriminate gets ignored or overpaid. Severity-flat forecasts, depth-flat reviews — one family.

## Proposed shape (developer direction, to be designed at intake/ADR time)

**"Code-lead takes seat in HQ"** — role, not dispatch (same pattern as the PM interface rule):

1. `/g-review` embodies the code-lead role in the main session (review-orchestrator's constraint explicitly permits "directly from a skill in the main session").
2. HQ dispatches **scoped parallel reviewer waves** — partitioned per-cluster (gating libs / hooks / skills-docs / tests) or per-axis, each a small disposable context returning compact findings only.
3. A final cheap **synthesis** step (HQ inline, or one small agent) emits MERGE READY / HOLD off the findings blocks — never re-reads the diff.
4. **Salience selects depth per partition**: change-class → review depth (deep / structural / skip-with-reason). The M36 salience layer is the selection mechanism; review depth becomes one of its consumers alongside forecast scenario selection.

Expected effect: one 200k monolith → ~5 × 30k disposable contexts + small synthesis; deep attention only where the change class earns it.

## Open questions for the design pass

- Does code-lead remain an agent at all, or does the role fold into the `/g-review` SKILL with reviewer waves as the only dispatches? (One-command-per-thing criterion — ADR-007 spirit — suggests the latter.)
- Verdict ownership: synthesis emits the verdict — who owns HOLD adjudication, HQ-as-code-lead or the human?
- Interaction with telemetry profiles (`cautious`/`defensive` add reviewers — compose with partitioned waves how?).
- Attestation seam unchanged: g-forge-dev runner + header-vs-runner reconcile stays as-is (finding #20 doctrine untouched).

## Cross-refs

- `2026-07-18-forecast-calibration-feedback.md` (same family; "information not paranoia")
- G-RULES §C (context poisoning — applies to reviewers)
- ADR-007 (one command per thing — argument for folding the role into the SKILL)
- `/g-review` SKILL Step 4 (current dispatch shape), `agents/code-lead.md`, `agents/review-orchestrator.md` (frontmatter ground truth)

## Addendum (same day) — stall pattern, live instance

The W3 code-lead run itself STALLED mid-review (flat tokens, hung on a `cat` command; developer: "not the first time") and was killed by HQ. Two stacked known causes: (1) code-lead has no Write tool — big review records go through Bash heredoc writes, the class that stalled g-forge-dev at the permission layer in W1.6 (fixed for g-forge-dev by a Write grant; never applied to code-lead); (2) the installed PreToolUse gate still carried the pre-W2 heredoc false-positive at stall time (gating-pair carve-out deferred the lib install; closes at the W3 commit rider). Mitigation adopted for the redeploy: reviewer returns findings INLINE, HQ writes the record — zero agent file writes. Developer flagged the pattern as potentially 2.3-blocking; HQ assessment: orchestration friction, not gate correctness — but the reviewer-record write path needs a structural answer in the review rework (Write grant vs HQ-writes-records convention).

## Addendum 2 (same day) — stall ROOT CAUSE corrected: hook stdin-hang, not permission layer

A diagnostic fork found the actual mechanism: **orphaned hook processes blocked on `INPUT=$(cat)`** — `observe.sh:181` and `post-commit-cleanup.sh:53` alive 66 minutes with dead parents, stdin pipe never closed when the harness abandoned a tool call mid-flight (both spawned during the code-lead r2 run; the 60s hook timeout is not enforced on the Windows/PowerShell path). The visible "stuck on a cat" is the HOOK's cat, not the agent's report write — Addendum 1's permission-layer attribution is superseded for these instances (the W1.6 g-forge-dev permission block remains a separate, real, second class). Orphans were killed (non-gating hooks, gate unaffected; the fork's kill was pattern-match-based — flagged to the developer). **Fix routed forward: stdin read-timeout guard (e.g. `read -t` loop or timeout wrapper) on every stdin-JSON hook — source-side; the freshly installed copies carry the same pattern.** New finding row on the M-audit ledger; fix is post-M-audit (standing rule: nothing new enters a slice at gate).
