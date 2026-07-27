# Transitional rules (time-boxed — read the sunset condition)

**This file is the canonical source of the transitional-rules section. `CLAUDE.md` `@`-imports it and holds no copy of the text.** `CLAUDE.md` is a gitignored install artifact in this repo (`.gitignore`), so a live process rule written directly into it survives only a folder copy — and that has already failed once (the file was lost and hand-regenerated 2026-07-10). Rules live here, in committed `g-docs/`, and reach the session through the import. Editing this file is how a transitional rule changes; editing the CLAUDE.md side is how a transitional rule gets lost.

Rules in this file exist **only for the G-Forge → G-Proof transformation** ([ADR-010](decisions/010-full-rebuild-on-current-platform.md)). Each carries an activation and a sunset condition. A transitional rule that outlives its condition is cruft — retire or promote it deliberately at sunset, never by default.

---

## T1 — Core-functionality check at every review

| | |
|---|---|
| **Active from** | the fork (this repo copied into a new repo to start **G-Proof**). Inert until then — v2.5 here is frozen and not being transformed. |
| **Sunset when** | **G-Proof 1.0** is released — its first release, per the version identity in [ADR-010](decisions/010-full-rebuild-on-current-platform.md) and `project_brief.md:54` (versioning restarts under the new name; no `3.0.0`). Continuous transformation ends there; so does the reason for this rule. |
| **Rule** | `/g-doctor` runs **inside the review process**, not only at health-check time. The review pipeline takes its report as an input, and `code-lead` may HOLD on incoherence. `/g-doctor`'s role is unchanged — same checks, same read-only report; what is new is when it runs and who consumes it. The verdict stays where verdicts already live. |
| **Why** | Under continuous transformation the dangerous failure is not a wrong diff, it is the system quietly ceasing to be whole: a hook present but unregistered, a router token pointing at a deleted skill, a lib nobody sources, a caller deleted while its callee sits there looking alive. Diff review cannot see any of it. |
| **At sunset** | Decide explicitly — retire, or promote to a permanent review step. Do not let it lapse silently, and do not let it persist unexamined. |

**Tripwires.** *On:* wiring the `@`-import into the forked repo's `CLAUDE.md` is a first-act item on the fork checklist — miss it and the rule silently never activates. The fork copies this file by git, so the *rule* survives regardless; what needs wiring is the import that makes a session read it. *Off:* **implemented.** `skills/g-trim/SKILL.md:18` now follows every existing `@`-import target and audits its content, and explicitly scans each target for "any stated sunset or activation condition", flagging it if the condition reads as already met or ambiguous. `CLAUDE.md` `@`-imports this file (via the @g-docs/transitional-rules.md import in the repo's CLAUDE.md), so the T1 sunset detector exists. The remaining R0 fork-checklist item is confirming `/g-trim` survives the rebuild first — the rebuild map has it shrinking, not dying.
