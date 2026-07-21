#!/bin/bash
# Unit tests for hooks/lib/classify-changeset.sh
# Tests the file-set classification logic: CODE vs DOC bucket assignment.
# Encodes ground-truth from actual case-statement body (2026-07-18).
# No temp repos — all tests call the function on fixed strings via heredoc only.
#
# Attested 2026-07-18 (W1.5b): 42 passed, 0 failed — after the whitespace-only
# assertion was flipped to pin observed fail-toward-deny behavior (see the
# polarity note on that case; lib header corrected in the same pass).
# W1.6 additions: +5 tests (shadowed .md dirs, pathspec fidelity, pre-commit scan).
# Total assertions: 47. Runner-attested (W1.6 Wave 7 r2: 47/47).

LIB="$(cd "$(dirname "$0")" && pwd)/../hooks/lib/classify-changeset.sh"
source "$LIB" || { echo "FAIL: could not source $LIB"; exit 1; }

PASS=0
FAIL=0

# test_classify <name> <paths_string> <expected_has_code> <expected_has_doc> —
# Call gf_classify_changeset via heredoc with the given paths and assert
# the resulting HAS_CODE and HAS_DOC globals match expectations.
# This must use HEREDOC, not pipe, per the lib's call convention.
test_classify() {
    local name="$1" paths="$2" exp_code="$3" exp_doc="$4"
    # Initialize globals before each test to ensure they don't leak state
    HAS_CODE=0
    HAS_DOC=0
    # HEREDOC invocation — never a pipe, per lib's call convention
    gf_classify_changeset <<EOF
$paths
EOF
    # After the heredoc, check results
    local code_match=0 doc_match=0
    if [ "$HAS_CODE" -eq "$exp_code" ]; then
        code_match=1
    fi
    if [ "$HAS_DOC" -eq "$exp_doc" ]; then
        doc_match=1
    fi
    if [ "$code_match" -eq 1 ] && [ "$doc_match" -eq 1 ]; then
        echo "PASS: $name"
        PASS=$((PASS+1))
    else
        echo "FAIL: $name (expected HAS_CODE=$exp_code HAS_DOC=$exp_doc, got HAS_CODE=$HAS_CODE HAS_DOC=$HAS_DOC)"
        FAIL=$((FAIL+1))
    fi
}

# ── Task 5: Bucket-rule coverage — one distinct assertion per rule path ───────

# DOC bucket: g-docs/* directory
test_classify "DOC: g-docs/test.md" "g-docs/test.md" 0 1
test_classify "DOC: g-docs/subdir/file.txt" "g-docs/subdir/file.txt" 0 1

# DOC bucket: g-wiki/* directory
test_classify "DOC: g-wiki/index.md" "g-wiki/index.md" 0 1
test_classify "DOC: g-wiki/posts/entry.md" "g-wiki/posts/entry.md" 0 1

# DOC bucket: docs/* directory
test_classify "DOC: docs/README.md" "docs/README.md" 0 1
test_classify "DOC: docs/api/guide.md" "docs/api/guide.md" 0 1

# DOC bucket: README*, CHANGELOG*, LICENSE* (root-level)
test_classify "DOC: README.md" "README.md" 0 1
test_classify "DOC: README_extended" "README_extended" 0 1
test_classify "DOC: CHANGELOG.md" "CHANGELOG.md" 0 1
test_classify "DOC: CHANGELOG.txt" "CHANGELOG.txt" 0 1
test_classify "DOC: LICENSE" "LICENSE" 0 1
test_classify "DOC: LICENSE.txt" "LICENSE.txt" 0 1

# DOC bucket: *.md at repo root (no slash in path)
test_classify "DOC: root-level *.md (no slash)" "example.md" 0 1
test_classify "DOC: root-level *.md another example" "CONTRIBUTING.md" 0 1

# CODE bucket: nested *.md (contains a slash)
test_classify "CODE: nested *.md file" "some/dir/file.md" 1 0
test_classify "CODE: nested *.md in docs dir" "content/pages/article.md" 1 0

