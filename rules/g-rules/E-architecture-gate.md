## E · Architecture Gate

Architecture rules: `.claude/rules/architecture-<stack>.md` — installed by `/g-specialize`
Architecture reviewer: `.claude/agents/<stack>-architect.md` — installed by `/g-specialize`

Run `/g-specialize` once after `/g-init` to detect the project stack and install the correct profile. Re-run if the stack or data layer changes significantly.

**Non-trivial** = any of: ≥3 files · layer-boundary path · new component/store/composable/route · public API change · refactor / migrate / restructure / new feature.

**Mandatory sequence:**
1. Plan Mode — no writes
2. Map each file to its layer (cite rules file by line)
3. Validate import directions — source layer → target layer must be permitted
4. Confirm state ownership — mutations in declared owner only
5. Confirm side-effect ownership — HTTP/IPC calls in service/composable layer only
6. Invoke architecture-review subagent → wait for PASS/FAIL report
7. Present: plan + review + files grouped by layer
8. Wait for explicit human approval before exiting Plan Mode

**Hard stops — refuse and ask for guidance if:**
- Any import flows up or sideways across layer boundaries
- Business logic in UI atoms, molecules, or pages
- Direct API/IPC calls outside the service/composable layer
- Circular dependency would be created
- State ownership duplicated across two modules
