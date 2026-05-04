## Unreal Engine 5 Architecture Rules

**Layer map:**
- `Source/<Project>/Core/` — `AGameMode`, `AGameState`, `AGameInstance`; game rules only; no per-actor logic
- `Source/<Project>/Characters/` — `ACharacter` subclasses; thin coordinators; delegate behaviour to Components
- `Source/<Project>/Components/` — `UActorComponent` subclasses; all gameplay logic lives here; composable and reusable
- `Source/<Project>/Systems/` — `UGameInstanceSubsystem`/`UWorldSubsystem` for global services
- `Source/<Project>/UI/` — `UUserWidget` subclasses; display only; no gameplay logic; bind to delegates or GameState
- `Content/Blueprints/` — data-only or thin wiring Blueprints; no logic that belongs in C++

**Import direction:** Characters → Components/Core/Systems. UI → Core/Systems only (never Characters or Components directly). Never upward.

**Component rule:** Logic belongs in Components, not Character subclasses. Prefer `Implements<UMyInterface>()` over `Cast<T>()` chains for capability discovery.

**Blueprint rule:** Blueprints configure and wire; C++ implements. No loops, state machines, or business logic in Blueprint event graphs. Logic-heavy graphs (>10 nodes, any loop) must move to C++.

**Subsystem rule:** Global services (audio, save, analytics) go in `UGameInstanceSubsystem` subclasses. `AGameMode` and `AGameInstance` must not accumulate service references.

**Reflection rule:** Every `UObject` pointer field must have `UPROPERTY()` for GC tracking. Every Blueprint-callable method needs `UFUNCTION(BlueprintCallable)`. Delegates exposed to Blueprints use `DECLARE_DYNAMIC_MULTICAST_DELEGATE`.

**Inheritance rule:** Avoid deep character inheritance chains. Flatten with Components. `AGameMode` contains only game rules, not spawning details or per-actor behaviour.

**Object pooling rule:** For high-frequency spawns (projectiles, hit effects, UI popups), implement a `UActorPoolComponent` or use Unreal's `SpawnActorDeferred` + `FinishSpawning` pattern with a free-list. Pooled actors are hidden and collision-disabled when inactive — not destroyed. Never call `SpawnActor`/`Destroy` per-frame or per-tick on gameplay-critical paths. Pool warm-up happens in `BeginPlay()`.

**State machine rule:** For character and AI states (grounded/airborne/attacking/stunned), use UE5's `UStateTreeComponent` (5.2+) for data-oriented state logic, or implement a custom `UStateMachineComponent` with a `TMap<EState, TScriptInterface<IState>>` for simpler cases. Avoid nested `if/else` on state enums in `Tick()`. Blueprint state machines are acceptable for animation-only state; gameplay logic belongs in C++ state classes.
