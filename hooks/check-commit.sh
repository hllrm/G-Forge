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
#
# Sources shared lib helpers so commit detection, pathspec extraction, and
# file-set classification agree with the ADR-004 native pre-commit hook
# instead of drifting apart across two hand-edited implementations
# (M-audit finding #21 / BUG-2). Resolved relative to this script's own
# location so the installed copy (.claude/hooks/check-commit.sh, with libs
# under .claude/hooks/lib/) finds its libs the same way the repo source
# (hooks/check-commit.sh, hooks/lib/) does.
_GF_HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/classify-changeset.sh
. "$_GF_HOOK_DIR/lib/classify-changeset.sh"
# shellcheck source=lib/commit-detect.sh
. "$_GF_HOOK_DIR/lib/commit-detect.sh"
# shellcheck source=lib/worktree-resolve.sh
. "$_GF_HOOK_DIR/lib/worktree-resolve.sh"

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
# probe). If none work, fall back to a portable sed extraction of the
# "command" field's raw string value — is_git_commit() (hooks/lib/
# commit-detect.sh) tokenizes its input with `xargs -n1`, which chokes on a
# whole unparsed JSON blob (unbalanced/embedded quotes), so this tier hands
# it a clean-enough command string instead of the full payload. If even that
# finds nothing, the caller falls back to the raw payload as a last resort.
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
    if [ -z "$cmd" ]; then
        cmd=$(printf '%s' "$payload" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(\([^"\\]\|\\.\)*\)".*/\1/p')
    fi
    printf '%s' "$cmd"
}

INPUT=$(cat)

CMD=$(extract_cmd "$INPUT")
# extract_cmd() itself already falls back to a portable sed extraction when
# every JSON parser is missing/stubbed; this is the final safety net for the
# pathological case where even that yields nothing — use the raw payload so
# is_git_commit()'s tokenizer has *something* to walk. Fails toward enforcing
# the gate.
[ -z "$CMD" ] && CMD="$INPUT"

# G-Forge project guard — act only inside a G-Forge-managed project (one that ran
# /g-init, which writes .claude/integration-tier). Keeps the gate inert everywhere
# else, so it never blocks commits in a project that doesn't use G-Forge — and so
# multiple registration sources can never make it misfire.
#
# ADR-005 — worktree primary-state resolution: a linked git worktree has no
# local .claude/ of its own (gitignored, so it's simply absent in a fresh
# worktree). Before treating that as "not a G-Forge project", try resolving
# the PRIMARY working tree's .claude/ via the shared lib
# (hooks/lib/worktree-resolve.sh) and use it if the primary is itself a
# gated project — a worktree of a gated project inherits the gate instead of
# silently no-op'ing. GF_CLAUDE_DIR is the resolved base for every .claude/
# read below (tier + both sentinel existence-checks); it defaults to the
# local "." tree, which keeps the primary-tree / non-worktree path
# byte-identical to before this change. This is path resolution only — no
# per-worktree sentinel keying here (a separate follow-up per ADR-005).
GF_CLAUDE_DIR=".claude"
if [ ! -f "$GF_CLAUDE_DIR/integration-tier" ]; then
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        _primary_claude_dir=$(gf_resolve_primary_claude_dir)
        if [ -n "$_primary_claude_dir" ] && [ -f "$_primary_claude_dir/integration-tier" ]; then
            # Primary resolved AND is itself a gated project — inherit its
            # state for the rest of this run.
            GF_CLAUDE_DIR="$_primary_claude_dir"
        elif [ -n "$_primary_claude_dir" ]; then
            # Primary resolved cleanly but never ran /g-init either — neither
            # tree is gated. Not ambiguous, just genuinely ungated: inert.
            exit 0
        else
            # Inside a real git work tree, but gf_resolve_primary_claude_dir
            # printed nothing — its documented signal for ANY failure,
            # including genuine ambiguity (nested worktree,
            # --separate-git-dir, submodule, ADR-005's fail-toward-deny
            # case), not merely "no primary". Escalate to deny ONLY for a
            # CONFIRMED git commit — an unrelated command in an ambiguous
            # worktree must stay inert rather than block unrelated work.
            if is_git_commit "$CMD"; then
                deny "Could not resolve this worktree's primary G-Forge state (ambiguous or unreachable git-common-dir). Resolve the worktree layout, or run /g-init in the primary working tree, before committing here."
            fi
            exit 0
        fi
    else
        # Not inside a git work tree at all — definitely not a G-Forge project.
        exit 0
    fi
fi

if is_git_commit "$CMD"; then
    # Integration tier check — `light` disables the commit gate entirely.
    # Validate the value against the known tier set; unknown/garbage values
    # fall through safely to the gate path (default = enforcement).
    TIER="full"
    if [ -f "$GF_CLAUDE_DIR/integration-tier" ]; then
        _raw=$(tr -d '[:space:]' < "$GF_CLAUDE_DIR/integration-tier" 2>/dev/null)
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
    # doc-only) index would misclassify a code commit as doc/none. Extraction
    # (argv walk after the `commit` subcommand, flag/value-skip rules, `--`
    # handling) lives in the shared lib (hooks/lib/commit-detect.sh) so this
    # hook and the ADR-004 native pre-commit hook agree byte-for-byte — see
    # that file's header for the full rule table. Absent any positional
    # pathspec, behavior is unchanged (staged/union set only).
    PATHSPECS=$(extract_pathspecs "$CMD")
    if [ -n "$(printf '%s' "$PATHSPECS" | tr -d '[:space:]')" ]; then
        STAGED=$(printf '%s\n%s\n' "$STAGED" "$PATHSPECS" | sort -u)
    fi
    # Classification bucket rules live in the shared lib (hooks/lib/classify-changeset.sh)
    # so this hook and the ADR-004 native pre-commit hook agree byte-for-byte —
    # see that file's header for the bucket table. Sets HAS_CODE/HAS_DOC.
    gf_classify_changeset <<EOF
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
        if [ ! -f "$GF_CLAUDE_DIR/g-forge-docs-approved" ]; then
            deny "No doc-review sign-off. Run /g-doc-review and wait for its verdict before committing documentation."
        fi
    elif [ "$CLASS" = "mixed" ]; then
        if [ ! -f "$GF_CLAUDE_DIR/g-forge-approved" ] && [ ! -f "$GF_CLAUDE_DIR/g-forge-docs-approved" ]; then
            deny "Mixed commit (code + docs) needs both sign-offs. Run /g-review (code) and /g-doc-review (docs) before committing."
        fi
        if [ ! -f "$GF_CLAUDE_DIR/g-forge-approved" ]; then
            deny "Mixed commit missing code sign-off. Run /g-review and wait for MERGE READY before committing."
        fi
        if [ ! -f "$GF_CLAUDE_DIR/g-forge-docs-approved" ]; then
            deny "Mixed commit missing doc sign-off. Run /g-doc-review and wait for its verdict before committing."
        fi
    elif [ ! -f "$GF_CLAUDE_DIR/g-forge-approved" ]; then
        deny "No code-lead sign-off. Run /g-review and wait for MERGE READY before committing."
    fi
    # Advisory: warn when committing directly to main with approval
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
        echo "G-Forge: Note — committing directly to main. Non-trivial work should be on a feature branch (feat/<slug>, fix/<slug>)." >&2
    fi
fi
