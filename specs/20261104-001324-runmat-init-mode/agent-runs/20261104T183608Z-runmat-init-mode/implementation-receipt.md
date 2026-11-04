# Implementation receipt: runmat-init-mode, slice T001–T012

## Prompt

`/speckit-implement` (no further input). It was invoked after Gate 2 approved the first slice T001–T012 ("Fix
findings, approve slice (Recommended)").

## Final response

The approved slice T001–T012 is implemented. It is on branch `20261104-001324-runmat-init-mode` (`be511edec..39e80441d`) and has not been pushed. `initCobraToolbox(false, 'runmat')` now exists, behaves exactly like agent mode in MATLAB, and under RunMat v0.6.2 gets through its own start-up before stopping at the first toolbox call on a known RunMat defect.

**What changed:**
- **`'runmat'` mode in `initCobraToolbox.m`:**
  - it follows agent mode, so it is silent and skips git, network access, solver probing and path saving;
  - combining it with `updateToolbox=true` is an error;
  - two workarounds run only in this mode, each marked `% RUNTIME-DEBT(RunMat:<id>)`: the toolbox folder comes from `mfilename` instead of `which` (D6, D24), and `prefdir` isn't called (D10);
  - the help header documents the mode.
- **Two rewrites in every mode:** `{}` became `cell(0, 0)` (9 places), and adding the missing `docs/source/notes` folder to the path now checks that it exists. MATLAB gives the same result either way, so these aren't recorded as debt.
- **Summary line:** it now names the mode, `runmat mode` or `agent mode`. The agent-mode text is unchanged.
- **Test:** `testInitCobraToolboxAgentMode.m` is renamed to `testInitCobraToolbox.m` (one test file per function) and gains two tests:
  - argument checks for the new mode;
  - a check that, in MATLAB, `'runmat'` mode gives the same toolbox folder and path entries as agent mode and leaves the git setting `http.sslVerify` unchanged.
- **Debt record** in `test/runtimeCompatibility/RunMat/`:
  - a register with 3 workaround rows and 4 blocking defects (D26–D29);
  - 8 reproducers, each with the output MATLAB gives;
  - `recheckRunMat.sh`.

**Checks:**
- `testInitCobraToolbox` failed before the change and passes after.
- The MATLAB code analyzer shows no new message for `initCobraToolbox.m`.
- The re-check finds 3 markers matching 3 register rows.
- MATLAB `testAll` baseline (T001): 538 tests; 495 passed, 7 failed, 36 skipped. Four failures are the ones known from before; the other three come from the greedy-ray work already on this branch.

**Under RunMat:**
- **v0.6.2:** `initCobraToolbox.m` now loads in RunMat. The run stops at `changeCbMapOutput` on D27/D28, which are in the register, so SC-001 holds.
- **A newer RunMat build from the parallel RunMat session:** D5, D10 and D26–D29 already report removable. The run gets past `changeCbMapOutput`, then stops on a new error that isn't in the register: "dynamic output count is not supported for expanded builtin calls", reported at the wrong place. That session's exploration folder is tracking it.

**Not done yet:** T013–T025 were not approved for this slice. They cover the `testAll` switch, restoring the banner link, the correction to the previous report, and the full MATLAB comparison after the change. The full MATLAB `testAll` was therefore not rerun after the change.

## Diff summary

| Commit | Tasks | Change |
|---|---|---|
| be511edec | T002–T006 | register, reproducers D5 D6 D10 D24 D26–D29 with MATLAB `expected.txt`, `recheckRunMat.sh`, analyzer baseline |
| ffa5f523d | T007 | `git mv` `testInitCobraToolboxAgentMode.m` → `testInitCobraToolbox.m` |
| 9b9cd72a4 | T008–T011 | `'runmat'` mode in `initCobraToolbox.m` (markers D6, D24, D10), `cell(0, 0)` and `isfolder` rewrites, tests, register rows |
| 39e80441d | T001, T012 | MATLAB baseline (`baseline/testAll-before*.{csv,md}`), RunMat measurement `reports/runmat-init.txt`, summary-line mode name (in 9b9cd72a4) |

Source files: `initCobraToolbox.m` (+44/−16), `test/verifiedTests/base/testInstall/testInitCobraToolbox.m` (renamed,
+80 lines of tests), and `test/runtimeCompatibility/RunMat/**` (new). Nothing under `external/`, `deprecated/` or a
submodule changed. The uncommitted `findSExRxnInd.m` and `findStoichConsistentSubset.m` changes from another
session were not touched or committed.

## Tests

- `testInitCobraToolbox` in the MCP MATLAB session (R2026a), from its folder after `clear functions; rehash`:
  - before T009–T011: Test 4 failed (`Error message should list accepted values including 'runmat'`);
  - after: Tests 3, 4, 2, 5 and 1 all passed.
- `checkcode`: `initCobraToolbox.m` has 52 messages before and 51 after, with no new identifier. The test file
  has 2 messages (GVMIS, NUSED on its `global` line).
- `recheckRunMat.sh`:
  - v0.6.2: all 8 still needed; markers 3 = rows 3; exit 0;
  - newer build: D6 and D24 still needed, the rest removable; markers 3 = rows 3; exit 0.
- RunMat driver `initCobraToolbox(false, 'runmat')` in a `runmat_testall.sh` tree built from a full clone at
  `9b9cd72a4`: v0.6.2 stops at `changeCbMapOutput` (`RunMat:FunctionCompileError`, D27/D28). See
  `reports/runmat-init.txt`.
- MATLAB `testAll` baseline (T001) at `afe0fac8f`: 538 tests, 495 passed, 7 failed, 36 skipped.

## Unresolved issues

- **Newer RunMat build:** the stop with "dynamic output count is not supported for expanded builtin calls" is not
  registered. It belongs to the RunMat exploration inbox `specs/20261104-134231-runmat-init-exploration/`, or to
  a later slice.
- **D10 reproducer:** it covers `prefdir` only. The `testAll` `exit` workaround (T017) needs its own check.
- **Deferred:** T013–T025. The full MATLAB `testAll` after the change (T022) has not been run.

## Other information

Deviations:
- The re-check and measurement also used a newer RunMat build. It is a copy of the parallel RunMat session's
  release binary, taken when `../runmat` was at `6e0a7df1a`, and kept in this session's scratch. It is reported
  for information; v0.6.2 stays the SC-001 reference.
- `expected.txt` files print through `fprintf` with fixed formats, because MATLAB and RunMat pad `disp` output of
  numbers differently.
- The summary line now prints the mode name. Agent mode's text is unchanged; it reads `runmat mode` only in the
  new mode.
- VII-F: no new MATLAB skill was loaded. `checkcode` (the core of `matlab-review-code`) was applied to both
  changed files.
