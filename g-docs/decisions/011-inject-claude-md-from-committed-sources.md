# ADR-011: Inject CLAUDE.md's load-bearing content from committed sources

**Date:** 2026-07-26
**Status:** Accepted
**Reversibility:** two-way door (reversible) — see the qualification in Consequences: the *decision* is reversible, the *marker syntax* hardens once it ships to consumer projects
**Context:** G-Forge — CLAUDE.md durability and accuracy; the boundary between installed artifact and project record

## Context

In this repo `/CLAUDE.md` is gitignored (`.gitignore:56`), because here it is the *installed artifact* of the plugin dogfooding itself — the same class as `.claude/`. This deviates deliberately from what `/g-init` tells consumer projects (`skills/g-init/SKILL.md:168` classifies CLAUDE.md as tracked project record), because in a consumer project the file is not an install artifact of the tree it sits in.

Two real failures forced the decision. **The file was lost once** and hand-regenerated on 2026-07-10, taking its then-current hand-written rule text with it — the precedent that later drove T1 (created 2026-07-26) to be extracted off this surface into committed `g-docs/transitional-rules.md` rather than live here as bare prose. **Hand-typed prose inside it went stale**: the per-suite test-assertion table sat at 522 while the real suite had moved to 523 — and tracking would not have caught it, since a *tracked* file carried the same class of staleness at the same time (`tests/test-workflow-checkpoint.sh:12`, declared 80 vs runner 81). The defect is hand-typed facts, not the file's git status; the cure is deriving facts from their source.

A `.gitignore` negation carve-out to track the file was implemented, reviewed live, and reversed on 2026-07-26. The rule below is what replaced it. Until this ADR, the record of the decision was the comment block above the `/CLAUDE.md` pattern in `.gitignore` (`:22-55` as of this commit).

## Decision

Every load-bearing line in `CLAUDE.md` must be exactly one of:

- **(a) marker-fed** — inside a G-Forge marker block fed from committed plugin source (`<!-- G-Forge Rules -->`, `<!-- G-Forge <stack> Architecture Rules -->`), owned by `/g-init` / `/g-specialize` / `/g-update`;
- **(b) imported** — an `@`-import of a committed file;
- **(c) declared local-only** — bracketed in a local-only marker, hand-written at the moment local content is added:

```
<!-- G-Forge local-only: <slug> -->
...content...
<!-- End G-Forge local-only: <slug> -->
```

`<slug>` is lowercase kebab-case (`^[a-z0-9][a-z0-9-]*$`) and is a pairing key only, not a description. There is deliberately **no reason field**: the check is a syntax classifier, not a rationale auditor, and a required justification adds a schema to get wrong without adding a guarantee — while adding exactly the friction that would turn (c) into a dumping ground.

**Bare prose asserting facts about the tree is the defect.** Fix the injection, never the `.gitignore`.

Branch (c)'s declaration is itself local — the marker lives only inside the gitignored `CLAUDE.md`, never in a committed allowlist. A committed manifest naming what a contributor declared local would defeat the entire reason (c) exists: the one sanctioned instance is a personal voice-profile `@`-import — **not yet wrapped in the marker; today's declared-block count is 0, and wrapping it is part of the detector build** — and this is a public marketplace repo. The detector recognizes the *shape* of a local-only block, never its contents.

The marker survives `/g-update` because `/g-update` locates its managed blocks by two literal labels — `G-Forge Rules` and `G-Forge <stack> Architecture Rules` (`skills/g-update/SKILL.md:160-172`, `:191`) — never a `G-Forge *` wildcard, and never modifies content outside them (`:333`). `G-Forge local-only:` matches neither.

`/g-doctor` **Check 24** — **specified here, not yet implemented; do not rely on it** (`/g-doctor` currently ships 23 checks, `skills/g-doctor/SKILL.md:10`; the build is a planned follow-up changeset) — will enforce the rule (advisory, read-only per [ADR-009](009-update-integrity-detect-diagnose-fix-split.md)) by classifying `CLAUDE.md` in a single top-to-bottom pass into four buckets — MARKER-FED / IMPORT / DECLARED-LOCAL / BARE-PROSE — reporting any region landing outside the first three, plus unpaired and unterminated markers as distinct findings. It validates presence of the wrapper, never the truth of what is inside it. Payload correctness against committed source is drift-detection's job, not Check 24's — and today no check covers it for CLAUDE.md: Check 16 compares hooks, libs, g-rules and installed agents, never CLAUDE.md marker payloads. Extending payload comparison to marker blocks is folded into the detector build.

