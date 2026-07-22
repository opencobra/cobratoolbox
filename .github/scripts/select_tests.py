#!/usr/bin/env python3
"""Select the CobraToolbox tests relevant to a PR's changed files.

Static, token-based *reverse* dependency analysis over ``src/`` and ``test/``:

  * index every ``src/**/*.m`` by its function name (== file basename, per the
    MATLAB rule that a file's primary function matches its filename);
  * a file "depends on" a src function if its text mentions that name as a
    word token (comments are intentionally NOT stripped -- an extra edge only
    makes us run *more* tests, which is safe; a missed edge would not be);
  * starting from the changed src files, walk the reverse-dependency edges
    ("who references me", transitively) to reach every ``test*.m`` that uses
    them, directly or through intermediate src functions;
  * changed ``test*.m`` files are always included directly.

Conservative full-run policy -- run the WHOLE suite when any of these hold:

  * ``COBRA_FORCE_FULL`` is truthy (e.g. a ``ci-full`` PR label);
  * a changed path matches a core/shared pattern (``src/base/**``,
    ``initCobraToolbox.m``, the test harness, ``.github/**``, ``external/**``,
    ``codecov.yml``) -- these can affect anything;
  * the selected set would be >= FULL_FRACTION of the whole suite anyway
    (a very widely-used dependency was touched -- selecting saves nothing).

Machine-readable results are printed to STDOUT as ``KEY=VALUE`` lines (ready to
append to ``$GITHUB_OUTPUT``); a human summary goes to STDERR.

  run_tests   = true | false      # false => nothing relevant; skip MATLAB
  mode        = full | selective | none
  test_filter = <regexp>          # empty when full; a runTestSuite() regexp

Anything unexpected (parse error, empty index, ...) fails safe to ``full``.
"""

import argparse
import os
import re
import sys

# Paths that, when touched, force the full suite (matched against posix relpaths).
CORE_PATTERNS = [
    r"^src/base/",              # solvers, IO, install, core utilities: used everywhere
    r"^initCobraToolbox\.m$",   # toolbox bootstrap
    r"^test/[^/]+\.m$",         # the test harness itself (testAll, runTestSuite, ...)
    r"^\.github/",              # workflow / CI scripts (including this one)
    r"^external/",              # bundled third-party code, broadly depended upon
    r"^codecov\.yml$",          # coverage gate configuration
]
CORE_RE = [re.compile(p) for p in CORE_PATTERNS]

# If the selection reaches this fraction of the whole suite, just run it all.
FULL_FRACTION = 0.90

IDENT_RE = re.compile(r"[A-Za-z][A-Za-z0-9_]*")


def truthy(val):
    return str(val).strip().lower() in ("1", "true", "yes", "on")


def walk_m_files(root, subdir):
    base = os.path.join(root, subdir)
    for dirpath, _dirs, files in os.walk(base):
        for f in files:
            if f.endswith(".m"):
                full = os.path.join(dirpath, f)
                rel = os.path.relpath(full, root).replace(os.sep, "/")
                yield rel, full


def read_text(path):
    try:
        with open(path, "r", encoding="utf-8", errors="replace") as fh:
            return fh.read()
    except OSError:
        return ""


def is_test_file(rel):
    return rel.startswith("test/verifiedTests/") and os.path.basename(rel).startswith("test")


def emit(mode, run_tests, test_filter):
    print(f"mode={mode}")
    print(f"run_tests={'true' if run_tests else 'false'}")
    print(f"test_filter={test_filter}")


