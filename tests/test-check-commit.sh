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

cd / && rm -rf "$WORKDIR"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