**Scope is split.** `/CLAUDE.md` stays gitignored **in this repo only** (`.gitignore:27-32`) — that half is a property of the plugin dogfooding itself and does not ship. The three-branch sourcing requirement and the Check 24 classifier **do ship to every project**, including consumer projects whose CLAUDE.md is tracked project record (`skills/g-init/SKILL.md:168`, unchanged). The classifier is git-status-agnostic: same taxonomy, same findings, different remediation pointer.

## Alternatives considered

| Option | Why rejected |
|--------|-------------|
| `.gitignore` negation carve-out — track `/CLAUDE.md`, mirroring the `g-forge-dev.md` pattern at `.gitignore:18-20` | Implemented then reversed 2026-07-26 on two costs: it publishes the personal voice-profile `@`-import on a public marketplace repo, and the profile *definition* stays gitignored by design, so every clone would carry a CLAUDE.md importing a file it does not have |
| Status quo — bare hand-typed prose, held together by discipline | Empirically failed twice: file loss 2026-07-10, and a stale 522 against a real 523. Two independent instances, not a hypothetical |
| Two-file split — commit a stripped public CLAUDE.md, keep a local one carrying the personal import | Reintroduces the two-sources-of-truth class [ADR-007](007-one-command-per-skill-retire-shims.md) eliminated. The rule's premise is removing sync surfaces, not adding one |
| git clean/smudge filter — strip the personal line on commit, keep the file tracked | Host-fragile mechanism class [ADR-008](008-self-host-working-tree-split-cadence.md) already rejected for this repo on Windows/git-bash semantics; no repo precedent, and it sits outside G-Forge's own hooks |
| A committed allowlist declaring which CLAUDE.md regions are local-only | Publishes what branch (c) exists to keep unpublished. Ruled out by the same constraint that killed the carve-out |

## Consequences

**Easier:** A lost CLAUDE.md is mechanically restorable — everything load-bearing resolves to committed plugin source or a committed imported file, never to memory. Facts stop rotting because they are generated or imported rather than typed. All three branches are now grep-provable, so `/g-doctor` can point at a specific `CLAUDE.md:<line>` instead of relying on someone remembering a `.gitignore` comment. Consumer projects inherit the same hygiene detector without needing this repo's gitignore backstory.

**Harder / constrained:** Every new load-bearing line needs a home *and* a delivery mechanism before it can be written — friction at authoring time that free-form prose did not have. Check 24 will immediately flag most of this repo's own `CLAUDE.md` project prose as BARE-PROSE — its first run generates the authoritative backlog list (a hand-typed enumeration here would be the very defect this ADR condemns); remediating that backlog is deliberately out of the detector's own scope and stands as the named prerequisite before Check 24 can go required. `/g-update`'s marker vocabulary must **never** expand to match `G-Forge local-only:` — doing so would let a routine update silently rewrite hand-declared local content. Every local-only addition needs its slug typed correctly twice, or it reports as unpaired rather than declared.

On reversibility: the decision is a two-way door — reverting to bare prose or to tracking the file costs a day and nothing external commits to it. The **marker syntax** is the part that hardens: once consumer projects carry `<!-- G-Forge local-only: -->` blocks, changing the syntax re-classifies their declarations as bare prose. That degrades to an advisory warning rather than a break, so it stays recoverable — but the format should be treated as published once it ships.

**Follow-up decisions:**

1. **When to promote Check 24 from advisory to required** — gated on remediating this repo's existing bare-prose backlog.
2. **Slug collision handling** — whether re-opening an already-open slug is a hard fail or silently accepted. Unspecified; an implementer must decide before shipping, or the state machine may pair opener A with closer B.
3. **Unterminated-marker terminal state** — as specced, an opener with no closer would leave the state machine in `LOCAL`/`MARKER` through EOF, silently reclassifying everything after it. The implementation needs an explicit end-of-file check rather than folding into the BARE-PROSE bucket.
4. **Whether `/g-init`'s consumer scaffold should ship the local-only marker as an inline template comment**, so consumers discover branch (c) without reading this ADR.
5. **`/g-trim` import-follow** — `/g-trim` already Globs each `@path` to confirm it exists (`skills/g-trim/SKILL.md:14`) but does not follow the import to audit the target's content. Extracting T1 to a committed imported file therefore moved a live rule out of `/g-trim`'s audit subject set (`skills/g-trim/SKILL.md:3`), weakening its sunset detector — a regression this decision's own T1 precedent caused. See `g-docs/transitional-rules.md`, Tripwires.
6. **Check 24 verifying `@`-import target committedness** — branch (b) is defined as an import of a *committed* file, but the classifier as specced keys only on the line-initial `@` shape, so an import of a gitignored target would classify as clean IMPORT. That is exactly the dangling-import failure mode that killed the carve-out. The check is trivially mechanical (`git check-ignore` per `@`-target); `/g-trim`'s exists-only Glob (`skills/g-trim/SKILL.md:14`) is the weaker version already running. Fold into the Check 24 build.