def build_filter(test_basenames):
    # runTestSuite() keeps files whose path matches this regexp; anchor on the
    # basename so testFBA does not also drag in testFBADerived, etc.
    alt = "|".join(re.escape(n) for n in sorted(test_basenames))
    return rf"(?:{alt})\.m$"


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--changed", required=True,
                    help="file containing changed paths, one per line (git diff --name-only)")
    ap.add_argument("--root", default=".", help="repository root")
    args = ap.parse_args()

    root = os.path.abspath(args.root)

    # ---- changed files -------------------------------------------------------
    changed = []
    for line in read_text(args.changed).splitlines():
        line = line.strip()
        if line:
            changed.append(line.replace(os.sep, "/"))
    changed = sorted(set(changed))

    if not changed:
        # Nothing detected (odd, but possible for empty/merge diffs): be safe.
        print("No changed files detected -> running the full suite.", file=sys.stderr)
        emit("full", True, "")
        return 0

    # ---- force-full triggers -------------------------------------------------
    if truthy(os.environ.get("COBRA_FORCE_FULL", "")):
        print("COBRA_FORCE_FULL set -> running the full suite.", file=sys.stderr)
        emit("full", True, "")
        return 0

    core_hits = [c for c in changed if any(rx.search(c) for rx in CORE_RE)]
    if core_hits:
        print("Core/shared path(s) changed -> running the full suite:", file=sys.stderr)
        for c in core_hits[:20]:
            print(f"    {c}", file=sys.stderr)
        emit("full", True, "")
        return 0

    # ---- index src function names -------------------------------------------
    name_to_files = {}   # function name -> [src relpath, ...]
    src_files = {}       # src relpath -> text
    for rel, full in walk_m_files(root, "src"):
        name = os.path.basename(rel)[:-2]  # strip .m
        name_to_files.setdefault(name, []).append(rel)
        src_files[rel] = read_text(full)

    if not name_to_files:
        print("Empty src index -> running the full suite.", file=sys.stderr)
        emit("full", True, "")
        return 0

    # ---- reverse-dependency graph: defining src file -> files referencing it -
    dependents = {}  # src relpath -> set(referencing relpaths)

    def add_edges(rel, text):
        seen = set()
        for tok in IDENT_RE.findall(text):
            if tok in seen or tok not in name_to_files:
                continue
            seen.add(tok)
            for defrel in name_to_files[tok]:
                if defrel != rel:
                    dependents.setdefault(defrel, set()).add(rel)

    for rel, text in src_files.items():
        add_edges(rel, text)

    all_test_files = []  # list of test relpaths
    for rel, full in walk_m_files(root, "test"):
        if is_test_file(rel):
            all_test_files.append(rel)
            add_edges(rel, read_text(full))

    total_tests = len(all_test_files)

    # ---- collect selected tests ---------------------------------------------
    selected = set()

    # changed test files always run directly
    for c in changed:
        if is_test_file(c):
            selected.add(c)

    # reverse BFS from changed src files
    seeds = [c for c in changed if c in src_files]
    unknown_src = [c for c in changed
                   if c.startswith("src/") and c not in src_files]
    if unknown_src:
        # A changed src file we could not read/index: cannot reason about it.
        print("Un-indexable src change(s) -> running the full suite:", file=sys.stderr)
        for c in unknown_src[:20]:
            print(f"    {c}", file=sys.stderr)
        emit("full", True, "")
        return 0

    frontier = list(seeds)
    visited = set(seeds)
    while frontier:
        cur = frontier.pop()
        for ref in dependents.get(cur, ()):  # files that reference `cur`
            if is_test_file(ref):
                selected.add(ref)
            if ref not in visited:
                visited.add(ref)
                frontier.append(ref)

    # ---- decide mode ---------------------------------------------------------
    ignored = [c for c in changed
               if c not in src_files and not is_test_file(c)]

    if not selected:
        if seeds or any(is_test_file(c) for c in changed):
            # Touched code/tests but nothing reaches a test (e.g. a brand-new
            # unreferenced function). Safe default: run nothing here; the patch
            # coverage gate will flag genuinely-untested changes.
            print("No tests reach the changed code -> no tests to run.", file=sys.stderr)
            emit("none", False, "")
        else:
            # Only docs/tutorials/etc. changed.
            print("Only non-code paths changed -> no tests to run.", file=sys.stderr)
            emit("none", False, "")
        _summary(changed, ignored, selected, total_tests)
        return 0

    if total_tests and len(selected) >= FULL_FRACTION * total_tests:
        print(f"Selection covers {len(selected)}/{total_tests} tests "
              f"(>= {int(FULL_FRACTION*100)}%) -> running the full suite.",
              file=sys.stderr)
        emit("full", True, "")
        _summary(changed, ignored, selected, total_tests)
        return 0

    basenames = {os.path.basename(t)[:-2] for t in selected}
    emit("selective", True, build_filter(basenames))
    _summary(changed, ignored, selected, total_tests)
    return 0


def _summary(changed, ignored, selected, total_tests):
    print("", file=sys.stderr)
    print(f"Changed files:   {len(changed)}", file=sys.stderr)
    print(f"Ignored (no-op): {len(ignored)}", file=sys.stderr)
    print(f"Selected tests:  {len(selected)} / {total_tests}", file=sys.stderr)
    for t in sorted(selected):
        print(f"    {os.path.basename(t)}", file=sys.stderr)


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as exc:  # noqa: BLE001  -- fail safe to full on ANY error
        print(f"select_tests.py error: {exc!r} -> running the full suite.",
              file=sys.stderr)
        print("mode=full")
        print("run_tests=true")
        print("test_filter=")
        sys.exit(0)
