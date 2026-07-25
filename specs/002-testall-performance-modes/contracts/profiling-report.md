# Contract — opt-in profiling report

Edit to `test/testAll.m`, after `runTestSuite` returns `resultTable`, before the
existing MoCov coverage block (the profiler is already `on` from testAll line ~101).

## Trigger

Enabled when `getenv('COBRA_PERF') == '1'` OR a workspace/global `PERFORMANCE_REPORT`
is truthy. **Off by default.** Independent of fast/full mode.

## Outputs (only when enabled)

1. **Ranked per-test timing** → `test/performance/testTiming.csv`
   (`resultTable` sorted by `Time` desc: rank, test, status, time_s); the top 20 are
   also printed to the console.
2. **Profiler hotspots** → `test/performance/profileInfo.mat` (`profile('info')`) and
   `test/performance/html/` (`profsave`); top 20 functions by total time printed.

## Guarantees

- Enabling/disabling the report MUST NOT change any test's pass/fail/skip outcome
  (FR-009).
- Wrapped in try/catch: if the profiler or `profsave` is unavailable, emit a visible
  warning (`::warning::`-style, matching the coverage block) and continue; never fail
  the run.
- Writes only under `test/performance/` (gitignored); creates the dir if absent.
- No effect when disabled (no files, no console change).

## Validation

Prototype `profileTestSubset.m` (session scratchpad) demonstrated the ranking +
`profile('info')` hotspot extraction on a live 4-test run.
