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
IS_LINKED_WORKTREE=0
if [ -f ".claude/integration-tier" ]; then
    CLAUDE_DIR=".claude"
else
    CLAUDE_DIR="$(gf_resolve_primary_claude_dir 2>/dev/null)"
    if [ -z "$CLAUDE_DIR" ] || [ ! -f "$CLAUDE_DIR/integration-tier" ]; then
        exit 0
    fi
    IS_LINKED_WORKTREE=1
fi

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

LOG_FILE="$CLAUDE_DIR/g-forge-agent-log.jsonl"
JOURNAL_DIR="$CLAUDE_DIR/journal"
JOURNAL="$JOURNAL_DIR/$(date -u +%Y-%m-%d).jsonl"

mkdir -p "$CLAUDE_DIR"

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

if [ "$IS_LINKED_WORKTREE" -eq 1 ] && [ -n "$WT_KEY" ]; then
    echo "{\"event\":\"$EVENT\",\"agent\":\"$AGENT\",\"timestamp\":\"$TIMESTAMP\",\"wt\":\"$WT_KEY\"}" >> "$LOG_FILE"
else
    echo "{\"event\":\"$EVENT\",\"agent\":\"$AGENT\",\"timestamp\":\"$TIMESTAMP\"}" >> "$LOG_FILE"
fi

# Mirror into the unified journal (skip on `light` tier — observer is off).
_tier=""
[ -f "$CLAUDE_DIR/integration-tier" ] && _tier=$(tr -d '[:space:]' < "$CLAUDE_DIR/integration-tier" 2>/dev/null)
if [ "$_tier" != "light" ]; then
    mkdir -p "$JOURNAL_DIR" 2>/dev/null && \
    if [ "$IS_LINKED_WORKTREE" -eq 1 ] && [ -n "$WT_KEY" ]; then
        printf '{"ts":"%s","kind":"agent","detail":"%s %s","wt":"%s"}\n' "$TIMESTAMP" "$AGENT" "$EVENT" "$WT_KEY" >> "$JOURNAL" 2>/dev/null || true
    else
        printf '{"ts":"%s","kind":"agent","detail":"%s %s"}\n' "$TIMESTAMP" "$AGENT" "$EVENT" >> "$JOURNAL" 2>/dev/null || true
    fi
fi

if [ "$EVENT" = "start" ]; then
    echo "[G-Forge] agent '$AGENT' started"
elif [ "$EVENT" = "stop" ]; then
    echo "[G-Forge] agent '$AGENT' finished"
fi
