# Quickstart: known-defects registry

Prerequisites: Python 3, repository root as working directory (the tool also works from any
directory).

1. Generate: `python3 .github/scripts/known_defects.py` (writes `test/known-defects.md`).
2. Check only: `python3 .github/scripts/known_defects.py --check` (exit 0 if up to date,
   1 if stale, 2 if a header entry is invalid).
3. Unit tests of the tool: `python3 -m unittest discover -s .github/scripts -p "test_known_defects.py"`.
4. Prove the headers changed no behaviour: run the 55 batch tests through the harness runner
   (`runScriptFile` from `test/`); `git diff --stat -- src` must print nothing.
5. Add a defect: write an entry in the test header per
   [the contract](contracts/defect-entry-format.md), run step 1, commit both files.
