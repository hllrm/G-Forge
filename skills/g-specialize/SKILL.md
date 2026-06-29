---
name: g-specialize
description: Determine which stack profiles to apply by reading the project brief, roadmap, and dependency files. Handles multi-stack projects. Detects known stack combos and installs combo architecture rules covering emergent cross-stack patterns. Consults code-lead when the picture is ambiguous or risky. Installs architect agents, a write-side implementer agent per stack, and architecture rules. Supported stacks: angular, asp-net-core, astro, bun, c-embedded, capacitor, cpp-cmake, django, electron, express, fastapi, flask, flutter, go-fiber, go-gin, godot-csharp, godot-gdscript, hono, kotlin-android, kotlin-ktor, laravel, maui, nest-js, next-js, node-ts, nuxt, phoenix-liveview, pygame, python-cli, python-data, python-ml, python-textual, rails, react, react-native, remix, rust-axum, rust-cli, spring-boot, sveltekit, swift-ios, tauri, unity, unreal, vue-pinia, wpf-csharp, xamarin, claude-plugin. Supplementary: frontend-data-flow (auto-installed alongside component frameworks).
---

**Announce:** "Using g-specialize to apply the stack profile."

You are wiring stack-specific agents into this project: an **architect** (read-side, reviews for layer violations) and an **implementer** (write-side, executes wave tasks in the stack's idioms) for each detected stack, plus the architecture rules both rely on. The agent files and rules will be project-native after this runs — no plugin dependency required.

## Step 1 — Gather context

Build a picture of the project's stack and integrations from all available sources. Read every source that exists — skip silently if a file is absent.

**Source 1 — project_brief.md (highest confidence)**

Read `project_brief.md` if it exists. Extract:
- The "Tech decisions" table — each row is a confirmed stack component
- The "Technical constraints" section if present
- Any stack names mentioned in the text

Note every distinct runtime/framework/language. A project might have multiple (e.g., Vue 3 frontend + FastAPI backend in a monorepo).

**Source 2 — ROADMAP.md**

Read `ROADMAP.md` if it exists. Look for tech mentions in milestone descriptions or backlog items that indicate planned stack additions not yet in deps.

**Source 3 — Dependency files**

Read whichever of these exist in the current working directory:

- `package.json` — check `dependencies` and `devDependencies`:
  - `vue` + `pinia` → **vue-pinia**
  - `next` → **next-js**
  - `nuxt` → **nuxt**
  - `@sveltejs/kit` → **sveltekit**
  - `@angular/core` → **angular**
  - `astro` → **astro**
  - `@remix-run/react` → **remix**
  - `react-router` AND (`@react-router/dev` in devDependencies OR `react-router.config.ts` exists) → **remix** (React Router v7 framework mode — same architecture as Remix v2)
  - `react-native` or `expo` → **react-native**
  - `react` (no next/remix/native) → **react**
  - `express` → **express**
  - `@nestjs/core` → **nest-js**
  - `hono` → **hono**
  - `elysia` → **bun**
  - `electron` → **electron**
  - `@tauri-apps/api` → **tauri**
  - `@capacitor/core` → **capacitor**
  - `typescript` + (`express` or `fastify` or `koa`) without above → **node-ts**

- `requirements.txt` or `pyproject.toml` — read full contents:
  - `fastapi` → **fastapi**
  - `django` or `djangorestframework` → **django**
  - `flask` → **flask**
  - `pygame` → **pygame**
  - `textual` → **python-textual**
  - `click` or `typer` → **python-cli**
  - `torch` or `tensorflow` or `scikit-learn` → **python-ml**
  - `pandas` or `polars` or `sqlalchemy` (no web framework) → **python-data**

- `Cargo.toml` — read full contents:
  - `axum` → **rust-axum**
  - `clap` or `indicatif` or `dialoguer` (no axum) → **rust-cli**
  - `tauri` → **tauri** (Rust side of Tauri project)

- `build.gradle` or `pom.xml` or `build.gradle.kts`:
  - `spring-boot` / `org.springframework.boot` → **spring-boot**
  - `ktor` → **kotlin-ktor**
  - `androidx.compose` → **kotlin-android**

- `*.csproj` or `*.sln`:
  - `Microsoft.AspNetCore` → **asp-net-core**
  - `PresentationFramework` → **wpf-csharp**
  - `Microsoft.Maui` → **maui**
  - `Xamarin.Forms` (without `Microsoft.Maui`) → **xamarin** (legacy — Xamarin.Forms reached end-of-support May 2024; flag this to the developer with a migration-to-MAUI note)

- `pubspec.yaml`:
  - `flutter:` SDK entry → **flutter**

- `CMakeLists.txt` — presence suggests **cpp-cmake**

- `*.gd` files or `project.godot`:
  - GDScript files → **godot-gdscript**
  - C# files in Godot project → **godot-csharp**

- `*.unity` or `Assets/` with `*.cs` files → **unity**

- `*.uproject` → **unreal**

- `Package.swift` with iOS targets → **swift-ios**

- `.claude-plugin/plugin.json` — if this file exists, this is a Claude Code plugin project → **claude-plugin**
- `plugin.json` — if the `$schema` field contains `claude-code-plugin` → **claude-plugin**

**Synthesise:**

After reading all sources, build this picture:
```
Stacks detected:    [list — e.g. vue-pinia, fastapi]
Source confidence:  [brief / deps / roadmap / inferred]
Unsupported stacks: [list — e.g. django]
Conflicts:          [e.g. "brief says Vue 3, no package.json found yet"]
Profiles to apply:  [list of supported stacks to install]
Combos detected:    [list of combo keys, or "none"]
```

**Combo detection:**

After building the `Profiles to apply` list, sort the detected stack names alphabetically and check for known combos:

| Combo key            | Required stacks             | Emergent patterns covered                                                         |
|----------------------|-----------------------------|-----------------------------------------------------------------------------------|
| `electron-react`     | electron + react            | contextBridge API layer, IPC channel constants, cross-window state                |
| `electron-vue-pinia` | electron + vue-pinia        | contextBridge + Pinia IPC integration, cross-window state                         |
| `react-tauri`        | react + tauri               | `invoke()` typed API layer, Tauri event hooks in React, capability scoping        |
| `tauri-vue-pinia`    | tauri + vue-pinia           | `invoke()` typed API layer, Pinia + Tauri event subscriptions, capability scoping |
| `astro-react`        | astro + react               | Island isolation, serializable prop contract, cross-island state via nanostores, React hydration directives |
| `astro-vue`          | astro + vue-pinia           | Island isolation, serializable prop contract, cross-island state via nanostores, Vue hydration directives  |
| `astro-svelte`       | astro + sveltekit           | Island isolation, serializable prop contract, native Svelte store sharing across islands, hydration directives |

If any detected stacks fully cover a combo's required stacks, add that combo key to `Combos detected`. Combo profiles install rules only — no architect agent.

**Supplementary profile auto-detection — `frontend-data-flow`:**

If `Profiles to apply` contains any component-framework stack — `react`, `vue-pinia`, `nuxt`, `next-js`, `sveltekit`, `angular`, `remix`, `astro`, or any astro-* combo — also add `frontend-data-flow` to the apply list. This is a **supplementary** profile: it ships its own architect agent (`frontend-data-flow-architect`) and rules file (`profiles/frontend-data-flow/rules/architecture.md`), and it covers the universal two-network frontend data-flow model (read network + write network) plus the four canonical violations (HTTP in components, shadow-state ref sync, watch-as-dispatch, caller-follows-truck). It complements the per-framework architect — never replaces it. Surface it in confirmation as `+ frontend-data-flow (supplementary, auto-installed alongside component frameworks)`.

## Step 2 — Research current stable/LTS state

For each stack in `Profiles to apply`, run a WebSearch to verify the current stable and LTS version and identify any best-practice changes that may not be reflected in the installed profile.

**Search queries to run (in parallel, one pair per stack):**
- `"[stack] stable release [current year]"`
- `"[stack] best practices [current year]"`

**Scope rules — strict:**
- Only consider releases tagged as **stable**, **LTS**, or **GA (generally available)**.
- Ignore anything labelled alpha, beta, RC, canary, nightly, preview, experimental, or unreleased.
- If the only available information is pre-release, skip and note: "No stable/LTS data found — profile defaults apply."

**Extract per stack (skip if not found in stable/LTS sources):**
- Current stable version number (and LTS version if the ecosystem tracks both separately)
- Any **breaking changes or major deprecations** since the prior major version — only if they affect recommended code patterns (file structure, API surface, idioms)
- Any **updated recommended patterns** that differ from what the profile likely captures (e.g., a new router API replacing the old one, a new state management recommendation, a compiler option that is now the default)

**Do not extract:**
- Changelogs, release notes verbatim, or lists of bug fixes
- Minor patch details
- Anything still behind a feature flag or opt-in experimental API

**Synthesise into a version note per stack:**

```
[stack] — stable [version] (LTS: [version or "same"])
Notable since last major:
  • [change 1 — one line, code-impact only]
  • [change 2]
  (or: "No material pattern changes found.")
```

If a stack returns no stable-version data after searching, note `"stable version not confirmed — profile defaults apply"` and continue.

Store all version notes for use in Step 3 (confirmation) and Step 7 (agent installation).

## Step 3 — Handle edge cases before confirming

**If an explicit stack argument was provided** (e.g. `/g-specialize vue-pinia`):
- Validate it is one of the supported stacks listed in the description frontmatter. If not, say: "Unknown stack '[arg]'. Run `/g-specialize` with no argument to auto-detect, or pick from the supported list." and stop.
- Use this as the confirmed profile list, skipping further detection.

**If no brief and no dependency files exist:**
- Ask the developer: "I couldn't find a project_brief.md or any dependency files. Which profile(s) should I apply? Supported stacks: angular, asp-net-core, astro, bun, c-embedded, capacitor, cpp-cmake, django, electron, express, fastapi, flask, flutter, go-fiber, go-gin, godot-csharp, godot-gdscript, hono, kotlin-android, kotlin-ktor, laravel, maui, nest-js, next-js, node-ts, nuxt, phoenix-liveview, pygame, python-cli, python-data, python-ml, python-textual, rails, react, react-native, remix, rust-axum, rust-cli, spring-boot, sveltekit, swift-ios, tauri, unity, unreal, vue-pinia, wpf-csharp, xamarin."
- Wait for answer. Use it as the confirmed profile list.

**If unsupported stacks were detected:**
- Note them in the confirmation: "I detected [stack] which doesn't have a G-Forge profile yet. I'll skip that one."

**If the picture is ambiguous or there are conflicts:**

Ambiguous means: stacks detected from different sources that don't agree, or a brief that mentions a stack with no corresponding deps and no clear explanation.

Before asking the user, dispatch `code-lead` with:
- The synthesised picture from Step 1
- The relevant excerpt from project_brief.md (tech decisions table if present)
- The dependency file contents

Ask code-lead:
> "Based on this project's brief and dependencies, which G-Forge stack profiles should be applied? The supported profiles are: angular, asp-net-core, astro, bun, c-embedded, capacitor, cpp-cmake, django, electron, express, fastapi, flask, flutter, go-fiber, go-gin, godot-csharp, godot-gdscript, hono, kotlin-android, kotlin-ktor, laravel, maui, nest-js, next-js, node-ts, nuxt, phoenix-liveview, pygame, python-cli, python-data, python-ml, python-textual, rails, react, react-native, remix, rust-axum, rust-cli, spring-boot, sveltekit, swift-ios, tauri, unity, unreal, vue-pinia, wpf-csharp, xamarin. If the project is multi-stack, list all that apply. Flag anything that looks like a mismatch or a risky stack choice. Note that frontend-data-flow is a supplementary profile that I auto-install alongside any component framework — do not list it as a primary stack."

Present code-lead's response to the developer: "Here is code-lead's stack read — does this match what you're building?"

**If the brief lists a stack with a code-lead risk flag (Medium or High):**
- Surface it to the developer before proceeding: "code-lead flagged [stack choice] as [risk level]: [reason]. Do you want to proceed with this profile, or reconsider the stack first?"
- Wait for answer. Proceed only after confirmation.

## Step 4 — Confirm with developer

Present the full list of profiles to apply:

```
Based on [brief / deps / your input], I'll apply these profiles:

  • vue-pinia  →  vue-architect + vue-implementer agents + Vue 3 + Pinia architecture rules
  • fastapi    →  fastapi-architect + fastapi-implementer agents + FastAPI architecture rules

And combo rules (if combos were detected):
  ↳ [combo-key]  →  [combo-key] combo architecture rules (no agent)

Current stable/LTS versions confirmed:
  [paste each stack's version note from Step 2 — omit stacks with no material changes]

This will:
  ✦ Write [N] architect + [N] implementer agent file(s) to .claude/agents/
  ✦ Append architecture rules for each stack to CLAUDE.md
  ✦ Append combo rules section(s) to CLAUDE.md (if combos apply)
  ✦ Append version notes to each installed architect agent

The implementer agents are the write-side counterparts to the architects: wave
execution routes implementation tasks in each stack to its implementer, so the
code written conforms to that stack's layer map instead of a generic executor.

Continue? (y/n)
```

Wait for confirmation before writing anything.

## Step 5 — Locate profile files

For each profile to apply:

**Check the current working directory first.** Use Glob to check if `profiles/<stack>/` exists locally:
```
profiles/<stack>/agents/*.md
```

If found, use these local files — this is the correct path when working inside the G-Forge plugin repo itself. Skip the plugin cache lookup.

**If not found locally**, use Glob to find the plugin root in the cache:
```
~/.claude/plugins/cache/g-forge/g-forge/*/skills/g-init/SKILL.md
```

The parent of the `skills/` directory is the plugin root. For example, if Glob returns `/home/user/.claude/plugins/cache/g-forge/g-forge/0.3.3/skills/g-init/SKILL.md`, the plugin root is `/home/user/.claude/plugins/cache/g-forge/g-forge/0.3.3/` and the vue-pinia profile is at `/home/user/.claude/plugins/cache/g-forge/g-forge/0.3.3/profiles/vue-pinia/`.

If neither the local directory nor the plugin cache contain the profile, tell the developer: "Could not find the profile files for '[stack]'. If this is a new profile, ensure it exists under profiles/<stack>/. Otherwise run `/plugin update g-forge` to refresh the cache." and stop.

Stack → file mapping (agent file + rules file):
- `angular`         → `profiles/angular/agents/angular-architect.md`               + `profiles/angular/rules/architecture.md`
- `asp-net-core`    → `profiles/asp-net-core/agents/asp-net-core-architect.md`     + `profiles/asp-net-core/rules/architecture.md`
- `astro`           → `profiles/astro/agents/astro-architect.md`                   + `profiles/astro/rules/architecture.md`
- `bun`             → `profiles/bun/agents/bun-architect.md`                       + `profiles/bun/rules/architecture.md`
- `c-embedded`      → `profiles/c-embedded/agents/c-embedded-architect.md`         + `profiles/c-embedded/rules/architecture.md`
- `capacitor`       → `profiles/capacitor/agents/capacitor-architect.md`           + `profiles/capacitor/rules/architecture.md`
- `cpp-cmake`       → `profiles/cpp-cmake/agents/cpp-cmake-architect.md`           + `profiles/cpp-cmake/rules/architecture.md`
- `django`          → `profiles/django/agents/django-architect.md`                 + `profiles/django/rules/architecture.md`
- `electron`        → `profiles/electron/agents/electron-architect.md`             + `profiles/electron/rules/architecture.md`
- `express`         → `profiles/express/agents/express-architect.md`               + `profiles/express/rules/architecture.md`
- `fastapi`         → `profiles/fastapi/agents/fastapi-architect.md`               + `profiles/fastapi/rules/architecture.md`
- `flutter`         → `profiles/flutter/agents/flutter-architect.md`               + `profiles/flutter/rules/architecture.md`
- `go-fiber`        → `profiles/go-fiber/agents/go-fiber-architect.md`             + `profiles/go-fiber/rules/architecture.md`
- `go-gin`          → `profiles/go-gin/agents/go-gin-architect.md`                 + `profiles/go-gin/rules/architecture.md`
- `godot-csharp`    → `profiles/godot-csharp/agents/godot-csharp-architect.md`     + `profiles/godot-csharp/rules/architecture.md`
- `godot-gdscript`  → `profiles/godot-gdscript/agents/godot-gdscript-architect.md` + `profiles/godot-gdscript/rules/architecture.md`
- `hono`            → `profiles/hono/agents/hono-architect.md`                     + `profiles/hono/rules/architecture.md`
- `kotlin-android`  → `profiles/kotlin-android/agents/kotlin-android-architect.md` + `profiles/kotlin-android/rules/architecture.md`
- `kotlin-ktor`     → `profiles/kotlin-ktor/agents/kotlin-ktor-architect.md`       + `profiles/kotlin-ktor/rules/architecture.md`
- `laravel`         → `profiles/laravel/agents/laravel-architect.md`               + `profiles/laravel/rules/architecture.md`
- `maui`            → `profiles/maui/agents/maui-architect.md`                     + `profiles/maui/rules/architecture.md`
- `nest-js`         → `profiles/nest-js/agents/nest-architect.md`                  + `profiles/nest-js/rules/architecture.md`
- `next-js`         → `profiles/next-js/agents/next-js-architect.md`               + `profiles/next-js/rules/architecture.md`
- `node-ts`         → `profiles/node-ts/agents/node-architect.md`                  + `profiles/node-ts/rules/architecture.md`
- `nuxt`            → `profiles/nuxt/agents/nuxt-architect.md`                     + `profiles/nuxt/rules/architecture.md`
- `phoenix-liveview`→ `profiles/phoenix-liveview/agents/phoenix-architect.md`      + `profiles/phoenix-liveview/rules/architecture.md`
- `python-cli`      → `profiles/python-cli/agents/python-cli-architect.md`         + `profiles/python-cli/rules/architecture.md`
- `python-data`     → `profiles/python-data/agents/python-data-architect.md`       + `profiles/python-data/rules/architecture.md`
- `python-ml`       → `profiles/python-ml/agents/python-ml-architect.md`           + `profiles/python-ml/rules/architecture.md`
- `python-textual`  → `profiles/python-textual/agents/python-textual-architect.md` + `profiles/python-textual/rules/architecture.md`
- `rails`           → `profiles/rails/agents/rails-architect.md`                   + `profiles/rails/rules/architecture.md`
- `react`           → `profiles/react/agents/react-architect.md`                   + `profiles/react/rules/architecture.md`
- `react-native`    → `profiles/react-native/agents/react-native-architect.md`     + `profiles/react-native/rules/architecture.md`
- `remix`           → `profiles/remix/agents/remix-architect.md`                   + `profiles/remix/rules/architecture.md`
- `rust-axum`       → `profiles/rust-axum/agents/rust-architect.md`                + `profiles/rust-axum/rules/architecture.md`
- `rust-cli`        → `profiles/rust-cli/agents/rust-cli-architect.md`             + `profiles/rust-cli/rules/architecture.md`
- `spring-boot`     → `profiles/spring-boot/agents/spring-architect.md`            + `profiles/spring-boot/rules/architecture.md`
- `sveltekit`       → `profiles/sveltekit/agents/sveltekit-architect.md`           + `profiles/sveltekit/rules/architecture.md`
- `swift-ios`       → `profiles/swift-ios/agents/swift-ios-architect.md`           + `profiles/swift-ios/rules/architecture.md`
- `tauri`           → `profiles/tauri/agents/tauri-architect.md`                   + `profiles/tauri/rules/architecture.md`
- `unity`           → `profiles/unity/agents/unity-architect.md`                   + `profiles/unity/rules/architecture.md`
- `unreal`          → `profiles/unreal/agents/unreal-architect.md`                 + `profiles/unreal/rules/architecture.md`
- `vue-pinia`       → `profiles/vue-pinia/agents/vue-architect.md`                 + `profiles/vue-pinia/rules/architecture.md`
- `wpf-csharp`      → `profiles/wpf-csharp/agents/wpf-architect.md`               + `profiles/wpf-csharp/rules/architecture.md`
- `claude-plugin`   → `profiles/claude-plugin/agents/claude-plugin-architect.md`   + `profiles/claude-plugin/rules/architecture.md`

Read both files for each profile before writing anything.

**Combo files** — rules only, no agent.

For each combo key in `Combos detected`, locate `profiles/<combo-key>/rules/architecture.md` using the same local-first / plugin-cache fallback as individual profiles.

Combo → file mapping:
- `electron-react`     → `profiles/electron-react/rules/architecture.md`
- `electron-vue-pinia` → `profiles/electron-vue-pinia/rules/architecture.md`
- `react-tauri`        → `profiles/react-tauri/rules/architecture.md`
- `tauri-vue-pinia`    → `profiles/tauri-vue-pinia/rules/architecture.md`
- `astro-react`        → `profiles/astro-react/rules/architecture.md`
- `astro-vue`          → `profiles/astro-vue/rules/architecture.md`
- `astro-svelte`       → `profiles/astro-svelte/rules/architecture.md`

Read the combo rules file before writing anything.

## Step 6 — Write agents to .claude/agents/

Create `.claude/agents/` directory if it does not exist.

For each profile:

Write the agent file content to `.claude/agents/[agent-name].md`.

Agent filename: use the filename of the agent file from the stack → file mapping above (e.g. `vue-architect.md`, `fastapi-architect.md`, `react-architect.md`). Write it to `.claude/agents/<filename>`.

If the file already exists, read it first. If the `name:` field in frontmatter matches, tell the developer: "[agent-name] is already installed. Overwrite? (y/n)" and wait for confirmation before proceeding.

**After writing each agent file**, append the stack's version note from Step 2 as a versioned addendum at the end of the file:

```
---
<!-- Stable/LTS version note — injected by /g-specialize, [date]. Do not edit manually. -->
[stack] stable [version] (LTS: [version or "same"])
Notable current patterns:
  • [change 1]
  • [change 2]
  (or: "No material pattern changes found — profile defaults apply.")
<!-- End version note -->
```

If no version note was produced for a stack (Step 2 returned no stable data), skip the addendum for that agent.

**Also after writing each agent file**, expose the architecture rules as a preloadable skill and wire it into the agent:

1. Create `.claude/skills/architecture-[stack]/` if it does not exist.
2. Write `.claude/skills/architecture-[stack]/SKILL.md` with the following frontmatter, then the full unmodified content of `profiles/[stack]/rules/architecture.md` as the body:
   ```
   ---
   name: architecture-[stack]
   description: [Stack] architecture rules and patterns. Preloaded into the [stack] architect agent at startup.
   ---
   ```
3. Re-read the agent file you just wrote to `.claude/agents/[agent].md`. Add a `skills` entry to its YAML frontmatter immediately before the closing `---` of the frontmatter block:
   ```yaml
   skills:
     - architecture-[stack]
   ```

Report per profile:
```
✓ .claude/skills/architecture-[stack]/SKILL.md — rules exposed as preloadable skill
✓ .claude/agents/[agent].md — skills: [architecture-[stack]] injected
```

**Also after writing each architect agent**, install the stack's **implementer** — the write-side counterpart to the architect. The architect reviews; the implementer writes code that conforms to the same rules. This is what makes wave execution stack-native: implementation tasks in this stack route to an agent that knows its layer map, not a generic executor.

1. Locate the implementer template `templates/stack-implementer.md` using the same local-first / plugin-cache fallback as the profile files (Step 5). Read it.
2. Derive the substitutions from the architect you just installed:
   - `{{IMPLEMENTER_NAME}}` — the architect's filename base with `-architect` replaced by `-implementer` (e.g. `vue-architect` → `vue-implementer`, `fastapi-architect` → `fastapi-implementer`, `nest-architect` → `nest-implementer`).
   - `{{ARCHITECT_NAME}}` — the architect's `name:` (e.g. `vue-architect`).
   - `{{STACK_LABEL}}` — the human stack label (e.g. `Vue 3 + Pinia`, `FastAPI`), the same label used in the Step 4 confirmation.
   - `{{ARCHITECTURE_SKILL}}` — `architecture-[stack]`, the skill created above.
3. Substitute all placeholders, strip the leading `<!-- ... -->` template-usage comment, and write the result to `.claude/agents/[implementer-name].md`. If a file with that `name:` already exists, ask "[implementer-name] is already installed. Overwrite? (y/n)" and wait, same as for the architect.

Report per profile:
```
✓ .claude/agents/[implementer-name].md — stack implementer installed (skills: architecture-[stack])
```

Combo profiles have no agent file — skip architect, implementer, and skill creation for any combo key in the install list.

## Step 7 — Install architecture rules

Architecture rules live in `.claude/rules/` as separate files. CLAUDE.md holds a one-line `@reference` per profile — never the full content inline. This keeps CLAUDE.md thin regardless of how many profiles are installed, and allows `/g-update` to refresh rules by writing files rather than surgically editing CLAUDE.md.

Create `.claude/rules/` if it does not exist.

Read `CLAUDE.md` in the current project root. If it does not exist, create it with just a `# [Project]` header first.

**For each profile in the install list:**

1. Copy `profiles/[stack]/rules/architecture.md` from the plugin to `.claude/rules/architecture-[stack].md` in the project. Overwrite if it already exists — rules files are G-Forge managed.

2. Check if `<!-- G-Forge [stack] Architecture Rules` is already present in CLAUDE.md.
   - If found: skip (already registered).
   - If not found: append:
     ```
     <!-- G-Forge [stack] Architecture Rules — injected by /g-specialize. Do not edit manually. -->
     @.claude/rules/architecture-[stack].md
     <!-- End G-Forge [stack] Architecture Rules -->
     ```

**Repeat for each combo key in `Combos detected`** — same pattern. Combo rules destination: `.claude/rules/architecture-[combo-key].md`.

Report per profile:
```
✓ .claude/rules/architecture-[stack].md   — rules installed
✓ CLAUDE.md — @.claude/rules/architecture-[stack].md registered
```

## Step 8 — Report and initial dependency audit

```
Stack profiles applied ✓

  ✓ .claude/agents/vue-architect.md      — vue-pinia architect installed
  ✓ .claude/agents/vue-implementer.md    — vue-pinia implementer installed
  ✓ .claude/agents/tauri-architect.md    — tauri architect installed
  ✓ .claude/agents/tauri-implementer.md  — tauri implementer installed
  ✓ CLAUDE.md — Vue 3 + Pinia architecture rules appended
  ✓ CLAUDE.md — Tauri architecture rules appended
  ↳ CLAUDE.md — tauri-vue-pinia combo rules appended

These agents are now project-native. They will appear in Claude Code's agent list.
Dispatch the architects during review or planning that touches their stack; wave
execution dispatches the implementers automatically (wave-planner routes each
implementation task to the matching stack implementer).
```

List only the profiles that were actually applied.

**Initial dependency audit:** After the installation report, dispatch `dependency-auditor` with all dependency manifest files identified in Step 1 (e.g. `package.json`, `requirements.txt`, `Cargo.toml`, `go.mod`). This is the project's baseline dependency audit — surface any security advisories, deprecated packages, license conflicts, and unused declarations before development begins. If no manifest files were found, skip silently.

## Rules
- Never write any file before the developer confirms in Step 4.
- Never overwrite an existing agent without user confirmation.
- Profile files are read from the plugin directory — never embedded or hardcoded here.
- If the plugin directory cannot be located, tell the developer the expected path and ask them to verify the plugin is installed.
- code-lead is consulted only when the picture is ambiguous or a brief flags a risky stack choice — not on every run.
- If the developer provides an explicit stack arg, skip all detection and go straight to Step 2 (research) then Step 4 (confirm).
- Research (Step 2) covers stable and LTS releases only. Pre-release, canary, experimental, and RC versions are ignored regardless of recency.
- Version notes are informational — they do not override profile rules. If a current stable pattern contradicts a profile rule, surface the conflict to the developer during confirmation; do not silently rewrite the rules file.
