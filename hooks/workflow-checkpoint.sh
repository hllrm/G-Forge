#!/bin/bash
# G-Team workflow checkpoint — UserPromptSubmit hook.
# Outputs current workflow state so Claude can auto-trigger the right step.

ACTIVE_CONTEXT=""
if [ -f "ROADMAP.md" ]; then
    ACTIVE_CONTEXT=$(grep -m1 'Active context:' ROADMAP.md | sed 's/.*Active context:[[:space:]]*//')
fi

REVIEW_APPROVED=false
[ -f ".claude/g-team-approved" ] && REVIEW_APPROVED=true

CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

echo "[G-Team Workflow Checkpoint]"
echo "  Branch: $CURRENT_BRANCH"
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    echo "  ⚠  on main — non-trivial work should be on a feature branch (feat/<slug>, fix/<slug>)" >&2
fi
if [ -n "$ACTIVE_CONTEXT" ]; then
    echo "  Active: $ACTIVE_CONTEXT"
else
    echo "  Active: none"
fi
if [ "$REVIEW_APPROVED" = true ]; then
    echo "  Review: approved (commit gate open)"
else
    echo "  Review: not yet approved — run /g-team review before merging"
fi

if [ -f ".claude/tier3-active" ]; then
    BUG_COUNT=$(cat ".claude/tier3-active" 2>/dev/null || echo 0)
    echo "  Tier 3 listen mode ACTIVE — ${BUG_COUNT} bug(s) logged this round — no fixes until developer declares round complete"
fi
