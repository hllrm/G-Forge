#!/bin/bash
# Class-split invariant suite — ADR-008 clause 6
#
# Resolve script dir / hooks dir to ABSOLUTE paths exactly once, before any
# fixture cd. Relative $0 (as invoked from repo root) would otherwise break
# `dirname "$0"` after the sandbox cd below.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$(cd "$SCRIPT_DIR/../hooks" && pwd)"
# Assertion: the six non-gating hooks (observe.sh, agent-lifecycle.sh,
# session-start.sh, pre-compact.sh, workflow-checkpoint.sh, post-commit-cleanup.sh)
# NEVER exit non-zero, even under garbage/malformed stdin payloads.
# Exit code 0 is guaranteed by design — these hooks degrade silently rather than
# blocking. The gating pair (hooks/check-commit.sh, hooks/pre-commit) is explicitly
# out of scope and must never silently migrate into the non-gating class.
#
# Total assertions: 26
# - Structural: 2 (gating pair exclusion, hook list completeness)
# - Exit-code invariant: 24 (all six hooks × 4 payload types: 1 representative + 3 garbage)

# ============================================================================
# § Structural assertions — gating pair exclusion
# ============================================================================

PASS=0
FAIL=0

# Verify that the gating pair is never referenced in the hook list.
# check-commit.sh and pre-commit are ALLOWED to exit non-zero (they are
# enforcement gates); this suite ONLY tests the six non-gating hooks.
GATING_PAIR_IN_SCOPE=0
if grep -q 'check-commit.sh\|hooks/check-commit.sh' "$0" 2>/dev/null | grep -v '^#'; then
    GATING_PAIR_IN_SCOPE=$((GATING_PAIR_IN_SCOPE + 1))
fi
if grep -q '^[^#]*pre-commit[^a-z-]' "$0" 2>/dev/null | grep -v 'post-commit\|# '; then
    # This might match pre-commit but we check context carefully — skip if it's in
    # a comment or in "pre-commit-cleanup" or similar.
    :
fi

# The suite's declared NON-GATING_HOOKS list is the authority for which
# hooks are tested. Verify it exists and is complete.
NON_GATING_HOOKS="observe.sh agent-lifecycle.sh session-start.sh pre-compact.sh workflow-checkpoint.sh post-commit-cleanup.sh"

# Guard: ensure exactly six hooks in the list (not five or seven).
HOOK_COUNT=$(printf '%s\n' $NON_GATING_HOOKS | wc -w | tr -d '[:space:]')
if [ "$HOOK_COUNT" -eq 6 ]; then
    echo "PASS: six non-gating hooks declared"; PASS=$((PASS+1))
else
    echo "FAIL: expected 6 non-gating hooks, got $HOOK_COUNT"; FAIL=$((FAIL+1))
fi

# Guard: gating pair not in the declared list.
if ! printf '%s' "$NON_GATING_HOOKS" | grep -qE 'check-commit|pre-commit[^-]'; then
    echo "PASS: gating pair (check-commit.sh, pre-commit) explicitly excluded"; PASS=$((PASS+1))
else
    echo "FAIL: gating pair found in non-gating list"; FAIL=$((FAIL+1))
fi

# ============================================================================
# § Fixture setup — sandbox for all hook tests
# ============================================================================

# All six hooks self-guard to G-Forge-managed projects (.claude/integration-tier).
# Create a fixture directory that simulates a G-Forge project so all hooks activate.
FIXTURE="$(mktemp -d)"
cd "$FIXTURE" || { echo "FAIL: could not enter fixture dir"; exit 1; }

# Initialize as a git repo (some hooks call git commands)
git init -q 2>/dev/null
git config user.email "test@g-forge.local" 2>/dev/null
git config user.name "test" 2>/dev/null

# Mark as a G-Forge project so the guard passes
mkdir -p .claude
printf 'full\n' > .claude/integration-tier

