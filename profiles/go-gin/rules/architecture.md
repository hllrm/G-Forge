## Go + Gin Architecture Rules

**Layer map:**
- `cmd/` — entry points; wire dependencies, start server; no business logic
- `internal/handlers/` — HTTP only; bind request, call service, write JSON; no business logic
- `internal/services/` — all business logic; orchestrates repositories; framework-agnostic
- `internal/repository/` — data access only; SQL/ORM queries; returns domain models or errors
- `internal/models/` — domain struct definitions and typed error types; no business logic
- `internal/middleware/` — Gin middleware: auth, logging, rate limiting, recovery
- `pkg/` — shared utilities; no imports from `internal/`

**Import direction:** handlers → services → repository → models. Middleware and pkg are leaves. Never import upward. `cmd/` is the only wiring point.

**Context rule:** `context.Context` is the first parameter on every service and repository function. Handlers pass `c.Request.Context()`. Never use `context.Background()` inside a handler or service call chain.

**Error rule:** Domain errors are typed structs implementing the `error` interface. Services return typed errors. Handlers map typed errors to HTTP status codes using `errors.As()`. Never use string-matched errors for control flow.

**Handler rule:** Handlers bind input, call one service method, and write a JSON response. No SQL, no business decisions, no multi-step logic.

**Route rule:** All route registrations live in `internal/handlers/routes.go`, not in `cmd/` or `main.go`.
