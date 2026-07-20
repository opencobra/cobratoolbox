# Quickstart — validating testAll performance modes

Prerequisites: initialised COBRA Toolbox with ≥2 working solvers (so fast mode has
redundant loops to trim); MATLAB R2014b+. Run from the repo root.

## 1. Mode resolver behaves per contract

```matlab
initCobraToolbox(false);
assert(strcmp(getCobraTestMode(),'fast'));                 % default
setenv('COBRA_TEST_MODE','full'); assert(strcmp(getCobraTestMode(),'full'));
setenv('COBRA_CI','1');           assert(strcmp(getCobraTestMode(),'full'));  % CI forces full
setenv('COBRA_CI','');  setenv('COBRA_TEST_MODE','');       % reset
```

Expected: default `fast`; `COBRA_CI=1` overrides to `full`; invalid value errors
`COBRA:testMode:invalid`.

## 2. A modified test passes in BOTH modes (no assertion change)

Pick a modified solver-looped test (e.g. `testGpSampler`, `testReadSBML`):

```matlab
for m = ["full","fast"]
    setenv('COBRA_TEST_MODE', m);
    res = runTestSuite('testGpSampler');        % narrowest relevant test
    assert(all(res.passed | res.skipped));      % same pass/fail as today
end
```

Expected: passes in both; fast-mode run is faster (fewer solver iterations).

## 3. Fast vs full: faster, coverage within tolerance (SC-001/002/003/004)

Run a representative subset (a handful of the ranked-slowest solver-looped tests)
in each mode, capturing wall-time and MoCov coverage:

- Full mode → record total time `T_full` and covered-line % `C_full`.
- Fast mode → record `T_fast`, `C_fast`.

Expected:
- `T_fast` materially below `T_full` (target order 40–50% on a multi-solver box).
- `C_full - C_fast ≤ 5` percentage points (absolute).
- Identical set of tests reported; pass/fail counts reconcile (no test dropped).
- `testFVA`/`testdynamicRFBA` remain fail/error in both modes (not masked).

## 4. Full mode reproduces today (SC-003)

With `COBRA_TEST_MODE=full`, confirm each touched test exercises the same solver
loops/models as the pre-feature version (spot-check the diff’s `if` guards resolve to
the original path in full mode).

## 5. Opt-in profiling report (SC-005)

```matlab
setenv('COBRA_PERF','1');
% run testAll (or a subset harness); then:
assert(isfile('test/performance/testTiming.csv'));   % ranked timing written
setenv('COBRA_PERF','');
% re-run: assert no new artifacts and unchanged pass/fail
```

Expected: with `COBRA_PERF=1`, a ranked CSV + profiler HTML under `test/performance/`
and printed slowest tests; disabled → no artifacts, behaviour unchanged.
