## Laravel Architecture Rules

**Layer map:**
- `app/Http/Controllers/` — thin HTTP handlers; delegate to service immediately; return Resources; no business logic
- `app/Http/Requests/` — Form Request validation and authorization only; no business logic
- `app/Http/Resources/` — API response shaping; no business logic
- `app/Services/` — all business logic; constructor-injected dependencies; no Facades in new code; no HTTP awareness
- `app/Repositories/` — all Eloquent query encapsulation; CRUD and complex queries; no business logic
- `app/Models/` — Eloquent relationships, scopes, accessors/mutators only; no business logic methods
- `app/DTOs/` — immutable data transfer objects; plain PHP or `spatie/data`
- `app/Support/` — pure helper classes; no Eloquent, no HTTP

**Import direction:** Controllers → Services → Repositories → Models. Requests and Resources are leaves. DTOs and Support are leaves. Never upward.

**Controller rule:** No Eloquent calls, no Facade calls, no inline `$request->validate()`. Every controller method is: receive FormRequest, call service, return Resource.

**Service rule:** Inject dependencies via constructor — no `Mail::`, `Cache::`, `Queue::` Facades in new service code. Wrap multi-model writes in `DB::transaction()`. Raise domain exceptions, never `abort()` or `HttpException`.

**Repository rule:** All `::query()`, `->where()`, `->with()`, `->paginate()` chains live in repositories. Services never build Eloquent queries directly.

**Model rule:** Methods are limited to relationships, query scopes, and accessors. No cross-model writes, mail sends, or business rules inside model methods or `boot()`.
