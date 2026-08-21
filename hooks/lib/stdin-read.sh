#!/bin/bash
# hooks/lib/stdin-read.sh — shared stdin-read-with-timeout helper.
#
# Sourced by hooks; must be side-effect-free at source time (functions only,
# no top-level execution).
#
# Several hooks read their tool-call payload with a bare `INPUT=$(cat)`. When
# the Claude Code harness abandons a tool call (crash, restart, or a
# Windows-specific harness quirk), stdin is left open with no writer and no
# EOF ever arrives, so `cat` blocks forever — two such hooks were found
# orphaned for 66 minutes in the field before being killed manually. The
# plugin's own hook timeout (set in hooks.json) is not reliably enforced by
# the harness in that state, so hooks cannot rely on it alone. This helper
# bounds the wait itself, using only bash's own `read` builtin — NO
# dependency on the external `timeout` coreutil, which may be absent on a
# bare Windows Git Bash PATH.
#
# gf_read_stdin_timeout [seconds] — read stdin to EOF and print the captured
# payload to stdout. `seconds` defaults to 5 if omitted, empty, zero, or not
# a positive integer.
#
# Mechanism: `read -t <seconds> -d ''`. The NUL delimiter (`-d ''`) means
# "read every byte through EOF", not "read one line" — so a multi-line JSON
# payload is captured whole, newlines and all. `-t` bounds the wait: if
# stdin is an open pipe with no writer and no EOF, `read` returns with a
# >128 exit status once <seconds> elapses, and per bash's documented
# behaviour (bash >= 4.4) any partial input already received is preserved in
# the target variable rather than discarded — so a slow-but-eventually-live
# writer still yields whatever arrived before the deadline. The fast path —
# payload arrives and stdin hits EOF immediately, the common case — returns
# as soon as `read` sees EOF, with zero added latency; the timeout only
# bites when EOF never comes.
#
# This function always returns 0. A `read` timeout or EOF-without-delimiter
# is not treated as an error here — the caller gets back whatever was
# captured (possibly empty) either way, and decides whether an empty/partial
# payload is fatal. The explicit `|| true` on the read keeps this safe to
# call from a hook that has `set -e` active.
#
# CAVEAT — trailing newlines: the intended call form is
# `INPUT=$(gf_read_stdin_timeout 5)`. Bash command substitution `$(...)`
# unconditionally strips ALL trailing newlines from captured output, exactly
# like the `INPUT=$(cat)` idiom this replaces — so that edge behaviour is
# unchanged for callers. Internal (non-trailing) newlines in the payload are
# preserved exactly, since the read below is NUL-delimited, not
# newline-delimited.
#
# GF_STDIN_TIMEOUT_OVERRIDE — optional env var, consumed only by this
# function. When set and non-empty, its value replaces the effective
# timeout BEFORE the normalization below runs, so an invalid override
# (negative, non-numeric) falls through the exact same normalization/default
# path as an invalid `seconds` argument — no separate validation branch for
# the override. An empty override is a no-op, not an invalid-value case: the
# `-n` guard below skips the assignment entirely, so the `seconds` argument
# governs exactly as if the override were unset — it never reaches
# normalization. This exists so test fixtures (M48c)
# can force a short, deterministic timeout without changing call sites or
# argument-passing at every hook. Unset or empty GF_STDIN_TIMEOUT_OVERRIDE
# is a no-op: the function's behavior is then byte-identical to today,
# driven solely by the `seconds` argument as before. Production hooks do
# not set this var and are not expected to start doing so — it is a test
# hook, not a runtime tuning knob.
gf_read_stdin_timeout() {
    local timeout_secs="$1"
    local payload=""

    if [ -n "${GF_STDIN_TIMEOUT_OVERRIDE:-}" ]; then
        timeout_secs="$GF_STDIN_TIMEOUT_OVERRIDE"
    fi

    case "$timeout_secs" in
        '' | *[!0-9]*) timeout_secs=5 ;;
    esac
    [ "$timeout_secs" -gt 0 ] 2>/dev/null || timeout_secs=5

    IFS= read -r -t "$timeout_secs" -d '' payload || true

    printf '%s' "$payload"
    return 0
}
