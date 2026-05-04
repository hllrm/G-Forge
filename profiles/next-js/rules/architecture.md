## Next.js 14 App Router Architecture Rules

**Layer map:**
- `app/` — server components by default; pages, layouts, loading/error boundaries; fetch data directly with `async/await`
- `components/` — client components; require `'use client'` directive; receive serializable props from server components; no direct DB access
- `actions/` — server action functions; require `'use server'` directive; handle mutations, validate input, call `revalidatePath`/`revalidateTag`
- `lib/` — utilities and DB helpers; server-only or isomorphic; never imports from `app/` or `components/`
- `types/` — shared TypeScript interfaces; no runtime logic; no directives

**Import direction:** app → components/actions/lib → types. Client components never reach into server-only code.

**Server/client rule:** Server components are the default. Add `'use client'` only when the component needs interactivity (hooks, event handlers, browser APIs). Never put `'use client'` on layout wrappers or purely static components.

**Data fetching rule:** Fetch data in server components. Parallelize independent fetches with `Promise.all`. Never use `useEffect` + `fetch` for initial data load in client components.

**Mutation rule:** All mutations go in `actions/` with `'use server'`. Validate input with Zod. Call `revalidatePath` or `revalidateTag` after writes. Never write mutation logic inline in page components.

**Route handler rule:** `app/api/` route handlers serve external clients or webhooks. Do not create route handlers just to proxy data to your own server components — fetch directly.
