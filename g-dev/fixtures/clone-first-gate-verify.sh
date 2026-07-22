#!/bin/bash
# clone-first-gate-verify.sh — clone-first sandbox verification of the
# G-Forge commit gate, driven through REAL `git commit` invocations against
# a throwaway CLONE (never a directly-invoked hook, unlike
# g-dev/fixtures/pre-commit-gate-verify.sh, which is the reference this
# fixture reuses assertion style/helpers from).
#
# W1.7 Tasks 1-7. 37 main assertions across 14 scenario sub-cases (Scenarios
# 1-6 below, mapping to plan Tasks 2-7; includes the canary-restore check,
# which reports in the main counter) + 1 CANARY discrimination probe
# (tracked in its own separate counter — see the CANARY section).
#
# WHY clone-first, not direct hook invocation: pre-commit-gate-verify.sh
# invokes hooks/pre-commit directly via `bash "$PRECOMMIT"` with cwd set to
# a temp repo — useful for exhaustively covering the stamp-validation branch
# logic, but it never proves the hook actually FIRES as git's own native
# pre-commit hook, never proves check-commit.sh's PreToolUse-vs-native gap
# (finding #21's script-indirection surface — Scenario 6 below), and never
# proves a real `git commit` end-to-end (working tree -> index -> hook ->
# object database). This fixture closes that gap: every scenario below runs
# a REAL `git commit` (or a script that runs one) inside a repo that is
# itself a clone of THIS repo, with the REAL hooks/pre-commit and
# hooks/check-commit.sh + hooks/lib/* installed exactly the way a live
# self-host install would install them (ADR-008).
#
# Clone choice (per task instructions: prefer cloning the real repo,
# document the choice): this repo's .git is ~5MB / ~350 commits at the time
# this fixture was written — `git clone --local --no-hardlinks` of it
# completes in ~1s (measured directly while writing this fixture). That is
# well within budget for ~15 clones in one run, so this fixture clones the
# REAL repo (`$REPO_ROOT`) for every scenario that needs an existing HEAD,
# rather than constructing a synthetic minimal repo — the installed hooks
# then ship content-identical to what a real consumer clone would run.
# `--no-hardlinks` is passed unconditionally because the destination
# (a mktemp -d scratch dir) may resolve to a different drive/filesystem than
# $REPO_ROOT on Windows, where a cross-drive hardlink fails outright
# (verified empirically: "fatal: failed to create link ... Improper link").
# Scenario 4 (first-commit) is the one exception: a first-commit-with-no-HEAD
# state cannot come from cloning a repo that already has ~350 commits, so
# that scenario uses a plain `git init` instead and installs the same
# hooks/pre-commit + hooks/check-commit.sh + hooks/lib/* files directly from
# $REPO_ROOT/hooks — byte-identical content to what the clone path installs,
# just without the clone step (there is nothing to clone FROM for a
# first-commit state).
#
# Git identity: every commit in this fixture uses the
# `git -c user.email=t@t -c user.name=t commit` form (never `git config
# user.email` on the throwaway repos) per the task's explicit instruction —
# this makes identity resolution self-contained per invocation rather than
# depending on ambient global git config that may or may not be set on the
# machine running this fixture.
#
# The empty-filler trick (Scenario 2c): the task asks for "a --no-verify
# filler commit advances HEAD" to build a stale-HEAD (but tree-still-valid)
# sentinel. A `--no-verify` commit of REAL staged content necessarily
# changes the tree too (that's what committing content means), which would
# make the sentinel stale on BOTH ts and head, collapsing the test into the
# already-covered stale-tree case (2b) instead of isolating the stale-HEAD-
# only branch in hooks/pre-commit's gf_validate_sentinel. Fixed by ordering
# the filler BEFORE staging the target file, as an `--allow-empty
# --no-verify` commit against a clean index — this advances HEAD via a real,
# hook-bypassing `git commit` while leaving the working tree's file content
# byte-identical to before the filler (an empty commit's tree is my its
# parent's tree). The target file is staged only AFTER the filler, on top of
# the (content-identical) new HEAD, so `git write-tree` computed at
# read-the-hooks review time and at real-commit time are numerically the
# SAME tree hash git write-tree is a pure function of index content, not of
# which commit HEAD happens to point to) while HEAD_SHA has genuinely moved.
# Verified empirically while building this fixture: the resulting deny
# reason is exactly "HEAD has moved since review", not the stale-tree
# reason, confirming the isolation worked.
#
# CANARY discrimination (mandatory, see W1.7 forecast scenario 2 / the
# fixture false-green class from W1.6): this fixture proves its own
# assertions are not tautological by corrupting the CLONE's installed
# hooks/pre-commit (truncating it to `exit 0`) and re-running the same
# assertion shape as Scenario 2a (deny an unstamped commit) against the
# corrupted hook. Under corruption the commit WRONGLY succeeds, so the
# assertion — literally the same `check_canary "... exit non-zero ..."` an
# unmodified copy of the Scenario 2a assertion — reports FAIL. That FAIL is
# EXPECTED and is tracked in a SEPARATE counter (CANARY_PASS/CANARY_FAIL),
# never folded into the main TOTAL_PASS/TOTAL_FAIL gating counters, so the
# overall fixture still exits 0 (green) when the real (uncorrupted) hook is
# correct — while a canary that does NOT go red (i.e. the corrupted hook
# accidentally still denies, or the corruption/restore machinery itself is
# broken) IS folded into the main total as a real failure, since that would
# mean this fixture's assertions cannot actually discriminate correct
# behavior from broken behavior.
#
# Parent-shell PASS/FAIL counting (W1.5b false-green trap): every check()/
# check_canary() call and every counter increment below runs in the PARENT
# shell — no counter increment ever happens inside a subshell, command
# substitution, or the RHS of a pipe. run_commit() below uses `git -C`
# (never `cd` into a subshell) for exactly this reason: earlier drafts of
# this fixture used a `( cd "$dir" && ... )` subshell for git commit, which
# would have been harmless here (LAST_CODE/LAST_OUT/LAST_ERR are read back
# via files, not shell state), but `git -C "$dir" ...` avoids the pattern
# entirely and keeps every assignment in this script in the one shell that
# also runs check().
#
# VERIFICATION-ONLY: this fixture never edits hooks/pre-commit,
# hooks/check-commit.sh, hooks/lib/*, or the real repo's own git state —
# every mutation happens inside a throwaway clone/init under $BASE (a
# `mktemp -d` scratch dir), removed by a trap on EXIT.

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="${GFORGE_REPO_ROOT:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

