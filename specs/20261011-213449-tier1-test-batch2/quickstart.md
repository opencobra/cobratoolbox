# Quickstart: validating batch 2

Prerequisites: MATLAB R2025a, repository root as working directory, `initCobraToolbox(false)`.

1. Run one test through the real harness runner, from `test/`:
   `res = runScriptFile('<path to test file>'); disp(res.status)` (expect `passed`).
2. Measure line coverage of its function (throwaway runner, not committed):
   ```matlab
   suite  = matlab.unittest.TestSuite.fromFile('<test path>');
   runner = matlab.unittest.TestRunner.withTextOutput;
   fmt = matlab.unittest.plugins.codecoverage.CoberturaFormat('<tmp>/cov.xml');
   runner.addPlugin(matlab.unittest.plugins.CodeCoveragePlugin.forFile('<src path>','Producing',fmt));
   runner.run(suite);
   ```
   Read `<line hits=".." number="..">` entries: covered = hits > 0.
3. Confirm no source change: `git diff --stat -- src` prints nothing.
4. Confirm no files were created by the tests: `git status --short` shows only the new test
   files and this feature's folder.
5. Batch: run all 50 through `runScriptFile`, record total time and the per-function
   covered/total table for the receipt.
