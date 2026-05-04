## Spring Boot 3 Architecture Rules

**Layer map:**
- `controller/` — `@RestController`; parse HTTP input, call one service method, return response DTO; no business logic
- `service/` — `@Service`; all business logic; owns `@Transactional` boundaries; calls repositories
- `repository/` — `@Repository`; Spring Data JPA interfaces and custom JPQL; no business logic
- `entity/` — `@Entity` JPA models; table mapping only; no HTTP or service concerns
- `dto/` — plain Java/Kotlin request and response classes; no JPA annotations
- `exception/` — custom exceptions and `@ControllerAdvice` handlers; centralized error mapping
- `config/` — `@Configuration` beans and security setup; no business logic

**Import direction:** controller → service → repository → entity. DTOs and exceptions are leaves. Never import upward.

**DTO rule:** Separate classes for request (Create/Update) and response. Never return an entity from a controller. No sensitive fields (passwords, secrets) in response DTOs.

**Transaction rule:** `@Transactional` belongs on service methods, never on controllers. Multi-repository write paths must be wrapped in a single transaction. Read-only queries use `@Transactional(readOnly = true)`.

**Entity rule:** Entities are pure JPA mapping — no business methods, no `@JsonIgnore` hacks. Use `FetchType.LAZY` on collections. `equals`/`hashCode` based on `id` only.

**Exception rule:** All `@ExceptionHandler` methods live in a single `@ControllerAdvice` class. Controllers do not catch domain exceptions — they propagate to the advice.
