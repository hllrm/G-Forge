---
name: g-skill-design
description: Design a new G-Forge skill from scratch. Gathers requirements, drafts SKILL.md with correct structure, and adds a single bare-token routing line to the g-forge router.
---

**Announce:** "Using g-skill-design to design the new skill."

You are designing a new G-Forge skill. Follow these steps in order.

## Step 1 — Understand the skill's purpose

Ask the developer:

> "What should this skill do? Describe:
> 1. The trigger — what user action or workflow state invokes it?
> 2. The output — what does running this skill produce? (files, reports, modified state, user guidance)
> 3. The name — what will the skill be called? (e.g. `foo` → `skills/g-foo/SKILL.md`, invoked directly as its own entry or via `/g-forge foo`)"

Wait for answers before continuing.

## Step 2 — Check for existing similar skills

Use Glob to list `skills/*/SKILL.md`. Read the `description:` line from the frontmatter of each. If a skill with substantially similar purpose already exists, tell the developer:

> "A similar skill already exists: [name] — [description]. Should we extend that one or create a new one?"

Wait for answer. If extending, stop here and provide notes on what to change; do not write a new file.

## Step 3 — Draft the skill steps

From the developer's answers, draft the numbered steps the skill will follow. Each step must:
- Have a clear single responsibility (read, ask, draft, write, dispatch, or report)
- Specify wait points (when to pause for user input before proceeding)
- Not invoke the Skill() tool (use Glob+Read on the target SKILL.md instead)
- Not write a file before reading it first

Present the step outline to the developer:

> "Here is the proposed step outline — does this match what you want?"

Wait for approval or revision before writing anything.

## Step 4 — Write the SKILL.md

Write `skills/g-[name]/SKILL.md` with this structure:

```
---
name: g-[name]
description: [One sentence: what it does and when to use it.]
---

**Announce:** "Using g-[name] to [purpose]."

[Intro sentence describing what this skill does.]

## Step 1 — [Verb phrase]
[Step body]

## Step 2 — [Verb phrase]
[Step body]

[... remaining steps ...]

## Rules
- [Rule protecting against the most common mistake]
- [Rule protecting against the second most common mistake]
[... additional rules as needed ...]
```

**Required elements — verify before writing:**
- YAML frontmatter with `name:` and `description:` only (no `argument-hint`)
- `**Announce:**` line immediately after the closing `---` of frontmatter
- All steps numbered `## Step N — [Verb phrase]`
- At least one rule in `## Rules`
- No Skill() tool invocations anywhere in the file
- No hardcoded absolute paths (use Glob to discover dynamic paths)

## Step 5 — Add a bare-token routing line to the g-forge router

Read `commands/g-forge.md`. Make two additions only — no per-skill prose (ADR-007: prose in the router re-opens the drift axis the ADR closed):

1. In the `argument-hint` value: append `|[name]` to the pipe-separated list
2. In the routing table: add a new bare-token line `- \`[name]\`       → \`skills/g-[name]/SKILL.md\`` — no description, no prose

Do not add anything to the subcommand description list at the bottom for the new skill.

Write the updated file.

## Step 6 — Report

```
Skill created ✓

  ✓ skills/g-[name]/SKILL.md — skill workflow written
  ✓ commands/g-forge.md      — bare-token router line added

Run /g-skill-validate [name] to validate the new skill's structure.
```

## Rules
- Never write SKILL.md before Step 3 approval — the step outline must be confirmed first.
- Never use Skill() tool invocations in the generated SKILL.md.
- Never add argument-hint to SKILL.md frontmatter.
- If a similar skill already exists, surface it before drafting — do not create duplicates.
- Never create a companion `commands/g-[name].md` file — per ADR-007, `skills/g-[name]/SKILL.md` is the sole authored source; only a bare-token routing line is added to `commands/g-forge.md`.
- The router addition must be a bare token — no prose, no description — and must not touch the subcommand description list.
- Router update must preserve all existing entries — read before writing.
