#!/bin/bash
# Unit tests for hooks/observe.sh (the silent observer) + hooks/agent-lifecycle.sh.
# Verifies: meaningful commands are journaled with the right kind, noise is
# skipped, the journal is valid JSONL, and the parser survives a stubbed
# python3 (the Windows Microsoft-Store stub) without losing events.
# Also tests: agent-lifecycle extraction of agent_type, agent_id, and RESULT
# tokens from real SubagentStart/SubagentStop payloads (M-audit finding #22 fix),
# plus a forced-node-path regression pin for JSON null agent_type (W1.5f/W1.6-15).
# W1.6-17: json_escape hostile-input coverage with adversarial chars on line 1.
# W1.6-18: sed-tier escaped-quote truncation behavior regression pin.
# Total assertions: 24 (16 original observe tests + 8 agent-lifecycle extraction/regression tests).

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

# agent_lifecycle_journal <event> <payload-json> [PATH-override] — extract the
# journal detail line (if any) from the agent-lifecycle hook output. Optional
# third arg overrides PATH (same tier-forcing idiom as kind_of's second arg
# above) so a fixture can shadow specific parsers to force a given tier.
agent_lifecycle_journal() {
    local event="$1" payload="$2" path_override="$3" dir jfile detail
    dir=$(mktemp -d)
    ( cd "$dir" && git init -q && mkdir -p .claude && printf 'full\n' > .claude/integration-tier )
    if [ -n "$path_override" ]; then
        printf '%s' "$payload" | ( cd "$dir" && PATH="$path_override" bash "$AGENT_SCRIPT" "$event" >/dev/null 2>&1 )
    else
        printf '%s' "$payload" | ( cd "$dir" && bash "$AGENT_SCRIPT" "$event" >/dev/null 2>&1 )
    fi
    jfile=$(ls "$dir"/.claude/journal/*.jsonl 2>/dev/null | head -1)
    if [ -n "$jfile" ]; then
        # Extract detail field using sed (portable, no jq dependency in tests).
        # Escape-aware capture: \\. matches any escaped char so the value can
        # contain \" and \\ without truncating at the first escaped quote
        # (returns the still-escaped form; assertions match on substrings).
        sed -n 's/.*"detail":"\(\(\\.\|[^"\\]\)*\)".*/\1/p' "$jfile" | head -1
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
# (adversarial characters on line 1 of message, not line 2, so head -n1 captures them).
# json_escape must preserve and properly escape the quotes and backslashes.
PAYLOAD_STOP_QUOTED='{"session_id":"s1","transcript_path":"/tmp/t.jsonl","cwd":"/tmp","prompt_id":"p1","agent_id":"a7653079b1995bdc8","agent_type":"test-agent","hook_event_name":"SubagentStop","stop_hook_active":false,"agent_transcript_path":"/tmp/a.jsonl","last_assistant_message":"RESULT: DONE \"path\\\\file\" survived","background_tasks":[]}'

# Real payload fixture: SubagentStart with JSON null agent_type (distinct from
# the empty-string "internal" case above — a real null must fall back to
# "unknown", not stringify to the literal "null").
PAYLOAD_START_NULL='{"session_id":"s1","transcript_path":"/tmp/t.jsonl","cwd":"/tmp","prompt_id":"p1","agent_id":"a7653079b1995bdc8","agent_type":null,"hook_event_name":"SubagentStart"}'

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

# Test 5: Quotes and backslashes in RESULT line do not break JSON; adversarial
# chars (quotes + backslashes) must be present in the parsed detail (not discarded
# by head -n1), properly json-escaped in the journal line.
DETAIL5=$(agent_lifecycle_journal "stop" "$PAYLOAD_STOP_QUOTED")
JSONL5=$(agent_lifecycle_jsonl "stop" "$PAYLOAD_STOP_QUOTED")
if [ -n "$JSONL5" ]; then
    # Check JSON validity: line must start with { and end with }
    case "$JSONL5" in
        '{'*'}')
            # Detail must contain both "path" and "file" (from the adversarial fixture),
            # proving json_escape exercised the quotes and backslashes on line 1.
            if echo "$DETAIL5" | grep -q 'test-agent stop a7653079' && \
               echo "$DETAIL5" | grep -q 'path' && echo "$DETAIL5" | grep -q 'file'; then
                echo "PASS: quoted/backslash in RESULT → JSON valid, adversarial chars preserved"; PASS=$((PASS+1))
            else
                echo "FAIL: quoted/backslash in RESULT → adversarial chars lost or detail malformed, got '$DETAIL5'"; FAIL=$((FAIL+1))
            fi
            ;;
        *)
            echo "FAIL: quoted/backslash in RESULT → journal line is not valid JSON"; FAIL=$((FAIL+1))
            ;;
    esac
