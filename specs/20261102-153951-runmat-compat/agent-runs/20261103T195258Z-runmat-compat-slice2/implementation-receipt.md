# Implementation receipt: runmat-compat, slice 2

## Prompt

`/speckit-implement T017, T018, T020 and T031–T033 as necessary`. The same session had just been asked:
"commit /home/rfleming/drive/sbgCloud/code/fork-cobratoolbox-runmat then merge that with
/home/rfleming/drive/sbgCloud/code/fork-cobratoolbox".

## Final response

See the Completion Report given in the session. In short:
- T017, T018, T020 and T031–T033 are done.
- The source change is commit `25c3d1fd6` on `089-large-model-solver-speed`.
- The report is `reports/runmat-compat-report.md`.
- SC-004 is not met: `testAll` under RunMat now stops at RunMat defect D5, and after that at D6.

## Diff summary

| Commit | Tasks | Change |
|---|---|---|
| 6a22237af | (before this run) | committed the uncommitted `initCobraToolbox.m` change found in the worktree: the desktop hyperlink around the doc link removed |
| 6a391cab3 | (before this run) | feature branch merged into `089-large-model-solver-speed` |
| 25c3d1fd6 | T017, T018 | `test/testAll.m`: `PERFORMANCE_REPORT` read only inside an `exist` guard; `initCobraToolbox()`, `exit()`. `initCobraToolbox.m`: `prefdir()`, `ispc()` ×4 |
| (this commit) | T020, T031–T033 | report, reproducers `reports/repro/`, `reports/analyzer-after.json`, `reports/runmat-testAll-after-us2.txt`, quickstart, tasks, human-loop, this receipt |

## Tests

- **T017.** The old expression and the new statements give the same logical value in 7 cases: `COBRA_PERF` `1`,
  empty or `0`, combined with the variable absent, empty, false or true.
- **T018/T017 analyzer.** `checkcode` gives the same message set before and after: `testAll.m` 19 messages,
  `initCobraToolbox.m` 52.
- **T018 RunMat.** The undefined names were found by rerunning RunMat discovery until none was left:
  `initCobraToolbox`, `prefdir`, `ispc`, `exit`. After the change, `initCobraToolbox.m` passes discovery, and
  `testAll.m` fails only with D5.
- **T031.** None of the 975 changed in-scope files gains an analyzer identifier compared with
  `baseline/analyzer-before.json`.
- **T032.** `git diff --name-only develop HEAD` lists nothing under `external/`, `deprecated/` or a submodule
  path. The only file outside `src/`, `test/`, `specs/` and `initCobraToolbox.m` is the Spec Kit pointer
  `.specify/feature.json`.
- **T020 reproducers.** D1–D11 and D13–D22 were run under RunMat v0.6.2, and also in MATLAB R2026a for the
  expected result. D12 was not re-run.
- **Not run:** the full MATLAB `testAll` after `25c3d1fd6` (or after the slice-1 fix `3c2bbad64`), and
  `initCobraToolbox` in MATLAB after `25c3d1fd6`.

## Unresolved issues

- **SC-004 not met.** `testAll.m:285` hits D5, which RunMat raises even for a read inside an `exist(...,'var')`
  guard. FR-005's guard satisfies MATLAB but not RunMat. Getting past it inside COBRA would need `eval`, which
  FR-008 forbids, or removing the workspace-variable switch `PERFORMANCE_REPORT` (a user-visible behaviour
  change). That is a human decision.
- **Next blockers after D5:** D6 (`which`) at `testAll.m:55`, then D10 (`prefdir`, `ispc`).
- **Unspecified commit.** `6a22237af`, which removes the `usejava('desktop')` hyperlink, is not in `tasks.md` and
  changes the MATLAB desktop banner. Keep it or revert it.

## Other information

Deviations:
- The worktree `../fork-cobratoolbox-runmat` was removed after the merge (its folder was gone, and git lists it
  as prunable). The work was therefore done in the main checkout, on `089-large-model-solver-speed`, not on the
  feature branch. The feature branch `20261102-153951-runmat-compat` stops at `6a22237af`.
- T019 was not re-run with `runmat_testall.sh`, because that needs a full clone. The run after US2 reused the
  T019 work tree with the two entry points replaced (`reports/runmat-testAll-after-us2.txt`).
- `explicit_calls.py` skips `initCobraToolbox.m` because it calls `evalc`. That `evalc` runs a fixed
  `system(...)` string and creates no variable, so it was hidden from the tool's check only while the tool ran.
  The rewritten lines are listed in the diff summary.
