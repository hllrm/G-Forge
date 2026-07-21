#!/bin/bash
# test-pre-compact.sh — PreCompact hook behavioral suite
# Verifies: compaction-count increment, context-threshold-offset calibration,
# compact-state.md content, worktree guard, non-gating exit contract.
# Resolve script dir / hooks dir to ABSOLUTE paths exactly once, before any
# fixture cd (invocation-form-insensitive per ADR-008 W1.5g).
#
# Total assertions: 22
# - Exit-code contract (non-gating): 4 tests (valid project, empty, malformed, non-G-Forge)
# - Compaction-count increment: 4 tests (absent, 0→1, 5→6, garbage→1)
# - Context-threshold-offset calibration: 4 tests (absent, 0→5, 10→15, 28→30 capped)
# - Compact-state.md creation and content: 8 tests (exists, has branch, commits, handoff, fallback, timestamp)
# - Worktree guard: 2 tests (primary tree activation, linked worktree resolution)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$(cd "$SCRIPT_DIR/../hooks" && pwd)"

PASS=0
FAIL=0

# ============================================================================
# § Helper functions
# ============================================================================

# create_fixture — create a minimal G-Forge project directory
create_fixture() {
    local dir
    dir=$(mktemp -d) || return 1
    (
        cd "$dir" || exit 1
        git init -q 2>/dev/null
        git config user.email "test@g-forge.local" 2>/dev/null
        git config user.name "test" 2>/dev/null
        mkdir -p .claude
        printf 'full\n' > .claude/integration-tier
    )
    printf '%s\n' "$dir"
}

# check_value <name> <expected> <actual> — assert equality
check_value() {
    local name="$1" expected="$2" actual="$3"
    if [ "$expected" = "$actual" ]; then
        echo "PASS: $name"; PASS=$((PASS+1))
    else
        echo "FAIL: $name (expected '$expected', got '$actual')"; FAIL=$((FAIL+1))
    fi
}

# check_contains <name> <haystack> <needle> — assert substring match
check_contains() {
    local name="$1" haystack="$2" needle="$3"
    if printf '%s' "$haystack" | grep -q "$(printf '%s\n' "$needle" | sed 's/[[\.*^$/]/\\&/g')"; then
        echo "PASS: $name"; PASS=$((PASS+1))
    else
        echo "FAIL: $name (expected to contain '$needle', got '$haystack')"; FAIL=$((FAIL+1))
    fi
}

# check_file_exists <name> <path> — assert file exists
check_file_exists() {
    local name="$1" path="$2"
    if [ -f "$path" ]; then
        echo "PASS: $name"; PASS=$((PASS+1))
    else
        echo "FAIL: $name (file not found: $path)"; FAIL=$((FAIL+1))
    fi
}

# check_file_missing <name> <path> — assert file does not exist
check_file_missing() {
    local name="$1" path="$2"
    if [ ! -f "$path" ]; then
        echo "PASS: $name"; PASS=$((PASS+1))
    else
        echo "FAIL: $name (file should not exist: $path)"; FAIL=$((FAIL+1))
    fi
}

# ============================================================================
# § 1. Exit-code contract — non-gating hook must exit 0 always
# ============================================================================

# Test 1a: Valid G-Forge project, standard run
FIXTURE=$(create_fixture)
(
    cd "$FIXTURE" || exit 1
    printf '{}' | bash "$HOOKS_DIR/pre-compact.sh" >/dev/null 2>&1
)
RC=$?
if [ "$RC" -eq 0 ]; then
    echo "PASS: exit 0 with valid G-Forge project"; PASS=$((PASS+1))
else
    echo "FAIL: exit 0 with valid G-Forge project (got $RC)"; FAIL=$((FAIL+1))
fi
rm -rf "$FIXTURE"

# Test 1b: Empty stdin (no payload)
FIXTURE=$(create_fixture)
(
    cd "$FIXTURE" || exit 1
    printf '' | bash "$HOOKS_DIR/pre-compact.sh" >/dev/null 2>&1
)
RC=$?
if [ "$RC" -eq 0 ]; then
    echo "PASS: exit 0 with empty stdin"; PASS=$((PASS+1))
