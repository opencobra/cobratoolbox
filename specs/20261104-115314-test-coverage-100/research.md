# Research: coverage measurement

## R1 — Measuring per-test coverage of one function
- **Decision**: run each whole test script once through `runScriptFile` inside a temporary
  function-based test, with `CodeCoveragePlugin.forFile(<function under test>)` and Cobertura
  output; record executable lines and hit counts (`tools/measureCoverage.m`).
- **Rationale**: matches how `testAll` runs tests (sections share variables); a section-wise
  suite under-counts legacy tests whose sections depend on earlier ones.
- **Validated** on testExtractCompModel (18/18), testWaterGibbsEnergyOfFormation (11/11),
  testOptimizeCbModel (248/408).

## R2 — Documented exemptions
- **Decision**: a missed line counts as documented when its number appears in the header's
  "Coverage exemptions" block (numbers and ranges) or in a III-Defects entry's LINES field.
- **Allowed reasons** (III-Coverage, III-Defects): unavailable solver or toolbox, GUI,
  OS-specific branch, defective input skipped, and lines no input can reach (dead code,
  `if 0` blocks), stated as such.

## R3 — Mapping tests to functions
- 309 "Function under test:" headers, 218 `test<Name>` → `<name>.m` unique matches, 78 without a
  single function (out of scope, listed in the inventory).

## R4: Memory safety of measurement runs

- **Finding**: too many unmanaged parallel MATLAB sessions can exhaust a workstation's memory.
- **Decision**: runs go through a wrapper that limits the sessions and the memory of each. `tools/runCoverage.py` runs tests in short-lived chunks and records a killed test as `error` with the reason, so one heavy test cannot stop the run.
- **Alternatives**: fewer sessions alone leaves the run exposed to one heavy test.

## R5: Functions the coverage plugin cannot read

- **Finding**: MATLAB R2025a's coverage collector returns no lines for a function that calls a script (for example `AAStorage;` in setFeedingFastingConstraints), so a passing test looked unmeasured.
- **Decision**: such tests are measured with `tools/measureProfile.m`, which uses the profiler; records carry `method: profiler`. It counts `end` lines as executable, so its totals are slightly larger than the plugin's and never flatter a test (testExtractCompModel: 24/24 against 18/18). `src` is not changed.
