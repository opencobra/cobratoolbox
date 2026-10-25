# Implementation Receipt: function-name conflict test

## Prompt

User: "write me tests to fail when someone tries to add a function that has the same name as a previous cobra toolbox function or a MATLAB built-in function and also in the error indicates why it failed. do it with speckit". Work on develop; no personal information in repository files.

## Final response

Added testFunctionNameConflicts (test/verifiedTests/base/testInstall) plus a reviewed baseline file knownFunctionNameConflicts.txt. The test fails when a toolbox function has the same name as another toolbox function (src/ or external/, ignoring letter case and private/class/package folders) or as a MATLAB function, and its failure message lists every conflict with the clashing paths (and the MATLAB location), why it matters, and how to fix it or record a reviewed duplicate. It passes on the current repository (37 existing conflicts recorded with reasons: 35 duplicate names and 2 MATLAB-shadowing names), proves its own detector on a temporary tree, and was shown to fail for a copied function, a MATLAB-named function, a case-only twin and a removed baseline line. A rule in the change-based test selector makes the test run whenever a src function file changes. No src file changed.

## Diff summary

New: test/verifiedTests/base/testInstall/testFunctionNameConflicts.m, test/verifiedTests/base/testInstall/knownFunctionNameConflicts.txt, .github/scripts/test_select_tests.py, the feature folder under specs/.
Edited: .github/scripts/select_tests.py (one rule and one constant), .github/scripts/README.md (one list item), CLAUDE.md (plan pointer).
git diff --stat -- src: empty.

## Tests

- testFunctionNameConflicts through runScriptFile: passed in about 3.4 s; MATLAB path and working directory unchanged; no temporary files left.
- Failure demonstrations (all produced the expected explanatory message, then restored): copy of columnVector.m in another src folder; new union.m (MATLAB function); case twin ColumnVector.m; one baseline line removed.
- Python unit tests: 32 tests pass (3 new for the selector rule).
- Not verified: the rule in GitHub Actions; behaviour on Windows/macOS file systems; MATLAB toolboxes not installed here.

## Unresolved issues

- The MATLAB-function check is exact-case and sees only what is installed on the machine that runs it (documented in the test header).
- A further copy of an already recorded name is not detected (documented).
- 'setField' (src) vs 'Setfield' (external) differ only by case; on case-insensitive systems 'setField' also clashes with MATLAB's setfield. This is recorded as an existing duplicate; the MATLAB part is not detectable by the exact-case check.
- The selector edit touches .github/, which by the selector's own policy makes the introducing pull request run the full suite once.
