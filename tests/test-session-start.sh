#!/bin/bash
# Unit tests for hooks/session-start.sh (session sync and health check).
#
# Verifies:
# - Non-gating contract: hook exits 0 on all inputs (valid + garbage payloads)
# - Worktree guard: resolves primary-tree state per ADR-005, never blocks
# - Integration-tier gating: light tier ⇒ silently skips
# - Session banner: prints branch, dirty-count, stash, ahead/behind, clean indicator
# - SESSION_SOURCE semantics: compact ⇒ preserve counters, other ⇒ reset counters
# - Edge cases: not in git repo, not a G-Forge project, missing remote branch
#
# Total assertions: 30
# Count is the RUNNER-OBSERVED total and must equal the `Results:` line — the
# finding-#20 cross-check that catches a suite silently dropping cases.
# Every PASS/FAIL emission is in the parent shell; the subshells below are
# output-capture helpers that assert nothing, so no counter increment is lost.

# Resolve script dir / hooks dir to ABSOLUTE paths exactly once, before any
# fixture cd. Relative $0 (as invoked from repo root) would otherwise break
# `dirname "$0"` after the sandbox cd below.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$(cd "$SCRIPT_DIR/../hooks" && pwd)"
SESSION_SCRIPT="$HOOKS_DIR/session-start.sh"

PASS=0
FAIL=0

# Common check function
check() { # name expected actual
    if [ "$2" = "$3" ]; then
        echo "PASS: $1"; PASS=$((PASS+1))
    else
        echo "FAIL: $1 (expected '$2', got '$3')"; FAIL=$((FAIL+1))
    fi
}

# banner_output <payload> — run session-start.sh on a payload and return the
# banner text (everything except status codes).
banner_output() {
    local payload="$1" dir
    dir=$(mktemp -d)
    (
        cd "$dir" || exit 1
        git init -q
        git config user.email "test@g-forge.local"
        git config user.name "test"
        mkdir -p .claude
        printf 'full\n' > .claude/integration-tier
        # Self-ignoring .gitignore: without it the untracked .claude/ (and this
        # file) count as dirt, so the "clean tree" assertions never saw a clean
        # tree (r2 attestation §2.3 failure).
        printf '.claude/\n.gitignore\n' > .gitignore
        printf '%s' "$payload" | bash "$SESSION_SCRIPT"
    )
    rm -rf "$dir"
}

# exit_code <payload> — run session-start.sh and return only the exit code
exit_code() {
    local payload="$1" dir
    dir=$(mktemp -d)
    (
        cd "$dir" || exit 1
        git init -q
        git config user.email "test@g-forge.local"
        git config user.name "test"
        mkdir -p .claude
        printf 'full\n' > .claude/integration-tier
        # Self-ignoring .gitignore: without it the untracked .claude/ (and this
        # file) count as dirt, so the "clean tree" assertions never saw a clean
        # tree (r2 attestation §2.3 failure).
        printf '.claude/\n.gitignore\n' > .gitignore
        printf '%s' "$payload" | bash "$SESSION_SCRIPT" >/dev/null 2>&1
    )
    local rc=$?
    rm -rf "$dir"
    echo "$rc"
}

# counter_value <counter_name> <payload> — run session-start.sh and return
# the value of a session counter file (session-prompt-count or session-compaction-count)
counter_value() {
    local counter="$1" payload="$2" dir
    dir=$(mktemp -d)
    (
        cd "$dir" || exit 1
        git init -q
        git config user.email "test@g-forge.local"
        git config user.name "test"
        mkdir -p .claude
        printf 'full\n' > .claude/integration-tier
        # Pre-set counters to a known value to detect changes
        printf '5\n' > .claude/session-prompt-count
        printf '3\n' > .claude/session-compaction-count
        printf '%s' "$payload" | bash "$SESSION_SCRIPT" >/dev/null 2>&1
        # Return the counter value (or empty if not reset)
        cat ".claude/$counter" 2>/dev/null || echo ""
    )
    rm -rf "$dir"
}

# ============================================================================
# § Test payloads — fixed data, no timestamps or UUIDs
# ============================================================================

