## Frontend Data Flow Rules

**Supplementary profile.** Install alongside any component-framework stack profile (vue-pinia, react, nuxt, next-js, sveltekit, angular, remix, astro, sveltekit, and composites built on them). Does not replace stack-specific rules — adds the data-flow discipline that applies across all of them.

**When this profile applies:** projects with a store layer, a service/composable layer, multiple components sharing state, or any real-time connection. Skip for prototypes, demos, single-view tools, and apps with fewer than ~5 components.

---

### The Two Networks

A frontend application has two completely separate data networks:

- **Read network — strictly downward:** `API → Service/Store → Composable/Hook → Props → [ Component ]`
- **Write network — strictly upward:** `[ Component ] → emits → Composable/Store handler → API`

The **component is a terminal point.** It is the dead end of the read network and the origin of the write network. It renders props and emits events. It does not route, does not store, and does not coordinate across layers.

| Layer | Reads from | Writes to | Terminal? |
|---|---|---|---|
| Service / API layer | External API | Store / composable | No |
| Store / global composable | Service, other stores | Components (via reactivity) | No |
| Feature composable / hook | Store, services | Component (return values) | No |
| Component | Props | Event emitter (upward) | **Yes** |

---

### Violation Rules

**V1 — No HTTP calls in components** *(BLOCKING)*

Components must not call `fetch`, `axios`, or any HTTP client directly. HTTP belongs in the service/API layer. A component initiating a network request inherits every transport concern — caching, retry, response shaping, error handling — that the layers above it were designed to absorb. It also becomes untestable as a pure render unit.

**V2 — No shadow-state ref syncing props** *(BLOCKING)*

A component must not copy a prop into a local reactive variable and sync it back via a watcher:

```js
// Violation — two sources of truth
const local = ref(props.x)
watch(() => props.x, val => { local.value = val })
```

Two copies of the same value on the dead end of the network diverge under specific timing conditions — the bug surfaces months later, not immediately. Derive via `computed` and emit changes upward, or use the framework's sanctioned two-way binding primitive (Vue 3.4+: `defineModel()`; React: controlled component pattern).

**V3 — No watch/effect routing write commands** *(WARNING)*

A watcher or effect must not emit user-intent events or dispatch write commands in response to a value change. Reactivity propagates change notifications — it is not a dispatch layer. When a watcher fires a command, the intent ("user searched for X") is buried inside the propagation mechanic ("this ref changed"). Feedback loops emerge that debounce timers paper over rather than prevent.

Emit from the event handler that caused the change. Keep watch/effect for local-only propagation (e.g. syncing two internal refs, or triggering a fetch when a dependency changes — not firing an outward command).

**V4 — Caller steps back after emit** *(WARNING)*

After emitting an event, the component must not immediately update local state to reflect what it expects the handler will do. State changes that result from a write should arrive back via the read network, not be preemptively guessed by the emitter.

**Exception — the optimistic-update pattern** is the one sanctioned case: the component emits a write AND speculatively updates local read-state, provided (a) the optimistic state is explicitly reversible and (b) the read network reconciles afterward. Mark optimistic state clearly (`pending*`, `optimistic*`) and document the rollback path.

---

### What This Profile Does Not Govern

- **URL and routing state** — framework router is separate infrastructure
- **SSR / hydration** — server/client rendering boundary is outside this model
- **Web workers** — separate execution context; connect to the main city only at defined entry points
- **Error propagation** — retry logic, error boundaries, and fallback states follow stack-specific rules
- **Form accumulation** — complex multi-step forms accumulate state before firing a command; the accumulation phase is not covered here, only the final emit
