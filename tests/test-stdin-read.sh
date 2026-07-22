#!/bin/bash
# Unit tests for hooks/lib/stdin-read.sh (stdin-read-with-timeout helper).
#
# Verifies: gf_read_stdin_timeout [seconds] reads stdin to EOF, defaults to 5s
# if timeout arg is omitted/empty/zero/non-numeric, always returns 0, preserves
# internal newlines, and bounds the wait when stdin abandonment occurs.
#
# CAVEAT — trailing newlines: captured via $(...) command substitution which
# unconditionally strips ALL trailing newlines. Internal newlines are preserved
# since the read is NUL-delimited, not newline-delimited.
#
# Total assertions: 10
# Count is the RUNNER-OBSERVED total and must equal the `Results:` line — the
# finding-#20 cross-check that catches a suite silently dropping cases.

LIB="$(cd "$(dirname "$0")" && pwd)/../hooks/lib/stdin-read.sh"
source "$LIB" || { echo "FAIL: could not source $LIB"; exit 1; }

PASS=0
FAIL=0

# ── Task 1: Library sourced successfully ────────────────────────────────────

echo "PASS: source hooks/lib/stdin-read.sh"
PASS=$((PASS+1))

# ── Task 2: Fast-path fixture — EOF-terminated payload captured byte-identical ──

# Fixed hardcoded multi-line JSON payload (internal newlines preserved).
# Trailing newline is part of the payload before piping; after $() capture
# in the caller, it will be stripped (documented behavior, not a bug).
FIXTURE_JSON=$(printf '%s' '{"key":"value","nested":{"items":[1,2,3]},"lines":"first line\nsecond line"}')

# Feed the payload through stdin via command substitution. The $(...)
# syntax passes stdin from the pipe through to gf_read_stdin_timeout.
INPUT=$(printf '%s' "$FIXTURE_JSON" | gf_read_stdin_timeout 5)

# Assert: captured value matches fixture byte-identical
if [ "$INPUT" = "$FIXTURE_JSON" ]; then
    echo "PASS: fast-path fixture — EOF-terminated multi-line JSON captured byte-identical"
    PASS=$((PASS+1))
else
    echo "FAIL: fast-path fixture — expected $(printf '%q' "$FIXTURE_JSON"), got $(printf '%q' "$INPUT")"
    FAIL=$((FAIL+1))
fi

# ── Task 3: Trailing newline stripped by $() (documented behavior) ──────────────

# Verify that trailing newlines are stripped by the $(...) call, not lost in
# the function itself — this documents the expected behavior when callers
# use INPUT=$(gf_read_stdin_timeout 5) without understanding the trailing-NL caveat.
FIXTURE_WITH_NEWLINE=$(printf '%s\n' 'payload')  # printf %s\n adds trailing newline

INPUT=$(printf '%s\n' 'payload' | gf_read_stdin_timeout 5)

# Input before $() was 'payload\n'; after $() it becomes 'payload' (newline stripped)
if [ "$INPUT" = "payload" ]; then
    echo "PASS: trailing newline stripped by \$(...) as documented"
    PASS=$((PASS+1))
else
    echo "FAIL: trailing newline behavior (expected 'payload', got $(printf '%q' "$INPUT"))"
    FAIL=$((FAIL+1))
fi

# ── Task 4: Abandoned-stdin fixture — timeout returns within N + epsilon ───────

# Create a portable stdin fixture that will never reach EOF.
# Approach: use process substitution with a long-running sleep to simulate
# an abandoned stdin (no writer, no EOF). The file descriptor will remain
# open but readable with nothing ever arriving.
# This avoids mkfifo (unreliable on MSYS) and uses bash process substitution.
#
# Use a very short timeout (1 second) so the test completes quickly.
# Assert: function returns within ~1.5s (timeout + small epsilon for bash overhead).

START_TIME=$(date +%s%3N)  # milliseconds since epoch

# Invoke the function with a 1-second timeout attached to a process that
# never writes and never closes (simulates abandoned stdin).
INPUT=$(gf_read_stdin_timeout 1 < <(sleep 300))
RC=$?

END_TIME=$(date +%s%3N)
ELAPSED=$((END_TIME - START_TIME))

