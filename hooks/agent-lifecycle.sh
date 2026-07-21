#!/bin/bash
# G-Forge agent lifecycle logger.
# Wired to SubagentStart and SubagentStop hooks in hooks.json.
# Logs to .claude/g-forge-agent-log.jsonl (back-compat) AND appends to the
# silent-observer daily journal (.claude/journal/YYYY-MM-DD.jsonl) so
# /g-retro can synthesize from a single timeline. Echoes a status note.
#
# Usage: bash hooks/agent-lifecycle.sh start|stop
#
# Sources shared lib helpers so worktree resolution agrees with the ADR-004
# native pre-commit hook and the commit gate instead of drifting apart across
# hand-edited implementations (M-audit finding #21 / BUG-2). Resolved
# relative to this script's own location so the installed copy
# (.claude/hooks/agent-lifecycle.sh, with libs under .claude/hooks/lib/)
# finds its libs the same way the repo source (hooks/agent-lifecycle.sh,
# hooks/lib/) does.
_GF_HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/worktree-resolve.sh
. "$_GF_HOOK_DIR/lib/worktree-resolve.sh"

EVENT="${1:-unknown}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# G-Forge project guard — act only inside a G-Forge-managed project (one that ran
# /g-init, which writes .claude/integration-tier). Keeps the hook inert everywhere
# else, so multiple registration sources never cause it to misfire.
#
# Local-first-else-primary (ADR-005; developer decision 2026-07-15: one
# project = one /g-retro timeline): a local .claude/integration-tier means
# this IS the primary tree (or a standalone, non-worktree project) — behave
# exactly as before. Otherwise this may be a linked worktree of a gated
# primary tree; resolve the primary .claude/ via the shared helper and defer
# entirely to its tier + log/journal. This hook is NON-GATING — any
# resolution failure or ambiguity exits silently rather than guessing or
# blocking.
GF_CLAUDE_DIR=$(gf_guard_claude_dir) || exit 0
IS_LINKED_WORKTREE=0
[ "$GF_CLAUDE_DIR" != ".claude" ] && IS_LINKED_WORKTREE=1

# Linked-worktree events tag the log/journal line with which worktree fired
# it (gf_worktree_key — the absolute --show-toplevel path), since every
# linked worktree of a gated primary now shares that primary's single log +
# journal. Escaped the same way as the "agent" field is written below for
# JSON safety. Primary-tree events stay byte-identical to the historical
# format; only linked-worktree events (with a resolved WT_KEY) gain the "wt"
# field.
WT_KEY=""
if [ "$IS_LINKED_WORKTREE" -eq 1 ]; then
    WT_KEY=$(gf_worktree_key 2>/dev/null | sed 's/\\/\\\\/g; s/"/\\"/g' | tr -d '\n\r')
fi

LOG_FILE="$GF_CLAUDE_DIR/g-forge-agent-log.jsonl"
JOURNAL_DIR="$GF_CLAUDE_DIR/journal"
JOURNAL="$JOURNAL_DIR/$(date -u +%Y-%m-%d).jsonl"

mkdir -p "$GF_CLAUDE_DIR"

INPUT=$(cat)

