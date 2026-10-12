"""Unit tests for known_defects.py (generator and check of test/known-defects.md).

Run:  python3 -m unittest discover -s .github/scripts -p "test_known_defects.py"

Each test builds a tiny repository tree in a temporary directory (a few source files and
test files) and exercises the parser, the validation, the rendering and the command line.
"""
import contextlib
import io
import os
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import known_defects as kd  # noqa: E402

VALID_ENTRY = """\
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: first problem
%       SEVERITY: wrong-result
%       TRIGGER: calling with x
%       OBSERVED: returns 1
%       EXPECTED: returns 2
%       LINES: 2, 4-5
"""


def header(function_path="src/dom/fn.m", defects=VALID_ENTRY):
    return (
        "% The COBRAToolbox: testFn.m\n%\n% Function under test:\n"
        "%     " + function_path + "\n%\n" + defects + "%\n% Authors:\n%     - someone\n\n"
        "x = 1;\n"
    )


class Tree:
    """A temporary repository tree."""

    def __init__(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.root = Path(self._tmp.name)
        self.add_source("src/dom/fn.m", 10)
        self.add_source("src/dom/other.m", 10)

    def add_source(self, rel, n_lines):
        p = self.root / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text("function y = f(x)\n" + "y = x;\n" * (n_lines - 1))

    def add_test(self, rel, text):
        p = self.root / "test" / "verifiedTests" / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(text)
        return p

    def close(self):
        self._tmp.cleanup()


class ParseTests(unittest.TestCase):
    def setUp(self):
        self.tree = Tree()
        self.addCleanup(self.tree.close)

    def collect(self):
        return kd.collect(self.tree.root)

    def test_valid_entry_is_parsed(self):
        self.tree.add_test("a/testFn.m", header())
        entries, errors = self.collect()
        self.assertEqual(errors, [])
        self.assertEqual(len(entries), 1)
        e = entries[0]
        self.assertEqual(e.function, "src/dom/fn.m")
        self.assertEqual(e.title, "first problem")
        self.assertEqual(e.severity, "wrong-result")
        self.assertEqual(e.trigger, "calling with x")
        self.assertEqual(e.lines, [(2, 2), (4, 5)])
        self.assertEqual(e.test_file, "test/verifiedTests/a/testFn.m")

    def test_two_entries_and_continuation_lines(self):
        text = (
            "% Known defects documented (NOT tested, NOT fixed here):\n"
            "%     - DEFECT: one\n%       SEVERITY: error\n"
            "%       TRIGGER: a long\n%         trigger text\n"
            "%       OBSERVED: o\n%       EXPECTED: e\n%       LINES: 3\n"
            "%     - DEFECT: two\n%       SEVERITY: cosmetic\n%       TRIGGER: t\n"
            "%       OBSERVED: o\n%       EXPECTED: e\n%       LINES: 4\n"
        )
        self.tree.add_test("a/testFn.m", header(defects=text))
        entries, errors = self.collect()
        self.assertEqual(errors, [])
        self.assertEqual([e.title for e in entries], ["one", "two"])
        self.assertEqual(entries[0].trigger, "a long trigger text")

    def test_none_found_gives_no_entry(self):
        for tail in ("None found.", "None found. (The function prints text.)"):
            text = "% Known defects documented (NOT tested, NOT fixed here):\n%     " + tail + "\n"
            self.tree.add_test("a/testFn.m", header(defects=text))
            entries, errors = self.collect()
            self.assertEqual((entries, errors), ([], []))

    def test_file_without_function_line_or_heading_is_ignored(self):
        self.tree.add_test("a/testOld.m", "% old test\n% Purpose: x\n\nx = 1;\n")
        self.assertEqual(self.collect(), ([], []))

    def test_function_line_without_heading_is_an_error(self):
        self.tree.add_test("a/testFn.m", header(defects=""))
        _, errors = self.collect()
        self.assertEqual(len(errors), 1)
        self.assertIn("no 'Known defects documented", errors[0].message)

    def test_free_text_under_heading_is_an_error(self):
        text = "% Known defects documented (NOT tested, NOT fixed here):\n%     the function is wrong somehow\n"
        self.tree.add_test("a/testFn.m", header(defects=text))
        _, errors = self.collect()
        self.assertEqual(len(errors), 1)
        self.assertIn("neither an entry nor 'None found.'", errors[0].message)

    def test_section_ends_at_empty_comment_line(self):
        text = VALID_ENTRY + "%\n%     - DEFECT: not in the section\n"
        self.tree.add_test("a/testFn.m", header(defects=text))
        entries, errors = self.collect()
        self.assertEqual((len(entries), errors), (1, []))

    def test_code_after_header_is_not_read(self):
        text = header() + "% - DEFECT: in the body\n"
        self.tree.add_test("a/testFn.m", text)
        entries, _ = self.collect()
        self.assertEqual(len(entries), 1)


class ValidationTests(unittest.TestCase):
    def setUp(self):
        self.tree = Tree()
        self.addCleanup(self.tree.close)

    def errors_for(self, defects, function_path="src/dom/fn.m"):
        self.tree.add_test("a/testFn.m", header(function_path, defects))
        return kd.collect(self.tree.root)[1]

    def entry(self, **override):
        fields = dict(
            DEFECT="d", SEVERITY="error", TRIGGER="t", OBSERVED="o", EXPECTED="e", LINES="2"
        )
        fields.update(override)
        lines = ["% Known defects documented (NOT tested, NOT fixed here):\n"]
        first = True
        for k, v in fields.items():
            if v is None:
                continue
            lines.append("%     - " + k + ": " + v + "\n" if first else "%       " + k + ": " + v + "\n")
            first = False
        return "".join(lines)

    def test_missing_field(self):
        errors = self.errors_for(self.entry(EXPECTED=None))
        self.assertEqual(len(errors), 1)
        self.assertIn("missing field EXPECTED", errors[0].message)

    def test_duplicate_field(self):
        text = self.entry() + "%       TRIGGER: again\n"
        errors = self.errors_for(text)
        self.assertEqual(len(errors), 1)
        self.assertIn("duplicate field TRIGGER", errors[0].message)

    def test_unknown_severity(self):
        errors = self.errors_for(self.entry(SEVERITY="bad"))
        self.assertEqual(len(errors), 1)
        self.assertIn("SEVERITY", errors[0].message)

    def test_all_severities_accepted(self):
        for sev in kd.SEVERITIES:
            self.assertEqual(self.errors_for(self.entry(SEVERITY=sev)), [])

    def test_bad_lines_values(self):
        for bad in ("abc", "0", "5-3", "2,,3", "2-"):
            errors = self.errors_for(self.entry(LINES=bad))
            self.assertEqual(len(errors), 1, bad)
            self.assertIn("LINES", errors[0].message)

    def test_line_beyond_source_length(self):
        errors = self.errors_for(self.entry(LINES="11"))
        self.assertEqual(len(errors), 1)
        self.assertIn("beyond", errors[0].message)

    def test_missing_source_file(self):
        errors = self.errors_for(self.entry(), function_path="src/dom/nope.m")
        self.assertEqual(len(errors), 1)
        self.assertIn("does not exist", errors[0].message)

    def test_duplicate_title_for_one_function_across_files(self):
        self.tree.add_test("a/testFn.m", header())
        self.tree.add_test("b/testFnToo.m", header())
        errors = kd.collect(self.tree.root)[1]
        self.assertEqual(len(errors), 1)
        self.assertIn("duplicate defect", errors[0].message)

    def test_same_title_for_different_functions_is_fine(self):
        self.tree.add_test("a/testFn.m", header("src/dom/fn.m"))
        self.tree.add_test("a/testOther.m", header("src/dom/other.m"))
        self.assertEqual(kd.collect(self.tree.root)[1], [])

    def test_error_names_file_and_line(self):
        errors = self.errors_for(self.entry(SEVERITY="bad"))
        self.assertEqual(errors[0].file, "test/verifiedTests/a/testFn.m")
        self.assertGreater(errors[0].line, 0)
        self.assertRegex(str(errors[0]), r"^test/verifiedTests/a/testFn\.m:\d+: ")


class RenderTests(unittest.TestCase):
    def setUp(self):
        self.tree = Tree()
        self.addCleanup(self.tree.close)

    def test_empty_registry_is_still_generated(self):
        text = kd.render([])
        self.assertIn("Generated", text)
        self.assertIn("no known defects", text.lower())

    def test_ordering_is_by_function_then_title_and_has_no_timestamp(self):
        second = VALID_ENTRY.replace("first problem", "a earlier title")
        self.tree.add_test("z/testOther.m", header("src/dom/other.m"))
        self.tree.add_test("a/testFn.m", header("src/dom/fn.m", VALID_ENTRY + "%     - DEFECT: zzz\n%       SEVERITY: error\n%       TRIGGER: t\n%       OBSERVED: o\n%       EXPECTED: e\n%       LINES: 1\n"))
        self.tree.add_test("a/testFnB.m", header("src/dom/fn.m", second))
        entries, errors = kd.collect(self.tree.root)
        self.assertEqual(errors, [])
        text = kd.render(entries)
        self.assertLess(text.index("a earlier title"), text.index("first problem"))
        self.assertLess(text.index("first problem"), text.index("zzz"))
        self.assertLess(text.index("src/dom/fn.m"), text.index("src/dom/other.m"))
        self.assertNotRegex(text, r"\b20\d\d-\d\d-\d\d")

    def test_output_is_identical_on_repeat_and_ends_with_newline(self):
        self.tree.add_test("a/testFn.m", header())
        entries, _ = kd.collect(self.tree.root)
        self.assertEqual(kd.render(entries), kd.render(list(reversed(entries))))
        self.assertTrue(kd.render(entries).endswith("\n"))
        self.assertNotIn("\r", kd.render(entries))

    def test_pipe_in_value_is_escaped_in_the_table(self):
        text = VALID_ENTRY.replace("first problem", "a | b")
        self.tree.add_test("a/testFn.m", header(defects=text))
        entries, _ = kd.collect(self.tree.root)
        table_rows = [l for l in kd.render(entries).splitlines() if l.startswith("| `")]
        self.assertEqual(len(table_rows), 1)
        self.assertIn("a \\| b", table_rows[0])
        self.assertEqual(table_rows[0].count("|") - table_rows[0].count("\\|"), 5)

    def test_summary_and_detail_content(self):
        self.tree.add_test("a/testFn.m", header())
        entries, _ = kd.collect(self.tree.root)
        text = kd.render(entries)
        for expected in ("| Function | Severity | Problem | Test file |", "wrong-result",
                         "calling with x", "returns 1", "returns 2", "2, 4-5",
                         "test/verifiedTests/a/testFn.m", "must not be edited by hand"):
            self.assertIn(expected, text)


class CommandLineTests(unittest.TestCase):
    def setUp(self):
        self.tree = Tree()
        self.addCleanup(self.tree.close)
        self.tree.add_test("a/testFn.m", header())

    def run_main(self, *args):
        out, err = io.StringIO(), io.StringIO()
        with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
            code = kd.main(["--root", str(self.tree.root), *args])
        return code, out.getvalue() + err.getvalue()

    def registry(self):
        return self.tree.root / "test" / "known-defects.md"

    def test_generate_then_check_passes(self):
        self.assertEqual(self.run_main()[0], 0)
        self.assertTrue(self.registry().exists())
        self.assertEqual(self.run_main("--check")[0], 0)

    def test_check_fails_when_registry_missing(self):
        code, output = self.run_main("--check")
        self.assertEqual(code, 1)
        self.assertIn("known_defects.py", output)

    def test_check_fails_after_hand_edit(self):
        self.run_main()
        self.registry().write_text(self.registry().read_text() + "hand edit\n")
        code, output = self.run_main("--check")
        self.assertEqual(code, 1)
        self.assertIn("out of date", output)

    def test_check_fails_after_header_change_without_regeneration(self):
        self.run_main()
        self.tree.add_test("a/testFn.m", header(defects=VALID_ENTRY.replace("first problem", "changed title")))
        self.assertEqual(self.run_main("--check")[0], 1)
        self.run_main()
        self.assertEqual(self.run_main("--check")[0], 0)

    def test_invalid_entry_gives_exit_2_and_writes_nothing(self):
        self.tree.add_test("a/testFn.m", header(defects=VALID_ENTRY.replace("wrong-result", "bad")))
        for args in ((), ("--check",)):
            code, output = self.run_main(*args)
            self.assertEqual(code, 2)
            self.assertIn("testFn.m:", output)
        self.assertFalse(self.registry().exists())

    def test_works_from_another_working_directory(self):
        here = os.getcwd()
        try:
            os.chdir(tempfile.gettempdir())
            self.assertEqual(self.run_main()[0], 0)
        finally:
            os.chdir(here)


if __name__ == "__main__":
    unittest.main()
