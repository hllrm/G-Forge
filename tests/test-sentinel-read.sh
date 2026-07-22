#!/bin/bash
# Unit tests for hooks/lib/sentinel-read.sh (ADR-004 sentinel-stamp parser).
#
# STATUS (W1.5d task 1 — fail-before suite): hooks/lib/sentinel-read.sh does
# NOT exist yet. This suite is written and committed BEFORE the lib exists,
# pinning the contract of the CURRENT gf_parse_stamp() implementation that
# lives inline in hooks/pre-commit (lines ~74-115, as of 2026-07-19) so that
# W1.5d Wave 3 can extract it into hooks/lib/sentinel-read.sh and convert
# both call sites (hooks/pre-commit, hooks/workflow-checkpoint.sh) to source
# the shared lib — with this suite as the fail-before/pass-after gate,
# mirroring tests/test-classify-changeset.sh's ground-truth-from-the-actual-
# implementation-body precedent.
#
# EXPECTED RESULT TODAY: non-zero exit. Sourcing hooks/lib/sentinel-read.sh
# fails (file does not exist) — every contract case below reports FAIL
# clearly (never silently skipped), and all three single-reader invariant
# greps in Task 3 also report FAIL (the two call sites still contain their
# own inline extraction instead of sourcing the not-yet-created lib). After
# W1.5d Wave 3 extracts the lib and converts both call sites, this whole
# suite is expected to flip green.
#
# Ground-truth contract encoded from hooks/pre-commit's gf_parse_stamp()
# (verified against the source body, not from memory or idealized behavior):
#   - reads the file as a single string via `cat`; a single trailing CR
#     (CRLF-authored stamp) is stripped from the whole line before parsing
#   - embedded newlines (multi-line file) => rc 1, all globals blanked
#   - missing file => rc 1, all globals blanked
#   - all three fields (commit_sentinel_ts / commit_sentinel_head /
#     commit_sentinel_worktree) are required; ANY missing => rc 1, all
#     globals blanked (checked before any field is assigned)
#   - commit_sentinel_ts and commit_sentinel_head are extracted via
#     `${line#*key=}` (first-occurrence prefix-strip) then space-truncated
#     via `${val%% *}`
#   - commit_sentinel_worktree is the TERMINAL field: extracted the same
#     way but read to end-of-line (no space-truncation), then has one
#     trailing CR stripped — this is the W1.2 Major fix that lets worktree
#     paths containing spaces (e.g. Windows `C:/Users/Some Name/repo`)
#     survive intact
#   - an empty commit_sentinel_head value is legitimate (first-commit stamp)
#     and still yields rc 0
#
# Total assertions: 16
# Count is the RUNNER-OBSERVED total and must equal the `Results:` line — the
# finding-#20 cross-check that catches a suite silently dropping cases.

SUITE_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SUITE_DIR/.." && pwd)"
LIB="$REPO_ROOT/hooks/lib/sentinel-read.sh"

PASS=0
FAIL=0

# ── Source the lib (expected to FAIL today — the fail-before signal) ──────────

LIB_SOURCED=0
if source "$LIB" 2>/dev/null; then
    LIB_SOURCED=1
    echo "PASS: source hooks/lib/sentinel-read.sh"
    PASS=$((PASS+1))
else
    echo "FAIL: source hooks/lib/sentinel-read.sh (file missing or fails to source — EXPECTED today, this is the W1.5d fail-before signal; every contract case below will also report FAIL rather than being silently skipped)"
    FAIL=$((FAIL+1))
fi

# Temp dir for stamp fixture files.
STAMP_DIR=$(mktemp -d 2>/dev/null) || STAMP_DIR="${TMPDIR:-/tmp}/gf-test-sentinel-read-$$"
mkdir -p "$STAMP_DIR" 2>/dev/null
cleanup_trap() {
    [ -n "$STAMP_DIR" ] && [ -d "$STAMP_DIR" ] && rm -rf "$STAMP_DIR"
}
trap cleanup_trap EXIT

_stamp_seq=0

