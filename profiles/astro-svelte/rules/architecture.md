## Astro + Svelte Islands — Combo Architecture Rules

These rules extend the base Astro and SvelteKit profiles with patterns that only emerge when Svelte components are used as Astro islands. Both the `astro` and `sveltekit` profiles must be installed alongside this combo.

**Layer map (seam):** Astro pages/layouts (`.astro`) are the server/orchestration layer — they own routing, data fetching, and layout composition. Svelte islands (`src/islands/`) are the interactive leaf layer — they own client-side interaction and rendering only. Import direction across the seam is one-way: Astro → island, via JSON-serializable props passed at render time. Islands never import `.astro` files or `Astro.*` globals — those are server-only and absent from the browser bundle. `$app/*` (SvelteKit router/page-store APIs) is also absent in this context — see the SvelteKit-specific note below.

**Island placement rule:** Interactive Svelte components live in `src/islands/`, not `src/components/`. Static `.astro` components live in `src/components/`. A `.svelte` file in `src/components/` is a violation.

**Prop serialization contract:** Props passed from Astro pages to Svelte islands must be JSON-serializable. Permitted: strings, numbers, booleans, plain objects, arrays, null. Forbidden: functions, class instances, Dates (convert to ISO string first), Maps, Sets. Svelte receives props as standard component props (`export let propName`).

**Cross-island state — Svelte exception:** Unlike React and Vue islands, Svelte islands on the same page share module-level Svelte stores (writable/readable/derived) defined in external `.ts` store files. This is because Svelte compiles store subscriptions to direct DOM updates without a virtual DOM reconciler — the store lives in the module scope, which IS shared across islands. This means native Svelte stores are the correct cross-island state mechanism for Svelte islands. Nanostores are also supported (`@nanostores/svelte`) and are preferred when stores must be shared with non-Svelte islands on the same page.

**Hydration directive rule:** Apply the least aggressive `client:*` directive:
- `client:visible` — default for below-the-fold interactive islands
- `client:load` — above-the-fold islands that must be interactive on page load
- `client:idle` — islands that enhance but are not critical
- `client:only="svelte"` — last resort for islands that cannot SSR; must have a fallback slot or skeleton

**Data flow rule:** Islands receive data as props from Astro pages. Islands must not `fetch()` independently for data the server can provide in frontmatter. `fetch()` inside a Svelte island is permitted only for user-triggered actions or real-time subscriptions.

**Svelte-specific rules inside islands:** Standard Svelte conventions apply within islands — reactive declarations (`$:`), stores, event dispatching. SvelteKit-specific APIs (`goto`, `page` store, form actions) are NOT available in Astro context — they require SvelteKit's router, which is absent. Use only Svelte core; do not import from `$app/*`.
