#!/usr/bin/env bash
# checkCommentsOnly.sh — behaviour-preservation verifier for feature 014.
#
# For every src/*.m file that changed between <baseRef> and <headRef>, confirm that
# only comment and whitespace lines changed: the sequence of executable (non-comment,
# non-blank) lines, compared with all whitespace removed, MUST be identical before and
# after. Whitespace-insensitive comparison intentionally allows the permitted
# signature-whitespace change (H-SIG) and any indentation change, both behaviour-
# preserving in MATLAB, while catching any token addition/removal/reorder.
#
# USAGE:
#    test/verifiedTests/documentation/checkCommentsOnly.sh <baseRef> <headRef>
#
# Exit status: 0 if every changed src/*.m is comments-only; 1 otherwise (offending
# files listed on stderr). See specs/014-src-header-compliance/research.md R5.

set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "usage: $0 <baseRef> <headRef>" >&2
    exit 2
fi
BASE="$1"
HEAD="$2"

# Strip pure-comment lines (^ optional ws then %), join MATLAB `...` line
# continuations, drop blank lines, then remove ALL whitespace, yielding the
# whitespace-insensitive executable-token signature of a file. Joining `...`
# continuations first means a behaviour-preserving reflow of a multi-line
# statement (e.g. an H-SIG signature rewrite that moves the `...` breaks) is not
# mistaken for an executable-line change, while any real token add/remove/reorder
# still shows up in the joined signature.
code_signature() {
    # reads file content on stdin
    grep -vE '^[[:space:]]*%' \
        | awk '{ i = index($0, "..."); if (i > 0) printf "%s ", substr($0, 1, i - 1); else print $0 }' \
        | grep -vE '^[[:space:]]*$' | tr -d '[:space:]'
}

changed=$(git diff --name-only "$BASE" "$HEAD" -- 'src/**/*.m' 'src/*.m' | sort -u || true)

fail=0
count=0
for f in $changed; do
    count=$((count + 1))
    before=$(git show "$BASE:$f" 2>/dev/null | code_signature || true)
    after=$(git show "$HEAD:$f" 2>/dev/null | code_signature || true)
    if [ "$before" != "$after" ]; then
        echo "EXECUTABLE-LINE CHANGE: $f" >&2
        fail=1
    fi
done

if [ "$count" -eq 0 ]; then
    echo "no changed src/*.m files between $BASE and $HEAD"
fi

if [ "$fail" -ne 0 ]; then
    echo "FAIL: one or more src/*.m files changed executable lines (see above)" >&2
    exit 1
fi
echo "OK: $count changed src/*.m file(s) are comments/whitespace-only"
exit 0
