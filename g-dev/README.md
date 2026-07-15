# g-dev/

Dev-only test harness for the G-Forge repo itself. **Not plugin content** — nothing under `g-dev/` is referenced by `.claude-plugin/plugin.json`, is never Globbed by a skill or command, and is never installed into a consumer project by `/g-init`, `/g-update`, or `/g-specialize`. Consumers of the G-Forge plugin never receive this directory.

This exists because G-Forge dogfoods itself (see `CLAUDE.md`): the repo that ships the commit gate, the review pipeline, and the wave-execution model also has to verify its *own* hooks and gate behavior in a sandbox, the same way any other implementer would verify a consumer project's fixtures. `g-dev/` is where that verification work lives so it survives past a single session.

## Layout

- `g-dev/fixtures/` — disposable-repo gate fixtures. Each script builds one or more throwaway git repos under a `mktemp -d` (or equivalent scratch) location, drives `hooks/pre-commit` (or another hook) against them directly, and asserts exit codes / stderr content against the documented contract (ADRs, `hooks/lib/*`, skill files) — never against the hook's own implementation, to avoid tautological tests. Fixtures never touch the real repo's git state.

## How `g-forge-dev` uses this

The `g-forge-dev` agent (`.claude/agents/g-forge-dev.md`, itself repo-local and never shipped) runs `tests/test-*.sh` and named scripts under `g-dev/fixtures/` on request, and returns verbatim pass/fail runner output — the execution evidence that `code-lead`/`g-review` require before treating a "tests pass" done condition as verified (see M-audit finding #20). It never edits fixtures or hooks; it only runs and reports.

## Promotion rule

Verification scripts written into a session's scratchpad during wave work (sandbox fixtures built to check a hook or gate behavior mechanically) get **promoted into `g-dev/fixtures/`** instead of dying with the scratchpad when the session ends. A fixture worth writing once to verify a fix is worth keeping to catch a regression later — promote it here, strip any session-specific absolute paths, and make sure it runs standalone against this repo's checked-out `hooks/` from a fresh `mktemp -d` temp repo.
