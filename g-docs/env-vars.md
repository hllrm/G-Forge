# Environment variables

G-RULES §G reference. G-Forge's shipped surfaces read two environment variables;
three more names that look like env vars are actually test-suite constants,
not environment variables at all — listed below to prevent that confusion.

## `GF_STDIN_TIMEOUT_OVERRIDE`

| | |
|---|---|
| **Purpose** | Test-fixture timeout override for `gf_read_stdin_timeout` (`hooks/lib/stdin-read.sh:63-80`). When set and non-empty, its value replaces the effective stdin-read timeout before argument normalization — an invalid override (negative, non-numeric) falls through the same normalization/default path as an invalid `seconds` argument. |
| **Required/optional** | Optional. |
| **Default when unset** | No-op — unset or empty is byte-identical to today's behaviour; the function's `seconds` argument governs exactly as before. |
| **Set in production?** | No. Every top-level hook sources `stdin-read.sh` and so runs the `[ -n "${GF_STDIN_TIMEOUT_OVERRIDE:-}" ]` check on every invocation, but none of the seven hooks sets the variable itself — it is a test hook, not a runtime tuning knob. An operator or CI environment that exports it would be honored by every hook that reads stdin through this helper. |
| **Wired into fixtures** | M48c (`test-class-split-invariant.sh`'s six-hook loop, `test-check-commit.sh` cases 23/25) — not yet wired as of M48b. |
| **Example value** | `GF_STDIN_TIMEOUT_OVERRIDE=2` (fast mode — see `GF_FAST_STDIN_GUARD_MS` below for the bound that governs it once wired). |

## `GF_RUNALL_SUITE_DIR`

| | |
|---|---|
| **Purpose** | Overrides the suite directory `tests/run-all.sh` globs for `test-*.sh` (`tests/run-all.sh:48`). Test-only — lets `tests/test-run-all.sh` point the runner at fixture directories. |
| **Required/optional** | Optional. |
| **Default when unset** | `tests` — behavior unchanged. |
| **Set in production?** | No — consumed only by the runner's own test suite. Also documented at `tests/README.md`. |
| **Example value** | `GF_RUNALL_SUITE_DIR=/tmp/fixture-suites` |

## Test-suite constants (not environment variables)

Sourced from `tests/lib/timing-bounds.sh` — declared once as shell constants
inside test suites, never read from the process environment. Listed here only
because their `GF_`-prefixed names read like the env var above at a glance.

| Constant | Value | What it bounds |
|---|---|---|
| `GF_HOOK_STDIN_GUARD_MS` | `65000` | A hook invoked with stdin attached to an abandoned pipe (no writer, no EOF) must return once its 5s stdin guard fires plus MSYS subprocess overhead. |
| `GF_LIB_READ_WINDOW_MS` | `6000` | `gf_read_stdin_timeout` called directly with a 1s timeout, no hook body, no subprocess fan-out. |
| `GF_FAST_STDIN_GUARD_MS` | `15000` | A hook invoked in override mode (`GF_STDIN_TIMEOUT_OVERRIDE` set, ~2s fast-mode guard) once M48c wires the override into test runs. **Provisional** — authored before any suite consumes it, no empirical run evidence yet; M48c closes with the revalidation (`CHANGELOG.md`, `tests/lib/timing-bounds.sh:57-62`). |
