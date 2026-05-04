## Phoenix LiveView Architecture Rules

**Layer map:**
- `lib/<app>_web/controllers/` — HTTP controllers; call context functions; render or redirect; no Repo calls
- `lib/<app>_web/live/` — LiveView modules; handle events by calling contexts; assign state; no Repo calls
- `lib/<app>_web/components/` — pure function components; rendering only; no context or Repo calls
- `lib/<app>/` (contexts) — all business logic modules (`Accounts`, `Catalog`, `Orders`); own all Repo calls
- `lib/<app>/` (schemas) — Ecto schema modules; define changesets for shape validation; no business rules
- `lib/<app>/repo.ex` — `Ecto.Repo`; only called from context modules, never from web layer

**Import direction:** web layer (LiveViews, controllers) → contexts → Repo/schemas. Components are leaves. Contexts never import from `_web`. Schemas never import other schemas or contexts.

**Context rule:** The context module is the only boundary between the web layer and the database. Every LiveView and controller must call a context public function — never `Repo` directly. Contexts must not expose raw `Ecto.Query` values for callers to execute.

**Changeset rule:** Changesets are defined in schema modules and cover shape/format validation. Business rules (quotas, authorization, cross-entity invariants) live in context functions, not changesets.

**LiveView rule:** `handle_event/3` parses params and calls one context function. No business logic, no authorization checks, no direct DB access in LiveView callbacks.

**Cross-context rule:** Contexts do not call each other's internal schemas. If two contexts must share data, expose a public function in one context for the other to call.
