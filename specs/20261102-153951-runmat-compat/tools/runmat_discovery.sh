#!/bin/bash
# RunMat test-runner discovery over the in-scope files of a COBRA tree (FR-014, SC-001).
#
# Usage: runmat_discovery.sh ROOT OUT
#   ROOT  repository root to measure (its in-scope files are listed by scope_files.py)
#   OUT   log file; a summary by error message is written to OUT.summary
#
# The in-scope files are copied to a measurement tree outside the repository, because RunMat
# compiles every file on its path and refuses to run while any one fails. Files that cannot be
# measured are set aside and listed in OUT.set-aside:
#   - files listed in $F/reports/runmat-set-aside.txt (RunMat compiler panics, defect D7);
#   - files that are not valid UTF-8 (defect D11).
#
# Environment:
#   RUNMAT        RunMat binary (required)
#   RUNMAT_LIBS   extra LD_LIBRARY_PATH entries for the binary (for example the HDF5 library folder)
#   WORK          folder for the measurement tree (default: a new mktemp folder)
set -u
ROOT=$(cd "$1" && pwd)
OUT=$(realpath -m "$2")
F=$(cd "$(dirname "$0")/.." && pwd)
: "${RUNMAT:?set RUNMAT to the RunMat binary}"
WORK=${WORK:-$(mktemp -d)}
TREE="$WORK/tree"
rm -rf "$TREE" && mkdir -p "$TREE"

(cd "$ROOT" && python3 "$F/tools/scope_files.py") > "$WORK/scope.txt"
: > "$OUT.set-aside"
SETASIDE="$F/reports/runmat-set-aside.txt"
while IFS= read -r path; do
    if [ -f "$SETASIDE" ] && grep -qxF "$path" <(cut -f1 "$SETASIDE"); then
        printf '%s\tlisted in runmat-set-aside.txt\n' "$path" >> "$OUT.set-aside"
    elif ! iconv -f UTF-8 -t UTF-8 "$ROOT/$path" > /dev/null 2>&1; then
        printf '%s\tnot UTF-8\n' "$path" >> "$OUT.set-aside"
    else
        mkdir -p "$TREE/$(dirname "$path")"
        cp -p "$ROOT/$path" "$TREE/$path"
    fi
done < "$WORK/scope.txt"

cd "$TREE" && LD_LIBRARY_PATH="${RUNMAT_LIBS:-}${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" timeout 900 \
    "$RUNMAT" test --color never --list --path=src --path=test test/verifiedTests > "$OUT" 2>&1
echo "exit=$?" >> "$OUT"

{
    echo "files measured: $(find "$TREE" -name '*.m' | wc -l)"
    echo "files set aside: $(wc -l < "$OUT.set-aside")"
    echo "files with a discovery error: $(grep -c '^Error: [^ ]*\.m: ' "$OUT")"
    echo
    echo "errors by message (the name in an undefined-name error replaced by '_'):"
    grep '^Error: [^ ]*\.m: ' "$OUT" | sed -E "s/^Error: [^ ]*\.m: //; s/(undefined [a-z]+) '[^']*'/\1 '_'/" \
        | sort | uniq -c | sort -rn
} > "$OUT.summary"
cat "$OUT.summary" | head -20
