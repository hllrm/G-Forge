#!/bin/bash
# Unit tests for hooks/check-commit.sh
# Runs entirely inside a throwaway fixture dir so the suite never mutates the
# repo's own .claude/ (an earlier version deleted .claude/integration-tier in
# the repo root, silently disabling the hooks for the project).

SCRIPT="$(cd "$(dirname "$0")" && pwd)/../hooks/check-commit.sh"
SENTINEL=".claude/g-forge-approved"
PASS=0
FAIL=0

run() {
    local name="$1" input="$2" expected="$3"
    echo "$input" | bash "$SCRIPT" 2>/dev/null
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
    1

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
    1

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
if [ $? -eq 1 ]; then
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
    1

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
    1
rm -f "$SENTINEL"

# 10: mixed commit (code + doc) blocked when only the code sentinel is present
rm -f "$SENTINEL" "$DOCS_SENTINEL"
echo "approved" > "$SENTINEL"
stage "hooks/thing.sh" "g-docs/notes.md"
run "mixed commit blocked with only code sign-off" \
    '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feat: code + docs\""}}' \
    1
rm -f "$SENTINEL"

# 11: mixed commit blocked when only the doc sentinel is present
rm -f "$SENTINEL" "$DOCS_SENTINEL"
echo "approved" > "$DOCS_SENTINEL"
stage "hooks/thing.sh" "g-docs/notes.md"
run "mixed commit blocked with only doc sign-off" \
    '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feat: code + docs\""}}' \
    1
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
    1
rm -f "$DOCS_SENTINEL"

# Reset the index so any later cases see a clean (empty) staged set.
stage

cd / && rm -rf "$WORKDIR"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
