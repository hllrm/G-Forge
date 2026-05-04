## Android + Kotlin + Jetpack Compose + MVVM Architecture Rules

**Layer map:**
- `ui/screens/` — `@Composable` screen functions; collect `StateFlow` from ViewModel; pass events as lambdas; no business logic
- `ui/components/` — reusable `@Composable`s; pure UI; no ViewModel or domain imports
- `ui/viewmodels/` — `ViewModel` + Hilt; hold `StateFlow<UiState>` (sealed class); call UseCases; expose read-only `StateFlow`
- `domain/usecases/` — single-responsibility classes; one public `invoke` function; return `Flow<Result<T>>` or `suspend`; call repository interfaces
- `data/repositories/` — `IXxxRepository` interface + `XxxRepositoryImpl`; map data sources to domain models; no business logic
- `data/sources/` — Room DAOs, Retrofit services, DataStore; raw data access only
- `di/` — Hilt `@Module` classes; `@Binds`/`@Provides` only; no logic or side effects

**Import direction:** screens → viewmodels → usecases → repository interface → data sources. Components are leaves. DI modules bind implementations to interfaces. No layer imports upward.

**StateFlow rule:** ViewModels expose a single `StateFlow<UiState>` with a sealed class. `MutableStateFlow` is always private. Use `collectAsStateWithLifecycle()` in screens, not `collectAsState()`. One-shot events use `Channel`/`SharedFlow`.

**UseCase rule:** One public function (`operator fun invoke`). One distinct business operation per class. UseCases must not call other UseCases — compose in ViewModel. Inject repository interfaces, not implementations.

**Repository rule:** Always backed by an interface. Implementation in `data/repositories/`. Maps raw source data (entities, DTOs) to domain models. No business filtering or transformation logic.

**LiveData rule:** `LiveData` is banned in new code. Use `StateFlow` and `SharedFlow` throughout.

**Hilt rule:** `@Singleton` on repositories and network objects. ViewModels use `@HiltViewModel`. No logic in `@Module` classes.
