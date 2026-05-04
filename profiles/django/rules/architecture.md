## Django + DRF Architecture Rules

**Layer map:**
- `apps/<feature>/views.py` — ViewSets/APIViews; parse request, call service, return serialized response; no business logic
- `apps/<feature>/serializers.py` — validate input and serialize output only; no DB writes, no side effects
- `apps/<feature>/services.py` — all business logic; ORM access, transactions, external calls; no HTTP awareness
- `apps/<feature>/models.py` — ORM field definitions, relationships, `@property` computed fields only; no business logic methods
- `apps/<feature>/urls.py` — URL routing only
- `config/settings/` — all Django settings and env var access; split by environment
- `utils/` or `apps/common/` — pure utility functions; no ORM, no HTTP imports

**Import direction:** views → services → models. Serializers → models (field refs only). Utils and models are leaves. Never upward.

**Service rule:** Wrap multi-model writes in `transaction.atomic()`. Services raise domain exceptions — never DRF `ValidationError` or `Http404`.

**Serializer rule:** `create()` and `update()` in serializers must delegate immediately to a service — no business logic inline. Never use `fields = "__all__"` on response serializers. Separate request and response serializer classes.

**Model rule:** Model methods are limited to `@property` computed fields. No cross-model writes, no side effects, no conditional business rules in model methods or `save()` overrides.

**Config rule:** All `os.environ` and `settings.*` access lives in `config/settings/` only. Services and models never read env vars directly.