if [ ! -f "$REPO_ROOT/hooks/pre-commit" ]; then
    echo "FATAL: cannot find hooks/pre-commit at $REPO_ROOT/hooks/pre-commit" >&2
    exit 1
fi
if [ ! -f "$REPO_ROOT/hooks/check-commit.sh" ]; then
    echo "FATAL: cannot find hooks/check-commit.sh at $REPO_ROOT/hooks/check-commit.sh" >&2
    exit 1
fi

BASE="$(mktemp -d)"
trap 'rm -rf "$BASE"' EXIT

echo "=== clone-first-gate-verify — clone-first sandbox verification of the G-Forge commit gate ==="
echo "REPO_ROOT=$REPO_ROOT"
echo "BASE (temp repos)=$BASE"
echo

TOTAL_PASS=0
TOTAL_FAIL=0
CANARY_PASS=0
CANARY_FAIL=0

check() {
    # check <name> <1|0> <detail> — main gating counter, parent-shell only.
    local name="$1" ok="$2" detail="$3"
    if [ "$ok" = "1" ]; then
        echo "PASS: $name"
        TOTAL_PASS=$((TOTAL_PASS + 1))
    else
        echo "FAIL: $name -- $detail"
        TOTAL_FAIL=$((TOTAL_FAIL + 1))
    fi
}

check_canary() {
    # check_canary <name> <1|0> <detail> — SEPARATE counter for the CANARY
    # section. A FAIL here under a corrupted hook is EXPECTED and proves
    # discrimination; it is never added to TOTAL_PASS/TOTAL_FAIL.
    local name="$1" ok="$2" detail="$3"
    if [ "$ok" = "1" ]; then
        echo "PASS (canary): $name"
        CANARY_PASS=$((CANARY_PASS + 1))
    else
        echo "FAIL (canary, EXPECTED under a corrupted hook -- proves assertions discriminate): $name -- $detail"
        CANARY_FAIL=$((CANARY_FAIL + 1))
    fi
}

# --- fixture helpers -------------------------------------------------------

GITID="-c user.email=t@t -c user.name=t"

first_line() {
    printf '%s\n' "$1" | head -n1
}

