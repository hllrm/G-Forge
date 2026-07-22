---
name: g-docs
description: Documentation audit and generation. Scans for missing or stale code docs, missing README sections, undocumented env vars, CHANGELOG gaps, and architectural decisions without ADRs. Targeted scope fixes gaps immediately via doc-writer. Whole-codebase scope produces a prioritised documentation debt report and optional roadmap entry.
---

**Announce:** "Using g-docs to audit and fill documentation gaps."

You audit documentation coverage and invoke `doc-writer` to fill identified gaps. You do not write docs yourself.

## Step 1 — Determine scope

**If an argument was provided** (e.g. `/g-docs src/services`):
- Set `mode: targeted`, `scope: [argument]`. Skip the question.

**If no argument was provided**, ask:
> "Scan the whole codebase (findings become a documentation debt report) or a specific area?
> Type a path (e.g. `src/services`) or **all** for the full codebase."

Wait for the answer. Set `mode: targeted` or `mode: full`.

Apply the scope filter to all subsequent searches.

## Step 2 — Detect project documentation standard

Read `CLAUDE.md` and `g-docs/project_brief.md` to establish:
- Language(s) in use — determines the expected doc format (JSDoc, docstrings, doc comments)
- Whether a public API is exposed (REST, GraphQL, SDK) — determines if an API reference is expected
- Whether env vars are used (`process.env`, `os.environ`, `std::env`) — determines if an env var reference is expected
- Whether `g-docs/decisions/` exists — determines if ADR audit applies

## Step 3 — Parallel documentation scan

Run all of the following in parallel (scope all searches to `[scope]`):

**Code docs — undocumented public exports**
```bash
# TypeScript/JavaScript: exported symbols without JSDoc
grep -rn "^export\s\+\(function\|class\|const\|async\|type\|interface\|enum\)" \
  --include="*.ts" --include="*.tsx" --include="*.js" \
  --exclude-dir=node_modules --exclude-dir=dist \
  --exclude="*.test.*" --exclude="*.spec.*" \
  [scope]
```
For each exported symbol found, check whether the 3 lines above it contain a `/**` JSDoc block. Missing = gap.

```bash
# Python: exported functions/classes without docstrings
grep -rn "^def \|^class \|^async def " \
  --include="*.py" \
  --exclude="test_*" --exclude="*_test.py" \
  [scope]
```
For each, check whether the line immediately following `def`/`class` is `"""`. Missing = gap.

```bash
# Go: exported identifiers without doc comments
grep -rn "^func [A-Z]\|^type [A-Z]\|^var [A-Z]\|^const [A-Z]" \
  --include="*.go" \
  [scope]
```
For each, check whether the immediately preceding line starts with `//`. Missing = gap.

**Code docs — stale documentation**
```bash
# Find all JSDoc blocks followed by function signatures
grep -rn -B1 "^export\s\+\(async\s\+\)\?function\|^export\s\+class" \
  --include="*.ts" --include="*.js" \
  --exclude-dir=node_modules \
  [scope]
```
Flag any JSDoc that describes parameters not present in the current signature, or omits parameters that are present. These are stale.

**Module headers — files without a purpose statement**
```bash
# Source files without any leading comment or docstring in first 5 lines
find [scope] -type f \( -name "*.ts" -o -name "*.py" -o -name "*.go" -o -name "*.rs" \) \
  -not -path "*/node_modules/*" -not -path "*/dist/*" \
  -not -name "*.test.*" -not -name "*.spec.*" \
  -not -name "index.*" -not -name "main.*" \
  | head -30
```
For each file >100 lines, read the first 5 lines. If no comment or docstring is present, flag as a module header gap.

**README completeness**

Read `README.md` (or `g-docs/README.md`). Check for the presence of each required section:
- What the project is (one-sentence description)
- Why someone would use it / what problem it solves
- Installation or setup instructions
- Quickstart / usage example
- Configuration reference (if the project is configurable)
- API reference or link to it (if a public API is exposed)
- Contributing guide or link
- License

Flag each missing section.

**Environment variable reference**
```bash
# Find env var reads
grep -rn "process\.env\.\|os\.environ\[\|os\.getenv(\|std::env::var(\|Environment\.GetEnvironmentVariable(" \
  --include="*.ts" --include="*.tsx" --include="*.js" \
  --include="*.py" --include="*.go" --include="*.rs" --include="*.cs" \
  --exclude-dir=node_modules \
  [scope]
```
Extract every distinct env var name. Then check whether each is documented in any of: `README.md`, `g-docs/env-vars.md`, `.env.example`, or a configuration reference section. Undocumented = gap.

**CHANGELOG currency**
```bash
# Last commit date vs last CHANGELOG entry date
git log --oneline -5
```
Read `CHANGELOG.md`. If the most recent entry is more than 5 commits behind HEAD, flag as a CHANGELOG gap — significant changes may be unrecorded.

**ADR coverage**
```bash
# Check for existing ADRs
find . -path "*/g-docs/decisions/*.md" -not -path "*/node_modules/*" | sort
```
If `g-docs/decisions/` is empty or missing but the project has a CLAUDE.md with architectural rules, flag: "Architectural decisions present in CLAUDE.md have no corresponding ADRs — the rationale behind these choices is undocumented."

