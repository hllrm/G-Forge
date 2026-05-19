---
name: g-blast-radius
description: Analyse the blast radius of a planned change. Inputs a file path, feature name, or list of paths from a plan. Outputs the set of dependent files (forward and reverse references), a per-file volatility score (commit frequency proxy), and a total blast-radius rating (low / moderate / wide). Read-only.
context: [task, sprint, architectural]
---

**Announce:** "Using g-blast-radius to map dependencies and volatility for the planned change."

You are running a forward-looking dependency-impact pass: given a target file or feature, find everything that depends on it directly or indirectly, score each by volatility, and aggregate into a single blast-radius rating.

## Step 1 — Resolve targets

Determine the target set:

1. **Single file** — `$ARGUMENTS` is a path to an existing file. Use as the only target.
2. **Plan file** — `$ARGUMENTS` is a `docs/plans/<slug>.md` path or slug. Read the plan's task `Scope` column, extract every distinct file path. Those are the targets.
3. **Feature name** — `$ARGUMENTS` is a short label (no slash). Grep recent commit subjects (`git log --oneline -50`) for the label; collect files touched in matching commits. Those are the targets.
4. **No argument** — read the most-recently-modified plan in `docs/plans/` with any `pending` wave. Use its task scope files.

If no targets resolve:
```
✗ No targets to analyse. Pass a file path, plan slug, or feature label.
```
Stop.

## Step 2 — Forward references (what each target depends on)

For each target file, run Grep on the file's contents for `import` / `require` / `from` / `use` / `#include` / `<reference>` statements. Resolve each reference to a project file when the path is local. External packages are noted but do not propagate.

Record `{target → [dependencies]}` as the forward graph.

## Step 3 — Reverse references (what depends on each target)

For each target file, Grep the project tree for `import.*<target-basename>`, `require.*<target>`, `from <target>`, etc. Common patterns by language:

| Language | Search pattern |
|----------|----------------|
| JS/TS    | `from ['"].*<basename>['"]`, `require\(['"].*<basename>['"]\)` |
| Python   | `from .*<module> import`, `import .*<module>` |
| Go       | `"<module-path>"` inside import blocks |
| Rust     | `use .*<crate>::` or `use .*<module>::` |
| C/C++    | `#include ["<].*<basename>[">]` |
| Java/Kotlin | `import .*<class>` |
| C#       | `using <namespace>` |

Record `{target → [reverse-deps]}` as the reverse graph. This is the immediate blast radius.

If the project has no recognised file extensions for the above languages, fall back to a project-wide basename grep and report best-effort findings flagged with `★ heuristic`.

## Step 4 — Compute per-file volatility

For each file in the **union of targets, forward dependencies, and reverse dependencies**, compute a volatility score from git history:

```
commits_last_50  = count of commits touching this file in `git log --oneline -50 -- <path>`
volatility       = clamp(0, 10, commits_last_50 × 2)
```

A file touched in zero of the last 50 commits = 0 (stable). A file touched in 5+ of the last 50 = 10 (hot).

## Step 5 — Score blast radius

Aggregate into a single rating:

```
total_files    = |targets ∪ forward_deps ∪ reverse_deps|
avg_volatility = mean(volatility across that set)
hot_files      = count of files with volatility ≥ 6
radius_score   = total_files × (1 + avg_volatility/10) + hot_files × 2
```

Map to rating:

| `radius_score` | Rating |
|----------------|--------|
| < 15 | ✓ Narrow — local change |
| 15–35 | ⚠ Moderate — review reverse deps before approving |
| > 35 | ✗ Wide — high coupling; consider re-scoping or splitting the change |

## Step 6 — Print report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
G-BLAST-RADIUS — [targets]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Targets:        [N files]
Forward deps:   [M files]
Reverse deps:   [K files]
Total in scope: [T files]
Avg volatility: [V/10]
Hot files (≥6): [H]
Radius score:   [S] — [✓ Narrow / ⚠ Moderate / ✗ Wide]

Top reverse-dependency files (most likely affected by your change):
  • [path]    volatility [V]
  • [path]    volatility [V]
  • ...

Hot files in scope (high volatility — frequent recent changes):
  • [path]    volatility [V]    [N] commits in last 50

[If Wide:]
Recommendation: this change spans [T] files, including [H] hot files.
Consider splitting into smaller scoped changes or staging the rollout.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Step 7 — Persist for /g-forecast linkage

Write the result to `docs/blast-radius/<slug>.md` (create directory if missing). Use the slug from $ARGUMENTS or the plan slug. Schema:

````markdown
# Blast radius: [targets]

> Created: [YYYY-MM-DD]
> Source: [argument or resolved plan]

## Score

Total files: [T]  ·  Avg volatility: [V]  ·  Hot files: [H]  ·  Score: [S]  ·  Rating: [tag]

## Files in scope

| Path | Role | Volatility |
|------|------|------------|
| ... | target / forward-dep / reverse-dep | [V] |
````

`/g-forecast` Step 2b reads `docs/blast-radius/<slug>.md` if it exists for the plan slug and incorporates the rating into its complexity score: Moderate adds 1 to complexity; Wide adds 2.

## Rules

- Read-only. Never modify source files, only write the persisted report to `docs/blast-radius/`.
- The volatility score is a proxy, not a measurement — files touched many times recently are likely to be touched again, but the score does not predict correctness or risk by itself.
- If the project has no git history (fresh `git init`), report `volatility n/a — no history` for every file and flag rating as `low confidence`.
- External packages in forward dependencies are noted but not scored — their volatility is not under the project's control.
- For very large projects (>1000 files), warn the developer that reverse-reference Grep may be slow, and offer to scope the search to a subdirectory.
