# Pattern Report — 2026-08-15

**Synthetic round-trip validation fixture.** This report exists to verify that the outbound publication path and the external counter-report ingress work end to end. Its patterns are illustrative rather than mined from a real corpus, and no rule change will be applied from them. A counter-report responding to it is welcome and will be weighed as advisory only, the same as any other.

## Systemic (≥3)

- **Label:** verification-deferred-until-after-integration | **Weighted count:** 3 | **Sources:** 3 retrospectives
  **Failure class:** Work is declared complete on the strength of a component behaving correctly in isolation, while the check that it still behaves correctly once joined to its neighbours is postponed to a later stage. Defects that only appear at the join are therefore found by whoever integrates, long after the authoring context is gone, and cost far more to place than they would have cost to catch.
  **Proposed fix intent:** Make the integrated behaviour, not the isolated one, the condition that closes a unit of work.
  **Status:** PENDING

## Emerging (2)

- **Label:** single-source-estimates-presented-as-measurements | **Weighted count:** 2 | **Sources:** 1 retrospective, 1 forecast
  **Failure class:** A figure derived from one observation is restated downstream without its provenance, and each restatement makes it look better established than the single data point behind it. By the time it informs a decision, nothing in how it is presented distinguishes it from a measured quantity.
  **Proposed fix intent:** Carry the sample size and derivation alongside any figure that travels between documents, so a reader can see what it rests on.
  **Status:** PENDING

## Isolated (1)

- **Label:** cleanup-step-owned-by-nobody | **Sources:** 1 | **Status:** —

## Reinforced

- **Label:** independent-verification-beats-self-report | **Sources:** 2 | **Status:** —
