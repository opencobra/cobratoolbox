# Quickstart: function-name conflict test

Prerequisites: MATLAB with the toolbox initialised (`initCobraToolbox(false)`), repository root.

1. Run the test through the harness runner, from `test/`:
   `res = runScriptFile('verifiedTests/base/testInstall/testFunctionNameConflicts.m'); disp(res.status)`
   (expect `passed`).
2. Demonstrate a failure: temporarily add `src/analysis/zzTmp/union.m` (a MATLAB name) or copy an
   existing function file to another `src/` folder, run step 1 (expect `failed` with the
   explanatory message), then delete the temporary file.
3. Selection rule: `printf 'src/analysis/foo/newFn.m\n' > /tmp/changed.txt && python3 .github/scripts/select_tests.py --changed /tmp/changed.txt --root .`
   (the output lists `testFunctionNameConflicts` in the test filter).
4. `python3 -m unittest discover -s .github/scripts -p "test_select_tests.py"`.
5. `git diff --stat -- src` prints nothing.
