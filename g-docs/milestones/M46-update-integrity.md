# M46 — Update Integrity: detect / diagnose / fix split

**Generated:** 2026-07-23
**Status:** ✅ Complete (shipped v2.4.0, 2026-07-23 — 19 tasks / 6 waves / 3 passes; work commit `e3d9d71`)
**Version:** v2.4.0 (minor — contract change across two skills + one hook; slots ahead of M41 per developer call 2026-07-23: small, high impact over time — every consumer touches the update path on every release)
**Goal:** The update path can never silently realign a project from a stale plugin cache, and exactly one skill writes while exactly one diagnoses. Three verbs, three owners, one writer: **detect** (workflow-checkpoint hook) → **diagnose** (/g-doctor, read-only) → **fix** (/g-update, sole writer).

**Origin:** live consumer incident, 2026-07-23, `hllrm/G-Cash` — the first post-v2.3.0 downstream update. Developer ran `/g-update` before the manual `/plugins` marketplace update: the cache still held 2.2.1, so `/g-update` "realigned" the project with old files while presenting as an update ("weird, not sure what happened"). After the manual cache update the second run went fine. Same class visible on the G-Forge repo itself: `workflow-checkpoint.sh` printed "update available: 2.3.0 → 2.2.1" — a backwards advisory, because the check is not direction-aware. Neither failure corrupts, but both misrepresent state on the one path every consumer walks at every release.

## Scope

### Wave 1 — stop the bleeding (the two shipped bugs)
- [x] **`/g-update` staleness preflight.** Before touching any file: resolve installed-project version, plugin-cache version, and latest-available version (marketplace manifest / source repo). If cache < latest: **STOP, write nothing**, print the three versions and the instruction to run the manual `/plugins` update first (offer the automatic path only if one verifiably exists on this platform). Done: a stale-cache `/g-update` run provably writes zero files (fixture: fake cache dir with lower version; assert no mtime changes) and prints the advisory; a current-cache run behaves exactly as today.
- [x] **`workflow-checkpoint.sh` direction-aware update line.** Semver-compare installed vs cache: cache newer ⇒ today's "update available X → Y" nudge; cache older or equal ⇒ no update line (optionally a one-line "cache lags repo" note on the dev repo only). Done: test-workflow-checkpoint gains cases for newer / equal / older cache, fail-before/pass-after on the older-cache case.

### Wave 2 — the contract split
- [x] **`/g-doctor` becomes the sole diagnostic.** Absorbs the version-lag check (installed vs cache vs latest, direction-aware — shares the Wave 1 comparison logic, single implementation) and recommends the right vector: `/plugins` update when the cache lags, `/g-update` when installed files lag the cache. Stays read-only — recommends, never realigns.
- [x] **`/g-update` sheds diagnostic overlap.** Any check it duplicates from doctor goes; it keeps only the preflight guard (a write-safety gate, not a diagnostic) and the realign work itself. Done: no check exists in both skills; grep-provable single owner per check.
- [x] **Docs sweep rides the change:** `skills/g-update/SKILL.md` + `skills/g-doctor/SKILL.md` descriptions, README hook/skill tables, G-RULES §B skill table line. (ADR-007 note: SKILL.md is the sole authored source — no shim files to touch.)

**Explicitly out of scope:** `/g-release` and release-cut machinery (M41 — composes with this: M41's `/g-doctor` version-consistency check extends the same diagnostic surface Wave 2 establishes); auto-updating the plugin cache itself (owned by Claude Code `/plugins`, not us); any scheduled/self-firing skill (detection stays in the hook that already fires every prompt).

**Depends on:** — (independent). Sequenced ahead of M41: the update path misleads consumers today, release machinery only compounds traffic on it.

**Premortem:**
- *Latest-available unreachable offline* (med) → preflight degrades to cache-vs-installed only, says so explicitly, never blocks realign on a network failure. Fail toward today's behavior, loudly.
- *Semver compare edge cases* (low) → shared compare function in one lib file, tested once, used by hook + doctor + update — never three hand-rolled compares (that is how the direction bug happened).
- *Split leaves an orphaned check* (low) → Wave 2 done condition is grep-provable single ownership; `/g-doctor` drift check already validates installed copies post-change.

**Cross-cutting propagation (G-RULES §B):** the version triple (installed / cache / latest) becomes a shared primitive read by `workflow-checkpoint.sh`, `/g-doctor`, and `/g-update` — one comparison implementation, three consumers. Run `/g-blast-radius` at Wave 1 close to confirm no other reader (g-init, g-status, README docs) assumes the old contract.
