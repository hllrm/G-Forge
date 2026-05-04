## ASP.NET Core 8 Architecture Rules

**Layer map:**
- `Controllers/` — thin action methods; delegate to `IXxxService`; return `ActionResult<DTO>`; no business logic
- `Services/` — business logic behind `IXxxService` interfaces; injected into controllers; call repositories
- `Repositories/` — EF Core data access behind `IXxxRepository` interfaces; no business logic
- `Models/` — EF Core entity classes; table mapping only; no HTTP concerns
- `DTOs/` — request and response record/class types; no EF attributes
- `Middleware/` — `IMiddleware` pipeline components; cross-cutting concerns only
- `Extensions/` — `IServiceCollection` extension methods for DI registration; keeps `Program.cs` clean

**Import direction:** Controllers → Services (interface) → Repositories (interface) → Models. DTOs are leaves. Never import upward. No direct DbContext in controllers or services.

**Interface rule:** Every service and repository must be backed by an interface. Inject the interface, never the concrete class. Enables unit testing and loose coupling.

**Async rule:** All I/O must be `async`/`await` all the way. No `.Result`, `.Wait()`, or `.GetAwaiter().GetResult()`. Propagate `CancellationToken` through the call chain.

**DTO rule:** Separate request and response types. Never return an EF entity from a controller. No sensitive fields (passwords, hashes) in response DTOs.

**Program.cs rule:** DI registration and pipeline configuration only. No inline route handlers, no DbContext access, no business logic.
