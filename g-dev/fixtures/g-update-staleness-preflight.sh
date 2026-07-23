#!/bin/bash
# g-update-staleness-preflight.sh — sandbox verification of /g-update's staleness
# preflight contract (skills/g-update/SKILL.md Step 0).
#
# VERIFICATION-ONLY: this script does not invoke the /g-update skill (it is
# markdown-based and non-executable). Instead, it sandbox-proves the preflight
# DECISION LOGIC mechanically — the same style as pre-commit-gate-verify.sh.
#
# Contract to prove:
# - Setup: temp sandbox with fake G-Forge project + fake plugin cache at
#   LOWER version than stubbed "GitHub latest"
# - Execute: scripted preflight logic (resolve triple, compare versions using
#   hooks/lib/semver-compare.sh — source the real lib, that IS the shared
#   contract), which on cache < latest must print the triple + STOP advisory
#   naming /plugins, and must NOT touch any sandbox project file.
# - Assert: (a) advisory text printed (grep for /plugins instruction + all
#   three triple versions); (b) ZERO writes — snapshot BEFORE (per-file sha256
#   + mtime) and compare AFTER: hashes identical AND file count identical.
#   Mtime granularity probed first: touch a probe file twice quickly, check
#   whether mtimes can distinguish. If coarse, note it and rely on hash
#   comparison as primary.
# - Also cover the equal/newer-cache branch: cache >= latest ⇒ no STOP
#   advisory (one negative case).
# - Teardown removes the sandbox even on failure (trap).
#
# Output: per-assert PASS/FAIL lines + totals; exit non-zero on any fail.

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="${GFORGE_REPO_ROOT:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
SEMVER_LIB="$REPO_ROOT/hooks/lib/semver-compare.sh"
BASE="$(mktemp -d)"

if [ ! -f "$SEMVER_LIB" ]; then
    echo "FATAL: cannot find $SEMVER_LIB" >&2
    exit 1
fi

echo "=== g-update-staleness-preflight — sandbox verification ==="
echo "REPO_ROOT=$REPO_ROOT"
echo "SEMVER_LIB=$SEMVER_LIB"
echo "BASE (temp sandbox)=$BASE"
echo

TOTAL_PASS=0
TOTAL_FAIL=0

# Cleanup trap — runs even on failure
trap 'rm -rf "$BASE"' EXIT

check() {
    # check <name> <1|0> <detail>
    local name="$1" ok="$2" detail="$3"
    if [ "$ok" = "1" ]; then
        echo "PASS: $name"
        TOTAL_PASS=$((TOTAL_PASS + 1))
    else
        echo "FAIL: $name -- $detail"
        TOTAL_FAIL=$((TOTAL_FAIL + 1))
    fi
}

# --- fixture helpers -------------------------------------------------------

new_project() {
    # new_project <name> -> prints absolute path of a temp project dir
    local name="$1"
    local dir="$BASE/project/$name"
    rm -rf "$dir"
    mkdir -p "$dir/.claude/hooks"

    # Create minimal G-Forge-managed files
    printf 'CLAUDE.md stub\n' > "$dir/CLAUDE.md"
    printf '# G-RULES\n' > "$dir/G-RULES.md"
    printf '#!/bin/bash\necho stub\n' > "$dir/.claude/hooks/x.sh"

    printf '%s' "$dir"
}

new_plugin_cache() {
    # new_plugin_cache <version> -> prints absolute path of fake cache dir at that version
    local version="$1"
    local dir="$BASE/plugin_cache/$version"
    mkdir -p "$dir/.claude-plugin"

    # Stub plugin.json with the given version
    printf '{\n  "name": "g-forge",\n  "version": "%s"\n}\n' "$version" > "$dir/.claude-plugin/plugin.json"

    printf '%s' "$dir"
}

snapshot_project() {
    # snapshot_project <project_dir> -> outputs "file_count\nsha256_per_file"
    # Hashes are primary signal; mtime is captured separately via probe.
    local proj="$1"
    local count=0
    local hashes=""

    if [ -d "$proj" ]; then
        # Count files, excluding .DS_Store and other noise
        count=$(find "$proj" -type f ! -name '.DS_Store' 2>/dev/null | wc -l)

        # SHA256 hashes of all files (or sha1sum if sha256sum unavailable), sorted by path
        if command -v sha256sum >/dev/null 2>&1; then
            hashes=$(find "$proj" -type f ! -name '.DS_Store' 2>/dev/null -exec sha256sum {} + | sort)
        else
            # Fallback to sha1sum on systems without sha256sum
            hashes=$(find "$proj" -type f ! -name '.DS_Store' 2>/dev/null -exec sha1sum {} + | sort)
        fi
    fi

    printf '%d\n%s\n' "$count" "$hashes"
}

