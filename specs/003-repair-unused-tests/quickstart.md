# Quickstart — validating the test repairs

Prerequisites: initialised COBRA Toolbox with the local solvers (gurobi, mosek, glpk,
pdco, quadMinos, dqqMinos). Run from the repo root. Each repaired test is validated
the same way: run it before and after, confirm the outcome improved without weakening.

## 1. Per-test before/after (the core check — SC-001/SC-002/SC-003)

For each repaired test, run it in isolation via the harness (isolated workspace):

```matlab
res = runScriptFile('testGenerateFieldDescriptionFile.m');   % from its folder
disp(res.status)   % expect 'passed' (was 'failed'/'errored'); or 'skipped' cleanly
```

Expected per category:
- **Code-bug fix** → status goes error/fail → `passed`, with the diff showing no
  assertion removed/loosened (SC-002).
- **Requirement broadening** → status goes `skipped` → `passed` on an available solver.
- **Clean-skip conversion** → status goes `errored` → `skipped` (COBRA:RequirementsNotMet).
- **Stray removal** → `test_myfunction.m` no longer present; suite still runs (SC-006).

## 2. lrs install (env-dependency, user-surfaced — FR-011)

The lrs tests need `lrs` on PATH. Install the freely-available package (this changes
system state — run it yourself):

```
! sudo apt-get install -y lrslib     # or: add binary/glnxa64/bin/lrs/ to PATH
```

Then:

```matlab
res = runScriptFile('testExtremePathways.m');   % expect 'passed' once lrs is on PATH
```

## 3. No regressions (SC-003)

Run a representative set of already-passing tests (in both fast and full modes) and
confirm none newly fails:

```matlab
for m = ["fast","full"]
    setenv('COBRA_TEST_MODE', m);
    % run a sample of previously-passing tests near the edited ones
end
```

## 4. Pass-count delta (definition of done — FR-008)

Record, over the touched set, the count of `passed` / `skipped` / `failed` before vs
after. Done requires: strictly more `passed`, strictly fewer `failed/errored`, and
every identified test accounted for (repaired / clean-skip / removed / documented).
Whole-suite source-line coverage is confirmed separately in CI.
