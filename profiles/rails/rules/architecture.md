## Rails Architecture Rules

**Layer map:**
- `app/controllers/` — params + auth + delegate to service + render; no business logic; strong params always
- `app/services/` — POROs with `#call`; all business logic; `ActiveRecord::Base.transaction` for multi-model writes; no HTTP references
- `app/models/` — ActiveRecord: associations, validations, scopes, simple computed properties only; no business logic
- `app/queries/` — extracted ActiveRecord query objects for chains longer than 3 clauses; return a relation
- `app/serializers/` — JSON output shaping only; no business logic
- `app/policies/` — authorization predicates only
- `app/jobs/` — minimal logic; delegate to service objects immediately
- `lib/` — pure utility modules; no ActiveRecord, no Rails HTTP

**Import direction:** controllers → services → models. Queries → models. Jobs → services. Serializers and policies are leaves. Never upward.

**Service rule:** One public method (`#call`). Return a result object or raise a domain error — never `render`, `redirect_to`, or `ActionController` exceptions. Wrap multi-model writes in `transaction`.

**Model rule:** No cross-model writes, no mail sends, no job enqueues in model methods or callbacks. `after_create`/`after_save` triggering side effects is a violation — move to service layer.

**Query rule:** Any AR chain longer than 3 clauses inline in a controller or service must be extracted to a query object in `app/queries/`.

**Fat model rule:** If a model method contains branching business logic, calls `.save`/`.update` on another model, or triggers external services — it is a violation. Extract to a service object.
