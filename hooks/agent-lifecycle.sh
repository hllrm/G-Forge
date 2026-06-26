#!/bin/bash
# G-Forge agent lifecycle logger.
# Wired to SubagentStart and SubagentStop hooks in hooks.json.
# Logs to .claude/g-forge-agent-log.jsonl (back-compat) AND appends to the
# silent-observer daily journal (.claude/journal/YYYY-MM-DD.jsonl) so
# /g-retro can synthesize from a single timeline. Echoes a status note.
#
# Usage: bash hooks/agent-lifecycle.sh start|stop

EVENT="${1:-unknown}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG_FILE=".claude/g-forge-agent-log.jsonl"
JOURNAL_DIR=".claude/journal"
JOURNAL="$JOURNAL_DIR/$(date -u +%Y-%m-%d).jsonl"

mkdir -p .claude

INPUT=$(cat)

# Extract the agent name. Probe python3 before trusting it — the Windows
# Microsoft-Store stub prints to stderr and exits non-zero; a silenced
# failure must not poison the result. jq first, then probed python3, then
# node, then a best-effort raw grep.
extract_agent() {
    local payload="$1" name=""
    if command -v jq >/dev/null 2>&1; then
        name=$(printf '%s' "$payload" | jq -r '.agent_name // .name // .subagent_name // .type // ""' 2>/dev/null)
    fi
    if [ -z "$name" ] && python3 -c 'import sys' >/dev/null 2>&1; then
        name=$(printf '%s' "$payload" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('agent_name') or d.get('name') or d.get('subagent_name') or d.get('type') or '')
except Exception:
    pass
" 2>/dev/null)
    fi
    if [ -z "$name" ] && command -v node >/dev/null 2>&1; then
        name=$(printf '%s' "$payload" | node -e "
let s='';process.stdin.on('data',d=>s+=d).on('end',()=>{try{const d=JSON.parse(s);process.stdout.write(d.agent_name||d.name||d.subagent_name||d.type||'');}catch(e){}});
" 2>/dev/null)
    fi
    [ -z "$name" ] && name="unknown"
    printf '%s' "$name"
}

AGENT=$(extract_agent "$INPUT")

echo "{\"event\":\"$EVENT\",\"agent\":\"$AGENT\",\"timestamp\":\"$TIMESTAMP\"}" >> "$LOG_FILE"

# Mirror into the unified journal (skip on `light` tier — observer is off).
_tier=""
[ -f ".claude/integration-tier" ] && _tier=$(tr -d '[:space:]' < .claude/integration-tier 2>/dev/null)
if [ "$_tier" != "light" ]; then
    mkdir -p "$JOURNAL_DIR" 2>/dev/null && \
    printf '{"ts":"%s","kind":"agent","detail":"%s %s"}\n' "$TIMESTAMP" "$AGENT" "$EVENT" >> "$JOURNAL" 2>/dev/null || true
fi

if [ "$EVENT" = "start" ]; then
    echo "[G-Forge] agent '$AGENT' started"
elif [ "$EVENT" = "stop" ]; then
    echo "[G-Forge] agent '$AGENT' finished"
fi
