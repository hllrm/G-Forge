#!/bin/bash
# Unit tests for hooks/check-commit.sh
# Runs entirely inside a throwaway fixture dir so the suite never mutates the
# repo's own .claude/ (an earlier version deleted .claude/integration-tier in
# the repo root, silently disabling the hooks for the project).
#
# Total assertions: 22
# Count is the RUNNER-OBSERVED total and must equal the `Results:` line — the
# finding-#20 cross-check that catches a suite silently dropping cases.

SCRIPT="$(cd "$(dirname "$0")" && pwd)/../hooks/check-commit.sh"
SENTINEL=".claude/g-forge-approved"
PASS=0
FAIL=0

run() {
    local name="$1" input="$2" expected="$3"
    echo "$input" | bash "$SCRIPT" >/dev/null 2>&1
    local actual=$?
    if [ "$actual" -eq "$expected" ]; then
        echo "PASS: $name"; PASS=$((PASS+1))
    else
        echo "FAIL: $name (expected exit $expected, got $actual)"; FAIL=$((FAIL+1))
    fi
}

# Isolate all .claude state in a temp fixture — the hook resolves .claude
# relative to CWD, so running here keeps the real project untouched.
WORKDIR="$(mktemp -d)"
cd "$WORKDIR" || { echo "FAIL: could not enter fixture dir"; exit 1; }
mkdir -p .claude
# The hook self-guards to G-Forge-managed projects (presence of
# .claude/integration-tier). Mark this fixture as one so the gate is active.
printf 'full\n' > .claude/integration-tier
rm -f "$SENTINEL"

# Make the fixture a real git repo so the hook's file-set classifier
# (git diff --cached --name-only) has an index to read. Tests that stage no
# files keep an empty index → classifier routes through the code gate, exactly
# the historical behavior the original cases above rely on.
git init -q 2>/dev/null
git config user.email "test@g-forge.local" 2>/dev/null
git config user.name "g-forge-test" 2>/dev/null

DOCS_SENTINEL=".claude/g-forge-docs-approved"

# stage <path>... — reset the index, create + stage the given paths so the
# hook's classifier sees a known staged file set for the next run() call.
stage() {
    git rm -r --cached --quiet . >/dev/null 2>&1
    local p
    for p in "$@"; do
        mkdir -p "$(dirname "$p")"
        printf 'x\n' > "$p"
        git add "$p" >/dev/null 2>&1
    done
}

# 1: git commit without sign-off → blocked
run "git commit blocked without sign-off" \
    '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feat: add feature\""}}' \
    2

# 2: git commit with sign-off → allowed
echo "approved" > "$SENTINEL"
run "git commit allowed with sign-off" \
    '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feat: add feature\""}}' \
    0
rm -f "$SENTINEL"

# 3: npm test → allowed without sign-off
run "non-commit command always passes" \
    '{"tool_name":"Bash","tool_input":{"command":"npm test"}}' \
    0

# 4: git push → not blocked
run "git push not blocked" \
    '{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}' \
    0

# 5: git commit --amend → blocked without sign-off
run "git commit --amend blocked without sign-off" \
    '{"tool_name":"Bash","tool_input":{"command":"git commit --amend --no-edit"}}' \
    2

# 6: Regression — when no JSON parser works (jq absent, python3 is the Windows
# Microsoft-Store stub, node absent) the hook must fall back to grepping the
# raw payload and still block. Shadow all three parsers with exit-1 stubs
# *prepended* to the real PATH. (Replacing PATH wholesale by symlinking
# coreutils breaks git-bash — bash.exe can't load its DLLs from a bare symlink
# dir — which is what made this test mis-report a fail-open on Windows.)
STUBDIR="$(mktemp -d)"
for p in jq python3 node; do
    printf '#!/bin/sh\nexit 1\n' > "$STUBDIR/$p"
    chmod +x "$STUBDIR/$p"
done
rm -f "$SENTINEL"
echo '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"x\""}}' \
    | PATH="$STUBDIR:$PATH" bash "$SCRIPT" >/dev/null 2>&1
if [ $? -eq 2 ]; then
    echo "PASS: gate enforced when no JSON parser works (raw-payload fallback)"; PASS=$((PASS+1))
else
    echo "FAIL: gate fell OPEN with no working parser"; FAIL=$((FAIL+1))
fi
rm -rf "$STUBDIR"

# ── File-set classification gate (code / doc / mixed sentinels) ──────────────
# The hook classifies a commit by its staged file set and requires the matching
# sentinel(s): code paths → .claude/g-forge-approved; doc paths →
# .claude/g-forge-docs-approved; mixed → both. g-docs/* and root *.md are docs.

# 7: doc-only commit blocked when the doc sentinel is absent
rm -f "$SENTINEL" "$DOCS_SENTINEL"
stage "g-docs/notes.md"
run "doc-only commit blocked without doc sign-off" \
    '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"docs: notes\""}}' \
    2

