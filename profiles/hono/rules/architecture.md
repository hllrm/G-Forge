## Hono Architecture Rules

**Layer map:**
- `src/routes/` — Hono route handlers; validate via `zValidator`, call service, respond with `c.json()`
- `src/middleware/` — Hono middleware functions; auth, logging, CORS; set typed context variables via `c.set()`
- `src/services/` — business logic; edge-compatible; accepts `env: Env['Bindings']` as parameter; no Hono imports
- `src/types/` — shared `Env` type (Bindings + Variables), Zod schemas, TypeScript interfaces; no runtime logic

**Import direction:** routes → services, middleware → services. Types are a leaf. Services never import from routes.

**Edge rule:** No Node.js APIs anywhere. Banned: `process.env`, `Buffer`, `fs`, `path`, `http`, `require()`, `process.nextTick`, `setImmediate`. Use Web Platform APIs: `crypto.subtle`, `TextEncoder`, `fetch`, `URL`.

**Env rule:** All environment variables and Workers bindings accessed via `c.env` in routes, then passed to services. Never `process.env`.

**Validation rule:** All request bodies and query parameters validated with `zValidator` middleware using Zod schemas before the handler runs. `c.req.valid()` returns the typed, validated payload.

**Error rule:** One `app.onError()` handler configured in `src/app.ts`. Route handlers return typed `AppError` — never inline `c.json({ error: ... }, 500)` for unexpected errors.
