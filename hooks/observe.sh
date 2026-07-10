#!/bin/bash
# G-Forge silent observer — maintains a passive activity journal.
# Wired to PostToolUse(Bash) and SessionStart. Writes NOTHING to stdout:
# it observes, it never interrupts. The daily journal it produces is the
# raw material /g-retro later synthesizes into a retrospective — no
# end-of-session interview required.
#
# Journal: .claude/journal/YYYY-MM-DD.jsonl  (append-only, one event per line)
#   {"ts":"<iso8601>","kind":"<kind>","detail":"<text>"}
#
# Usage: observe.sh log      # PostToolUse — categorize the Bash command
#        observe.sh session  # SessionStart — mark a session open

MODE="${1:-log}"
JOURNAL_DIR=".claude/journal"
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DAY=$(date -u +"%Y-%m-%d")
JOURNAL="$JOURNAL_DIR/$DAY.jsonl"

# G-Forge project guard — journal only inside a G-Forge-managed project (one that
# ran /g-init, which writes .claude/integration-tier). Stays silent (and cheap)
# everywhere else, so multiple registration sources never cause it to misfire.
[ -f ".claude/integration-tier" ] || exit 0

# `light` tier means the user opted G-Forge out — don't journal either.
if [ -f ".claude/integration-tier" ]; then
    _t=$(tr -d '[:space:]' < .claude/integration-tier 2>/dev/null)
    [ "$_t" = "light" ] && exit 0
fi

mkdir -p "$JOURNAL_DIR" 2>/dev/null || exit 0

append() {
    # $1 = kind, $2 = detail. Escape for JSON, strip newlines, cap length.
    local kind="$1" detail="$2"
    detail=$(printf '%s' "$detail" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr -d '\n\r' | cut -c1-300)
    printf '{"ts":"%s","kind":"%s","detail":"%s"}\n' "$TS" "$kind" "$detail" >> "$JOURNAL" 2>/dev/null || true
}

if [ "$MODE" = "session" ]; then
    BRANCH=$(git branch --show-current 2>/dev/null || echo unknown)
    append "session" "session opened on $BRANCH"
    exit 0
fi

# Extract the tool command from a PostToolUse JSON payload. Same hardened
# cascade as the commit gate: probe each parser before trusting it (the
# Windows Microsoft-Store python3 stub fails the probe), then fall back to
# the raw payload. Never depend on a lone silenced interpreter.
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

INPUT=$(cat 2>/dev/null)
CMD=$(extract_cmd "$INPUT")
[ -z "$CMD" ] && CMD="$INPUT"
[ -z "$CMD" ] && exit 0

# Journal only meaningful workflow events — not every `ls` and `cat`.
# Commit detection is hardened ahead of the case: a glob pattern can't express
# tolerance for `-C <path>` / `-c key=value` global flags between `git` and
# `commit`, so probe with the same regex the sibling hooks use before the case.
if printf '%s' "$CMD" | grep -qE '(^|[^[:alnum:]-])git([[:space:]]+-[cC][[:space:]]*[^[:space:]]+)*[[:space:]]+commit([[:space:]]|$)'; then
    append "commit" "$CMD"
    exit 0
fi
case "$CMD" in
    *"git push"*)                            append "push"        "$CMD" ;;
    *"git merge"*)                           append "merge"       "$CMD" ;;
    *"git checkout -b"*|*"git switch -c"*)   append "branch"      "$CMD" ;;
    *"git revert"*)                          append "revert"      "$CMD" ;;
    *npm\ test*|*"pytest"*|*"make test"*|*"bun test"*|*yarn\ test*|*go\ test*|*cargo\ test*|*vitest*|*jest*)
                                             append "test"        "$CMD" ;;
    *"rm -rf"*)                              append "destructive" "$CMD" ;;
    *) : ;;  # uninteresting — stay silent
esac
exit 0