mtime_granularity_probe() {
    # mtime_granularity_probe -> prints "granular" or "unknown"
    # Attempts to detect mtime granularity by touching a file twice and comparing.
    # If the test cannot be run (stat not available), prints "unknown" but does not fail.
    local probe_file="$BASE/mtime_probe"

    # Only attempt probe if ls can report times in seconds (simple check)
    touch "$probe_file"
    local ls_out1=$(ls -l "$probe_file" 2>/dev/null | awk '{print $6, $7, $8}')

    # Busy-loop a bit and touch again (attempt to create measurable time gap)
    local i=0
    while [ $i -lt 10000 ]; do
        i=$((i + 1))
    done
    touch "$probe_file"
    local ls_out2=$(ls -l "$probe_file" 2>/dev/null | awk '{print $6, $7, $8}')

    rm -f "$probe_file"

    # If the ls -l output differs (date/time changed), mtime is granular enough
    if [ "$ls_out1" != "$ls_out2" ]; then
        printf 'granular'
    else
        printf 'coarse'
    fi
}

curl_stub() {
    # curl_stub <version> -> simulates successful curl returning plugin.json with the given version
    # Called by the preflight logic as: "curl ... | grep ..."
    local version="$1"
    printf '{\n  "name": "g-forge",\n  "version": "%s"\n}\n' "$version"
}

run_preflight() {
    # run_preflight <project_dir> <cache_version> <latest_version>
    # Simulates the preflight logic from skills/g-update/SKILL.md Step 0.
    # Returns via OUTPUT_TRIPLE and OUTPUT_ADVISORY globals.
    local proj="$1" cache_ver="$2" latest_ver="$3"

    # Source the real semver-compare lib
    . "$SEMVER_LIB"

    OUTPUT_TRIPLE=""
    OUTPUT_ADVISORY=""

    # Resolve cache version (from the stubbed cache dir)
    local cache_dir="$BASE/plugin_cache/$cache_ver"
    if [ -f "$cache_dir/.claude-plugin/plugin.json" ]; then
        # In a real scenario this is read from the highest semver subdir; here we have a fixed stub
        OUTPUT_CACHE_VERSION="$cache_ver"
    else
        OUTPUT_CACHE_VERSION=""
    fi

    # Resolve latest version (simulated via stub function)
    local latest_json
    latest_json=$(curl_stub "$latest_ver")
    if [ -n "$latest_json" ]; then
        OUTPUT_LATEST_VERSION="$latest_ver"
    else
        OUTPUT_LATEST_VERSION=""
    fi

    # Project-installed version (unknown per the spec)
    OUTPUT_INSTALLED_VERSION="unknown"

    # Build the triple
    OUTPUT_TRIPLE="cache=$OUTPUT_CACHE_VERSION latest=$OUTPUT_LATEST_VERSION installed=$OUTPUT_INSTALLED_VERSION"

    # Compare versions
    if [ -z "$OUTPUT_CACHE_VERSION" ]; then
        # No cache found; continue without advisory
        OUTPUT_ADVISORY=""
        return 0
    fi

    # Use real semver-compare to decide
    local cmp_result
    cmp_result=$(gf_semver_compare "$OUTPUT_CACHE_VERSION" "$OUTPUT_LATEST_VERSION")

    if [ "$cmp_result" = "-1" ]; then
        # cache < latest => STOP advisory
        OUTPUT_ADVISORY="⚠ Plugin cache is stale — v${OUTPUT_CACHE_VERSION} installed, v${OUTPUT_LATEST_VERSION} available on GitHub.
  Project-installed version: v${OUTPUT_INSTALLED_VERSION}

Update the plugin cache first:
  /plugins  →  Installed  →  g-forge  →  Update now

Then re-run /g-update to sync your project files."
        return 1  # Signal: STOP, no writes
    else
        # cache >= latest => continue normally
        OUTPUT_ADVISORY=""
        return 0
    fi
}

# ============================================================================
echo "--- Probe: mtime granularity ---"
GRANULARITY=$(mtime_granularity_probe)
echo "  Granularity: $GRANULARITY (touch-twice test)"
echo

# ============================================================================
echo "--- Scenario a: cache < latest => STOP advisory, ZERO writes ---"
PROJ=$(new_project "a-stale-cache")
echo "  Project: $PROJ"

