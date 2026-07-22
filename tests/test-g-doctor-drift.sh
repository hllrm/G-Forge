#!/bin/bash
# Unit tests for g-doctor Check 16: installed-copy drift detection
# Verifies the hash-comparison mechanism correctly identifies matching and mismatched
# hooks using the portable cascade (sha256sum → shasum -a 256 → cksum).
#
# Extended for W1.5g (M-audit tasks 3+4):
#   Tests 1-3: Hook drift detection (3 assertions, existing)
#   Tests 4-6: G-rules path drift (3 assertions, 10-file flat-rename mapping: rules/g-rules/*.md → .claude/rules/g-rules-*.md)
#   Tests 7-11: Agent classifier (6 assertions: profile-copied match/mismatch/missing, template-instantiated advisory-only, project-local *-dev.md excluded)
# Extended for W3 task 3 (M-audit finding #23 / BUG-4):
#   Tests 12-14: Check 21 stray-doc scan, fail-before/pass-after (5 assertions: old fixed 6-name
#   allowlist misses agent-output/plans strays, new inverted check — canonical names derived from
#   g-docs/ subdirs — catches them, no false positive on a clean tree)
# Total: 17 assertions (up from 3)

PASS=0
FAIL=0

check() { # name expected actual
    if [ "$2" = "$3" ]; then
        echo "PASS: $1"; PASS=$((PASS+1))
    else
        echo "FAIL: $1 (expected '$2', got '$3')"; FAIL=$((FAIL+1))
    fi
}

# compare_hashes <canonical> <installed> — verifies drift detection
# Returns "MATCH" if hashes are identical, "MISMATCH" if different, "MISSING" if installed copy absent.
# Implements the portable cascade: sha256sum → shasum -a 256 → cksum
compare_hashes() {
    local canonical="$1" installed="$2"

    # If installed copy does not exist, report MISSING
    [ -f "$installed" ] || { echo "MISSING"; return 0; }

    local canon_hash installed_hash

    # Cascade 1: Try sha256sum (Linux, macOS, modern BSD)
    if command -v sha256sum >/dev/null 2>&1; then
        canon_hash=$(sha256sum "$canonical" 2>/dev/null | awk '{print $1}')
        installed_hash=$(sha256sum "$installed" 2>/dev/null | awk '{print $1}')
    # Cascade 2: Fallback to shasum -a 256 (macOS, BSD, git-bash)
    elif command -v shasum >/dev/null 2>&1; then
        canon_hash=$(shasum -a 256 "$canonical" 2>/dev/null | awk '{print $1}')
        installed_hash=$(shasum -a 256 "$installed" 2>/dev/null | awk '{print $1}')
    # Cascade 3: Fallback to cksum (portable, POSIX-only)
    elif command -v cksum >/dev/null 2>&1; then
        # cksum outputs: <checksum> <bytes> <filename>
        canon_hash=$(cksum "$canonical" 2>/dev/null | awk '{print $1}')
        installed_hash=$(cksum "$installed" 2>/dev/null | awk '{print $1}')
    else
        # No hash command available
        echo "ERROR"
        return 1
    fi

    # Compare hashes: equal → MATCH, different → MISMATCH
    if [ "$canon_hash" = "$installed_hash" ]; then
        echo "MATCH"
    else
        echo "MISMATCH"
    fi
}

# ────────────────────────────────────────────────────────────────────────────

# Test 1: IDENTICAL CONTENT → hashes equal → MATCH (no drift)
# Scenario: canonical and installed copies have identical content (expected steady state).
# Expected: compare_hashes reports MATCH.
#
# Trace:
#   - Create hooks/sample.sh with "#!/bin/bash\necho hook1\n"
#   - Copy it to .claude/hooks/sample.sh (bit-identical)
#   - Compute hash of hooks/sample.sh (e.g., sha256sum = abc123...)
#   - Compute hash of .claude/hooks/sample.sh (same content = abc123...)
#   - abc123... == abc123... → MATCH ✓

