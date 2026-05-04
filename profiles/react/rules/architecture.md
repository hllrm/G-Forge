## React 18 + React Query + Zustand Architecture Rules

**Layer map:**
- `src/pages/` — route-level pages; thin orchestration; no inline business logic
- `src/components/` — reusable UI; props in, events out; no direct store or service imports
- `src/hooks/` — custom hooks; bridge between components and stores/services; home for all `useQuery`/`useMutation` calls
- `src/stores/` — Zustand slices for global client state only; no API calls; no server state
- `src/services/` — async API functions; pure; no store or component imports
- `src/types/` — shared TypeScript interfaces; no runtime logic

**Import direction:** pages → components → hooks → stores/services. Never upward, never sideways.

**State rule:** Server state lives in React Query cache. Global client state lives in Zustand. Component-local state uses `useState`. Never store API response data in Zustand.

**Hook rule:** All `useQuery` and `useMutation` calls must live in `src/hooks/`. Components call hooks, not services or stores directly.

**Component rule:** Function components only — no class components. No `useEffect` for derived state; use `useMemo`. No direct store imports in components.

**Store rule:** Zustand stores are typed slices. Actions use `set()`. No HTTP calls inside stores.
