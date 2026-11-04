#!/bin/bash
# Re-check the RunMat compatibility debt (constitution VIII-Runtime).
#
# Usage: recheckRunMat.sh RUNMAT [REPO_ROOT]
#   RUNMAT     the RunMat binary to check
#   REPO_ROOT  COBRA repository root (default: three levels above this script)
#
# 1. Runs every reproducer repro/<id>/<id>.m in a fresh temporary copy of its folder (RunMat compiles every file
#    in the folder it runs from), drops RunMat's WARN lines, and compares the output with repro/<id>/expected.txt
#    (the MATLAB output). Prints one line per defect:
#       <id> <TAB> still needed|removable <TAB> first line of the RunMat output that differs
#    An optional repro/<id>/mode.txt containing "test-list" runs `runmat test --list --path=. tests` instead.
# 2. Compares the % RUNTIME-DEBT(RunMat:<id>) markers in .m files under REPO_ROOT (excluding specs/) with the rows
#    of the "Workarounds" table in debtRegister.md, as (file, defect) pairs, and prints every mismatch.
#
# Exit status: 0 when markers and register rows match; 1 otherwise; 2 on a usage error. A "removable" entry does
# not change the exit status: it is a report that a workaround can now be removed by a spec-driven change.
#
# Environment: RUNMAT_LIBS, extra LD_LIBRARY_PATH entries for the binary (for example the HDF5 library folder).
set -u
if [ $# -lt 1 ]; then
    echo "usage: $0 RUNMAT [REPO_ROOT]" >&2
    exit 2
fi
RUNMAT=$(realpath "$1")
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "${2:-$HERE/../../..}" && pwd)
export LD_LIBRARY_PATH="${RUNMAT_LIBS:-}${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

echo "RunMat: $("$RUNMAT" --version 2>/dev/null | grep -v WARN | head -1) ($RUNMAT)"
echo
echo "## Reproducers"
for dir in "$HERE"/repro/*/; do
    id=$(basename "$dir")
    [ -f "$dir/$id.m" ] || continue
    rm -rf "$WORK/run" && cp -r "$dir" "$WORK/run" && rm -f "$WORK/run/expected.txt" "$WORK/run/mode.txt"
    mode=run
    [ -f "$dir/mode.txt" ] && mode=$(tr -d '[:space:]' < "$dir/mode.txt")
    if [ "$mode" = "test-list" ]; then
        (cd "$WORK/run" && timeout 120 "$RUNMAT" test --color never --list --path=. tests) > "$WORK/out.txt" 2>&1
    else
        (cd "$WORK/run" && timeout 120 "$RUNMAT" run --color never "$id.m") > "$WORK/out.txt" 2>&1
    fi
    grep -v 'WARN' "$WORK/out.txt" > "$WORK/actual.txt"
    if diff -q "$dir/expected.txt" "$WORK/actual.txt" > /dev/null; then
        printf '%s\tremovable\t\n' "$id"
    else
        first=$(diff "$dir/expected.txt" "$WORK/actual.txt" | grep '^>' | head -1 | cut -c3- | cut -c1-120)
        printf '%s\tstill needed\t%s\n' "$id" "$first"
    fi
done

echo
echo "## Markers versus register"
(cd "$ROOT" && grep -rnoE --include='*.m' --exclude-dir=specs --exclude-dir=.git \
    'RUNTIME-DEBT\(RunMat:D[0-9]+\)' . ) \
    | sed -E 's#^\./##; s#^([^:]+):[0-9]+:RUNTIME-DEBT\(RunMat:(D[0-9]+)\)#\1\t\2#' | sort > "$WORK/markers.tsv"
awk '/^## Workarounds/{on=1; next} /^## /{on=0} on && /^\| *D[0-9]+ *\|/' "$HERE/debtRegister.md" \
    | awk -F'|' '{d=$2; f=$3; gsub(/[ `]/, "", d); gsub(/[ `]/, "", f); print f "\t" d}' | sort > "$WORK/rows.tsv"
echo "markers: $(wc -l < "$WORK/markers.tsv"), register rows: $(wc -l < "$WORK/rows.tsv")"
if diff "$WORK/markers.tsv" "$WORK/rows.tsv" > "$WORK/mismatch.txt"; then
    echo "markers and register rows match"
    exit 0
fi
sed -E 's/^</marker without a register row:/; s/^>/register row without a marker:/' "$WORK/mismatch.txt" \
    | grep -E '^(marker|register)'
exit 1
