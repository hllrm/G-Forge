#!/bin/bash
# Unit tests for hooks/lib/worktree-resolve.sh
# Tests the worktree resolution helper functions across git configurations.
# Encodes HQ-verified ground-truth behavior (2026-07-18, git-bash 5.2.37).
# Extended W1.5f Task 5+6: gf_guard_claude_dir() unit tests (5 scenarios, 10
# assertions) + conformance invariant checks (7 assertions: loop-per-file
# guard-line presence + zero occurrences of retired tokens).
# Total: 42 assertions (25 original + 10 from Task 5 + 7 from Task 6).

SUITE_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SUITE_DIR/.." && pwd)"

LIB="$REPO_ROOT/hooks/lib/worktree-resolve.sh"
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

# ── GF_GUARD_CLAUDE_DIR TESTS (Task 5) ────────────────────────────────────────
echo ""
echo "=== GF_GUARD_CLAUDE_DIR (local-first-else-primary guard) ==="

# Test 1: Local .claude/integration-tier present → prints ".claude", rc 0
# Setup: primary repo with local integration-tier file
LOCAL_GATED_REPO="$SANDBOX/local-gated-repo"
create_primary_repo "$LOCAL_GATED_REPO" || { echo "FAIL: could not create local-gated repo"; exit 1; }
mkdir -p "$LOCAL_GATED_REPO/.claude" || { echo "FAIL: could not create .claude dir"; exit 1; }
touch "$LOCAL_GATED_REPO/.claude/integration-tier" || { echo "FAIL: could not create integration-tier"; exit 1; }

cd_fixture "$LOCAL_GATED_REPO"
output=$(gf_guard_claude_dir)
rc=$?
assert_rc 0 "$rc" "GUARD: local integration-tier present returns rc=0"
assert_stdout_suffix "$output" ".claude" "GUARD: local integration-tier returns .claude"
return_to_suite_root

# Test 2: Linked worktree, primary IS gated (has integration-tier)
# Setup: primary with .claude/integration-tier, linked worktree (no local .claude)
PRIMARY_GATED_REPO="$SANDBOX/primary-gated-repo"
create_primary_repo "$PRIMARY_GATED_REPO" || { echo "FAIL: could not create primary-gated"; exit 1; }
mkdir -p "$PRIMARY_GATED_REPO/.claude" || { echo "FAIL: could not create .claude"; exit 1; }
touch "$PRIMARY_GATED_REPO/.claude/integration-tier" || { echo "FAIL: could not create integration-tier"; exit 1; }

WT_GATED="$SANDBOX/wt-of-gated-primary"
create_linked_worktree "$PRIMARY_GATED_REPO" "$WT_GATED" "wt-gated" || { echo "FAIL: could not create worktree"; exit 1; }

cd_fixture "$WT_GATED"
output=$(gf_guard_claude_dir)
rc=$?
assert_rc 0 "$rc" "GUARD: linked worktree of gated primary returns rc=0"
assert_stdout_suffix "$output" "primary-gated-repo/.claude" "GUARD: linked worktree returns primary .claude path"
return_to_suite_root

# Test 3: Linked worktree, primary is NOT gated (no integration-tier)
# Setup: primary without .claude/integration-tier, linked worktree (no local)
PRIMARY_UNGATED_REPO="$SANDBOX/primary-ungated-repo"
create_primary_repo "$PRIMARY_UNGATED_REPO" || { echo "FAIL: could not create primary-ungated"; exit 1; }
# Deliberately do NOT create .claude/integration-tier in primary

WT_UNGATED="$SANDBOX/wt-of-ungated-primary"
create_linked_worktree "$PRIMARY_UNGATED_REPO" "$WT_UNGATED" "wt-ungated" || { echo "FAIL: could not create worktree"; exit 1; }

cd_fixture "$WT_UNGATED"
output=$(gf_guard_claude_dir)
rc=$?
assert_rc 1 "$rc" "GUARD: linked worktree of ungated primary returns rc=1"
assert_stdout_empty "$output" "GUARD: linked worktree of ungated primary returns empty stdout"
return_to_suite_root

# Test 4: Non-git directory → resolution failure, rc 1, empty stdout
NON_GIT_GUARD="$SANDBOX/plain-dir-for-guard"
mkdir -p "$NON_GIT_GUARD" || { echo "FAIL: could not create plain dir"; exit 1; }

cd_fixture "$NON_GIT_GUARD"
output=$(gf_guard_claude_dir)
rc=$?
assert_rc 1 "$rc" "GUARD: non-git directory returns rc=1"
assert_stdout_empty "$output" "GUARD: non-git directory returns empty stdout"
return_to_suite_root

