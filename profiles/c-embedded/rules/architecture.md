## C Embedded Architecture Rules

**Layer map:**
- `src/hal/` — hardware abstraction; register-level MCU operations; MCU-specific; no protocol logic
- `src/drivers/` — peripheral drivers (UART, SPI, I2C, ADC) built on HAL; no direct RTOS calls
- `src/middleware/` — RTOS wrappers, protocol stacks, ring buffers; calls drivers; no HAL calls
- `src/app/` — application logic, state machines, control loops; calls drivers and middleware only; never HAL
- `include/` — public declarations; no cross-layer includes inside headers

**Import direction:** app → drivers/middleware. middleware → drivers. drivers → hal. hal → vendor MCU headers. App never includes HAL. Never upward.

**ISR rule:** ISRs set a flag (`volatile bool`) or post to a RTOS queue using the `FromISR` variant, then return. No function calls with non-trivial depth, no blocking, no `printf`, no `malloc`.

**Allocation rule:** No `malloc`/`calloc`/`realloc`/`free` after system initialisation. All buffers statically allocated at startup with `static` storage. No VLAs in real-time paths.

**Volatile rule:** All hardware registers accessed via `volatile`-qualified pointer types. All variables shared between ISR and non-ISR context declared `volatile`. Memory barriers after MMIO sequences requiring ordering.

**Global state rule:** Module-level state uses `static` to restrict visibility to the translation unit. No `extern` on internal state — expose via API functions. Each module's global state documented with an ownership comment.

**Driver rule:** Drivers call HAL, not vendor MCU headers directly. RTOS APIs wrapped in middleware — drivers are RTOS-agnostic. No application state machine logic in drivers or HAL.
