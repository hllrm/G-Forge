# Electron + Vue 3 + Pinia Architecture Rules

## Context bridge (IPC boundary)
- All main-process capabilities exposed via `contextBridge.exposeInMainWorld()` in `preload.ts` — never use the `remote` module or set `contextIsolation: false`
- Declare the exposed API as a TypeScript interface and augment the global `Window` type in `src/types/global.d.ts` — no bare `(window as any)` casts in renderer code
- Pinia stores access Electron exclusively via `window.electronAPI.*` — never import `electron` in renderer files

## IPC channel discipline
- All two-way calls use `ipcMain.handle()` / `ipcRenderer.invoke()` pairs
- Channel names are string constants exported from `src/shared/ipc-channels.ts` — no bare string literals; mismatched channel names are silent failures
- One handler per channel in main; one matching call site per channel in the store that owns that data domain

## Pinia + Electron IPC integration
- Stores that mirror main-process state own their `window.electronAPI.on()` subscriptions — not components
- Subscribe inside the store's setup function; hold the unsubscribe function and call it in `$dispose` or on app unmount — leaked subscriptions cause duplicate handlers across hot reloads
- Components read from the store; they call store actions; they never call `window.electronAPI.*` directly
- For one-shot reads (file content, app version, system info): store action calls `ipcRenderer.invoke()`, updates state, components read reactive state

## State across windows
- Each BrowserWindow has its own Vue app and its own Pinia instance — they do not share reactive state across process boundaries
- Shared app state lives in main; windows sync via IPC events; stores re-fetch from main on reload rather than restoring renderer-side persisted state
- Cross-window events: main broadcasts via `BrowserWindow.webContents.send()`, stores subscribe in setup

## Build
- Renderer and main are separate build targets — cross-target imports will fail at runtime; verify both targets build in CI
- `electron-builder` must declare all native modules to prevent packaging failures
- In development, start the renderer dev server before spawning Electron — use `wait-on` or equivalent
