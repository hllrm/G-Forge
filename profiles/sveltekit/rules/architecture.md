## SvelteKit Architecture Rules

**Layer map:**
- `src/routes/` — file-based routing; `+page.svelte` for UI, `+page.server.ts` for server load and form actions, `+layout.svelte`/`+layout.server.ts` for shared structure and data
- `src/lib/components/` — reusable Svelte components; props in, events out; no server imports; no service imports
- `src/lib/stores/` — Svelte writable/readable/derived stores for global client state; no API calls
- `src/lib/services/` — data access and external APIs; used only by `+page.server.ts` and `+server.ts` files
- `src/lib/types/` — shared TypeScript interfaces; no runtime logic
- `src/lib/utils/` — pure isomorphic utility functions; no SvelteKit server APIs

**Import direction:** route files → lib/components/lib/stores, server route files → lib/services. Components never import services.

**Load rule:** All data fetching happens in `+page.server.ts` or `+layout.server.ts` load functions. Never fetch in `onMount` or directly in page script blocks.

**Mutation rule:** Mutations use form actions in `+page.server.ts`. Forms use `method="POST"` and `use:enhance` for progressive enhancement. Prefer actions over `fetch` calls for mutations.

**Store rule:** Stores live in `lib/stores/`. Use `update()` or `set()` — never mutate store values directly. Stores do not call APIs.

**Progressive enhancement rule:** Forms must work without JavaScript. `use:enhance` adds JS enhancement on top — never make JS a hard requirement for core form flows.
