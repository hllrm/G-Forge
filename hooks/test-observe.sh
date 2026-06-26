#!/bin/bash
# Unit tests for hooks/observe.sh (the silent observer).
# Verifies: meaningful commands are journaled with the right kind, noise is
# skipped, the journal is valid JSONL, and the parser survives a stubbed
# python3 (the Windows Microsoft-Store stub) without losing events.

SCRIPT="$(cd "$(dirname "$0")" && pwd)/observe.sh"
PASS=0
FAIL=0

check() { # name expected actual
    if [ "$2" = "$3" ]; then echo "PASS: $1"; PASS=$((PASS+1));
    else echo "FAIL: $1 (expected '$2', got '$3')"; FAIL=$((FAIL+1)); fi
}

# kind_of <command> [PATH-override] — run observe.sh on a payload, return the
# journaled kind (empty string if the command was skipped as noise).
kind_of() {
    local dir; dir=$(mktemp -d); ( cd "$dir" && git init -q )
    if [ -n "$2" ]; then
        echo "{\"tool_input\":{\"command\":\"$1\"}}" | ( cd "$dir" && PATH="$2" bash "$SCRIPT" log )
    else
        echo "{\"tool_input\":{\"command\":\"$1\"}}" | ( cd "$dir" && bash "$SCRIPT" log )
    fi
    local f; f=$(ls "$dir"/.claude/journal/*.jsonl 2>/dev/null | head -1)
    if [ -n "$f" ]; then jq -r '.kind' "$f" 2>/dev/null | head -1; fi
    rm -rf "$dir"
}

check "git commit → commit"            "commit"      "$(kind_of 'git commit -m wip')"
check "git push → push"                "push"        "$(kind_of 'git push origin main')"
check "git merge → merge"              "merge"       "$(kind_of 'git merge main')"
check "git checkout -b → branch"       "branch"      "$(kind_of 'git checkout -b feat/x')"
check "git revert → revert"            "revert"      "$(kind_of 'git revert HEAD')"
check "pytest → test"                  "test"        "$(kind_of 'pytest -q')"
check "npm test → test"                "test"        "$(kind_of 'npm test')"
check "go test → test"                 "test"        "$(kind_of 'go test ./...')"
check "rm -rf → destructive"           "destructive" "$(kind_of 'rm -rf build')"
check "ls (noise) → skipped"           ""            "$(kind_of 'ls -la')"
check "cat (noise) → skipped"          ""            "$(kind_of 'cat file.txt')"

# Stub safety: python3 is the Windows Store stub, and no jq/node on PATH.
# The raw-payload fallback must still recognise the commit and journal it.
STUB=$(mktemp -d); BIN=$(mktemp -d)
cat > "$STUB/python3" <<'EOF'
#!/bin/sh
echo "Python was not found; run without arguments to install from the Microsoft Store..." >&2
exit 1
EOF
chmod +x "$STUB/python3"
for t in bash sh cat grep printf echo rm mkdir tr dirname env git sed cut ls date; do
    p=$(command -v "$t"); [ -n "$p" ] && ln -sf "$p" "$BIN/$t" 2>/dev/null
done
ln -sf "$STUB/python3" "$BIN/python3"   # jq and node intentionally absent
check "commit journaled under python3 stub" "commit" "$(kind_of 'git commit -m wip' "$BIN")"
rm -rf "$STUB" "$BIN"

# Session marker.
SDIR=$(mktemp -d); ( cd "$SDIR" && git init -q && bash "$SCRIPT" session )
SKIND=$(jq -r '.kind' "$SDIR"/.claude/journal/*.jsonl 2>/dev/null | head -1)
check "session marker written" "session" "$SKIND"
# Journal must be valid JSONL.
if jq -e . "$SDIR"/.claude/journal/*.jsonl >/dev/null 2>&1; then
    echo "PASS: journal is valid JSONL"; PASS=$((PASS+1))
else
    echo "FAIL: journal is not valid JSONL"; FAIL=$((FAIL+1))
fi
rm -rf "$SDIR"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
