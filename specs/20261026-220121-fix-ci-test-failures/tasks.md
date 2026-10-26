# Tasks: Fix four CI test failures (lrs, console-capture filter, ReconMap) and quiet getRankLUSOL

**Input**: design documents in `specs/20261026-220121-fix-ci-test-failures/`
(spec.md, plan.md, research.md, data-model.md, contracts/, quickstart.md)

**Tests**: required (spec FR-011, constitution Principle III). In each story the test
tasks come before the source change, and each new check is first run against the
unchanged source to show that it fails.

**How to run** (research R0):
- **MCP session**: tests that don't capture the console (the lrs tests, the regression
  set). Start with `clear functions; rehash`.
- **`matlab -batch` from the shell**: testGenerateFullRowRankFR, testRank, testReconMap
  and the baseline script. Use
  `/home/rfleming/drive/sbgCloud/code/MATLAB/R2026a/bin/matlab -batch "cd('<folder>'); <cmd>"`,
  with logs written to the scratchpad.

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup

- [X] T001 Record the regression baseline at the OLD binary pointer.
  - Run `git -C binary checkout 43f41b0b7`.
  - Run testSolveCobraLP, testSolveCobraQP, testQuadLP, testDuals and
    testMapSolverStatus (research R5), and testExtremePathways, testExtremePools and
    testLrsInterface.
  - Record each test's pass/fail/skip and first error line in
    `specs/20261026-220121-fix-ci-test-failures/binary-bump-regression.md`.
  - Expect the three lrs tests to fail with "Could not read lrs output file.", which
    reproduces CI.
  - Then run `git -C binary checkout 10697a987`.
- [X] T002 Write `specs/20261026-220121-fix-ci-test-failures/getRankLUSOLBaseline.m`.
  - Modes `'record'` and `'compare'`.
  - Save or compare `[rankA, p, q] = getRankLUSOL(A, pl)` for pl = 0 and 1 on:
    iAF1260.S; ecoli_core S; that S with an all-zero column appended; a fixed-seed
    `sprand(200,300,0.02)` (rng 20261026); and `sparse(0,3)`.
  - Store results in `baseline/getRankLUSOL.mat`, and add `baseline/.gitignore`
    containing `*.mat`.
  - Run `'record'` under `-batch` on the unchanged source.

## Phase 2: Foundational

- [X] T003 Commit the `binary` pointer `10697a987` (already checked out locally) as its
  own commit on this branch (FR-001).

**Checkpoint**: baseline recorded; binary pinned.

## Phase 3: User Story 1 - lrs-based tests run on CI (P1) 🎯 MVP

**Goal**: the three lrs tests pass with the pinned binary, and an lrs failure names the
command and its status.
**Independent test**: quickstart §1.

- [X] T004 [US1] Add checks to
  `test/verifiedTests/analysis/testTopology/testLrsInterface.m`.
  - **FR-002**, run only `if isunix`:
    - Write a stand-in executable `lrs` (`#!/bin/sh`, `echo stand-in lrs failure`,
      `exit 127`) into a `tempname` folder and `chmod +x` it.
    - Prepend that folder to `PATH` with `setenv`, and restore `PATH` with `onCleanup`.
    - Call `lrsRun` once with `param.facetEnumeration = 0` (vertex) and once with `1`
      (facet; C1).
    - Each call must raise identifier `lrsRun:commandFailed`, with a message that
      contains `127`.
  - **FR-003**, in the test folder:
    - Write `test.sh` containing `exit 0`. With `param.shellScript = 1`, `lrsRun` must
      return `test.ext`.
    - Rewrite it to `exit 3`; `lrsRun` must raise `lrsRun:commandFailed`.
    - Delete `test.sh` with `onCleanup`.
  - Run the test against the unchanged `lrsRun` and record that the checks fail.
- [X] T005 [US1] Change `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsRun.m`.
  - Replace every `status == 1` check after a `system` call to lrs or redund with
    `status ~= 0`, raising `error('lrsRun:commandFailed', ...)`. The message names the
    command, the status and `result` (contracts/lrsRun.md).
  - In the shell-script branch, fix the inverted check (`status ~= 0` is failure).
  - In the shell-script branch, assign `fileNameOut`: `<model>.ine` when
    `param.facetEnumeration`, otherwise `<model>.ext`.
  - Change no other behaviour.