# Test 5: Separate-git-dir repository → resolution failure (rejection per ADR-005),
# rc 1, empty stdout (gf_resolve_primary_claude_dir rejects ambiguous configs)
SEP_STORAGE="$SANDBOX/sep-storage"
SEP_REPO="$SANDBOX/sep-git-dir-repo"
mkdir -p "$SEP_STORAGE" || { echo "FAIL: could not create sep storage"; exit 1; }
mkdir -p "$SEP_REPO" || { echo "FAIL: could not create sep repo"; exit 1; }

(
    cd "$SEP_REPO"
    git init --separate-git-dir "$SEP_STORAGE"
    git config user.email "test@g-forge.test"
    git config user.name "Test"
    touch .gitkeep
    git add .gitkeep
    git -c commit.gpgsign=false commit -m "initial"
) || { echo "FAIL: could not create separate-git-dir repo"; exit 1; }

cd_fixture "$SEP_REPO"
output=$(gf_guard_claude_dir)
rc=$?
assert_rc 1 "$rc" "GUARD: separate-git-dir repository returns rc=1"
assert_stdout_empty "$output" "GUARD: separate-git-dir repository returns empty stdout"
return_to_suite_root

# ── TASK 6: CONFORMANCE INVARIANT CHECKS (guard-idiom) ───────────────────────
echo ""
echo "── Task 6: Guard-idiom conformance invariant checks ────────────────────────"

# Task 6a: The literal canonical guard line MUST appear EXACTLY ONCE in each of
# the six W1.3 hooks (post-commit-cleanup.sh, observe.sh, pre-compact.sh,
# session-start.sh, workflow-checkpoint.sh, agent-lifecycle.sh).
# Loop structure mirrors test-classify-changeset.sh per-file assertions.

GUARD_HOOKS=("post-commit-cleanup.sh" "observe.sh" "pre-compact.sh" "session-start.sh" "workflow-checkpoint.sh" "agent-lifecycle.sh")
GUARD_LINE='GF_CLAUDE_DIR=$(gf_guard_claude_dir) || exit 0'

for hook_name in "${GUARD_HOOKS[@]}"; do
    hook_path="$REPO_ROOT/hooks/$hook_name"
    if [ ! -f "$hook_path" ]; then
        echo "FAIL: Task 6a — hooks/$hook_name missing"
        FAIL=$((FAIL+1))
        continue
    fi

    # Count occurrences of the exact guard line
    count=$(grep -F "$GUARD_LINE" "$hook_path" 2>/dev/null | wc -l)
    if [ "$count" -eq 1 ]; then
        echo "PASS: Task 6a — $hook_name has guard line exactly once"
        PASS=$((PASS+1))
    else
        echo "FAIL: Task 6a — $hook_name has guard line $count times (expected 1)"
        FAIL=$((FAIL+1))
    fi
done

# Task 6b: Zero occurrences of retired tokens in non-gating hooks. The retired
# tokens represent old inline implementations that should have been replaced by
# gf_guard_claude_dir(). Excludes hooks/lib/ (where gf_guard_claude_dir lives)
# and the W1.2 gating hooks check-commit.sh + pre-commit (fail-toward-deny
# semantics mandate raw gf_resolve_primary_claude_dir, not the guard idiom).
# Scan includes hooks/pre-commit (W1.5b minor: an invariant grep that scans
# only hooks/*.sh would miss it).

RETIRED_TOKENS=('_primary_claude_dir=' 'CLAUDE_DIR="$(gf_resolve_primary_claude_dir' '_gf_primary_claude_dir=' '_GF_PRIMARY_CLAUDE_DIR=')
found_retired=0

for token in "${RETIRED_TOKENS[@]}"; do
    # Search all .sh files under hooks/ for the retired token,
    # excluding hooks/lib/ (utility library) and gating hooks check-commit.sh
    # and pre-commit (which require fail-toward-deny semantics with raw resolver).
    hits=$(grep -rn --exclude-dir=lib "$token" "$REPO_ROOT/hooks/" 2>/dev/null | grep -v -- '/hooks/check-commit\.sh:' | grep -v -- '/hooks/pre-commit:')
    if [ -n "$hits" ]; then
        found_retired=1
    fi
done

if [ "$found_retired" -eq 0 ]; then
    echo "PASS: Task 6b — zero occurrences of retired tokens in non-gating hooks"
    PASS=$((PASS+1))
else
    echo "FAIL: Task 6b — found retired tokens in non-gating hooks (expected zero occurrences)"
    FAIL=$((FAIL+1))
fi

# ── SUMMARY ───────────────────────────────────────────────────────────────────
echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
