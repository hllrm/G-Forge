#!/bin/bash
# Regression tests for the M33 Roundtable heartbeat in hooks/workflow-checkpoint.sh.
# The load-bearing guarantee of Phase A: with NO Roundtable configured the hook output
# is byte-identical to before the Roundtable existed (null adapter). These tests pin
# that — plus the tier gate (off on light) and the bound-Roundtable nudge — inside a
# throwaway fixture so the repo's own .claude/ is never touched.
#
# Total assertions: 5
# Count is the RUNNER-OBSERVED total and must equal the `Results:` line — the
# finding-#20 cross-check that catches a suite silently dropping cases.

SCRIPT="$(cd "$(dirname "$0")" && pwd)/../hooks/workflow-checkpoint.sh"
PASS=0
FAIL=0

check() { # name expected actual
    if [ "$2" = "$3" ]; then echo "PASS: $1"; PASS=$((PASS+1));
    else echo "FAIL: $1 (expected '$2', got '$3')"; FAIL=$((FAIL+1)); fi
}

# run_hook <tier> [table-title] — run the checkpoint in a fresh fixture with the
# given integration tier, optionally binding a Roundtable (.claude/roundtable). Echoes
# whether the Roundtable-heartbeat line ("Roundtable bound") appeared: "yes" | "no".
run_hook() {
    local tier="$1" title="$2" dir
    dir=$(mktemp -d)
    (
        cd "$dir" || exit 1
        git init -q 2>/dev/null
        mkdir -p .claude
        printf '%s\n' "$tier" > .claude/integration-tier
        if [ -n "$title" ]; then
            printf 'surface=google-drive\nref=fake-id\ntitle=%s\ncreated=2026-06-30\n' "$title" > .claude/roundtable
        fi
        echo '{}' | bash "$SCRIPT" 2>/dev/null
    ) | grep -q 'Roundtable bound' && echo "yes" || echo "no"
    rm -rf "$dir"
}

# title_shown <tier> <title> — does the bound-Roundtable line carry the Doc title?
title_shown() {
    local dir; dir=$(mktemp -d)
    (
        cd "$dir" || exit 1
        git init -q 2>/dev/null
        mkdir -p .claude
        printf '%s\n' "$1" > .claude/integration-tier
        printf 'surface=google-drive\nref=fake-id\ntitle=%s\ncreated=2026-06-30\n' "$2" > .claude/roundtable
        echo '{}' | bash "$SCRIPT" 2>/dev/null
    ) | grep -q "Roundtable bound: $2" && echo "yes" || echo "no"
    rm -rf "$dir"
}

# 1: no Roundtable configured → heartbeat silent (byte-identical-to-before guarantee)
check "no Roundtable on full → heartbeat silent"      "no"  "$(run_hook full)"
# 2: no Roundtable configured on balanced → still silent
check "no Roundtable on balanced → heartbeat silent"  "no"  "$(run_hook balanced)"
# 3: Roundtable bound on full → heartbeat nudged
check "Roundtable bound on full → heartbeat shown"    "yes" "$(run_hook full my-table)"
# 4: Roundtable bound but light tier → heartbeat OFF (light exits before the block)
check "Roundtable bound on light → heartbeat OFF"     "no"  "$(run_hook light my-table)"
# 5: the nudge carries the Doc title
check "bound-Roundtable line carries the title"       "yes" "$(title_shown full standup-doc)"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
