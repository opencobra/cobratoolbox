#!/bin/bash
# Run test/testAll.m under RunMat on a copy of a COBRA clone and record how far it gets (FR-014, T019).
#
# Usage: runmat_testall.sh SOURCE OUT
#   SOURCE  a full COBRA clone with its submodules checked out (not a git worktree: initCobraToolbox
#           fails where .git is a file). It is copied, never changed.
#   OUT     summary file; the RunMat output goes to OUT.output, the files set aside to OUT.set-aside,
#           and, when testAll writes its JUnit report, one row per test to OUT.csv
#
# RunMat compiles every file in a folder on its path when it first calls a function from it, and a
# file that fails to compile stops the call (it cannot be caught). The copy therefore keeps only the
# files RunMat compiles; the others are moved to WORK/set-aside and listed in OUT.set-aside:
#   1. files that are not valid UTF-8 (defect D11);
#   2. files on which `runmat check` panics (defect D7);
#   3. files that fail RunMat test discovery over the runtime path, repeated until none fails
#      (removing a function can make its callers fail).
# Test files set aside are not run; testAll does not see them. The entry points (ENTRY_POINTS) are
# never set aside: their discovery errors are reported, and the run shows where they stop it.
#
# Environment:
#   RUNMAT        RunMat binary (required)
#   RUNMAT_LIBS   extra LD_LIBRARY_PATH entries for the binary (for example the HDF5 library folder)
#   WORK          folder for the copy (default: a new mktemp folder); emptied first
#   TIME_LIMIT    limit for the testAll run, as for timeout(1) (default 4h)
#   JOBS          parallel `runmat check` processes (default 8)
#   SHIMS         optional folder of .m files copied to src/runmatShims in the copy, for functions that
#                 RunMat lacks. Off by default; a run with shims does not measure COBRA under RunMat
#                 alone, and the summary lists them.
#   COBRA_TESTS   passed to testAll (a runTestSuite filter), as under MATLAB
set -u
SOURCE=$(cd "$1" && pwd)
OUT=$(realpath -m "$2")
: "${RUNMAT:?set RUNMAT to the RunMat binary}"
RUNMAT=$(realpath "$RUNMAT")
WORK=${WORK:-$(mktemp -d)}
TIME_LIMIT=${TIME_LIMIT:-4h}
JOBS=${JOBS:-8}
TREE="$WORK/tree"
ENTRY_POINTS="test/testAll.m initCobraToolbox.m"
ASIDE="$WORK/set-aside"
export LD_LIBRARY_PATH="${RUNMAT_LIBS:-}${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
# git commands run by initCobraToolbox must not read or write the user's global configuration
export GIT_CONFIG_GLOBAL="$WORK/gitconfig"

if [ -f "$SOURCE/.git" ]; then
    echo "SOURCE is a git worktree; use a full clone" >&2
    exit 2