# CODE bucket: shadowed .md directory — directory name ends in .md but doesn't match
# special directory rules (g-docs, g-wiki, docs), so files inside fall through to CODE
# (M-audit W1.6 task 11)
test_classify "CODE: file in docs.md directory (no match)" "docs.md/README" 1 0
test_classify "CODE: file in api.md directory (no match)" "api.md/guide.txt" 1 0
test_classify "CODE: nested .md file in .md-named directory" "docs.md/file.md" 1 0

# CODE bucket: hooks/* directory
test_classify "CODE: hooks/check-commit.sh" "hooks/check-commit.sh" 1 0
test_classify "CODE: hooks/lib/commit-detect.sh" "hooks/lib/commit-detect.sh" 1 0

# CODE bucket: skills/* directory
test_classify "CODE: skills/g-review/SKILL.md" "skills/g-review/SKILL.md" 1 0
test_classify "CODE: skills/g-init/SKILL.md" "skills/g-init/SKILL.md" 1 0

# CODE bucket: agents/* directory
test_classify "CODE: agents/architect.md" "agents/architect.md" 1 0
test_classify "CODE: agents/reviewer/check.md" "agents/reviewer/check.md" 1 0

# CODE bucket: commands/* directory
test_classify "CODE: commands/g-review.md" "commands/g-review.md" 1 0
test_classify "CODE: commands/g-init.md" "commands/g-init.md" 1 0

# CODE bucket: profiles/* directory
test_classify "CODE: profiles/stack/rules.md" "profiles/stack/rules.md" 1 0

# CODE bucket: tests/* directory
test_classify "CODE: tests/test-foo.sh" "tests/test-foo.sh" 1 0
test_classify "CODE: tests/fixtures/data.json" "tests/fixtures/data.json" 1 0

# CODE bucket: .claude-plugin/* directory
test_classify "CODE: .claude-plugin/plugin.json" ".claude-plugin/plugin.json" 1 0
test_classify "CODE: .claude-plugin/marketplace.json" ".claude-plugin/marketplace.json" 1 0

# CODE bucket: .claude/rules/* directory
test_classify "CODE: .claude/rules/g-rules-A.md" ".claude/rules/g-rules-A.md" 1 0
test_classify "CODE: .claude/rules/architecture.md" ".claude/rules/architecture.md" 1 0

# CODE bucket: unknown/unmatched path (default: stricter gate)
test_classify "CODE: unknown root file (no match)" "unknown.txt" 1 0
test_classify "CODE: unknown nested path" "random/dir/file" 1 0
test_classify "CODE: unknown extension" "file.xyz" 1 0

# CODE bucket: pathspec fidelity — unmatched/complex pathspecs fall through to CODE
# (M-audit W1.6 task 10) — verifies the stricter default gate behavior
test_classify "CODE: pathspec with quoted/escaped chars not matching DOC rules" "\"quoted-path\"/file.txt" 1 0
test_classify "CODE: pathspec with shell metacharacters not matching any rule" "path\$with\$vars/file" 1 0

# BOUNDARY: Empty input — neither flag set (both 0)
test_classify "EMPTY: empty input string" "" 0 0
# BOUNDARY: whitespace-only (non-empty) line is NOT skipped by the lib's
# `[ -z "$_f" ] && continue` guard — it falls through every case arm to the
# unmatched→CODE default. This is fail-toward-deny (an unparseable/garbage
# path gates as the stricter CODE bucket) and is byte-identical to the
# pre-extraction inline loop in hooks/check-commit.sh (verified commit
# 9688e95) — the header comment was corrected to match this observed
# behavior rather than the body being changed to match a wrong comment.
test_classify "WHITESPACE: whitespace-only line falls through to CODE (fail-toward-deny)" "
  " 1 0

