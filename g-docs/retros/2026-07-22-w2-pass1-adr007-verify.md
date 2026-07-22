# Retro — 2026-07-22 (session d): ADR-007 verify → W2 plan → Wave 1 (Pass 1)

## What happened
- `/g-resume` re-hydrated; first task was the ADR-007 fresh-window verify — ran immediately (pure verification): **all 7 claim groups hold**, W2 unblocked. Two notes: umbrella *frontmatter* already bare tokens (but see finding below); S1(b) mtime evidence strengthens, not weakens, the migration caveat.
- Developer asked "aligned with plan?" — alignment pass found 4 real adjustments (stale ROADMAP W2 bullet; task overlaps to merge; installed-rule propagation missing; post-release check unowned). All folded into `/g-plan`.
- `/g-plan` W2: 24 tasks / 6 waves / 17 slots; Clarifies resolved (teaching-docs-only sweep, g-help catch in scope); budget 81 vs ~35 → 4-pass split approved; forecast 85% High (breadth).
- Wave 1 (Pass 1) executed: 5/5 agents DONE first attempt, 5 HQ-inline done, integrity clean (12 files, zero overreach). Zero commits by design — everything rides Pass 4's gated commit.

## Decisions
- Teaching-docs-only sweep policy; g-help unknown-token catch in W2 (developer, at Clarify gate).
- PostToolUse skip-on-error: **accepted, no code fix** (fixture-proven hooks-correct; native consume covers sentinels; probe-hygiene rule stands).
- Heredoc fix shape locked by characterization: strip well-formed heredoc bodies pre-suffix-walk; never when feeding an interpreter; unterminated ⇒ untouched.

## Cold-start context
**Branch:** main (5 unpushed + Wave-1 uncommitted working tree — deliberate).
**Next up:** Pass 2 = `/g-execute` Wave 2 of `g-docs/plans/m-audit-w2-shim-retirement-conformance.md` (shim deletion now unblocked; task 19 executor reads the characterization first).
**Key files touched:** skills/{g-skill-validate,g-skill-design}/SKILL.md, profiles/claude-plugin/rules/architecture.md, agents/architecture-enforcer.md, commands/g-forge.md, hooks/observe.sh, tests/{test-observe.sh,README.md}, g-dev/fixtures/posttooluse-skip-boundary.sh, ROADMAP/milestone docs.

## Avoid / do differently
- **"Near-nil" pre-reads deceive:** the ADR-verify note called the umbrella trim near-nil after reading only frontmatter — the real per-skill prose lived in the fallback list at lines 48-85. A claim about a file surface needs the WHOLE file read, not the first screen (same lesson class as the W1.5e full-file-diff rule, recurrence #2 → pattern-worthy).
- Wave-planner's schedule had one ordering risk (attestation of suites whose hooks source a lib being edited in the same wave) — HQ validation caught it; keep Check-3 sharp on *sourced-lib* edges, not just direct file collisions.
