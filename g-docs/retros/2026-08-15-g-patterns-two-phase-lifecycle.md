# Retro: g-patterns-two-phase-lifecycle — 2026-08-15

## What was done
- Shipped the `/g-patterns` two-phase lifecycle (commit `7627073`, merge `857fd30`, pushed): MINE saves an abstracted externally-shareable report to `g-docs/patterns/latest.md` (apply removed from the mining session); RESOLVE runs in a fresh session via the ROADMAP handoff, screens `g-docs/inbox/adversarial/` counter-reports (mechanical ingress screen mirroring Check 24: addressee-based injection discriminator, filename laundering, 10-cleared-file backfill window, size cap, quarantine + cleared-file dispositions, advisory-only), re-derives edits from internal sources only, and renames the report to its resolution date on completion.
- Folded M49 (Devil's-Advocate Agent) into the v2.5 scope: ROADMAP milestone entry + build order, ADR-012 dated amendment with the complete six-surface enumeration (`012:11`), brief, README, CHANGELOG, and the local fork-file stamp all updated.
- Registered `g-docs/patterns/` and `g-docs/inbox/adversarial/` across §I (shipped source), `/g-init` tracked list, `/g-doctor` Checks 20/21 (incl. generic-name content filter for consumer false positives), `/g-help` archive map, README, CHANGELOG.
- Re-sequenced `/g-patterns` out of `/g-review`'s "read-only" close swarm (it is a writer that pauses for triage and races the handoff write).
- Produced the blast-radius record for the inbox/report primitive (`g-docs/blast-radius/g-patterns-inbox-primitive.md`, Wide, with dated Resolution note) and committed the live test fixture: `g-docs/patterns/latest.md` (3 PENDING). The two inbox drops committed alongside it were developer-authored placeholders, not external counter-reports — the n8n round-trip never completed.
- Carried the prior session's pass-close doc changeset (owner rename sweep, wiki, manifests) in the same reviewed commit by explicit developer decision; merged cleanly on top of two n8n-side remote commits.

## Decisions made
- **Two-phase split with fresh-session resolve, handoff-managed** — no hook changes; the ADR-verification rail reused (developer, at intake; the hook alternative was rejected as new bash + new timing-suite surface).
- **`latest.md` single-open-report model** (developer, mid-review): stable path for external automation; rename-to-resolution-date archives closed-by-construction. Superseded the date-named scheme and killed three findings (suffix ordering, suffix-blind bullet, unreachable overwrite clause).
- **External counter-reports are advisory only** (developer): gpt-5-mini via n8n; suggestions, human-weighed, never authoritative. Internal devil's-advocate seat deferred to M49.
- **Everything-together review scope** (developer): rider + pre-existing pass-close changeset reviewed and committed as one tree (README/CHANGELOG/ROADMAP carried both changesets' edits and could not be split by staging).
- **Tier-1 re-run overridden** (developer stopped the runner): markdown-only rider vs the 2026-08-12 attested 564/18 suite; recorded verbatim in the review record, not contested by code-lead.
- **Inbox test drop committed as fixture** (HQ, flagged to developer via R3-4): a developer-authored placeholder proving the ingress path's shape only — not a live round-trip artifact. No Tier-3 round-trip evidence exists for the external ingress; the n8n pipeline is unvalidated until a real delivery lands (dogfood / M49).

## Patterns
### Worked well
- Single-use fix agents converged every round — each redeploy closed its findings list on the first attempt (journal: no repeated dispatch on any fix task).
- Resume-not-redeploy (§C carve-out) recovered four interruptions cheaply: three session-limit kills and one empty-seam decomposer return, all resumed with context intact instead of re-run.
- Grep-the-literal-fact sweep (M48 discipline) broke the stale-enumeration loop in one pass after three rounds of per-line patching.
### Avoid / do differently
- The external adversarial round-trip was recorded in-session as a first-attempt success off inbox drops that were actually developer placeholders — the n8n automation never delivered. The ingress screen itself shipped review-proven, but the pipeline is unvalidated; don't let a fixture masquerade as round-trip evidence.
- Derived facts restated across un-enumerated surfaces cost three consecutive Major rounds (milestone counts, bucket-vs-weight, mechanism claims). The fix that ended it was writing the complete surface checklist into the authority document (ADR-012:11) — enumerate the sweep set at amendment time, not from memory per round.
- Mid-review design changes re-break doc currency: the latest.md redesign landed after Wave 2's docs were written, recreating README/CHANGELOG drift twice (r3-1, r4-1).
- A point-in-time record authored concurrently with a fix wave (blast-radius A1-A3) contradicted the tree it described within the hour; records citing in-flight surfaces need step-anchored cites, not line numbers.
- Reviewer axes dispatched without Bash reconstruct the diff from cache baselines and file reads — workable, but two reviewers independently flagged the gap; give reviewer dispatches the diff or a diff file when the tree mixes changesets.

## Cold-start context
**Branch:** main
**Active milestone:** v2.5 arc — M47 ✅ shipped; M48 Review-Pipeline Hardening ⬜ next in build order; M49 ⬜ folded in (2026-08-14), sequenced after M43 before M41
**Next up:** resolve pattern report (g-docs/patterns/latest.md, 3 PENDING) — inbox empty — the two committed drops were developer placeholders (n8n round-trip never completed; deleted in the pass-close commit), resolve from internal sources; then M47 close swarm still owed (/g-telemetry · /g-align · /g-wiki refresh · /g-doctor odd-count); then /g-plan M48
**Key files touched:** SKILL.md (g-patterns, g-review, g-doctor, g-help, g-init), I-project-tracking.md, README.md, CHANGELOG.md, ROADMAP.md, project_brief.md, 012-g-forge-2.5-final-release-scope.md, communication-plan-2.5.md, g-patterns-inbox-primitive.md, latest.md (patterns + inbox), g-patterns-two-phase-lifecycle.md (plan + forecast), workflow-checkpoint.sh
**Carry-over context:** merge `857fd30` + `0ff2a3b` pushed clean; suite untouched this pass (developer override, prior attestation 564/18 of 2026-08-12 stands); review records g-docs/agent-output/review/*2026-08-1[45]-patterns* (r1–r4, gitignored); review-holds = 18 (4 HOLDs this pass, 6 rounds total)

## Journal basis
2026-08-15: 107 agent · 1 commit · 1 push (2026-08-14 journal also read — wave dispatches and r1 reviews span it)
