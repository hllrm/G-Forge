# Pygame Architecture Rules

Rules for any project built on Pygame. Live alongside the universal rules in `G-RULES.md`.

## Layer Map

| Layer | Directory | Responsibility |
|-------|-----------|----------------|
| Main | `main.py` | Game loop scaffold only |
| Scenes | `game/scenes/` | Scene = update + draw + handle_event + own entity list |
| Entities | `game/entities/` | Sprite classes; `update(dt)` + `draw(surface)` |
| Systems | `game/systems/` | Cross-cutting: physics, collision, audio, input |
| Assets | `game/assets/` | Cached loader; loads at scene transitions |
| Config | `game/config.py` | Constants only; no `pygame.init()` |
| Save | `game/save.py` | Serialization; never per-frame |

## Hard Rules

1. **Single game-loop site.** `pygame.event.get()` is called in exactly one place: the main loop.
2. **`dt`, not frame count.** All time-based motion uses `dt = clock.tick(FPS) / 1000.0`. Frame-count motion is forbidden.
3. **Assets cached at scene init.** Never load images, sounds, or fonts inside `update()` or `draw()`.
4. **State machines for discrete modes.** Per G-RULES §F, ≥3 mutually exclusive modes require an explicit state machine, not nested booleans.
5. **Convert surfaces.** `pygame.image.load(...)` must be followed by `.convert()` or `.convert_alpha()` for blitting performance.
6. **Config-driven.** Screen size, FPS, keybinds, colors live in `config.py` — never inline magic numbers in entity or scene code.

## Common Violations

- Game logic in `main.py` beyond loop scaffold
- `pygame.image.load()` inside `update()` or `draw()`
- Frame-count motion (`x += 2`) instead of `x += speed * dt`
- Missing `clock.tick(FPS)`
- Multiple `pygame.event.get()` calls per frame
- File I/O or save serialization on every frame
- Entities directly importing siblings (couple through a system or scene)

## Object Pooling (carries from G-RULES §F)

Game-dev profiles install object-pooling expectations: bullets, particles, projectiles, and frequently-spawned entities use a pool keyed by type. Allocations on the hot path (per-frame `new`/object creation in tight loops) are flagged.

## Frame-time Budget

Target 16.6ms at 60 FPS. The pygame-architect agent runs profile-level checks on the per-frame path and flags collision routines without spatial partitioning above ~100 entities and any I/O on the hot path.
