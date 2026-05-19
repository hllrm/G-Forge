# Flask Architecture Rules

These rules apply to any project using Flask. They live alongside the universal rules in `G-RULES.md`.

## Layer Map

| Layer | Directory | Responsibility |
|-------|-----------|----------------|
| Blueprints / Views | `app/blueprints/` | HTTP boundary: parse, validate, call service, serialize, return |
| Services | `app/services/` | Business logic — framework-agnostic |
| Repositories | `app/repositories/` | Database access |
| Schemas | `app/schemas/` | Marshmallow or Pydantic request/response shapes |
| Models | `app/models/` | SQLAlchemy ORM |
| Extensions | `app/extensions.py` | Singletons initialised without app |
| Factory | `app/__init__.py` | `create_app(config_name)` |
| Config | `app/config.py` | Per-environment config classes |

## Hard Rules

1. **App factory is mandatory.** Never instantiate `Flask(__name__)` at module level — always inside a `create_app()` function.
2. **Blueprints only.** Register routes on `Blueprint` objects, never on the `Flask` app directly.
3. **Service layer is framework-agnostic.** No `flask.request`, `flask.g`, `flask.session`, or `flask.current_app` imports below the blueprint boundary.
4. **Repositories own SQLAlchemy.** Services do not call `Model.query` or `db.session.execute()` directly.
5. **Separate request and response schemas.** No double-duty schemas with optional fields to serve both directions.
6. **Config classes, not module globals.** Configuration lives in `Config` subclasses by environment, selected at factory time.

## Common Violations

- Routes registered on `app.route` instead of `blueprint.route`
- Business logic inline in route handler (>10 lines beyond parse/call/serialize)
- Service or repository reading `request.json` directly
- Sensitive fields exposed in response schemas (`password`, tokens)
- `g.user` accessed inside service — pass it in instead
- Tests of services that require a request context — indicates request-coupling

## Async Note

If the project uses `flask[async]` (route handlers as `async def`), the service layer may also be async; document this clearly in the project brief. Plain Flask runs synchronously and that's the expected mode.
