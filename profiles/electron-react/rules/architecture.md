# Electron + React Architecture Rules

## Context bridge (IPC boundary)
- All main-process capabilities exposed via `contextBridge.exposeInMainWorld()` in `preload.ts` — never use the `remote` module or set `contextIsolation: false`
- Declare the exposed API as a TypeScript interface and augment the global `Window` type in `src/types/global.d.ts` — no bare `(window as any)` casts in renderer code
- Renderer code accesses Electron exclusively via `window.electronAPI.*` — never import `electron` directly in renderer files

## IPC channel discipline
- All two-way calls use `ipcMain.handle()` / `ipcRenderer.invoke()` pairs — not `ipcMain.on()` for request/response patterns
- Channel names are string constants exported from `src/shared/ipc-channels.ts` — no bare string literals in renderer or main; mismatched channel names are silent failures
- One handler per channel in main; no dynamic channel name construction

## State across windows
- Shared app state lives in the main process — windows receive it via IPC, not shared renderer memory
- On window reload, state is re-fetched from main rather than restored from renderer-side storage
- Cross-window events: main broadcasts via `BrowserWindow.webContents.send()`, never renderer-to-renderer

## React + Electron lifecycle
- Subscribe to main-process events inside `useEffect` — always return the unsubscribe function as cleanup; never subscribe in component body or module scope
- App-wide events (update status, system tray, window focus) belong in a top-level context provider, not in leaf components
- Window visibility and focus signals come from main via IPC — do not rely on `document.visibilityState` alone in Electron

## Build
- Renderer and main are separate Vite/webpack targets — imports valid in one target may not resolve in the other; test both in CI
- `electron-builder` must declare all native modules to prevent packaging failures
- In development, start the renderer dev server before spawning Electron — use `wait-on` or equivalent; never hard-sleep
