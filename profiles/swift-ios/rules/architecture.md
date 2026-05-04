## iOS SwiftUI + MVVM Architecture Rules

**Layer map:**
- `Features/<Feature>/*View.swift` — SwiftUI view structs; call ViewModel methods only; no service access; no business logic
- `Features/<Feature>/*ViewModel.swift` — `@MainActor ObservableObject`; owns published state; calls services; drives the view
- `Shared/Components/` — reusable SwiftUI views; accept data via init; no ViewModel or service imports
- `Services/` — network, persistence, auth; protocol-based; returns domain models only; no UI types
- `Models/` — `Codable` structs; pure domain types; no UI imports
- `Extensions/` — Swift/Foundation/SwiftUI extensions; pure utility; no service or ViewModel imports

**Import direction:** Views → ViewModels → Services → Models. Shared components and extensions are pure leaves. Never upward.

**ViewModel rule:** All ViewModels are `@MainActor final class` conforming to `ObservableObject`. No `DispatchQueue.main` — the `@MainActor` annotation handles thread safety. No SwiftUI imports in ViewModel files.

**Async rule:** All new code uses `async/await`. Completion handlers are banned in new code. Use `.task` in views for async loads (auto-cancels); avoid `.onAppear` for async work.

**Safety rule:** No force unwraps (`!`). No `as!` force casts. Use `guard let`, `if let`, or `?? default`. `fatalError` only in provably unreachable branches.

**Service rule:** Services are protocol-backed for testability. Services return `Model` types — never `UIImage`, `View`, or any framework UI type.
