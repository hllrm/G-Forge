## C++17/20 + CMake Architecture Rules

**Layer map:**
- `include/<project>/` — public API headers; declarations only; no private details or implementation headers
- `src/` — implementation `.cpp` files; include their own public header plus private headers
- `tests/` — Catch2/GTest files mirroring `src/` structure; include only public headers
- `cmake/` — helper `.cmake` modules (toolchain, find modules, version)
- `extern/` — vendored third-party source trees; never modified; never leaked into public headers

**Import direction:** `src/` includes `include/<project>/` and private `src/` headers. Public headers include system headers and forward-declare project types. `extern/` headers never appear in public headers.

**Header rule:** Headers declare; sources define. No function definitions in `.h` (except templates/inline). No `using namespace std` in headers. Forward-declare rather than include where possible.

**PIMPL rule:** Public classes with private members that may change use PIMPL (`struct Impl; std::unique_ptr<Impl> _impl`). Destructor defined in `.cpp` where `Impl` is complete.

**Ownership rule:** No raw owning pointers — use `std::make_unique` for sole ownership, `std::shared_ptr` only for documented shared ownership. No bare `new`/`delete` in application code.

**CMake rule:** Use `target_*` commands, never global `include_directories`/`link_libraries`. Always specify `PRIVATE`/`PUBLIC`/`INTERFACE`. Warning flags (`-Wall -Wextra -Werror`) are `PRIVATE` so they do not propagate. List sources explicitly — no `file(GLOB)`.

**Warning rule:** `-Wall -Wextra -Werror` required in CI for all targets. No suppression pragmas without a documented reason.

**Object pooling rule:** For hot-path allocations (entities, particles, messages, events), implement a `Pool<T>` backed by a pre-allocated `std::array` or `std::vector` with a free-list (`std::stack<T*>`). `Pool<T>::acquire()` pops from the free list; `Pool<T>::release(T*)` pushes back. No `new`/`delete` on the hot path. Pool capacity is fixed at construction from a config constant — never grows at runtime. Placement-new for in-place construction if T has non-trivial init.

**State machine rule:** Implement as a `StateMachine<TState>` class with a map of state objects implementing a common `IState` interface (`enter()`, `exit()`, `update(float dt)`). Alternatively use a variant-based FSM (`std::variant<States...>` + `std::visit`) for states with no shared virtual base. Avoid raw `enum` + `switch` in the game loop. For AI, a hierarchical FSM (HFSM2 or equivalent) is preferred over flat FSMs with guard conditions.
