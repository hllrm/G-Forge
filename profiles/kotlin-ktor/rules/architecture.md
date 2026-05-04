## Ktor + Kotlin Architecture Rules

**Layer map:**
- `routes/` — Ktor routing DSL; parse HTTP input, call service, respond; no business logic; no DB access
- `services/` — suspend business logic functions; return sealed `ServiceResult<T>` or `Either`; call repositories
- `repositories/` — data access via Exposed or other DB library; no business logic
- `models/` — pure Kotlin domain data classes; no framework annotations
- `dto/` — request/response data classes; `@Serializable` annotations live here
- `plugins/` — Ktor plugin installation (`ContentNegotiation`, `Authentication`, `CORS`); routing wiring entry point
- `di/` — Koin module definitions; binding only, no logic

**Import direction:** routes → services → repositories → models. DTOs and models are leaves. Plugin wiring calls routes. DI module references services and repositories only.

**Routing rule:** Route blocks parse the request, call exactly one service function, and respond. Any logic beyond that belongs in the service layer.

**Error rule:** Use sealed classes for typed service results. Services must not throw exceptions for expected domain outcomes (not-found, conflict, unauthorized). Routes pattern-match on the sealed result.

**Coroutine rule:** All suspend functions must not call `runBlocking`. DB access wrapped in `newSuspendedTransaction(Dispatchers.IO)`. Never swallow `CancellationException`.

**DI rule:** All dependencies resolved via Koin. No `new`/manual instantiation of services or repositories in routes or plugins.
