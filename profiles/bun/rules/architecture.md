## Bun + Elysia Architecture Rules

**Layer map:**
- `src/routes/` — Elysia route definitions; TypeBox-validated input; call service; no business logic
- `src/services/` — all business logic; calls repositories; throws typed `AppError`; no Elysia imports
- `src/repositories/` — data access only; DB queries; returns domain models or throws
- `src/models/` — domain TypeScript interfaces and TypeBox schema definitions
- `src/types/` — shared types, Elysia context extensions, `AppError` class

**Import direction:** routes → services → repositories → models. Types are a leaf. Never import upward.

**Schema rule:** Every Elysia route with a body, query string, or params must declare a TypeBox `t.Object()` schema in the route config. Unvalidated inputs are a violation.

**Guard rule:** Auth and other cross-cutting context injection uses `.derive()` on a named Elysia plugin. Never repeat auth logic inline in route handlers.

**ESM rule:** No `require()`, `module.exports`, or `exports.`. ESM `import`/`export` only. Use `import.meta.dir` instead of `__dirname`. Include `.ts` extensions in local import paths.

**Error rule:** One `.onError()` lifecycle handler in `src/app.ts`. Route handlers throw `AppError` — never inline `set.status = 500` for unexpected errors. TypeBox `VALIDATION` code must be handled in `onError`.