fi
rm -rf "$TREE" "$ASIDE" && mkdir -p "$TREE" "$ASIDE"
: > "$GIT_CONFIG_GLOBAL"
: > "$OUT.set-aside"
started=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "copying $SOURCE"
rsync -a "$SOURCE/" "$TREE/"
# not on the runtime path, and their tools are not COBRA code
rm -rf "$TREE/specs" "$TREE/documentation"
if [ -n "${SHIMS:-}" ]; then
    mkdir -p "$TREE/src/runmatShims"
    cp "$SHIMS"/*.m "$TREE/src/runmatShims/"
fi
cd "$TREE" || exit 2

set_aside() {  # path reason
    mkdir -p "$ASIDE/$(dirname "$1")"
    mv "$TREE/$1" "$ASIDE/$1"
    printf '%s\t%s\n' "$1" "$2" >> "$OUT.set-aside"
}

echo "setting aside files that are not UTF-8 or on which RunMat panics"
find . -name '*.m' -not -path './.git/*' -printf '%P\n' | sort > "$WORK/files.txt"
while IFS= read -r path; do
    iconv -f UTF-8 -t UTF-8 "$path" > /dev/null 2>&1 || set_aside "$path" "not UTF-8 (D11)"
done < "$WORK/files.txt"
find . -name '*.m' -not -path './.git/*' -printf '%P\n' | sort \
    | xargs -P "$JOBS" -I{} sh -c 'timeout 60 "$0" check --color never "$1" 2>&1 | grep -q "panicked at" && echo "$1"' "$RUNMAT" {} \
    | sort > "$WORK/panics.txt"
while IFS= read -r path; do
    set_aside "$path" "runmat check panics (D7)"
done < "$WORK/panics.txt"
: > "$WORK/entry-errors.tsv"

echo "setting aside files that fail discovery"
round=0
while :; do
    round=$((round + 1))
    timeout 1800 "$RUNMAT" test --color never --list --path=. test/verifiedTests > "$WORK/discovery-$round.txt" 2>&1
    if grep -q "panicked at" "$WORK/discovery-$round.txt"; then
        echo "discovery panicked in round $round; see $WORK/discovery-$round.txt" >&2
        exit 3
    fi
    grep -oE '^Error: [^ ]+\.m: .*' "$WORK/discovery-$round.txt" \
        | sed -E 's/^Error: ([^ ]+\.m): (.*)$/\1\t\2/' | sort -u -t$'\t' -k1,1 > "$WORK/failing-$round.tsv"
    removed=0
    while IFS=$'\t' read -r path message; do
        path=${path#"$TREE/"}
        path=${path#./}
        if [[ " $ENTRY_POINTS " == *" $path "* ]]; then
            grep -qF "$path"$'\t'"$message" "$WORK/entry-errors.tsv" \
                || printf '%s\t%s\n' "$path" "$message" >> "$WORK/entry-errors.tsv"
        elif [ -f "$TREE/$path" ]; then
            set_aside "$path" "discovery round $round: $message"
            removed=$((removed + 1))
        fi
    done < "$WORK/failing-$round.tsv"
    [ "$removed" -gt 0 ] || break
    if [ "$round" -ge 20 ]; then
        echo "discovery still failing after 20 rounds" >&2
        exit 3
    fi
done

echo "running testAll (limit $TIME_LIMIT)"
rm -f "$TREE/testReport.junit.xml"
t0=$(date +%s)
COBRA_CI=1 timeout "$TIME_LIMIT" "$RUNMAT" run --color never test/testAll.m > "$OUT.output" 2>&1
status=$?
elapsed=$(( $(date +%s) - t0 ))

F=$(cd "$(dirname "$0")/.." && pwd)
{
    echo "# testAll under RunMat"
    echo
    echo "- Started: $started"
    echo "- Source: $SOURCE @ $(git -C "$SOURCE" rev-parse --short HEAD)"
    echo "- RunMat: $("$RUNMAT" version 2>/dev/null | grep -v WARN | head -1) ($RUNMAT)"
    echo "- Command: COBRA_CI=1${COBRA_TESTS:+ COBRA_TESTS=$COBRA_TESTS} timeout $TIME_LIMIT runmat run test/testAll.m, in a copy of SOURCE"
    if [ -n "${SHIMS:-}" ]; then
        echo "- Shims (functions RunMat lacks, supplied for this run): $(cd "$SHIMS" && ls *.m | tr '\n' ' ')"
    else
        echo "- Shims: none"
    fi
    echo "- Exit status: $status$([ "$status" = 124 ] && echo ' (time limit reached)'), after ${elapsed}s"
    echo
    echo "## Files set aside ($(wc -l < "$OUT.set-aside"))"
    echo
    echo '```'
    cut -f2 "$OUT.set-aside" | sed -E 's/: .*//' | sort | uniq -c | sort -rn
    echo "test files among them (not run): $(grep -c '^test/verifiedTests/.*\.m' "$OUT.set-aside")"
    echo '```'
    echo
    if [ -s "$WORK/entry-errors.tsv" ]; then
        echo "## Entry points that fail discovery (kept, not set aside)"
        echo
        echo '```'
        cat "$WORK/entry-errors.tsv"
        echo '```'
        echo
    fi
    if [ -f "$TREE/testReport.junit.xml" ]; then
        echo "## Test results"
        echo
        echo '```'
        python3 "$F/tools/compare_testall.py" csv "$TREE/testReport.junit.xml" "$OUT.csv"
        echo '```'
    else
        echo "## Stopping point (no JUnit report was written)"
        echo
        echo '```'
        grep -v 'WARN wgpu' "$OUT.output" | grep -n -E -A12 '^(Execution )?[Ee]rror[: ]|panicked at' | head -40
        echo '```'
        echo
        echo "Last lines of the output:"
        echo
        echo '```'
        grep -v 'WARN wgpu' "$OUT.output" | tail -15
        echo '```'
    fi
} > "$OUT"
cat "$OUT"