# MIXED: One DOC path and one CODE path → both flags 1
test_classify "MIXED: g-docs path + hooks path" "g-docs/example.md
hooks/test.sh" 1 1
test_classify "MIXED: README + unknown file" "README.md
some/code/file.py" 1 1
test_classify "MIXED: nested .md + root .md" "dir/nested.md
root.md" 1 1

# ── Task 6: Single-classifier invariant — grep tests ──────────────────────────

echo ""
echo "── Task 6: Single-classifier invariant checks ────────────────────────────"

# Task 6a: Verify no other hooks contain DOC bucket classification patterns
# (except classify-changeset.sh itself). These patterns should NOT appear as
# case-statement or if-statement logic elsewhere — they belong in ONE place only.

DOC_PATTERNS=("g-docs/\*" "g-wiki/\*" "docs/\*" "README\*" "CHANGELOG\*" "LICENSE\*")

# Check that no hook file (except the lib itself) contains a case-statement
# matching the DOC bucket patterns. We search for the literal case patterns.
# If found outside of classify-changeset.sh, that's a duplicate rule violation.
# Scan both *.sh files AND the extensionless hooks/pre-commit (M-audit W1.6 task 12).

found_duplicate_rules=0

# Search for case statement patterns that match DOC buckets in other hooks
# Look for lines like `g-docs/*|` or `README*|` in case statements
for hook_file in hooks/*.sh hooks/pre-commit; do
    [ "$hook_file" = "hooks/lib/classify-changeset.sh" ] && continue
    [ -f "$hook_file" ] || continue
    # Search for DOC bucket case patterns (pipe-separated glob patterns in case statements)
    if grep -E 'g-docs/\*|g-wiki/\*|docs/\*|README\*|CHANGELOG\*|LICENSE\*' "$hook_file" | grep -qv "^[[:space:]]*#"; then
        # Check if it's in a case-statement (not just a comment)
        if grep 'case.*in' "$hook_file" | head -1 > /dev/null; then
            # This hook has a case statement and contains DOC bucket patterns
            # Likely a duplicate — but check more carefully by examining context
            if sed -n '/^[[:space:]]*case.*in/,/^[[:space:]]*esac/p' "$hook_file" | grep -E 'g-docs/\*|g-wiki/\*|docs/\*|README\*|CHANGELOG\*|LICENSE\*'; then
                echo "FAIL: Task 6a — found DOC bucket case-pattern duplicated in $hook_file (expected zero duplicates)"
                FAIL=$((FAIL+1))
                found_duplicate_rules=1
            fi
        fi
    fi
done

if [ "$found_duplicate_rules" -eq 0 ]; then
    echo "PASS: Task 6a — no DOC bucket classification patterns found in other hooks (including hooks/pre-commit)"
    PASS=$((PASS+1))
fi

# Task 6b: Verify that hooks/check-commit.sh sources classify-changeset.sh
# and actually calls gf_classify_changeset (via heredoc, not pipe)
if grep -q "^\. .*classify-changeset.sh" hooks/check-commit.sh && \
   grep -q "gf_classify_changeset <<" hooks/check-commit.sh; then
    echo "PASS: Task 6b-1 — hooks/check-commit.sh sources lib and calls gf_classify_changeset"
    PASS=$((PASS+1))
else
    echo "FAIL: Task 6b-1 — hooks/check-commit.sh missing lib source or call"
    FAIL=$((FAIL+1))
fi

# Task 6c: Verify that hooks/pre-commit sources classify-changeset.sh
# and actually calls gf_classify_changeset (via heredoc, not pipe)
if grep -q "^\. .*classify-changeset.sh" hooks/pre-commit && \
   grep -q "gf_classify_changeset <<" hooks/pre-commit; then
    echo "PASS: Task 6b-2 — hooks/pre-commit sources lib and calls gf_classify_changeset"
    PASS=$((PASS+1))
else
    echo "FAIL: Task 6b-2 — hooks/pre-commit missing lib source or call"
    FAIL=$((FAIL+1))
fi

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
