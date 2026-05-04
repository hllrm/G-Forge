## Python Data Pipeline Architecture Rules

**Layer map:**
- `pipelines/` — orchestration only; calls loaders → transforms → writers in sequence; no inline DataFrame operations
- `transforms/` — pure transformation functions; accept DataFrame, return new DataFrame; no I/O, no side effects
- `loaders/` — data ingestion; return raw DataFrame; no transformation logic
- `writers/` — write ready-to-write DataFrame to destination; return `None`; no transformation logic
- `models/` — SQLAlchemy ORM models and Pydantic schemas for row-level validation
- `utils/` — pure utility functions; no DataFrame operations

**Import direction:** pipelines → loaders, transforms, writers, models, utils. Transforms/loaders/writers → models, utils. Models and utils are leaves. Never upward.

**Pure function rule:** Every function in `transforms/` must be a pure function: same input → same output, no side effects, no I/O. Violations are blocking.

**No mutation rule:** In-place DataFrame modification (`df["col"] = ...`, any `inplace=True`) is a blocking violation. Always return a new DataFrame.

**Type hint rule:** Every public function in any layer must have fully annotated parameter and return types. Missing annotations are a warning.

**Polars rule:** Prefer Polars over Pandas for new code, especially for DataFrames > 100k rows. Flag `df.iterrows()`, chained `[]` indexing, and `apply()` with Python lambdas as anti-patterns.

**Layer purity rule:** Loaders return raw data — no filters or transforms. Writers receive ready data — no transforms before writing. Pipelines orchestrate — no inline DataFrame operations.
