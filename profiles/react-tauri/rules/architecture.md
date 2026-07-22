# React + Tauri Architecture Rules

## Layer map (seam)
- **Rust backend (`src-tauri/`)** — owns system resources, OS APIs, and `State<T>`; the source of truth.
- **Typed API layer (`src/api/`)** — the seam: wraps `invoke()`/`listen()` calls with TS types mirroring the Rust command signatures; the only permitted crossing point.
- **React components** — the UI projection layer; call into `src/api/` only, never `invoke()`/`listen()` directly, and subscribe to events inside `useEffect` with cleanup.
- **Import direction:** Rust (`src-tauri/`) → Tauri IPC → `src/api/` → React component, one-way; React never imports Rust modules or bypasses `src/api/`.

## IPC boundary
- All Rust command calls use `invoke()` from `@tauri-apps/api/core` — never attempt to call Rust directly or access undocumented internals
- Create a typed API layer at `src/api/` — one file per domain (e.g. `src/api/files.ts`). Each export wraps `invoke()` with TypeScript types matching the Rust command signature
- Rust `#[command]` return types (serialised structs) → mirror as TypeScript interfaces in `src/api/types.ts`; the Rust struct and the TS interface are a contract — changes to one require changes to the other

## Tauri events in React
- Subscribe to Tauri events with `listen()` inside `useEffect` — always return the unsubscribe function as the effect cleanup
- Never subscribe outside an effect; leaked subscriptions survive component unmounts and cause duplicate handlers on re-mount
- App-wide events (update status, background progress, system tray) belong in a top-level context provider, not in leaf components

## Capability scoping
- List only the capabilities actually used in `tauri.conf.json` — no `fs:read-all`, no `shell:open-all` blanket grants; the default deny is a security boundary, not a configuration default to work around
- Every new Rust shell command must be explicitly allow-listed
- Scope file system paths to the minimum required directory; prefer `$APP` and `$DOCUMENT` over absolute paths

## State management
- Tauri backend `State<T>` is the source of truth for system resources — React state is the UI projection; never derive backend truth from frontend state
- On app startup, fetch initial backend state via `invoke()` calls; do not assume React defaults match Rust defaults
- For long-lived backend state changes (file watcher, background process): use Tauri events, not polling via `setInterval`

## Build and dev
- `tauri dev` starts both Vite and the Rust process — never start Vite separately when developing; running them independently misses Tauri's dev injection
- `cargo check` runs before `tauri build` in CI; Rust type errors break the final binary, not just the Rust crate
- Commit `src-tauri/Cargo.lock` — Tauri's dependency graph is large; reproducible builds require a locked manifest
