#!/bin/bash
# Unit tests for hooks/observe.sh (the silent observer) + hooks/agent-lifecycle.sh.
# Verifies: meaningful commands are journaled with the right kind, noise is
# skipped, the journal is valid JSONL, and the parser survives a stubbed
# python3 (the Windows Microsoft-Store stub) without losing events.
# Also tests: agent-lifecycle extraction of agent_type, agent_id, and RESULT
# tokens from real SubagentStart/SubagentStop payloads (M-audit finding #22 fix).
# Total assertions: 22 (16 original observe tests + 6 new agent-lifecycle extraction tests).

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
# Hardening #6 — commit detection tolerates -C/-c global flags before `commit`.
check "git -C path commit → commit"    "commit"      "$(kind_of 'git -C /some/path commit -m x')"
check "git -c config commit → commit"  "commit"      "$(kind_of 'git -c user.name=x commit -m x')"

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

# ============================================================================
# Agent-lifecycle extraction tests (M-audit finding #22 fix).
# Test the agent_type / agent_id / RESULT extraction from real harness payloads
# and journal detail formatting: "<agent_type> <event> <agent_id8>[ <RESULT>]"
# ============================================================================

AGENT_SCRIPT="$(cd "$(dirname "$0")" && pwd)/../hooks/agent-lifecycle.sh"

# agent_lifecycle_detail <event> <payload-json> — run agent-lifecycle.sh on a
# real payload and extract the journal detail field from the output.
agent_lifecycle_detail() {
    local event="$1" payload="$2" dir
    dir=$(mktemp -d)
    ( cd "$dir" && git init -q && mkdir -p .claude && printf 'full\n' > .claude/integration-tier )
    printf '%s' "$payload" | ( cd "$dir" && bash "$AGENT_SCRIPT" "$event" 2>&1 )
    rm -rf "$dir"
}

