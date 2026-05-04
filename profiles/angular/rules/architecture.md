## Angular 17+ Standalone Components Architecture Rules

**Layer map:**
- `src/app/features/` — feature folders with standalone components; self-contained; never import other features' internals
- `src/app/shared/components/` — reusable presentational standalone components; receive data via inputs only; no service injection
- `src/app/shared/services/` — reusable `providedIn: 'root'` services; business logic and state management shared across features
- `src/app/shared/models/` — TypeScript interfaces, enums, DTOs; no runtime logic
- `src/app/core/` — app-wide singletons: HTTP interceptors, auth guards, error handlers; no feature imports

**Import direction:** features → shared/components + shared/services + core → shared/models. Core never imports features.

**Standalone rule:** All components must be `standalone: true`. NgModule declarations are banned in new files.

**Injection rule:** Use `inject()` function for dependency injection in all new code. Constructor-based injection is banned in new files.

**Change detection rule:** `changeDetection: ChangeDetectionStrategy.OnPush` is required on every component. Default change detection is banned.

**Signals rule:** Prefer signal `input()` and `output()` over `@Input()`/`@Output()` decorators in new Angular 17+ code.

**HTTP rule:** HTTP calls belong in services only. Components never inject `HttpClient`. All `Observable` subscriptions in components must use `async` pipe or `takeUntilDestroyed()`.