else
    echo "FAIL: exit 0 with empty stdin (got $RC)"; FAIL=$((FAIL+1))
fi
rm -rf "$FIXTURE"

# Test 1c: Malformed JSON
FIXTURE=$(create_fixture)
(
    cd "$FIXTURE" || exit 1
    printf 'not json at all' | bash "$HOOKS_DIR/pre-compact.sh" >/dev/null 2>&1
)
RC=$?
if [ "$RC" -eq 0 ]; then
    echo "PASS: exit 0 with malformed JSON"; PASS=$((PASS+1))
else
    echo "FAIL: exit 0 with malformed JSON (got $RC)"; FAIL=$((FAIL+1))
fi
rm -rf "$FIXTURE"

# Test 1d: Non-G-Forge project (no .claude/integration-tier) — still exit 0 (non-gating)
FIXTURE=$(mktemp -d)
(
    cd "$FIXTURE" || exit 1
    git init -q 2>/dev/null
    git config user.email "test@g-forge.local" 2>/dev/null
    git config user.name "test" 2>/dev/null
    # No .claude/ directory
    printf '{}' | bash "$HOOKS_DIR/pre-compact.sh" >/dev/null 2>&1
)
RC=$?
if [ "$RC" -eq 0 ]; then
    echo "PASS: exit 0 for non-G-Forge project (non-gating)"; PASS=$((PASS+1))
else
    echo "FAIL: exit 0 for non-G-Forge project (got $RC)"; FAIL=$((FAIL+1))
fi
rm -rf "$FIXTURE"

# ============================================================================
# § 2. Compaction-count increment (session-compaction-count)
# ============================================================================

# Test 2a: Initial state (no file) → count is 1
FIXTURE=$(create_fixture)
(
    cd "$FIXTURE" || exit 1
    bash "$HOOKS_DIR/pre-compact.sh" >/dev/null 2>&1
)
COUNT=$(cat "$FIXTURE/.claude/session-compaction-count" 2>/dev/null)
check_value "initial compaction count is 1" "1" "$COUNT"
rm -rf "$FIXTURE"

# Test 2b: Existing count 0 → count is 1
FIXTURE=$(create_fixture)
(
    cd "$FIXTURE" || exit 1
    printf '0' > .claude/session-compaction-count
    bash "$HOOKS_DIR/pre-compact.sh" >/dev/null 2>&1
)
COUNT=$(cat "$FIXTURE/.claude/session-compaction-count" 2>/dev/null)
check_value "compaction count 0 → 1" "1" "$COUNT"
rm -rf "$FIXTURE"

# Test 2c: Existing count 5 → count is 6
FIXTURE=$(create_fixture)
(
    cd "$FIXTURE" || exit 1
    printf '5' > .claude/session-compaction-count
    bash "$HOOKS_DIR/pre-compact.sh" >/dev/null 2>&1
)
COUNT=$(cat "$FIXTURE/.claude/session-compaction-count" 2>/dev/null)
check_value "compaction count 5 → 6" "6" "$COUNT"
rm -rf "$FIXTURE"

# Test 2d: Non-numeric garbage in file → treated as 0, incremented to 1
FIXTURE=$(create_fixture)
(
    cd "$FIXTURE" || exit 1
    printf 'garbage' > .claude/session-compaction-count
    bash "$HOOKS_DIR/pre-compact.sh" >/dev/null 2>&1
)
COUNT=$(cat "$FIXTURE/.claude/session-compaction-count" 2>/dev/null)
check_value "non-numeric count → sanitized to 1" "1" "$COUNT"
rm -rf "$FIXTURE"

# ============================================================================
# § 3. Context-threshold-offset calibration (context-threshold-offset)
# ============================================================================

