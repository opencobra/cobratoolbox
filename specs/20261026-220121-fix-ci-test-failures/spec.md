# Feature Specification: Fix four CI test failures (lrs, LUSOL printLevel, ReconMap)

**Feature Branch**: `20261026-220121-fix-ci-test-failures`

**Created**: 2026-10-26

**Status**: Draft

**Input**: User description: "Fix four CI test failures. (1) testExtremePathways,
testExtremePools, testLrsInterface fail on CI with 'Could not read lrs output file.' ...
(2) testGenerateFullRowRankFR fails on CI with 'generateFullRowRankFR printed output at
printLevel 0' ... (3) testReconMap fails on CI and locally because the external MINERVA
server returns Access denied ... Narrowest tests: the five named test files." (full text
in the conversation record; evidence summarised under Background.)

## Clarifications

### Session 2026-10-26

- Q: If LUSOL fails on CI, how should the visible fallback warning interact with
  testGenerateFullRowRankFR's printLevel-0 console capture? → A: The rank routine raises
  the fallback warning once per MATLAB session (with message and stack), and the test's
  capture also discards that one named warning, as it already discards the addReaction
  warning.
- Q: Should the unreachable else-branch of testReconMap.m, which hard-codes a personal
  MINERVA login and password, be handled here? → A: Yes: delete the unreachable branch.
  The password remains in git history, so the user should rotate it on the service.

## Background (evidence, 2026-10-26, MATLAB R2026a, gurobi, local)

