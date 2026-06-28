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
