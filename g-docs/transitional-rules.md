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

**Tripwires.** *On:* wiring the `@`-import into the forked repo's `CLAUDE.md` is a first-act item on the fork checklist — miss it and the rule silently never activates. The fork copies this file by git, so the *rule* survives regardless; what needs wiring is the import that makes a session read it. *Off:* **not yet implemented — do not rely on it.** `/g-trim`'s audit *subjects* are `CLAUDE.md` and agent memory (`skills/g-trim/SKILL.md:3`); it reads no `g-docs/` file carrying a sunset condition, so it cannot see this one. (It does already read `g-docs/project_brief.md` as ground truth at `:16` — that is the existing read path a scope-add would extend, not a gap to create from nothing.) Moving T1 out of `CLAUDE.md` therefore moved it out of the audit's subject set, so the sunset detector is currently *weaker* than before the extraction, not stronger. Scope-adding `/g-trim` to cover this file is an R0 fork-checklist item (and confirm `/g-trim` survives the rebuild first — the rebuild map has it shrinking, not dying). Until that lands, the only thing standing between a fired sunset and permanent cruft is someone reading this file.
