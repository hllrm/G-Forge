#!/bin/bash
# hooks/lib/semver-compare.sh — shared semver-order comparison helper.
#
# Sourced by hooks/skills; must be side-effect-free at source time (functions
# only, no top-level execution) — same contract as hooks/lib/stdin-read.sh.
#
# M46 (Update Integrity) gives workflow-checkpoint.sh, /g-doctor, and
# /g-update all a reason to know whether one version string is older, equal
# to, or newer than another (installed vs cache vs latest). Three consumers
# hand-rolling their own version-order idiom is exactly the split-brain shape
# that produced the "backwards nudge" bug class this milestone exists to
# close — e.g. a naive string or field compare telling the user to update
# when the cache is actually *behind* the repo. One comparison, one place.
#
# gf_semver_compare A B — print exactly one of -1 / 0 / 1 to stdout
# (A older / equal / newer than B), followed by a newline.
#
# Version grammar (this repo's convention, G-RULES §D):
#   MAJOR[.MINOR[.PATCH]][suffix]
# where suffix is a single lowercase letter (the hotfix convention, e.g.
# "2.3.3a"). Missing MINOR/PATCH default to 0 ("2.3" == "2.3.0").
#
# Ordering: MAJOR, MINOR, PATCH compare numerically, left to right. The
# suffix is compared only once all three numeric segments are equal —
# absent suffix sorts before any present suffix, and two present suffixes
# compare lexically as single characters ("2.3.3" < "2.3.3a" < "2.3.3b").
#
# Malformed input — either argument empty, or not matching the grammar
# above — prints "0" and returns exit status 1: "cannot compare, caller
# treats as no-action". Every well-formed comparison returns exit status 0.
#
# gf_semver_parse VER — internal helper. Validates VER against the grammar
# and, on success, prints "MAJOR MINOR PATCH SUFFIX" (space-separated,
# SUFFIX may be an empty trailing field) and returns 0. On a malformed VER,
# prints nothing and returns 1. Not intended to be called directly by hooks
# — exposed only because it is a named function in a sourced-only file.
gf_semver_parse() {
    local ver="$1"
    local suffix="" nums=""

    if [ -z "$ver" ]; then
        return 1
    fi

    # ERE: MAJOR required; .MINOR optional, .PATCH only valid nested under
    # MINOR; a single trailing lowercase-letter suffix is always optional.
    if [[ ! "$ver" =~ ^[0-9]+(\.[0-9]+(\.[0-9]+)?)?[a-z]?$ ]]; then
        return 1
    fi

    case "$ver" in
        *[a-z])
            suffix="${ver: -1}"
            nums="${ver%?}"
            ;;
        *)
            nums="$ver"
            ;;
    esac

    local major minor patch
    IFS='.' read -r major minor patch <<< "$nums"
    [ -z "$minor" ] && minor=0
    [ -z "$patch" ] && patch=0

    printf '%s %s %s %s\n' "$major" "$minor" "$patch" "$suffix"
    return 0
}

gf_semver_compare() {
    local a="$1" b="$2"
    local a_parsed b_parsed

    a_parsed="$(gf_semver_parse "$a")"
    if [ $? -ne 0 ]; then
        printf '%s\n' 0
        return 1
    fi
    b_parsed="$(gf_semver_parse "$b")"
    if [ $? -ne 0 ]; then
        printf '%s\n' 0
        return 1
    fi

    local a_major a_minor a_patch a_suffix
    local b_major b_minor b_patch b_suffix
    read -r a_major a_minor a_patch a_suffix <<< "$a_parsed"
    read -r b_major b_minor b_patch b_suffix <<< "$b_parsed"

    if [ "$a_major" -ne "$b_major" ]; then
        if [ "$a_major" -lt "$b_major" ]; then printf '%s\n' -1; else printf '%s\n' 1; fi
        return 0
    fi
    if [ "$a_minor" -ne "$b_minor" ]; then
        if [ "$a_minor" -lt "$b_minor" ]; then printf '%s\n' -1; else printf '%s\n' 1; fi
        return 0
    fi
    if [ "$a_patch" -ne "$b_patch" ]; then
        if [ "$a_patch" -lt "$b_patch" ]; then printf '%s\n' -1; else printf '%s\n' 1; fi
        return 0
    fi

    if [ "$a_suffix" = "$b_suffix" ]; then
        printf '%s\n' 0
        return 0
    fi
    if [ -z "$a_suffix" ]; then
        printf '%s\n' -1
        return 0
    fi
    if [ -z "$b_suffix" ]; then
        printf '%s\n' 1
        return 0
    fi
    if [[ "$a_suffix" < "$b_suffix" ]]; then
        printf '%s\n' -1
    else
        printf '%s\n' 1
    fi
    return 0
}
