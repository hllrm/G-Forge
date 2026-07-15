#!/bin/bash
# hooks/lib/worktree-resolve.sh — shared worktree resolution helpers (ADR-005).
# Sourced by hooks; must be side-effect-free at source time (functions only,
# no top-level execution).
#
# Convention: on success, each function prints the resolved absolute path to
# stdout and returns 0. On ANY failure or unparseable/ambiguous input, each
# function prints NOTHING to stdout and returns 1 — callers must treat a
# non-zero return / empty stdout as "fail toward deny" per ADR-005, not as
# "this isn't a g-forge project" (that separate guard — the caller's
# `.claude/integration-tier` existence check — runs before these are ever
# invoked and is unaffected by this file).

# gf_resolve_primary_claude_dir — resolve the absolute path to the PRIMARY
# working tree's .claude/ directory, from inside either the primary tree or
# a linked worktree.
#
# `git rev-parse --git-common-dir` returns a path RELATIVE to cwd when run in
# the primary working tree (e.g. ".git") but an ABSOLUTE path when run inside
# a linked worktree (e.g. "D:/SW_Projects/G-Forge/.git") — both forms are
# normalized here into one absolute parent path (the parent directory of the
# resolved .git dir, joined with ".claude"). Prints nothing and returns 1 on
# any git failure, or on any result this function cannot confidently parse
# (nested-worktree / --separate-git-dir / submodule ambiguity) — per ADR-005
# this function's job is only to surface ambiguity, never to guess past it.
gf_resolve_primary_claude_dir() {
    local common_dir abs_common_dir parent rel_dir rel_base

    common_dir=$(git rev-parse --git-common-dir 2>/dev/null) || return 1
    [ -n "$common_dir" ] || return 1
    # Reject anything with embedded newlines (unparseable / multi-line output).
    case "$common_dir" in
        *$'\n'*) return 1 ;;
    esac

    case "$common_dir" in
        /*|[A-Za-z]:*)
            # Already absolute (POSIX-absolute or Windows drive-letter form,
            # e.g. "D:/SW_Projects/G-Forge/.git" as seen in a linked worktree).
            abs_common_dir="$common_dir"
            ;;
        *)
            # Relative — relative to cwd (the primary working tree's own
            # case, e.g. ".git"). Resolve by cd'ing into its parent and
            # reading the real pwd, then re-appending the basename.
            rel_dir=$(dirname -- "$common_dir")
            rel_base=$(basename -- "$common_dir")
            [ -n "$rel_base" ] || return 1
            rel_dir=$(cd -- "$rel_dir" 2>/dev/null && pwd -P) || return 1
            [ -n "$rel_dir" ] || return 1
            abs_common_dir="$rel_dir/$rel_base"
            ;;
    esac

    # Sanity check: the common-dir must actually be (or end in) ".git" for
    # the "parent directory is the primary repo root" assumption to hold.
    # Anything else — nested-worktree oddities, --separate-git-dir pointing
    # somewhere unexpected, a submodule's ".git/modules/<name>" form, etc. —
    # is genuine ambiguity per ADR-005: fail toward deny rather than guess.
    case "$abs_common_dir" in
        */.git|.git) ;;
        *) return 1 ;;
    esac

    parent=$(dirname -- "$abs_common_dir") || return 1
    [ -n "$parent" ] || return 1

    printf '%s/.claude\n' "$parent"
}

# gf_worktree_key — print the absolute path of the CURRENT worktree's
# toplevel directory. `git rev-parse --show-toplevel` already returns an
# absolute path that is distinct per tree (primary vs. each linked
# worktree), so no normalization is needed — it is used as-is as the
# per-worktree sentinel key, so an approval in one tree cannot bleed into
# another (ADR-005, composing with ADR-004's sentinel format). Prints
# nothing and returns 1 on any git failure or unparseable/empty result.
gf_worktree_key() {
    local toplevel

    toplevel=$(git rev-parse --show-toplevel 2>/dev/null) || return 1
    [ -n "$toplevel" ] || return 1
    case "$toplevel" in
        *$'\n'*) return 1 ;;
    esac

    printf '%s\n' "$toplevel"
}
