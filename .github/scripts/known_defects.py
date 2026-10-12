#!/usr/bin/env python3
"""Generate (or check) the registry of known defects, ``test/known-defects.md``.

Constitution III-Defects: when writing a test reveals a defect in a source function, the
defect is documented in the test header in one standard format and skipped, never asserted.
This tool reads those entries from every ``test*.m`` under ``test/verifiedTests`` and writes
the single registry. The registry is GENERATED and must not be edited by hand.

Usage:
    python3 .github/scripts/known_defects.py            # write test/known-defects.md
    python3 .github/scripts/known_defects.py --check    # fail if the registry is stale

Exit status: 0 = ok / written, 1 = registry stale or missing (check mode, optional and not
run in CI), 2 = invalid header entries (nothing is written).

The entry format is defined once, in
``specs/20261012-121035-known-defects-registry/contracts/defect-entry-format.md``.
Only the Python standard library is used; MATLAB is not needed.
"""
import argparse
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

HEADING = "Known defects documented (NOT tested, NOT fixed here):"
FUNCTION_LABEL = "Function under test:"
FIELDS = ("DEFECT", "SEVERITY", "TRIGGER", "OBSERVED", "EXPECTED", "LINES")
SEVERITIES = ("wrong-result", "error", "unusable-option", "cosmetic", "limitation")
REGISTRY_REL = "test/known-defects.md"
TESTS_REL = "test/verifiedTests"
REGENERATE = "python3 .github/scripts/known_defects.py"

_FIELD_RE = re.compile(r"^(" + "|".join(FIELDS) + r"):\s*(.*)$")
_ENTRY_RE = re.compile(r"^-\s*DEFECT:\s*(.*)$")


@dataclass(frozen=True)
class ParseError:
    file: str
    line: int
    message: str

    def __str__(self):
        return "%s:%d: %s" % (self.file, self.line, self.message)


@dataclass
class Entry:
    function: str
    title: str
    severity: str
    trigger: str
    observed: str
    expected: str
    lines: list
    test_file: str
    line: int = 0


@dataclass
class _Draft:
    """An entry while it is being read."""
    line: int
    values: dict = field(default_factory=dict)
    current: str = ""


def _header_block(text):
    """Return [(line_number, text_after_%)] for the leading comment lines of a file."""
    block = []
    for number, raw in enumerate(text.split("\n"), start=1):
        raw = raw.rstrip("\r")
        if not raw.startswith("%"):
            break
        block.append((number, raw[1:]))
    return block


def _parse_lines(value):
    """Parse '2, 4-5' into [(2, 2), (4, 5)]; raise ValueError with a reason."""
    ranges = []
    for item in value.split(","):
        item = item.strip()
        match = re.fullmatch(r"(\d+)(?:\s*-\s*(\d+))?", item)
        if not match:
            raise ValueError("'%s' is not a line number or a range a-b" % item)
        first = int(match.group(1))
        last = int(match.group(2)) if match.group(2) else first
        if first < 1 or last < first:
            raise ValueError("'%s' is not a valid line range (lines start at 1, a <= b)" % item)
        ranges.append((first, last))
    return ranges


def _format_lines(ranges):
    return ", ".join(str(a) if a == b else "%d-%d" % (a, b) for a, b in ranges)


def _source_length(root, rel, cache):
    if rel not in cache:
        path = Path(root) / rel
        if path.is_file():
            data = path.read_bytes().decode("utf-8", "replace")
            cache[rel] = data.count("\n") + (0 if data.endswith("\n") or not data else 1)
        else:
            cache[rel] = None
    return cache[rel]


