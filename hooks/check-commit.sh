#!/bin/bash
# G-Forge commit gate — PreToolUse hook.
# Blocks git commit if .claude/g-forge-approved does not exist.
# Input: Claude Code PreToolUse JSON on stdin.

# Extract the tool command from a PreToolUse JSON payload.
# Never trust a lone interpreter whose failure we've silenced: probe each
# parser before use (the Windows Microsoft-Store `python3` stub fails the
# probe), and fall back to the caller's raw-payload grep if none works.
# Fails safe toward gating — see tests/test-check-commit.sh.
extract_cmd() {
    local payload="$1" cmd=""
    if command -v jq >/dev/null 2>&1; then
        cmd=$(printf '%s' "$payload" | jq -r '.tool_input.command // .command // ""' 2>/dev/null)
    fi
    if [ -z "$cmd" ] && python3 -c 'import sys' >/dev/null 2>&1; then
        cmd=$(printf '%s' "$payload" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', '') or d.get('command', ''))
except Exception:
    pass
" 2>/dev/null)
    fi
    if [ -z "$cmd" ] && command -v node >/dev/null 2>&1; then
        cmd=$(printf '%s' "$payload" | node -e "
let s='';process.stdin.on('data',d=>s+=d).on('end',()=>{try{const d=JSON.parse(s);process.stdout.write((d.tool_input&&d.tool_input.command)||d.command||'');}catch(e){}});
" 2>/dev/null)
    fi
    printf '%s' "$cmd"
}

INPUT=$(cat)
CMD=$(extract_cmd "$INPUT")
# No parser yielded a command (missing/stubbed) → grep the raw payload, which
# still contains "command":"git commit …". Fails toward enforcing the gate.
[ -z "$CMD" ] && CMD="$INPUT"

if echo "$CMD" | grep -q "git commit"; then
    # Integration tier check — `light` disables the commit gate entirely.
    # Validate the value against the known tier set; unknown/garbage values
    # fall through safely to the gate path (default = enforcement).
    TIER="full"
    if [ -f ".claude/integration-tier" ]; then
        _raw=$(tr -d '[:space:]' < .claude/integration-tier 2>/dev/null)
        case "$_raw" in
            full|balanced|light) TIER="$_raw" ;;
        esac
    fi
    if [ "$TIER" = "light" ]; then
        # Light mode — gate is off. Exit 0 without checking the sentinel.
        exit 0
    fi

    if [ ! -f ".claude/g-forge-approved" ]; then
        echo "G-Forge: No code-lead sign-off. Run /g-review and wait for MERGE READY before committing." >&2
        echo "G-Forge: (To disable the gate for this project, run /g-tier light — opt-out mode.)" >&2
        exit 1
    fi
    # Advisory: warn when committing directly to main with approval
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
        echo "G-Forge: Note — committing directly to main. Non-trivial work should be on a feature branch (feat/<slug>, fix/<slug>)." >&2
    fi
fi
