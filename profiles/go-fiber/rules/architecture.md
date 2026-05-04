## Go + Fiber Architecture Rules

**Layer map:**
- `cmd/` — entry points; configure `fiber.New()` with `ErrorHandler`, wire deps, start server; no business logic
- `internal/routes/` — route group registration; group paths, attach middleware per group; no handler logic
- `internal/handlers/` — HTTP only; `*fiber.Ctx` parsing, call service, `c.JSON()` response; no business logic
- `internal/services/` — all business logic; no Fiber imports; accepts `context.Context` as first arg
- `internal/repository/` — data access only; SQL/ORM queries; returns domain models or typed errors
- `internal/models/` — domain struct definitions and typed error types
- `internal/middleware/` — `fiber.Handler` functions: auth, logging, rate limiting, recovery
- `pkg/` — shared utilities; no imports from `internal/`

**Import direction:** routes → handlers → services → repository → models. Middleware and pkg are leaves. Never import upward.

**Handler rule:** Use `c.BodyParser()` for binding, `c.UserContext()` for context propagation, `c.JSON()` for responses. Return typed errors — let `fiber.ErrorHandler` map them to status codes.

**Route rule:** All route registrations live in `internal/routes/`, never in `cmd/` or `main.go`.

**Error rule:** Domain errors are typed structs. Services return typed errors. `fiber.ErrorHandler` in `fiber.Config` maps them centrally. Handlers return `err` — never inline `c.Status(500).JSON(...)`.

**Context rule:** Pass `c.UserContext()` from handler to service. Never use `context.Background()` inside a live request path.
