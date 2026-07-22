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
# Total assertions: 38
# - Structural: 2 (gating pair exclusion, hook list completeness)
# - Exit-code invariant: 24 (all six hooks × 4 payload types: 1 representative + 3 garbage)
# - Abandoned-stdin invariant: 12 (all six hooks × 2 assertions: exit 0 + bounded wait time)

# ============================================================================
# § Structural assertions — gating pair exclusion
# ============================================================================

PASS=0
FAIL=0

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

# test_hook_abandoned_stdin <name> <hook-script> <description>
# Invoke hook with stdin attached to an open pipe with NO writer and NO EOF
# (simulates orphaned tool call). Assert: exit 0 + return within guard window.
# Window = 5s guard + 15s epsilon: MSYS subprocess-spawn overhead in the hook
# body after the read can add 3-5s (worst observed 9.9s total on Windows);
# 20s stays 15x under the 300s no-writer fixture, so the bound is still decisive.
GUARD_WINDOW_MS=20000
test_hook_abandoned_stdin() {
    local name="$1" script="$2" desc="$3"
    local start_time end_time elapsed

    start_time=$(date +%s%3N)
    bash "$script" >/dev/null 2>&1 < <(sleep 300)
    local rc=$?
    end_time=$(date +%s%3N)
    elapsed=$((end_time - start_time))

    if [ "$rc" -eq 0 ]; then
        echo "PASS: $name — $desc (abandoned stdin, exit 0)"; PASS=$((PASS+1))
    else
        echo "FAIL: $name — $desc (abandoned stdin, exit $rc, expected 0)"; FAIL=$((FAIL+1))
    fi

    if [ "$elapsed" -lt "$GUARD_WINDOW_MS" ]; then
        echo "PASS: $name — $desc (abandoned stdin, returned in ${elapsed}ms, <${GUARD_WINDOW_MS}ms)"; PASS=$((PASS+1))
    else
        echo "FAIL: $name — $desc (abandoned stdin, took ${elapsed}ms, expected <${GUARD_WINDOW_MS}ms)"; FAIL=$((FAIL+1))
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
# § 7. Abandoned-stdin fixture — all six hooks tolerate orphaned stdin
# ============================================================================
#
# Verifies the orphan-process class (66-min hangs on abandoned stdin found in
# field) is dead. Each hook sources hooks/lib/stdin-read.sh and calls
# gf_read_stdin_timeout 5, which bounds the wait via `read -t 5 -d ''`.
# This fixture invokes each hook with stdin attached to an open pipe with NO
# writer and NO EOF, simulating a harness crash or timeout that leaves stdin
# stranded. Assert: exit 0 + return within guard window (timeout 5s + overhead).

# ── 1. observe.sh with abandoned stdin ─────────────────────────────────────

test_hook_abandoned_stdin "observe.sh/abandoned" "$OBSERVE_SCRIPT" \
    "abandoned stdin (no writer, no EOF)"

# ── 2. agent-lifecycle.sh with abandoned stdin ─────────────────────────────

test_hook_abandoned_stdin "agent-lifecycle.sh/abandoned" "$AGENT_SCRIPT" \
    "abandoned stdin (no writer, no EOF)"

# ── 3. session-start.sh with abandoned stdin ───────────────────────────────

test_hook_abandoned_stdin "session-start.sh/abandoned" "$SESSION_SCRIPT" \
    "abandoned stdin (no writer, no EOF)"

# ── 4. pre-compact.sh with abandoned stdin ────────────────────────────────

test_hook_abandoned_stdin "pre-compact.sh/abandoned" "$COMPACT_SCRIPT" \
    "abandoned stdin (no writer, no EOF)"

# ── 5. workflow-checkpoint.sh with abandoned stdin ────────────────────────

test_hook_abandoned_stdin "workflow-checkpoint.sh/abandoned" "$CHECKPOINT_SCRIPT" \
    "abandoned stdin (no writer, no EOF)"

# ── 6. post-commit-cleanup.sh with abandoned stdin ─────────────────────────

test_hook_abandoned_stdin "post-commit-cleanup.sh/abandoned" "$POSTCOMMIT_SCRIPT" \
    "abandoned stdin (no writer, no EOF)"

# ============================================================================
# § Cleanup and results
# ============================================================================

cd / && rm -rf "$FIXTURE"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
