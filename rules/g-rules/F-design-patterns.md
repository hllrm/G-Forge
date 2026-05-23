## F · Design Patterns

**Principles**
- **Composition over inheritance** — favour small, focused units composed together. Inheritance for true is-a relationships only; everything else is composition or delegation.
- **Explicit over implicit** — visible dependencies, clear data flow, no magic registration or auto-wiring. If you can't trace where something comes from by reading the call site, it's too implicit.
- **YAGNI** — no abstractions, generics, base classes, or extensibility hooks until there is a second concrete use case. The first use case defines the shape; the second reveals the pattern.
- **Fail fast at boundaries** — validate and throw at system entry points (user input, external API, IPC). Never let invalid state propagate inward; never swallow it silently.
- **Observer / event-driven** — decouple producers from consumers via events, signals, or channels. Components that react to state changes subscribe; they do not poll, reach up the hierarchy, or hold a direct reference to the emitter. The emitter knows nothing about its subscribers.
- **State machine for discrete modes** — when a unit has ≥3 mutually exclusive modes (loading/idle/error, grounded/jumping/falling, locked/unlocked/expired), model them as an explicit state machine — not nested booleans, not string comparisons, not flag fields. Each state owns its enter, update, and exit behaviour.

**Anti-patterns — refuse unless there is an explicit documented reason**
- **God object / god component** — one class or component responsible for more than one coherent concern. Split by responsibility, not by line count.
- **Prop drilling past 2 levels** — pass data through more than two component layers via props. Use a store, context, or composable instead.
- **Business logic in the UI layer** — pages and components wire state and handle events; they do not compute, transform, or validate domain data. Extract to lib/, services/, or composables/.
- **Mutable module-level state** — module-level `let` that is mutated at runtime causes invisible coupling between callers and breaks SSR and test isolation.
- **Premature abstraction** — a shared utility, base class, or generic extracted from a single use case. Wait for the second caller; the first use case defines the interface, the second validates it.
- **Magic values** — naked numbers or strings with non-obvious meaning inline in logic. Extract to a named constant with a comment if the name alone isn't self-evident.
- **Circular dependencies** — always indicates a layer boundary violation or a missing intermediate abstraction. Resolve by extracting the shared dependency or inverting the dependency direction.
- **Catch-and-continue** — `catch (e) {}` or `catch (e) { return null }` without logging, re-throwing, or surfacing to the caller. Every caught error must be handled explicitly or re-thrown.

**Stack-specific patterns** live in `.claude/rules/architecture-<stack>.md`, installed by `/g-specialize`. The rules above apply universally; stack rules add or refine them for the specific architecture.
