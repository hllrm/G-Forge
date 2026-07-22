#!/bin/bash
# hooks/lib/classify-changeset.sh — shared code/doc/mixed file-set classifier.
#
# Sourced (never executed directly) by hooks/check-commit.sh and the ADR-004
# native pre-commit hook, so both enforcement sites classify a changeset's
# file set identically instead of two hand-edited case-statements that can
# drift apart. This file defines a function only — sourcing it alone has no
# output and no side effects.
#
# Public API:
#   gf_classify_changeset — read a changeset's file paths (one per line) on
#     stdin, classify each path into the CODE or DOC bucket, and set the
#     caller-visible globals HAS_CODE / HAS_DOC accordingly (1 = present in
#     this changeset, 0 = absent). Always sets both globals. Empty lines are
#     skipped, so a fully empty input leaves both flags at 0 (neither bucket
#     present). A whitespace-only line (e.g. a single space) is NOT empty and
#     is NOT skipped — it falls through every case arm to the unmatched→CODE
#     default, so HAS_CODE=1 for that input. This is fail-toward-deny (an
#     unparseable/garbage path gates as the stricter CODE bucket rather than
#     silently vanishing) and matches the pre-extraction inline loop in
#     hooks/check-commit.sh byte-for-byte (verified against commit 9688e95),
#     so the derived CLASS logic that follows it (mixed/doc/code/none→code)
#     is unaffected by this extraction.
#
# Bucket rules (byte-identical to hooks/check-commit.sh's former inline
# case-statement — do not extend or "improve" without a corresponding update
# to every caller and to tests/test-check-commit.sh):
#   g-docs/* | g-wiki/* | docs/*        → DOC
#   README* | CHANGELOG* | LICENSE* at repo root (no slash) → DOC
#   README* | CHANGELOG* | LICENSE* nested (contains a slash) → CODE
#     (M-audit W3 task 12: a bare `README*` glob matches the *entire* path
#     string, not just a basename, so a non-root path whose top-level
#     component merely starts with "README" — e.g. `README-archive/notes.txt`,
#     a directory, not the doc file — was over-matching into DOC. Narrowed to
#     mirror the existing root-vs-nested split already used for *.md below.
#     Root-level oddities like `README_extended` intentionally stay DOC —
#     that pinned case is unchanged.)
#   *.md at repo root (no slash)        → DOC
#   *.md nested (contains a slash)      → CODE
#   hooks/* | skills/* | agents/* | commands/* | profiles/* | tests/* |
#     .claude-plugin/* | .claude/rules/*  → CODE
#   anything else (unmatched)           → CODE (default — the stricter gate,
#                                          so a misclassification never
#                                          weakens enforcement)
#   empty input                         → neither flag set; caller's CLASS
#                                          derivation falls through to CODE
#                                          (the historical fail-safe default)
#
# Call convention: invoke with a HEREDOC or input redirection —
#   gf_classify_changeset <<EOF
#   $STAGED
#   EOF
# — never by piping (`printf '%s' "$STAGED" | gf_classify_changeset`). A pipe
# runs the function in a subshell in plain bash, so its HAS_CODE/HAS_DOC
# assignments would not propagate back to the caller; a heredoc/redirection
# does not fork a subshell, so the globals land in the caller's own shell —
# exactly how hooks/check-commit.sh's original inline loop consumed $STAGED.

# gf_classify_changeset — see header. Sets globals HAS_CODE and HAS_DOC.
gf_classify_changeset() {
    HAS_CODE=0
    HAS_DOC=0
    local _f
    while IFS= read -r _f; do
        [ -z "$_f" ] && continue
        case "$_f" in
            # DOC paths — narrative documentation surface. Documentation
            # directories first.
            g-docs/*|g-wiki/*|docs/*) HAS_DOC=1 ;;
            # Root-level documentation files (README*, CHANGELOG*, LICENSE*)
            # and any root-level *.md (no slash in the path = repo root)
            # treated as docs. A bare README*/CHANGELOG*/LICENSE* glob matches
            # the whole path string, so without the root check a non-root path
            # whose top-level component merely starts with one of these words
            # (e.g. README-archive/notes.txt) would over-match into DOC; narrow
            # to root-only, same split already used for *.md below (M-audit W3
            # task 12). Non-matches fall through to the unmatched→CODE default,
            # keeping fail-toward-deny polarity unchanged.
            README*|CHANGELOG*|LICENSE*) case "$_f" in */*) HAS_CODE=1 ;; *) HAS_DOC=1 ;; esac ;;
            *.md) case "$_f" in */*) HAS_CODE=1 ;; *) HAS_DOC=1 ;; esac ;;
            # CODE paths — plugin executable/instruction surface. .claude/rules/
            # is instruction surface (code); anything under it gates as code.
            hooks/*|skills/*|agents/*|commands/*|profiles/*|tests/*|.claude-plugin/*|.claude/rules/*) HAS_CODE=1 ;;
            # When in doubt, treat as CODE — the code gate is the stricter one.
            *) HAS_CODE=1 ;;
        esac
    done
}
