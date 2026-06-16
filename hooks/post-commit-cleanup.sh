#!/bin/bash
# G-Team post-commit cleanup — PostToolUse hook.
# Clears .claude/g-forge-approved after a successful git commit.
# Input: Claude Code PostToolUse JSON on stdin.

INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    cmd = d.get('tool_input', {}).get('command', '') or d.get('command', '')
    print(cmd)
except Exception:
    pass
" 2>/dev/null)

if echo "$CMD" | grep -q "git commit"; then
    rm -f ".claude/g-forge-approved"
fi
