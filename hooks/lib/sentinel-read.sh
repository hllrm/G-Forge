#!/bin/bash
# hooks/lib/sentinel-read.sh — shared ADR-004 sentinel-stamp parser.
#
# Sourced (never executed directly) by hooks/pre-commit and
# hooks/workflow-checkpoint.sh, so the gate's own stamp format has exactly
# one reader instead of two hand-copied parsers that can drift apart
# (M-audit finding #21 / BUG-2 pattern — the same rationale behind
# hooks/lib/worktree-resolve.sh and hooks/lib/classify-changeset.sh). This
# file defines a function only — sourcing it alone has no output and no
# side effects.
#
# D1 (W1.5d Wave 3 design decision): ONLY gf_parse_stamp moves here.
# gf_validate_sentinel STAYS in hooks/pre-commit because it reads gate-local
# globals (TREE / HEAD_SHA / WORKTREE_KEY) that have no meaning outside the
# gate itself — it now calls this lib's gf_parse_stamp instead of a private
# copy.
#
# gf_parse_stamp <file> — parse the one-line sentinel stamp /g-review writes
# (skills/g-review/SKILL.md Step 6): a single line of space-separated
# key=value fields —
#   commit_sentinel_ts=<write-tree hash> commit_sentinel_head=<HEAD sha> commit_sentinel_worktree=<toplevel path>
# Field names copied byte-for-byte from the skill; do not rename/reorder.
#
# NOTE on the `_ts` name: despite the suffix, `commit_sentinel_ts` does NOT
# carry a timestamp — per SKILL.md Step 6 it carries `git write-tree` of the
# reviewed index (ADR-004's content-binding hash). Verified directly against
# the skill text before implementing this parser; the field is compared
# against the CALLER's own `git write-tree` output (see hooks/pre-commit's
# gf_validate_sentinel), never against a clock.
#
# Sets globals STAMP_TS / STAMP_HEAD / STAMP_WORKTREE (any may legitimately
# be an empty string — e.g. STAMP_HEAD on a first-commit-time stamp, where
# `git rev-parse HEAD` had nothing to resolve). Returns 1, leaving the
# globals blanked, on: missing file, multi-line/unparseable content, or any
# of the three required fields absent — all "invalid", never guessed past.
#
# gf_* namespace: every symbol here (function name and the STAMP_* globals
# it sets) is prefixed gf_/STAMP_ to avoid colliding with caller-local
# names — callers still own TREE / HEAD_SHA / WORKTREE_KEY etc. themselves.
gf_parse_stamp() {
    local file="$1" line
    STAMP_TS=""
    STAMP_HEAD=""
    STAMP_WORKTREE=""
    [ -f "$file" ] || return 1
    line=$(cat -- "$file" 2>/dev/null) || return 1
    # Strip one trailing CR (CRLF-authored sentinel) before further parsing.
    line=${line%$'\r'}
    # Must be a single line — embedded newlines mean the file is not the
    # one-line format the skill writes; treat as unparseable rather than
    # guess which line is authoritative.
    case "$line" in
        *$'\n'*) return 1 ;;
    esac
    case "$line" in
        *commit_sentinel_ts=*) ;;
        *) return 1 ;;
    esac
    case "$line" in
        *commit_sentinel_head=*) ;;
        *) return 1 ;;
    esac
    case "$line" in
        *commit_sentinel_worktree=*) ;;
        *) return 1 ;;
    esac
    STAMP_TS=${line#*commit_sentinel_ts=}
    STAMP_TS=${STAMP_TS%% *}
    STAMP_HEAD=${line#*commit_sentinel_head=}
    STAMP_HEAD=${STAMP_HEAD%% *}
    # commit_sentinel_worktree is the TERMINAL field on the stamp line (see
    # the fixed field order documented above) — read it to end-of-line
    # rather than truncating at the first space. Worktree paths legitimately
    # contain spaces (common on Windows, e.g. `C:/Users/Some Name/repo`);
    # the first two fields (ts, head) are still safely space-truncated above
    # because those values never contain spaces. Any future field appended
    # AFTER worktree would force revisiting this.
    STAMP_WORKTREE=${line#*commit_sentinel_worktree=}
    STAMP_WORKTREE=${STAMP_WORKTREE%$'\r'}
    return 0
}