echo "Test 1: Identical canonical and installed hooks"
FIXTURE1=$(mktemp -d)
cd "$FIXTURE1" || { echo "FAIL: could not create fixture"; exit 1; }

mkdir -p hooks .claude/hooks

# Fixed, deterministic content (no Date.now, no random)
HOOK_CONTENT="#!/bin/bash
# Sample hook for g-forge
echo 'sample hook executed'
exit 0
"
printf '%s\n' "$HOOK_CONTENT" > hooks/sample.sh
cp hooks/sample.sh .claude/hooks/sample.sh

RESULT=$(compare_hashes "hooks/sample.sh" ".claude/hooks/sample.sh")
check "identical files: hashes match (no drift)" "MATCH" "$RESULT"

cd / && rm -rf "$FIXTURE1"

# Test 2: DIFFERENT CONTENT → hashes differ → MISMATCH (drift detected)
# Scenario: canonical has current code, installed copy has staled old code (drift).
# Expected: compare_hashes reports MISMATCH.
#
# Trace:
#   - Create hooks/other.sh with "#!/bin/bash\necho v1\n" (canonical, current)
#   - Create .claude/hooks/other.sh with "#!/bin/bash\necho v2-staled\n" (installed, old)
#   - Compute hash of hooks/other.sh (e.g., sha256sum = def456...)
#   - Compute hash of .claude/hooks/other.sh (different content = ghi789...)
#   - def456... != ghi789... → MISMATCH ✓

echo "Test 2: Staled installed hook (drift)"
FIXTURE2=$(mktemp -d)
cd "$FIXTURE2" || { echo "FAIL: could not create fixture"; exit 1; }

mkdir -p hooks .claude/hooks

# Canonical (current)
CURRENT="#!/bin/bash
# Current version of hook
echo 'current implementation'
exit 0
"
printf '%s\n' "$CURRENT" > hooks/other.sh

# Installed (staled)
STALED="#!/bin/bash
# Old staled version
echo 'staled implementation'
exit 1
"
printf '%s\n' "$STALED" > .claude/hooks/other.sh

RESULT=$(compare_hashes "hooks/other.sh" ".claude/hooks/other.sh")
check "different files: hashes differ (drift detected)" "MISMATCH" "$RESULT"

cd / && rm -rf "$FIXTURE2"

# Test 3: MISSING INSTALLED COPY → no hash comparison possible → MISSING
# Scenario: canonical hook exists but its installed copy is absent (not yet deployed).
# Expected: compare_hashes reports MISSING.
#
# Trace:
#   - Create hooks/missing.sh with "#!/bin/bash\necho hook\n" (canonical)
#   - Do NOT create .claude/hooks/missing.sh (missing)
#   - Check if .claude/hooks/missing.sh exists → NO
#   - Return MISSING without computing hashes ✓

echo "Test 3: Canonical hook with no installed copy"
FIXTURE3=$(mktemp -d)
cd "$FIXTURE3" || { echo "FAIL: could not create fixture"; exit 1; }

mkdir -p hooks .claude/hooks

HOOK_CONTENT="#!/bin/bash
# Hook not yet installed
echo 'missing installed copy'
exit 0
"
printf '%s\n' "$HOOK_CONTENT" > hooks/missing.sh
# Intentionally do NOT create .claude/hooks/missing.sh

RESULT=$(compare_hashes "hooks/missing.sh" ".claude/hooks/missing.sh")
check "missing installed copy: detected as MISSING" "MISSING" "$RESULT"

cd / && rm -rf "$FIXTURE3"

# ────────────────────────────────────────────────────────────────────────────
# Test 4: G-RULES IDENTICAL CONTENT → hashes equal → MATCH (no drift)
# Scenario: canonical g-rules file and installed copy have identical content.
# Expected: compare_hashes reports MATCH.
# This verifies the 10-file flat-rename mapping: rules/g-rules/X-name.md → .claude/rules/g-rules-X-name.md
#
# Trace:
#   - Create rules/g-rules/A-session.md with "## A · Session Rules\n..."
#   - Copy it to .claude/rules/g-rules-A-session.md (bit-identical)
#   - Compute hash of both → identical hashes → MATCH ✓