- [X] T006 [US1] Update the `lrsRun.m` help header (VII-E, FR-010).
  - Document the error identifier and what counts as success in shell-script mode.
  - Add a `NOTE:` naming this feature (October 2026).
- [X] T007 [US1] Run testLrsInterface, testExtremePathways and testExtremePools; all
  must pass (quickstart §1).

**Checkpoint**: US1 complete and independently verified.

## Phase 4: User Story 2 - silence check works under CI (P2)

**Goal**: testGenerateFullRowRankFR passes under `matlab -batch`, and still fails on
real stray output.
**Independent test**: quickstart §2.

- [ ] T008 [US2] Confirm the failure on the unchanged test. Run
  testGenerateFullRowRankFR under `-batch` (already seen on 2026-10-26: "RESULT FAIL …
  printed output at printLevel 0"). Keep the log.
- [ ] T009 [US2] In
  `test/verifiedTests/analysis/testTopology/testGenerateFullRowRankFR.m`, replace the
  `regexprep` filter in `captureConsoleText` with a local function
  `removeExpectedWarnings(text, messages)` (FR-004, research R8).
  - Collapse whitespace runs to one space.
  - For each message, remove `\[?Warning: <regexptranslate('escape', msg)>[^\]]*?\]?`
    followed by an optional backtrace: the `\s*\[?> In [^\]]*\]` form or the desktop
    `(\s*>? ?In [^\n]*\(line \d+\))+` form.
  - Trim the result.
  - Messages: `Reaction with the same name already exists in the model, updating the
    reaction` and `getRankLUSOL: LUSOL unavailable`.
  - Update the comment above the helper.
- [ ] T010 [US2] Run testGenerateFullRowRankFR under `-batch`; it must pass.
- [ ] T011 [US2] Sensitivity check (SC-003). In a scratch copy outside the repo, call
  `removeExpectedWarnings` on:
  - the T008 log text plus one extra line `stray` → returns `stray`;
  - the T008 log text alone → returns empty;
  - a desktop-form sample (no brackets, `> In` lines) → returns empty.

  Record the results for the receipt. Nothing from this check is committed.

**Checkpoint**: US2 complete.

## Phase 5: User Story 3 - ReconMap test skips on refused login (P3)

**Goal**: the harness reports testReconMap as skipped, not failed, while MINERVA refuses
the test account.
**Independent test**: quickstart §3.

- [ ] T012 [US3] Change `test/verifiedTests/visualization/testReconMap/testReconMap.m`.
  - Delete the `if 1 … else … end` wrapper and its unreachable `else` branch, which
    holds the personal credentials (FR-005a). Keep the `if 1` body.
  - Add `global CBT_MISSING_REQUIREMENTS_ERROR_ID`.
  - Wrap the first `buildFluxDistLayout` call in a diary capture to a `tempname` file
    (no `evalc`; research R4).
  - If `response` is not `'Overlay generated successfully.'` and the captured text
    contains `Access denied` or `Access is denied`:
    - restore `minerva.login` and `minerva.password`, then `cd(currentDir)` (FR-005b);
    - raise `error(CBT_MISSING_REQUIREMENTS_ERROR_ID, ...)` with a message naming
      vmh.life MINERVA and quoting the reply line (FR-005).
  - Otherwise keep all existing assertions.
  - Update the header: purpose and skip condition.
- [ ] T013 [US3] Run testReconMap under `-batch`.
  - It must end with `COBRA:RequirementsNotMet`, a message quoting the refusal, and
    `pwd` unchanged.
  - Then run it through `test/runScriptFile.m` (`-batch`) to show the harness classes it
    as skipped.

**Checkpoint**: US3 complete.

## Phase 6: User Story 4 - getRankLUSOL silent at printLevel 0 (P4)

**Goal**: at printLevel 0 the only output is one warning per session on fallback; the
outputs don't change.
**Independent test**: quickstart §2b.

- [ ] T014 [US4] Add checks to `test/verifiedTests/analysis/testRank/testRank.m`
  (research R1, R2).
  - **Setup**:
    - Write a stand-in `lusol_obj.m` into a `tempname` folder; it errors with identifier
      `testRank:standIn`.
    - `addpath` the folder at the front and `rehash`; undo both with `onCleanup`.
    - Run `clear getRankLUSOL`.
  - **Capture**: use a diary-based helper. Reuse the `removeExpectedWarnings` approach
    from T009 as a local function.
  - **Cases**:
    - (a) printLevel 0, first call: the capture contains a warning with prefix
      `getRankLUSOL: LUSOL unavailable` that mentions `standIn`, and nothing else once
      that warning is removed. `lastwarn` has id `getRankLUSOL:lusolFallback`.
    - (b) printLevel 0, second call: the capture is empty.
    - (c) printLevel 1: the capture contains `Caught error using lusol interface`.
    - (d) In every case `rankA == rank(full(A))`.
    - (e) Remove the stand-in. Temporarily `rmpath` the real `lusol_obj` folder (found
      with `fileparts(which('lusol_obj'))`, restored with `onCleanup`), then run
      `clear getRankLUSOL`. At printLevel 0 the first call gives one warning naming
      `lusol_obj.m not found`; a second call is silent.
  - Run the test under `-batch` against the unchanged source and record the failures.
- [ ] T015 [US4] Change `src/analysis/subspaces/rank/getRankLUSOL.m`
  (contracts/getRankLUSOL.md, research R6).
  - Wrap the inform 3/4/7/8/9 `fprintf` lines and the `Check norm(b-b2)` line in
    `if printLevel > 0`.
  - Add a `persistent` flag.
  - In the catch block:
    - while the flag is unset, raise `getRankLUSOL:lusolFallback` with the message plus
      `ME.stack(1).file` and `ME.stack(1).line`, or `(no stack)` (U1); then set the flag;
    - print the existing "Caught error…" line only when `printLevel > 0`.
  - Handle the not-on-path branch the same way: same warning id, with cause
    `lusol_obj.m not found on the MATLAB path`.
  - Leave every numerical statement unchanged.
- [ ] T016 [US4] Update the `getRankLUSOL.m` help header (VII-E, FR-009, FR-010).
  - Under `OPTIONAL INPUT`, describe what printLevel 0 and ≥ 1 print.
  - Add a `NOTE:` recording the October 2026 diagnostic change and the warning id.
- [ ] T017 [US4] Under `-batch`, run testRank (it must pass),
  `getRankLUSOLBaseline('compare')` (it must report identical results, SC-005), and
  testGenerateFullRowRankFR again.

**Checkpoint**: US4 complete.

## Phase 7: Polish & Cross-Cutting

- [ ] T018 [P] Run `mcp__matlab__check_matlab_code` on the two source files and the four
  edited test files. Fix new issues only; list the pre-existing ones.
- [ ] T019 Rerun the T001 regression set at `10697a987` and complete
  `binary-bump-regression.md` with a before/after table (FR-012).
- [ ] T020 Run every `test*.m` in `test/verifiedTests/analysis/testTopology/` and
  `testRank/`, using `-batch` for the capture-based ones. None may newly fail (SC-006).
- [ ] T021 Check the scope with `git diff --stat develop...`. Only the files in
  plan.md Project Structure, the feature directory and `CLAUDE.md` may have changed.
- [ ] T022 Write the implementation receipt at
  `specs/20261026-220121-fix-ci-test-failures/agent-runs/<UTC>-fix-ci-test-failures/implementation-receipt.md`
  (constitution ledger), and point `human-loop.md` at it.

## Dependencies & Execution Order

- Setup (T001, T002) → T003 → user stories.
- After T003 the four stories are independent of each other:
  - US1: T004 → T005 → T006 → T007.
  - US2: T008 → T009 → T010 → T011.
  - US3: T012 → T013.
  - US4: T014 → T015 → T016 → T017.
- US4's T014 reuses the US2 helper idea; a copy is kept local to testRank.
- T002 must be recorded before T015.
- Polish (T018–T022) comes after all stories.

## Parallel Opportunities

- T018 can run alongside T019/T020 (different files, read-only).
- The stories touch disjoint files. Run them in series anyway: there is one shared
  MATLAB session, and each `-batch` run takes about 10 s to start.

## Implementation Strategy

1. MVP = Phases 1–3 (US1), which clears three of the five CI failures.
2. US2 and US3 clear the other two.
3. US4 is hygiene.

Commit after each phase.