# 8: doc-only commit allowed when the doc sentinel is present
rm -f "$SENTINEL" "$DOCS_SENTINEL"
echo "approved" > "$DOCS_SENTINEL"
stage "g-docs/notes.md"
run "doc-only commit allowed with doc sign-off" \
    '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"docs: notes\""}}' \
    0
rm -f "$DOCS_SENTINEL"

# 9: doc-only commit blocked when only the CODE sentinel is present (wrong gate)
rm -f "$SENTINEL" "$DOCS_SENTINEL"
echo "approved" > "$SENTINEL"
stage "README.md"
run "doc-only commit blocked when only code sign-off present" \
    '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"docs: readme\""}}' \
    2
rm -f "$SENTINEL"

# 10: mixed commit (code + doc) blocked when only the code sentinel is present
rm -f "$SENTINEL" "$DOCS_SENTINEL"
echo "approved" > "$SENTINEL"
stage "hooks/thing.sh" "g-docs/notes.md"
run "mixed commit blocked with only code sign-off" \
    '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feat: code + docs\""}}' \
    2
rm -f "$SENTINEL"

# 11: mixed commit blocked when only the doc sentinel is present
rm -f "$SENTINEL" "$DOCS_SENTINEL"
echo "approved" > "$DOCS_SENTINEL"
stage "hooks/thing.sh" "g-docs/notes.md"
run "mixed commit blocked with only doc sign-off" \
    '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feat: code + docs\""}}' \
    2
rm -f "$DOCS_SENTINEL"

# 12: mixed commit allowed when BOTH sentinels are present
rm -f "$SENTINEL" "$DOCS_SENTINEL"
echo "approved" > "$SENTINEL"
echo "approved" > "$DOCS_SENTINEL"
stage "hooks/thing.sh" "g-docs/notes.md"
run "mixed commit allowed with both sign-offs" \
    '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feat: code + docs\""}}' \
    0
rm -f "$SENTINEL" "$DOCS_SENTINEL"

# 13: code-only commit still allowed with only the code sentinel (regression)
rm -f "$SENTINEL" "$DOCS_SENTINEL"
echo "approved" > "$SENTINEL"
stage "hooks/thing.sh"
run "code-only commit allowed with code sign-off" \
    '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feat: code\""}}' \
    0
rm -f "$SENTINEL"

# 14: code-only commit blocked when only the DOC sentinel is present (wrong gate)
rm -f "$SENTINEL" "$DOCS_SENTINEL"
echo "approved" > "$DOCS_SENTINEL"
stage "hooks/thing.sh"
run "code-only commit blocked when only doc sign-off present" \
    '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feat: code\""}}' \
    2
rm -f "$DOCS_SENTINEL"

# 15: THE REGRESSION GUARD — a blocked commit must actually BLOCK, not just warn.
# The historical bug: block paths used `exit 1`, which is a NON-blocking PreToolUse
# error (the commit runs anyway). This asserts the two things that make it a real
# block: (a) exit code 2, and (b) a stdout `permissionDecision":"deny"` JSON. The
# old exit-1/no-JSON gate fails BOTH — this is the test that would have caught it.
rm -f "$SENTINEL" "$DOCS_SENTINEL"
stage "hooks/thing.sh"
OUT=$(echo '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"x\""}}' | bash "$SCRIPT" 2>/dev/null)
CODE=$?
if [ "$CODE" -eq 2 ] && printf '%s' "$OUT" | grep -q '"permissionDecision":"deny"'; then
    echo "PASS: blocked commit truly blocks (exit 2 + deny JSON on stdout)"; PASS=$((PASS+1))
else
    echo "FAIL: block is a no-op (got exit $CODE, deny-JSON $(printf '%s' "$OUT" | grep -q deny && echo present || echo ABSENT))"; FAIL=$((FAIL+1))
fi
rm -f "$SENTINEL"

# 16: an ALLOWED commit must NOT emit a deny decision (no false block).
echo "approved" > "$SENTINEL"
stage "hooks/thing.sh"
OUT=$(echo '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"x\""}}' | bash "$SCRIPT" 2>/dev/null)
CODE=$?
if [ "$CODE" -eq 0 ] && ! printf '%s' "$OUT" | grep -q 'deny'; then
    echo "PASS: approved commit passes clean (exit 0, no deny)"; PASS=$((PASS+1))
else
    echo "FAIL: approved commit mis-gated (exit $CODE)"; FAIL=$((FAIL+1))
fi
rm -f "$SENTINEL"

