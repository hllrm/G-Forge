# M9 — Intelligence Foundation

**Status:** ✅ Complete
**Version:** v0.10.0
**Branch:** feat/m9-intelligence-foundation

## Goal

Structural substrate for agent context management and decision memory. Preceded by a full project rename pass (G-Team → G-Forge).

## Scope

### 0 — Project rename pass

Rename the project from **G-Team** to **G-Forge** across the full repo. The Git remote has already been renamed; this task aligns all in-repo references.

**Files to update:**
- `ROADMAP.md` — title heading (done in planning)
- `CHANGELOG.md` — heading and any prose mentioning "G-Team"
- `README.md` — title, badges, intro, and all prose references
- `.claude-plugin/plugin.json` — `name` and `display_name` fields
- `.claude-plugin/marketplace.json` — plugin name and description fields
- `G-RULES.md` — header and any self-referential prose
- `CLAUDE.md` — title, section headings, and skill router references
- `commands/g-team.md` — document header only (command names `g-*` stay unchanged)
- `skills/*/SKILL.md` — any prose referring to "G-Team plugin"
- `agents/*.md` — any prose referring to "G-Team"
- `profiles/*/` — architect agent and rules files
- `docs/` — all `.md` files referencing "G-Team"
- `milestones/` — all milestone files (headers and prose only; milestone IDs unchanged)
- `project_brief.md` — if present

**What does NOT change:**
- Command names (`/g-plan`, `/g-execute`, etc.) — these are user-facing and stable
- Skill/agent IDs, file names, directory names
- Git history

**Done condition:** `grep -ri "g-team" .` returns only entries in `.git/` and this milestone file's historical notes.

---

### 1 — Context profiles v1

Memory slice declared in skill/agent frontmatter — each skill/agent declares which memory tiers it reads and writes, so HQ can scope context correctly at dispatch time.

**Done condition:** frontmatter spec documented in `docs/context-profiles.md`; at least `/g-plan` and `/g-review` updated to declare their profiles.

---

### 2 — Memory layer taxonomy

6-tier model with defined lifetime and audience:

| Tier | Name | Lifetime | Audience |
|------|------|----------|---------|
| 1 | Working | current message | HQ only |
| 2 | Task | current wave | HQ + dispatched agents |
| 3 | Sprint | active milestone | HQ |
| 4 | Architectural | project lifetime | all agents |
| 5 | Institutional | org lifetime | all agents |
| 6 | Human Preference | persistent | HQ |

**Done condition:** taxonomy documented in `docs/memory-taxonomy.md`; referenced from `G-RULES.md` §C.

---

### 3 — ADR lineage fields

Extend the ADR template in `/g-adr` to capture:
- Rejected alternatives (with one-line reason each)
- Assumptions that held at decision time
- Constraints that drove the decision

**Done condition:** `docs/decisions/` template updated; at least one existing ADR migrated to the new format as example.

---

## Done Conditions (milestone)

- [ ] `grep -ri "g-team" .` returns zero matches outside `.git/` and historical notes
- [ ] `plugin.json` and `marketplace.json` both show `G-Forge` as display name and versions agree
- [ ] `docs/context-profiles.md` exists and `/g-plan` + `/g-review` frontmatter updated
- [ ] `docs/memory-taxonomy.md` exists and referenced from `G-RULES.md`
- [ ] ADR template updated with lineage fields; one migrated example present
- [ ] CHANGELOG entry added for v0.10.0
- [ ] README updated to reflect G-Forge name

## Depends on

M8 (complete)