def parse_header(text, test_rel, root, length_cache=None):
    """Parse the defects of one test file. Returns (entries, errors)."""
    length_cache = {} if length_cache is None else length_cache
    block = _header_block(text)
    entries, errors = [], []

    function_path, function_line = None, 0
    heading_index = None
    for index, (number, content) in enumerate(block):
        stripped = content.strip()
        if stripped == FUNCTION_LABEL and function_path is None:
            for follow_number, follow in block[index + 1:]:
                if follow.strip():
                    function_path, function_line = follow.strip(), follow_number
                    break
        elif stripped == HEADING and heading_index is None:
            heading_index = index

    if function_path is None and heading_index is None:
        return entries, errors  # an older test without the convention: ignored
    if function_path is None:
        return entries, [ParseError(test_rel, block[heading_index][0],
                                    "defects section found but no '%s' line" % FUNCTION_LABEL)]
    if heading_index is None:
        return entries, [ParseError(test_rel, function_line,
                                    "no '%s' section (write 'None found.' if there is no defect)" % HEADING)]

    # the section: from the line after the heading to the first empty comment line
    drafts, saw_none, saw_text = [], False, False
    for number, content in block[heading_index + 1:]:
        stripped = content.strip()
        if not stripped:
            break
        saw_text = True
        entry_match = _ENTRY_RE.match(stripped)
        field_match = _FIELD_RE.match(stripped)
        if entry_match:
            draft = _Draft(number, {"DEFECT": entry_match.group(1).strip()}, "DEFECT")
            drafts.append(draft)
        elif field_match:
            if not drafts:
                errors.append(ParseError(test_rel, number,
                                         "field %s before the first '- DEFECT:' entry" % field_match.group(1)))
                continue
            name, value = field_match.group(1), field_match.group(2).strip()
            draft = drafts[-1]
            if name in draft.values:
                errors.append(ParseError(test_rel, number, "duplicate field %s in the entry" % name))
            else:
                draft.values[name] = value
            draft.current = name
        elif stripped.startswith("None found."):
            saw_none = True
        elif drafts:
            draft = drafts[-1]  # continuation of the current field
            draft.values[draft.current] = (draft.values[draft.current] + " " + stripped).strip()
        elif saw_none:
            continue  # explanation that follows 'None found.'
        else:
            errors.append(ParseError(test_rel, number,
                                     "text under the defects heading is neither an entry nor 'None found.': '%s'" % stripped))
    if not saw_text:
        errors.append(ParseError(test_rel, block[heading_index][0],
                                 "empty defects section (write 'None found.' if there is no defect)"))
    if saw_none and drafts:
        errors.append(ParseError(test_rel, drafts[0].line, "'None found.' together with defect entries"))

    source_length = _source_length(root, function_path, length_cache)
    if source_length is None and drafts:
        errors.append(ParseError(test_rel, function_line,
                                 "source file '%s' does not exist" % function_path))

    for draft in drafts:
        missing = [name for name in FIELDS if name not in draft.values or draft.values[name] == ""]
        for name in missing:
            errors.append(ParseError(test_rel, draft.line, "missing field %s" % name))
        if missing:
            continue
        values = draft.values
        if values["SEVERITY"] not in SEVERITIES:
            errors.append(ParseError(test_rel, draft.line, "SEVERITY '%s' is not one of: %s"
                                     % (values["SEVERITY"], ", ".join(SEVERITIES))))
            continue
        try:
            ranges = _parse_lines(values["LINES"])
        except ValueError as problem:
            errors.append(ParseError(test_rel, draft.line, "LINES: %s" % problem))
            continue
        if source_length is not None and max(b for _, b in ranges) > source_length:
            errors.append(ParseError(test_rel, draft.line, "LINES %s is beyond the %d lines of %s"
                                     % (values["LINES"], source_length, function_path)))
            continue
        entries.append(Entry(function_path, values["DEFECT"], values["SEVERITY"], values["TRIGGER"],
                             values["OBSERVED"], values["EXPECTED"], ranges, test_rel, draft.line))
    return entries, errors


