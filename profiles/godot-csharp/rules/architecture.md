## Godot 4 C# Architecture Rules

**Layer map:**
- `Scenes/<Feature>/` — scene files and partial node classes; self-contained; communicate via Godot signals
- `Scripts/Core/` — plain C# classes for game systems (state machines, AI, physics); no Node inheritance
- `Scripts/Nodes/` — reusable Node subclasses; thin coordinators that delegate logic to Core classes
- `Scripts/Data/` — `Resource` subclasses with `[Export]` properties only; no Node references or runtime state
- `Scripts/UI/` — `Control`/`CanvasLayer` subclasses; no game logic; reads state via signals or injected data

**Import direction:** Scenes → Nodes/Core/Data. Nodes → Core/Data. UI → Data only. Core → Data. Never upward.

**Partial class rule:** Node partial classes are thin coordinators. Logic goes in plain C# classes in `Scripts/Core/`. No business logic in `_Process()` beyond a single delegate call.

**Signal rule:** Use `[Signal]` attribute with `*EventHandler` delegate naming. Emit via `EmitSignal(SignalName.*)` — never raw strings. Upward communication via signals; internal system callbacks via C# `event`.

**Typed reference rule:** No string-based node paths (`GetNode("path/to/node")`). Expose typed node references via `[Export]` for editor wiring. `GetNode<T>()` only when type is known and path is local; cache in `_Ready()`, never in `_Process()`.

**Service rule:** Cross-system communication uses a ServiceLocator or autoload. Do not walk the scene tree (`GetTree().Root.GetNode(...)`) to find services. Do not pass services through 3+ constructor levels.

**Data rule:** `Resource` subclasses are pure data. No `@onready` equivalent, no Node references, no scene access. `[Export]` for all configurable properties.

**Object pooling rule:** For frequently spawned nodes (bullets, particles, enemies), implement a `NodePool<T>` wrapper backed by a `Queue<T>` in `Scripts/Core/`. Pre-warm in the owning scene's `_Ready()`. Call `pool.Return(node)` instead of `node.QueueFree()`. Never allocate new nodes per-frame on hot paths. Pool size should be determined by worst-case concurrent active count, not an arbitrary constant.

**State machine rule:** Define an `IState` interface with `Enter()`, `Exit()`, and `Update(double delta)` in `Scripts/Core/`. A `StateMachine` class holds the current `IState` and calls `Tick(delta)`. Node scripts delegate in `_Process()` — no state-string `switch` or boolean flag chains in Node code. Transitions are owned by the state machine or by states triggering them on the machine — never from outside the state machine boundary.
