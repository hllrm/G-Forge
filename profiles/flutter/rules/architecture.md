## Flutter + Riverpod Architecture Rules

**Layer map:**
- `lib/features/<feature>/screens/` — full-screen widgets; thin; no business logic in `build()`
- `lib/features/<feature>/widgets/` — feature-scoped UI widgets; no direct provider state writes
- `lib/features/<feature>/providers/` — Riverpod providers or BLoC; owns all feature state and logic
- `lib/shared/widgets/` — app-wide reusable UI; pure; no provider or service imports
- `lib/shared/models/` — immutable Dart data classes; no Flutter/UI imports
- `lib/services/` — API clients, persistence, platform integrations; framework-agnostic
- `lib/core/` — theme, routing (GoRouter), app config, DI bootstrap

**Import direction:** features/screens → features/providers → services → shared/models. Shared widgets are pure leaves. Never upward, never cross-feature widget imports.

**Widget purity rule:** Widgets are pure UI. All state lives in providers. `build()` must not call sort/filter/map or contain async logic — move to provider or selector.

**`const` rule:** Every `StatelessWidget` and `ConsumerWidget` constructor must be `const`. Every widget instantiation in `build()` that can be `const` must be `const`.

**Provider rule:** Use code-generated Riverpod (`@riverpod`) for new providers. `ref.watch` in `build`, `ref.read` in callbacks only. All async providers handle loading and error states with `.when()`.

**Model rule:** Models are immutable (`final` fields, `copyWith`, `fromJson`). No Flutter imports in `lib/shared/models/`.
