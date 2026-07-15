# ADR-004: Bind the review sentinel to the reviewed tree and expire it on staleness

**Date:** 2026-07-12
**Status:** Accepted
**Reversibility:** two-way door (reversible) — revert the hook + stamper and delete stamps; ~half a day, local files only, nothing external commits to it
**Context:** g-forge — the commit gate (the load-bearing enforcement differentiator)

## Context

The commit gate trusts a bare sentinel **file**: `/g-review` writes `.claude/g-forge-approved` (content `approved`) and the gate checks only that it *exists* (`[ -f … ]`). The 2026-07 audit found two silent integrity holes. **#8 (content-blind):** after MERGE READY, any further edit to the working tree still commits cleanly — the sentinel is not bound to the reviewed tree, so an approval can sign off a tree that no longer exists. **#9 (staleness):** `post-commit-cleanup.sh` removes the sentinel only when the commit runs through a PostToolUse-matched Bash/PowerShell tool; a commit from a raw terminal or any unmatched path never clears it, so the next in-session commit rides the stale approval. Both defeat the "provably enforces" claim without any surfaced error.

## Decision

Bind the sentinel to the exact reviewed tree, and make the **native git `pre-commit` hook the authoritative enforcement site** — PreToolUse is retained only for the rich model-facing deny message. `/g-review` stamps the reviewed state into the sentinel: the `git write-tree` hash of the index it approved **plus** the HEAD sha at review time. The `pre-commit` hook (where git has already staged `-a`/`-p`/interactive selections, so the index *is* the to-be-committed tree) re-derives `git write-tree` and **denies on mismatch**. Staleness (#9) is **folded into the same check**: a sentinel whose recorded HEAD no longer equals current HEAD — or whose stamped tree hash no longer matches the staged tree — is invalid and consumed. Canonical identifier = **`git write-tree` of the index** (git's own `.gitattributes`/clean-filter-normalized "what will be committed"), never diff text. Staleness anchor = **recorded HEAD sha**, never mtime.

## Alternatives considered

| Option | Why rejected |
|--------|-------------|
| Status quo + docs warning ("don't edit after MERGE READY; don't commit from a terminal") | Both holes are silent; a discipline aid that relies on remembering discipline is the failure it exists to prevent. Enforcement, not advice. |
| Content-binding only (fix #8, ignore #9) | Leaves the raw-terminal stale-sentinel path — the leak the audit explicitly named — open. |
| Staleness expiry only (fix #9, ignore #8) | A fresh sentinel still signs off any post-review edit within the same HEAD — the higher-impact hole (#8 is Impact: High). |
| HMAC / secret-sign the sentinel | No secret store in a local, world-readable file-based plugin; the dev can recompute the MAC as easily as the hash. Crypto + key management for zero adversarial gain against an accidental-bypass threat model. |
| Server-side `pre-receive` hook | Fires at push, after the local commit the gate exists to block; can't see a local gitignored sentinel; needs infra g-forge doesn't own. Wrong layer for an in-session commit-time gate. |
| Enforce the hash **inside PreToolUse** (the original provisional framing) | PreToolUse fires *before* git stages anything, so `git write-tree` there cannot see `commit -a`/`-p` modifications — it hashes the wrong tree and can pass unreviewed content. There is no commit-time index inside a PreToolUse hook. This is why the enforcement site moved to `pre-commit`. |
| Stamp mtime instead of HEAD sha | Not reproducible: clone/checkout/`cp -p`/editor-touch reset it independently of git state, and no git op updates it when HEAD moves. HEAD sha is the correct "which state did we approve" anchor. |
| Hash the diff instead of the tree | Diff text is sensitive to context lines, rename/whitespace flags, and algorithm version — not reproducible between stamper and gate. |

## Consequences

**Easier:** the gate can no longer be defeated by edit-after-MERGE-READY or a stale sentinel; enforcement finally matches the marketing claim. The `pre-commit` site fires on **every** commit including raw-terminal ones, so #9 is covered natively. Binding via `git write-tree` reuses the same "what will be committed" notion the `-a`/pathspec classifier (W1 #7) already reasons about.

**Harder / constrained:** `/g-review` (stamper) and the hook (verifier) must agree on the canonical hash method byte-for-byte, and both the CODE and DOC sentinels (and the mixed bucket) must carry and verify the stamp. The gate stops being read-only — `git write-tree` materializes loose tree objects on commit attempts (confirm GC-safe). Native `pre-commit` installs into per-clone `.git/hooks`, which is not shared to worktrees — this is the seam handled by **ADR-005**.

**Follow-up decisions:**
- Review-flow alignment: `/g-review` currently reviews `git diff main...HEAD` (committed history) while the sentinel is consumed by the next staged commit. Content-binding is only coherent when review and commit concern the same tree — decide whether `/g-review` stamps the HEAD tree it reviewed and the workflow commits that tree, or moves to a `--staged` review. Resolve before coding.
- First-commit / empty-repo has no HEAD to stamp or compare — special-case it without opening a "no-HEAD ⇒ pass" hole (fail toward deny).
- Whether the residual staleness case (identical-tree re-commit) needs any handling beyond the folded check.
- Rollout under installed-copy drift (#5): a new hash-checking hook + an old `/g-review` writing literal `approved` blocks every commit (or vice-versa). Sequence stamper, both verifiers, and the #5 drift check together.

**Risks:** stamper/verifier hash-method skew under installed-copy drift → deny-storm or silent pass (mitigate: ship together, pin with fail-before/pass-after fixtures). Spurious invalidation: HEAD-advance also fires on checkout/reset/rebase (re-review churn), and `git reset --soft HEAD~1` can revive a consumed sentinel. Honest framing: the tree hash is publicly recomputable, so the sentinel can be hand-stamped — content-binding is ~100% against accidents and ~0% against intent; user-facing copy must not imply more.

## Rejected Alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Advice-only / docs warning | Leaves both holes silent; claim stays false. |
| Either-half-only (content or staleness) | Half a fix; leaves the other named hole open. |
| HMAC-signed sentinel | No secret store; wrong threat model; new-deps constraint. |
| Server-side `pre-receive` | Can't gate a local commit; can't see a local sentinel; needs infra. |
| Hashing inside PreToolUse as the binding site | Runs before staging — cannot see `-a`/`-p`; hashes the wrong tree. |
| mtime anchor / diff hash | Not reproducible across stamper and gate. |

## Assumptions That Held

- **`git write-tree` on the staged index in a `pre-commit` hook is a stable, reproducible identifier of what will be committed.** Fragile on an unmerged/conflicted index (must fail toward deny) and requires the stamper to have computed the identical identifier.
- **HEAD-advance is a sound proxy for "this sentinel was consumed."** Fragile: it also moves on checkout/reset/rebase (spurious re-review) and can move back on `reset --soft` (revival). It proxies "history changed," which is why content-binding — not staleness alone — is the primary guarantee.
- **`/g-review` and the hook share one hashing method.** Fragile: they install from different files at different times; finding #5 already proved installed copies drift. Fail-toward-deny must cover the skew that drift doesn't.
- **The tree the sentinel stamps is the tree the next commit gates.** Holds only once the review-flow follow-up is resolved (main...HEAD vs staged).
- **The raw-terminal committer is the leak, not a determined bypass; the gate is a discipline aid, not a security boundary.** Honest for accidents; the ADR and docs must not oversell it.

## Resolution — review-flow alignment (2026-07-14)

The open follow-up ("`/g-review` reviews `git diff main...HEAD` while the sentinel gates the *next staged* commit — resolve before coding") is closed. Verified live on this repo: `/g-execute` never commits mid-wave (HQ commits once, after MERGE READY), so at review time there is normally **nothing** on `main...HEAD` yet — the whole wave's work is sitting staged/unstaged, and `skills/g-review/SKILL.md`'s existing `--staged` line was already the common-case fallback, not the edge case.

**Decision:** flip `/g-review`'s primary review target to the staged tree — `git diff --staged` unioned with unstaged-but-tracked modifications (the same union `check-commit.sh`'s `-a`/`--all` handling already computes), matching exactly what `git write-tree` will hash at commit time. `/g-review` stamps the sentinel with the `write-tree` hash of *that* reviewed tree plus HEAD sha. `main...HEAD` is retained only as a fallback for the edge case of resuming review on a branch that already carries committed-but-unreviewed history (e.g. an interrupted multi-commit session) — same fallback role it plays today, priority inverted.

This makes the reviewed tree and the gated tree the same tree by construction, rather than by accident — the sentinel's `write-tree` binding (this ADR's core mechanism) only holds if the two ever compute over the same input.

**Scope for implementation:** one change to `skills/g-review/SKILL.md`'s diff-target step (swap primary/fallback order + widen the primary target to the `-a`-union); no change to `check-commit.sh`'s classifier logic. Pin with a fail-before/pass-after test: reviewing a wave with only staged+unstaged changes (no prior commit on the branch) currently produces an empty `main...HEAD` diff — after the fix it must produce the real diff.

## Constraints That Drove This Decision

- Portable POSIX shell, no new runtime deps beyond git and the existing jq→python3→node cascade → forces `git write-tree`/`git rev-parse` over any crypto.
- Fail toward enforcement on any ambiguity (empty/unknown/unparseable/no-HEAD/conflicted-index → deny), consistent with the existing gate.
- Must not break the two-sentinel CODE/DOC/mixed model — the stamp is carried and verified on both sentinels; mixed commits bind both to the same tree.
- Must be pinned by fail-before/pass-after tests like the rest of M-audit W1 (deterministic hash, no timestamps/random — aligns with the D-code-quality fixed-data testing rule).
- A local, in-session, commit-time gate is the load-bearing differentiator — enforcement must act before the local commit completes.
