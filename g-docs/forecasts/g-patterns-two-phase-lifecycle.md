# Forecast: g-patterns Two-Phase Lifecycle Rider

> Created: 2026-08-14
> Plan: g-docs/plans/g-patterns-two-phase-lifecycle.md
> Mode: regular

## Complexity
- Score: 6/10
- Breakdown: files 2 (5 files), waves 1 (2 waves), boundaries 1 (skills ↔ rules profile), new surface 1 (two new g-docs subpaths + resolve phase), rule edits 1 (G-RULES §I table)

## Miss-risk: 65% — Elevated
- Raw score (pre-calibration): 73%
- Calibration: adjustment −7, N=15 confirmed outcomes, M=0 mitigation-held (sample floor met — corpus over-predicts: hit_rate 0.13)

## Premortem scenarios

| Rank | Scenario | Likelihood | Impact | Score | Mitigation | Source |
|------|----------|------------|--------|-------|------------|--------|
| 1 | Handoff-block format violation — task 1 adds a NEW writer into the `## Active Session` block whose two consumers (workflow-checkpoint greedy BRE, pre-compact awk capture) disagree on malformed input, observed live 2026-07-26 | 3 | 4 | 12 | SKILL.md's pending-line instruction must specify editing the existing Next-up list only — never appending a second block, never repeating the leading label; cite the format note verbatim | 2026-07-26 live incident (handoff format note); stale-handoff-block class |
| 2 | Abstraction leak — the "core principles only" report ships a file path, identifier, or code fragment to external third-party models | 3 | 4 | 12 | SKILL.md defines a concrete abstraction contract (forbidden: paths, symbols, code, repo names) + a self-check line before writing the file; reviewer verifies with the report template | New class — plan surface (external n8n exposure), no corpus precedent |
| 3 | Confabulated summary/count — doc-writer asserts README/CHANGELOG counts or "no other occurrences" without whole-file evidence | 3 | 2 | 6 | Targeted-claims rule in agent prompts; HQ verifies README row + CHANGELOG bullet by grep, not by agent claim | Recurrence #3 tracked for /g-patterns (W3 Pass 3 confabulated 568/650); M-audit #20 class |
| 4 | Heredoc stall — a wave agent writes its record via Bash heredoc and wedges in the permission layer | 2 | 3 | 6 | Wave prompts mandate Write tool for all file output (G-RULES §C standing rule) | M-audit code-lead heredoc wedge (2026-08 outcome notes) |
| 5 | Doc-currency drift — README/CHANGELOG wording diverges from the final SKILL.md text | 2 | 2 | 4 | Wave 2 sequenced after Wave 1; doc tasks receive the finished SKILL.md text as input | M48 motivating class (volatile-fact heuristic) |

## Recommendations

Apply at least the top-2 mitigations before approving. Consider splitting the largest wave. (Both top-2 mitigations are prompt/spec-level and are folded into the wave dispatch prompts — no schedule change needed. Forecast assumes the historical pattern set is representative; the −7 calibration says this corpus historically over-predicts.)

## Outcome (filled in at /g-retro time)

| Scenario | Predicted | Actually happened? | Notes |
|----------|-----------|---------------------|-------|
| 1 | yes | did not happen (git) | mitigation-held: in-place-only instruction + verbatim format-note citation shipped in the SKILL and followed by the HQ bullet edit; both handoff consumers kept parsing across the pass. |
| 2 | yes | did not happen (git) | mitigation-held: forbidden-list + self-check shipped; r2 code-reviewer and r4 verified the saved report artifact clean (no paths/identifiers/repo names). Security review strengthened the contract in-review (secrets class, re-scan-on-mutation) before anything left the repo. |
| 3 | yes | partial (git) | The doc-writers did NOT confabulate (r2 verified counts exact) — but the class fired sideways: stale derived counts ("seven milestones", fixture bucket-vs-count, CHANGELOG mechanism claim) cost 3 consecutive Major rounds until the surface set was enumerated in ADR-012:11. |
| 4 | yes | did not happen (journal) | mitigation-held: every wave/fix prompt mandated Write tool; 107 agent events today, zero permission-layer wedges. |
| 5 | yes | happened — variant (git) | Wave-2 sequencing held for round 1, but the mid-review latest.md redesign recreated README/CHANGELOG drift against the SKILL (r3-1, r4-1) — doc currency re-broke each time the design moved. |
