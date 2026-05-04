## Godot 4 GDScript Architecture Rules

**Layer map:**
- `scenes/<feature>/` — scene files and attached scripts; self-contained; expose behaviour via signals
- `scripts/core/` — autoload singletons for truly global systems (event bus, game state, settings, scene manager)
- `scripts/components/` — reusable node scripts composing behaviour across scenes
- `scripts/data/` — `Resource` subclasses for configuration and data containers; no runtime logic
- `scripts/ui/` — UI node scripts; reads data via signals or injected references; no game logic

**Import direction:** scenes → components/data/core (via autoload name). UI → data/core only. Components → data/core. Never upward via `get_parent()`.

**Signal rule:** Signals flow upward (child emits, parent or root connects). Never call `get_parent()` to invoke logic on a parent. Siblings communicate through a shared parent handler or the `GameEvents` autoload bus.

**Autoload rule:** Autoloads only for truly global systems. Maximum ~5 autoloads. Each should be single-purpose. Scene-specific state belongs in a scene-local node, not an autoload.

**Resource rule:** `Resource` subclasses in `scripts/data/` are pure data with `@export` properties. No `@onready`, no Node references, no scene access. Use `[CreateAssetMenu]` equivalent via `class_name` + `extends Resource`.

**Scene rule:** No business logic in `_ready()` beyond local init and `@onready` assignments. No absolute node paths. No `get_tree().get_nodes_in_group()` in `_process()`. `@export` for all configurable properties.

**Object pooling rule:** For frequently spawned nodes (bullets, particles, enemies), create a dedicated `Pool` node as a child of the scene root. Pre-instance nodes in `_ready()`. To "spawn": retrieve a hidden node, reposition, and show. To "despawn": hide and reset — never call `queue_free()` on pooled nodes. Never allocate new nodes per-frame on hot paths.

**State machine rule:** Model entities with ≥3 mutually exclusive states (idle/chase/attack/dead, grounded/airborne/wall-sliding) as an explicit state machine. Implement as a `StateMachine` node with `State` child nodes, each exposing `enter()`, `exit()`, and `update(delta)` methods. The root entity script calls `state_machine.update(delta)` in `_process()` — no `match` on state strings or nested `if/elif` chains in `_process()`. Transitions are triggered by states themselves or by the state machine, not from outside.