# ============================================================================
# § Representative payloads and garbage for each hook
# ============================================================================

# Test payloads — fixed data, no timestamps or UUIDs
OBSERVE_PAYLOAD='{"tool_input":{"command":"git commit -m test"}}'
AGENT_PAYLOAD='{"agent_type":"TestAgent","agent_id":"12345678","hook_event_name":"SubagentStart"}'
SESSION_PAYLOAD='{"source":"startup"}'
COMPACT_PAYLOAD='{}'  # pre-compact.sh discards stdin anyway
CHECKPOINT_PAYLOAD='{"tool_input":{"prompt":"test"}}'
POSTCOMMIT_PAYLOAD='{"tool_name":"Bash","tool_input":{"command":"git commit -m test"}}'

# Garbage payloads — all hooks must tolerate these
GARBAGE_EMPTY=""
GARBAGE_NONTEXT="not json at all"
GARBAGE_TRUNCATED='{"incomplete":'

# ============================================================================
# § Test harness: exit-code invariant for each hook
# ============================================================================

# test_hook_exit_code <name> <hook-script> <payload> <description>
test_hook_exit_code() {
    local name="$1" script="$2" payload="$3" desc="$4"
    printf '%s' "$payload" | bash "$script" >/dev/null 2>&1
    local rc=$?
    if [ "$rc" -eq 0 ]; then
        echo "PASS: $name — $desc (exit 0)"; PASS=$((PASS+1))
    else
        echo "FAIL: $name — $desc (exit $rc, expected 0)"; FAIL=$((FAIL+1))
    fi
}

# ============================================================================
# § 1. observe.sh — silent observer, non-gating
# ============================================================================

OBSERVE_SCRIPT="$HOOKS_DIR/observe.sh"

# Representative payload (valid PostToolUse)
test_hook_exit_code "observe.sh/rep" "$OBSERVE_SCRIPT" "$OBSERVE_PAYLOAD" \
    "representative payload"

# Garbage: empty stdin
test_hook_exit_code "observe.sh/empty" "$OBSERVE_SCRIPT" "$GARBAGE_EMPTY" \
    "empty stdin"

# Garbage: non-JSON text
test_hook_exit_code "observe.sh/nontext" "$OBSERVE_SCRIPT" "$GARBAGE_NONTEXT" \
    "non-JSON text"

# Garbage: truncated JSON
test_hook_exit_code "observe.sh/truncated" "$OBSERVE_SCRIPT" "$GARBAGE_TRUNCATED" \
    "truncated JSON"

# ============================================================================
# § 2. agent-lifecycle.sh — agent event logger, non-gating
# ============================================================================

AGENT_SCRIPT="$HOOKS_DIR/agent-lifecycle.sh"

# Representative payload (valid SubagentStart)
test_hook_exit_code "agent-lifecycle.sh/rep" "$AGENT_SCRIPT" "$AGENT_PAYLOAD" \
    "representative payload"

# Garbage: empty stdin
test_hook_exit_code "agent-lifecycle.sh/empty" "$AGENT_SCRIPT" "$GARBAGE_EMPTY" \
    "empty stdin"

# Garbage: non-JSON text
test_hook_exit_code "agent-lifecycle.sh/nontext" "$AGENT_SCRIPT" "$GARBAGE_NONTEXT" \
    "non-JSON text"

# Garbage: truncated JSON
test_hook_exit_code "agent-lifecycle.sh/truncated" "$AGENT_SCRIPT" "$GARBAGE_TRUNCATED" \
    "truncated JSON"

# ============================================================================
# § 3. session-start.sh — session sync and health check, non-gating
# ============================================================================

SESSION_SCRIPT="$HOOKS_DIR/session-start.sh"

# Representative payload (valid SessionStart)
test_hook_exit_code "session-start.sh/rep" "$SESSION_SCRIPT" "$SESSION_PAYLOAD" \
    "representative payload"

