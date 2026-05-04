## Electron + TypeScript Architecture Rules

**Layer map:**
- `main/` — main process; window management, IPC handlers, all Node.js/native APIs; delegates logic to `main/services/`
- `renderer/` — web frontend (React/Vue); no Node.js imports; communicates only via `window.api`
- `preload/` — `contextBridge.exposeInMainWorld` declarations only; thin IPC wrappers; no business logic; no Node built-ins except `ipcRenderer`
- `shared/types/` — TypeScript interfaces shared across processes; no runtime code

**Import direction:** main → shared/types. renderer → shared/types. Preload is a bridge only. Renderer never imports from main or Node.js built-ins.

**IPC rule:** All IPC goes through `contextBridge`. `ipcRenderer` is used only in preload. Renderer calls `window.api.*`. Main handles via `ipcMain.handle`. IPC handler callbacks are thin — delegate to `main/services/`.

**Security rule (non-negotiable):** `nodeIntegration` must be `false`. `contextIsolation` must be `true`. `webSecurity` must not be disabled. These are BLOCKING violations.

**Preload rule:** Preload files must stay under ~80 lines. Only `ipcRenderer.invoke`/`send`/`on` wrappers are allowed. Any computation belongs in main.

**Renderer rule:** No `import` of `electron`, `fs`, `path`, `os`, or any Node built-in in renderer source files. All native capabilities accessed through typed `window.api` wrappers.
