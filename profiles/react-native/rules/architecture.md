## React Native + Expo + Zustand Architecture Rules

**Layer map:**
- `screens/` — route-level components; thin orchestration only; no business logic
- `components/` — reusable UI; props in, callbacks out; no store or service imports
- `hooks/` — shared logic, data fetching, native module wrappers; accesses stores and services
- `stores/` — Zustand slices; global client state only; delegates HTTP to services
- `services/` — API calls and data transformation; no store or screen imports
- `navigation/` — React Navigation stacks/tabs; route definitions only
- `types/` — shared TypeScript interfaces and enums; no runtime logic

**Import direction:** screens → hooks → stores → services. Components only import types. Never upward, never sideways across features.

**Store rule:** One Zustand slice per file, typed with an interface. Stores call services, never HTTP clients directly. No store file > 150 lines.

**Styling rule:** `StyleSheet.create()` required for all styles — no inline style objects. Platform-specific code in `.ios.ts` / `.android.ts` files or `Platform.select()`. Colors and spacing from a shared constants/theme file.

**Native module rule:** All Expo native module access (camera, location, sensors, haptics, etc.) must be wrapped in a dedicated hook in `hooks/`. Never call native APIs directly from screens or components.

**Screen rule:** Screens are thin — compose components, call hooks, wire navigation. Extract any data logic to a hook immediately.