def collect(root):
    """Read every test header under test/verifiedTests. Returns (entries, errors)."""
    root = Path(root)
    tests_dir = root / TESTS_REL
    entries, errors, cache = [], [], {}
    seen = {}
    files = sorted(p for p in tests_dir.rglob("test*.m") if p.is_file()) if tests_dir.is_dir() else []
    for path in files:
        rel = path.relative_to(root).as_posix()
        text = path.read_bytes().decode("utf-8", "replace")
        found, problems = parse_header(text, rel, root, cache)
        errors.extend(problems)
        for entry in found:
            key = (entry.function, entry.title)
            if key in seen:
                other = seen[key]
                errors.append(ParseError(rel, entry.line, "duplicate defect '%s' for %s (also in %s:%d)"
                                         % (entry.title, entry.function, other.test_file, other.line)))
            else:
                seen[key] = entry
                entries.append(entry)
    return entries, errors


def _cell(value):
    return value.replace("|", "\\|")


def render(entries):
    """Render the registry as Markdown: deterministic, no timestamps."""
    ordered = sorted(entries, key=lambda e: (e.function, e.title, e.test_file))
    out = [
        "# Known defects in tested functions",
        "",
        "> **Generated file: do not edit by hand.** It is built from the "
        "\"Known defects documented\" section of each test header by "
        "`%s` (Constitution III-Defects)." % REGENERATE,
        "> It is a snapshot: a function may have been changed or fixed since an entry was "
        "written. When you rely on an entry or work on resolving a defect, re-check it against "
        "the current source, then update the test header and regenerate this file.",
        "",
    ]
    if not ordered:
        out += ["There are no known defects recorded yet.", ""]
        return "\n".join(out)
    functions = sorted({e.function for e in ordered})
    counts = ", ".join("%d %s" % (sum(1 for e in ordered if e.severity == s), s)
                       for s in SEVERITIES if any(e.severity == s for e in ordered))
    out += ["%d known defects in %d functions (%s)." % (len(ordered), len(functions), counts), "",
            "## Summary", "",
            "| Function | Severity | Problem | Test file |",
            "|----------|----------|---------|-----------|"]
    for e in ordered:
        out.append("| `%s` | %s | %s | `%s` |" % (e.function, e.severity, _cell(e.title), e.test_file))
    out += ["", "## Details", ""]
    for function in functions:
        out += ["### `%s`" % function, ""]
        for e in (x for x in ordered if x.function == function):
            out += ["#### %s" % e.title, "",
                    "- **Severity**: %s" % e.severity,
                    "- **Trigger**: %s" % e.trigger,
                    "- **Observed**: %s" % e.observed,
                    "- **Expected**: %s" % e.expected,
                    "- **Source lines**: %s" % _format_lines(e.lines),
                    "- **Documented in**: `%s`" % e.test_file, ""]
    return "\n".join(out)


def main(argv=None):
    default_root = Path(__file__).resolve().parents[2]
    parser = argparse.ArgumentParser(description="Generate or check test/known-defects.md")
    parser.add_argument("--root", default=str(default_root), help="repository root")
    parser.add_argument("--check", action="store_true",
                        help="do not write; fail if the registry is missing or out of date")
    args = parser.parse_args(argv)
    root = Path(args.root)

    entries, errors = collect(root)
    if errors:
        print("Invalid known-defect entries (nothing was written):", file=sys.stderr)
        for problem in errors:
            print("  " + str(problem), file=sys.stderr)
        return 2
    text = render(entries)
    registry = root / REGISTRY_REL
    if args.check:
        if not registry.is_file():
            print("%s is missing. Generate it with: %s" % (REGISTRY_REL, REGENERATE), file=sys.stderr)
            return 1
        if registry.read_bytes().decode("utf-8") != text:
            print("%s is out of date with the test headers (or was edited by hand). "
                  "Regenerate it with: %s" % (REGISTRY_REL, REGENERATE), file=sys.stderr)
            return 1
        print("%s is up to date (%d defects)." % (REGISTRY_REL, len(entries)))
        return 0
    registry.parent.mkdir(parents=True, exist_ok=True)
    with open(registry, "w", encoding="utf-8", newline="\n") as handle:
        handle.write(text)
    print("Wrote %s (%d defects)." % (REGISTRY_REL, len(entries)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