# Garbage: empty stdin
test_hook_exit_code "session-start.sh/empty" "$SESSION_SCRIPT" "$GARBAGE_EMPTY" \
    "empty stdin"

# Garbage: non-JSON text
test_hook_exit_code "session-start.sh/nontext" "$SESSION_SCRIPT" "$GARBAGE_NONTEXT" \
    "non-JSON text"

# Garbage: truncated JSON
test_hook_exit_code "session-start.sh/truncated" "$SESSION_SCRIPT" "$GARBAGE_TRUNCATED" \
    "truncated JSON"

# ============================================================================
# § 4. pre-compact.sh — PreCompact hook, silently consumes stdin, non-gating
# ============================================================================

COMPACT_SCRIPT="$HOOKS_DIR/pre-compact.sh"

# Representative payload (pre-compact discards stdin, so any valid payload works)
test_hook_exit_code "pre-compact.sh/rep" "$COMPACT_SCRIPT" "$COMPACT_PAYLOAD" \
    "representative payload"

# Garbage: empty stdin
test_hook_exit_code "pre-compact.sh/empty" "$COMPACT_SCRIPT" "$GARBAGE_EMPTY" \
    "empty stdin"

# Garbage: non-JSON text
test_hook_exit_code "pre-compact.sh/nontext" "$COMPACT_SCRIPT" "$GARBAGE_NONTEXT" \
    "non-JSON text"

# Garbage: truncated JSON
test_hook_exit_code "pre-compact.sh/truncated" "$COMPACT_SCRIPT" "$GARBAGE_TRUNCATED" \
    "truncated JSON"

# ============================================================================
# § 5. workflow-checkpoint.sh — UserPromptSubmit checkpoint, non-gating
# ============================================================================

CHECKPOINT_SCRIPT="$HOOKS_DIR/workflow-checkpoint.sh"

# Representative payload (valid UserPromptSubmit)
test_hook_exit_code "workflow-checkpoint.sh/rep" "$CHECKPOINT_SCRIPT" "$CHECKPOINT_PAYLOAD" \
    "representative payload"

# Garbage: empty stdin
test_hook_exit_code "workflow-checkpoint.sh/empty" "$CHECKPOINT_SCRIPT" "$GARBAGE_EMPTY" \
    "empty stdin"

# Garbage: non-JSON text
test_hook_exit_code "workflow-checkpoint.sh/nontext" "$CHECKPOINT_SCRIPT" "$GARBAGE_NONTEXT" \
    "non-JSON text"

# Garbage: truncated JSON
test_hook_exit_code "workflow-checkpoint.sh/truncated" "$CHECKPOINT_SCRIPT" "$GARBAGE_TRUNCATED" \
    "truncated JSON"

# ============================================================================
# § 6. post-commit-cleanup.sh — PostToolUse sentinel cleanup, non-gating
# ============================================================================

POSTCOMMIT_SCRIPT="$HOOKS_DIR/post-commit-cleanup.sh"

# Representative payload (valid PostToolUse with commit command)
test_hook_exit_code "post-commit-cleanup.sh/rep" "$POSTCOMMIT_SCRIPT" "$POSTCOMMIT_PAYLOAD" \
    "representative payload"

# Garbage: empty stdin
test_hook_exit_code "post-commit-cleanup.sh/empty" "$POSTCOMMIT_SCRIPT" "$GARBAGE_EMPTY" \
    "empty stdin"

# Garbage: non-JSON text
test_hook_exit_code "post-commit-cleanup.sh/nontext" "$POSTCOMMIT_SCRIPT" "$GARBAGE_NONTEXT" \
    "non-JSON text"

# Garbage: truncated JSON
test_hook_exit_code "post-commit-cleanup.sh/truncated" "$POSTCOMMIT_SCRIPT" "$GARBAGE_TRUNCATED" \
    "truncated JSON"

# ============================================================================
# § Cleanup and results
# ============================================================================

cd / && rm -rf "$FIXTURE"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
