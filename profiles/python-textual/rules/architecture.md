## Python Textual TUI Architecture Rules

**Layer map:**
- `app/app.py` — `App` subclass; screen management, service instantiation, global lifecycle only; no business logic
- `app/screens/` — `Screen` subclasses; compose layout, wire events, delegate to services; no business logic
- `app/widgets/` — custom `Widget` subclasses; handle UI events, delegate to services via `@work` workers; no business logic
- `app/services/` — all business logic; zero Textual imports; framework-agnostic; async-friendly
- `app/models/` — pure Python dataclasses or Pydantic models; zero Textual imports
- `app/utils/` — pure utility functions; no Textual, no service imports

**Import direction:** app → screens → widgets → services → models. Utils is a leaf. Services and models have no Textual imports. Never upward.

**Reactive rule:** Use `reactive` attributes for any state that should trigger a UI refresh. Cross-widget communication uses `Message` subclasses — never reach into another widget's internals directly.

**Worker rule:** Any service call from a widget or screen that does I/O (file, network, DB) must run inside `@work` or `run_worker()`. Never call blocking or async services directly in event handlers on the main thread.

**compose() rule:** `compose()` is for layout only. No business logic, no conditionals encoding rules, no I/O. `on_mount()` is for initialization only — not data loading.

**Service isolation rule:** `app/services/` and `app/models/` must never import from `textual`. If this import appears, it is a blocking violation.
