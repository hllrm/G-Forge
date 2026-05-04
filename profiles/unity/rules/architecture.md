## Unity Architecture Rules

**Layer map:**
- `Scripts/Core/` — pure C# game systems (physics, AI, input processing); no MonoBehaviour
- `Scripts/Gameplay/` — MonoBehaviour coordinators for player, enemies, items; thin wiring only
- `Scripts/UI/` — UI controllers; reads state via events or injected references; no game logic
- `Scripts/Data/` — ScriptableObjects for configuration and event channels; no runtime logic
- `Scripts/Services/` — audio, save, analytics; accessed via DI or ScriptableObject event channels
- `Prefabs/` — scene-ready GameObjects; no logic

**Import direction:** Gameplay → Core/Data/Services. UI → Data/Services only (never Gameplay). Core → Data. Never upward.

**MonoBehaviour rule:** MonoBehaviours are thin coordinators. Delegate all logic to plain C# classes in Core. No business logic in `Update()` beyond a single dispatch call (e.g., `_stateMachine.Tick()`).

**Singleton rule:** Static singletons on MonoBehaviours are a last resort. Use ScriptableObject event channels for decoupled communication and constructor-injected plain C# classes for systems.

**Runtime lookup rule:** No `FindObjectOfType<T>()` or `GameObject.Find()` at runtime. Wire references via serialized fields, ScriptableObject channels, or a DI container at scene load.

**ScriptableObject rule:** All shared configuration lives in `Scripts/Data/` as ScriptableObjects with `[CreateAssetMenu]`. Event channels (`VoidEventChannel`, `IntEventChannel`, etc.) replace singleton event buses.

**Update discipline:** Physics goes in `FixedUpdate()`. Input goes through an `InputReader` ScriptableObject. `GetComponent<T>()` must be cached in `Awake()`, never called per-frame.
