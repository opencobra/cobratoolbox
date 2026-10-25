"""Unit tests for the rule in select_tests.py that always selects the function-name
conflict test when a src function file changes.

Run:  python3 -m unittest discover -s .github/scripts -p "test_select_tests.py"
"""
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parent / "select_tests.py"
CONFLICT_TEST = "test/verifiedTests/base/testInstall/testFunctionNameConflicts.m"


def write(root, rel, text="function y = f(x)\ny = x;\nend\n"):
    path = Path(root) / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)


def select(root, changed_paths):
    changed = Path(root) / "changed.txt"
    changed.write_text("\n".join(changed_paths) + "\n")
    result = subprocess.run(
        [sys.executable, str(SCRIPT), "--changed", str(changed), "--root", str(root)],
        capture_output=True, text=True, check=True)
    return dict(line.split("=", 1) for line in result.stdout.splitlines() if "=" in line)


class NameConflictSelectionTests(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self._tmp.cleanup)
        self.root = self._tmp.name
        # many tests, so that selecting two of them stays below the 'run everything' fraction
        write(self.root, "src/analysis/used.m")
        write(self.root, "src/analysis/newUnreferenced.m")
        write(self.root, "test/verifiedTests/x/testUsed.m", "used(1);\n")
        write(self.root, CONFLICT_TEST, "% mentions no source function\n")
        for k in range(12):
            write(self.root, "test/verifiedTests/x/testOther%d.m" % k, "% nothing\n")

    def test_new_unreferenced_src_function_selects_the_conflict_test(self):
        out = select(self.root, ["src/analysis/newUnreferenced.m"])
        self.assertEqual(out["run_tests"], "true")
        self.assertIn("testFunctionNameConflicts", out["test_filter"])

    def test_changed_referenced_function_selects_its_test_and_the_conflict_test(self):
        out = select(self.root, ["src/analysis/used.m"])
        self.assertIn("testUsed", out["test_filter"])
        self.assertIn("testFunctionNameConflicts", out["test_filter"])

    def test_non_src_change_does_not_select_the_conflict_test(self):
        out = select(self.root, ["README.md"])
        self.assertEqual(out["run_tests"], "false")
        self.assertNotIn("testFunctionNameConflicts", out["test_filter"])


if __name__ == "__main__":
    unittest.main()
