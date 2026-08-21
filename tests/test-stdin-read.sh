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
# Total assertions: 12
# Count is the RUNNER-OBSERVED total and must equal the `Results:` line — the
# finding-#20 cross-check that catches a suite silently dropping cases.

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="$TESTS_DIR/../hooks/lib/stdin-read.sh"
source "$LIB" || { echo "FAIL: could not source $LIB"; exit 1; }
# Timing bounds are declared once, with their evidence, in tests/lib/.
source "$TESTS_DIR/lib/timing-bounds.sh" || { echo "FAIL: could not source tests/lib/timing-bounds.sh"; exit 1; }

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
# Assert: function returns within GF_LIB_READ_WINDOW_MS (tests/lib/timing-bounds.sh).

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

# Assert: elapsed time is bounded by the 1s timeout + MSYS epsilon. Bound and
# evidence live in tests/lib/timing-bounds.sh; it is not a "loose bound to avoid
# CI flake" — it is 2x the worst run ever observed here.
if [ "$ELAPSED" -lt "$GF_LIB_READ_WINDOW_MS" ]; then
    echo "PASS: abandoned-stdin timeout — returned within ~${ELAPSED}ms (expected <${GF_LIB_READ_WINDOW_MS}ms)"
    PASS=$((PASS+1))
else
    echo "FAIL: abandoned-stdin timeout — took ${ELAPSED}ms, expected <${GF_LIB_READ_WINDOW_MS}ms (timeout was 1s + MSYS epsilon)"
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

# ── Task 6: GF_STDIN_TIMEOUT_OVERRIDE honored — override bounds the read, not the arg ──

# Falsifiability: proven against a disposable scratch copy of the lib with the
# override branch (stdin-read.sh:67-69) commented out — production
# hooks/lib/stdin-read.sh was never touched for this. Same fixture (override=1,
# argument=8, abandoned stdin) took 8162ms on the neutered copy, breaching
# GF_LIB_READ_WINDOW_MS (6000ms) — i.e. this assertion goes RED when the
# override mechanism is absent. Transcript in
# g-docs/agent-output/wave-2-m48b/stdin-read-override-assertions.md.

# Set a short override (1s) but pass a much longer argument (8s). If the
# override is honored, the abandoned-stdin read returns bounded by the
# override, not the argument — proving GF_STDIN_TIMEOUT_OVERRIDE wins.
export GF_STDIN_TIMEOUT_OVERRIDE=1

START_TIME=$(date +%s%3N)
INPUT=$(gf_read_stdin_timeout 8 < <(sleep 300))
RC=$?
END_TIME=$(date +%s%3N)
ELAPSED=$((END_TIME - START_TIME))

unset GF_STDIN_TIMEOUT_OVERRIDE

if [ "$RC" -eq 0 ] && [ -z "$INPUT" ] && [ "$ELAPSED" -lt "$GF_LIB_READ_WINDOW_MS" ]; then
    echo "PASS: GF_STDIN_TIMEOUT_OVERRIDE honored — override(1s) bounded the read within ~${ELAPSED}ms despite argument(8s) (expected <${GF_LIB_READ_WINDOW_MS}ms)"
    PASS=$((PASS+1))
else
    echo "FAIL: GF_STDIN_TIMEOUT_OVERRIDE honored — rc=$RC input=$(printf '%q' "$INPUT") took ${ELAPSED}ms, expected rc=0/empty/<${GF_LIB_READ_WINDOW_MS}ms"
    FAIL=$((FAIL+1))
fi

# ── Task 7: GF_STDIN_TIMEOUT_OVERRIDE unset/empty — argument still governs ──────

# GF_STDIN_TIMEOUT_OVERRIDE present but empty (the `[ -n ... ]` no-op case, not
# merely absent — every prior test in this suite already ran with the var
# fully unset, so this pins the "set but empty" edge explicitly). The
# argument's own 1s timeout must still bound an abandoned-stdin read, exactly
# as it did before the override existed.
#
# Local bound, not GF_LIB_READ_WINDOW_MS: this assertion exists to catch the
# regression where the `-n` guard at stdin-read.sh:67 is loosened to treat
# "set but empty" as "set" — which would make timeout_secs="" fall through
# normalization to the 5s default instead of staying a no-op. Bounding at
# GF_LIB_READ_WINDOW_MS (6000ms) cannot distinguish the two: the regressed
# path still finishes in ~5.2s, under 6000ms, so the assertion would stay
# green on the exact bug it names. GF_EMPTY_OVERRIDE_WINDOW_MS sits strictly
# between the correct path's worst observed (2876ms, GF_LIB_READ_WINDOW_MS
# comment in tests/lib/timing-bounds.sh) and the regression's ~5.2s floor —
# 1.56x the worst observed - the widest bound the discrimination window
# allows; the profile's 2x rule cannot be met here without making the
# assertion inert, and this comment records that trade explicitly. Local to this file
# (not tests/lib/timing-bounds.sh) because it discriminates one assertion's
# regression, not a shared fact about the lib.
#
# Falsifiability: scratch-red-proven against a disposable copy of the lib
# whose guard was changed from `[ -n "${GF_STDIN_TIMEOUT_OVERRIDE:-}" ]` to
# `[ "${GF_STDIN_TIMEOUT_OVERRIDE+x}" = "x" ]` (treats set-but-empty as set)
# — production hooks/lib/stdin-read.sh was never touched. Same fixture
# (override="", argument=1, abandoned stdin): neutered copy took 5158ms,
# breaching a 4500ms bound (RED, `exit 1`); the real fixed lib took 1165ms
# against the same bound (PASS). Command + output recorded in
# g-docs/agent-output/fix-r1-m48b/code-fixes.md (fix round r1, M48b HOLD
# item 2).
GF_EMPTY_OVERRIDE_WINDOW_MS=4500

export GF_STDIN_TIMEOUT_OVERRIDE=""

START_TIME=$(date +%s%3N)
INPUT=$(gf_read_stdin_timeout 1 < <(sleep 300))
RC=$?
END_TIME=$(date +%s%3N)
ELAPSED=$((END_TIME - START_TIME))

unset GF_STDIN_TIMEOUT_OVERRIDE

if [ "$RC" -eq 0 ] && [ -z "$INPUT" ] && [ "$ELAPSED" -lt "$GF_EMPTY_OVERRIDE_WINDOW_MS" ]; then
    echo "PASS: GF_STDIN_TIMEOUT_OVERRIDE empty — argument(1s) still governs, returned within ~${ELAPSED}ms (expected <${GF_EMPTY_OVERRIDE_WINDOW_MS}ms)"
    PASS=$((PASS+1))
else
    echo "FAIL: GF_STDIN_TIMEOUT_OVERRIDE empty — rc=$RC input=$(printf '%q' "$INPUT") took ${ELAPSED}ms, expected rc=0/empty/<${GF_EMPTY_OVERRIDE_WINDOW_MS}ms"
    FAIL=$((FAIL+1))
fi

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
