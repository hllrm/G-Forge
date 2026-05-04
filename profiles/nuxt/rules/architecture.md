## Nuxt 3 + Pinia Architecture Rules

**Layer map:**
- `pages/` — file-based route views; thin orchestration; composables do the work
- `components/` — reusable UI; auto-imported; props in, events out; no direct store imports
- `composables/` — shared reactive logic; auto-imported; home for `useFetch`/`useAsyncData` calls; may access stores
- `stores/` — Pinia setup stores; auto-imported via `useXxxStore()`; no `$fetch` calls inside
- `server/api/` — Nitro server route handlers; no Vue or Pinia imports; HTTP verb in filename (`.get.ts`, `.post.ts`)
- `utils/` — pure utility functions; auto-imported; no Vue reactivity
- `types/` — shared TypeScript interfaces; no runtime logic

**Import direction:** pages → components → composables → stores/utils. Server routes are fully isolated from client code.

**Auto-import rule:** Never manually import from `composables/`, `stores/`, `utils/`, or `components/`. Nuxt auto-imports them. Manual imports are only acceptable in `server/api/` and test files.

**State rule:** Setup stores only (no Pinia Options API). Store names must match `useXxxStore` convention. Stores do not call `$fetch` — composables do.

**Server rule:** `server/api/` files are Nitro handlers. They must not import Vue, Pinia, or client-side utilities. Use `defineEventHandler`, `getQuery`, `readBody`.

**Composable rule:** All `useFetch`/`useAsyncData` calls live in `composables/`. Components never call these directly.
