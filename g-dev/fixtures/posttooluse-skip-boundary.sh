#!/bin/bash
# posttooluse-skip-boundary.sh — characterization fixture for the M-audit W2
# residual: Claude Code skips PostToolUse hooks when the tool call exits
# non-zero, so a real commit buried in a failing chain is never seen by the
# argv-based PostToolUse sites (observe.sh journal, post-commit-cleanup.sh
# sentinel clear). This fixture proves the two halves that CAN be proven
# outside the platform:
#   §1 the class exists at git level — a chain `git commit … && false` exits
#      non-zero while the commit lands (HEAD advances);
#   §2 the hooks themselves are CORRECT given the event — fed the same
#      payload directly, observe.sh journals the commit and
#      post-commit-cleanup.sh clears both sentinels.
# The gap is therefore upstream (platform does not fire the hook), not a hook
# parsing bug. The unprovable half — the platform skip itself — is pinned by
# live evidence: W1.7's three gated commits are absent from the 2026-07-22
# journal (see M-audit ledger row W1.7ii, Task 28).
#
# All commits happen inside a throwaway repo under mktemp; identity is passed
# per-invocation with -c flags so nothing leaks into any real repo or config.

set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OBSERVE="$REPO_ROOT/hooks/observe.sh"
CLEANUP="$REPO_ROOT/hooks/post-commit-cleanup.sh"

PASS=0
FAIL=0

check() { # check <label> <cond-exit-code>
    if [ "$2" -eq 0 ]; then
        PASS=$((PASS + 1)); echo "  PASS: $1"
    else
        FAIL=$((FAIL + 1)); echo "  FAIL: $1"
    fi
}

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# ── §1 class exists at git level ─────────────────────────────────────────────
git -C "$TMP" init -q sandbox
SB="$TMP/sandbox"
echo seed > "$SB/f.txt"
git -C "$SB" add f.txt
git -C "$SB" -c user.name=fixture -c user.email=f@x commit -q -m "seed"
HEAD_BEFORE="$(git -C "$SB" rev-parse HEAD)"

echo change > "$SB/f.txt"
git -C "$SB" add f.txt
# The failing chain: commit succeeds, chain exits non-zero.
( cd "$SB" && git -c user.name=fixture -c user.email=f@x commit -q -m "buried commit" && false )
CHAIN_RC=$?
HEAD_AFTER="$(git -C "$SB" rev-parse HEAD)"

check "§1 failing chain exits non-zero (rc=$CHAIN_RC)" "$([ "$CHAIN_RC" -ne 0 ]; echo $?)"
check "§1 commit landed despite non-zero chain (HEAD advanced)" "$([ "$HEAD_BEFORE" != "$HEAD_AFTER" ]; echo $?)"

# ── §2 hooks are correct GIVEN the event ─────────────────────────────────────
# Scaffold a minimal G-Forge project state in the sandbox so the hooks engage.
mkdir -p "$SB/.claude/journal"
echo full > "$SB/.claude/integration-tier"

PAYLOAD='{"tool_name":"Bash","tool_input":{"command":"git commit -m \"buried commit\" && false"}}'

# observe.sh journals the commit when it actually receives the payload.
( cd "$SB" && printf '%s' "$PAYLOAD" | bash "$OBSERVE" ) >/dev/null 2>&1
OBS_RC=$?
JOURNAL_HIT=1
if ls "$SB/.claude/journal/"*.jsonl >/dev/null 2>&1; then
    grep -q '"kind":"commit"' "$SB/.claude/journal/"*.jsonl && JOURNAL_HIT=0
fi
check "§2 observe.sh exits 0 (non-gating invariant)" "$OBS_RC"
check "§2 observe.sh journals the commit when fed the payload" "$JOURNAL_HIT"

# post-commit-cleanup.sh clears both sentinels when it actually runs.
touch "$SB/.claude/g-forge-approved" "$SB/.claude/g-forge-docs-approved"
( cd "$SB" && printf '%s' "$PAYLOAD" | bash "$CLEANUP" ) >/dev/null 2>&1
CLEAN_RC=$?
SENTINELS_GONE=1
[ ! -f "$SB/.claude/g-forge-approved" ] && [ ! -f "$SB/.claude/g-forge-docs-approved" ] && SENTINELS_GONE=0
check "§2 post-commit-cleanup.sh exits 0 (non-gating invariant)" "$CLEAN_RC"
check "§2 post-commit-cleanup.sh clears both sentinels when fed the payload" "$SENTINELS_GONE"

echo
echo "Results: $PASS/$((PASS + FAIL)) passed"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