**Risks:** Check 24 is syntactic, not semantic — nothing stops wrapping content that should be marker-fed or imported inside a local-only pair to dodge a flag. The check removes silence, not misuse. This is the decision's most likely failure mode: branch (c) becomes the laundry chute, the check certifies the wrapper, and facts-asserted-from-memory carry on behind a compliance marker — leaving the detector actively worse than nothing. **Earliest warning sign: a local-only block containing a number or a count rather than a personal reference.** Personal content is the branch's only legitimate use; a suite total or file count inside one means the chute is open. Second sign: the block count rising above one (baseline after the detector build wraps the voice-profile section: exactly one). Advisory tier means a run completes regardless of finding count: discoverable, not enforced, until promotion. And `CLAUDE.md` has no git history in this repo, so Check 24 cannot separate newly introduced bare prose from long-standing debt — every run re-surfaces the full backlog, which is itself why promotion is not immediate.

## Rejected Alternatives

| Alternative | Deciding factor |
|-------------|-----------------|
| `.gitignore` negation carve-out (track CLAUDE.md) | Publishes the personal voice-profile import on a public repo; ships a dangling `@`-import to every clone |
| Status quo bare prose + discipline | Failed twice, measurably (file loss; stale 522 vs real 523) |
| Two-file split (public + local CLAUDE.md) | Reopens the two-sources-of-truth class ADR-007 closed |
| git clean/smudge filter | Host-fragile mechanism class ADR-008 already rejected here |
| Committed local-only allowlist | Publishes exactly what branch (c) exists to keep unpublished |
| Required `reason:` field on the local-only marker | Gates on nothing mechanically checkable; adds the friction that makes branch (c) a dumping ground |

## Assumptions That Held

- **`/g-update`'s marker-block mechanism refreshes what it claims to.** Verified this pass: it extracts from plugin source and replaces the block wholesale (`skills/g-update/SKILL.md:166-170`), never touching content outside markers (`:333`); both blocks exist live at `CLAUDE.md:75-81`. *Fragility: low, but the Rules block currently carries only a pointer to `@G-RULES.md` — branch (a) is confirmed to exist and is unexercised for project prose. The queued marker-block-for-project-prose work is what would exercise it.*
- **`@`-imports of committed files resolve in every clone.** Holds for T1 today (`g-docs/transitional-rules.md` is committed and `@`-imported). *Fragility: low per-instance, total per-instance if an import target is ever left gitignored — the exact bug the rejected carve-out demonstrated is easy to introduce.*
- **The three branches are mechanically distinguishable.** True as of this ADR: (a) and (c) are literal-prefix markers, (b) is a line-initial `@`. *Fragility: low for syntax; the classifier cannot judge whether a region is in the right branch.*
- **Branch (c) stays rare.** One sanctioned instance (the voice-profile import) — not yet wrapped in the marker, so today's declared count is 0 until the detector build wraps it. *Fragility: medium — nothing structurally caps it once (a)/(b) friction is felt; the no-reason-field choice trades an unenforceable guard for adoption.*
- **`/g-trim` can be scope-extended to follow committed imports.** Its Step 1 already reads `@`-paths and already treats `g-docs/project_brief.md` as ground truth (`skills/g-trim/SKILL.md:16`), so this extends an existing read path. *Fragility: high and known — the gap is currently open, not closed, and is recorded as follow-up 5 above.*

## Constraints That Drove This Decision

- **Public marketplace repo** — nothing personal may be published. This ruled out tracking CLAUDE.md as-is, and ruled out any committed manifest of local-only content.
- **The personal voice-profile definition stays gitignored by design** — every tracked-CLAUDE.md alternative inherits a dangling-import failure mode.
- **`/g-init`'s consumer guidance must stay correct** (`skills/g-init/SKILL.md:168`, track CLAUDE.md) and must not be collaterally reversed by this repo's local deviation. This is why the decision splits by scope rather than asserting one rule everywhere.
- **No CI** — enforcement has to come from G-Forge's own hooks and skills or from human review, not a pipeline. This is why the rule rested on a `.gitignore` comment block until Check 24 was specified.
- **Evidence bar** — two measured failures rather than a projected one, matching the standard ADR-007 and ADR-008 set.
