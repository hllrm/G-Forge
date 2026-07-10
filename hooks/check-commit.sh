#!/bin/bash
# G-Forge commit gate — PreToolUse hook.
# Blocks git commit if the required review sentinel does not exist.
# Input: Claude Code PreToolUse JSON on stdin.
#
# Enforcement contract (this is load-bearing — a plain `exit 1` does NOT block):
#   A PreToolUse hook blocks the tool ONLY via `exit 2` or a stdout JSON
#   `permissionDecision:"deny"`. Any other non-zero exit (incl. 1) is a
#   *non-blocking* error — the message is shown but the commit still runs. So
#   every block path here goes through deny(), which emits the deny JSON on
#   stdout (rich reason to the model), the reason on stderr (for the CLI user),
#   and exits 2 (the universal blocker). Never use `exit 1` to block.

# deny <reason> — block the commit. Belt-and-suspenders across Claude Code
# versions: stdout JSON deny + stderr reason + exit 2. Reasons are fixed,
# quote/backslash-free strings, so the inline JSON needs no escaping.
deny() {
    local reason="$1"
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"G-Forge: %s"}}\n' "$reason"
    printf 'G-Forge: %s\n' "$reason" >&2
    printf 'G-Forge: (To disable the gate for this project, run /g-tier light — opt-out mode.)\n' >&2
    exit 2
}

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

if printf '%s' "$CMD" | grep -qE '(^|[^[:alnum:]-])git([[:space:]]+-[cC][[:space:]]*[^[:space:]]+)*[[:space:]]+commit([[:space:]]|$)'; then
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
    # `git commit -a`/`--all` auto-stages every modified TRACKED file at commit
    # time — the index at the moment this hook runs (pre-commit) does not yet
    # reflect that. Without this, a code file left unstaged rides along under
    # a doc-only (or under-scoped) sentinel. Detect -a/--all as a standalone
    # word on the commit command (also matches combined short flags like -am,
    # -avm — a single '-' cluster containing 'a', not part of a '--' long
    # option) and, when present, widen the classifier's input to the UNION of
    # staged paths and modified-but-unstaged tracked paths (git diff
    # --name-only) — the exact set -a would fold into the index. Absent
    # -a/--all, behavior is unchanged (staged set only).
    if printf '%s' "$CMD" | grep -qE '(^|[[:space:]])(-[a-zA-Z]*a[a-zA-Z]*|--all)([[:space:]]|$)'; then
        UNSTAGED=$(git diff --name-only 2>/dev/null)
        STAGED=$(printf '%s\n%s\n' "$STAGED" "$UNSTAGED" | sort -u)
    fi
    # Explicit pathspec arguments — `git commit <pathspec>...` or
    # `git commit -- <pathspec>...` commits the NAMED paths (plus whatever of
    # them is already staged), independent of the rest of the index. Without
    # this, `git commit -m "fix" hooks/thing.sh` against an empty (or
    # doc-only) index would misclassify a code commit as doc/none. Isolate
    # the substring of CMD after the `commit` keyword, tokenize it, and walk
    # the tokens:
    #   - after a literal `--` token, every remaining token is a pathspec.
    #   - before `--`, a token starting with `-` is a flag: skip it, and if
    #     it is one of the known value-taking flags (-m/--message,
    #     -c/-C/--reuse-message/--reedit-message, -F/--file, -A/--author,
    #     --date, --template, --fixup, --squash, --trailer), also skip the
    #     NEXT token (its value — e.g. the `-m "msg"` message text is not a
    #     pathspec). `--opt=value` forms are self-contained (no extra token
    #     to skip).
    #   - any other token is a positional pathspec candidate.
    # Full git-alias resolution is out of scope. Absent any positional
    # pathspec, behavior is unchanged (staged/union set only).
    PATHSPECS=""
    _after_commit=$(printf '%s' "$CMD" | sed -E 's/^.*[[:space:]]commit([[:space:]]|$)//')
    if [ -n "$_after_commit" ]; then
        _tokens=()
        # Tokenize WITHOUT eval — eval re-parses the string as shell code and would
        # execute command substitutions/backticks embedded in the commit command
        # (even when the gate ultimately DENIES the commit). xargs does shell-style
        # quote-and-whitespace splitting but never evaluates $(...), backticks, or
        # variables, so a crafted `-m "$(...)"` message is treated as inert text.
        while IFS= read -r _tok_line; do
            _tokens+=("$_tok_line")
        done < <(printf '%s' "$_after_commit" | xargs -n1 2>/dev/null)
        _seen_dashdash=0
        _skip_next=0
        for _tok in "${_tokens[@]}"; do
            if [ "$_skip_next" -eq 1 ]; then
                _skip_next=0
                continue
            fi
            if [ "$_seen_dashdash" -eq 0 ]; then
                if [ "$_tok" = "--" ]; then
                    _seen_dashdash=1
                    continue
                fi
                case "$_tok" in
                    -m|--message|-c|--reuse-message|-C|--reedit-message|-F|--file|-A|--author|--date|--template|--fixup|--squash|--trailer)
                        _skip_next=1
                        continue
                        ;;
                    --message=*|--reuse-message=*|--reedit-message=*|--file=*|--author=*|--date=*|--template=*|--fixup=*|--squash=*|--trailer=*)
                        continue
                        ;;
                    -*)
                        continue
                        ;;
                esac
            fi
            PATHSPECS="$PATHSPECS
$_tok"
        done
    fi
    if [ -n "$(printf '%s' "$PATHSPECS" | tr -d '[:space:]')" ]; then
        STAGED=$(printf '%s\n%s\n' "$STAGED" "$PATHSPECS" | sort -u)
    fi
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
            deny "No doc-review sign-off. Run /g-doc-review and wait for its verdict before committing documentation."
        fi
    elif [ "$CLASS" = "mixed" ]; then
        if [ ! -f ".claude/g-forge-approved" ] && [ ! -f ".claude/g-forge-docs-approved" ]; then
            deny "Mixed commit (code + docs) needs both sign-offs. Run /g-review (code) and /g-doc-review (docs) before committing."
        fi
        if [ ! -f ".claude/g-forge-approved" ]; then
            deny "Mixed commit missing code sign-off. Run /g-review and wait for MERGE READY before committing."
        fi
        if [ ! -f ".claude/g-forge-docs-approved" ]; then
            deny "Mixed commit missing doc sign-off. Run /g-doc-review and wait for its verdict before committing."
        fi
    elif [ ! -f ".claude/g-forge-approved" ]; then
        deny "No code-lead sign-off. Run /g-review and wait for MERGE READY before committing."
    fi
    # Advisory: warn when committing directly to main with approval
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
        echo "G-Forge: Note — committing directly to main. Non-trivial work should be on a feature branch (feat/<slug>, fix/<slug>)." >&2
    fi
fi
