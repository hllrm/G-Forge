#!/bin/bash
# Unit tests for hooks/lib/worktree-resolve.sh
# Tests the worktree resolution helper functions across git configurations.
# Encodes HQ-verified ground-truth behavior (2026-07-18, git-bash 5.2.37).

LIB="$(cd "$(dirname "$0")" && pwd)/../hooks/lib/worktree-resolve.sh"
source "$LIB" || { echo "FAIL: could not source $LIB"; exit 1; }

# Root directory to return to after every per-fixture cd. Captured before any
# cd happens so the parent shell always has a known-good place to land.
SUITE_ROOT="$(pwd)"

PASS=0
FAIL=0

# Sandbox setup
SANDBOX=""
cleanup_trap() {
    if [ -n "$SANDBOX" ] && [ -d "$SANDBOX" ]; then
        # Clean up worktrees before removing dir
        for repo_dir in "$SANDBOX"/*; do
            if [ -d "$repo_dir" ] && [ -d "$repo_dir/.git" ]; then
                (
                    cd "$repo_dir" 2>/dev/null || true
                    git worktree list --porcelain 2>/dev/null | while read line; do
                        case "$line" in
                            worktree\ *)
                                wt_path="${line#worktree }"
                                git worktree remove --force "$wt_path" 2>/dev/null || true
                                ;;
                        esac
                    done
                ) || true
            fi
        done
        rm -rf "$SANDBOX"
    fi
}
trap cleanup_trap EXIT

# Create sandbox
SANDBOX=$(mktemp -d 2>/dev/null) || SANDBOX="${TMPDIR:-/tmp}/gf-test-worktree-$$"
[ -d "$SANDBOX" ] || { echo "FAIL: could not create sandbox"; exit 1; }

# Helper: create a primary repo with initial commit
create_primary_repo() {
    local repo_path="$1"
    mkdir -p "$repo_path" || return 1
    (
        cd "$repo_path"
        git init
        git config user.email "test@g-forge.test"
        git config user.name "Test"
        touch .gitkeep
        git add .gitkeep
        git -c commit.gpgsign=false commit -m "initial"
    ) || return 1
}

# Helper: create a linked worktree with explicit branch name
create_linked_worktree() {
    local primary_repo="$1"
    local wt_path="$2"
    local branch_name="${3:-wt-branch}"
    (
        cd "$primary_repo"
        git worktree add -b "$branch_name" "$wt_path" || return 1
    ) || return 1
}

# Helper: assert function return code
assert_rc() {
    local expected_rc="$1" actual_rc="$2" test_name="$3"
    if [ "$actual_rc" -eq "$expected_rc" ]; then
        echo "PASS: $test_name"
        PASS=$((PASS+1))
    else
        echo "FAIL: $test_name (expected rc=$expected_rc, got rc=$actual_rc)"
        FAIL=$((FAIL+1))
    fi
}

# Helper: assert stdout ends with suffix
assert_stdout_suffix() {
    local stdout="$1" suffix="$2" test_name="$3"
    case "$stdout" in
        *"$suffix")
            echo "PASS: $test_name"
            PASS=$((PASS+1))
            ;;
        *)
            echo "FAIL: $test_name (expected suffix '$suffix', got: $(printf '%q' "$stdout"))"
            FAIL=$((FAIL+1))
            ;;
    esac
}

# Helper: assert stdout is empty
assert_stdout_empty() {
    local stdout="$1" test_name="$2"
    if [ -z "$stdout" ]; then
        echo "PASS: $test_name"
        PASS=$((PASS+1))
    else
        echo "FAIL: $test_name (expected empty stdout, got: $(printf '%q' "$stdout"))"
        FAIL=$((FAIL+1))
    fi
}

# Helper: cd into a fixture dir in the parent shell, recording a FAIL (rather
# than aborting the suite) if the fixture is missing. Callers MUST pair this
# with return_to_suite_root once their assertions are done, so cwd never
# leaks between test cases.
cd_fixture() {
    local dir="$1"
    cd "$dir" || { echo "FAIL: could not cd to $dir"; FAIL=$((FAIL+1)); return 1; }
}

# Helper: guaranteed return to the suite root after a fixture block.
return_to_suite_root() {
    cd "$SUITE_ROOT" || { echo "FAIL: could not cd back to $SUITE_ROOT"; FAIL=$((FAIL+1)); exit 1; }
}

# ── PRIMARY REPO TESTS ────────────────────────────────────────────────────────
echo ""
echo "=== PRIMARY REPOSITORY ==="

PRIMARY_REPO="$SANDBOX/primary-repo"
create_primary_repo "$PRIMARY_REPO" || { echo "FAIL: could not create primary repo"; exit 1; }

cd_fixture "$PRIMARY_REPO"

# Test: gf_resolve_primary_claude_dir in primary repo
output=$(gf_resolve_primary_claude_dir)
rc=$?
assert_rc 0 "$rc" "PRIMARY: gf_resolve_primary_claude_dir rc=0"
# Path should end with "/.claude" and contain "primary-repo"
# Note: exercises relative .git form (primary repo returns ".git" from git rev-parse --git-common-dir)
assert_stdout_suffix "$output" "primary-repo/.claude" "PRIMARY: gf_resolve_primary_claude_dir returns .claude path"

# Test: gf_worktree_key in primary repo
output=$(gf_worktree_key)
rc=$?
assert_rc 0 "$rc" "PRIMARY: gf_worktree_key rc=0"
assert_stdout_suffix "$output" "primary-repo" "PRIMARY: gf_worktree_key returns repo toplevel"

return_to_suite_root

# ── LINKED WORKTREE TESTS ─────────────────────────────────────────────────────
echo ""
echo "=== LINKED WORKTREE ==="

WT_PATH="$SANDBOX/wt-normal"
create_linked_worktree "$PRIMARY_REPO" "$WT_PATH" "wt-normal" || { echo "FAIL: could not create worktree"; exit 1; }

# Capture primary key once for comparison
PRIMARY_KEY=$(cd "$PRIMARY_REPO" && gf_worktree_key)

cd_fixture "$WT_PATH"

# Test: gf_resolve_primary_claude_dir in worktree should point to PRIMARY .claude
# Note: exercises absolute .git form (worktree returns C:/... or /... with absolute path)
output=$(gf_resolve_primary_claude_dir)
rc=$?
assert_rc 0 "$rc" "LINKED: gf_resolve_primary_claude_dir rc=0"
assert_stdout_suffix "$output" "primary-repo/.claude" "LINKED: gf_resolve_primary_claude_dir points to primary"

# Test: gf_worktree_key in worktree should return WORKTREE toplevel (distinct)
output=$(gf_worktree_key)
rc=$?
assert_rc 0 "$rc" "LINKED: gf_worktree_key rc=0"
assert_stdout_suffix "$output" "wt-normal" "LINKED: gf_worktree_key returns worktree toplevel"

# Verify distinctness: worktree key must differ from primary key
if [ "$output" != "$PRIMARY_KEY" ]; then
    echo "PASS: LINKED: gf_worktree_key distinct from primary"
    PASS=$((PASS+1))
else
    echo "FAIL: LINKED: gf_worktree_key not distinct from primary"
    FAIL=$((FAIL+1))
fi

return_to_suite_root

# ── SPACED PATH TESTS ─────────────────────────────────────────────────────────
echo ""
echo "=== SPACED PATHS ==="

SPACED_PRIMARY="$SANDBOX/primary repo"
create_primary_repo "$SPACED_PRIMARY" || { echo "FAIL: could not create spaced primary"; exit 1; }

cd_fixture "$SPACED_PRIMARY"

# Test: gf_resolve_primary_claude_dir in spaced primary (spaces preserved)
output=$(gf_resolve_primary_claude_dir)
rc=$?
assert_rc 0 "$rc" "SPACED-PRIMARY: gf_resolve_primary_claude_dir rc=0"
assert_stdout_suffix "$output" "primary repo/.claude" "SPACED-PRIMARY: path preserves spaces in .claude"

# Test: gf_worktree_key in spaced primary (spaces preserved)
output=$(gf_worktree_key)
rc=$?
assert_rc 0 "$rc" "SPACED-PRIMARY: gf_worktree_key rc=0"
assert_stdout_suffix "$output" "primary repo" "SPACED-PRIMARY: gf_worktree_key preserves spaces"

return_to_suite_root

# Create spaced worktree (must use -b flag for spaced path)
SPACED_WT="$SANDBOX/wt with space"
create_linked_worktree "$SPACED_PRIMARY" "$SPACED_WT" "wt-space" || { echo "FAIL: could not create spaced worktree"; exit 1; }

cd_fixture "$SPACED_WT"

# Test: gf_resolve_primary_claude_dir in spaced worktree (spaces preserved)
output=$(gf_resolve_primary_claude_dir)
rc=$?
assert_rc 0 "$rc" "SPACED-WT: gf_resolve_primary_claude_dir rc=0"
assert_stdout_suffix "$output" "primary repo/.claude" "SPACED-WT: resolve preserves spaces in primary path"

# Test: gf_worktree_key in spaced worktree (spaces preserved)
output=$(gf_worktree_key)
rc=$?
assert_rc 0 "$rc" "SPACED-WT: gf_worktree_key rc=0"
assert_stdout_suffix "$output" "wt with space" "SPACED-WT: key preserves spaces in worktree path"

return_to_suite_root

# ── SEPARATE-GIT-DIR TESTS ────────────────────────────────────────────────────
echo ""
echo "=== SEPARATE-GIT-DIR REPOSITORY ==="

SEPARATE_STORAGE="$SANDBOX/separate-git-storage"
SEPARATE_REPO="$SANDBOX/separate-repo"
mkdir -p "$SEPARATE_STORAGE" || { echo "FAIL: could not create separate storage dir"; exit 1; }
mkdir -p "$SEPARATE_REPO" || { echo "FAIL: could not create separate repo dir"; exit 1; }

(
    cd "$SEPARATE_REPO"
    git init --separate-git-dir "$SEPARATE_STORAGE"
    git config user.email "test@g-forge.test"
    git config user.name "Test"
    touch .gitkeep
    git add .gitkeep
    git -c commit.gpgsign=false commit -m "initial"
) || { echo "FAIL: could not create separate-git-dir repo"; exit 1; }

cd_fixture "$SEPARATE_REPO"

# Test: gf_resolve_primary_claude_dir should FAIL (rejection per ADR-005)
# Reason: git rev-parse --git-common-dir returns path NOT ending in .git
output=$(gf_resolve_primary_claude_dir)
rc=$?
assert_rc 1 "$rc" "SEPARATE-GIT-DIR: gf_resolve_primary_claude_dir rc=1 (rejection)"
assert_stdout_empty "$output" "SEPARATE-GIT-DIR: gf_resolve_primary_claude_dir empty stdout"

# Test: gf_worktree_key should SUCCEED (git rev-parse --show-toplevel works)
output=$(gf_worktree_key)
rc=$?
assert_rc 0 "$rc" "SEPARATE-GIT-DIR: gf_worktree_key rc=0"
assert_stdout_suffix "$output" "separate-repo" "SEPARATE-GIT-DIR: gf_worktree_key returns toplevel"

return_to_suite_root

# ── NON-GIT DIRECTORY TESTS ───────────────────────────────────────────────────
echo ""
echo "=== NON-GIT DIRECTORY ==="

NON_GIT_DIR="$SANDBOX/plain-dir"
mkdir -p "$NON_GIT_DIR" || { echo "FAIL: could not create plain dir"; exit 1; }

cd_fixture "$NON_GIT_DIR"

# Test: gf_resolve_primary_claude_dir should FAIL
output=$(gf_resolve_primary_claude_dir)
rc=$?
assert_rc 1 "$rc" "NON-GIT: gf_resolve_primary_claude_dir rc=1"
assert_stdout_empty "$output" "NON-GIT: gf_resolve_primary_claude_dir empty stdout"

# Test: gf_worktree_key should FAIL
output=$(gf_worktree_key)
rc=$?
assert_rc 1 "$rc" "NON-GIT: gf_worktree_key rc=1"
assert_stdout_empty "$output" "NON-GIT: gf_worktree_key empty stdout"

return_to_suite_root

# ── SUMMARY ───────────────────────────────────────────────────────────────────
echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