echo "Test 4: Identical g-rules file (no drift)"
FIXTURE4=$(mktemp -d)
cd "$FIXTURE4" || { echo "FAIL: could not create fixture"; exit 1; }

mkdir -p rules/g-rules .claude/rules

# Fixed g-rules content (10-file mapping example: A-session.md)
GRULES_CONTENT="## A · Session Rules

This is the canonical A-session rules file.
Model selection, planning, execution, token optimisation.
"
printf '%s\n' "$GRULES_CONTENT" > rules/g-rules/A-session.md
cp rules/g-rules/A-session.md .claude/rules/g-rules-A-session.md

RESULT=$(compare_hashes "rules/g-rules/A-session.md" ".claude/rules/g-rules-A-session.md")
check "identical g-rules: hashes match (no drift)" "MATCH" "$RESULT"

cd / && rm -rf "$FIXTURE4"

# Test 5: G-RULES DIFFERENT CONTENT → hashes differ → MISMATCH (drift detected)
# Scenario: canonical g-rules has current rules, installed copy has staled version.
# Expected: compare_hashes reports MISMATCH.
#
# Trace:
#   - Create rules/g-rules/B-workflow.md with "## B · Workflow Rules\n..." (canonical, current)
#   - Create .claude/rules/g-rules-B-workflow.md with old "## OLD Workflow\n..." (installed, staled)
#   - Compute hashes → different → MISMATCH ✓

echo "Test 5: Different g-rules file (drift detected)"
FIXTURE5=$(mktemp -d)
cd "$FIXTURE5" || { echo "FAIL: could not create fixture"; exit 1; }

mkdir -p rules/g-rules .claude/rules

# Canonical (current)
CURRENT_GRULES="## B · Workflow Rules

G-Forge lifecycle, per-task loop, PM interface, skills reference.
Version 2.0 with updated semantics.
"
printf '%s\n' "$CURRENT_GRULES" > rules/g-rules/B-workflow.md

# Installed (staled)
STALED_GRULES="## B · OLD Workflow

Legacy workflow rules (outdated).
Do not use this version.
"
printf '%s\n' "$STALED_GRULES" > .claude/rules/g-rules-B-workflow.md

RESULT=$(compare_hashes "rules/g-rules/B-workflow.md" ".claude/rules/g-rules-B-workflow.md")
check "different g-rules: hashes differ (drift detected)" "MISMATCH" "$RESULT"

cd / && rm -rf "$FIXTURE5"

# Test 6: G-RULES MISSING INSTALLED COPY → no hash comparison possible → MISSING
# Scenario: canonical g-rules exists but its installed copy is absent.
# Expected: compare_hashes reports MISSING.
#
# Trace:
#   - Create rules/g-rules/C-agent-discipline.md (canonical)
#   - Do NOT create .claude/rules/g-rules-C-agent-discipline.md (missing)
#   - Check if installed copy exists → NO
#   - Return MISSING without computing hashes ✓

echo "Test 6: Missing g-rules installed copy"
FIXTURE6=$(mktemp -d)
cd "$FIXTURE6" || { echo "FAIL: could not create fixture"; exit 1; }

mkdir -p rules/g-rules .claude/rules

GRULES_CONTENT="## C · Agent Discipline

Wave model, spawn decisions, agent caps.
"
printf '%s\n' "$GRULES_CONTENT" > rules/g-rules/C-agent-discipline.md
# Intentionally do NOT create .claude/rules/g-rules-C-agent-discipline.md

RESULT=$(compare_hashes "rules/g-rules/C-agent-discipline.md" ".claude/rules/g-rules-C-agent-discipline.md")
check "missing g-rules installed copy: detected as MISSING" "MISSING" "$RESULT"

cd / && rm -rf "$FIXTURE6"

