#!/bin/bash
# tests/lib/timing-bounds.sh — the suite's timing assertion bounds, declared once.
#
# Sourced by test suites; side-effect-free at source time (constants only, no
# top-level execution, no output).
#
# WHY a shared file rather than a constant per suite: these bounds are ONE fact
# each, and a fact duplicated across suites drifts. It already did — the
# hook-guard bound was widened in test-class-split-invariant.sh on fresh
# evidence and not in test-check-commit.sh, and that suite went red on the next
# run (20919ms / 20955ms against a 20000ms bound). A comment saying "keep these
# in step" does not enforce; a single definition does.
#
# Authoring rule (profiles/claude-plugin/rules/architecture.md, timing note):
# at least 2x the worst observed run on MSYS/Git-Bash, named *_MS, WHY stated.
# Author generous, tighten on evidence. The two empirical bounds below were
# first authored tight, both breached, and both now sit at 2x worst observed;
# the third constant is provisional and carries its own caveat in place.

# Hook-body-under-abandoned-pipe bound: a hook invoked with stdin attached to an
# open pipe that has no writer and never sends EOF must return once its 5s stdin
# guard fires. Covers test-check-commit.sh (cases 23, 25) and the six non-gating
# hooks in test-class-split-invariant.sh — the same fixture class either way.
#
# WHY 65000 and not 5s+epsilon: the epsilon is MSYS subprocess-spawn overhead in
# the hook body AFTER the read, which scales with machine load and dwarfs the
# guard it protects. Authored at 20000 when the worst observed was 9.9s on a
# quiet machine; breached on 2026-08-16 under a full suite plus agents
# (agent-lifecycle 21.8s, workflow-checkpoint 31.9s, check-commit 20.9s, and
# post-commit-cleanup — the smallest hook, no network, nothing after the read —
# at 23.5s). The same six hooks return in 9.3-15.4s idle, so 20000 sat only ~30%
# above the IDLE worst case and well inside the loaded distribution: a flaky
# bound, not a regression signal. 65000 is 2x the worst ever observed (31.9s).
#
# Still decisive: the guard-deleted failure mode blocks ~300s on the sleeper
# fixture, so this stays 4.6x under a genuine hang, and 61x under the 66-minute
# field orphan the guard exists to catch. It proves the hook RETURNS, which is
# the whole invariant. The fine-grained regression detector is the bound below,
# which exercises the lib directly with no hook body in the way.
GF_HOOK_STDIN_GUARD_MS=65000

# Bare-lib-read bound: gf_read_stdin_timeout called directly with a 1s timeout,
# no hook body, no subprocess fan-out. Used by test-stdin-read.sh.
#
# WHY 6000 and not 2000: the original was a bare literal allowing 1000ms over
# its own 1s timeout, tighter than the hook-body bound above that had already
# breached twice. It then reproduced red at 2876ms loaded and 2588ms on a quiet
# machine (2026-08-16), so it was a wrong bound rather than load flake. 6000 is
# 2x the worst observed (2876ms). Still 50x under the 300s sleeper fixture, so
# an unbounded read is caught with the same certainty as before.
GF_LIB_READ_WINDOW_MS=6000

# Fast-stdin-guard override bound: a hook invoked with stdin-timeout override
# set to ~2s (fast mode, test acceleration) instead of the production 5s
# guard. Bounds hooks running in override mode after M48c wires the override
# into test runs.
#
# Provisional, unvalidated: this value is authored before any suite consumes
# it, with no empirical run evidence yet. Placed in the 10000–20000ms range as
# a reasonable initial estimate accounting for MSYS subprocess overhead (see
# GF_HOOK_STDIN_GUARD_MS comment above). Must be revalidated against observed
# runs before any test depends on it. M48c closes with this revalidation; until
# then, treat this as a working placeholder, not a regression signal.
GF_FAST_STDIN_GUARD_MS=15000
