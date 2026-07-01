# M13 — Profile Additions

**Status:** ✅ Complete
**Version:** v0.14.0
**Branch:** feat/m13-profile-additions

## Goal

Expand stack coverage and deepen the frontend story. Three new stack profiles (flask, pygame, xamarin) close common gaps. A new general-purpose agent (`dependency-auditor`) audits manifests for security advisories, deprecations, license conflicts, and unused declarations. The pre-existing `frontend-data-flow` supplementary profile is now wired into `/g-specialize` so it auto-installs alongside any component-framework profile.

## Scope

### 1 — flask profile

Architect agent + architecture rules for Flask projects. Covers app factory pattern, blueprint-only route registration, service-layer framework-agnosticism (no `flask.request`/`g`/`current_app` below the route boundary), repository pattern over `Model.query`, and Marshmallow/Pydantic schema discipline (separate request/response).

**Done condition:** `profiles/flask/agents/flask-architect.md` and `profiles/flask/rules/architecture.md` exist; `/g-specialize` detects `flask` in `requirements.txt`/`pyproject.toml` and installs the profile.

---

### 2 — pygame profile

Architect agent + architecture rules for Pygame projects. Covers game-loop discipline (single `pygame.event.get()` site, `dt`-based motion), scene/entity/system separation, asset lifecycle (load at scene transitions, never per-frame), and frame-time budget enforcement. Aligns with G-RULES §F state-machine and object-pooling expectations for game-dev profiles.

**Done condition:** `profiles/pygame/agents/pygame-architect.md` and `profiles/pygame/rules/architecture.md` exist; `/g-specialize` detects `pygame` and installs the profile.

---

### 3 — xamarin profile

Architect agent + architecture rules for Xamarin.Forms projects (legacy — end-of-support May 2024). Covers MVVM discipline, view-model framework-agnosticism (no `Xamarin.Forms.*` UI controls or platform assemblies in view-models), `DependencyService` boundary for platform-specific features, async/await UI-thread marshalling, and `OnPropertyChanged(nameof(...))` discipline. Flags Xamarin.Forms's end-of-support status and recommends MAUI for new work.

**Done condition:** `profiles/xamarin/agents/xamarin-architect.md` and `profiles/xamarin/rules/architecture.md` exist; `/g-specialize` detects `Xamarin.Forms` in `.csproj` (without `Microsoft.Maui`) and installs the profile with a migration note.

---

### 4 — `dependency-auditor` agent

General-purpose agent that audits the project's dependency manifest. Detects manifest type automatically (npm/yarn/pnpm/bun, pip, Cargo, Go, Gem, Composer, pubspec, .NET, JVM) and reports: known security advisories (Critical), deprecated and unmaintained packages (Major), license conflicts (Major), unused declarations (Minor), duplicate versions (Minor), and major-version drift (Minor). Read-only — never upgrades.

**Done condition:** `agents/dependency-auditor.md` exists with frontmatter (model: sonnet, tools: Read/Glob/Grep), input spec, severity-graded output format, and explicit "report-only, never upgrade" rule.

---

### 5 — `frontend-data-flow` supplementary profile wired into `/g-specialize`

The pre-existing `profiles/frontend-data-flow/` (architect agent + rules covering the two-network model and the four canonical violations: HTTP in components, shadow-state ref sync, watch-as-dispatch, caller-follows-truck) is now auto-installed by `/g-specialize` whenever any component-framework stack is detected: `react`, `vue-pinia`, `nuxt`, `next-js`, `sveltekit`, `angular`, `remix`, `astro`, or any astro-* combo. It is supplementary — never replaces the per-framework architect.

**Done condition:** `skills/g-specialize/SKILL.md` Step 1 contains the supplementary-profile rule; description and supported-stacks list include `frontend-data-flow` annotation; `profiles/frontend-data-flow/agents/frontend-data-flow-architect.md` and `profiles/frontend-data-flow/rules/architecture.md` are committed.

---

## Done Conditions (milestone)

- [x] `profiles/flask/` (architect + rules) exists and is registered in `/g-specialize`
- [x] `profiles/pygame/` (architect + rules) exists and is registered in `/g-specialize`
- [x] `profiles/xamarin/` (architect + rules) exists and is registered in `/g-specialize` with end-of-support flag
- [x] `agents/dependency-auditor.md` exists with severity-graded output and read-only rule
- [x] `profiles/frontend-data-flow/` committed; auto-install rule wired into `/g-specialize` Step 1
- [x] `/g-specialize` supported-stacks list updated (description + detection logic + interactive prompt list)
- [x] `plugin.json` and `marketplace.json` at v0.14.0; agent count 17, stack profile count 48 (+ frontend-data-flow supplementary)
- [x] CHANGELOG `[0.14.0]` entry added
- [x] README skill list and roadmap table updated; new profiles and dependency-auditor mentioned
- [x] M13 marked ✅ Complete in ROADMAP.md

## Tier 3 DoD

Developer runs `/g-specialize` against a test project with `flask` in `requirements.txt` — the skill detects flask, applies the profile, and the flask-architect agent becomes available. Same with `pygame` and a `*.csproj` containing `Xamarin.Forms`. Running `/g-specialize` on a Vue 3 + Pinia project results in both `vue-architect` and `frontend-data-flow-architect` being installed.

## Depends on

M8 (initial profile system) — adds to the existing profile catalogue. Independent of the M9–M12 intelligence chain.
