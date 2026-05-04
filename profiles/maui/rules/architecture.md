## .NET MAUI + C# MVVM Architecture Rules

**Layer map:**
- `Views/` — XAML pages; code-behind contains `InitializeComponent()` only; data via binding to ViewModel
- `ViewModels/` — `ObservableObject` from CommunityToolkit.Mvvm; `[ObservableProperty]` and `[RelayCommand]` preferred over manual INPC; no MAUI UI type references
- `Models/` — pure C# domain objects; no MAUI or platform dependencies
- `Services/` — business logic behind `IXxxService` interfaces; platform concerns abstracted
- `Repositories/` — data access (SQLite, REST) behind `IXxxRepository` interfaces
- `Platforms/` — platform-specific API implementations only; register as `IXxxService` in DI

**Import direction:** Views bind to ViewModels. ViewModels → Services (interface) → Repositories (interface) → Models. Platforms/ implements shared interfaces. No MAUI types (`Shell`, `Application.Current`, `Page`) in ViewModels or Services.

**CommunityToolkit rule:** Use `[ObservableProperty]` on private backing fields and `[RelayCommand]` on Task/void methods. Class must be `partial`. No manual `INotifyPropertyChanged` when toolkit is available.

**Navigation rule:** ViewModels must not reference `Shell.Current` or `Application.Current.MainPage`. Use `INavigationService` interface. Shell route registration belongs in `AppShell.xaml` and `MauiProgram.cs`.

**Platform rule:** `#if ANDROID`/`#if IOS` compiler directives are banned in shared ViewModels and Services. Platform-specific code belongs in `Platforms/<Platform>/` and injected via a shared interface.

**Thread rule:** `MainThread.BeginInvokeOnMainThread` may appear in ViewModels to update `ObservableCollection` from background work. It must not appear in Services or Repositories.
