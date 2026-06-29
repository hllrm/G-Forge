#!/bin/bash
# Unit tests for hooks/observe.sh (the silent observer).
# Verifies: meaningful commands are journaled with the right kind, noise is
# skipped, the journal is valid JSONL, and the parser survives a stubbed
# python3 (the Windows Microsoft-Store stub) without losing events.

SCRIPT="$(cd "$(dirname "$0")" && pwd)/../hooks/observe.sh"
PASS=0
FAIL=0

check() { # name expected actual
    if [ "$2" = "$3" ]; then echo "PASS: $1"; PASS=$((PASS+1));
    else echo "FAIL: $1 (expected '$2', got '$3')"; FAIL=$((FAIL+1)); fi
}

# kind_of <command> [PATH-override] — run observe.sh on a payload, return the
# journaled kind (empty string if the command was skipped as noise).
kind_of() {
    # The hook self-guards to G-Forge-managed projects (.claude/integration-tier);
    # mark each fixture as one so the observer is active.
    local dir; dir=$(mktemp -d); ( cd "$dir" && git init -q && mkdir -p .claude && printf 'full\n' > .claude/integration-tier )
    if [ -n "$2" ]; then
        echo "{\"tool_input\":{\"command\":\"$1\"}}" | ( cd "$dir" && PATH="$2" bash "$SCRIPT" log )
    else
        echo "{\"tool_input\":{\"command\":\"$1\"}}" | ( cd "$dir" && bash "$SCRIPT" log )
    fi
    local f; f=$(ls "$dir"/.claude/journal/*.jsonl 2>/dev/null | head -1)
    # Read the kind with sed, not jq — stock git-bash has no jq, and the hook
    # must not depend on it either. Journal lines are a fixed flat shape.
    if [ -n "$f" ]; then sed -n 's/.*"kind":"\([^"]*\)".*/\1/p' "$f" | head -1; fi
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

# Stub safety: shadow every JSON parser (jq/python3/node) with exit-1 stubs
# prepended to the real PATH, so no parser yields a command. The raw-payload
# fallback must still recognise the commit and journal it. (Replacing PATH
# wholesale by symlinking coreutils breaks git-bash — bash.exe can't load its
# DLLs from a bare symlink dir — so we shadow the parsers, not the environment.)
STUB=$(mktemp -d)
for p in jq python3 node; do printf '#!/bin/sh\nexit 1\n' > "$STUB/$p"; chmod +x "$STUB/$p"; done
check "commit journaled with no working parser" "commit" "$(kind_of 'git commit -m wip' "$STUB:$PATH")"
rm -rf "$STUB"

# Session marker.
SDIR=$(mktemp -d); ( cd "$SDIR" && git init -q && mkdir -p .claude && printf 'full\n' > .claude/integration-tier && bash "$SCRIPT" session )
JFILE=$(ls "$SDIR"/.claude/journal/*.jsonl 2>/dev/null | head -1)
SKIND=$(sed -n 's/.*"kind":"\([^"]*\)".*/\1/p' "$JFILE" 2>/dev/null | head -1)
check "session marker written" "session" "$SKIND"
# Journal must be valid JSONL. Portable shape check (no jq): every non-empty
# line is a single brace-wrapped object carrying the ts + kind keys.
valid=1; lines=0
while IFS= read -r line; do
    [ -z "$line" ] && continue
    lines=$((lines+1))
    case "$line" in
        '{"ts":"'*'","kind":"'*'"'*'}') : ;;
        *) valid=0 ;;
    esac
done < "$JFILE"
if [ "$valid" -eq 1 ] && [ "$lines" -ge 1 ]; then
    echo "PASS: journal is valid JSONL"; PASS=$((PASS+1))
else
    echo "FAIL: journal is not valid JSONL"; FAIL=$((FAIL+1))
fi
rm -rf "$SDIR"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