# Test 3a: Initial state (no file) → offset is 5
FIXTURE=$(create_fixture)
(
    cd "$FIXTURE" || exit 1
    bash "$HOOKS_DIR/pre-compact.sh" >/dev/null 2>&1
)
OFFSET=$(cat "$FIXTURE/.claude/context-threshold-offset" 2>/dev/null)
check_value "initial offset is 5" "5" "$OFFSET"
rm -rf "$FIXTURE"

# Test 3b: Existing offset 0 → offset is 5
FIXTURE=$(create_fixture)
(
    cd "$FIXTURE" || exit 1
    printf '0' > .claude/context-threshold-offset
    bash "$HOOKS_DIR/pre-compact.sh" >/dev/null 2>&1
)
OFFSET=$(cat "$FIXTURE/.claude/context-threshold-offset" 2>/dev/null)
check_value "offset 0 → 5" "5" "$OFFSET"
rm -rf "$FIXTURE"

# Test 3c: Existing offset 10 → offset is 15
FIXTURE=$(create_fixture)
(
    cd "$FIXTURE" || exit 1
    printf '10' > .claude/context-threshold-offset
    bash "$HOOKS_DIR/pre-compact.sh" >/dev/null 2>&1
)
OFFSET=$(cat "$FIXTURE/.claude/context-threshold-offset" 2>/dev/null)
check_value "offset 10 → 15" "15" "$OFFSET"
rm -rf "$FIXTURE"

# Test 3d: Existing offset 28 → offset is capped at 30
FIXTURE=$(create_fixture)
(
    cd "$FIXTURE" || exit 1
    printf '28' > .claude/context-threshold-offset
    bash "$HOOKS_DIR/pre-compact.sh" >/dev/null 2>&1
)
OFFSET=$(cat "$FIXTURE/.claude/context-threshold-offset" 2>/dev/null)
check_value "offset 28 → 30 (capped)" "30" "$OFFSET"
rm -rf "$FIXTURE"

# ============================================================================
# § 4. Compact-state.md creation and content
# ============================================================================

# Test 4a: File is created
FIXTURE=$(create_fixture)
(
    cd "$FIXTURE" || exit 1
    bash "$HOOKS_DIR/pre-compact.sh" >/dev/null 2>&1
)
check_file_exists "compact-state.md is created" "$FIXTURE/.claude/compact-state.md"
rm -rf "$FIXTURE"

# Test 4b: File contains branch information
FIXTURE=$(create_fixture)
(
    cd "$FIXTURE" || exit 1
    git checkout -b test-branch 2>/dev/null
    bash "$HOOKS_DIR/pre-compact.sh" >/dev/null 2>&1
)
CONTENT=$(cat "$FIXTURE/.claude/compact-state.md" 2>/dev/null)
check_contains "compact-state.md contains ## Branch header" "$CONTENT" "## Branch"
rm -rf "$FIXTURE"

# Test 4c: File contains recent commits section
FIXTURE=$(create_fixture)
(
    cd "$FIXTURE" || exit 1
    echo "test" > file.txt
    git add file.txt
    git commit -m "test commit" >/dev/null 2>&1
    bash "$HOOKS_DIR/pre-compact.sh" >/dev/null 2>&1
)
CONTENT=$(cat "$FIXTURE/.claude/compact-state.md" 2>/dev/null)
check_contains "compact-state.md contains ## Recent commits header" "$CONTENT" "## Recent commits"
rm -rf "$FIXTURE"

# Test 4d: File contains handoff section header
FIXTURE=$(create_fixture)
(
    cd "$FIXTURE" || exit 1
    bash "$HOOKS_DIR/pre-compact.sh" >/dev/null 2>&1
)
CONTENT=$(cat "$FIXTURE/.claude/compact-state.md" 2>/dev/null)
check_contains "compact-state.md contains ## Handoff at compaction" "$CONTENT" "## Handoff at compaction"
rm -rf "$FIXTURE"