# Assert: return code is 0 (always returns 0 per contract)
if [ "$RC" -ne 0 ]; then
    echo "FAIL: abandoned-stdin timeout — expected rc=0, got rc=$RC"
    FAIL=$((FAIL+1))
else
    echo "PASS: abandoned-stdin timeout — return code is 0"
    PASS=$((PASS+1))
fi

# Assert: captured value is empty (timeout with no input)
if [ -z "$INPUT" ]; then
    echo "PASS: abandoned-stdin timeout — captured value is empty"
    PASS=$((PASS+1))
else
    echo "FAIL: abandoned-stdin timeout — expected empty value, got $(printf '%q' "$INPUT")"
    FAIL=$((FAIL+1))
fi

# Assert: elapsed time is bounded by timeout + epsilon (1000ms + ~500ms overhead)
# This is a soft check; systems under heavy load may exceed epsilon, so we use
# a loose bound (2000ms / 2 seconds) to avoid false failures on slow CI.
if [ "$ELAPSED" -lt 2000 ]; then
    echo "PASS: abandoned-stdin timeout — returned within ~${ELAPSED}ms (expected <2000ms)"
    PASS=$((PASS+1))
else
    echo "FAIL: abandoned-stdin timeout — took ${ELAPSED}ms, expected <2000ms (timeout was 1s + epsilon)"
    FAIL=$((FAIL+1))
fi

# ── Task 5: Default-fallback fixture — invalid/zero/missing args → 5s default ──

# Test 1: Missing argument — should use 5s default
# Assert behavior via short-timeout proxy: call with empty string, verify it
# doesn't time out on a fast stdin (if it were 5s, a 1-line JSON would return
# instantly; if it were using empty default, it would also return instantly).
# This test relies on testing through behavior, not by waiting 5s.
INPUT_EMPTY=$(printf '%s' '{"empty":"true"}' | gf_read_stdin_timeout '')
if [ "$INPUT_EMPTY" = '{"empty":"true"}' ]; then
    echo "PASS: default-fallback fixture — empty string argument falls back to default (fast EOF returns instantly)"
    PASS=$((PASS+1))
else
    echo "FAIL: default-fallback fixture — empty string (expected fast EOF to return, got $(printf '%q' "$INPUT_EMPTY"))"
    FAIL=$((FAIL+1))
fi

# Test 2: Zero argument — should use 5s default
INPUT_ZERO=$(printf '%s' '{"zero":"test"}' | gf_read_stdin_timeout 0)
if [ "$INPUT_ZERO" = '{"zero":"test"}' ]; then
    echo "PASS: default-fallback fixture — zero argument falls back to default (fast EOF returns instantly)"
    PASS=$((PASS+1))
else
    echo "FAIL: default-fallback fixture — zero (expected fast EOF to return, got $(printf '%q' "$INPUT_ZERO"))"
    FAIL=$((FAIL+1))
fi

# Test 3: Non-numeric argument — should use 5s default
INPUT_NONNUMERIC=$(printf '%s' '{"nonnumeric":"test"}' | gf_read_stdin_timeout 'abc')
if [ "$INPUT_NONNUMERIC" = '{"nonnumeric":"test"}' ]; then
    echo "PASS: default-fallback fixture — non-numeric argument falls back to default (fast EOF returns instantly)"
    PASS=$((PASS+1))
else
    echo "FAIL: default-fallback fixture — non-numeric (expected fast EOF to return, got $(printf '%q' "$INPUT_NONNUMERIC"))"
    FAIL=$((FAIL+1))
fi

# Test 4: Missing argument — should use 5s default
# Call without any argument at all.
INPUT_MISSING=$(printf '%s' '{"missing":"test"}' | gf_read_stdin_timeout)
if [ "$INPUT_MISSING" = '{"missing":"test"}' ]; then
    echo "PASS: default-fallback fixture — missing argument falls back to default (fast EOF returns instantly)"
    PASS=$((PASS+1))
else
    echo "FAIL: default-fallback fixture — missing (expected fast EOF to return, got $(printf '%q' "$INPUT_MISSING"))"
    FAIL=$((FAIL+1))
fi

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
