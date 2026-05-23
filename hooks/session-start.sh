#!/bin/bash
# G-Forge session-start hook — repo sync and branch health check.
# Fires once per session (SessionStart event). Fetches remote state
# in the background while checking local state, then reports any gaps.

# Consume stdin payload if present.
if [ ! -t 0 ]; then
    _STDIN_PAYLOAD=$(cat - 2>/dev/null || true)
    : "${_STDIN_PAYLOAD:=}"
fi

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