resolve_git_hooks_dir() {
    # resolve_git_hooks_dir <dir> -> absolute path to <dir>'s native git
    # hooks directory. `git -C <dir> rev-parse --git-path hooks` prints a
    # path relative to <dir> for a plain (non-worktree) repo — verified
    # empirically while building this fixture — so a relative result is
    # joined onto <dir> here; an already-absolute result (POSIX or Windows
    # drive-letter form) is used as-is.
    local dir="$1"
    local p
    p=$(git -C "$dir" rev-parse --git-path hooks)
    case "$p" in
        /*|[A-Za-z]:*) printf '%s\n' "$p" ;;
        *) printf '%s/%s\n' "$dir" "$p" ;;
    esac
}

install_gate() {
    # install_gate <dir> — installs the REAL hooks/pre-commit as the native
    # git hook, and hooks/check-commit.sh + hooks/lib/* under .claude/hooks/
    # (the PreToolUse-probe install location — Scenario 5a), then marks
    # <dir> as a full-tier G-Forge project. Deliberately does NOT install
    # hooks/post-commit-cleanup.sh anywhere — Scenario 6b relies on its
    # absence to prove sentinel consumption is the native hook's own
    # consume-on-pass, not a PostToolUse side effect it never sees.
    local dir="$1"
    local hooks_dir
    hooks_dir=$(resolve_git_hooks_dir "$dir")
    mkdir -p "$hooks_dir/lib"
    cp "$REPO_ROOT/hooks/pre-commit" "$hooks_dir/pre-commit"
    chmod +x "$hooks_dir/pre-commit"
    cp "$REPO_ROOT"/hooks/lib/*.sh "$hooks_dir/lib/"

    mkdir -p "$dir/.claude/hooks/lib"
    cp "$REPO_ROOT/hooks/check-commit.sh" "$dir/.claude/hooks/check-commit.sh"
    chmod +x "$dir/.claude/hooks/check-commit.sh"
    cp "$REPO_ROOT"/hooks/lib/*.sh "$dir/.claude/hooks/lib/"

    mkdir -p "$dir/.claude"
    printf 'full\n' > "$dir/.claude/integration-tier"
    # Cosmetic only (does not affect gate correctness): silence git's
    # LF/CRLF autocrlf warning noise on Windows so this fixture's own stdout
    # stays readable.
    git -C "$dir" config core.autocrlf false
}

new_clone_gated() {
    # new_clone_gated <name> -> prints the absolute path of a fresh clone of
    # $REPO_ROOT at $BASE/<name>, with the real gate installed (see
    # install_gate). Has a real HEAD (inherited from $REPO_ROOT's history).
    local name="$1"
    local dir="$BASE/$name"
    rm -rf "$dir"
    git clone --local --no-hardlinks --quiet -- "$REPO_ROOT" "$dir" >/dev/null 2>&1
    install_gate "$dir"
    printf '%s' "$dir"
}

new_fresh_gated() {
    # new_fresh_gated <name> -> prints the absolute path of a brand new
    # `git init` repo (NO HEAD, no history) at $BASE/<name>, with the real
    # gate installed directly from $REPO_ROOT/hooks (see header rationale —
    # there is nothing to clone FROM for a first-commit state).
    local name="$1"
    local dir="$BASE/$name"
    rm -rf "$dir"
    mkdir -p "$dir"
    git -C "$dir" init -q
    install_gate "$dir"
    printf '%s' "$dir"
}

stage_code_file() {
    # stage_code_file <dir> <path>  (path must classify CODE per classify-changeset.sh)
    local dir="$1" path="$2"
    mkdir -p "$dir/$(dirname "$path")"
    printf '#!/bin/bash\necho hi\n' > "$dir/$path"
    git -C "$dir" add "$path"
}

stage_doc_file() {
    # stage_doc_file <dir> <path>  (path must classify DOC per classify-changeset.sh)
    local dir="$1" path="$2"
    mkdir -p "$dir/$(dirname "$path")"
    printf '# doc\n' > "$dir/$path"
    git -C "$dir" add "$path"
}

write_sentinel() {
    # write_sentinel <file> <tree> <head> <worktree>
    local file="$1" tree="$2" head="$3" worktree="$4"
    mkdir -p "$(dirname "$file")"
    printf 'commit_sentinel_ts=%s commit_sentinel_head=%s commit_sentinel_worktree=%s\n' \
        "$tree" "$head" "$worktree" > "$file"
}

run_commit() {
    # run_commit <dir> <message> [extra git-commit args...] — a REAL
    # `git commit`, always via `-c user.email=t@t -c user.name=t` and always
    # via `git -C <dir>` (never a `cd` subshell — see header's parent-shell
    # counting rationale). Sets LAST_CODE, LAST_OUT, LAST_ERR,
    # LAST_HEAD_BEFORE, LAST_HEAD_AFTER — all read back in THIS shell.
    local dir="$1" msg="$2"
    shift 2
    LAST_HEAD_BEFORE=$(git -C "$dir" rev-parse --verify HEAD 2>/dev/null)
    git -C "$dir" $GITID commit -q -m "$msg" "$@" >"$dir/.gc.out" 2>"$dir/.gc.err"
    LAST_CODE=$?
    LAST_OUT=$(cat "$dir/.gc.out")
    LAST_ERR=$(cat "$dir/.gc.err")
    LAST_HEAD_AFTER=$(git -C "$dir" rev-parse --verify HEAD 2>/dev/null)
    echo "  \$ (git -C $dir commit -q -m \"$msg\" $*)"
    echo "  exit code: $LAST_CODE"
    echo "  stdout: ${LAST_OUT:-<empty>}"
    echo "  stderr: ${LAST_ERR:-<empty>}"
    echo "  HEAD before=$LAST_HEAD_BEFORE after=$LAST_HEAD_AFTER"
}

# ============================================================================
echo "--- Setup sanity (Task 1): clone-first install produces a real, executable, full-tier gate ---"
SETUP_REPO=$(new_clone_gated "setup-sanity")
SETUP_HOOKS_DIR=$(resolve_git_hooks_dir "$SETUP_REPO")
check "setup: native pre-commit hook installed and executable" \
    "$([ -x "$SETUP_HOOKS_DIR/pre-commit" ] && echo 1 || echo 0)" \
    "missing or non-executable: $SETUP_HOOKS_DIR/pre-commit"
check "setup: pre-commit installed content matches source hooks/pre-commit" \
    "$(cmp -s "$SETUP_HOOKS_DIR/pre-commit" "$REPO_ROOT/hooks/pre-commit" && echo 1 || echo 0)" \
    "installed copy differs from $REPO_ROOT/hooks/pre-commit"
check "setup: check-commit.sh installed and executable under .claude/hooks/" \
    "$([ -x "$SETUP_REPO/.claude/hooks/check-commit.sh" ] && echo 1 || echo 0)" \
    "missing or non-executable: $SETUP_REPO/.claude/hooks/check-commit.sh"
check "setup: integration-tier=full" \
    "$([ "$(cat "$SETUP_REPO/.claude/integration-tier" 2>/dev/null)" = "full" ] && echo 1 || echo 0)" \
    "unexpected tier content"
echo

# ============================================================================
echo "--- Scenario 1 (Task 2): stamped pass path -- real commit succeeds, sentinel consumed ---"
REPO=$(new_clone_gated "s1-stamped-pass")
stage_code_file "$REPO" "hooks/s1-fixture.sh"
TREE=$(git -C "$REPO" write-tree)
HEAD=$(git -C "$REPO" rev-parse --verify HEAD)
WT=$(git -C "$REPO" rev-parse --show-toplevel)
write_sentinel "$REPO/.claude/g-forge-approved" "$TREE" "$HEAD" "$WT"
echo "  correct stamp: ts=$TREE head=$HEAD worktree=$WT"
run_commit "$REPO" "s1: stamped pass path"
check "1: exit 0 on matching stamp" "$([ "$LAST_CODE" -eq 0 ] && echo 1 || echo 0)" "exit=$LAST_CODE"
check "1: commit landed (HEAD advanced)" "$([ "$LAST_HEAD_AFTER" != "$LAST_HEAD_BEFORE" ] && [ -n "$LAST_HEAD_AFTER" ] && echo 1 || echo 0)" "before=$LAST_HEAD_BEFORE after=$LAST_HEAD_AFTER"
check "1: sentinel consumed (file gone) immediately after" "$([ ! -f "$REPO/.claude/g-forge-approved" ] && echo 1 || echo 0)" "file still present"
echo

# ============================================================================
echo "--- Scenario 2 (Task 3): deny x3 -- real commit non-zero, HEAD unchanged ---"

echo "  2a: no sentinel -> deny"
REPO=$(new_clone_gated "s2a-no-sentinel")
stage_code_file "$REPO" "hooks/s2a.sh"
echo "  staged: hooks/s2a.sh (CODE bucket); no sentinel written"
run_commit "$REPO" "s2a: unstamped commit"
check "2a: exit non-zero when unstamped" "$([ "$LAST_CODE" -ne 0 ] && echo 1 || echo 0)" "exit=$LAST_CODE"
check "2a: HEAD unchanged pre/post" "$([ "$LAST_HEAD_AFTER" = "$LAST_HEAD_BEFORE" ] && echo 1 || echo 0)" "before=$LAST_HEAD_BEFORE after=$LAST_HEAD_AFTER"
FL=$(first_line "$LAST_ERR")
check "2a: stderr starts with 'G-Forge:'" "$(case "$FL" in "G-Forge:"*) echo 1;; *) echo 0;; esac)" "first stderr line='$FL'"

echo "  2b: stale-tree stamp (stamp written, then staged content changed) -> deny"
REPO=$(new_clone_gated "s2b-stale-tree")
stage_code_file "$REPO" "hooks/s2b.sh"
TREE=$(git -C "$REPO" write-tree)
HEAD=$(git -C "$REPO" rev-parse --verify HEAD)
WT=$(git -C "$REPO" rev-parse --show-toplevel)
write_sentinel "$REPO/.claude/g-forge-approved" "$TREE" "$HEAD" "$WT"
echo "  stamp taken: ts=$TREE head=$HEAD worktree=$WT"
printf '#!/bin/bash\necho changed\n' > "$REPO/hooks/s2b.sh"
git -C "$REPO" add hooks/s2b.sh
NEWTREE=$(git -C "$REPO" write-tree)
echo "  staged content changed post-stamp; new write-tree=$NEWTREE (differs: $([ "$NEWTREE" != "$TREE" ] && echo yes || echo NO))"
run_commit "$REPO" "s2b: stale-tree commit"
check "2b: exit non-zero on stale tree" "$([ "$LAST_CODE" -ne 0 ] && echo 1 || echo 0)" "exit=$LAST_CODE"
check "2b: HEAD unchanged pre/post" "$([ "$LAST_HEAD_AFTER" = "$LAST_HEAD_BEFORE" ] && echo 1 || echo 0)" "before=$LAST_HEAD_BEFORE after=$LAST_HEAD_AFTER"
LC_ERR=$(printf '%s' "$LAST_ERR" | tr '[:upper:]' '[:lower:]')
check "2b: reason names the stale tree" "$(case "$LC_ERR" in *stale*tree*does*not*match*|*stale*) echo 1;; *) echo 0;; esac)" "stderr='$LAST_ERR'"

echo "  2c: stale-HEAD stamp (empty --no-verify filler advances HEAD, tree stays valid) -> deny"
REPO=$(new_clone_gated "s2c-stale-head")
HEAD0=$(git -C "$REPO" rev-parse --verify HEAD)
git -C "$REPO" $GITID commit -q --no-verify --allow-empty -m "filler: advance head (bypasses hook, --no-verify, no content change)"
HEAD1=$(git -C "$REPO" rev-parse --verify HEAD)
echo "  filler advanced HEAD: HEAD0=$HEAD0 -> HEAD1=$HEAD1 (moved: $([ "$HEAD1" != "$HEAD0" ] && echo yes || echo NO))"
stage_code_file "$REPO" "hooks/s2c.sh"
TREE=$(git -C "$REPO" write-tree)
WT=$(git -C "$REPO" rev-parse --show-toplevel)
write_sentinel "$REPO/.claude/g-forge-approved" "$TREE" "$HEAD0" "$WT"
echo "  stamp taken with STALE head=$HEAD0 (current real HEAD is $HEAD1); tree=$TREE (content-identical to a pre-filler stamp, since the filler was a no-op empty commit)"
run_commit "$REPO" "s2c: stale-head commit"
check "2c: exit non-zero on stale HEAD (tree still valid, HEAD moved)" "$([ "$LAST_CODE" -ne 0 ] && echo 1 || echo 0)" "exit=$LAST_CODE"
check "2c: HEAD unchanged pre/post (still HEAD1, no new commit landed)" "$([ "$LAST_HEAD_AFTER" = "$HEAD1" ] && [ "$LAST_HEAD_AFTER" = "$LAST_HEAD_BEFORE" ] && echo 1 || echo 0)" "HEAD1=$HEAD1 before=$LAST_HEAD_BEFORE after=$LAST_HEAD_AFTER"
LC_ERR=$(printf '%s' "$LAST_ERR" | tr '[:upper:]' '[:lower:]')
check "2c: reason names HEAD having moved" "$(case "$LC_ERR" in *head*has*moved*) echo 1;; *) echo 0;; esac)" "stderr='$LAST_ERR'"
echo

# ============================================================================
echo "--- Scenario 3 (Task 4): doc/mixed dual-sentinel x3 ---"

echo "  3a: doc-only change with valid doc sentinel -> pass"
REPO=$(new_clone_gated "s3a-doc-valid")
stage_doc_file "$REPO" "g-docs/s3a.md"
TREE=$(git -C "$REPO" write-tree)
HEAD=$(git -C "$REPO" rev-parse --verify HEAD)
WT=$(git -C "$REPO" rev-parse --show-toplevel)
write_sentinel "$REPO/.claude/g-forge-docs-approved" "$TREE" "$HEAD" "$WT"
echo "  staged: g-docs/s3a.md (DOC bucket only); valid doc sentinel: ts=$TREE head=$HEAD worktree=$WT"
run_commit "$REPO" "s3a: doc-only valid doc sentinel"
check "3a: exit 0 on matching doc sentinel" "$([ "$LAST_CODE" -eq 0 ] && echo 1 || echo 0)" "exit=$LAST_CODE"
check "3a: doc sentinel consumed" "$([ ! -f "$REPO/.claude/g-forge-docs-approved" ] && echo 1 || echo 0)" "file still present"

echo "  3b: mixed change, only code sentinel -> deny naming doc, code sentinel NOT consumed"
REPO=$(new_clone_gated "s3b-mixed-code-only")
stage_code_file "$REPO" "hooks/s3b.sh"
stage_doc_file "$REPO" "g-docs/s3b.md"
TREE=$(git -C "$REPO" write-tree)
HEAD=$(git -C "$REPO" rev-parse --verify HEAD)
WT=$(git -C "$REPO" rev-parse --show-toplevel)
write_sentinel "$REPO/.claude/g-forge-approved" "$TREE" "$HEAD" "$WT"
echo "  code sentinel only: ts=$TREE head=$HEAD worktree=$WT; no doc sentinel"
run_commit "$REPO" "s3b: mixed missing doc sentinel"
check "3b: exit non-zero, doc sentinel missing" "$([ "$LAST_CODE" -ne 0 ] && echo 1 || echo 0)" "exit=$LAST_CODE"
LC_ERR=$(printf '%s' "$LAST_ERR" | tr '[:upper:]' '[:lower:]')
check "3b: reason names doc as missing" "$(case "$LC_ERR" in *doc*) echo 1;; *) echo 0;; esac)" "stderr='$LAST_ERR'"
check "3b: code sentinel NOT consumed on partial failure" "$([ -f "$REPO/.claude/g-forge-approved" ] && echo 1 || echo 0)" "code sentinel was consumed despite denial"

echo "  3c: mixed change, BOTH sentinels valid -> pass, BOTH consumed"
REPO=$(new_clone_gated "s3c-mixed-both")
stage_code_file "$REPO" "hooks/s3c.sh"
stage_doc_file "$REPO" "g-docs/s3c.md"
TREE=$(git -C "$REPO" write-tree)
HEAD=$(git -C "$REPO" rev-parse --verify HEAD)
WT=$(git -C "$REPO" rev-parse --show-toplevel)
write_sentinel "$REPO/.claude/g-forge-approved" "$TREE" "$HEAD" "$WT"
write_sentinel "$REPO/.claude/g-forge-docs-approved" "$TREE" "$HEAD" "$WT"
echo "  both sentinels valid: ts=$TREE head=$HEAD worktree=$WT"
run_commit "$REPO" "s3c: mixed both sentinels valid"
check "3c: exit 0, both sentinels valid" "$([ "$LAST_CODE" -eq 0 ] && echo 1 || echo 0)" "exit=$LAST_CODE"
check "3c: code sentinel consumed" "$([ ! -f "$REPO/.claude/g-forge-approved" ] && echo 1 || echo 0)" "file still present"
check "3c: doc sentinel consumed" "$([ ! -f "$REPO/.claude/g-forge-docs-approved" ] && echo 1 || echo 0)" "file still present"
echo

# ============================================================================
echo "--- Scenario 4 (Task 5): first-commit x2 (fresh git init, no HEAD) ---"

echo "  4a: unstamped first commit -> deny"
REPO=$(new_fresh_gated "s4a-first-unstamped")
stage_code_file "$REPO" "hooks/s4a.sh"
HEAD_CHECK=$(git -C "$REPO" rev-parse --verify HEAD 2>/dev/null)
echo "  confirmed no HEAD yet: '$HEAD_CHECK' (expected empty)"
run_commit "$REPO" "s4a: first commit unstamped"
check "4a: exit non-zero, first commit unstamped" "$([ "$LAST_CODE" -ne 0 ] && echo 1 || echo 0)" "exit=$LAST_CODE"

echo "  4b: correctly stamped first commit (empty-HEAD form) -> pass"
REPO=$(new_fresh_gated "s4b-first-stamped")
stage_code_file "$REPO" "hooks/s4b.sh"
TREE=$(git -C "$REPO" write-tree)
HEAD=$(git -C "$REPO" rev-parse --verify HEAD 2>/dev/null)
WT=$(git -C "$REPO" rev-parse --show-toplevel)
write_sentinel "$REPO/.claude/g-forge-approved" "$TREE" "$HEAD" "$WT"
echo "  stamp taken: ts=$TREE head='$HEAD' (empty, matches empty current HEAD) worktree=$WT"
run_commit "$REPO" "s4b: first commit stamped"
check "4b: exit 0, correctly-stamped first commit" "$([ "$LAST_CODE" -eq 0 ] && echo 1 || echo 0)" "exit=$LAST_CODE"
check "4b: commit landed (git log has exactly 1 commit)" "$([ "$(git -C "$REPO" rev-list --count HEAD 2>/dev/null)" = "1" ] && echo 1 || echo 0)" "rev-list --count=$(git -C "$REPO" rev-list --count HEAD 2>/dev/null)"
check "4b: sentinel consumed" "$([ ! -f "$REPO/.claude/g-forge-approved" ] && echo 1 || echo 0)" "file still present"
echo

# ============================================================================
echo "--- Scenario 5 (Task 6): #21 false-positive probes x2 ---"

echo "  5a: PreToolUse (check-commit.sh) fed a command that merely CONTAINS 'git commit' inside a quoted grep pattern -> must NOT deny"
REPO=$(new_clone_gated "s5a-pretooluse-probe")
PAYLOAD='{"tool_name":"Bash","tool_input":{"command":"grep -n \"git commit\" README.md"}}'
CC_OUT=$(cd "$REPO" && printf '%s' "$PAYLOAD" | bash .claude/hooks/check-commit.sh 2>"$REPO/.cc.err")
CC_CODE=$?
CC_ERR=$(cat "$REPO/.cc.err" 2>/dev/null)
echo "  \$ (cd $REPO && echo <payload with grep \"git commit\" ...> | bash .claude/hooks/check-commit.sh)"
echo "  exit code: $CC_CODE"
echo "  stdout: ${CC_OUT:-<empty>}"
echo "  stderr: ${CC_ERR:-<empty>}"
check "5a: PreToolUse exit code is not 2 (the universal blocker -- non-committing grep must not be denied)" "$([ "$CC_CODE" -ne 2 ] && echo 1 || echo 0)" "exit=$CC_CODE"
check "5a: PreToolUse stdout carries no deny JSON" "$(case "$CC_OUT" in *'\"permissionDecision\":\"deny\"'*|*'permissionDecision":"deny"'*) echo 0;; *) echo 1;; esac)" "stdout='$CC_OUT'"

echo "  5b: real commit whose MESSAGE cites file paths (code+doc) but only a single actually-staged code file + its sentinel -> classifier must NOT misroute to mixed"
REPO=$(new_clone_gated "s5b-message-paths")
stage_code_file "$REPO" "hooks/s5b.sh"
TREE=$(git -C "$REPO" write-tree)
HEAD=$(git -C "$REPO" rev-parse --verify HEAD)
WT=$(git -C "$REPO" rev-parse --show-toplevel)
write_sentinel "$REPO/.claude/g-forge-approved" "$TREE" "$HEAD" "$WT"
echo "  staged ONLY hooks/s5b.sh (CODE); code sentinel: ts=$TREE head=$HEAD worktree=$WT; no doc sentinel"
run_commit "$REPO" "touch hooks/check-commit.sh and g-docs/x.md"
check "5b: exit 0 -- message text citing doc paths does not force a doc-sentinel requirement" "$([ "$LAST_CODE" -eq 0 ] && echo 1 || echo 0)" "exit=$LAST_CODE"
echo

# ============================================================================
echo "--- Scenario 6 (Task 7): script-indirection probe (bash indirect.sh) ---"
REPO=$(new_clone_gated "s6-indirect")
stage_code_file "$REPO" "hooks/s6.sh"
{
    printf '#!/bin/bash\n'
    printf 'cd "$(dirname "$0")" || exit 99\n'
    printf 'git -c user.email=t@t -c user.name=t commit -q -m "via indirect.sh"\n'
} > "$REPO/indirect.sh"
chmod +x "$REPO/indirect.sh"

echo "  6a: no sentinel, run via 'bash indirect.sh' -> native pre-commit still denies (PreToolUse never sees this argv)"
HEAD_BEFORE_6A=$(git -C "$REPO" rev-parse --verify HEAD)
(cd "$REPO" && bash indirect.sh >"$REPO/.ind.out" 2>"$REPO/.ind.err")
IND_CODE=$?
IND_ERR=$(cat "$REPO/.ind.err")
echo "  \$ (cd $REPO && bash indirect.sh)  # no sentinel"
echo "  exit code: $IND_CODE"
echo "  stderr: ${IND_ERR:-<empty>}"
check "6a: exit non-zero, native pre-commit denies the indirected commit" "$([ "$IND_CODE" -ne 0 ] && echo 1 || echo 0)" "exit=$IND_CODE"
FL=$(first_line "$IND_ERR")
check "6a: stderr starts with 'G-Forge:'" "$(case "$FL" in "G-Forge:"*) echo 1;; *) echo 0;; esac)" "first stderr line='$FL'"

echo "  6b: valid stamped sentinel, run via 'bash indirect.sh' -> passes, sentinel consumed by the native hook (post-commit-cleanup.sh is not even installed in this fixture)"
TREE=$(git -C "$REPO" write-tree)
HEAD=$(git -C "$REPO" rev-parse --verify HEAD)
WT=$(git -C "$REPO" rev-parse --show-toplevel)
write_sentinel "$REPO/.claude/g-forge-approved" "$TREE" "$HEAD" "$WT"
echo "  stamp taken: ts=$TREE head=$HEAD worktree=$WT"
check "6b: post-commit-cleanup.sh is NOT installed anywhere in this fixture repo (sentinel consumption, if it happens, cannot be attributed to it)" "$([ ! -f "$REPO/.claude/hooks/post-commit-cleanup.sh" ] && echo 1 || echo 0)" "unexpectedly present"
(cd "$REPO" && bash indirect.sh >"$REPO/.ind2.out" 2>"$REPO/.ind2.err")
IND2_CODE=$?
IND2_ERR=$(cat "$REPO/.ind2.err")
echo "  \$ (cd $REPO && bash indirect.sh)  # valid stamped sentinel"
echo "  exit code: $IND2_CODE"
echo "  stderr: ${IND2_ERR:-<empty>}"
check "6b: exit 0, indirected commit with valid sentinel passes" "$([ "$IND2_CODE" -eq 0 ] && echo 1 || echo 0)" "exit=$IND2_CODE"
check "6b: sentinel consumed by the native hook (consume-on-pass)" "$([ ! -f "$REPO/.claude/g-forge-approved" ] && echo 1 || echo 0)" "file still present"
echo

# ============================================================================
echo "--- CANARY (mandatory): corrupt the installed pre-commit, re-run Scenario 2a's assertion shape -- must go red ---"
REPO=$(new_clone_gated "canary")
HOOKS_DIR=$(resolve_git_hooks_dir "$REPO")
cp "$HOOKS_DIR/pre-commit" "$BASE/canary-precommit-backup.orig"
stage_code_file "$REPO" "hooks/canary.sh"
echo "  staged: hooks/canary.sh (CODE bucket); no sentinel written (identical setup to Scenario 2a)"
printf '#!/bin/bash\nexit 0\n' > "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/pre-commit"
echo "  CORRUPTED $HOOKS_DIR/pre-commit -> truncated to 'exit 0'"
run_commit "$REPO" "canary: corrupted-hook commit (should have been denied)"
check_canary "canary: exit non-zero when unstamped (same assertion as 2a, run against the CORRUPTED hook)" "$([ "$LAST_CODE" -ne 0 ] && echo 1 || echo 0)" "expected non-zero but corrupted hook returned exit=$LAST_CODE -- this FAIL is EXPECTED and proves the fixture's deny assertions are not tautological"
cp "$BASE/canary-precommit-backup.orig" "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/pre-commit"
check "CANARY: pre-commit hook restored (byte-identical to source hooks/pre-commit)" "$(cmp -s "$HOOKS_DIR/pre-commit" "$REPO_ROOT/hooks/pre-commit" && echo 1 || echo 0)" "restored hook differs from source"
if [ "$CANARY_FAIL" -ne 1 ] || [ "$CANARY_PASS" -ne 0 ]; then
    echo "CANARY DID NOT BEHAVE AS EXPECTED (fail=$CANARY_FAIL pass=$CANARY_PASS, expected fail=1 pass=0) -- assertions may be tautological; treating as a fixture failure"
    TOTAL_FAIL=$((TOTAL_FAIL + 1))
else
    echo "CANARY behaved as expected: 1 expected-red assertion fired under corruption, 0 unexpected passes -- discrimination proven"
fi
echo

# ============================================================================
echo "=== SUMMARY ==="
echo "PASS: $TOTAL_PASS"
echo "FAIL: $TOTAL_FAIL"
echo "CANARY (separate, not gating): expected-red=$CANARY_FAIL unexpected-pass=$CANARY_PASS"
echo "Results: $TOTAL_PASS/$TOTAL_FAIL"

if [ "$TOTAL_FAIL" -ne 0 ]; then
    exit 1
fi
exit 0