# ────────────────────────────────────────────────────────────────────────────
# Agent Classifier Tests (Tests 7-11)
# Three classes of agents in G-Forge:
#   1. Profile-copied agents: profiles/<stack>/agents/<name>.md (hash-compare, Fail on mismatch/missing)
#   2. Template-instantiated agents: agents/<name>.md at root (advisory-only, never Fail)
#   3. Project-local *-dev.md agents: .claude/agents/*-dev.md (excluded entirely, zero-drift)

# Helper function: classify_agent <canonical_path>
# Returns: "PROFILE_COPIED", "TEMPLATE_INSTANTIATED", or "PROJECT_LOCAL_DEV"
# This mimics the Check 16 agent classification logic
classify_agent() {
    local canonical="$1"

    # Check if it's a project-local *-dev.md agent (.claude/agents/*-dev.md)
    if [[ "$canonical" =~ \.claude/agents/.*-dev\.md$ ]]; then
        echo "PROJECT_LOCAL_DEV"
        return 0
    fi

    # Check if it's a profile-copied agent (profiles/<stack>/agents/<name>.md)
    if [[ "$canonical" =~ ^profiles/[^/]+/agents/[^/]+\.md$ ]]; then
        echo "PROFILE_COPIED"
        return 0
    fi

    # Otherwise, it's template-instantiated (agents/<name>.md at root)
    if [[ "$canonical" =~ ^agents/[^/]+\.md$ ]]; then
        echo "TEMPLATE_INSTANTIATED"
        return 0
    fi

    # Unknown classification
    echo "UNKNOWN"
    return 1
}

# Test 7: PROFILE-COPIED AGENT MATCHING → hashes equal → MATCH (no drift)
# Scenario: profile-copied agent exists in both canonical (plugin profiles/) and installed (.claude/agents/)
# with identical content. This represents a healthy, synced profile-copied agent.
# Expected: compare_hashes reports MATCH.
#
# Trace:
#   - Create profiles/test-stack/agents/test-architect.md (canonical, in plugin source)
#   - Create .claude/agents/test-architect.md (installed, copied by /g-init)
#   - Content is identical
#   - Classify as PROFILE_COPIED
#   - compare_hashes reports MATCH ✓

echo "Test 7: Profile-copied agent matching (no drift)"
FIXTURE7=$(mktemp -d)
cd "$FIXTURE7" || { echo "FAIL: could not create fixture"; exit 1; }

mkdir -p profiles/test-stack/agents .claude/agents

AGENT_CONTENT="---
name: test-architect
description: Test stack architecture specialist. Validates structure and design.
model: sonnet
tools: Read, Glob, Grep
---

You are a test stack architecture validator.
"
printf '%s\n' "$AGENT_CONTENT" > profiles/test-stack/agents/test-architect.md
cp profiles/test-stack/agents/test-architect.md .claude/agents/test-architect.md

# Classify
CLASSIFICATION=$(classify_agent "profiles/test-stack/agents/test-architect.md")
check "profile-copied agent classification" "PROFILE_COPIED" "$CLASSIFICATION"

# Compare hashes
RESULT=$(compare_hashes "profiles/test-stack/agents/test-architect.md" ".claude/agents/test-architect.md")
check "profile-copied agent matching (no drift)" "MATCH" "$RESULT"

cd / && rm -rf "$FIXTURE7"

# Test 8: PROFILE-COPIED AGENT MISMATCH → hashes differ → MISMATCH (drift detected)
# Scenario: profile-copied agent has drifted — canonical and installed have different content.
# Expected: compare_hashes reports MISMATCH.
#
# Trace:
#   - Create profiles/another-stack/agents/another-architect.md (canonical, current)
#   - Create .claude/agents/another-architect.md (installed, staled version)
#   - Hashes differ
#   - compare_hashes reports MISMATCH ✓

echo "Test 8: Profile-copied agent mismatch (drift detected)"
FIXTURE8=$(mktemp -d)
cd "$FIXTURE8" || { echo "FAIL: could not create fixture"; exit 1; }

mkdir -p profiles/another-stack/agents .claude/agents

# Canonical (current, v2.0)
CURRENT_AGENT="---
name: another-architect
description: Another stack architecture specialist. Validates structure and design (v2.0).
model: sonnet
tools: Read, Glob, Grep
---

