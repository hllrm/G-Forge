#!/bin/bash
# pre-compact.sh — PreCompact hook for G-Forge Claude Code plugin
# Fires before context compression. Writes .claude/compact-state.md so the
# next session can recover context without re-briefing. Must never exit 1.

# Consume stdin to avoid broken pipe (PreCompact may or may not send JSON)
cat > /dev/null 2>&1

# Sources the shared worktree-resolution lib so the project guard below can
# resolve a linked worktree's PRIMARY .claude/ the same way check-commit.sh
# does (ADR-005). Resolved relative to this script's own location so the
# installed copy (.claude/hooks/pre-compact.sh, with libs under
# .claude/hooks/lib/) finds its libs the same way the repo source
# (hooks/pre-compact.sh, hooks/lib/) does.
_GF_HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/worktree-resolve.sh
. "$_GF_HOOK_DIR/lib/worktree-resolve.sh"

# G-Forge project guard — act only inside a G-Forge-managed project (one that ran
# /g-init, which writes .claude/integration-tier). Keeps the hook inert everywhere
# else, so multiple registration sources never cause it to misfire.
#
# ADR-005 — worktree primary-state resolution: a linked git worktree has no
# local .claude/ of its own (gitignored, so it's simply absent in a fresh
# worktree). Before treating that as "not a G-Forge project", try resolving
# the PRIMARY working tree's .claude/ via the shared canonical guard
# (gf_guard_claude_dir(), hooks/lib/worktree-resolve.sh) purely to decide
# whether this hook should activate — a worktree of a gated project inherits
# activation instead of silently no-op'ing. This hook is NON-GATING (it must
# never block or deny), so any resolution failure or ambiguity just falls
# through to a silent `exit 0` below, never an escalation. GF_CLAUDE_DIR is
# activation-only here — all state below (this hook's writes) still targets
# the LOCAL .claude/, unchanged.
GF_CLAUDE_DIR=$(gf_guard_claude_dir) || exit 0

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "unknown")

# Ensure .claude/ exists in the developer's project directory
mkdir -p .claude 2>/dev/null

# Record that this session compacted. Auto-compaction is the strongest
# "context overloaded" signal there is — workflow-checkpoint.sh reads this count
# and escalates the §A7 reset recommendation (auto-/g-retro + fresh session).
# Reset to 0 by session-start.sh only on a genuinely new session, never on the
# compact-source SessionStart that follows this hook.
CC_FILE=".claude/session-compaction-count"
_cc=0
[ -f "$CC_FILE" ] && _cc=$(tr -dc '0-9' < "$CC_FILE" 2>/dev/null)
[ -z "$_cc" ] && _cc=0
printf '%d\n' "$((_cc + 1))" > "$CC_FILE" 2>/dev/null || true

# Auto-calibration: a compaction means the gate's thresholds were too loose for
# this project's burn rate. Grow the persistent offset (never reset) so
# workflow-checkpoint.sh fires amber/red earlier next time — converging toward
# zero compactions. Step 5 per compaction, capped at 30 (the per-mode floors in
# workflow-checkpoint.sh stop thresholds collapsing regardless).
OFF_FILE=".claude/context-threshold-offset"
_off=0
[ -f "$OFF_FILE" ] && _off=$(tr -dc '0-9' < "$OFF_FILE" 2>/dev/null)
[ -z "$_off" ] && _off=0
_off=$((_off + 5))
[ "$_off" -gt 30 ] && _off=30
printf '%d\n' "$_off" > "$OFF_FILE" 2>/dev/null || true

# Collect git state
BRANCH=$(git branch --show-current 2>/dev/null || echo "not a git repo")
COMMITS=$(git log --oneline -5 2>/dev/null || echo "no commits found")

# Snapshot the single canonical handoff — the `## Active Session` block in
# g-docs/ROADMAP.md. Capture everything under that heading up to the next `## ` heading,
# so the full Done/Next up/Active context block is preserved (not just the header).
if [ -f "g-docs/ROADMAP.md" ]; then
  HANDOFF=$(awk '/^## Active Session/{cap=1; next} cap && /^## /{exit} cap{print}' g-docs/ROADMAP.md 2>/dev/null)
  if [ -z "$HANDOFF" ]; then
    HANDOFF="(No '## Active Session' handoff found in g-docs/ROADMAP.md)"
  fi
else
  HANDOFF="g-docs/ROADMAP.md not found"
fi

# Write compact-state.md
cat > .claude/compact-state.md << EOF
# Compact State — ${TIMESTAMP}

## Branch
${BRANCH}

## Recent commits
${COMMITS}

## Handoff at compaction
${HANDOFF}

---
*Written by pre-compact hook at ${TIMESTAMP}. Load this file at session start to recover context.*
EOF

exit 0
