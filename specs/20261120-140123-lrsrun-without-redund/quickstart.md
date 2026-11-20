# Quickstart: validate lrsRun without redund

Prerequisites: MATLAB R2024b or newer, COBRA initialised, lrs (lrslib 7 or later) on the PATH. Run
MATLAB through the project's memory-capped wrapper.

1. Test with coverage, as for the back-fill feature:
   `specs/20261113-142115-test-backfill-tiers/tools/run_coverage.sh <list> <out.jsonl>` with the line
   `test/verifiedTests/analysis/testLrsInterface/testLrsRun.m|src/analysis/topology/extremeRays/lrs/lrsInterface/lrsRun.m`.
   Expected: passed, every executable line except the non-Unix branch, nothing left behind.
2. Without redund: in MATLAB set `PATH` to a folder holding only links to `lrs` and `which`, run
   `runScriptFile('testLrsRun.m')`. Expected: status `passed` (before this feature: `skipped`,
   "required software is not installed: redund"). testLrsRun also runs its redund-free section this
   way itself.
3. Caller check: `testExtremePools` and `testExtremePathways` pass (they use `redund = 1`).
