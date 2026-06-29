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

# G-Forge project guard — act only inside a G-Forge-managed project (one that ran
# /g-init, which writes .claude/integration-tier). Keeps the gate inert everywhere
# else, so it never blocks commits in a project that doesn't use G-Forge — and so
# multiple registration sources can never make it misfire.
[ -f ".claude/integration-tier" ] || exit 0

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

    # File-set classifier — the gate triggers on WHAT is being committed, not
    # merely that a commit is happening. Two review surfaces, two sentinels:
    #   CODE (executable/instruction surface) → /g-review writes .claude/g-forge-approved
    #   DOC  (narrative documentation surface) → /g-doc-review writes .claude/g-forge-docs-approved
    # A commit is classified by its staged file set into one of four buckets:
    #   code  — only CODE paths            → require the code sentinel (unchanged behavior)
    #   doc   — only DOC paths             → require the doc sentinel
    #   mixed — both present               → require BOTH sentinels
    #   none  — empty staged set / unknown → fall through to the code gate (fail safe)
    # Unmatched paths default to CODE (the stricter gate) so a misclassification
    # never weakens enforcement.
    STAGED=$(git diff --cached --name-only 2>/dev/null)
    HAS_CODE=0
    HAS_DOC=0
    while IFS= read -r _f; do
        [ -z "$_f" ] && continue
        case "$_f" in
            # DOC paths — narrative documentation surface (M27: "doc-only
            # changes — wiki, README, ADRs"). Documentation directories first.
            g-docs/*|g-wiki/*|docs/*) HAS_DOC=1 ;;
            # Root-level documentation files (README*, CHANGELOG*, LICENSE*) and
            # any root-level *.md (no slash in the path = repo root) treated as docs.
            README*|CHANGELOG*|LICENSE*) HAS_DOC=1 ;;
            *.md) case "$_f" in */*) HAS_CODE=1 ;; *) HAS_DOC=1 ;; esac ;;
            # CODE paths — plugin executable/instruction surface. .claude/rules/
            # is instruction surface (code); anything under it gates as code.
            hooks/*|skills/*|agents/*|commands/*|profiles/*|tests/*|.claude-plugin/*|.claude/rules/*) HAS_CODE=1 ;;
            # When in doubt, treat as CODE — the code gate is the stricter one.
            *) HAS_CODE=1 ;;
        esac
    done <<EOF
$STAGED
EOF

    if [ "$HAS_CODE" -eq 1 ] && [ "$HAS_DOC" -eq 1 ]; then
        CLASS="mixed"
    elif [ "$HAS_DOC" -eq 1 ]; then
        CLASS="doc"
    elif [ "$HAS_CODE" -eq 1 ]; then
        CLASS="code"
    else
        # Empty staged set or no parseable paths — preserve existing behavior by
        # routing through the code gate (the historical default).
        CLASS="code"
    fi

    if [ "$CLASS" = "doc" ]; then
        if [ ! -f ".claude/g-forge-docs-approved" ]; then
            echo "G-Forge: No doc-review sign-off. Run /g-doc-review and wait for its verdict before committing documentation." >&2
            echo "G-Forge: (To disable the gate for this project, run /g-tier light — opt-out mode.)" >&2
            exit 1
        fi
    elif [ "$CLASS" = "mixed" ]; then
        if [ ! -f ".claude/g-forge-approved" ] && [ ! -f ".claude/g-forge-docs-approved" ]; then
            echo "G-Forge: Mixed commit (code + docs) needs both sign-offs. Run /g-review (code) and /g-doc-review (docs) before committing." >&2
            echo "G-Forge: (To disable the gate for this project, run /g-tier light — opt-out mode.)" >&2
            exit 1
        fi
        if [ ! -f ".claude/g-forge-approved" ]; then
            echo "G-Forge: Mixed commit missing code sign-off. Run /g-review and wait for MERGE READY before committing." >&2
            echo "G-Forge: (To disable the gate for this project, run /g-tier light — opt-out mode.)" >&2
            exit 1
        fi
        if [ ! -f ".claude/g-forge-docs-approved" ]; then
            echo "G-Forge: Mixed commit missing doc sign-off. Run /g-doc-review and wait for its verdict before committing." >&2
            echo "G-Forge: (To disable the gate for this project, run /g-tier light — opt-out mode.)" >&2
            exit 1
        fi
    elif [ ! -f ".claude/g-forge-approved" ]; then
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
