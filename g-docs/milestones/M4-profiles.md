# M4 — Stack Profiles

## Goal
`/g-team specialize` detects the project stack and installs a stack-specific architect agent + architecture rules. Three profiles ship at launch: vue-pinia, node-ts, fastapi.

## Done condition
- `skills/g-team-specialize/SKILL.md` is implemented (no stub text, valid frontmatter)
- `profiles/vue-pinia/agents/vue-architect.md` exists with valid frontmatter (`name`, `model`)
- `profiles/vue-pinia/rules/architecture.md` exists and is non-empty
- Same for `node-ts` and `fastapi`

## Scope
- [x] `/g-team specialize` skill — stack detection + profile copy
- [x] vue-pinia profile — vue-architect agent + architecture rules
- [x] node-ts profile — node-architect agent + architecture rules
- [x] fastapi profile — fastapi-architect agent + architecture rules

## Status
✅ Done
