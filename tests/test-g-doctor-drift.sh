#!/bin/bash
# Unit tests for g-doctor Check 16: installed-copy drift detection
# Verifies the hash-comparison mechanism correctly identifies matching and mismatched
# hooks using the portable cascade (sha256sum → shasum -a 256 → cksum).

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
# Summary

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
