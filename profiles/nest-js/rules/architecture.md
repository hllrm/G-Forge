## NestJS Architecture Rules

**Layer map:**
- `src/<feature>/<feature>.module.ts` — one module per domain feature; declares providers, imports, exports
- `src/<feature>/<feature>.controller.ts` — HTTP routing only; extract request data, call service, return response; no business logic
- `src/<feature>/<feature>.service.ts` — all business logic; Injectable providers; framework-agnostic logic
- `src/<feature>/<feature>.repository.ts` — data access only; TypeORM/Prisma calls; no business logic
- `src/<feature>/entities/` — TypeORM entities or domain types; DB schema definition only
- `src/<feature>/dto/` — class-validator decorated shapes; separate Create, Update, and Response DTOs
- `src/guards/` — `CanActivate` implementations; auth/authorization checks only; no side effects
- `src/interceptors/` — response transformation and logging; no business logic

**Import direction:** controllers → services → repositories → entities. DTOs are leaves. Guards import services but never controllers. Never import upward.

**Module rule:** One module per domain feature. Modules import other modules, not their internals. Only export providers that other modules need.

**DTO rule:** All DTOs used with `ValidationPipe` must have `class-validator` decorators on every field. Separate request DTOs (`CreateDto`, `UpdateDto`) from response DTOs (`ResponseDto`). Never expose password fields in response DTOs.

**Controller rule:** Controllers handle HTTP concerns only — parameter extraction, calling one service method, returning the result. Any conditional logic or multi-step operations belong in the service.

**Guard rule:** Guards check authorization only. Recording events, updating state, or calling non-auth services is a violation — use interceptors for side effects.
