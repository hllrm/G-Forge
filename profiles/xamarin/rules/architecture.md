# Xamarin.Forms Architecture Rules

Rules for projects on Xamarin.Forms. Live alongside the universal rules in `G-RULES.md`.

**End-of-support notice:** Xamarin.Forms reached end-of-support in May 2024. This profile applies to maintained legacy projects only. For new mobile work, use the `maui` profile.

## Layer Map

| Layer | Directory | Responsibility |
|-------|-----------|----------------|
| Views | `Views/` | XAML + code-behind, code-behind for UI plumbing only |
| View-Models | `ViewModels/` | UI state, commands, INotifyPropertyChanged |
| Services | `Services/` (+ `Abstractions/`) | Business logic, data access, behind interfaces |
| Models | `Models/` | Domain POCOs |
| Platform | `*.iOS/`, `*.Android/`, `*.UWP/` | Per-platform implementations of service abstractions |

## Hard Rules

1. **MVVM is mandatory.** View-models drive views via bindings; views never call services directly.
2. **View-models are framework-agnostic.** No `Xamarin.Forms.*` UI types in view-model code; no platform-specific assembly references — wrap in service abstractions.
3. **Code-behind for plumbing only.** Anything beyond binding wiring and event-to-command forwarding belongs in the view-model.
4. **Async/await discipline.** No `async void` outside event handlers; no `.Wait()` or `.Result` on the UI thread; `ConfigureAwait(false)` on service-layer awaits.
5. **Platform services behind interfaces.** Cross-platform features (file system, sensors, secure storage) accessed through `IDependencyService` abstractions; concrete implementations in platform projects.
6. **`OnPropertyChanged` via `nameof()` or `[CallerMemberName]`.** Hardcoded property-name strings break refactors and miss compile-time errors.

## Common Violations

- Business logic in code-behind
- Direct `Xamarin.Essentials` calls in view-models
- `async void` service calls
- Platform `#if` directives in shared code
- View-models holding `Page` references
- Missing `OnPropertyChanged` on bindable properties
- `Application.Current.MainPage = …` outside `App.xaml.cs` or a navigation service

## Migration Note

New features should be designed with MAUI migration in mind. MAUI shares the MVVM contract but replaces `DependencyService` with .NET DI, custom renderers with handlers, and several XAML control names. Avoid deep custom renderer chains in new code — they will need rewriting under MAUI handlers.
