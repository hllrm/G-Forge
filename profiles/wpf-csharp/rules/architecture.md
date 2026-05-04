## WPF + C# MVVM Architecture Rules

**Layer map:**
- `Views/` — XAML files and code-behind; code-behind contains `InitializeComponent()` only; all data via binding
- `ViewModels/` — `INotifyPropertyChanged`; properties, `ICommand` implementations, UI state; calls services via interfaces; no WPF type references
- `Models/` — plain C# domain objects; no WPF dependencies
- `Services/` — business logic behind `IXxxService` interfaces; no WPF dependencies
- `Repositories/` — data access behind `IXxxRepository` interfaces; no WPF dependencies

**Import direction:** Views bind to ViewModels (DataContext). ViewModels → Services (interface) → Repositories (interface) → Models. No layer imports Views. No WPF types in ViewModels, Services, or Repositories.

**Code-behind rule:** The only permitted code in a View's code-behind is `InitializeComponent()`. Any click handler, event handler, or logic is a violation — bind to `ICommand` in the ViewModel instead.

**Command rule:** Every user action is exposed as an `ICommand` property on the ViewModel. Use `RelayCommand`/`DelegateCommand`. `CanExecute` logic lives in the command guard, not duplicated in properties.

**INotifyPropertyChanged rule:** Use `[CallerMemberName]` or a `SetProperty` helper — never magic strings. Raise `PropertyChanged` only when the value actually changes.

**WPF isolation rule:** ViewModels must not reference `MessageBox`, `Window`, `Dispatcher`, or any `System.Windows` type. Use `IDialogService` and `INavigationService` interfaces for WPF-specific operations.

**DI rule:** Services injected into ViewModels via constructor. No `new XxxService()` in ViewModels.
