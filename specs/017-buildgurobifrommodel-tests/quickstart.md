# Quickstart: Validate the buildGurobiProblemFromModel characterization test

Prerequisites: a MATLAB install with the COBRA Toolbox path set up (no Gurobi
license required — the function under test never invokes the solver).

## Setup

```matlab
>> initCobraToolbox
```

(No solver needs to be configured; `changeCobraSolver` is not called by this test.)

## Run the new test standalone

```matlab
>> cd(fullfile(CBTDIR, 'test', 'verifiedTests', 'base', 'testSolvers'))
>> testBuildGurobiProblemFromModel
```

**Expected outcome**: the script runs to completion with no error and no output
(matching the sibling `testBuildOptProblemFromModel.m`'s silent-on-
success convention) — every `assert()` in the file passed.

## Validation checklist (maps to data-model.md fixtures and spec.md Traceability)

1. **Field set** (US1/FR-001): `fieldnames(gurobiModel)` for Toy Model 1 equals
   exactly `{A, obj, rhs, lb, ub, sense, modelsense}` (order-independent set
   comparison via `ismember`, mirroring the sibling test's `expectedFields` check).
2. **Field values** (US1/FR-002): `gurobiModel.A`, `.obj`, `.rhs`, `.lb`, `.ub`
   for Toy Model 1 `isequal` the values in `data-model.md`'s Toy Model 1 table.
3. **Sense translation** (US2/FR-003): `gurobiModel.sense` for Toy Model 1
   `isequal(['=';'<';'>'])`; `gurobiModel.sense` for Toy Model 1b (all-`'E'`
   variant) `isequal(['=';'=';'='])`.
4. **modelsense — max** (US1/FR-004): Toy Model 1's `gurobiModel.modelsense`
   `isequal('max')`.
5. **modelsense — min** (US1/FR-004): Toy Model 2's `gurobiModel.modelsense`
   `isequal('min')`.
6. **verify no-op on a valid model** (US3/FR-005): calling
   `buildGurobiProblemFromModel(model)`, `buildGurobiProblemFromModel(model, false)`,
   and `buildGurobiProblemFromModel(model, true)` on Toy Model 1 all `isequal`
   each other.
7. **verify error path** (US3/FR-005/SC-006): calling
   `buildGurobiProblemFromModel(invalidModel, true)` throws (assert via
   `verifyCobraFunctionError` or an equivalent try/catch that confirms an error
   was raised and re-enables state on failure).

## Run inside the full suite

```matlab
>> cd(CBTDIR)
>> testAll
```

**Expected outcome**: the new test is discovered automatically by `testAll.m`'s
recursive scan of `test/verifiedTests/` (no manual registration required) and
passes in both fast and full mode (it contains no per-solver loop to trim, so
fast/full behave identically for this test — feature 002). Confirm via the
summary table that `testBuildGurobiProblemFromModel` shows as passed,
and that no previously-passing test regressed.

## Confirm no `src` changes

```bash
git diff --stat -- src/
```

**Expected outcome**: empty (Constitution Principle III — characterization tests
must not modify the function under test or any other `src` file).
