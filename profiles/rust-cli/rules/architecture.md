## Rust CLI Architecture Rules

**Layer map:**
- `src/main.rs` — async runtime init, top-level arg parsing, route to CLI layer; no business logic
- `src/cli/` — Clap structs and command routing; maps CLI args to service calls
- `src/commands/` — one file per subcommand; thin glue: validate, call service, format output
- `src/services/` — all business logic; no Clap types, no terminal output formatting
- `src/models/` — domain structs and enums; `serde` derives; no logic beyond `Display`/`From`
- `src/errors.rs` — `thiserror`-derived `AppError` enum; all typed error variants

**Import direction:** main → cli → commands → services → models. Errors is a leaf. No upward imports.

**Command rule:** Commands are thin. >30 lines in a command handler means logic belongs in a service. `println!`/`eprintln!` must not appear in services.

**Error rule:** No `.unwrap()` outside tests. No `Box<dyn Error>` in services — use typed `AppError`. `anyhow` is acceptable in `main.rs` and `commands/` for display; services must return `AppError`.

**Async rule:** `#[tokio::main]` on `main` only. No `Runtime::new()` in services. No `std::thread::sleep` in async code — use `tokio::time::sleep`. CPU-bound work uses `tokio::task::spawn_blocking`.

**Config rule:** All `std::env::var` access centralised in `AppConfig` loaded at startup. Config values injected into services — not read inline. Use `config` crate or `envy` for structured env deserialization.
