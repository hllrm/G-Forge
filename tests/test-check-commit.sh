#!/bin/bash
# Unit tests for hooks/check-commit.sh

SCRIPT="$(dirname "$0")/../hooks/check-commit.sh"
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

# 6: Regression — Windows Microsoft-Store python3 stub (prints to stderr,
# exits non-zero) must NOT make the gate fall open. With no working parser,
# the hook falls back to grepping the raw payload and still blocks.
# Simulate by shadowing python3 with a stub and exposing only a minimal PATH
# (no jq, no node) so the raw-payload fallback is the only thing left.
STUBDIR="$(mktemp -d)"
BINDIR="$(mktemp -d)"
cat > "$STUBDIR/python3" <<'STUB'
#!/bin/sh
echo "Python was not found; run without arguments to install from the Microsoft Store..." >&2
exit 1
STUB
chmod +x "$STUBDIR/python3"
for t in bash sh cat grep printf echo rm mkdir tr dirname env git; do
    p="$(command -v "$t")"; [ -n "$p" ] && ln -sf "$p" "$BINDIR/$t" 2>/dev/null
done
ln -sf "$STUBDIR/python3" "$BINDIR/python3"   # jq and node intentionally absent
rm -f "$SENTINEL"
echo '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"x\""}}' \
    | PATH="$BINDIR" bash "$SCRIPT" >/dev/null 2>&1
if [ $? -eq 1 ]; then
    echo "PASS: gate enforced when python3 is the Store stub (no jq/node)"; PASS=$((PASS+1))
else
    echo "FAIL: gate fell OPEN under python3 stub (the Windows bug)"; FAIL=$((FAIL+1))
fi
rm -rf "$STUBDIR" "$BINDIR"
rm -f .claude/integration-tier

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
