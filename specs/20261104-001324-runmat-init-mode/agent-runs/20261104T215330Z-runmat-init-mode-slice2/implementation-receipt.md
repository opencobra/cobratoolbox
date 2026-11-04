# Implementation receipt: runmat-init-mode, slice T013–T025

## Prompt

`/speckit-implemen` (typed as shown; taken as `/speckit-implement`). It was invoked after Gate 3 approved the
remaining tasks T013–T025 ("Continue with T013–T025 (Recommended)").

## Final response

T013–T025 are done except T019, which ran but did not meet its acceptance criterion (SC-002). The work is on branch `20261104-001324-runmat-init-mode` (`88ed03855..HEAD`) and has not been pushed.

**What changed:**
- **`initCobraToolbox.m`:** the banner link is clickable again in the MATLAB desktop (FR-014).
- **`test/testAll.m`:** `COBRA_RUNMAT=1` turns on RunMat mode, which is off by default. In that mode:
  - the toolbox folder comes from `mfilename`, marked D6 and D24;
  - it calls `initCobraToolbox(false, 'runmat')`;
  - it skips the final `exit()`, marked D10.
  In every mode, the `PERFORMANCE_REPORT` check now reads the variable through `eval`, marked D5. This works around D5, a RunMat compile-time error on a guarded read of an undefined variable. MATLAB gives the same value in all 12 cases checked.
- **Debt register:** it now has 7 workaround rows. The D26 entry now also describes how a `{}` stops an entire folder.
- **Previous feature's report:** an erratum, and a note that its FR-008 is superseded for these two files.

**Checks:**
- **MATLAB `testAll`** after the change (SC-003): 538 tests, 495 passed, 7 failed, 36 skipped, the same as the baseline. The only difference is the renamed test file, which passed before and after.
- **Debt re-check:** 7 markers match 7 register rows under both RunMat builds. Under v0.6.2 every entry is still needed. The newer build marks D5, D10 and D26–D29 as removable.
- No path under `external/`, `deprecated/` or a submodule changed.

**Not met: SC-002 under RunMat v0.6.2.** `testAll` stops before running its first statement:
- The cause is the `{}` on line 35 of `test/verifyCobraFunctionError.m` (D26), although `testAll` never calls that file.
- Under v0.6.2, a `{}` in any file in the folder of the script being run stops that script. I confirmed this with a 3-line reproducer.
- Run alone in a folder, `testAll.m` gets through its start-up.
- Fixing it means changing `{}` to `cell(0, 0)` in that file, which is outside the files this feature may change.

With the newer RunMat build, `testAll` reaches `initCobraToolbox(false, 'runmat')`, then stops with `Undefined function: changeCbMapOutput`. That defect isn't in the register.

## Diff summary

| Commit | Tasks | Change |
|---|---|---|
| 88ed03855 | T013–T014 | banner hyperlink under `usejava('desktop')` in `initCobraToolbox.m`; test comment |
| 5625ee3ef | T015–T018 | `COBRA_RUNMAT` switch in `test/testAll.m` (markers D5, D6, D24, D10); register rows; D10 reproducer covers `exit`; `reports/performance-report-check.txt` |
| 0a9a941d5 | T021, T023, T024 | erratum in the previous feature's report and run log; FR-008 superseded note; `reports/path-check.txt` |
| c879d1a61 | T019 (measured), T020 | `reports/runmat-testAll.txt`, `reports/recheck.txt`; D26 register note on its effect across the folder |
| (this commit) | T022, T025 | `reports/testAll-after.csv`, `reports/testAll-compare.md`, quickstart, this receipt, human-loop |

Source files: `initCobraToolbox.m` (+3), `test/testAll.m` (+23/−4), `test/runtimeCompatibility/RunMat/**`. The
uncommitted `findSExRxnInd.m`, `findStoichConsistentSubset.m` and `specs/20261104-134231-runmat-init-exploration/`
from another session were not touched or committed.

## Tests

- **MATLAB `testAll`** with `COBRA_CI=1` (R2026a): run on a full clone at `5625ee3ef`. The JUnit report was converted with `compare_testall.py csv` and compared with `compare_testall.py compare`. Result: `before 537 tests, after 537 tests, 2 differences`, both of them the rename pair.
- **`recheckRunMat.sh`:**
  - v0.6.2: 8 reproducers, all still needed; markers 7 = rows 7; exit 0.
  - Newer build: D6 and D24 still needed, the other six removable; exit 0.
- **`runmat_testall.sh`** with `COBRA_RUNMAT=1`, on a full clone at `5625ee3ef`:
  - v0.6.2 stops with `RunMat:MirAggregateShapeInvalid`, reported at `testAll.m:53:16`.
  - The culprit file, `test/verifyCobraFunctionError.m`, was found by bisecting the 2329 files in the tree.
- **`PERFORMANCE_REPORT`:** 12 cases checked in MATLAB, with 0 differences between the old and new expression.
- **`checkcode` on `test/testAll.m`:** the only new message is EVLCS on the D5 line, which the register records.

## Unresolved issues

- **SC-002 / T019 under v0.6.2:** blocked by D26 in `test/verifyCobraFunctionError.m`, which is outside this feature's files. It needs a decision: widen this feature's scope to that one MATLAB-equivalent rewrite, or open a follow-up feature.
- **Newer build:** two stops are not in the register. One is `Undefined function: changeCbMapOutput` under `testAll`; the other is "dynamic output count …" from the slice-1 driver. Both are left to the RunMat exploration inbox.

## Other information

Deviations:
- **T019 left unchecked in `tasks.md`:** the measurement was made and recorded, but its acceptance criterion failed.
- **D26 register row widened:** it now records the folder-wide effect. The register is in this feature's allowed
  files.
- **Newer RunMat build:** it is a copy of `../runmat` at `6e0a7df1a`, used for information only.
- **VII-F:** no MATLAB skill was loaded. `checkcode` was applied to both changed `.m` files.