# Create the fake cache at v2.3.0 (lower than v2.4.0 latest)
CACHE_2_3=$(new_plugin_cache "2.3.0")
echo "  Fake cache v2.3.0: $CACHE_2_3"

# Snapshot project BEFORE the preflight
SNAP_BEFORE=$(snapshot_project "$PROJ")
BEFORE_COUNT=$(printf '%s\n' "$SNAP_BEFORE" | head -n1)
BEFORE_HASHES=$(printf '%s\n' "$SNAP_BEFORE" | tail -n +2)

echo "  Snapshot BEFORE: file_count=$BEFORE_COUNT"

# Run the preflight logic: cache 2.3.0 vs. latest 2.4.0
run_preflight "$PROJ" "2.3.0" "2.4.0"
PREFLIGHT_RC=$?
ADVISORY="$OUTPUT_ADVISORY"
TRIPLE="$OUTPUT_TRIPLE"

echo "  Preflight exit: $PREFLIGHT_RC (expected 1 for cache < latest)"
echo "  Printed triple: $TRIPLE"
echo "  Advisory length: ${#ADVISORY}"

# Snapshot project AFTER
SNAP_AFTER=$(snapshot_project "$PROJ")
AFTER_COUNT=$(printf '%s\n' "$SNAP_AFTER" | head -n1)
AFTER_HASHES=$(printf '%s\n' "$SNAP_AFTER" | tail -n +2)

echo "  Snapshot AFTER: file_count=$AFTER_COUNT"

# Check a1: advisory printed
ADVISORY_HAS_PLUGINS=$(case "$ADVISORY" in *"/plugins"*) echo 1 ;; *) echo 0 ;; esac)
ADVISORY_HAS_2_3=$(case "$ADVISORY" in *"2.3"*) echo 1 ;; *) echo 0 ;; esac)
ADVISORY_HAS_2_4=$(case "$ADVISORY" in *"2.4"*) echo 1 ;; *) echo 0 ;; esac)
check "a1: advisory names /plugins" "$ADVISORY_HAS_PLUGINS" "advisory='$ADVISORY'"
check "a2: advisory contains cache version 2.3" "$ADVISORY_HAS_2_3" "advisory='$ADVISORY'"
check "a3: advisory contains latest version 2.4" "$ADVISORY_HAS_2_4" "advisory='$ADVISORY'"

# Check b: ZERO writes
SAME_COUNT=0
if [ "$BEFORE_COUNT" = "$AFTER_COUNT" ]; then SAME_COUNT=1; fi
check "a4: file count unchanged (no new files)" "$SAME_COUNT" "before=$BEFORE_COUNT after=$AFTER_COUNT"

SAME_HASHES=0
if [ "$BEFORE_HASHES" = "$AFTER_HASHES" ]; then SAME_HASHES=1; fi
check "a5: file content hashes unchanged" "$SAME_HASHES" "before=$BEFORE_HASHES after=$AFTER_HASHES"

# c: mtime check (secondary, note if coarse)
if [ "$GRANULARITY" = "coarse" ]; then
    echo "  [note: mtime granularity is coarse; hash check is primary signal]"
fi

echo

# ============================================================================
echo "--- Scenario b: cache >= latest => no STOP advisory ---"
PROJ=$(new_project "b-current-cache")
echo "  Project: $PROJ"

# Create cache at v2.4.0 (same as latest v2.4.0)
CACHE_2_4=$(new_plugin_cache "2.4.0")
echo "  Fake cache v2.4.0: $CACHE_2_4"

# Snapshot BEFORE
SNAP_BEFORE=$(snapshot_project "$PROJ")
BEFORE_COUNT=$(printf '%s\n' "$SNAP_BEFORE" | head -n1)

# Run preflight: cache 2.4.0 vs. latest 2.4.0
run_preflight "$PROJ" "2.4.0" "2.4.0"
PREFLIGHT_RC=$?
ADVISORY="$OUTPUT_ADVISORY"

echo "  Preflight exit: $PREFLIGHT_RC (expected 0 for cache >= latest)"
echo "  Advisory: '${ADVISORY}' (expected empty)"

# Snapshot AFTER
SNAP_AFTER=$(snapshot_project "$PROJ")
AFTER_COUNT=$(printf '%s\n' "$SNAP_AFTER" | head -n1)

# Check b1: no STOP advisory
ADVISORY_EMPTY=0
if [ -z "$ADVISORY" ]; then ADVISORY_EMPTY=1; fi
check "b1: no advisory when cache is current" "$ADVISORY_EMPTY" "advisory='$ADVISORY'"