# 17: PowerShell-tool payload — on Windows, Claude Code runs shell commands
# through the PowerShell tool, so the hook must gate its payloads identically
# to Bash ones (the matcher-level fix widens registration to Bash|PowerShell;
# this pins that the script itself is tool-agnostic on the payload).
rm -f "$SENTINEL" "$DOCS_SENTINEL"
stage "hooks/thing.sh"
run "PowerShell-tool git commit blocked without sign-off" \
    '{"tool_name":"PowerShell","tool_input":{"command":"git commit -m \"feat: from windows\""}}' \
    2

# 18: PowerShell-tool payload with sign-off → allowed
echo "approved" > "$SENTINEL"
run "PowerShell-tool git commit allowed with sign-off" \
    '{"tool_name":"PowerShell","tool_input":{"command":"git commit -m \"feat: from windows\""}}' \
    0
rm -f "$SENTINEL"

# 19: Regression — `git -C <path> commit` is now caught (commit #6 hardening).
# Previously, this would bypass the gate. Verify it is now blocked when no sentinel.
rm -f "$SENTINEL" "$DOCS_SENTINEL"
stage "hooks/thing.sh"
run "git -C path commit blocked without sign-off" \
    '{"tool_name":"Bash","tool_input":{"command":"git -C /tmp/subdir commit -m \"feat: from subdir\""}}' \
    2

# 20: Regression — `git -c key=value commit` is now caught (commit #6 hardening).
# Previously, this would bypass the gate. Verify it is now blocked when no sentinel.
rm -f "$SENTINEL" "$DOCS_SENTINEL"
stage "hooks/thing.sh"
run "git -c config commit blocked without sign-off" \
    '{"tool_name":"Bash","tool_input":{"command":"git -c user.name=testuser commit -m \"feat: with config\""}}' \
    2

# 21: Regression — #7 `-a`/`--all` fix: `git commit -a` must consider
# modified-but-unstaged tracked files (not just the staged set). Scenario:
# a code file (hooks/thing.sh) exists and is modified but NOT staged, only
# the DOC sentinel is present. `git commit -a` should auto-stage the code
# file via the -a flag, then classify the commit as mixed or code, and block
# because the code sentinel is missing. Before fix #7, this would wrongly pass
# as doc-only because the classifier only looked at the staged set.
rm -f "$SENTINEL" "$DOCS_SENTINEL"
echo "approved" > "$DOCS_SENTINEL"
# Create and track a code file, then modify it (without staging)
mkdir -p hooks
printf 'x\n' > hooks/thing.sh
git add hooks/thing.sh >/dev/null 2>&1
git commit -q -m "initial: track code file" 2>/dev/null
printf 'y\n' > hooks/thing.sh
# Unstage everything from prior cases (but keep tracked files tracked)
git reset -q 2>/dev/null
# Stage only a doc file; the code file is modified but unstaged
mkdir -p g-docs
printf 'x\n' > g-docs/notes.md
git add g-docs/notes.md >/dev/null 2>&1
run "git commit -a with unstaged code blocked when only doc sentinel present" \
    '{"tool_name":"Bash","tool_input":{"command":"git commit -a -m \"fix: code + docs\""}}' \
    2
rm -f "$DOCS_SENTINEL"

# 22: Regression — #7 explicit-pathspec fix: when `git commit <pathspec>` is used,
# the pathspec argument names code paths that the classifier must include in the
# file-set classification, even if the staged index alone is doc-only. Scenario:
# only the DOC sentinel is present (no CODE sentinel), hooks/thing.sh exists as
# a tracked file, only a doc file is staged, and `git commit hooks/thing.sh -m "fix"`
# is executed. The pathspec pulls hooks/thing.sh (code) into the classification,
# making it mixed (code + doc), so it should block due to missing CODE sentinel.
# Before fix #7, this would wrongly pass as doc-only because the classifier
# ignored the explicit pathspec and only inspected the staged set.
rm -f "$SENTINEL" "$DOCS_SENTINEL"
echo "approved" > "$DOCS_SENTINEL"
# Ensure hooks/thing.sh is tracked (commit to history to make it tracked)
mkdir -p hooks
printf 'x\n' > hooks/thing.sh
git add hooks/thing.sh >/dev/null 2>&1
git commit -q -m "case 22: track code file" 2>/dev/null
# Use git reset -q to unstage but keep files tracked (not git rm -r --cached)
git reset -q 2>/dev/null
# Stage only a doc file; code file is tracked but unstaged
mkdir -p g-docs
printf 'x\n' > g-docs/notes.md
git add g-docs/notes.md >/dev/null 2>&1
# Run commit with explicit pathspec naming the code file — should block because
# the pathspec adds a code file to the staged-set union during classification
run "git commit with explicit code pathspec blocked when only doc sentinel present" \
    '{"tool_name":"Bash","tool_input":{"command":"git commit hooks/thing.sh -m \"fix: code via pathspec\""}}' \
    2
rm -f "$DOCS_SENTINEL"

# Reset the index so any later cases see a clean (empty) staged set.
stage

cd / && rm -rf "$WORKDIR"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