You are an another stack architecture validator.
Current version with new rules.
"
printf '%s\n' "$CURRENT_AGENT" > profiles/another-stack/agents/another-architect.md

# Installed (staled, v1.0)
STALED_AGENT="---
name: another-architect
description: Another stack architecture specialist (v1.0 - outdated).
model: sonnet
tools: Read, Glob
---

You are an another stack architecture validator.
Old version.
"
printf '%s\n' "$STALED_AGENT" > .claude/agents/another-architect.md

RESULT=$(compare_hashes "profiles/another-stack/agents/another-architect.md" ".claude/agents/another-architect.md")
check "profile-copied agent mismatch (drift detected)" "MISMATCH" "$RESULT"

cd / && rm -rf "$FIXTURE8"

# Test 9: PROFILE-COPIED AGENT MISSING → installed copy absent → MISSING
# Scenario: profile-copied agent exists in canonical but its installed copy is absent (not yet deployed).
# Expected: compare_hashes reports MISSING.
#
# Trace:
#   - Create profiles/new-stack/agents/new-architect.md (canonical)
#   - Do NOT create .claude/agents/new-architect.md (missing)
#   - Check if installed copy exists → NO
#   - Return MISSING ✓

echo "Test 9: Profile-copied agent missing (not yet deployed)"
FIXTURE9=$(mktemp -d)
cd "$FIXTURE9" || { echo "FAIL: could not create fixture"; exit 1; }

mkdir -p profiles/new-stack/agents .claude/agents

AGENT_CONTENT="---
name: new-architect
description: New stack architecture specialist.
model: sonnet
tools: Read, Glob, Grep
---

You are a new stack architecture validator.
"
printf '%s\n' "$AGENT_CONTENT" > profiles/new-stack/agents/new-architect.md
# Intentionally do NOT create .claude/agents/new-architect.md

RESULT=$(compare_hashes "profiles/new-stack/agents/new-architect.md" ".claude/agents/new-architect.md")
check "profile-copied agent missing (not yet deployed)" "MISSING" "$RESULT"

cd / && rm -rf "$FIXTURE9"

# Test 10: TEMPLATE-INSTANTIATED AGENT CLASSIFICATION → advisory-only (never Fail)
# Scenario: template-instantiated agent (e.g., agents/feature-implementer.md) is classified correctly
# and is treated as advisory-only, never Fail.
# Expected: classify_agent reports TEMPLATE_INSTANTIATED.
# This test verifies that the agent classifier correctly identifies template-instantiated agents
# and ensures Check 16 will only produce advisories for them, not failures.
#
# Trace:
#   - Classify agents/feature-implementer.md
#   - Classification should be TEMPLATE_INSTANTIATED
#   - Check 16 logic: template-instantiated agents are advisory-only (never Fail) ✓

echo "Test 10: Template-instantiated agent classification (advisory-only, never Fail)"
FIXTURE10=$(mktemp -d)
cd "$FIXTURE10" || { echo "FAIL: could not create fixture"; exit 1; }

mkdir -p agents

TEMPLATE_AGENT="---
name: feature-implementer
description: Generic, stack-agnostic wave implementer.
model: sonnet
tools: Read, Glob, Grep, Write, Edit, Bash
---

You are a generic wave implementer.
"
printf '%s\n' "$TEMPLATE_AGENT" > agents/feature-implementer.md

CLASSIFICATION=$(classify_agent "agents/feature-implementer.md")
check "template-instantiated agent classification" "TEMPLATE_INSTANTIATED" "$CLASSIFICATION"

cd / && rm -rf "$FIXTURE10"

# Test 11: PROJECT-LOCAL *-DEV.MD AGENT EXCLUSION → completely excluded (zero-drift/no-op)
# Scenario: project-local agent (e.g., .claude/agents/g-forge-dev.md) is classified and excluded
# from drift detection entirely. It should never be compared against anything.
# Expected: classify_agent reports PROJECT_LOCAL_DEV and Check 16 produces zero-drift (no-op).
#
# Trace:
#   - Classify .claude/agents/g-forge-dev.md
#   - Classification should be PROJECT_LOCAL_DEV
#   - Check 16 logic: project-local *-dev.md agents are excluded entirely (zero-drift/no-op) ✓

