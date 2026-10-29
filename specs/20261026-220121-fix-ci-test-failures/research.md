# Research: Fix four CI test failures

All findings are from the repository at `develop` (`5e8170e12`, the branch base) and a
local MATLAB R2026a session on 2026-10-26.

## R0 - Verification environment (added after analyze)

- **Finding**: in the MCP MATLAB session (Live Editor evaluation), `diary` records
  nothing: a warning and an `fprintf` inside a diary block left the diary file empty.
  Under `matlab -batch` (as CI runs), the diary records everything; a warning raised in
  a function appears as

  ```text
  [Warning: <message, wrapped at ~80 columns>] 
  [> In <fn> (line N)
  In <caller> (line M)] 
  ```

- **Consequence**: the earlier local "PASS" of testGenerateFullRowRankFR was vacuous.
  Every console-capture check in this feature (testGenerateFullRowRankFR, testRank,
  testReconMap) is verified with `matlab -batch` from the shell (clarification Q4).
  `initCobraToolbox` changes the folder at startup, so each run starts with
  `cd('<test folder>')`.

## R8 - Confirmed cause of the testGenerateFullRowRankFR CI failure

- **Finding**: `matlab -batch` run of the unchanged test on 2026-10-26 ends with
  "RESULT FAIL: generateFullRowRankFR printed output at printLevel 0". The captured text
  is the expected addReaction warning in -batch form (brackets, the message wrapped as
  `... updating the` / `reaction]`, then a `[> In addReaction (line 156) ... ]`
  backtrace block). `captureConsoleText` removes only
  `'Warning: Reaction with the same name already exists in the model, updating the reaction\s*'`,
  which matches neither the wrapped text nor the brackets nor the backtrace. No LUSOL
  fallback text appears anywhere in the log.
- **Decision**: rewrite the filter in `captureConsoleText` (test-only) as a small local
  function that, for each named warning message:
  1. collapses all whitespace runs in the captured text to one space;
  2. removes `\[?Warning: <escaped message>\]?` followed by an optional backtrace block,
     `\s*\[?> In .*?\]` in -batch form (the block contains no `]` before its end) or a
     run of `> In …`/`In …` lines in desktop form;
  3. trims the result.
  Named messages: the addReaction message, and the getRankLUSOL fallback prefix
  `getRankLUSOL: LUSOL unavailable` up to the end of that warning.
- **Alternatives considered**:
  - `warning('off','backtrace')` during the capture removes the backtrace but not the
    brackets or the wrap, and changes global state.
  - Using `lastwarn`, or a warning listener, to drop known warnings is not possible:
    MATLAB has no supported warning listener.
  - Turning the addReaction warning off would suppress a warning (VII-B, rejected).

## R1 - Where the getRankLUSOL test lives

- **Decision**: add the print-level/fallback assertions to the existing
  `test/verifiedTests/analysis/testRank/testRank.m`.
- **Rationale**: `testRank.m` is the existing test of `getRankLUSOL` (it calls only
  `getRankLUSOL`, at print levels 0 and 1, on iAF1260). Principle III-Naming says exactly
  one test file per function and that new assertions go into the function's existing test
  file; creating `testGetRankLUSOL.m` would make a second file for the same function.
- **Alternatives considered**: a new `testGetRankLUSOL.m` (rejected: two files for one
  function); renaming `testRank.m` to `testGetRankLUSOL.m` (correct per III-Naming, but a
  rename touches CI/test lists and is out of scope; recorded as a follow-up).

## R2 - Forcing a LUSOL failure without editing shipped files

- **Decision**: in `testRank.m`, create a temporary folder (`tempname`) holding a stand-in
  `lusol_obj.m` whose constructor raises an error with a known identifier; `addpath` it at
  the front, `rehash`, call `getRankLUSOL`, and remove it with an `onCleanup` that also
  runs `rmpath` and `rehash`. The "interface not on the path" branch is exercised by
  temporarily `rmpath`-ing the real folder that holds `lusol_obj.m` (found with `which`)
  and restoring it in the same `onCleanup`.
- **Rationale**: `getRankLUSOL` checks `which('lusol_obj')` and then constructs
  `lusol_obj(A)` inside `try`, so a shadowing stand-in drives exactly the catch branch.
  Nothing shipped is modified, and the path is restored even if an assertion fails.
- **Alternatives considered**: unloading `libclusol` (does not error deterministically);
  editing `lusol_obj.m` (forbidden: shipped file).
- **Session state**: the once-per-session flag is a `persistent` variable in
  `getRankLUSOL`; the test runs `clear getRankLUSOL` before each scenario so results do not
  depend on test order.

## R3 - Simulating an unrunnable lrs, and the shell-script branch

- **Decision (FR-002)**: Unix only. Write a stand-in executable named `lrs` (a two-line
  `sh` script that prints a message and `exit 127`) in a `tempname` folder; prepend that
  folder to `PATH` with `setenv`, call `lrsRun` on the test's `.ine` file, assert the
  error identifier and that the message names the command and status; restore `PATH` with
  `onCleanup`.