# Test 4e: File contains timestamp
FIXTURE=$(create_fixture)
(
    cd "$FIXTURE" || exit 1
    bash "$HOOKS_DIR/pre-compact.sh" >/dev/null 2>&1
)
CONTENT=$(cat "$FIXTURE/.claude/compact-state.md" 2>/dev/null)
check_contains "compact-state.md contains Compact State header with timestamp" "$CONTENT" "# Compact State —"
rm -rf "$FIXTURE"

# Test 4f: Handoff captured when g-docs/ROADMAP.md with ## Active Session exists
FIXTURE=$(create_fixture)
(
    cd "$FIXTURE" || exit 1
    mkdir -p g-docs
    cat > g-docs/ROADMAP.md << 'EOF'
# Roadmap

## Active Session

Done this pass: · task 1
Next up: · task 2

## Next Milestone

Some other content.
EOF
    bash "$HOOKS_DIR/pre-compact.sh" >/dev/null 2>&1
)
CONTENT=$(cat "$FIXTURE/.claude/compact-state.md" 2>/dev/null)
check_contains "handoff content captured from ROADMAP.md" "$CONTENT" "Done this pass"
rm -rf "$FIXTURE"

# Test 4g: Fallback message when g-docs/ROADMAP.md missing
FIXTURE=$(create_fixture)
(
    cd "$FIXTURE" || exit 1
    bash "$HOOKS_DIR/pre-compact.sh" >/dev/null 2>&1
)
CONTENT=$(cat "$FIXTURE/.claude/compact-state.md" 2>/dev/null)
check_contains "fallback message when ROADMAP.md missing" "$CONTENT" "not found"
rm -rf "$FIXTURE"

# Test 4h: Fallback message when ## Active Session not found
FIXTURE=$(create_fixture)
(
    cd "$FIXTURE" || exit 1
    mkdir -p g-docs
    printf '# Roadmap\n\n## Some Other Section\n' > g-docs/ROADMAP.md
    bash "$HOOKS_DIR/pre-compact.sh" >/dev/null 2>&1
)
CONTENT=$(cat "$FIXTURE/.claude/compact-state.md" 2>/dev/null)
check_contains "fallback when Active Session missing" "$CONTENT" "No '## Active Session' handoff found"
rm -rf "$FIXTURE"

# ============================================================================
# § 5. Worktree guard — primary tree activation (simplified; full linked
#       worktree testing requires git worktree setup, verified by
#       tests/test-worktree-resolve.sh)
# ============================================================================

# Test 5a: Primary tree with local .claude/integration-tier activates hook
FIXTURE=$(create_fixture)
(
    cd "$FIXTURE" || exit 1
    # Remove to verify re-creation by hook
    rm -f .claude/session-compaction-count .claude/context-threshold-offset
    bash "$HOOKS_DIR/pre-compact.sh" >/dev/null 2>&1
)
if [ -f "$FIXTURE/.claude/session-compaction-count" ] && [ -f "$FIXTURE/.claude/context-threshold-offset" ]; then
    echo "PASS: primary tree activation creates state files"; PASS=$((PASS+1))
else
    echo "FAIL: primary tree activation should create state files"; FAIL=$((FAIL+1))
fi
rm -rf "$FIXTURE"

# Test 5b: Non-G-Forge tree (no .claude/integration-tier) does NOT create state files
FIXTURE=$(mktemp -d)
(
    cd "$FIXTURE" || exit 1
    git init -q 2>/dev/null
    git config user.email "test@g-forge.local" 2>/dev/null
    git config user.name "test" 2>/dev/null
    bash "$HOOKS_DIR/pre-compact.sh" >/dev/null 2>&1
)
if [ ! -f "$FIXTURE/.claude/session-compaction-count" ]; then
    echo "PASS: non-G-Forge tree does not create state files"; PASS=$((PASS+1))
else
    echo "FAIL: non-G-Forge tree should not create state files"; FAIL=$((FAIL+1))
fi
rm -rf "$FIXTURE"

# ============================================================================
# § Cleanup and results
# ============================================================================

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
