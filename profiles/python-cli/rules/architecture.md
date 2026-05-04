## Python CLI Architecture Rules

**Layer map:**
- `cli/main.py` — Click/Typer app + group registration; entry point only
- `cli/commands/` — one file per command group; parse args, call service, format output with Rich; no business logic
- `services/` — all business logic; returns data objects; zero Click/Typer/Rich imports; no `os.environ` access
- `models/` — Pydantic models or dataclasses; schema for data objects flowing through the system
- `config/` — single `pydantic_settings.BaseSettings` subclass; all env var and `.env` file access lives here
- `utils/` — pure utility functions; no CLI or service imports

**Import direction:** commands → services → models. Commands → config. Services → config. Models and utils are leaves. Never upward.

**Command rule:** Command functions do three things only: parse args, call service, render output. No DB, no HTTP, no business logic. Use Rich for all terminal output — no `print()` or bare `typer.echo()` for structured content.

**Service rule:** Services are framework-agnostic. No `click`, `typer`, `rich`, or `sys.exit` imports. Return data objects — never formatted strings. Receive settings via constructor, never read `os.environ` directly.

**Config rule:** All `os.environ` and `os.getenv` access lives in `config/` only. One `settings` singleton imported project-wide. Use `pydantic-settings` — no `configparser` or manual env parsing.

**Output rule:** All terminal output uses Rich (`Console`, `Table`, `Panel`, `Progress`). Long-running operations show a spinner or progress bar. Errors print to stderr with `console.print(..., file=sys.stderr)`.
