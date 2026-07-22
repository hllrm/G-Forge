## Claude Code Plugin Architecture Rules

**Layer map:**
- `commands/` — exactly one file, `commands/g-forge.md`, the single umbrella router (per [ADR-007](../../../g-docs/decisions/007-one-command-per-skill-retire-shims.md)): a bare-token subcommand list that routes to `skills/<name>/SKILL.md`; no per-skill prose or descriptions; no hardcoded logic; no Skill() calls. Standalone per-skill command files (`commands/<name>.md`) are retired — their presence anywhere in `commands/` is a violation.
- `skills/<name>/SKILL.md` — multi-step workflow instructions; no Skill() invocations; must have Announce line and Rules section; no argument-hint in frontmatter
- `agents/` — specialist .md agents; Read, Glob, Grep tools only; output findings, never fixes; must include name, description, model, tools frontmatter
- `profiles/<stack>/` — stack architect agent + architecture rules; installed per-project by /g-specialize; architect agent must be read-only
- `hooks/` — standalone bash scripts; read stdin JSON; exit 1 to block; no Claude runtime dependency; must have #!/bin/bash shebang. Two contract classes coexist here — see the hook-class note below.
- `.claude-plugin/` — plugin.json + marketplace.json; schema-valid; version numbers must match across both files

**Note — two hook classes:** (a) Claude Code plugin hooks — registered in `.claude/settings.json`, read stdin JSON, deny = JSON deny object on stdout + `exit 2` for PreToolUse; (b) native git hooks — `hooks/pre-commit`, installed into the git hooks directory, no stdin JSON, deny = stderr message + `exit 1`. Both classes live under `hooks/`; the contract difference is load-bearing — using the wrong exit/deny convention silently fails open (the M-audit Bug-A class).

**Note — three installed-agent classes (`.claude/agents/`):** for drift-detection purposes, every installed agent file is one of: (a) **profile-copied** — sourced verbatim from `profiles/<stack>/agents/`, hash-comparable against that canonical source, mismatch = drift; (b) **template-instantiated** — generated from a template (e.g. `templates/stack-implementer.md` → `claude-plugin-implementer`), no byte-canonical source to compare against, checks are advisory-only; (c) **project-local** — `*-dev.md` per the runner convention (e.g. `g-forge-dev`), no canonical source, excluded from drift checks entirely.

**Skill rule:** Every SKILL.md must have: YAML frontmatter (name + description, plus an optional `context:` key declaring memory layers per G-RULES §J, e.g. `context: [task, sprint]` — no `argument-hint`), `**Announce:**` line immediately after frontmatter, numbered steps (`## Step N —`), and a `## Rules` section. No Skill() tool calls anywhere in skill files.

**Agent rule:** Agents are reviewers only. Tools: Read, Glob, Grep — never Write, Edit, or Bash. Must include name, description, model, tools in frontmatter (`context:` optional, same G-RULES §J memory-layer declaration). Output format must distinguish BLOCKING, WARNING, and PASS findings.

**Command rule:** `commands/` holds exactly one hand-maintained file, `commands/g-forge.md` — the single router. Its subcommand list is bare tokens only (no per-skill prose/descriptions); at dispatch it Globs+Reads the corresponding `skills/<name>/SKILL.md`. Per-skill command shims are retired per ADR-007 — a standalone `commands/<name>.md` file is a violation, not a redundant-but-harmless file.

**Version rule:** `.claude-plugin/plugin.json` version and `marketplace.json` plugin version must be identical on every release.