| Test | Local | CI | Established cause |
|---|---|---|---|
| testExtremePathways | PASS | FAIL "Could not read lrs output file." | CONFIRMED: CI checks out the committed `binary` submodule pointer `43f41b0b7`, whose `glnxa64/bin/lrs/lrs` needs `libgmp.so.3` and cannot start (shell exit 127). The local checkout has `binary` at `10697a987` (on the binary repository's `master`), whose `lrs` needs only `libgomp`/`libc`. The lrs driver treats only exit status 1 as failure, so it reads an empty output file. |
| testExtremePools | PASS | FAIL (same) | same |
| testLrsInterface | PASS | FAIL (same) | same |
| testGenerateFullRowRankFR | PASS | FAIL "printed output at printLevel 0" | HYPOTHESIS, not confirmed (no CI log available): the rank routine prints unconditionally when its LUSOL library call fails (fallback message) and for LUSOL error codes 3-9, whatever the print level. |
| testReconMap | FAIL | FAIL "Assertion failed." | CONFIRMED: the MINERVA server answers `{"reason":"Access is denied","error":"Access denied."}` for the test account; the test asserts success. |

## User Scenarios & Testing *(mandatory)*

### User Story 1 - lrs-based tests run on CI (Priority: P1)

A maintainer pushes to a branch; CI runs the three lrs-based topology tests and they pass,
because the shipped lrs executable can start on the CI image. When lrs (or redund) cannot
run for any reason, the user sees an error that names the failed command and its exit
status, instead of a misleading "Could not read lrs output file."

**Why this priority**: three of the five failures; the root cause is confirmed and the
silent-failure path can mislead any user of the extreme-ray tools, not only CI.

**Independent Test**: run the three lrs tests against the updated `binary` checkout; then
make lrs unavailable/unrunnable and check that the driver reports the command and status.

**Acceptance Scenarios**:

1. **Given** the `binary` submodule at the updated pointer on a modern Linux image,
   **When** testExtremePathways, testExtremePools and testLrsInterface run, **Then** all
   three pass.
2. **Given** an lrs or redund executable that exits with any non-zero status, **When** the
   lrs driver runs it, **Then** it stops with an error naming the command and the exit
   status, and does not go on to read the output file.
3. **Given** the driver's shell-script mode, **When** the script succeeds (status 0),
   **Then** the driver continues; **When** it fails (non-zero), **Then** it stops with an
   error. (Today the test is inverted: it errors on success.)

---

### User Story 2 - rank routine silent at printLevel 0 (Priority: P2)

A user calls a function at print level 0 and gets no console text from the rank routine
it uses, even when the routine falls back from LUSOL to MATLAB's LU. The fallback is still
reported as a visible MATLAB warning that carries the original error's message and where
it was raised, and the rank returned is unchanged.

**Why this priority**: one failing test; the cause is a hypothesis until a CI log or a
local reproduction confirms it.

**Independent Test**: force the LUSOL path to fail locally, call the rank routine at print
level 0, capture the console, and compare with print level 1.

**Acceptance Scenarios**:

1. **Given** the LUSOL call fails, **When** the rank routine runs at print level 0,
   **Then** the only console output is one MATLAB warning (message plus file and line of
   the original error), and the returned rank equals MATLAB's rank of the input.
2. **Given** the same failure at print level ≥ 1, **Then** the explanatory fallback
   message is also printed.
3. **Given** LUSOL returns error codes 3-9, **When** the routine runs at print level 0,
   **Then** no explanatory text is printed; at print level ≥ 1 the same text as today is
   printed.
4. **Given** LUSOL works (codes 0/1), **Then** rank, row and column permutations are
   identical to today's for any print level.
5. **Given** the LUSOL interface file is not on the path, **When** the routine runs at
   print level 0, **Then** nothing is printed [handled the same way as the fallback].
6. **Given** the fallback occurs, **When** testGenerateFullRowRankFR runs, **Then** it
   passes: its console capture discards the one named fallback warning (as it already
   discards the expected addReaction warning), and any other printed text still fails it.
7. **Given** repeated fallbacks in one MATLAB session, **Then** the warning appears on the
   first fallback only; later fallbacks are silent at print level 0.

---

### User Story 3 - ReconMap test skips when the service refuses the login (Priority: P3)

When the external MINERVA service refuses the shared test account, testReconMap is
reported as skipped (missing requirement) by the test harness, not as failed. When the
service accepts the login, the test asserts what it asserts today.

**Why this priority**: the failure is caused by an external service, not by code; it
should not mask real failures in the suite.

**Independent Test**: run testReconMap now (service refuses the login) and check it ends
with the harness's missing-requirement skip, and that the skip message quotes the
service's reply.

**Acceptance Scenarios**:

1. **Given** the service's reply to the first upload contains `Access denied` or
   `Access is denied` (the observed refusal), **When** testReconMap runs, **Then** it ends with the toolbox's standard
   missing-requirement skip and a message naming the service and its reply.
2. **Given** the service is unreachable, **Then** the existing reachability requirement
   check skips the test, as today.
3. **Given** the service accepts the login, **Then** both upload assertions run as today.
4. **Given** any other unexpected reply, **Then** the test fails as today.

### Edge Cases

- lrs exits 0 but writes an empty or truncated file: the existing read error stays (out of
  scope to change).
- lrs is absent from the path (`which lrs` empty): behaviour unchanged by this feature.
- The updated `binary` pointer changes other shipped executables (quad MINOS, DQQ,
  libgfortran.so.6 rebuilds); tests that use them may change outcome on CI.
- The rank routine's fallback runs once per call; a model-building loop would otherwise
  emit many identical warnings, hence once per session (Clarifications).
- The ReconMap test restores the caller's working directory and the shared credentials
  when it skips.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The repository MUST pin the `binary` submodule at `10697a987` (the binary
  repository's current `master`), whose Linux lrs starts on an image without
  `libgmp.so.3`.
- **FR-002**: The lrs driver MUST treat any non-zero exit status from lrs or redund as a
  failure and raise an error that names the command run and the exit status, and includes
  the command's output text when available, before any attempt to read the output file.
- **FR-003**: In the driver's shell-script mode, success MUST be exit status 0 and failure
  any non-zero status (correcting the inverted test).
- **FR-004**: The rank routine MUST print its explanatory fallback and LUSOL error-code
  messages only when print level ≥ 1; the messages' wording at print level ≥ 1 MUST stay as
  today.
- **FR-005**: When the LUSOL call fails, the rank routine MUST emit a visible MATLAB
  warning, with a stable identifier, that includes the original error's message and at
  least the file and line of its first stack frame (Principle VII-C), at every print
  level, on the first fallback of the MATLAB session; later fallbacks in the same
  session MUST NOT repeat it at print level 0. "Session" means until the rank routine's
  state is cleared (a new MATLAB process, `clear functions`, `clear all`, or `clear
  getRankLUSOL`). The warning identifier is `getRankLUSOL:lusolFallback`.
- **FR-005a**: testGenerateFullRowRankFR's console capture MUST discard only that one
  named fallback warning (matched by its fixed message prefix), in addition to the addReaction warning it already discards.
- **FR-006**: The rank routine's outputs (rank, row and column permutations) MUST be
  identical to today's for every input and print level.
- **FR-007**: testReconMap MUST end with the toolbox's standard missing-requirement skip
  when the service refuses the test account, and MUST otherwise keep today's assertions.
- **FR-007b**: When testReconMap skips, it MUST first restore the caller's working
  directory (the shared credentials are local to the test and need no restoring).
- **FR-007a**: testReconMap's unreachable branch, which holds hard-coded personal
  credentials, MUST be deleted.
- **FR-008**: Public interfaces MUST NOT change: no new required inputs, no changed outputs,
  no changed print-level default. Intentional diagnostic change (Principle II): at the
  default print level 0 the rank routine no longer prints its fallback and LUSOL
  error-code text; the information stays available as the warning (FR-005) and at print
  level ≥ 1. This MUST be recorded in the routine's help header NOTE.
- **FR-011**: The help headers of the rank routine and the lrs driver MUST be updated in
  the same change to describe the print-level and error behaviour (VII-E).
- **FR-009**: Each change MUST be covered by the narrowest test: the three lrs tests, plus
  automated checks in testLrsInterface for FR-002 (a stand-in lrs that exits non-zero,
  placed first on the PATH for the duration of the check, Unix only) and FR-003 (the
  shell-script branch, if the driver's shell-script mode can run without network or root;
  otherwise a documented reproducibility check per Principle III),
  testGenerateFullRowRankFR plus a test of the rank routine's print-level behaviour under a
  forced fallback, and testReconMap.
- **FR-010**: The full topology and rank test folders MUST pass locally after the change.
  The binary bump changes 42 files under `glnxa64/bin/` in four folders: `lrs` (18),
  `quadPrecision` (17), `minos` (4), `DQQ` (3). Solvers `dqqMinos`/`quadMinos` load from
  `quadPrecision`; the tests that use them (at least testSolveCobraLP, testSolveCobraQP,
  testQuadLP, testDuals, testMapSolverStatus, runLPvariousSolvers) MUST be run locally
  before and after the bump and any change in outcome reported. The local checkout
  already runs at `10697a987`, so "before" is a run with the old pointer checked out.

### Key Entities

- **binary submodule pointer**: the commit of the shipped executables repository that a
  checkout (and CI) uses.
- **lrs driver**: the toolbox function that writes lrs input, runs lrs/redund, and reads
  the output.
- **rank routine**: the toolbox function that returns the rank of a sparse matrix via LUSOL,
  falling back to MATLAB's LU.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The five named tests: four pass and testReconMap is reported as skipped
  (while the service refuses the account) — locally, and on CI once the branch runs there.
- **SC-002**: With lrs made unrunnable, 100% of driver calls stop with an error naming the
  command and exit status; 0 calls report "Could not read lrs output file."
- **SC-003**: With LUSOL forced to fail at print level 0, the first call in a session
  writes exactly one warning and no other console text, later calls write nothing;
  returned ranks equal MATLAB's rank in every call.
- **SC-004**: On fixtures where LUSOL works, rank and permutations are bit-for-bit
  identical before and after the change.
- **SC-005**: No previously passing test in the topology and rank test folders fails after
  the change (local run reported in the implementation receipt).

## Assumptions

- The CI image lacks `libgmp.so.3` (confirmed by the exit-127 reproduction with the old
  binary); it may also lack `libgfortran.so.5`, which the LUSOL library needs. The latter
  is unconfirmed without a CI log.
- The binary repository's `10697a987` is the intended current set of shipped executables;
  bumping to it is preferable to cherry-picking lrs alone (the binary repository has no
  lrs-only commit).
- Testing the "unrunnable lrs" path is done with a stand-in executable earlier on the path
  that exits non-zero, not by modifying the shipped binary.
- Constitution III's "avoid internet access" rule is not addressed here; testReconMap
  remains a network test.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1-1 / FR-001 | testExtremePathways, testExtremePools, testLrsInterface (test/verifiedTests/analysis/testTopology/) | — (binary submodule pointer) |
| US1-2 / FR-002 | testLrsInterface (added failure check) | src/analysis/topology/extremeRays/lrs/lrsInterface/lrsRun.m |
| US1-3 / FR-003 | testLrsInterface (added shell-script check, if practical) | src/analysis/topology/extremeRays/lrs/lrsInterface/lrsRun.m |
| US2-1..5 / FR-004..006 | rank routine print-level test (test/verifiedTests/analysis/testSubspaces/ or existing getRankLUSOL test) | src/analysis/subspaces/rank/getRankLUSOL.m |
| US2-6..7 / FR-005a | testGenerateFullRowRankFR | src/analysis/topology/.../generateFullRowRankFR.m (unchanged) |
| US3-1..4 / FR-007, FR-007a | testReconMap (test/verifiedTests/visualization/testReconMap/) | — (test-only change) |
