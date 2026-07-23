#!/bin/bash
# Unit tests for hooks/lib/semver-compare.sh (semantic versioning comparison).
#
# Verifies: gf_semver_compare A B returns -1 (A older), 0 (equal), or 1 (A newer).
# Grammar: MAJOR[.MINOR[.PATCH]][single-lowercase-letter-suffix]
# Missing segments default to 0 (e.g., 1.0 == 1.0.0).
# Hotfix suffix: only when numeric parts are equal; absent < present; present lexical.
# Malformed (empty or non-matching): prints 0, exits 1.
# Well-formed: exits 0.
#
# Total assertions: 26 (covering major/minor/patch ordering, missing segments,
# suffix ordering, and malformed inputs).

LIB="$(cd "$(dirname "$0")" && pwd)/../hooks/lib/semver-compare.sh"
source "$LIB" || { echo "FAIL: could not source $LIB"; exit 1; }

PASS=0
FAIL=0

# ── Task 1: Library sourced successfully ────────────────────────────────────

echo "PASS: source hooks/lib/semver-compare.sh"
PASS=$((PASS+1))

# ── Task 2: Major version comparison — newer ────────────────────────────────

OUTPUT=$(gf_semver_compare "2.0.0" "1.0.0")
RC=$?
if [ "$OUTPUT" = "1" ] && [ "$RC" -eq 0 ]; then
    echo "PASS: major newer — 2.0.0 > 1.0.0 returns 1, exit 0"
    PASS=$((PASS+1))
else
    echo "FAIL: major newer — expected output=1 rc=0, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 3: Major version comparison — older ───────────────────────────────

OUTPUT=$(gf_semver_compare "1.0.0" "2.0.0")
RC=$?
if [ "$OUTPUT" = "-1" ] && [ "$RC" -eq 0 ]; then
    echo "PASS: major older — 1.0.0 < 2.0.0 returns -1, exit 0"
    PASS=$((PASS+1))
else
    echo "FAIL: major older — expected output=-1 rc=0, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 4: Major version comparison — equal ───────────────────────────────

OUTPUT=$(gf_semver_compare "1.0.0" "1.0.0")
RC=$?
if [ "$OUTPUT" = "0" ] && [ "$RC" -eq 0 ]; then
    echo "PASS: major equal — 1.0.0 == 1.0.0 returns 0, exit 0"
    PASS=$((PASS+1))
else
    echo "FAIL: major equal — expected output=0 rc=0, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 5: Minor version comparison — newer ────────────────────────────────

OUTPUT=$(gf_semver_compare "1.2.0" "1.1.0")
RC=$?
if [ "$OUTPUT" = "1" ] && [ "$RC" -eq 0 ]; then
    echo "PASS: minor newer — 1.2.0 > 1.1.0 returns 1, exit 0"
    PASS=$((PASS+1))
else
    echo "FAIL: minor newer — expected output=1 rc=0, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 6: Minor version comparison — older ───────────────────────────────

OUTPUT=$(gf_semver_compare "1.1.0" "1.2.0")
RC=$?
if [ "$OUTPUT" = "-1" ] && [ "$RC" -eq 0 ]; then
    echo "PASS: minor older — 1.1.0 < 1.2.0 returns -1, exit 0"
    PASS=$((PASS+1))
else
    echo "FAIL: minor older — expected output=-1 rc=0, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 7: Minor version comparison — equal ───────────────────────────────

OUTPUT=$(gf_semver_compare "1.1.0" "1.1.0")
RC=$?
if [ "$OUTPUT" = "0" ] && [ "$RC" -eq 0 ]; then
    echo "PASS: minor equal — 1.1.0 == 1.1.0 returns 0, exit 0"
    PASS=$((PASS+1))
else
    echo "FAIL: minor equal — expected output=0 rc=0, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 8: Patch version comparison — newer ───────────────────────────────

OUTPUT=$(gf_semver_compare "1.0.2" "1.0.1")
RC=$?
if [ "$OUTPUT" = "1" ] && [ "$RC" -eq 0 ]; then
    echo "PASS: patch newer — 1.0.2 > 1.0.1 returns 1, exit 0"
    PASS=$((PASS+1))
