## C · Agent Discipline

**HQ = command centre only.** Decomposes, directs, integrates, commits. Never does grunt work an agent could do.

**Wave model** — Classify every step: Independent / Dependent / Sequential-by-file. All independent steps launch in one message. Never split a wave across messages.

**When to spawn vs. inline**

| Situation | Action |
|-----------|--------|
| Non-trivial feature or multi-step task | `/g-plan` first |
| All agent work ready to merge | `/g-review` gate before commit |
| Open-ended search, unknown locations, >3 files | Spawn **Explore** agent |
| Self-contained implementation, inputs fully known | Spawn the matching **`<stack>-implementer`** (if `/g-specialize` installed one for the task's stack), else **`feature-implementer`** — never a bare general-purpose agent |
| Long task that would bloat main context | Spawn agent |
| Exact file:line known, <3 targeted edits | Inline |
| Needs mid-task judgment or back-and-forth | Inline — keep in HQ |
| Build / audit >2 min with clear done condition | Background agent |
| Same bug class, 3rd attempt | Stop inline. Explore agent + escalate model + different mechanism. |

**Agent prompt must include:** exact `file:line` refs for known things · scope boundary (what NOT to touch) · one specific verifiable done condition · enough WHY for judgment calls.

**Results flow:** summary + `file:line` refs back to HQ — never raw file dumps.

**Caps:** Hard limit 7 agents/task. 4 agents in one wave = warning sign, restructure first.

**Background by default** for anything >~2 min that doesn't block HQ's next move.

### Single-use agents — one approach, one attempt

**An agent is single-use. It gets one approach and one attempt. It is never continued, re-prompted, or reused for a retry.** If its approach works, it returns `DONE`. If the approach doesn't work, it does **not** thrash — it returns `FAILED` with a learnings report and is discarded. HQ owns every retry.

**Why — context poisoning.** A context window conditions the next token on its *entire* contents, not just the parts that were "accepted." When an agent explores options, hits dead-ends, makes a wrong first guess, and then keeps going in the same context, that crossed-out reasoning stays on the page it is reading from. The agent then anchors on options it already rejected, hedges because conflicting half-conclusions are still in-window, and clings to a wrong first guess even after correcting it. The residue of deliberation poisons execution — and the higher-stakes the task, the more exploration it needed, so the most consequential work gets the most poison. **Single-use agents make this structurally impossible: the failed exploration dies with the agent. Nothing crosses back to HQ except the distilled learnings.**

**The failure loop (`FAILED` → learnings → fresh redeploy):**

1. A failing agent returns `RESULT: FAILED` with a `LEARNINGS:` block — the approach it tried, where and why it broke, what is now ruled out, and a recommended *different* approach. This is a clean contract, not a transcript.
2. HQ reads the learnings (and may dispatch `error-detective` / `debugger` on them for a different mechanism). It does **not** re-prompt the dead agent.
3. HQ deploys a **fresh** single-use agent for the same task, seeded **only** by the revised approach + distilled learnings — never the failed agent's context or output file. Hand the fresh agent a clean starting point: revert the failed attempt's partial changes, or describe the working-tree state explicitly, so it conditions on ground truth, not residue.
4. **Bound = Three-Strikes (§A8).** Each strike is a fresh agent with a *different* mechanism. Escalate the model tier before attempt 3. After three failed approaches, **stop and escalate to the human** with the full learnings trail — do not deploy a fourth.

`FAILED` (the approach didn't work — HQ analyzes and redeploys) is distinct from `BLOCKED` (an external dependency makes the task impossible to proceed — surface to the human immediately; redeploying a fresh agent won't help).

This is the same airtight-contract discipline G-Forge already uses for *first* attempts — `spec-writer` produces a spec precise enough for a cheap executor to run without judgment calls — extended to *retries*. The learnings report is the fixed-contract value crossing the seam; thinking out loud inside a reused agent is mutating the shared object (the executor's window) in place. Keep the seam clean.

**HQ poisons too — offload high-stakes deliberation.** The doctrine applies to HQ's own window, not just dispatched agents. High-branching deliberation — weighing architecture options, debating a pattern, drafting an ADR — is exactly the reasoning that poisons a context, and HQ runs it directly. So for a consequential decision, **offload the weighing to a throwaway subagent and promote only the finished answer** (this is what `/g-adr` does: a single-use deliberation subagent stress-tests and drafts; HQ never sees the comparison). And when the decision is finalized, **reset the residue using the path the context gate already provides** — finalizing a consequential ADR is a *semantic* trigger for the same reset §A7 runs on the *quantitative* (exchange-count) trigger: auto-`/g-retro`, write the handoff, recommend a fresh session whose *first task verifies the decision against ground truth*. An airtight answer must be checked, not trusted from memory — its deliberation context may have gone confidently stale. The verification is the seam check; the fresh session is the clean executor.
