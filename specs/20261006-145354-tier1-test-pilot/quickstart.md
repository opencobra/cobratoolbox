# Quickstart: validating the pilot

Prerequisites: MATLAB R2025a, repository root as working directory.

1. Initialize the toolbox once: `initCobraToolbox(false)`.
2. Run one test: `runtests('test/verifiedTests/base/testTools/testGetDefaultValue.m')`
   (repeat for the other four paths listed in plan.md).
3. Measure coverage of one function:
   ```matlab
   import matlab.unittest.TestRunner
   import matlab.unittest.plugins.CodeCoveragePlugin
   suite  = matlab.unittest.TestSuite.fromFile('<test path>');
   runner = TestRunner.withTextOutput;
   runner.addPlugin(CodeCoveragePlugin.forFile('<src path>'));
   runner.run(suite);
   ```
   Expected: every executable line covered, or each uncovered line listed in the test header.
4. Confirm no source change: `git diff --stat -- src` prints nothing.
5. Confirm the harness picks the tests up: `test/testAll.m` (or the change-based CI
   selector) lists the five new files.
