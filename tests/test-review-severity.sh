#!/bin/bash
# Contract guard for the review-pipeline severity fixes (Bugs B & C).
# The pipeline is LLM-driven — its runtime behaviour can't be unit-tested here.
# What we CAN pin is the prompt contract that makes the fail-open impossible:
# the orchestrator normalizes native scales + forces FAIL on any axis HOLD +
# emits an AXES line; code-lead honours that AXES line; and every auditor's
# return-block scale matches the shared Critical/Major/Minor vocabulary it feeds.
# A future edit that reopens the mismatch fails these greps — that's the point.
#
# Total assertions: 9
# Count is the RUNNER-OBSERVED total and must equal the `Results:` line — the
# finding-#20 cross-check that catches a suite silently dropping cases.

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0

ok() { # name  test-cmd...
    local name="$1"; shift
    if "$@" >/dev/null 2>&1; then echo "PASS: $name"; PASS=$((PASS+1));
    else echo "FAIL: $name"; FAIL=$((FAIL+1)); fi
}
no() { # name  test-cmd... (asserts the grep does NOT match)
    local name="$1"; shift
    if "$@" >/dev/null 2>&1; then echo "FAIL: $name"; FAIL=$((FAIL+1));
    else echo "PASS: $name"; PASS=$((PASS+1)); fi
}

ORCH="$ROOT/agents/review-orchestrator.md"
LEAD="$ROOT/agents/code-lead.md"
PERF="$ROOT/agents/performance-auditor.md"
DEP="$ROOT/agents/dependency-auditor.md"
SEC="$ROOT/agents/security-auditor.md"

# --- Bug B: orchestrator normalization + HOLD propagation + AXES ---
ok  "orchestrator maps security High → Critical" \
    grep -qi 'Critical \*\*and High\*\*' "$ORCH"
ok  "orchestrator: any reviewer HOLD forces aggregate FAIL" \
    grep -qi 'forces aggregate \*\*\?FAIL\|forces aggregate FAIL' "$ORCH"
ok  "orchestrator return block emits an AXES line" \
    grep -q '^AXES:' "$ORCH"
ok  "code-lead treats the AXES line as authoritative (axis HOLD blocks)" \
    grep -qi 'axis is HOLD\|AXES' "$LEAD"

# --- Bug C: auditor return scales match the shared Critical/Major/Minor buckets ---
ok  "performance-auditor return uses critical·major·minor" \
    grep -q 'ISSUES: N critical · M major · K minor' "$PERF"
ok  "performance-auditor body defines the Critical/Major/Minor scale" \
    grep -qi 'Severity scale' "$PERF"
ok  "dependency-auditor return uses critical·major·minor" \
    grep -q 'ISSUES: N critical · M major · K minor' "$DEP"
no  "dependency-auditor return no longer uses the stale high/medium/low scale" \
    grep -q 'M high · M medium · K low' "$DEP"

# --- security-auditor KEEPS its native Critical/High/Medium/Low (orchestrator normalizes it) ---
ok  "security-auditor retains its native Critical/High/Medium/Low scale" \
    grep -q 'ISSUES: N critical · M high · M medium · K low' "$SEC"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