# Extract agent_type / agent_id / (on stop) the leading RESULT: line, from
# the REAL SubagentStart/SubagentStop payload shape (captured live from this
# repo's own harness — M-audit finding #22): `agent_type`, `agent_id`,
# `hook_event_name`, and on stop, `last_assistant_message` (whose first line
# begins "RESULT: DONE|FAILED|BLOCKED" for wave agents). The old chain
# (`.agent_name // .name // .subagent_name // .type`) probed keys that never
# existed on a real payload and always fell through to "unknown" — dropped.
#
# Each extractor distinguishes "field present but empty string" (real signal
# — internal agents fire SubagentStop with agent_type:"" and no matching
# start; not a dispatch failure) from "tier unavailable / payload
# unparseable" by checking the parser's own exit status, not just testing
# the result for emptiness — an empty result is data here, not a probe
# failure. jq first, then probed python3 (the Windows Microsoft-Store stub
# fails the probe), then node, then a best-effort raw grep (which cannot
# make that present-vs-absent distinction and collapses both to "unknown" —
# acceptable degradation for the last-resort tier only).
extract_agent_type() {
    local payload="$1" val rc

    if command -v jq >/dev/null 2>&1; then
        val=$(printf '%s' "$payload" | jq -r '.agent_type // "unknown"' 2>/dev/null)
        rc=$?
        if [ "$rc" -eq 0 ]; then printf '%s' "$val"; return 0; fi
    fi
    if python3 -c 'import sys' >/dev/null 2>&1; then
        val=$(printf '%s' "$payload" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    v = d.get('agent_type')
    print(v if v is not None else 'unknown')
except Exception:
    sys.exit(1)
" 2>/dev/null)
        rc=$?
        if [ "$rc" -eq 0 ]; then printf '%s' "$val"; return 0; fi
    fi
    if command -v node >/dev/null 2>&1; then
        val=$(printf '%s' "$payload" | node -e "
let s='';process.stdin.on('data',d=>s+=d).on('end',()=>{try{const d=JSON.parse(s);const v=d.agent_type;process.stdout.write((v===undefined||v===null)?'unknown':String(v));}catch(e){process.exit(1);}});
" 2>/dev/null)
        rc=$?
        if [ "$rc" -eq 0 ]; then printf '%s' "$val"; return 0; fi
    fi
    val=$(printf '%s' "$payload" | sed -n 's/.*"agent_type"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
    [ -z "$val" ] && val="unknown"
    printf '%s' "$val"
}

extract_agent_id() {
    local payload="$1" val rc

    if command -v jq >/dev/null 2>&1; then
        val=$(printf '%s' "$payload" | jq -r '.agent_id // empty' 2>/dev/null)
        rc=$?
        if [ "$rc" -eq 0 ]; then printf '%s' "${val:0:8}"; return 0; fi
    fi
    if python3 -c 'import sys' >/dev/null 2>&1; then
        val=$(printf '%s' "$payload" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('agent_id') or '')
except Exception:
    sys.exit(1)
" 2>/dev/null)
        rc=$?
        if [ "$rc" -eq 0 ]; then printf '%s' "${val:0:8}"; return 0; fi
    fi
    if command -v node >/dev/null 2>&1; then
        val=$(printf '%s' "$payload" | node -e "
let s='';process.stdin.on('data',d=>s+=d).on('end',()=>{try{const d=JSON.parse(s);process.stdout.write(d.agent_id||'');}catch(e){process.exit(1);}});
" 2>/dev/null)
        rc=$?
        if [ "$rc" -eq 0 ]; then printf '%s' "${val:0:8}"; return 0; fi
    fi
    val=$(printf '%s' "$payload" | sed -n 's/.*"agent_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
    printf '%s' "${val:0:8}"
}

# Stop-only: pull the leading "RESULT: DONE|FAILED|BLOCKED" token out of
# last_assistant_message (wave agents end their final message with it).
# Missing field, empty message, or a first line that doesn't start with
# "RESULT:" all omit gracefully (empty stdout, rc 1) — never fails the hook.
extract_result() {
    local payload="$1" msg="" first

    if command -v jq >/dev/null 2>&1; then
        msg=$(printf '%s' "$payload" | jq -r '.last_assistant_message // empty' 2>/dev/null)
    fi
    if [ -z "$msg" ] && python3 -c 'import sys' >/dev/null 2>&1; then
        msg=$(printf '%s' "$payload" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('last_assistant_message') or '')
except Exception:
    pass
" 2>/dev/null)
    fi
    if [ -z "$msg" ] && command -v node >/dev/null 2>&1; then
        msg=$(printf '%s' "$payload" | node -e "
let s='';process.stdin.on('data',d=>s+=d).on('end',()=>{try{const d=JSON.parse(s);process.stdout.write(d.last_assistant_message||'');}catch(e){}});
" 2>/dev/null)
    fi
    [ -z "$msg" ] && return 1

    # First line only — a multi-KB agent transcript must never reach the
    # journal line; strip CR for CRLF transcripts.
    first=$(printf '%s\n' "$msg" | head -n 1 | tr -d '\r')
    case "$first" in
        RESULT:*)
            printf '%s' "$first" | sed 's/^RESULT:[[:space:]]*//'
            return 0
            ;;
        *) return 1 ;;
    esac
}

# JSON-escape (backslash, then quote, then strip CR/LF) — same treatment
# already applied to WT_KEY above, extended here to every field derived from
# payload content so a stray quote/backslash in an id or a RESULT line can
# never break the emitted JSON (journal control-char minor #W3 — don't add
# to it).
json_escape() {
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr -d '\n\r'
}

AGENT_TYPE_RAW=$(extract_agent_type "$INPUT")
AGENT_ID=$(json_escape "$(extract_agent_id "$INPUT")")

RESULT_VAL=""
if [ "$EVENT" = "stop" ]; then
    RESULT_VAL=$(json_escape "$(extract_result "$INPUT")")
fi

# Display value: an explicit empty agent_type (internal agents' SubagentStop
# — see finding #22 anomaly note) renders as "internal" so the imbalance
# class stays attributable instead of collapsing into "unknown" (reserved
# for genuine extraction failure / malformed payload). Used both for the
# back-compat log's "agent" field and the journal detail below.
AGENT=$(json_escape "$AGENT_TYPE_RAW")
[ -z "$AGENT" ] && AGENT="internal"

if [ "$IS_LINKED_WORKTREE" -eq 1 ] && [ -n "$WT_KEY" ]; then
    echo "{\"event\":\"$EVENT\",\"agent\":\"$AGENT\",\"timestamp\":\"$TIMESTAMP\",\"wt\":\"$WT_KEY\"}" >> "$LOG_FILE"
else
    echo "{\"event\":\"$EVENT\",\"agent\":\"$AGENT\",\"timestamp\":\"$TIMESTAMP\"}" >> "$LOG_FILE"
fi

# Journal detail: "<agent_type> <event> <agent_id8>[ <RESULT>]".
DETAIL="$AGENT $EVENT"
[ -n "$AGENT_ID" ] && DETAIL="$DETAIL $AGENT_ID"
[ -n "$RESULT_VAL" ] && DETAIL="$DETAIL $RESULT_VAL"

# Mirror into the unified journal (skip on `light` tier — observer is off).
_tier=""
[ -f "$GF_CLAUDE_DIR/integration-tier" ] && _tier=$(tr -d '[:space:]' < "$GF_CLAUDE_DIR/integration-tier" 2>/dev/null)
if [ "$_tier" != "light" ]; then
    mkdir -p "$JOURNAL_DIR" 2>/dev/null && \
    if [ "$IS_LINKED_WORKTREE" -eq 1 ] && [ -n "$WT_KEY" ]; then
        printf '{"ts":"%s","kind":"agent","detail":"%s","wt":"%s"}\n' "$TIMESTAMP" "$DETAIL" "$WT_KEY" >> "$JOURNAL" 2>/dev/null || true
    else
        printf '{"ts":"%s","kind":"agent","detail":"%s"}\n' "$TIMESTAMP" "$DETAIL" >> "$JOURNAL" 2>/dev/null || true
    fi
fi

if [ "$EVENT" = "start" ]; then
    echo "[G-Forge] agent '$AGENT' started"
elif [ "$EVENT" = "stop" ]; then
    echo "[G-Forge] agent '$AGENT' finished"
fi