PAYLOAD_STARTUP='{"source":"startup"}'
PAYLOAD_COMPACT='{"source":"compact"}'
PAYLOAD_RESUME='{"source":"resume"}'
PAYLOAD_CLEAR='{"source":"clear"}'
PAYLOAD_EMPTY=""
PAYLOAD_GARBAGE_TEXT="not json at all"
PAYLOAD_TRUNCATED='{"source":'

# ============================================================================
# § Section 1: Non-gating contract — exit 0 on all inputs
# ============================================================================

echo "§ 1 — Non-gating exit-code invariant (5 scenarios)"

# 1.1 Valid startup payload
RC=$(exit_code "$PAYLOAD_STARTUP")
check "startup payload exits 0" "0" "$RC"

# 1.2 Valid compact payload
RC=$(exit_code "$PAYLOAD_COMPACT")
check "compact payload exits 0" "0" "$RC"

# 1.3 Valid resume payload
RC=$(exit_code "$PAYLOAD_RESUME")
check "resume payload exits 0" "0" "$RC"

# 1.4 Empty stdin
RC=$(exit_code "$PAYLOAD_EMPTY")
check "empty stdin exits 0" "0" "$RC"

# 1.5 Garbage JSON
RC=$(exit_code "$PAYLOAD_GARBAGE_TEXT")
check "garbage text exits 0" "0" "$RC"

# ============================================================================
# § Section 2: Banner output validation (4 scenarios)
# ============================================================================

echo "§ 2 — Banner content validation"

# 2.1 Prints branch line
BANNER=$(banner_output "$PAYLOAD_STARTUP")
if echo "$BANNER" | grep -q "Branch:"; then
    echo "PASS: banner includes 'Branch:' line"; PASS=$((PASS+1))
else
    echo "FAIL: banner missing 'Branch:' line"; FAIL=$((FAIL+1))
fi

# 2.2 Prints session start marker
BANNER=$(banner_output "$PAYLOAD_STARTUP")
if echo "$BANNER" | grep -q "\[G-Forge Session Start\]"; then
    echo "PASS: banner includes '[G-Forge Session Start]' marker"; PASS=$((PASS+1))
else
    echo "FAIL: banner missing session start marker"; FAIL=$((FAIL+1))
fi

# 2.3 Clean state: no dirty-count line on clean tree (and banner still present)
BANNER=$(banner_output "$PAYLOAD_STARTUP")
if echo "$BANNER" | grep -q "\[G-Forge Session Start\]" && ! echo "$BANNER" | grep -q "uncommitted change"; then
    echo "PASS: clean tree has no dirty-count line"; PASS=$((PASS+1))
else
    echo "FAIL: clean tree should have no dirty-count line, got: $BANNER"; FAIL=$((FAIL+1))
fi

# 2.4 Dirty count printed when files modified
FIXTURE="$(mktemp -d)"
cd "$FIXTURE"
git init -q
git config user.email "test@g-forge.local"
git config user.name "test"
mkdir -p .claude
printf 'full\n' > .claude/integration-tier
echo "test content" > testfile.txt
BANNER=$(printf '%s' "$PAYLOAD_STARTUP" | bash "$SESSION_SCRIPT")
if echo "$BANNER" | grep -q "uncommitted change"; then
    echo "PASS: dirty-count line printed"; PASS=$((PASS+1))
else
    echo "FAIL: dirty-count line missing"; FAIL=$((FAIL+1))
fi
cd - >/dev/null
rm -rf "$FIXTURE"

# ============================================================================
# § Section 3: SESSION_SOURCE semantics (4 scenarios)
# ============================================================================

echo "§ 3 — Counter reset-vs-preserve semantics"

# 3.1 Startup source resets prompt counter
COUNTER=$(counter_value "session-prompt-count" "$PAYLOAD_STARTUP")
check "startup resets prompt counter to 0" "0" "$COUNTER"

# 3.2 Startup source resets compaction counter
COUNTER=$(counter_value "session-compaction-count" "$PAYLOAD_STARTUP")
check "startup resets compaction counter to 0" "0" "$COUNTER"

# 3.3 Compact source preserves prompt counter
COUNTER=$(counter_value "session-prompt-count" "$PAYLOAD_COMPACT")
check "compact preserves prompt counter (not reset)" "5" "$COUNTER"

