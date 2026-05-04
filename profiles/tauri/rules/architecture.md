## Tauri 2 + Rust Architecture Rules

**Layer map:**
- `src-tauri/src/commands/` — `#[tauri::command]` handlers; thin; validate input, delegate to services, return `Result`
- `src-tauri/src/services/` — all business logic and I/O; Tauri-agnostic (no `use tauri::`); independently testable
- `src-tauri/src/models/` — domain structs/enums; `Serialize`/`Deserialize` for IPC types; no Tauri imports
- `src-tauri/src/state.rs` — `tauri::State<T>` managed type initialization only; no logic
- `src/` — web frontend; communicates with backend only via `invoke()`; follows base framework rules

**Import direction:** commands → services → models. Services never import Tauri types. Frontend only imports from `@tauri-apps/api/core`.

**Command rule:** Commands are thin (~10 lines max). All logic lives in services. Commands call one service method and map the error to `String` or a typed error enum.

**Service rule:** Services are `async`, use `tokio` for all I/O, and have zero Tauri imports. Errors propagated with `?` and `anyhow::Result` or typed enums. No `unwrap()` or blocking I/O in async functions.

**State rule:** Shared state managed via `tauri::State<T>`, registered at app startup with `.manage()`. No `static`/`lazy_static` for shared mutable state.

**Frontend rule:** `invoke()` calls are wrapped in typed service functions in `src/services/`. Components never call `invoke()` directly. Tauri plugin APIs (`@tauri-apps/api/fs`, etc.) are wrapped — never used directly in components.