Also grep for patterns indicating undocumented decisions in the diff scope:
```bash
grep -rn "// TODO.*why\|# TODO.*why\|// FIXME.*why\|deliberate\|intentional\|by design" \
  --include="*.ts" --include="*.py" --include="*.go" \
  --exclude-dir=node_modules \
  [scope]
```
Each hit suggests an undocumented decision.

**API reference**
If the project exposes a REST API:
```bash
grep -rn "router\.\(get\|post\|put\|patch\|delete\)\|app\.\(get\|post\|put\|patch\|delete\)\|@Get\|@Post\|@Put\|@Delete\|@Patch" \
  --include="*.ts" --include="*.py" --include="*.go" \
  --exclude-dir=node_modules \
  [scope]
```
Check whether an OpenAPI spec (`openapi.yaml`, `swagger.json`, `openapi.json`) or a generated API reference exists. Missing = gap.

## Step 4 — Score each gap

**Severity**
- Critical (3): no documentation on a public-facing API that external consumers depend on; stale docs that actively contradict current behaviour
- Major (2): missing JSDoc/docstring on exported functions; missing README section; undocumented env vars; missing CHANGELOG entry for a shipped feature; no ADR for a significant architectural decision
- Minor (1): missing module header on an internal file; incomplete README section; TODO-why comments

**Impact**
- High (3): affects onboarding, external integrators, or production operations
- Medium (2): affects internal developers or future maintainability
- Low (1): minor clarity improvement

**Priority score** = Severity × Impact

| Score | Tier |
|-------|------|
| ≥ 6 | P0 — Fix before next merge |
| 3–5 | P1 — Fix this cycle |
| 1–2 | P2 — Schedule |

## Step 5a — Targeted mode: fix gaps

For each gap identified, dispatch `doc-writer` with:
- The file(s) with missing or stale documentation
- What specifically is missing (JSDoc on which export, which README section, which env var)
- The project's doc format (JSDoc / docstring / doc comment)
- Instruction: "Write the missing documentation. Explain WHY — the constraint, decision, or non-obvious behaviour. Do not restate the type signature."

After doc-writer completes each gap, report:
```
✅ g-docs/env-vars.md — DATABASE_URL, REDIS_URL, JWT_SECRET documented
✅ src/services/UserService.ts — JSDoc added to createUser, updateUser
⚠ README.md — Contributing section still missing (requires human input on process)
```

Flag gaps that require human knowledge (contributing guide, deployment specifics, product rationale) rather than filling them with placeholders.

## Step 5b — Full-codebase mode: report and offer

Print the gap report:

```
## Documentation Audit
Generated: [date]

### P0 — Fix before next merge
- README.md: missing Installation, Quickstart, Configuration sections (Major · High)
- src/api/routes.ts: 12 endpoints with no OpenAPI spec (Critical · High)

### P1 — Fix this cycle
- src/services/: 8 exported functions without JSDoc (Major · Medium)
- .env vars: DATABASE_URL, REDIS_URL undocumented (Major · High)
- CHANGELOG.md: 7 commits since last entry (Major · Medium)

### P2 — Schedule
- g-docs/decisions/: no ADRs found despite 3 architectural patterns in CLAUDE.md (Major · Low)
- src/lib/: 4 modules >100 lines without module headers (Minor · Low)

---
Total: N gaps (P0: X · P1: Y · P2: Z)
```

Ask:
> "Fix P0 and P1 gaps now (doc-writer will run on each), add all gaps to the roadmap as a documentation milestone, or both?"

- **Fix now**: dispatch `doc-writer` on each P0 and P1 gap in parallel waves (P0 first). Report completions.
- **Roadmap**: write `g-docs/milestones/M-docs-[YYYY-MM].md` and append entry to `g-docs/ROADMAP.md`.
- **Both**: fix first, then write the milestone with P2 items only.

**Milestone format** (`g-docs/milestones/M-docs-[YYYY-MM].md`):
```markdown
# M-docs-[YYYY-MM] — Documentation Debt

**Generated:** [date]
**Status:** ⬜ Not started
**Goal:** Close [N] documentation gaps to prevent onboarding friction and project drift.

## P0 — Fix before next merge
[table: gap · file · type · priority]

## P1 — This cycle
[table]

## P2 — Backlog
[table]

## Execution notes
- Run `/g-docs [path]` on each scoped area to generate docs and fill gaps.
- Gaps requiring human knowledge (contributing guide, deployment steps) are flagged — do not generate placeholders.
- Run `/g-adr` for each undocumented architectural decision.
```

## Rules
- Never generate placeholder or filler documentation ("TODO: add description here"). Either write real documentation or flag the gap for human input.
- Never document things that are obvious from names alone — flag redundant doc requests and skip them.
- CHANGELOG gaps require human judgment about what to write — flag them, do not auto-generate entries.
- ADR gaps: dispatch `/g-adr` instructions, do not attempt to reconstruct past decisions from code alone.
- If doc-writer flags a function as "needs renaming instead of documenting", surface that as a code quality finding rather than writing a workaround doc.