# test_parse_stamp <name> <file_content> <exp_rc> <exp_ts> <exp_head> <exp_worktree>
# Writes <file_content> verbatim (via printf '%s') to a fresh temp file, calls
# gf_parse_stamp on it, and asserts return code + all three globals. Runs in
# the PARENT shell (never a subshell/pipe/command-substitution) so PASS/FAIL
# accumulate correctly — the W1.5b false-green trap this mirrors from
# tests/test-classify-changeset.sh's convention.
test_parse_stamp() {
    local name="$1" content="$2" exp_rc="$3" exp_ts="$4" exp_head="$5" exp_worktree="$6"
    if [ "$LIB_SOURCED" -ne 1 ]; then
        echo "FAIL: $name (skipped — hooks/lib/sentinel-read.sh not sourced; fail-before evidence, not a silent skip)"
        FAIL=$((FAIL+1))
        return
    fi
    _stamp_seq=$((_stamp_seq+1))
    local f="$STAMP_DIR/stamp_$_stamp_seq"
    printf '%s' "$content" > "$f"
    STAMP_TS="__unset__"
    STAMP_HEAD="__unset__"
    STAMP_WORKTREE="__unset__"
    gf_parse_stamp "$f"
    local rc=$?
    rm -f -- "$f"
    if [ "$rc" -eq "$exp_rc" ] && [ "$STAMP_TS" = "$exp_ts" ] && [ "$STAMP_HEAD" = "$exp_head" ] && [ "$STAMP_WORKTREE" = "$exp_worktree" ]; then
        echo "PASS: $name"
        PASS=$((PASS+1))
    else
        echo "FAIL: $name (expected rc=$exp_rc ts=$(printf '%q' "$exp_ts") head=$(printf '%q' "$exp_head") worktree=$(printf '%q' "$exp_worktree"); got rc=$rc ts=$(printf '%q' "$STAMP_TS") head=$(printf '%q' "$STAMP_HEAD") worktree=$(printf '%q' "$STAMP_WORKTREE"))"
        FAIL=$((FAIL+1))
    fi
}

# test_parse_stamp_missing <name> — assert rc=1 and all globals blanked when
# the target file does not exist at all.
test_parse_stamp_missing() {
    local name="$1"
    if [ "$LIB_SOURCED" -ne 1 ]; then
        echo "FAIL: $name (skipped — hooks/lib/sentinel-read.sh not sourced; fail-before evidence, not a silent skip)"
        FAIL=$((FAIL+1))
        return
    fi
    _stamp_seq=$((_stamp_seq+1))
    local f="$STAMP_DIR/does-not-exist-$_stamp_seq"
    rm -f -- "$f" 2>/dev/null
    STAMP_TS="__unset__"
    STAMP_HEAD="__unset__"
    STAMP_WORKTREE="__unset__"
    gf_parse_stamp "$f"
    local rc=$?
    if [ "$rc" -eq 1 ] && [ -z "$STAMP_TS" ] && [ -z "$STAMP_HEAD" ] && [ -z "$STAMP_WORKTREE" ]; then
        echo "PASS: $name"
        PASS=$((PASS+1))
    else
        echo "FAIL: $name (expected rc=1 and all globals blank; got rc=$rc ts=$(printf '%q' "$STAMP_TS") head=$(printf '%q' "$STAMP_HEAD") worktree=$(printf '%q' "$STAMP_WORKTREE"))"
        FAIL=$((FAIL+1))
    fi
}

# ── Task 2: gf_parse_stamp contract cases ──────────────────────────────────────

echo ""
echo "── Task 2: gf_parse_stamp contract cases ─────────────────────────────────"

# Valid 3-field stamp.
test_parse_stamp "valid 3-field stamp" \
    $'commit_sentinel_ts=abc123 commit_sentinel_head=def456 commit_sentinel_worktree=/home/user/repo\n' \
    0 "abc123" "def456" "/home/user/repo"

# Spaced-worktree stamp — terminal-read pin (W1.2 Major fix): a worktree path
# containing spaces (Windows-style) must survive intact rather than being
# truncated at the first space like ts/head are.
test_parse_stamp "spaced Windows worktree path (terminal read, no truncation)" \
    $'commit_sentinel_ts=abc123 commit_sentinel_head=def456 commit_sentinel_worktree=C:/Users/Some Name/repo\n' \
    0 "abc123" "def456" "C:/Users/Some Name/repo"

# CRLF-authored stamp (single line ending \r\n) — one trailing CR stripped.
test_parse_stamp "CRLF-authored stamp (trailing CR stripped)" \
    $'commit_sentinel_ts=abc commit_sentinel_head=def commit_sentinel_worktree=/repo\r\n' \
    0 "abc" "def" "/repo"

# CRLF-authored stamp with a spaced worktree — pins that the trailing-CR
# strip applies to the worktree value specifically (not just line-level),
# combined with the terminal-read behavior, as two independent bullets of
# the contract collapsing onto the same field.
test_parse_stamp "CRLF-authored stamp with spaced worktree (both fixes combined)" \
    $'commit_sentinel_ts=abc commit_sentinel_head=def commit_sentinel_worktree=C:/Users/Some Name/repo\r\n' \
    0 "abc" "def" "C:/Users/Some Name/repo"

# Empty-head stamp — legitimate first-commit stamp (no HEAD to resolve yet).
test_parse_stamp "empty commit_sentinel_head (legitimate first-commit stamp)" \
    $'commit_sentinel_ts=abc123 commit_sentinel_head= commit_sentinel_worktree=/repo\n' \
    0 "abc123" "" "/repo"

