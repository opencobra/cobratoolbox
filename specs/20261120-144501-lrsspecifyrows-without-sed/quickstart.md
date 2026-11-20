# Quickstart: validate lrsSpecifyRows without sed

1. Coverage run (back-fill feature's `tools/run_coverage.sh`) of
   `testLrsSpecifyRows.m|lrsSpecifyRows.m` and `testLrsRun.m|lrsRun.m`: both pass, full coverage of
   lrsSpecifyRows, lrsRun except line 156 (non-Unix), nothing left behind.
2. testLrsSpecifyRows runs a section with an empty `PATH` itself; testLrsRun's minimal `PATH` holds
   only lrs and which.
3. Callers: the ten lrs-related tests of testLrsInterface/ and testTopology/ pass.
4. `python3 .github/scripts/known_defects.py` regenerates the registry: 861 defects (863 - 2).
