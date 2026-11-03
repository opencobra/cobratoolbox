# Implementation Receipt — 20261026-220121-fix-ci-test-failures

## Prompt

`/speckit-implement` (no arguments), after Gate 2 approval of T001–T022 (human-loop.md,
2026-10-26). The checklists were complete (45/45), so the run continued without a prompt.

## Final response

All five tests now behave correctly locally: four pass and `testReconMap` is reported as skipped. All 22 tasks are done and committed on `20261026-220121-fix-ci-test-failures` (`36d2a0e3b`…`699990873`, plus the receipt); nothing is pushed.

**What changed**
- **lrs tests** (`testExtremePathways`, `testExtremePools`, `testLrsInterface`):
  - The `binary` submodule is pinned at `10697a987`. With the old pointer the three tests fail exactly as on CI; with the new one they pass.
  - `lrsRun` now stops with `lrsRun:commandFailed`, naming the command and exit status, when lrs, redund or the shell script fails. Before, it went on and read an empty output file.
  - Shell-script mode no longer errors on success, and it now returns the output file name.
  - New checks in `testLrsInterface` use a stand-in lrs that exits with 127.
- **`testGenerateFullRowRankFR`**: its console filter now removes each expected warning completely, in the form `matlab -batch` writes it (brackets with backspace characters, wrapped text, then a backtrace). This was the real CI cause. Under `-batch` the test failed before the change and passes after.
- **`testReconMap`**: when MINERVA refuses the test account, the test skips (`COBRA:RequirementsNotMet`) and quotes the server's reply; the harness counts it as skipped. The unreachable branch with your personal MINERVA login is deleted.
- **`getRankLUSOL`**: at printLevel 0 it prints nothing, apart from one `getRankLUSOL:lusolFallback` warning per MATLAB session when it falls back from LUSOL. The warning gives the cause and where it was raised. Rank and permutations are identical on all 10 baseline runs.

**Verification**
- Tests that capture the console were run with `matlab -batch`, as CI does. The MATLAB session I was driving records nothing in `diary`, so an earlier "pass" there meant nothing.
- Each new check failed against the old code and passes against the new.
- All 14 tests in the topology and rank folders: 13 pass, and `testMoieties` is skipped (no Statistics Toolbox licence here).
- Binary regression set, old pointer vs new: same outcome except the three lrs tests, which go from failing to passing.

**Not verified**
- **CI itself**: CI runs on this fork are skipped.
- **The new quad-precision MINOS and DQQ binaries**: `testQuadLP` is skipped here at both pointers, so they first run on CI.
- **`param.redund = 0`**: the new binary has no separate `redund` executable, so this option now stops with the new error instead of silently reading an empty file. No test or caller uses it.

**For you**: change the MINERVA password. Deleting the branch doesn't remove it from git history.

## Diff summary

`git diff --stat develop...` excluding the feature directory:

| File | Change |
|---|---|
| `binary` | submodule pointer `43f41b0b7` → `10697a987` |
| `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsRun.m` | `checkCommandStatus` local function: any non-zero status → `lrsRun:commandFailed`; shell-script status check fixed and `fileNameOut` assigned; header NOTE |
| `src/analysis/subspaces/rank/getRankLUSOL.m` | LUSOL inform-code text, `Check norm` line and fallback messages gated on `printLevel > 0`; `warnLusolFallback` local function (once-per-session warning with cause and location, "(no stack)" guard); header OPTIONAL INPUT and NOTE |
| `test/verifiedTests/analysis/testTopology/testLrsInterface.m` | stand-in lrs (exit 127) checks for vertex and facet enumeration; shell-script exit 0 / exit 3 checks |
| `test/verifiedTests/analysis/testTopology/testGenerateFullRowRankFR.m` | `removeExpectedWarnings` replaces the single-line filter |
| `test/verifiedTests/analysis/testRank/testRank.m` | fallback checks with a stand-in `lusol_obj` class and with LUSOL off the path |
| `test/verifiedTests/visualization/testReconMap/testReconMap.m` | diary capture of the first upload; skip on Access denied; dead credential branch deleted; header |
| `CLAUDE.md`, `.specify/feature.json` | Spec Kit plan pointer / active feature |

Feature directory: Spec Kit artifacts, `getRankLUSOLBaseline.m` (+ ignored
`baseline/*.mat`), `binary-bump-regression.md`, this receipt. Unchanged (verified with
`git diff --quiet develop...`): `generateFullRowRankFR.m`, `src/visualization/maps/ReconMap/`,
`lrsWriteHalfspace.m`, `external/`, testExtremePathways.m, testExtremePools.m.

## Tests

MATLAB R2026a Update 3, gurobi; `binary` at `10697a987` unless stated.

| Check | How | Result |
|---|---|---|
| testLrsInterface | MCP session | PASS; with old `lrsRun` shadowed: FAIL "lrsRun did not raise an error." |
| testExtremePathways, testExtremePools | MCP session and `-batch` | PASS |
| testGenerateFullRowRankFR | `-batch` | PASS; before the change: FAIL "printed output at printLevel 0" |
| filter sensitivity (scratch, real `-batch` log text) | MCP session | 8/8 cases as expected (stray text kept, other warnings kept) |
| testReconMap | `-batch`, direct and via `runScriptFile` | `COBRA:RequirementsNotMet`, reply quoted, `pwd` unchanged; harness status `skipped` |
| testRank | `-batch` | PASS; with old `getRankLUSOL` shadowed: FAIL "last warning was " |
| `getRankLUSOLBaseline('compare')` | `-batch` | all 10 runs identical |
| regression set at `43f41b0b7` vs `10697a987` | `-batch` via `runScriptFile` | see `binary-bump-regression.md`: only lrs tests change (fail → pass) |
| all tests in testTopology/ and testRank/ (14) | `-batch` via `runScriptFile` | 13 passed, testMoieties skipped (no Statistics Toolbox licence) |
| Code Analyzer, 6 files | `check_matlab_code` | no new issues; the new `global CBT_MISSING_REQUIREMENTS_ERROR_ID` follows the toolbox skip convention |

## Unresolved issues

- The CI outcome (SC-001's CI half) is not verified: this fork's CI jobs are skipped.
- The quadPrecision/minos/DQQ binaries changed by the bump are not exercised locally
  (testQuadLP skipped at both pointers).
- `param.redund = 0` now errors (no `redund` in the new binary); unused by tests or
  callers. Follow-up if needed.
- Follow-ups recorded, out of scope:
  - rename `testRank.m` to `testGetRankLUSOL.m` (III-Naming);
  - `lrsWriteHalfspace` writes shell scripts that redirect to a hard-coded `/nas/rfleming/` path;
  - `postMINERVArequest` returns a generic text instead of the server's reply;
  - testReconMap remains a network test (III).
- The exposed MINERVA password must be rotated by the user.

## Other information

Mid-run deviations (both within the approved files):
- the T004 stand-in check was moved into a local function so `onCleanup` restores `PATH`
  after a failure, and each enumeration case reads its own copy of the input file;
- the T014 stand-in `lusol_obj` became a class (a plain function cannot serve
  `lusol_obj.luset()`).
