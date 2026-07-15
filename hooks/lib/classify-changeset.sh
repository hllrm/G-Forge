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
#     this changeset, 0 = absent). Always sets both globals, even for an
#     empty/whitespace-only input (both left 0), matching the pre-extraction
#     inline loop in hooks/check-commit.sh so the derived CLASS logic that
#     follows it (mixed/doc/code/none→code) is unaffected by this extraction.
#
# Bucket rules (byte-identical to hooks/check-commit.sh's former inline
# case-statement — do not extend or "improve" without a corresponding update
# to every caller and to tests/test-check-commit.sh):
#   g-docs/* | g-wiki/* | docs/*        → DOC
#   README* | CHANGELOG* | LICENSE*     → DOC
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
            # treated as docs.
            README*|CHANGELOG*|LICENSE*) HAS_DOC=1 ;;
            *.md) case "$_f" in */*) HAS_CODE=1 ;; *) HAS_DOC=1 ;; esac ;;
            # CODE paths — plugin executable/instruction surface. .claude/rules/
            # is instruction surface (code); anything under it gates as code.
            hooks/*|skills/*|agents/*|commands/*|profiles/*|tests/*|.claude-plugin/*|.claude/rules/*) HAS_CODE=1 ;;
            # When in doubt, treat as CODE — the code gate is the stricter one.
            *) HAS_CODE=1 ;;
        esac
    done
}