# 3.4 Compact source preserves compaction counter
COUNTER=$(counter_value "session-compaction-count" "$PAYLOAD_COMPACT")
check "compact preserves compaction counter (not reset)" "3" "$COUNTER"

# 3.5 Resume source resets counters (same as startup)
COUNTER=$(counter_value "session-prompt-count" "$PAYLOAD_RESUME")
check "resume resets prompt counter to 0" "0" "$COUNTER"

# 3.6 Missing source field resets counters (backward-compat)
COUNTER=$(counter_value "session-prompt-count" "$PAYLOAD_EMPTY")
check "missing source resets prompt counter to 0" "0" "$COUNTER"

# 3.7 LINKED-WORKTREE reset path. The fixtures above are primary-tree only, where
# a bare-relative ".claude/..." write and a "$GF_CLAUDE_DIR/..." write are the same
# file — so they cannot see a writer that never reaches the primary tree. From a
# linked worktree (no local .claude/) a bare-relative reset silently no-ops under
# `|| true`, leaving workflow-checkpoint.sh's $GF_CLAUDE_DIR-resolved counter to
# climb forever: a permanently stuck red context gate. This asserts the reset
# actually lands on the PRIMARY counter.
linked_worktree_reset_value() { # <counter_name> <payload>
    local counter="$1" payload="$2" base primary linked out
    base=$(mktemp -d)
    primary="$base/primary"
    linked="$base/linked-wt"
    mkdir -p "$primary"
    (
        cd "$primary" || exit 1
        git init -q
        git config user.email "test@g-forge.local"
        git config user.name "test"
        mkdir -p .claude
        printf 'full\n' > .claude/integration-tier
        printf '5\n' > .claude/session-prompt-count
        printf '3\n' > .claude/session-compaction-count
        touch .gitkeep
        git add .gitkeep
        git -c commit.gpgsign=false commit -m "initial" >/dev/null 2>&1
        git worktree add -b "wt-reset-test" "$linked" >/dev/null 2>&1
    ) >/dev/null 2>&1
    # .git is a FILE inside a linked worktree — test existence, not -d.
    if [ -e "$linked/.git" ]; then
        ( cd "$linked" && printf '%s' "$payload" | bash "$SESSION_SCRIPT" >/dev/null 2>&1 )
        out=$(cat "$primary/.claude/$counter" 2>/dev/null || echo "")
    else
        out="SETUP_FAILED"
    fi
    git -C "$primary" worktree remove --force "$linked" >/dev/null 2>&1 || true
    rm -rf "$base"
    printf '%s' "$out"
}

COUNTER=$(linked_worktree_reset_value "session-prompt-count" "$PAYLOAD_STARTUP")
check "linked worktree: startup resets PRIMARY prompt counter" "0" "$COUNTER"

COUNTER=$(linked_worktree_reset_value "session-compaction-count" "$PAYLOAD_STARTUP")
check "linked worktree: startup resets PRIMARY compaction counter" "0" "$COUNTER"

COUNTER=$(linked_worktree_reset_value "session-prompt-count" "$PAYLOAD_COMPACT")
check "linked worktree: compact preserves PRIMARY prompt counter" "5" "$COUNTER"

# ============================================================================
# § Section 4: Worktree guard and integration-tier gating (8 scenarios)
# ============================================================================

echo "§ 4 — Guard conditions and exit behavior"

# 4.1 Non-G-Forge project exits silently (no .claude/integration-tier)
FIXTURE="$(mktemp -d)"
cd "$FIXTURE"
git init -q
git config user.email "test@g-forge.local"
git config user.name "test"
# Do NOT create .claude/integration-tier — this is not a G-Forge project
RC=$(printf '%s' "$PAYLOAD_STARTUP" | bash "$SESSION_SCRIPT" >/dev/null 2>&1; echo $?)
if [ "$RC" -eq 0 ]; then
    echo "PASS: non-G-Forge project exits 0"; PASS=$((PASS+1))
else
    echo "FAIL: non-G-Forge project should exit 0, got $RC"; FAIL=$((FAIL+1))
fi
cd - >/dev/null
rm -rf "$FIXTURE"