else
    echo "FAIL: patch newer — expected output=1 rc=0, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 9: Patch version comparison — older ───────────────────────────────

OUTPUT=$(gf_semver_compare "1.0.1" "1.0.2")
RC=$?
if [ "$OUTPUT" = "-1" ] && [ "$RC" -eq 0 ]; then
    echo "PASS: patch older — 1.0.1 < 1.0.2 returns -1, exit 0"
    PASS=$((PASS+1))
else
    echo "FAIL: patch older — expected output=-1 rc=0, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 10: Patch version comparison — equal ──────────────────────────────

OUTPUT=$(gf_semver_compare "1.0.1" "1.0.1")
RC=$?
if [ "$OUTPUT" = "0" ] && [ "$RC" -eq 0 ]; then
    echo "PASS: patch equal — 1.0.1 == 1.0.1 returns 0, exit 0"
    PASS=$((PASS+1))
else
    echo "FAIL: patch equal — expected output=0 rc=0, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 11: Missing patch segment equivalence ──────────────────────────────

OUTPUT=$(gf_semver_compare "1.0.0" "1.0")
RC=$?
if [ "$OUTPUT" = "0" ] && [ "$RC" -eq 0 ]; then
    echo "PASS: missing patch — 1.0.0 == 1.0 (missing patch defaults to 0), exit 0"
    PASS=$((PASS+1))
else
    echo "FAIL: missing patch — expected output=0 rc=0, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 12: Missing patch segment equivalence — reverse order ──────────────

OUTPUT=$(gf_semver_compare "1.0" "1.0.0")
RC=$?
if [ "$OUTPUT" = "0" ] && [ "$RC" -eq 0 ]; then
    echo "PASS: missing patch reverse — 1.0 == 1.0.0 (missing patch defaults to 0), exit 0"
    PASS=$((PASS+1))
else
    echo "FAIL: missing patch reverse — expected output=0 rc=0, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 13: Missing minor and patch segments equivalence ────────────────────

OUTPUT=$(gf_semver_compare "1.0.0" "1")
RC=$?
if [ "$OUTPUT" = "0" ] && [ "$RC" -eq 0 ]; then
    echo "PASS: missing minor.patch — 1.0.0 == 1 (missing segments default to 0), exit 0"
    PASS=$((PASS+1))
else
    echo "FAIL: missing minor.patch — expected output=0 rc=0, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 14: Missing minor and patch segments equivalence — reverse order ────

OUTPUT=$(gf_semver_compare "1" "1.0.0")
RC=$?
if [ "$OUTPUT" = "0" ] && [ "$RC" -eq 0 ]; then
    echo "PASS: missing minor.patch reverse — 1 == 1.0.0 (missing segments default to 0), exit 0"
    PASS=$((PASS+1))
else
    echo "FAIL: missing minor.patch reverse — expected output=0 rc=0, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 15: Complex missing segment case ───────────────────────────────────

OUTPUT=$(gf_semver_compare "2.3" "2.3.0")
RC=$?
if [ "$OUTPUT" = "0" ] && [ "$RC" -eq 0 ]; then
    echo "PASS: complex missing segment — 2.3 == 2.3.0 (missing patch defaults to 0), exit 0"
    PASS=$((PASS+1))
else
    echo "FAIL: complex missing segment — expected output=0 rc=0, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 16: Hotfix suffix — no suffix < with suffix ────────────────────────

OUTPUT=$(gf_semver_compare "2.3.3" "2.3.3a")
RC=$?
if [ "$OUTPUT" = "-1" ] && [ "$RC" -eq 0 ]; then
    echo "PASS: hotfix suffix absent < present — 2.3.3 < 2.3.3a returns -1, exit 0"
    PASS=$((PASS+1))
else
    echo "FAIL: hotfix suffix absent < present — expected output=-1 rc=0, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 17: Hotfix suffix — lexical ordering a < b ─────────────────────────

OUTPUT=$(gf_semver_compare "2.3.3a" "2.3.3b")
RC=$?
if [ "$OUTPUT" = "-1" ] && [ "$RC" -eq 0 ]; then
    echo "PASS: hotfix suffix lexical — 2.3.3a < 2.3.3b returns -1, exit 0"
    PASS=$((PASS+1))
