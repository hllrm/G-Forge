# Hook tests

Unit tests for the G-Forge hook scripts in `hooks/`. Pure bash — no test
framework, no dependencies beyond a POSIX shell and `git`.

| Test | Covers |
|------|--------|
| `test-check-commit.sh` | `hooks/check-commit.sh` — the commit gate: blocks `git commit` without the approval sentinel, allows it with one, and stays fail-closed when the only available JSON parser is the broken Windows Microsoft-Store `python3` stub. |
| `test-observe.sh` | `hooks/observe.sh` — the silent observer: journals meaningful workflow commands with the right kind, skips noise, emits valid JSONL, and survives the same stubbed `python3`. |

## Run

```bash
bash tests/test-check-commit.sh
bash tests/test-observe.sh
```

Each script prints one `PASS:`/`FAIL:` line per case and a `Results: N passed, M failed` summary, exiting non-zero if any case fails.

## Path resolution convention

Every suite resolves script/repo paths to **absolute, once, at the top** —
before any fixture `cd`. Suites must be invocation-form-insensitive: identical
results whether run as `bash tests/test-<name>.sh` from the repo root or via
an absolute path from any cwd. Lazy `dirname "$0"` re-derivation after a `cd`
is prohibited — a fixture `cd` invalidates a relative `$0`, silently breaking
path lookups that run after it.

Reference implementation: `tests/test-class-split-invariant.sh` lines 1-8 —
resolve `SCRIPT_DIR` and `HOOKS_DIR` via `cd "$(dirname "${BASH_SOURCE[0]}")" && pwd`
before the sandbox `cd`, never after.

This convention exists because the class-split invariant suite once returned
contradictory results under relative vs. absolute invocation — hook paths
were re-derived after a fixture `cd` (W1.5g finding, ADR-008 clause 6).

Attestation runs use the canonical invocation form (repo-root relative,
`bash tests/test-<name>.sh`); only an attested runner table is authoritative
for pass counts.
