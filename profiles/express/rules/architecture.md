## Express.js + TypeScript Architecture Rules

**Layer map:**
- `src/routes/` — Express Router wiring only; maps paths to controller methods; no logic
- `src/controllers/` — parse request, validate input, call service, format response; no business logic
- `src/services/` — all business logic; no Express imports (`req`/`res`/`next`); framework-agnostic
- `src/repositories/` — database access only; Mongoose/Prisma queries; no business logic
- `src/middleware/` — auth, logging, validation, centralized error handling
- `src/models/` — Mongoose schemas / Prisma types / domain interfaces; no logic
- `src/types/` — shared DTOs, interfaces, enums; no runtime code
- `src/config/` — environment loading; all `process.env` access goes here only

**Import direction:** routes → controllers → services → repositories → models. Types and utils are leaves. Never import upward.

**Controller rule:** Controllers validate and delegate only. Any logic beyond parse/call/return belongs in a service.

**Service rule:** Services must not import Express types. No `req`, `res`, or `next` in service files. Services throw typed errors; they never call `next()`.

**Error rule:** One centralized error middleware in `src/middleware/error.ts`, registered last in `app.ts`. All controllers call `next(error)`. Never send raw error objects or stack traces to the client.

**TypeScript rule:** No `any` in public function signatures. Explicit return types on all exported functions. `process.env` only in `src/config/`.
