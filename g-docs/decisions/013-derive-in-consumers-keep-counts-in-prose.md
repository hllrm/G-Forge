# ADR-013: Consumers derive their lists; documents keep their numbers

**Date:** 2026-08-17
**Status:** Accepted
**Reversibility:** two-way door (repo-local convention plus `tests/` assertions; reversing means deleting assertions)
**Context:** G-Forge plugin source repo. Decided by the developer in session 2026-08-17; simplified to this form 2026-08-18 after the first draft — dense with hand-typed file:line claims — failed its own doc-review three rounds running, which is this rule demonstrating itself.

## Decision

**1. Consumers derive.** A skill, hook, or test that *acts* on a set of files (enumerates, iterates, gates, scores, offers options) reads the directory at run time — it never carries a typed list. A typed list silently omits new members, so the consumer goes blind to exactly what it exists to notice. Every fix in this class ships with a test that fails when a typed list and its directory disagree — never a hand-corrected list. A typed list whose only consumer could test the filesystem directly (e.g. validating an argument via `[ -d profiles/<arg> ]`) is deleted, not pinned.

**2. Documents keep their numbers.** Prose that states a count keeps the concrete number; replacing it with "read the directory for the current set" removes a useful fact and substitutes one nobody can use. If the number matters enough to state, pin it with a test (the pattern of Group D in `tests/test-lib-install-completeness.sh`); if it can't be pinned, leave it out rather than shipping an unchecked claim.

## Why

Five recurrences of rule 1's failure, the live one being `/g-telemetry`: its coverage table types 17 agent names against 19 in `agents/`, so two agents are structurally uncountable, and the 2026-08-17 committed report shipped blind to one of them. Rule 2's failure happened once — a `/g-wiki` edit replaced a concrete ADR count with a directory pointer and was reverted as worse documentation.

## Rejected

- **Derive everywhere, prose included** — the reverted `/g-wiki` edit as policy.
- **Hand-correcting typed lists** — tried five times; corrections repeatedly missed a second list in the same file.
- **Advisory (`/g-doctor`) instead of blocking tests** — advisory nudges are measurably ignored in this repo.
- **A taxonomy of exception buckets for "underivable" lists** — the first draft of this ADR. Both claimed exceptions dissolved on inspection (install-path pairings are on disk under `profiles/<stack>/`; the frontmatter stack list's one consumer should be a directory test), and the apparatus generated more review findings than it prevented.

## Consequences

Adding an agent/hook/profile turns a suite red until every consumer sees it — that friction is the point. The evidence inventory (which sites, which counts, exact line refs) lives in M50's scope in `g-docs/ROADMAP.md`, where churn is expected — not here. One residual is untestable statically: whether the model actually enumerates at run time. Covered by an end-to-end done condition in M50 — add an agent, run `/g-telemetry`, confirm the report counts it.
