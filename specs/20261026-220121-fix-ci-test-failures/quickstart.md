# Quickstart: validating the CI fixes

Prerequisites: MATLAB with COBRA Toolbox initialised; Linux; `binary` submodule at
`10697a987` (`git -C binary rev-parse --short HEAD`). Because this drive can serve stale
copies of edited files, start every run with `clear functions; rehash`.

## 1. lrs (US1)

```matlab
clear functions; rehash
cd test/verifiedTests/analysis/testTopology
testLrsInterface      % includes the stand-in lrs (exit 127) and shell-script checks
testExtremePathways
testExtremePools
```

Expected: all three complete; the stand-in check reports `lrsRun:commandFailed` naming
exit status 127.

## 2. Console-capture filter (US2) — must use matlab -batch (research R0)

```bash
matlab -batch "cd('<repo>/test/verifiedTests/analysis/testTopology'); testGenerateFullRowRankFR"
```

Expected: completes without "printed output at printLevel 0".

## 2b. getRankLUSOL (US4) — testRank under matlab -batch

```bash
matlab -batch "cd('<repo>/test/verifiedTests/analysis/testRank'); testRank"
matlab -batch "cd('<repo>/specs/20261026-220121-fix-ci-test-failures'); getRankLUSOLBaseline('compare')"   # SC-005
```

Expected: testRank checks that with a stand-in failing `lusol_obj` the first call warns once
(`getRankLUSOL:lusolFallback`), a second call is silent at printLevel 0, and the ranks
equal `rank(full(A))`.

## 3. testReconMap (US3) — matlab -batch

```bash
matlab -batch "cd('<repo>/test/verifiedTests/visualization/testReconMap'); try, testReconMap, catch ME, disp(ME.identifier), disp(ME.message), end"
```

Expected while the service refuses the account: identifier `COBRA:RequirementsNotMet`,
message quoting `Access denied`, current folder restored.

## 4. Binary-bump regression set (FR-012)

Run testSolveCobraLP, testSolveCobraQP, testQuadLP, testDuals, testMapSolverStatus at
`binary` `43f41b0b7` and at `10697a987`; report any change in outcome.
