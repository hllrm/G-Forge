## Node.js + TypeScript Architecture Rules

**Layer map:**
- `src/routes/` — HTTP handler registration; validate input, call service, return response; no business logic
- `src/services/` — all business logic; framework-agnostic; calls repositories and external APIs
- `src/repositories/` — data access only; no business logic; wraps ORM/DB calls
- `src/models/` — TypeScript interfaces and ORM entity definitions
- `src/middleware/` — auth, logging, validation, error handling
- `src/utils/` — pure utility functions; no side effects
- `src/config/` — environment loading; all `process.env` access goes here only

**Import direction:** routes → services → repositories → models. Never upward. Config and utils are leaves (no project imports).

**TypeScript rule:** No `any` in public function signatures. Explicit return types on all exported functions. `process.env` only in `src/config/`.

**Async rule:** `async/await` everywhere. No raw `.then()` chains. All async paths have error handling.

**Error rule:** Services throw typed errors. Routes catch and format. Never expose raw error objects in HTTP responses.
