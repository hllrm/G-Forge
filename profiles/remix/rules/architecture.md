## Remix v2 Architecture Rules

**Layer map:**
- `app/routes/` — file-based routing; loader + action + route component colocated in one file; `loader` fetches data, `action` handles mutations
- `app/components/` — reusable UI; receive props from route components; never call `useLoaderData()` directly; no service imports
- `app/services/` — data access and external APIs; server-only (use `.server.ts` suffix); no Remix imports (`json`, `redirect`)
- `app/utils/` — pure isomorphic utility functions; no Remix or DB imports
- `app/types/` — shared TypeScript interfaces; no runtime logic

**Import direction:** routes → components/services/utils. Components receive data via props. Services are called only from loaders and actions.

**Loader rule:** All data fetching happens in `loader` functions. Never use `useEffect` + `fetch` for initial data. Route components call `useLoaderData<typeof loader>()` for type safety.

**Action rule:** All mutations go through `action` functions. Validate form input before writing. Return `json({ error }, { status: 400 })` on validation failure. Use `redirect(url, { status: 303 })` after successful POST.

**Progressive enhancement rule:** Forms must work without JavaScript. Use `<Form method="post">` for actions. `useFetcher` is an enhancement — not a replacement for proper actions.

**Service rule:** Service files containing DB access or secrets must use the `.server.ts` suffix to prevent accidental client bundle inclusion. Services are framework-agnostic: no `json`, `redirect`, or `@remix-run/*` imports.
