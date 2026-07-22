# Spike S1 — Skills/Agents Dev-Install Path: Decision Input

> Date: 2026-07-22
> Status: spike complete
> **Framing: decision input for a future dev-install call — NOT an install, nothing changes now.**

This document does not recommend acting. It reports what two executed probes (Wave 6, `g-docs/agent-output/wave-w15g-6/spike-s1-probes.md`, HQ-verified 2026-07-22) found, so that if a future slice proposes dev-installing skills/agents from the working tree, the call is made against measured platform behavior rather than assumption. No dev-install has been performed. Cache-only distribution for skills/commands stands unchanged.

---

## Question the spike answers

ADR-008 (`g-docs/decisions/008-self-host-working-tree-split-cadence.md`) self-hosts hooks/rules/agents from the working tree, but leaves a scope ceiling: shipped skills (38) and agents (19) are cache-pinned by construction — command routers hardcode the cache Glob, and the `g-forge:` namespace can't be shadowed by project-local files. ADR-008 named this the open follow-up (§Consequences: "Spike S1 — skills/agents dev-install path — the remaining majority of the product surface") and posed two empirical questions:

- (a) Does a local-marketplace install of `g-forge` replace or collide with the GitHub-marketplace install?
- (b) How do the command routers' cache Globs behave with multiple version directories present?

Spike S1 answers both.

---

## Findings

### S1(a) — Local marketplace install: replace, not collide

Adding a local-path marketplace under the same name (`g-forge`) does not sit side-by-side with the GitHub marketplace — it **overwrites the registry entry**:

```
BEFORE:  g-forge → GitHub (hllrm/G-Forge)
AFTER:   g-forge → Directory (D:\SW_Projects\G-Forge)
```

Installing from that local marketplace when the plugin is already installed at the same scope is a **no-op** — zero cache mutation:

```
✔ Plugin "g-forge@g-forge" is already installed (scope: user)
```

Cache observation: no new version dir created; existing `2.2.1/` untouched; file hashes matched the pre-probe baseline exactly (e.g. `g-adr: 03ad145d4f51b8beff1913621e6510eb` unchanged).

Consequence: forcing a refresh onto the working tree would require **uninstall-then-install**, not a plain re-install. Removing a marketplace auto-removes its cache dir (confirmed during restoration). The GitHub install survived the whole probe byte-identical.

### S1(b) — Router Glob resolution: mtime-ordered, not semver-ordered

With two version dirs present (`2.2.1/` and a fabricated `9.9.9/`), `Glob "**/skills/g-status/SKILL.md"` returned matches in **ascending mtime order**, independent of version number:

```
Glob mtime (9.9.9): 09:20:40 (older)
Glob mtime (2.2.1): 09:20:52 (newer)
Glob output order: [9.9.9 first, 2.2.1 second]
```

Touching `2.2.1` to make it the newest mtime did not change the outcome — the older-mtime file (still `9.9.9` at that point) sorted first regardless of which version it was:

```
Glob output order: [9.9.9 first (oldest file first), 2.2.1 second]
```

Consequence: a router that reads the first Glob match gets whichever file was touched least recently — not the highest semver, not necessarily the newest. In practice this is an edge state: the cache holds exactly one version dir under normal operation, and a second only appears via manual creation or update corruption — but if it did appear, resolution is silently non-deterministic with respect to version semantics.

### Cache layout

`g-forge` cache uses semver directory names (`cache/g-forge/g-forge/2.2.1/`); other marketplaces (e.g. `caveman`) use content-hash directory names (`0d95a81d35a9`). The semver-name pattern is what makes S1(b)'s ambiguity possible in the first place — a content-hash layout can't collide on a human-meaningful version string.

---

## Repro steps (condensed from the Wave 6 probe record)

**S1(b) — multi-version resolution:**
```bash
mkdir -p ~/.claude/plugins/cache/g-forge/g-forge/9.9.9/skills/g-status
echo "SPIKE-S1-MARKER-9.9.9" > ~/.claude/plugins/cache/g-forge/g-forge/9.9.9/skills/g-status/SKILL.md
glob "**/skills/g-status/SKILL.md" ~/.claude/plugins/cache/g-forge/g-forge/
rm -rf ~/.claude/plugins/cache/g-forge/g-forge/9.9.9/
```

**S1(a) — local marketplace install:**
```bash
claude plugin marketplace list
claude plugin marketplace add /path/to/G-Forge
claude plugin install g-forge@g-forge --scope user   # expect no-op if already installed
find ~/.claude/plugins/cache/g-forge -type d -name "2.2.1"
claude plugin marketplace remove g-forge
claude plugin marketplace update g-forge
```

Full procedure, exact command logs, and restoration verification: `g-docs/agent-output/wave-w15g-6/spike-s1-probes.md`.

---

## Implications for a hypothetical live dev-install (not decided, not scheduled)

| Finding | If a future slice proposed dev-installing skills/agents live |
|---|---|
| Same-name marketplace add replaces, no side-by-side | A dev-install is a **marketplace-registry flip**, not an additive change — reversible by re-adding the GitHub marketplace and updating, as demonstrated in restoration. No mechanism exists (today) to run both a released and a working-tree copy at once. |
| Install onto an existing same-scope install is a no-op | Any dev-install flow **must uninstall before installing** to force cache refresh from the local marketplace — a plain `install` call is silently inert. |
| Removing a marketplace auto-removes its cache dir | Reverting out of a dev-install is a clean two-step (`marketplace remove` + `marketplace update`), matching what restoration already proved works end-to-end. |
| Router Glob is mtime-ordered, not semver-ordered | A dev-install mechanism must **never allow two version dirs to coexist** in the cache — any transitional state with both the released and working-tree version present resolves non-deterministically, not "latest wins." |
| Cache layout is semver-dir, not content-hash | The ambiguity in the row above is specific to this marketplace's layout; it is a property of how `g-forge`'s cache is structured, not a platform universal. |

---

## What was NOT decided

- **No dev-install was performed.** Both probes were executed, verified, and fully reverted in Wave 6; the live install/uninstall cycle was exercised only as a reversible test, not adopted as a running mechanism.
- **Cache-only distribution for skills/commands stands.** ADR-008's scope ceiling is unchanged: shipped skills (38) and agents (19) remain cache-pinned, resolved at the released version (currently 2.2.1).
- **No router code, `/g-update`, or `/g-init` logic changed as a result of this spike.** This report is read-only decision input.
- **Any future flip to a live dev-install path is its own gated slice** — its own plan, its own architecture review, its own rollback contract — not something this report authorizes or schedules.