else
    echo "FAIL: quoted/backslash in RESULT → no journal line emitted"; FAIL=$((FAIL+1))
fi

# Test 6: JSON null agent_type on a forced-node-path — shadow jq and python3
# with exit-1 stubs (same shadowing idiom as the STUB fixture above) so only
# the node tier can answer; JSON.parse(...).agent_type is JS `null`, and the
# node tier must map that to "unknown", never stringify it to "null".
STUB2=$(mktemp -d)
for p in jq python3; do printf '#!/bin/sh\nexit 1\n' > "$STUB2/$p"; chmod +x "$STUB2/$p"; done
DETAIL6=$(agent_lifecycle_journal "start" "$PAYLOAD_START_NULL" "$STUB2:$PATH")
if echo "$DETAIL6" | grep -q "^unknown start" && ! echo "$DETAIL6" | grep -q "null"; then
    echo "PASS: forced-node-path null agent_type → detail begins 'unknown start', never 'null'"; PASS=$((PASS+1))
else
    echo "FAIL: forced-node-path null agent_type → expected detail to begin 'unknown start' with no 'null', got '$DETAIL6'"; FAIL=$((FAIL+1))
fi
rm -rf "$STUB2"

# Test 7: Sed tier escaped-quote truncation behavior (W1.6-18 regression pin).
# The sed-tier parser (last resort when jq/python3/node all fail) uses the
# pattern [^"]* which means "match any char except literal quote". It does not
# understand JSON escaping, so an escaped quote like \" is seen as backslash
# followed by a quote terminator. For payload with agent_type "value\"truncated",
# the sed tier extracts "value\" (truncated at the escaped quote). This test
# stubs ALL THREE parsers (jq, python3, AND node) to force the sed tier, then
# verifies it produces the documented truncation behavior on escaped quotes.
STUB3=$(mktemp -d)
for p in jq python3 node; do printf '#!/bin/sh\nexit 1\n' > "$STUB3/$p"; chmod +x "$STUB3/$p"; done
PAYLOAD_STOP_SED_ESCAPE='{"session_id":"s1","transcript_path":"/tmp/t.jsonl","cwd":"/tmp","prompt_id":"p1","agent_id":"a7653079b1995bdc8","agent_type":"sedtier\"truncated","hook_event_name":"SubagentStop","stop_hook_active":false,"agent_transcript_path":"/tmp/a.jsonl","last_assistant_message":"RESULT: DONE","background_tasks":[]}'
DETAIL7=$(agent_lifecycle_journal "stop" "$PAYLOAD_STOP_SED_ESCAPE" "$STUB3:$PATH")
# The sed tier extracts "sedtier\" (backslash is part of the payload content,
# quote is the terminator). After json_escape, the backslash is doubled, so the
# observed detail is: sedtier\\ stop <agent_id>
# The assertion must DISCRIMINATE: an escape-aware parser would instead yield
# "sedtier\"truncated", so a bare '^sedtier' anchor matches both forms and pins
# nothing. Require the doubled-backslash terminus AND the absence of the tail
# that only an escape-aware parser could recover.
if printf '%s' "$DETAIL7" | grep -qF 'sedtier\\' \
   && ! printf '%s' "$DETAIL7" | grep -qF 'truncated' \
   && printf '%s' "$DETAIL7" | grep -q 'stop'; then
    echo "PASS: sed-tier escaped-quote truncation → detail shows extraction terminated at quote"; PASS=$((PASS+1))
else
    echo "FAIL: sed-tier escaped-quote truncation → detail does not show truncation, got '$DETAIL7'"; FAIL=$((FAIL+1))
fi
rm -rf "$STUB3"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