else
    echo "FAIL: hotfix suffix lexical — expected output=-1 rc=0, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 18: Hotfix suffix — with suffix > no suffix ───────────────────────

OUTPUT=$(gf_semver_compare "2.3.3a" "2.3.3")
RC=$?
if [ "$OUTPUT" = "1" ] && [ "$RC" -eq 0 ]; then
    echo "PASS: hotfix suffix present > absent — 2.3.3a > 2.3.3 returns 1, exit 0"
    PASS=$((PASS+1))
else
    echo "FAIL: hotfix suffix present > absent — expected output=1 rc=0, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 19: Malformed — empty string as first argument ────────────────────

OUTPUT=$(gf_semver_compare "" "1.0.0")
RC=$?
if [ "$OUTPUT" = "0" ] && [ "$RC" -eq 1 ]; then
    echo "PASS: malformed first arg (empty) — prints 0, exit 1"
    PASS=$((PASS+1))
else
    echo "FAIL: malformed first arg (empty) — expected output=0 rc=1, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 20: Malformed — non-matching characters in first argument ──────────

OUTPUT=$(gf_semver_compare "1.2.x" "1.0.0")
RC=$?
if [ "$OUTPUT" = "0" ] && [ "$RC" -eq 1 ]; then
    echo "PASS: malformed first arg (non-matching) — prints 0, exit 1"
    PASS=$((PASS+1))
else
    echo "FAIL: malformed first arg (non-matching) — expected output=0 rc=1, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 21: Malformed — empty string as second argument ────────────────────

OUTPUT=$(gf_semver_compare "1.0.0" "")
RC=$?
if [ "$OUTPUT" = "0" ] && [ "$RC" -eq 1 ]; then
    echo "PASS: malformed second arg (empty) — prints 0, exit 1"
    PASS=$((PASS+1))
else
    echo "FAIL: malformed second arg (empty) — expected output=0 rc=1, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 22: Malformed — non-matching characters in second argument ─────────

OUTPUT=$(gf_semver_compare "1.0.0" "2.3.x")
RC=$?
if [ "$OUTPUT" = "0" ] && [ "$RC" -eq 1 ]; then
    echo "PASS: malformed second arg (non-matching) — prints 0, exit 1"
    PASS=$((PASS+1))
else
    echo "FAIL: malformed second arg (non-matching) — expected output=0 rc=1, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 23: Malformed — both arguments empty ───────────────────────────────

OUTPUT=$(gf_semver_compare "" "")
RC=$?
if [ "$OUTPUT" = "0" ] && [ "$RC" -eq 1 ]; then
    echo "PASS: malformed both args (empty) — prints 0, exit 1"
    PASS=$((PASS+1))
else
    echo "FAIL: malformed both args (empty) — expected output=0 rc=1, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 24: Malformed — uppercase suffix (invalid) ───────────────────────

OUTPUT=$(gf_semver_compare "1.0.0A" "1.0.0")
RC=$?
if [ "$OUTPUT" = "0" ] && [ "$RC" -eq 1 ]; then
    echo "PASS: malformed uppercase suffix — prints 0, exit 1"
    PASS=$((PASS+1))
else
    echo "FAIL: malformed uppercase suffix — expected output=0 rc=1, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 25: Malformed — too many segments (four numeric parts) ─────────────

OUTPUT=$(gf_semver_compare "1.0.0.0" "1.0.0")
RC=$?
if [ "$OUTPUT" = "0" ] && [ "$RC" -eq 1 ]; then
    echo "PASS: malformed too many segments — prints 0, exit 1"
    PASS=$((PASS+1))
else
    echo "FAIL: malformed too many segments — expected output=0 rc=1, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Task 26: Malformed — multiple suffix characters ────────────────────────

OUTPUT=$(gf_semver_compare "1.0.0ab" "1.0.0")
RC=$?
if [ "$OUTPUT" = "0" ] && [ "$RC" -eq 1 ]; then
    echo "PASS: malformed multiple suffix chars — prints 0, exit 1"
    PASS=$((PASS+1))
else
    echo "FAIL: malformed multiple suffix chars — expected output=0 rc=1, got output=$OUTPUT rc=$RC"
    FAIL=$((FAIL+1))
fi

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
