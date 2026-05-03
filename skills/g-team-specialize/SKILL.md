---
name: g-team-specialize
description: Detect the project stack and write the matching profile agents and architecture rules into .claude/agents/ and CLAUDE.md. Accepts an optional stack argument to skip detection. Supported stacks: vue-pinia, node-ts, fastapi.
argument-hint: [stack]
---

**Announce:** "Using g-team-specialize to apply the stack profile."

You are wiring a stack-specific architect agent into this project. The agent file and rules will be project-native after this runs — no plugin dependency required.

## Step 1 — Determine the stack

**If a stack argument was provided** (e.g. `/g-team specialize vue-pinia`), skip detection and use the provided value. Validate it is one of: `vue-pinia`, `node-ts`, `fastapi`. If not, tell the developer: "Unknown stack. Supported: vue-pinia, node-ts, fastapi."

**If no argument was provided**, detect the stack by reading these files in the current working directory (if they exist):

- `package.json` — read `dependencies` and `devDependencies`
  - Contains `vue` → candidate: `vue-pinia`
  - Contains `pinia` alongside `vue` → confirm `vue-pinia`
  - Contains none of the above, but has `typescript` or `ts-node` → candidate: `node-ts`
  - Contains `express`, `fastify`, `koa`, or `hono` → confirm `node-ts`
- `requirements.txt` or `pyproject.toml` — read contents
  - Contains `fastapi` → confirm `fastapi`
  - Contains `flask` or `django` → tell developer: "Detected Flask/Django. G-Team does not have a profile for this stack yet. Supported: vue-pinia, node-ts, fastapi."

If detection is ambiguous or no match found, ask the developer:
> "I couldn't auto-detect your stack. Which profile should I apply? Options: vue-pinia, node-ts, fastapi"

Once the stack is determined, present:
> "Detected stack: [stack]. I'll write the [agent-name] agent to `.claude/agents/` and append architecture rules to `CLAUDE.md`. Continue? (y/n)"

Wait for confirmation.

## Step 2 — Locate the profile files

The profile files live in the g-team plugin directory. The base directory of this skill is shown at the top of your context as "Base directory for this skill: [path]".

Navigate from that path: go up two directory levels to reach the plugin root, then look in `profiles/[stack]/`.

For example, if the base directory is `/home/user/.claude/plugins/cache/hllrm-g-team/skills/g-team-specialize`, the plugin root is `/home/user/.claude/plugins/cache/hllrm-g-team/` and the vue-pinia profile is at `/home/user/.claude/plugins/cache/hllrm-g-team/profiles/vue-pinia/`.

Read:
- `profiles/[stack]/agents/[agent-name].md` — the architect agent file
- `profiles/[stack]/rules/architecture.md` — the architecture rules

Stack → agent file mapping:
- `vue-pinia` → `profiles/vue-pinia/agents/vue-architect.md`
- `node-ts` → `profiles/node-ts/agents/node-architect.md`
- `fastapi` → `profiles/fastapi/agents/fastapi-architect.md`

## Step 3 — Write agent to .claude/agents/

Create `.claude/agents/` directory if it does not exist.

Write the agent file content (read in Step 2) to `.claude/agents/[agent-name].md`.

Agent filename mapping:
- `vue-pinia` → `.claude/agents/vue-architect.md`
- `node-ts` → `.claude/agents/node-architect.md`
- `fastapi` → `.claude/agents/fastapi-architect.md`

If the file already exists, read it first. If it already contains the correct content (same `name:` field in frontmatter), tell the developer: "[agent-name] is already installed. Overwrite? (y/n)" and wait for confirmation before proceeding.

## Step 4 — Append architecture rules to CLAUDE.md

Read `CLAUDE.md` in the current project root. If it does not exist, create it with just a `# [Project]` header first.

Check whether the architecture rules are already present by searching for the marker `<!-- G-Team [stack] Architecture Rules -->`. If found, tell the developer: "Architecture rules for [stack] already in CLAUDE.md. Skipping rules append." and skip this step.

If not present, append this block at the end of CLAUDE.md:

```
<!-- G-Team [stack] Architecture Rules — injected by /g-team specialize. Do not edit manually. -->
[full content of profiles/[stack]/rules/architecture.md]
<!-- End G-Team [stack] Architecture Rules -->
```

## Step 5 — Report

```
[stack] profile applied ✓

  ✓ .claude/agents/[agent-name].md — architect agent installed
  ✓ CLAUDE.md — architecture rules appended

The [agent-name] agent is now project-native. It will appear in Claude Code's agent list.
To use it: dispatch [agent-name] in any review or planning task that touches [stack] code.
```

## Rules
- Never overwrite an existing agent without user confirmation.
- Never write any file before the developer confirms the stack in Step 1.
- Profile files are read from the plugin directory — never embedded or hardcoded here.
- If the plugin directory cannot be located, tell the developer the expected path and ask them to verify the plugin is installed.
