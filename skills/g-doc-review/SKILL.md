---
name: g-doc-review
description: Documentation review gate. Dispatches the doc-reviewer agent on the changed file set to check documentation currency against the code it describes, then issues a standalone DOCS READY or DOCS HOLD verdict. On DOCS READY it writes the doc-approval sentinel that the commit gate checks for doc/mixed commits. Read-only on project content — it judges and gates, never writes docs. Distinct from /g-review (code review) and /g-docs (audits and generates docs).
context: [task, sprint]
---

**Announce:** "Using g-doc-review to run the documentation review gate."

You are running the documentation merge gate. It has its own verdict — **DOCS READY** or **DOCS HOLD** — separate from /g-review's code verdict. This skill judges documentation currency only; it never writes or fixes docs. Execute these steps in order.

## Step 1 — Determine the changed file set

Identify the set of files under review.

**If a path argument was provided** (e.g. `/g-doc-review src/services`):
- Restrict the review to files under that path. Skip the git detection below.

**If no argument was provided**, detect the changed set from git:
```
git diff --name-only main...HEAD
```
- If that output is empty, run: `git diff --name-only --staged`
- If both are empty, run: `git diff --name-only` (unstaged working-tree changes)
- If all three are empty, ask the developer: "No changes detected. What branch, commit range, or path should I review for documentation currency?" — wait for the answer.

From the changed set, separate:
- **Doc surfaces** — files carrying documentation: source files with exported/public symbols, module headers, `README*.md`, `CHANGELOG.md`, `g-docs/env-vars.md`, `g-docs/decisions/*.md`, OpenAPI specs (`openapi.yaml`/`openapi.json`/`swagger.json`).
- **Code-of-record** — the source files whose behaviour the docs must stay current with (function signatures, exported symbols, env var reads, route definitions, public API shape).

## Step 2 — Dispatch doc-reviewer

Dispatch the `doc-reviewer` agent (read-only). This gate calls doc-reviewer **directly** — review-orchestrator is for code review, not this gate. Provide in the prompt:

- The full changed file set from Step 1, split into **doc surfaces** and **code-of-record**.
- Instruction: "Verify documentation currency against the code it describes. For every changed public/exported symbol, check that its doc (JSDoc / docstring / doc comment) exists and matches the current signature and behaviour. For every changed env var read, README section, public route, or CHANGELOG-worthy change, check the corresponding documentation is present and accurate. Report findings as BLOCKING, WARNING, or PASS with `file:line` refs. Do not fix anything."
- The severity contract (so its verdict aligns with this gate):
  - **BLOCKING (→ DOCS HOLD):** a public/exported symbol or public API surface (route, SDK export, webhook/event schema) has missing documentation; documentation that **contradicts** the current code (stale signature, wrong param, removed behaviour still documented); an undocumented env var read by the app; a shipped user-facing change with no CHANGELOG entry.
  - **WARNING (advisory — still DOCS READY):** internal/private symbol lacking docs; module-header gap on an internal file; clarity or wording issues; minor incompleteness that does not mislead.
- `output_file: g-docs/agent-output/review/doc-reviewer-[YYYY-MM-DD].md`

Wait for doc-reviewer's complete report. Parse its findings into BLOCKING vs WARNING.

## Step 3 — Derive the verdict

- **If doc-reviewer returned one or more BLOCKING findings → DOCS HOLD.**
- **If doc-reviewer returned only WARNING findings (or PASS) → DOCS READY.** WARNING findings are advisory and never block.

## Step 4 — Present verdict and manage the sentinel

Present doc-reviewer's findings to the developer verbatim, grouped BLOCKING / WARNING / PASS.

**If verdict is DOCS READY:**
- Create the `.claude/` directory if it does not exist.
- Compute the sentinel stamp (binds the sentinel to the exact reviewed tree — ADR-004, same format `/g-review` uses for the code sentinel):
  - `commit_sentinel_ts`: `git write-tree` of the currently-staged index (the tree just reviewed in Step 1/2)
  - `commit_sentinel_head`: `git rev-parse HEAD`
  - `commit_sentinel_worktree`: `git rev-parse --show-toplevel`
- Write `.claude/g-forge-docs-approved` with content: `commit_sentinel_ts=<write-tree output> commit_sentinel_head=<rev-parse HEAD output> commit_sentinel_worktree=<show-toplevel output>` (one line, space-separated `key=value` fields, exact field names — do not rename them)
- If this review covered code/mixed changes and `.claude/g-forge-approved` is also being written (see `/g-review`), the two sentinels should carry the identical stamp — both bind to the one tree being committed.
- Tell the developer: "DOCS READY. Documentation gate open — the doc/mixed-commit gate is satisfied for these changes."
- If any WARNING findings were reported, list them as advisory follow-ups and note: "These do not block. Run `/g-docs <path>` or dispatch `doc-writer` to close them."

**If verdict is DOCS HOLD:**
- Do **NOT** write `.claude/g-forge-docs-approved`.
- List every BLOCKING finding with its `file:line` ref and what is missing or contradicted.
- Recommend the fix path — `/g-docs <path>` to audit-and-generate, or `doc-writer` to fill a specific gap — but do not run it from this skill.
- Stop with: "DOCS HOLD. Fix every blocking item above, then re-run `/g-doc-review`."

## Rules
- This skill is **READ-ONLY on project content** — it judges and gates only. It never writes, edits, or generates documentation. The **only** file it writes is the `.claude/g-forge-docs-approved` sentinel, and only on DOCS READY.
- To fix gaps, recommend `/g-docs` or the `doc-writer` agent — never perform doc edits here, and never dispatch doc-writer from this gate.
- Never write `.claude/g-forge-docs-approved` for anything other than a DOCS READY verdict.
- Public-API / exported-symbol doc gaps and contradicts-code findings are **BLOCKING** → DOCS HOLD. Internal-only gaps and clarity issues are **WARNING** → advisory, still DOCS READY.
- This is the documentation gate. It is distinct from `/g-review` (code-review gate, sentinel `.claude/g-forge-approved`) and from `/g-docs` (which audits and generates docs). Do not run code review or the test suite here.
- Never modify doc-reviewer's findings — present them exactly as returned.
- Dispatch `doc-reviewer` directly; do not route through `review-orchestrator` (that pipeline is for code).
- The sentinel is cleared automatically after the next `git commit` by the commit hook — re-run this gate for the next change set.