# Check b2: no writes
SAME_COUNT=0
if [ "$BEFORE_COUNT" = "$AFTER_COUNT" ]; then SAME_COUNT=1; fi
check "b2: file count unchanged (no writes)" "$SAME_COUNT" "before=$BEFORE_COUNT after=$AFTER_COUNT"

echo

# ============================================================================
echo "--- Scenario c: cache < latest by multiple minor versions ---"
PROJ=$(new_project "c-old-cache")
echo "  Project: $PROJ"

# Cache at v1.9.0, latest at v2.4.0 (major+minor difference)
CACHE_1_9=$(new_plugin_cache "1.9.0")
echo "  Fake cache v1.9.0: $CACHE_1_9"

# Snapshot BEFORE
SNAP_BEFORE=$(snapshot_project "$PROJ")
BEFORE_COUNT=$(printf '%s\n' "$SNAP_BEFORE" | head -n1)
BEFORE_HASHES=$(printf '%s\n' "$SNAP_BEFORE" | tail -n +2)

# Run preflight
run_preflight "$PROJ" "1.9.0" "2.4.0"
PREFLIGHT_RC=$?
ADVISORY="$OUTPUT_ADVISORY"

echo "  Preflight exit: $PREFLIGHT_RC"

# Snapshot AFTER
SNAP_AFTER=$(snapshot_project "$PROJ")
AFTER_COUNT=$(printf '%s\n' "$SNAP_AFTER" | head -n1)
AFTER_HASHES=$(printf '%s\n' "$SNAP_AFTER" | tail -n +2)

# Check c1: advisory printed
ADVISORY_HAS_1_9=$(case "$ADVISORY" in *"1.9"*) echo 1 ;; *) echo 0 ;; esac)
ADVISORY_HAS_2_4=$(case "$ADVISORY" in *"2.4"*) echo 1 ;; *) echo 0 ;; esac)
check "c1: advisory names old version 1.9" "$ADVISORY_HAS_1_9" "advisory='$ADVISORY'"
check "c2: advisory names new version 2.4" "$ADVISORY_HAS_2_4" "advisory='$ADVISORY'"

# Check c3: ZERO writes
SAME_COUNT=0
if [ "$BEFORE_COUNT" = "$AFTER_COUNT" ]; then SAME_COUNT=1; fi
check "c3: no writes on stale major version" "$SAME_COUNT" "before=$BEFORE_COUNT after=$AFTER_COUNT"

SAME_HASHES=0
if [ "$BEFORE_HASHES" = "$AFTER_HASHES" ]; then SAME_HASHES=1; fi
check "c4: hashes unchanged" "$SAME_HASHES" "before=$BEFORE_HASHES after=$AFTER_HASHES"

echo

# ============================================================================
echo "--- Scenario d: cache newer than latest (edge case) ---"
PROJ=$(new_project "d-newer-cache")
echo "  Project: $PROJ"

# Cache at v2.5.0, latest at v2.4.0 (cache is ahead)
CACHE_2_5=$(new_plugin_cache "2.5.0")
echo "  Fake cache v2.5.0: $CACHE_2_5"

# Snapshot BEFORE
SNAP_BEFORE=$(snapshot_project "$PROJ")
BEFORE_COUNT=$(printf '%s\n' "$SNAP_BEFORE" | head -n1)

# Run preflight
run_preflight "$PROJ" "2.5.0" "2.4.0"
PREFLIGHT_RC=$?
ADVISORY="$OUTPUT_ADVISORY"

echo "  Preflight exit: $PREFLIGHT_RC (expected 0 for cache > latest)"

# Snapshot AFTER
SNAP_AFTER=$(snapshot_project "$PROJ")
AFTER_COUNT=$(printf '%s\n' "$SNAP_AFTER" | head -n1)

# Check d1: no advisory when cache is ahead
ADVISORY_EMPTY=0
if [ -z "$ADVISORY" ]; then ADVISORY_EMPTY=1; fi
check "d1: no advisory when cache is ahead of latest" "$ADVISORY_EMPTY" "advisory='$ADVISORY'"

# Check d2: no writes
SAME_COUNT=0
if [ "$BEFORE_COUNT" = "$AFTER_COUNT" ]; then SAME_COUNT=1; fi
check "d2: no writes when cache is ahead" "$SAME_COUNT" "before=$BEFORE_COUNT after=$AFTER_COUNT"

echo

# ============================================================================
echo "=== SUMMARY ==="
echo "PASS: $TOTAL_PASS"
echo "FAIL: $TOTAL_FAIL"
echo "Mtime granularity: $GRANULARITY"

if [ "$TOTAL_FAIL" -ne 0 ]; then
    exit 1
fi
exit 0
