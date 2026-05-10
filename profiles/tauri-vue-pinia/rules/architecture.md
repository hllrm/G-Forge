# Tauri + Vue 3 + Pinia Architecture Rules

## IPC boundary
- All Rust command calls use `invoke()` from `@tauri-apps/api/core` — never attempt to call Rust directly or access undocumented internals
- Create a typed API layer at `src/api/` — one file per domain, each export wraps `invoke()` with TypeScript types matching the Rust command signature
- Rust `#[command]` return types (serialised structs) → mirror as TypeScript interfaces in `src/api/types.ts`; the Rust struct and the TS interface are a contract — changes to one require changes to the other

## Pinia + Tauri event integration
- Stores that reflect backend state own their `listen()` subscriptions — not components
- `listen()` returns a `Promise<UnlistenFn>` — always await it and store the handle; call the handle in `$dispose` or `onUnmounted`; a leaked subscription causes duplicate event handlers that survive hot reloads
- Subscribe inside the store's setup function, not in component `onMounted`; components should not know that events exist
- Components read from the store; they call store actions; they never call `invoke()` or `listen()` directly

## Capability scoping
- List only the capabilities actually used in `tauri.conf.json` — no `fs:read-all`, no `shell:open-all` blanket grants; the default deny is a security boundary, not a configuration default to work around
- Every new Rust shell command must be explicitly allow-listed
- Scope file system paths to the minimum required directory; prefer `$APP` and `$DOCUMENT` over absolute paths

## State ownership
- Tauri backend `State<T>` is the source of truth for system resources — Pinia store is the UI projection; never derive backend truth from frontend state
- On app startup, stores fetch initial backend state via `invoke()` in their setup function; do not assume Vue defaults match Rust defaults
- For long-lived backend state changes (file watcher, background job): use Tauri events emitted from Rust, not polling from Vue

## Build and dev
- `tauri dev` starts both Vite and the Rust process — never start Vite separately; running them independently misses Tauri's dev injection
- `cargo check` runs before `tauri build` in CI; Rust type errors break the final binary, not just the Rust crate
- Commit `src-tauri/Cargo.lock` — Tauri's dependency graph is large; reproducible builds require a locked manifest