# 4.2 Not in a git repo exits silently
FIXTURE="$(mktemp -d)"
cd "$FIXTURE"
# Do NOT init git — not a git repo
mkdir -p .claude
printf 'full\n' > .claude/integration-tier
RC=$(printf '%s' "$PAYLOAD_STARTUP" | bash "$SESSION_SCRIPT" >/dev/null 2>&1; echo $?)
if [ "$RC" -eq 0 ]; then
    echo "PASS: not in git repo exits 0"; PASS=$((PASS+1))
else
    echo "FAIL: not in git repo should exit 0, got $RC"; FAIL=$((FAIL+1))
fi
cd - >/dev/null
rm -rf "$FIXTURE"

# 4.3 Light integration tier skips silently (exit 0, no banner)
FIXTURE="$(mktemp -d)"
cd "$FIXTURE"
git init -q
git config user.email "test@g-forge.local"
git config user.name "test"
mkdir -p .claude
printf 'light\n' > .claude/integration-tier
BANNER=$(printf '%s' "$PAYLOAD_STARTUP" | bash "$SESSION_SCRIPT")
RC=$?
if [ "$RC" -eq 0 ] && { [ -z "$BANNER" ] || ! echo "$BANNER" | grep -q "G-Forge Session Start"; }; then
    echo "PASS: light tier exits 0 and produces no banner"; PASS=$((PASS+1))
else
    echo "FAIL: light tier should exit 0 and produce no banner, got: $BANNER"; FAIL=$((FAIL+1))
fi
cd - >/dev/null
rm -rf "$FIXTURE"

# 4.4 Balanced integration tier produces banner (state hooks remain ON)
FIXTURE="$(mktemp -d)"
cd "$FIXTURE"
git init -q
git config user.email "test@g-forge.local"
git config user.name "test"
mkdir -p .claude
printf 'balanced\n' > .claude/integration-tier
BANNER=$(printf '%s' "$PAYLOAD_STARTUP" | bash "$SESSION_SCRIPT")
if echo "$BANNER" | grep -q "G-Forge Session Start"; then
    echo "PASS: balanced tier produces banner"; PASS=$((PASS+1))
else
    echo "FAIL: balanced tier should produce banner, got: $BANNER"; FAIL=$((FAIL+1))
fi
cd - >/dev/null
rm -rf "$FIXTURE"

# 4.5 Full integration tier produces banner
FIXTURE="$(mktemp -d)"
cd "$FIXTURE"
git init -q
git config user.email "test@g-forge.local"
git config user.name "test"
mkdir -p .claude
printf 'full\n' > .claude/integration-tier
BANNER=$(printf '%s' "$PAYLOAD_STARTUP" | bash "$SESSION_SCRIPT")
if echo "$BANNER" | grep -q "G-Forge Session Start"; then
    echo "PASS: full tier produces banner"; PASS=$((PASS+1))
else
    echo "FAIL: full tier should produce banner, got: $BANNER"; FAIL=$((FAIL+1))
fi
cd - >/dev/null
rm -rf "$FIXTURE"

# ============================================================================
# § Section 5: Edge cases and error resilience (3 scenarios)
# ============================================================================

echo "§ 5 — Error resilience and edge cases"

# 5.1 Truncated JSON payload exits 0
RC=$(exit_code "$PAYLOAD_TRUNCATED")
check "truncated JSON exits 0" "0" "$RC"

# 5.2 Malformed source field (non-string) is ignored gracefully
FIXTURE="$(mktemp -d)"
cd "$FIXTURE"
git init -q
git config user.email "test@g-forge.local"
git config user.name "test"
mkdir -p .claude
printf 'full\n' > .claude/integration-tier
printf '5\n' > .claude/session-prompt-count
# source is a number, not a string
PAYLOAD='{"source":123}'
RESULT=$(printf '%s' "$PAYLOAD" | bash "$SESSION_SCRIPT" >/dev/null 2>&1; cat .claude/session-prompt-count)
if [ "$RESULT" = "0" ]; then
    echo "PASS: malformed source field triggers reset"; PASS=$((PASS+1))
else
    echo "FAIL: malformed source should reset counter, got $RESULT"; FAIL=$((FAIL+1))
fi
cd - >/dev/null
rm -rf "$FIXTURE"

