# Implementation receipt: runmat-init-mode, slice T026–T027 (Gate 3 scope extension)

## Prompt

`/speckit-implement` (no further input). It was invoked after Gate 3 chose "Widen scope: fix that {} (Recommended)",
which added FR-016 and T026–T027. During T027 a second blocker appeared, and the decision "Widen to line 39 +
register D30 (Recommended)" extended the scope.

## Final response

All 27 tasks are done. SC-002 now holds under RunMat v0.6.2: `testAll` with `COBRA_RUNMAT=1` runs its start-up and stops at `initCobraToolbox(false, 'runmat')` on registered defect D27. The full MATLAB `testAll` is unchanged.

**What changed in `test/verifyCobraFunctionError.m`:** two rewrites that MATLAB runs the same, so neither is recorded as debt.
- **Line 35:** `{}` became `cell(0, 0)` (D26).
- **Line 39:** `parser.parse(..., varargin{:})` became `parse(parser, ..., varargin{:})` (D30, new).

Either construct, anywhere in a script's folder, stops RunMat v0.6.2 before the script's first line. This happens even when nothing calls the file.

**Debt register:** D30 is a new blocking defect: a method call that expands a cell into its arguments, as in `obj.m(c{:})`. It has a reproducer, and about 109 files contain the construct. The re-check:
- v0.6.2: every entry is still needed.
- The newer RunMat build: D30 is removable.
- Both builds: 7 markers match 7 register rows.

**Spec:** SC-002 now accepts a stop *at or inside* the `initCobraToolbox` call. Called from `test/`, `initCobraToolbox` is itself a function on the path, so D27 stops it at the call.

**Checks:**
- **MATLAB `testAll`** at `e2179c882`: 538 tests, 495 passed, 7 failed, 36 skipped, the same as the baseline. The only difference is the renamed test file. That includes the 65 tests that use the changed helper.
- **`checkcode`:** no new message.
- **Three tests that call the helper** pass in MATLAB.

**Newer RunMat build:** it still stops at `Undefined function: changeCbMapOutput`, which is not registered.

Nothing is pushed.

## Diff summary

| Commit | Tasks | Change |
|---|---|---|
| e367fa70d | Gate 3 | FR-016, T026–T027 in spec/plan/tasks; human-loop |
| d2230f7a5 | T026 | `test/verifyCobraFunctionError.m` line 35 `{}` → `cell(0, 0)` |
| e2179c882 | T026–T027 | line 39 → `parse(parser, ...)`; `repro/D30/` (D30.m, helper, expected.txt); D30 register row; FR-016 and SC-002 reworded; `reports/recheck.txt` |
| 9375090f4 | T019, T027 | `reports/runmat-testAll.txt` (T027 result first, T019 kept as superseded); quickstart |
| (this commit) | T027 | `reports/testAll-after.csv`, `reports/testAll-compare.md`, this receipt, human-loop |

Source files: `test/verifyCobraFunctionError.m` (+2/−2), `test/runtimeCompatibility/RunMat/**` (+14). The
uncommitted `findSExRxnInd.m`, `findStoichConsistentSubset.m` and `specs/20261104-134231-runmat-init-exploration/`
from another session were not touched or committed.

## Tests

- **MATLAB (MCP, R2026a):**
  - `checkcode` on `verifyCobraFunctionError.m`: 5 messages before and 5 after, the same lines and texts.
  - `testParseCobraVarargin`, `testMapAontoB` and `testExtendIndicesInDimenion` PASSED.
  - The D30 reproducer prints `start` and `1`, recorded as `expected.txt`.
- **MATLAB `testAll` (`COBRA_CI=1`)** on a full clone at `e2179c882`: `before 537 tests, after 537 tests, 2 differences`, which is the rename pair only.
- **`runmat_testall.sh` with `COBRA_RUNMAT=1`** at `e2179c882`:
  - v0.6.2 stops at `test/testAll.m:83:9`, `initCobraToolbox(false, 'runmat')`, with `RunMat:FunctionCompileError` ("local may be read before it is assigned", D27).
  - The intermediate run at `d2230f7a5` stopped with `RunMat:MirCellIndexPlanInvalid`. Bisecting the tree found line 39.
- **`recheckRunMat.sh`:** exit 0 under both builds.

## Unresolved issues

- **Newer build:** the `changeCbMapOutput` stop under `testAll` and the "dynamic output count" stop from the driver are not registered. They are left to the RunMat exploration inbox.
- **D30 across the toolbox:** about 109 files elsewhere in `src/` and `test/` use the construct. It is recorded as a blocking defect, not rewritten.

## Other information

Deviations:
- **Scope widened twice, both by explicit human decisions** (recorded in `human-loop.md`): first to line 35, then to line 39.
- **SC-002 reworded** at the second decision.
- **One MATLAB run stopped part-way:** the MATLAB `testAll` at `d2230f7a5` was stopped and replaced by the run at `e2179c882`.
