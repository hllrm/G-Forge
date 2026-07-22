#!/bin/bash
# G-Forge session-start hook — repo sync and branch health check.
# Fires once per session (SessionStart event). Fetches remote state
# in the background while checking local state, then reports any gaps.

# Sources shared lib helpers so worktree resolution agrees with the ADR-004/005
# native pre-commit hook instead of drifting apart across hand-edited
# implementations. Resolved relative to this script's own location so the
# installed copy (.claude/hooks/session-start.sh, with libs under
# .claude/hooks/lib/) finds its libs the same way the repo source
# (hooks/session-start.sh, hooks/lib/) does.
_GF_HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/worktree-resolve.sh
. "$_GF_HOOK_DIR/lib/worktree-resolve.sh"
# shellcheck source=lib/stdin-read.sh
[ -f "$_GF_HOOK_DIR/lib/stdin-read.sh" ] && . "$_GF_HOOK_DIR/lib/stdin-read.sh"

# Consume stdin payload if present. Moved below lib-sourcing so it can use
# the bounded hooks/lib/stdin-read.sh helper instead of a bare blocking
# `cat`; missing lib degrades to an unset/empty _STDIN_PAYLOAD via the guard
# below.
if [ ! -t 0 ]; then
    _STDIN_PAYLOAD=$(gf_read_stdin_timeout 5)
    : "${_STDIN_PAYLOAD:=}"
fi

# G-Forge project guard — act only inside a G-Forge-managed project (one that ran
# /g-init, which writes .claude/integration-tier). Keeps the hook inert everywhere
# else, so multiple registration sources never cause it to misfire.
#
# Local-first-else-primary (ADR-005), via the shared canonical guard
# (gf_guard_claude_dir(), hooks/lib/worktree-resolve.sh): if this worktree has
# its own .claude/integration-tier, behave exactly as before. Otherwise (a
# linked worktree with no local .claude/ of its own) resolve the PRIMARY
# working tree's .claude/ dir and check its integration-tier instead. Any
# resolution failure or empty result is treated as "not a G-Forge project"
# and exits silently — this guard is NON-GATING and must never block a
# session start. GF_CLAUDE_DIR is the resolved base this hook reads/writes
# throughout below — tier read and counter reset/preserve alike (W1.6
# counter-path unification) — not merely activation-only followed by a bare
# LOCAL .claude/ path; a linked worktree's counters live alongside its
# resolved primary tree's .claude/, same as the tier read.
GF_CLAUDE_DIR=$(gf_guard_claude_dir) || exit 0

# Integration tier — mirrors the read idiom in hooks/workflow-checkpoint.sh
# (lines 59-67): `full` (default) and `balanced` behave exactly as before;
# `light` is manual mode and must stay fully silent per the tier model in
# g-rules-B-workflow.md ("light = workflow-checkpoint only, G-Forge silent").
# Read via GF_CLAUDE_DIR (not a bare local path) so a linked worktree's tier
# decision matches the project guard it was just resolved against above.
TIER="full"
if [ -f "$GF_CLAUDE_DIR/integration-tier" ]; then
    _t=$(tr -d '[:space:]' < "$GF_CLAUDE_DIR/integration-tier" 2>/dev/null)
    case "$_t" in
        full|balanced|light) TIER="$_t" ;;
    esac
fi

# SessionStart carries a `source`: startup | resume | clear | compact.
# A `compact` start is NOT a fresh session — it's the same session continuing
# after context compression. `resume` reloads a PRIOR transcript back into the
# window too — per the 2026-07-22 decision (see
# g-docs/agent-output/wave-w3-1/characterize-resume-counter.md), it gets the
# same treatment as `compact`: resetting the depth counter on either is what
# let a deep/resumed session climb back toward the limit without ever
# re-tripping the §A7 gate. Only `compact`/`resume` are special-cased; `clear`
# and an unknown/absent source fall through to the normal reset
# (backward-compatible) — `clear` is an explicit context wipe, unlike resume's
# reload, so resetting on it is the intentionally correct behavior.
SESSION_SOURCE=$(printf '%s' "${_STDIN_PAYLOAD:-}" \
    | grep -oE '"source"[[:space:]]*:[[:space:]]*"[a-zA-Z]+"' | head -1 \
    | grep -oE '"[a-zA-Z]+"$' | tr -d '"')

