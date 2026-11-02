#!/bin/bash
# Apply one rewrite category to a list of files and keep only the rewrites MATLAB reads identically.
#
# Usage (from the repository root): apply_and_verify.sh CATEGORY LIST
#   CATEGORY  ends | separators | catch | calls, optionally with a suffix (for example ends-rerun);
#             the part before the first '-' selects the tool
#   LIST      file of repository-relative .m paths
#
# Steps:
#   1. copy the listed files to a before-tree (outside the repository);
#   2. run the category tool on them (calls: names from the NAMES environment variable);
#   3. in MATLAB (matlab -batch), for every file the tool changed:
#      - ends, separators: parseTreeEquivalence, the parse tree must be unchanged;
#      - catch: parseTreeEquivalence in 'catch' mode, the tree may differ only by added catch nodes;
#      - calls: no parse-tree check (the tree changes by design; research.md R5);
#      - all: analyzerSnapshot before and after, the file must gain no analyzer message (FR-011);
#   A file whose original MATLAB cannot parse (a one-node error tree) is rejected, because its
#   parse-tree comparison would be vacuous.
#   4. restore every rejected file from the before-tree.
# Writes $F/reports/accepted-CATEGORY.txt, $F/reports/rejected-CATEGORY.txt (path and reason) and
# $F/reports/tool-CATEGORY.log.
set -eu
CATEGORY=$1
LIST=$(realpath "$2")
REPO=$(pwd)
F=$(cd "$(dirname "$0")/.." && pwd)
TOOLS="$F/tools"
REPORTS="$F/reports"
WORK=${WORK:-$(mktemp -d)}
BEFORE="$WORK/before-$CATEGORY"
mkdir -p "$REPORTS"
rm -rf "$BEFORE" && mkdir -p "$BEFORE"

while IFS= read -r path; do
    [ -n "$path" ] || continue
    mkdir -p "$BEFORE/$(dirname "$path")"
    cp -p "$path" "$BEFORE/$path"
done < "$LIST"

mapfile -t files < "$LIST"
case "${CATEGORY%%-*}" in
    ends)       TREEMODE=strict; python3 "$TOOLS/add_function_ends.py" "${files[@]}" ;;
    separators) TREEMODE=strict; python3 "$TOOLS/explicit_separators.py" "${files[@]}" ;;
    catch)      TREEMODE=catch;  python3 "$TOOLS/add_empty_catch.py" "${files[@]}" ;;
    calls)      TREEMODE=none;   python3 "$TOOLS/explicit_calls.py" --names "${NAMES:?set NAMES}" "${files[@]}" ;;
    *) echo "unknown category $CATEGORY" >&2; exit 2 ;;
esac > "$REPORTS/tool-$CATEGORY.log"

CHANGED="$WORK/changed-$CATEGORY.txt"
: > "$CHANGED"
for path in "${files[@]}"; do
    cmp -s "$path" "$BEFORE/$path" || echo "$path" >> "$CHANGED"
done
echo "$CATEGORY: $(wc -l < "$CHANGED") of ${#files[@]} files changed by the tool"
if [ ! -s "$CHANGED" ]; then
    : > "$REPORTS/accepted-$CATEGORY.txt"; : > "$REPORTS/rejected-$CATEGORY.txt"; exit 0
fi

matlab -batch "addpath('$TOOLS'); \
    if ~strcmp('$TREEMODE', 'none'), parseTreeEquivalence('$BEFORE', '$REPO', '$CHANGED', '$WORK/tree-$CATEGORY.json', '$TREEMODE'); end; \
    cd('$BEFORE'); analyzerSnapshot('$CHANGED', '$WORK/analyzer-before-$CATEGORY.json'); \
    cd('$REPO'); analyzerSnapshot('$CHANGED', '$WORK/analyzer-after-$CATEGORY.json');"

python3 - "$WORK" "$CATEGORY" "$TREEMODE" "$CHANGED" "$REPORTS" <<'PY'
import collections, json, os, sys
work, cat, mode, changed, reports = sys.argv[1:]
files = [l for l in open(changed).read().splitlines() if l]

def load(name):
    data = json.load(open(os.path.join(work, name)))
    return data if isinstance(data, list) else [data]

def idlist(ids):
    if ids is None:
        return []
    return [ids] if isinstance(ids, str) else list(ids)

tree = {r["file"]: r for r in load(f"tree-{cat}.json")} if mode != "none" else {}
before = {r["file"]: idlist(r["ids"]) for r in load(f"analyzer-before-{cat}.json")}
after = {r["file"]: idlist(r["ids"]) for r in load(f"analyzer-after-{cat}.json")}
acc, rej = [], []
for f in files:
    reasons = []
    if mode != "none":
        entry = tree.get(f, {})
        if entry.get("nodesBefore", 0) <= 1:
            reasons.append("MATLAB cannot parse the original")
        elif not entry.get("equal", False):
            reasons.append("parse tree changed")
    gained = collections.Counter(after.get(f, [])) - collections.Counter(before.get(f, []))
    if gained:
        reasons.append("analyzer gained " + ",".join(sorted(gained.elements())))
    (rej if reasons else acc).append((f, "; ".join(reasons)))
with open(os.path.join(reports, f"accepted-{cat}.txt"), "w") as out:
    out.writelines(f + "\n" for f, _ in acc)
with open(os.path.join(reports, f"rejected-{cat}.txt"), "w") as out:
    out.writelines(f"{f}\t{r}\n" for f, r in rej)
print(f"{cat}: accepted {len(acc)}, rejected {len(rej)}")
PY

while IFS=$'\t' read -r path reason; do
    cp -p "$BEFORE/$path" "$path"
    echo "reverted $path ($reason)"
done < "$REPORTS/rejected-$CATEGORY.txt"
