#!/bin/bash
# Shared argv-based git-commit detection + pathspec extraction.
#
# Sourced (never executed directly) by hooks/check-commit.sh and the ADR-004
# native pre-commit hook, so both enforcement sites agree on "what is a git
# commit" from a single implementation instead of two hand-edited regexes
# that can drift apart (M-audit finding #21 / BUG-2 root cause). This file
# defines functions only — sourcing it alone has no output and no side
# effects.
#
# Public API:
#   is_git_commit <cmd>      — return 0 iff <cmd> really invokes `git commit`
#   extract_pathspecs <cmd>  — print, one per line, <cmd>'s positional
#                              pathspec arguments (assumes is_git_commit true)

# _commit_detect_tokenize <cmd> — split <cmd> into argv-like tokens, one per
# output line. Uses `xargs -n1` (shell-style quote/whitespace splitting)
# rather than `eval` — eval re-parses the string as shell code and would
# execute embedded command substitutions/backticks even when the caller only
# wants to inspect argv, including on a command the gate ultimately denies.
_commit_detect_tokenize() {
    printf '%s' "$1" | xargs -n1 2>/dev/null
}

# _commit_detect_parse <cmd> — internal shared walk, used by both public
# functions so they classify a command identically (never two implementations
# that could disagree). Sets globals:
#   _CD_TOKENS  — array of argv tokens
#   _CD_N       — token count
#   _CD_OK      — 1 if <cmd> is confirmed `git commit`, 0 otherwise
#   _CD_IDX     — index of the first token AFTER the `commit` subcommand
#                 (only meaningful when _CD_OK=1)
_commit_detect_parse() {
    local cmd="$1"
    _CD_TOKENS=()
    while IFS= read -r _cd_tok; do
        _CD_TOKENS+=("$_cd_tok")
    done < <(_commit_detect_tokenize "$cmd")
    _CD_N=${#_CD_TOKENS[@]}
    _CD_OK=0
    _CD_IDX=0

    local i=0

    # Strip leading VAR=val assignments (env-style prefix, e.g. `FOO=bar git commit`).
    while [ "$i" -lt "$_CD_N" ]; do
        case "${_CD_TOKENS[$i]}" in
            [A-Za-z_][A-Za-z0-9_]*=*) i=$((i + 1)) ;;
            *) break ;;
        esac
    done

    # Strip a leading `env` / `env -S ...` prefix (its own flags and any
    # VAR=val pairs it carries), landing on the real command token.
    if [ "$i" -lt "$_CD_N" ] && [ "${_CD_TOKENS[$i]}" = "env" ]; then
        i=$((i + 1))
        while [ "$i" -lt "$_CD_N" ]; do
            case "${_CD_TOKENS[$i]}" in
                -*) i=$((i + 1)) ;;
                [A-Za-z_][A-Za-z0-9_]*=*) i=$((i + 1)) ;;
                *) break ;;
            esac
        done
    fi

    [ "$i" -lt "$_CD_N" ] || return 0

    # The first real token must be `git` (bare, or a path ending in /git) —
    # anything else means this isn't a git invocation at all.
    case "${_CD_TOKENS[$i]}" in
        git | */git) ;;
        *) return 0 ;;
    esac
    i=$((i + 1))

    # Walk forward skipping global flags that take a value: -C <path>, -c <k=v>.
    while [ "$i" -lt "$_CD_N" ]; do
        case "${_CD_TOKENS[$i]}" in
            -C | -c) i=$((i + 2)) ;;
            *) break ;;
        esac
    done

    [ "$i" -lt "$_CD_N" ] || return 0

    # The first non-flag token after `git` (and its global flags) must be
    # exactly the literal `commit` — not a substring, not a quoted fragment
    # of some other argument.
    if [ "${_CD_TOKENS[$i]}" = "commit" ]; then
        _CD_OK=1
        _CD_IDX=$((i + 1))
    fi
    return 0
}

# is_git_commit <cmd> — true (exit 0) iff <cmd> actually invokes `git commit`
# as the real command being run, per the argv walk above.
is_git_commit() {
    _commit_detect_parse "$1"
    [ "$_CD_OK" -eq 1 ]
}

# extract_pathspecs <cmd> — print, one per line, the positional pathspec
# arguments of a `git commit` invocation. Walks argv strictly after the
# `commit` subcommand token (never a blind slice after the last literal
# "commit" word, which would also match one cited inside the message body).
# Assumes <cmd> already passed is_git_commit; prints nothing otherwise.
extract_pathspecs() {
    _commit_detect_parse "$1"
    [ "$_CD_OK" -eq 1 ] || return 0

    local i=$_CD_IDX
    local seen_dashdash=0
    local tok

    while [ "$i" -lt "$_CD_N" ]; do
        tok="${_CD_TOKENS[$i]}"
        i=$((i + 1))
        if [ "$seen_dashdash" -eq 0 ]; then
            if [ "$tok" = "--" ]; then
                seen_dashdash=1
                continue
            fi
            case "$tok" in
                -m | --message | -c | -C | --reuse-message | --reedit-message | -F | --file | -A | --author | --date | --template | --fixup | --squash | --trailer)
                    i=$((i + 1)) # skip the flag's separate value token
                    continue
                    ;;
                --message=* | --reuse-message=* | --reedit-message=* | --file=* | --author=* | --date=* | --template=* | --fixup=* | --squash=* | --trailer=*)
                    continue
                    ;;
                -*)
                    continue
                    ;;
            esac
        fi
        printf '%s\n' "$tok"
    done
}
