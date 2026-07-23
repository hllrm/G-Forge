# Blast radius: version-triple contract (semver lib + triple sources)

> Created: 2026-07-23
> Source: M46 task 11 — enumerate all readers of the version triple (installed / cache / latest) and the shared ordering lib; check g-init/g-status/README for old-contract assumptions.

## Score

Total files: 15  ·  Avg volatility: 7.3  ·  Hot files: 12  ·  Score: 50  ·  Rating: ✗ Wide

**Calibration note:** rating inflated by the release path itself — `plugin.json`, `marketplace.json`, README are touched by *every* release commit, so the volatility proxy reads hot regardless of coupling. Structural coupling is actually narrow: exactly one ordering implementation (`gf_semver_compare`), three contract owners (detect/diagnose/fix), and test/fixture coverage on each. Treat as ⚠ Moderate in substance.

## Files in scope

| Path | Role | Volatility |
|------|------|------------|
| hooks/lib/semver-compare.sh | target (sole ordering contract) | 0 (new) |
| .claude-plugin/plugin.json | target (triple source: cache/installed leg) | 10 |
| .claude-plugin/marketplace.json | target (version pair invariant) | 10 |
| hooks/workflow-checkpoint.sh | reverse-dep — **detect** owner, sources lib | 10 |
| skills/g-doctor/SKILL.md | reverse-dep — **diagnose** owner (Check 23), sources lib | 10 |
| skills/g-update/SKILL.md | reverse-dep — **fix** owner (Step-0 preflight reads triple) | 10 |
| tests/test-semver-compare.sh | reverse-dep — lib suite (26 cases) | 0 (new) |
| tests/test-workflow-checkpoint.sh | reverse-dep — direction cases §27 | 6 |
| g-dev/fixtures/g-update-staleness-preflight.sh | reverse-dep — zero-write fixture | 0 (new) |
| agents/project-manager.md | reverse-dep — **LEGACY reader, see finding 1** | 10 |
| README.md | reverse-dep — documents contract (task-15 current) | 10 |
| skills/g-review/SKILL.md | reverse-dep — release version-bump step reads pair | 10 |
| skills/g-init/SKILL.md | reverse-dep — mentions /g-update only (compatible) | 10 |
| rules/g-rules/D-code-quality.md | reverse-dep — version-sources table (pair invariant) | 6 |
| profiles/claude-plugin/rules/architecture.md | reverse-dep — version rule + sort -V exception note | 8 |

Incidental mentions (matched grep, no version-ordering read — not scored): skills/g-specialize, g-roadmap, g-intake, g-align, CHANGELOG.md, tests/test-classify-changeset.sh, profiles/claude-plugin/agents/claude-plugin-architect.md.

## Findings — old-contract assumptions

1. **`agents/project-manager.md:21` — legacy hand-rolled version check.** PM session-start step: "curl the GitHub plugin.json, compare to installed version in `~/.claude/plugins/cache/...`" + `.claude/last-update-check` 7-day stamp. Predates M46: (a) hand-rolled comparison outside `gf_semver_compare` — violates the sole-ordering-contract goal; (b) a fourth, unowned reader outside the detect/diagnose/fix split (detect is workflow-checkpoint's job, now direction-aware); (c) direction-blind — same bug class the checkpoint fix just closed. **Recommendation:** retire the PM's own check in favor of the checkpoint's detect line, or route its compare through the lib. Not in M46 wave scope — surface at /g-review, route to backlog/rider.
2. **`skills/g-update/SKILL.md` Step-0 compare is model-inline** (skill prose decides "Cache < GitHub latest"), while sibling g-doctor Check 23 explicitly sources the lib. Advisory inconsistency only — semantics match; consider an explicit lib reference for symmetry in a later doc pass.
3. **g-status:** zero version/update references — clean, no old-contract assumption.
4. **g-init:** sole reference is "run `/g-update` to re-sync" (line 27) — compatible with the new preflight (g-update now self-guards). Clean.
5. **README:** task-15 sweep current — preflight (line 128), checkpoint nudge example, Check 23 pointer (137), doctor/update table rows (288/301) all state the new contract. Clean.