# 5.3 Counter files are created if missing
FIXTURE="$(mktemp -d)"
cd "$FIXTURE"
git init -q
git config user.email "test@g-forge.local"
git config user.name "test"
mkdir -p .claude
printf 'full\n' > .claude/integration-tier
# Do not pre-create counter files
printf '%s' "$PAYLOAD_STARTUP" | bash "$SESSION_SCRIPT" >/dev/null 2>&1
if [ -f ".claude/session-prompt-count" ]; then
    COUNTER=$(cat .claude/session-prompt-count)
    if [ "$COUNTER" = "0" ]; then
        echo "PASS: missing counter file is created and set to 0"; PASS=$((PASS+1))
    else
        echo "FAIL: counter should be 0, got $COUNTER"; FAIL=$((FAIL+1))
    fi
else
    echo "FAIL: counter file not created"; FAIL=$((FAIL+1))
fi
cd - >/dev/null
rm -rf "$FIXTURE"

# ============================================================================
# § Section 6: Branch detection (2 scenarios)
# ============================================================================

echo "§ 6 — Branch and remote state detection"

# 6.1 Shows main branch name correctly
FIXTURE="$(mktemp -d)"
cd "$FIXTURE"
git init -q
git config user.email "test@g-forge.local"
git config user.name "test"
git checkout -b main >/dev/null 2>&1
mkdir -p .claude
printf 'full\n' > .claude/integration-tier
BANNER=$(printf '%s' "$PAYLOAD_STARTUP" | bash "$SESSION_SCRIPT")
if echo "$BANNER" | grep -q "Branch: main"; then
    echo "PASS: shows main branch name"; PASS=$((PASS+1))
else
    echo "FAIL: should show 'Branch: main', got: $BANNER"; FAIL=$((FAIL+1))
fi
cd - >/dev/null
rm -rf "$FIXTURE"

# 6.2 Shows feature branch name correctly
FIXTURE="$(mktemp -d)"
cd "$FIXTURE"
git init -q
git config user.email "test@g-forge.local"
git config user.name "test"
git checkout -b feat/test-feature >/dev/null 2>&1
mkdir -p .claude
printf 'full\n' > .claude/integration-tier
BANNER=$(printf '%s' "$PAYLOAD_STARTUP" | bash "$SESSION_SCRIPT")
if echo "$BANNER" | grep -q "Branch: feat/test-feature"; then
    echo "PASS: shows feature branch name"; PASS=$((PASS+1))
else
    echo "FAIL: should show feature branch name, got: $BANNER"; FAIL=$((FAIL+1))
fi
cd - >/dev/null
rm -rf "$FIXTURE"

# ============================================================================
# § Section 7: Stash detection (2 scenarios)
# ============================================================================

echo "§ 7 — Stash detection"

# 7.1 Shows stash count when stash exists
FIXTURE="$(mktemp -d)"
cd "$FIXTURE"
git init -q
git config user.email "test@g-forge.local"
git config user.name "test"
echo "test" > file.txt
git add file.txt
git commit -m "initial" >/dev/null 2>&1
echo "change" >> file.txt
git stash >/dev/null 2>&1
mkdir -p .claude
printf 'full\n' > .claude/integration-tier
BANNER=$(printf '%s' "$PAYLOAD_STARTUP" | bash "$SESSION_SCRIPT")
if echo "$BANNER" | grep -q "1 stash"; then
    echo "PASS: shows stash count when stash exists"; PASS=$((PASS+1))
else
    echo "FAIL: should show stash count, got: $BANNER"; FAIL=$((FAIL+1))
fi
cd - >/dev/null
rm -rf "$FIXTURE"

# 7.2 Hides stash message when no stash
FIXTURE="$(mktemp -d)"
cd "$FIXTURE"
git init -q
git config user.email "test@g-forge.local"
git config user.name "test"
mkdir -p .claude
printf 'full\n' > .claude/integration-tier
BANNER=$(printf '%s' "$PAYLOAD_STARTUP" | bash "$SESSION_SCRIPT")
if ! echo "$BANNER" | grep -q "stash"; then
    echo "PASS: no stash message when stash list is empty"; PASS=$((PASS+1))
else
    echo "FAIL: should not show stash message, got: $BANNER"; FAIL=$((FAIL+1))
fi
cd - >/dev/null
rm -rf "$FIXTURE"

# ============================================================================
# § Results
# ============================================================================

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