- **Decision (FR-003)**: write a `<model>.sh` file in the test folder containing
  `exit 0` (success) and, in a second check, `exit 3` (failure), call `lrsRun` with
  `param.shellScript = 1`, and assert that success returns the output name and failure
  raises the error.
- **Findings**:
  - `lrsRun` (lines 86-140) tests only `status == 1` after lrs and redund, so 127
    ("cannot execute") passes silently; the shell branch tests `status == 0` (inverted)
    and never assigns `fileNameOut`, so shell-script mode can never return (spec FR-003
    amended).
  - The shell script written by `lrsWriteHalfspace` (`param.sh == 1`) redirects to a
    hard-coded `/nas/rfleming/...` path, so it cannot be used in a test; a hand-written
    `.sh` is the only portable way to test the branch. The hard-coded path is out of scope
    (recorded as a follow-up).
  - The updated binary drops the separate `redund` executable (lrslib 7 folds it into
    `lrs`). `param.redund = 0` is used by no test or caller in `src/` other than the lrs
    interface itself; with FR-002 it now fails with a clear error instead of reading an
    empty file. Out of scope to re-implement; recorded.
- **Alternatives considered**: renaming the shipped binary during the test (modifies a
  shipped file; rejected).

## R4 - How the harness recognises a skip; how testReconMap detects the refusal

- **Finding (skip)**: `initCobraToolbox.m:93` sets the global
  `CBT_MISSING_REQUIREMENTS_ERROR_ID = 'COBRA:RequirementsNotMet'`;
  `test/runScriptFile.m:37` treats an error with that identifier as "skipped", and
  `testAll.m` counts and reports it as such (JUnit `<skipped/>`). Tests raise it with
  `global CBT_MISSING_REQUIREMENTS_ERROR_ID; error(CBT_MISSING_REQUIREMENTS_ERROR_ID, msg)`
  (e.g. `testExtremePools.m:17-21`, `testLoadBiGGModel.m:112`).
- **Finding (refusal)**: `buildFluxDistLayout` returns what `postMINERVArequest` returns.
  On a refused upload, `postMINERVArequest` (lines 40-48) prints the raw server reply with
  `disp` and returns the generic text "Overlay NOT generated successfully. curl post size
  in MB:…". The refusal text is therefore visible only on the console.
- **Decision**: testReconMap captures the console around the first upload with `diary` to
  a temporary file (verified under `matlab -batch`; R0) (not `evalc`; the text still reaches the console, VII-A/B), and, if the
  returned response is not the success text **and** the captured text contains
  `Access denied` or `Access is denied`, restores the working directory and raises the
  skip error with a message that quotes the reply. Any other unsuccessful reply still
  fails the existing assertion.
- **Alternatives considered**: changing `postMINERVArequest` to return the raw reply
  (changes a public return value, Principle II; rejected); a separate login probe (the
  login itself succeeds; the refusal comes on the upload, so a probe would have to upload).

## R5 - Binary submodule bump: what changes

- `git diff --stat 43f41b0b7 10697a987` in `binary/`: 42 files, all under
  `glnxa64/bin/`: `lrs` (18), `quadPrecision` (17), `minos` (4), `DQQ` (3). No change to
  `glnxa64/lib/libclusol.so` (LUSOL) or any non-Linux folder.
- Users of the changed folders: `solveCobraLP.m:375` and `solveCobraQP.m:854`
  (`quadPrecision/doubleQuadQuadFBA`), `changeCobraSolver.m:294` (`MINOS_PATH`). Tests
  that name `dqqMinos`/`quadMinos` include testSolveCobraLP, testSolveCobraQP,
  testQuadLP, testDuals, testMapSolverStatus, runLPvariousSolvers.
- **Decision**: bump to `10697a987`; run those tests at both pointers locally and report
  any outcome change (FR-010). The local checkout already runs at `10697a987`, so it is
  the configuration the user has been using.

## R6 - Gating the prints in getRankLUSOL

- Unconditional prints today: inform codes 3, 4, 7, 8, 9 (lines 128-139); the
  `Check norm(b-b2)` line for inform ∉ {0, 1} (line 149); the catch fallback (lines
  154-156: `warning(ME.message)` then `fprintf`); the "Cannot find lusol_obj.m" branch
  (line 162).
- **Decision**: wrap each `fprintf` in `if printLevel > 0`. Replace `warning(ME.message)`
  with a once-per-session `warning('getRankLUSOL:lusolFallback', …)` whose text holds
  `ME.message`, `ME.stack(1).file` and `ME.stack(1).line` (VII-C), or "(no stack)" when
  `ME.stack` is empty (analyze U1). Use the same identifier, once per session, for the
  "not on path" branch. Numerical statements are not touched,
  so outputs are unchanged (FR-006).
- **Check**: `getRankLUSOL` has 11 callers in `src/`; none parses its console text
  (grep for `getRankLUSOL:` in `src/` and `test/` finds only the function itself).

## R7 - External-solver configuration audit

- lrs (vertex/facet enumeration) and LUSOL are the external programs touched. No option
  or parameter of either changes; only exit-status handling and console text. N/A beyond
  this note.
