## Rust + Axum Architecture Rules

**Layer map:**
- `src/routes/` — Axum handler functions and router wiring; extract state/params, call service, return `Result<impl IntoResponse, AppError>`
- `src/services/` — all business logic; returns `Result<T, AppError>`; no Axum imports
- `src/repositories/` — DB access via `sqlx`/`diesel`; returns `Result<T, AppError>`; no business logic
- `src/models/` — domain structs with `Serialize`/`Deserialize`; no logic methods
- `src/errors/` — `AppError` enum implementing `IntoResponse`; all error-to-HTTP mapping lives here
- `src/state.rs` — `AppState` struct (DB pool, config); `Clone` derived; injected via `State<AppState>`

**Import direction:** routes → services → repositories → models. Errors and models are leaves. Never import upward.

**Error rule:** All errors use the typed `AppError` enum. `AppError` implements `IntoResponse` — all HTTP status mapping lives there, not in handlers. Use `?` to propagate. No `unwrap()` or `expect()` in handlers, services, or repositories.

**Handler rule:** Handlers extract state via `State<AppState>`, path/query params via `Path`/`Query`, and bodies via `Json`. They call one service method and return the result. No DB access, no business logic.

**Async rule:** No blocking operations (`std::thread::sleep`, `std::fs::read`) inside `async` functions. Use `tokio` equivalents or `spawn_blocking` for CPU-bound work.

**State rule:** `AppState` is the single shared struct. Inject via `Router::with_state()`. No global mutable statics.