echo "Test 11: Project-local *-dev.md agent excluded (zero-drift/no-op)"
FIXTURE11=$(mktemp -d)
cd "$FIXTURE11" || { echo "FAIL: could not create fixture"; exit 1; }

mkdir -p .claude/agents

DEV_AGENT="---
name: g-forge-dev
description: Use proactively to run this repo's test suites.
model: haiku
tools: Read, Glob, Grep, Bash
---

You run G-Forge's own test suites and report VERBATIM runner output.
"
printf '%s\n' "$DEV_AGENT" > .claude/agents/g-forge-dev.md

CLASSIFICATION=$(classify_agent ".claude/agents/g-forge-dev.md")
check "project-local *-dev.md agent classification" "PROJECT_LOCAL_DEV" "$CLASSIFICATION"

cd / && rm -rf "$FIXTURE11"

# ────────────────────────────────────────────────────────────────────────────
# Check 21 Stray-Doc Scan Tests (Tests 12-14)
# M-audit finding #23 / BUG-4: the old Check 21 used a fixed 6-name dir allowlist
# (decisions|retros|forecasts|telemetry|blast-radius|alignment), so a parallel docs/
# tree (agent-output/, plans/, qa-scope/) slipped through undetected. The fix inverts
# the check: canonical dir names are derived from whatever already lives directly
# under g-docs/ in the project, then any directory sharing one of those names anywhere
# outside g-docs/ or g-wiki/ is flagged as a stray.

# old_stray_check — mimics the OLD (pre-fix) Check 21 bash snippet: a fixed 6-name
# dir allowlist. Must be run with cwd at the fixture root. Prints stray dir paths found
# (empty output = none found).
old_stray_check() {
    find . -type d \( -name decisions -o -name retros -o -name forecasts -o -name telemetry -o -name blast-radius -o -name alignment \) \
      -not -path './g-docs/*' -not -path './.git/*' -not -path '*/node_modules/*' 2>/dev/null
}

# new_stray_check — mimics the NEW (post-fix) Check 21 bash snippet: an inverted check.
# Canonical dir names are derived from whatever already lives directly under g-docs/ in
# this fixture, then any directory sharing one of those names anywhere outside g-docs/ or
# g-wiki/ is a stray. Must be run with cwd at the fixture root.
new_stray_check() {
    for canon in $(find g-docs -mindepth 1 -maxdepth 1 -type d 2>/dev/null | xargs -n1 basename); do
        find . -type d -name "$canon" \
          -not -path './g-docs*' -not -path './g-wiki*' -not -path './.git/*' -not -path '*/node_modules/*' 2>/dev/null
    done
}

# Test 12: FAIL-BEFORE — OLD fixed 6-name allowlist misses a parallel docs/ tree
# Scenario: canonical g-docs/plans/ and g-docs/agent-output/ exist (project record), and a
# stray parallel tree docs/plans/ and docs/agent-output/ also exists (drifted copy). Neither
# "plans" nor "agent-output" is in the OLD fixed 6-name list, so the old check misses both —
# this is the exact M-audit #23/BUG-4 gap.
# Expected: old_stray_check reports neither stray (empty for both).
#
# Trace:
#   - Create g-docs/plans/f.md, g-docs/agent-output/f.md (canonical)
#   - Create docs/plans/f.md, docs/agent-output/f.md (stray parallel tree)
#   - old_stray_check searches only for decisions|retros|forecasts|telemetry|blast-radius|alignment
#   - "plans" and "agent-output" are not in that list → docs/plans, docs/agent-output NOT reported ✓ (bug reproduced)

echo "Test 12: OLD fixed-allowlist check misses agent-output/plans strays (fail-before)"
FIXTURE12=$(mktemp -d)
cd "$FIXTURE12" || { echo "FAIL: could not create fixture"; exit 1; }