# Session identity — the prompt counter is keyed per-session (M-audit W3
# task 14) so a startup/clear reset in ONE session can never clobber a
# CONCURRENT session's depth tracking on the same project (previously both
# sessions shared one project-wide session-prompt-count file). Claude Code's
# SessionStart/UserPromptSubmit payloads carry a stable `session_id` for the
# life of the session — unchanged across `compact` (same running process)
# and reused across `resume` (the platform resumes BY session id, so the
# resumed process keeps the same id), which is exactly what makes "preserve"
# above continue to work without any extra plumbing. If a payload omits
# `session_id` (older Claude Code, manual invocation, most of this suite's
# synthetic fixtures) there is no disambiguating signal available to a bash
# hook — falling back to the legacy bare filename is the graceful degrade:
# single-session behavior identical to before this fix, not a crash or a
# silent miscount, just no concurrent-session isolation without an id.
# session-compaction-count stays project-scoped on purpose (unchanged below)
# — the §A7 auto-calibration offset it feeds is a project-wide learning
# signal, not a per-session one.
SESSION_ID=$(printf '%s' "${_STDIN_PAYLOAD:-}" \
    | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[a-zA-Z0-9_-]+"' | head -1 \
    | grep -oE '"[a-zA-Z0-9_-]+"$' | tr -d '"')
PROMPT_COUNT_FILE="$GF_CLAUDE_DIR/session-prompt-count"
[ -n "$SESSION_ID" ] && PROMPT_COUNT_FILE="$GF_CLAUDE_DIR/session-prompt-count.$SESSION_ID"

# Only meaningful inside a git repo.
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    exit 0
fi

# Banner + network sync — skipped entirely on `light` (manual mode, G-Forge
# silent). The counter reset below is state maintenance, not banner output,
# so it stays outside this block and still runs on every tier.
if [ "$TIER" != "light" ]; then
    BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

    echo "[G-Forge Session Start]"
    echo "  Branch: $BRANCH"

    # Kick off a background fetch so local checks run in parallel. `timeout`
    # isn't guaranteed to be on PATH everywhere (minimal containers, some
    # BusyBox/Alpine images) — guard it explicitly (M-audit W3 task 15)
    # rather than let a missing binary silently swallow the whole fetch
    # attempt (an unguarded `timeout 5 …` simply fails to exec when
    # `timeout` is absent, so `git fetch` never runs at all, with no signal
    # to the developer). Fall back to an untimed background fetch instead —
    # still non-blocking, only the hard 5s cap is lost.
    if command -v timeout >/dev/null 2>&1; then
        timeout 5 git fetch origin --quiet --no-tags 2>/dev/null &
    else
        git fetch origin --quiet --no-tags 2>/dev/null &
    fi
    FETCH_PID=$!

    # --- Local state (no network required) ---
    DIRTY_COUNT=$(git status --porcelain 2>/dev/null | wc -l | tr -d '[:space:]')
    STASH_COUNT=$(git stash list 2>/dev/null | wc -l | tr -d '[:space:]')

    [ "$DIRTY_COUNT" -gt 0 ] && echo "  ~ $DIRTY_COUNT uncommitted change(s)"
    [ "$STASH_COUNT" -gt 0 ] && echo "  📦 $STASH_COUNT stash(es) pending"

    # --- Remote state (wait for fetch) ---
    wait "$FETCH_PID" 2>/dev/null

    BEHIND=$(git rev-list "HEAD..origin/$BRANCH" --count 2>/dev/null || echo 0)
    AHEAD=$(git rev-list "origin/$BRANCH..HEAD" --count 2>/dev/null || echo 0)

    [ "$BEHIND" -gt 0 ] && echo "  ⚠ $BEHIND commit(s) behind origin/$BRANCH — git pull"
    [ "$AHEAD" -gt 0 ]  && echo "  ↑ $AHEAD commit(s) ahead of origin/$BRANCH (unpushed)"

    # Warn when a feature branch has drifted behind origin/main.
    if [ "$BRANCH" != "main" ] && [ "$BRANCH" != "master" ]; then
        MAIN_BEHIND=$(git rev-list "HEAD..origin/main" --count 2>/dev/null || echo 0)
        [ "$MAIN_BEHIND" -gt 0 ] && echo "  ⚠ $MAIN_BEHIND commit(s) behind origin/main — consider rebasing"
    fi

    # Clean summary when there is nothing to report.
    if [ "$DIRTY_COUNT" -eq 0 ] && [ "$STASH_COUNT" -eq 0 ] && \
       [ "$BEHIND" -eq 0 ]       && [ "$AHEAD" -eq 0 ]; then
        echo "  ✓ Clean and in sync with remote"
    fi
fi

# Reset the per-session counters so workflow-checkpoint tracks context depth from
# session open — but ONLY on a genuinely new session. Both `compact` (same
# process continuing after context compression) and `resume` (same session id,
# prior transcript reloaded — see the SESSION_SOURCE comment above) carry their
# counters across instead of resetting: the depth counter keeps climbing toward
# the §A7 threshold; the compaction count keeps accumulating. PROMPT_COUNT_FILE
# is keyed per-session (SESSION_ID, above), so this reset only ever touches
# THIS session's own counter file, never a concurrent session's on the same
# project. session-compaction-count stays project-scoped (unchanged/unkeyed).
if [ "$SESSION_SOURCE" = "compact" ] || [ "$SESSION_SOURCE" = "resume" ]; then
    : # same session continuing — preserve counters
else
    printf '0\n' > "$PROMPT_COUNT_FILE" 2>/dev/null || true
    printf '0\n' > "$GF_CLAUDE_DIR/session-compaction-count" 2>/dev/null || true
fi
