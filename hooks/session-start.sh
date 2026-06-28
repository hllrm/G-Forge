#!/bin/bash
# G-Forge session-start hook — repo sync and branch health check.
# Fires once per session (SessionStart event). Fetches remote state
# in the background while checking local state, then reports any gaps.

# Consume stdin payload if present.
if [ ! -t 0 ]; then
    _STDIN_PAYLOAD=$(cat - 2>/dev/null || true)
    : "${_STDIN_PAYLOAD:=}"
fi

# G-Forge project guard — act only inside a G-Forge-managed project (one that ran
# /g-init, which writes .claude/integration-tier). Keeps the hook inert everywhere
# else, so multiple registration sources never cause it to misfire.
[ -f ".claude/integration-tier" ] || exit 0

# SessionStart carries a `source`: startup | resume | clear | compact.
# A `compact` start is NOT a fresh session — it's the same session continuing
# after context compression. Treating it as fresh (and resetting the context-depth
# counter) is what let a deep session compact over and over without ever tripping
# the §A7 reset gate. Only `compact` is special-cased; an unknown/absent source
# falls through to the normal reset (backward-compatible).
SESSION_SOURCE=$(printf '%s' "${_STDIN_PAYLOAD:-}" \
    | grep -oE '"source"[[:space:]]*:[[:space:]]*"[a-zA-Z]+"' | head -1 \
    | grep -oE '"[a-zA-Z]+"$' | tr -d '"')

# Only meaningful inside a git repo.
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    exit 0
fi

BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

echo "[G-Forge Session Start]"
echo "  Branch: $BRANCH"

# Kick off a background fetch so local checks run in parallel.
timeout 5 git fetch origin --quiet --no-tags 2>/dev/null &
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

# Reset the per-session counters so workflow-checkpoint tracks context depth from
# session open — but ONLY on a genuinely new session. A `compact` SessionStart is
# the same session continuing, so its counters must carry across (the depth counter
# keeps climbing toward the §A7 threshold; the compaction count keeps accumulating).
if [ "$SESSION_SOURCE" = "compact" ]; then
    : # same session post-compaction — preserve counters
else
    printf '0\n' > ".claude/session-prompt-count" 2>/dev/null || true
    printf '0\n' > ".claude/session-compaction-count" 2>/dev/null || true
fi