# Missing file.
test_parse_stamp_missing "missing file => rc 1, globals blank"

# Multi-line file (embedded newline) — unparseable, never guessed past.
test_parse_stamp "multi-line file => rc 1, globals blank" \
    $'commit_sentinel_ts=abc\ncommit_sentinel_head=def\ncommit_sentinel_worktree=/repo\n' \
    1 "" "" ""

# Each of the three required fields individually absent.
test_parse_stamp "missing commit_sentinel_ts field => rc 1, globals blank" \
    $'commit_sentinel_head=def456 commit_sentinel_worktree=/repo\n' \
    1 "" "" ""

test_parse_stamp "missing commit_sentinel_head field => rc 1, globals blank" \
    $'commit_sentinel_ts=abc123 commit_sentinel_worktree=/repo\n' \
    1 "" "" ""

test_parse_stamp "missing commit_sentinel_worktree field => rc 1, globals blank" \
    $'commit_sentinel_ts=abc123 commit_sentinel_head=def456\n' \
    1 "" "" ""

# Extra leading/interior content around fields — fields are extracted via
# `${line#*key=}` (first-occurrence prefix-strip), so garbage before and
# between the key=value pairs does not break extraction. This encodes the
# ACTUAL current behavior (tolerant of surrounding noise), not an idealized
# strict-format parser.
test_parse_stamp "extra leading/interior content around fields still extracts correctly" \
    $'garbage commit_sentinel_ts=abc123 blah commit_sentinel_head=def456 blah2 commit_sentinel_worktree=/repo/path\n' \
    0 "abc123" "def456" "/repo/path"

# Duplicate field name — pins first-occurrence-wins semantics of
# `${line#*key=}` (shortest-prefix-match strips only up to the FIRST
# occurrence of the literal key= text).
test_parse_stamp "duplicate commit_sentinel_ts field — first occurrence wins" \
    $'commit_sentinel_ts=first commit_sentinel_ts=second commit_sentinel_head=def commit_sentinel_worktree=/repo\n' \
    0 "first" "def" "/repo"

# ── Task 3: Single-reader invariant checks ─────────────────────────────────────
# Run REGARDLESS of source success (contract section above runs to completion
# first and reports its own failures clearly; these greps run independently
# below, against the actual repo files, not against the sourced lib).

echo ""
echo "── Task 3: Single-reader invariant checks ────────────────────────────────"

# Invariant (a): hooks/pre-commit sources hooks/lib/sentinel-read.sh.
if grep -qE '^\. .*sentinel-read\.sh' "$REPO_ROOT/hooks/pre-commit" 2>/dev/null; then
    echo "PASS: invariant (a) — hooks/pre-commit sources hooks/lib/sentinel-read.sh"
    PASS=$((PASS+1))
else
    echo "FAIL: invariant (a) — hooks/pre-commit does not source hooks/lib/sentinel-read.sh yet (EXPECTED today — flips green after W1.5d Wave 3 converts this call site)"
    FAIL=$((FAIL+1))
fi

# Invariant (b): hooks/workflow-checkpoint.sh sources hooks/lib/sentinel-read.sh.
if grep -qE '^\. .*sentinel-read\.sh' "$REPO_ROOT/hooks/workflow-checkpoint.sh" 2>/dev/null; then
    echo "PASS: invariant (b) — hooks/workflow-checkpoint.sh sources hooks/lib/sentinel-read.sh"
    PASS=$((PASS+1))
else
    echo "FAIL: invariant (b) — hooks/workflow-checkpoint.sh does not source hooks/lib/sentinel-read.sh yet (EXPECTED today — flips green after W1.5d Wave 3 converts this call site)"
    FAIL=$((FAIL+1))
fi

# Invariant (c): zero occurrences of inline `#*commit_sentinel_` parameter-
# expansion extraction anywhere under hooks/ EXCEPT hooks/lib/sentinel-read.sh
# itself — the single-reader invariant (only one place is allowed to parse
# the stamp format), mirroring test-classify-changeset.sh's Task 6a/6b/6c
# single-classifier invariant structure adapted to a single-READER invariant.
INLINE_HITS=$(grep -rn '#\*commit_sentinel_' "$REPO_ROOT/hooks" 2>/dev/null | grep -v -- '/hooks/lib/sentinel-read\.sh:')
if [ -z "$INLINE_HITS" ]; then
    echo "PASS: invariant (c) — zero inline #*commit_sentinel_ extraction outside hooks/lib/sentinel-read.sh"
    PASS=$((PASS+1))
else
    echo "FAIL: invariant (c) — inline #*commit_sentinel_ extraction still present outside hooks/lib/sentinel-read.sh (EXPECTED today — call sites not yet converted; flips green after W1.5d Wave 3):"
    echo "$INLINE_HITS" | sed 's/^/    /'
    FAIL=$((FAIL+1))
fi

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