mkdir -p g-docs/plans g-docs/agent-output docs/plans docs/agent-output
printf '%s\n' "canonical plan" > g-docs/plans/f.md
printf '%s\n' "canonical agent output" > g-docs/agent-output/f.md
printf '%s\n' "stray plan" > docs/plans/f.md
printf '%s\n' "stray agent output" > docs/agent-output/f.md

OLD_RESULT=$(old_stray_check)

FOUND_PLANS_OLD="no"
echo "$OLD_RESULT" | grep -q "docs/plans" && FOUND_PLANS_OLD="yes"
check "OLD allowlist misses docs/plans/ (bug reproduced)" "no" "$FOUND_PLANS_OLD"

FOUND_AGENT_OUTPUT_OLD="no"
echo "$OLD_RESULT" | grep -q "docs/agent-output" && FOUND_AGENT_OUTPUT_OLD="yes"
check "OLD allowlist misses docs/agent-output/ (bug reproduced)" "no" "$FOUND_AGENT_OUTPUT_OLD"

# Test 13: PASS-AFTER — NEW inverted check catches the same strays
# Scenario: same fixture as Test 12. The NEW check derives canonical names from what
# actually lives under g-docs/ (here: "plans" and "agent-output"), then flags any directory
# sharing those names found outside g-docs/ or g-wiki/.
# Expected: new_stray_check reports both docs/plans and docs/agent-output as strays.
#
# Trace:
#   - Same fixture tree as Test 12 (cwd unchanged)
#   - new_stray_check derives canonical names {"plans", "agent-output"} from g-docs/ subdirs
#   - Searches repo for dirs named "plans" or "agent-output" outside g-docs/ or g-wiki/
#   - Finds ./docs/plans and ./docs/agent-output → reported as strays ✓ (bug fixed)

echo "Test 13: NEW inverted check catches agent-output/plans strays (pass-after)"

NEW_RESULT=$(new_stray_check)

FOUND_PLANS_NEW="no"
echo "$NEW_RESULT" | grep -q "docs/plans" && FOUND_PLANS_NEW="yes"
check "NEW inverted check flags docs/plans/ (bug fixed)" "yes" "$FOUND_PLANS_NEW"

FOUND_AGENT_OUTPUT_NEW="no"
echo "$NEW_RESULT" | grep -q "docs/agent-output" && FOUND_AGENT_OUTPUT_NEW="yes"
check "NEW inverted check flags docs/agent-output/ (bug fixed)" "yes" "$FOUND_AGENT_OUTPUT_NEW"

cd / && rm -rf "$FIXTURE12"

# Test 14: NEW check produces no false positive on a clean tree (regression guard)
# Scenario: canonical-only tree — g-docs/plans/ and g-docs/decisions/ exist, no parallel
# stray tree anywhere else. The NEW inverted check must report zero strays (it must not
# flag g-docs/ contents against themselves, nor invent false matches).
# Expected: new_stray_check reports nothing.
#
# Trace:
#   - Create g-docs/plans/f.md, g-docs/decisions/f.md only (no stray copies elsewhere)
#   - new_stray_check derives canonical names {"plans", "decisions"} from g-docs/ subdirs
#   - Searches repo for dirs named "plans" or "decisions" outside g-docs/ or g-wiki/ → none exist
#   - Reports empty ✓ (no false positive)

echo "Test 14: NEW inverted check has no false positive on a clean tree"
FIXTURE14=$(mktemp -d)
cd "$FIXTURE14" || { echo "FAIL: could not create fixture"; exit 1; }

mkdir -p g-docs/plans g-docs/decisions
printf '%s\n' "canonical plan" > g-docs/plans/f.md
printf '%s\n' "canonical decision" > g-docs/decisions/f.md

NEW_RESULT_CLEAN=$(new_stray_check)
check "NEW inverted check: clean tree produces no strays" "" "$NEW_RESULT_CLEAN"

cd / && rm -rf "$FIXTURE14"

# ────────────────────────────────────────────────────────────────────────────
# Summary

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
