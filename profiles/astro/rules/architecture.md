## Astro Architecture Rules

**Layer map:**
- `src/pages/` — `.astro` page files; file-based routing; data fetching in frontmatter; static by default
- `src/layouts/` — Astro layout wrappers; static; no framework hooks
- `src/components/` — static `.astro` components; zero JS output; server-rendered HTML only
- `src/islands/` — interactive framework components (React/Vue/Svelte); hydrated with `client:*` directive at the use site
- `src/content/` — content collections with Zod-validated schemas in `config.ts`
- `src/lib/` — server-side utilities and data fetching helpers; no Astro/framework imports

**Import direction:** pages → layouts/components/islands/lib. Islands receive data as props from pages. Islands do not use `astro:content`.

**Static-first rule:** Default to `.astro` components with zero client JS. Only move to an island when you need interactivity (state, event handlers, browser APIs). No `client:*` on static components.

**Island directive rule:** Use the least aggressive directive: prefer `client:visible` for below-fold content, `client:load` only for above-fold interactive components, `client:only` as a last resort.

**Content rule:** All content in `src/content/` must have a `defineCollection` schema with Zod in `config.ts`. Use `getCollection()`, not `Astro.glob()`.

**Data flow rule:** Fetch data in page frontmatter and pass it as props to islands. Islands must not `fetch()` independently for data that the server can provide.

**Environment rule:** `SECRET_*` env vars must never appear in island code — they are exposed to the browser. Server-side only.