# agent_lifecycle_journal <event> <payload-json> — extract the journal detail
# line (if any) from the agent-lifecycle hook output.
agent_lifecycle_journal() {
    local event="$1" payload="$2" dir jfile detail
    dir=$(mktemp -d)
    ( cd "$dir" && git init -q && mkdir -p .claude && printf 'full\n' > .claude/integration-tier )
    printf '%s' "$payload" | ( cd "$dir" && bash "$AGENT_SCRIPT" "$event" >/dev/null 2>&1 )
    jfile=$(ls "$dir"/.claude/journal/*.jsonl 2>/dev/null | head -1)
    if [ -n "$jfile" ]; then
        # Extract detail field using sed (portable, no jq dependency in tests)
        sed -n 's/.*"detail":"\([^"]*\)".*/\1/p' "$jfile" | head -1
    fi
    rm -rf "$dir"
}

# agent_lifecycle_jsonl <event> <payload-json> — extract the raw journal line
# (if any) from the agent-lifecycle hook output for JSON validity checks.
agent_lifecycle_jsonl() {
    local event="$1" payload="$2" dir jfile
    dir=$(mktemp -d)
    ( cd "$dir" && git init -q && mkdir -p .claude && printf 'full\n' > .claude/integration-tier )
    printf '%s' "$payload" | ( cd "$dir" && bash "$AGENT_SCRIPT" "$event" >/dev/null 2>&1 )
    jfile=$(ls "$dir"/.claude/journal/*.jsonl 2>/dev/null | head -1)
    if [ -n "$jfile" ]; then
        head -1 "$jfile"
    fi
    rm -rf "$dir"
}

# Real payload fixture: SubagentStart with claude-plugin-implementer agent
PAYLOAD_START='{"session_id":"s1","transcript_path":"/tmp/t.jsonl","cwd":"/tmp","prompt_id":"p1","agent_id":"a7653079b1995bdc8","agent_type":"claude-plugin-implementer","hook_event_name":"SubagentStart"}'

# Real payload fixture: SubagentStop with wave agent (has RESULT: DONE line)
PAYLOAD_STOP_WAVE='{"session_id":"s1","transcript_path":"/tmp/t.jsonl","cwd":"/tmp","prompt_id":"p1","agent_id":"a7653079b1995bdc8","agent_type":"claude-plugin-implementer","permission_mode":"auto","effort":{"level":"high"},"hook_event_name":"SubagentStop","stop_hook_active":false,"agent_transcript_path":"/tmp/a.jsonl","last_assistant_message":"RESULT: DONE\nSUMMARY: x","background_tasks":[],"session_crons":[]}'

# Real payload fixture: SubagentStop with internal agent (empty agent_type)
PAYLOAD_STOP_INTERNAL='{"session_id":"s1","transcript_path":"/tmp/t.jsonl","cwd":"/tmp","prompt_id":"p1","agent_id":"a7653079b1995bdc8","agent_type":"","permission_mode":"auto","effort":{"level":"high"},"hook_event_name":"SubagentStop","stop_hook_active":false,"agent_transcript_path":"/tmp/a.jsonl","last_assistant_message":"go","background_tasks":[],"session_crons":[]}'

# Real payload fixture: SubagentStop with quotes and backslash in RESULT line
# (must not break the JSON line emitted to the journal)
PAYLOAD_STOP_QUOTED='{"session_id":"s1","transcript_path":"/tmp/t.jsonl","cwd":"/tmp","prompt_id":"p1","agent_id":"a7653079b1995bdc8","agent_type":"test-agent","hook_event_name":"SubagentStop","stop_hook_active":false,"agent_transcript_path":"/tmp/a.jsonl","last_assistant_message":"RESULT: DONE\nfixed \"path\\\\file\" issue","background_tasks":[]}'

# Test 1: Start payload extracts agent_type and agent_id correctly
DETAIL1=$(agent_lifecycle_journal "start" "$PAYLOAD_START")
if echo "$DETAIL1" | grep -q "claude-plugin-implementer start a7653079"; then
    echo "PASS: start payload → journal contains 'claude-plugin-implementer start a7653079'"; PASS=$((PASS+1))
else
    echo "FAIL: start payload → expected detail to contain 'claude-plugin-implementer start a7653079', got '$DETAIL1'"; FAIL=$((FAIL+1))
fi

# Test 2: Wave-agent stop extracts RESULT: DONE token
DETAIL2=$(agent_lifecycle_journal "stop" "$PAYLOAD_STOP_WAVE")
if echo "$DETAIL2" | grep -q "claude-plugin-implementer stop a7653079 DONE"; then
    echo "PASS: wave-agent stop → journal contains 'claude-plugin-implementer stop a7653079 DONE'"; PASS=$((PASS+1))
else
    echo "FAIL: wave-agent stop → expected detail to contain 'claude-plugin-implementer stop a7653079 DONE', got '$DETAIL2'"; FAIL=$((FAIL+1))
fi

# Test 3: Internal stop (empty agent_type) renders as "internal", not "unknown"
DETAIL3=$(agent_lifecycle_journal "stop" "$PAYLOAD_STOP_INTERNAL")
if [ -n "$DETAIL3" ] && echo "$DETAIL3" | grep -q "^internal stop"; then
    echo "PASS: internal stop → detail begins 'internal stop'"; PASS=$((PASS+1))
else
    echo "FAIL: internal stop → expected detail to begin 'internal stop', got '$DETAIL3'"; FAIL=$((FAIL+1))
fi
if echo "$DETAIL3" | grep -q "unknown"; then
    echo "FAIL: internal stop → detail should not contain 'unknown', got '$DETAIL3'"; FAIL=$((FAIL+1))
else
    echo "PASS: internal stop → detail contains no 'unknown'"; PASS=$((PASS+1))
fi

# Test 4: Empty stdin is handled gracefully (exit 0, absent-payload labeled as 'unknown start')
EMPTY_DETAIL=$(agent_lifecycle_journal "start" "")
if [ "$EMPTY_DETAIL" = "unknown start" ]; then
    echo "PASS: empty stdin → journal detail is 'unknown start' (absent-payload marker)"; PASS=$((PASS+1))
else
    echo "FAIL: empty stdin → expected detail 'unknown start', got '$EMPTY_DETAIL'"; FAIL=$((FAIL+1))
fi

# Test 5: Quotes and backslashes in RESULT line do not break JSON; detail ends with RESULT token
DETAIL5=$(agent_lifecycle_journal "stop" "$PAYLOAD_STOP_QUOTED")
JSONL5=$(agent_lifecycle_jsonl "stop" "$PAYLOAD_STOP_QUOTED")
if [ -n "$JSONL5" ]; then
    # Check JSON validity: line must start with { and end with }
    case "$JSONL5" in
        '{'*'}')
            # Check that detail ends with the parsed RESULT token (content beyond RESULT is deliberately not preserved)
            if echo "$DETAIL5" | grep -q 'test-agent stop a7653079 DONE$'; then
                echo "PASS: quoted/backslash in RESULT → JSON valid and detail ends with RESULT token"; PASS=$((PASS+1))
            else
                echo "FAIL: quoted/backslash in RESULT → detail did not end with RESULT token, got '$DETAIL5'"; FAIL=$((FAIL+1))
            fi
            ;;
        *)
            echo "FAIL: quoted/backslash in RESULT → journal line is not valid JSON"; FAIL=$((FAIL+1))
            ;;
    esac
else
    echo "FAIL: quoted/backslash in RESULT → no journal line emitted"; FAIL=$((FAIL+1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
