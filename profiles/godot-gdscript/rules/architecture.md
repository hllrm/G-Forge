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
