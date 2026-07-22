#!/bin/bash
# G-Forge post-commit cleanup — PostToolUse hook.
# Clears both .claude/g-forge-approved (commit sentinel) and
# .claude/g-forge-docs-approved (docs sentinel) after a successful git commit.
# Input: Claude Code PostToolUse JSON on stdin.

# Sources shared lib helpers so commit detection and worktree resolution
# agree with the ADR-004 native pre-commit hook and the check-commit.sh
# PreToolUse gate instead of drifting apart across hand-edited
# implementations (M-audit finding #21 / BUG-2). Resolved relative to this
# script's own location so the installed copy
# (.claude/hooks/post-commit-cleanup.sh, with libs under .claude/hooks/lib/)
# finds its libs the same way the repo source
# (hooks/post-commit-cleanup.sh, hooks/lib/) does.
_GF_HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/commit-detect.sh
. "$_GF_HOOK_DIR/lib/commit-detect.sh"
# shellcheck source=lib/worktree-resolve.sh
. "$_GF_HOOK_DIR/lib/worktree-resolve.sh"
# shellcheck source=lib/stdin-read.sh
[ -f "$_GF_HOOK_DIR/lib/stdin-read.sh" ] && . "$_GF_HOOK_DIR/lib/stdin-read.sh"

# Extract the tool command from a PostToolUse JSON payload.
# Never trust a lone interpreter whose failure we've silenced: probe each
# parser before use (the Windows Microsoft-Store `python3` stub fails the
# probe). If none work, fall back to a portable sed extraction of the
# "command" field's raw string value. If even that finds nothing, the
# caller falls back to the raw payload as a last resort.
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

# Bounded read (hooks/lib/stdin-read.sh) — a bare `cat` here left this hook
# orphaned for 66 minutes in the field when stdin had no writer and no EOF.
if command -v gf_read_stdin_timeout >/dev/null 2>&1; then
    INPUT=$(gf_read_stdin_timeout 5)
else
    INPUT=""
fi

# G-Forge project guard — act only inside a G-Forge-managed project (one that ran
# /g-init, which writes .claude/integration-tier). Keeps the hook inert everywhere
# else, so multiple registration sources never cause it to misfire.
#
# ADR-005 — worktree primary-state resolution: a linked git worktree has no
# local .claude/ of its own (gitignored, so it's simply absent in a fresh
# worktree). Before treating that as "not a G-Forge project", try resolving
# the PRIMARY working tree's .claude/ via the shared lib
# (hooks/lib/worktree-resolve.sh) and use it if the primary is itself a
# gated project — a worktree of a gated project gets its sentinels cleared
# through the primary's .claude/, the same directory check-commit.sh's gate
# and hooks/pre-commit read/consume for this worktree (mirrors
# check-commit.sh's GF_CLAUDE_DIR resolution, hooks/check-commit.sh
# ~lines 102-131). GF_CLAUDE_DIR is the resolved base for both sentinel
# paths below; it defaults to the local "." tree, which keeps the
# primary-tree / non-worktree path byte-identical to before this change.
#
# This hook is NON-GATING (unlike check-commit.sh's deny() path): any
# resolution failure or ambiguity here — gf_guard_claude_dir returning
# nothing (rc1) — just exits 0, clearing nothing. It never blocks and
# never guesses which sentinel to clear. gf_guard_claude_dir()
# (hooks/lib/worktree-resolve.sh) is the single shared implementation of
# the local-.claude-else-resolved-primary decision every non-gating hook
# in this repo needs (ADR-005).
GF_CLAUDE_DIR=$(gf_guard_claude_dir) || exit 0

CMD=$(extract_cmd "$INPUT")
# No parser yielded a command (missing/stubbed) → grep the raw payload.
[ -z "$CMD" ] && CMD="$INPUT"

if is_git_commit "$CMD"; then
    rm -f "$GF_CLAUDE_DIR/g-forge-approved"
    rm -f "$GF_CLAUDE_DIR/g-forge-docs-approved"
fi
