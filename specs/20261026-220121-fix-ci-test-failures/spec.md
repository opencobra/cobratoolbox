# Feature Specification: Fix four CI test failures (lrs, console-capture filter, ReconMap) and quiet getRankLUSOL

**Feature Branch**: `20261026-220121-fix-ci-test-failures`

**Created**: 2026-10-26

**Status**: Draft (revised after analyze: US2 cause confirmed, LUSOL gating moved to US4)

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
- Q: (after analyze) The testGenerateFullRowRankFR failure is caused by the test's own
  console filter, not by getRankLUSOL. How should the scope change? → A: Fix the filter
  (US2) and keep the getRankLUSOL print-level gating and once-per-session warning as a
  separate, lower-priority story (US4).
- Q: The MCP MATLAB session records no diary output. How are tests verified? → A: Tests
  that capture the console (testGenerateFullRowRankFR, testRank, testReconMap) are
  verified with `matlab -batch`, as CI runs them; the others may run in the MCP session.

## Background (evidence, 2026-10-26, MATLAB R2026a, gurobi, local)

| Test | Local (MCP session) | Local (`matlab -batch`) | CI | Established cause |
|---|---|---|---|---|
| testExtremePathways | PASS | — | FAIL "Could not read lrs output file." | CONFIRMED: CI checks out the committed `binary` submodule pointer `43f41b0b7`. Its `glnxa64/bin/lrs/lrs` needs `libgmp.so.3` and cannot start (shell exit 127). The local checkout has `binary` at `10697a987`, on the binary repository's `master`, whose `lrs` needs only `libgomp`/`libc`. The lrs driver treats only exit status 1 as a failure, so it reads an empty output file. |
| testExtremePools | PASS | — | FAIL (same) | same |
| testLrsInterface | PASS | — | FAIL (same) | same |
| testGenerateFullRowRankFR | PASS (vacuous: diary records nothing in the MCP session) | FAIL "printed output at printLevel 0" | FAIL (same) | CONFIRMED: under `-batch`, each expected addReaction warning reaches the diary as `[Warning: Reaction with the same name already exists in the model, updating the` / `reaction] ` followed by a `[> In addReaction (line 156)` … `]` backtrace block. The test's filter matches only the unwrapped, unbracketed message text, so the brackets, the line break and the backtrace are left over and counted as output. LUSOL is not involved (no fallback text in the log). |
| testReconMap | FAIL | — | FAIL "Assertion failed." | CONFIRMED: the MINERVA server answers `{"reason":"Access is denied","error":"Access denied."}` for the test account; the test asserts success. |

## User Scenarios & Testing *(mandatory)*

### User Story 1 - lrs-based tests run on CI (Priority: P1)

A maintainer pushes to a branch, and CI runs the three lrs-based topology tests. They pass,
because the shipped lrs executable can start on the CI image. When lrs (or redund) cannot
run for any reason, the user sees an error that names the failed command and its exit
status, not a misleading "Could not read lrs output file."

**Why this priority**: it covers three of the five failures. The root cause is confirmed,
and the silent-failure path can mislead any user of the extreme-ray tools, not only CI.

**Independent Test**: run the three lrs tests against the updated `binary` checkout; then
make lrs unrunnable and check that the driver reports the command and status for both
vertex and facet enumeration.

**Acceptance Scenarios**:

1. **Given** the `binary` submodule at the updated pointer on a modern Linux image,
   **When** testExtremePathways, testExtremePools and testLrsInterface run, **Then** all
   three pass.
2. **Given** an lrs or redund executable that exits with any non-zero status, **When** the
   lrs driver runs it, for vertex or facet enumeration, **Then** it stops with an error
   naming the command and the exit status, and does not go on to read the output file.
3. **Given** the driver's shell-script mode, **When** the script succeeds (status 0),
   **Then** the driver returns the output file name. **When** the script fails (non-zero),
   **Then** it stops with an error. Today this test is inverted: it errors on success.

---

### User Story 2 - testGenerateFullRowRankFR's silence check works under CI (Priority: P2)

When CI runs testGenerateFullRowRankFR, its "silent at printLevel 0" check discards each
expected, named warning in full: the message, however MATLAB wraps or brackets it, and the
backtrace block that follows. Any other console text still fails the check.

**Why this priority**: one failing test, with its cause confirmed. The fix is test-only.

**Independent Test**: run testGenerateFullRowRankFR with `matlab -batch` and see it pass.
Then make generateFullRowRankFR print one extra line at printLevel 0 (a stand-in on the
path, in a scratch run) and see the check fail.

**Acceptance Scenarios**:

1. **Given** the expected addReaction warning fires during the printLevel-0 call, **When**
   the test runs under `matlab -batch`, **Then** the check passes.
2. **Given** the same under an interactive or MCP session (no brackets; backtrace lines
   start `> In` / `In`, or backtrace is off), **Then** the filter removes the warning in
   full as well.
3. **Given** any other text, including another warning, is printed at printLevel 0,
   **Then** the check fails.
4. **Given** the getRankLUSOL fallback warning (US4) fires during the call, **Then** it
   is discarded in the same way (clarification Q1).

---

### User Story 3 - ReconMap test skips when the service refuses the login (Priority: P3)

When the external MINERVA service refuses the shared test account, the test harness
reports testReconMap as skipped (missing requirement), not failed. When the service
accepts the login, the test asserts what it asserts today.

**Why this priority**: the failure comes from an external service, not from code, and it
should not hide real failures in the suite.

**Independent Test**: run testReconMap with `matlab -batch` while the service refuses the
login. It must end with the harness's missing-requirement skip, and the skip message must
quote the service's reply.

**Acceptance Scenarios**:

1. **Given** the service's reply to the first upload contains `Access denied` or
   `Access is denied` (the observed refusal), **When** testReconMap runs, **Then** it
   ends with the toolbox's standard missing-requirement skip and a message naming the
   service and quoting its reply.
2. **Given** the service is unreachable, **Then** the existing reachability requirement
   check skips the test, as today.
3. **Given** the service accepts the login, **Then** both upload assertions run as today.
4. **Given** any other unexpected reply, **Then** the test fails as today.

---

### User Story 4 - rank routine silent at printLevel 0 (Priority: P4)

A user calls a function at print level 0 and gets no console text from the rank routine
it uses, even when the routine falls back from LUSOL to MATLAB's LU. The fallback is still
reported, once per MATLAB session, as a visible MATLAB warning that carries the original
error's message and where it was raised. The rank returned is unchanged.

**Why this priority**: a real defect, since the routine prints unconditionally whatever
`printLevel` is, but it is not the cause of any of the five CI failures.

**Independent Test**: force the LUSOL path to fail locally, call the rank routine at print
level 0 under `matlab -batch`, capture the console, and compare with print level 1.

**Acceptance Scenarios**:

1. **Given** the LUSOL call fails, **When** the rank routine runs at print level 0 for the
   first time in the session, **Then** the only console output is one MATLAB warning (with
   the message and the file and line of the original error, plus MATLAB's own backtrace),
   and the returned rank equals MATLAB's rank of the input.
2. **Given** repeated fallbacks in one session, **Then** later calls at print level 0 print
   nothing.
3. **Given** the same failure at print level ≥ 1, **Then** the explanatory fallback
   message is printed on every call, as today.
4. **Given** LUSOL returns error codes 3-9, **When** the routine runs at print level 0,
   **Then** no explanatory text is printed. At print level ≥ 1 the same text as today is
   printed.
5. **Given** LUSOL works (codes 0/1), **Then** rank, row and column permutations are
   identical to today's for any print level.
6. **Given** the LUSOL interface file is not on the path, **Then** it is handled as a
   fallback: the same once-per-session warning, naming the missing interface instead of
   an error, and no other text at print level 0.

### Edge Cases

- lrs exits 0 but writes an empty or truncated file: the existing read error stays (out of
  scope to change).
- lrs is absent from the path (`which lrs` empty): behaviour unchanged by this feature.
- The updated `binary` pointer changes other shipped executables (quad MINOS, DQQ,
  libgfortran.so.6 rebuilds), so tests that use them may change outcome on CI.
- The updated binary no longer ships a separate `redund` executable; `param.redund = 0`
  now fails with the FR-002 error instead of reading an empty file (research R3).
- A caught error with an empty stack still produces the US4 warning, with "(no stack)"
  in place of file and line.
- When testReconMap skips, it restores the caller's working directory and the shared
  credentials.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The repository MUST pin the `binary` submodule at `10697a987` (the binary
  repository's current `master`), whose Linux lrs starts on an image without
  `libgmp.so.3`.
- **FR-002**: The lrs driver MUST treat any non-zero exit status from lrs or redund as a
  failure. It MUST raise an error that names the command run and the exit status, and
  includes the command's output text when available, before any attempt to read the
  output file.
- **FR-003**: In the driver's shell-script mode, success MUST be exit status 0 and failure
  any non-zero status, correcting the inverted test. On success the driver MUST return
  the same output file name as in direct mode. Today that output is never assigned, so
  shell-script mode can never return (found during planning, research R3).
- **FR-004**: testGenerateFullRowRankFR's console capture MUST remove each occurrence of
  the named expected warnings in full: the message text (matched after collapsing
  whitespace, so line wrapping does not matter), any surrounding brackets, and the
  backtrace block that follows. The named warnings are the addReaction "Reaction with the
  same name already exists" warning and the getRankLUSOL fallback warning (FR-008). All
  other text MUST remain and fail the check.
- **FR-005**: testReconMap MUST end with the toolbox's standard missing-requirement skip
  when the service refuses the test account, and MUST otherwise keep today's assertions.
- **FR-005a**: testReconMap's unreachable branch, which holds hard-coded personal
  credentials, MUST be deleted.
- **FR-005b**: When testReconMap skips, it MUST first restore the caller's working
  directory and the shared credentials.
- **FR-006**: The rank routine MUST print its explanatory fallback and LUSOL error-code
  messages only when print level ≥ 1. Their wording at print level ≥ 1 MUST stay as
  today.
- **FR-007**: The rank routine's outputs (rank, row and column permutations) MUST be
  identical to today's for every input and print level.
- **FR-008**: When the LUSOL call fails, or the interface is not on the path, the rank
  routine MUST emit a visible MATLAB warning with identifier `getRankLUSOL:lusolFallback`.
  The warning MUST include the original error's message and the file and line of its
  first stack frame ("(no stack)" if the stack is empty; Principle VII-C). It is raised at
  every print level on the first fallback of the MATLAB session. Later fallbacks in the
  same session MUST NOT repeat it. "Session" means until the rank routine's state is
  cleared: a new MATLAB process, `clear functions`, `clear all`, or `clear getRankLUSOL`.
- **FR-009**: Public interfaces MUST NOT change: no new required inputs, no changed
  outputs, no changed print-level default. One diagnostic change is intentional
  (Principle II): at the default print level 0 the rank routine no longer prints its
  fallback and LUSOL error-code text. The information stays available as the warning
  (FR-008) and at print level ≥ 1. This MUST be recorded in the routine's help header
  NOTE.
- **FR-010**: The help headers of the rank routine and the lrs driver MUST be updated in
  the same change to describe the print-level and error behaviour (VII-E).
- **FR-011**: Each change MUST be covered by the narrowest test:
  - The three lrs tests.
  - Automated checks in testLrsInterface for FR-002 (Unix only): a stand-in lrs that
    exits non-zero, placed first on the PATH for the duration of the check, for vertex
    and facet enumeration.
  - An automated check in testLrsInterface for FR-003, using hand-written shell scripts
    that exit 0 and non-zero.
  - testGenerateFullRowRankFR, verified under `matlab -batch`, for FR-004.
  - testRank for FR-006–FR-008: a forced fallback, verified under `matlab -batch`.
  - testReconMap for FR-005, verified under `matlab -batch`.
- **FR-012**: The full topology and rank test folders MUST pass locally after the change.
  - The binary bump changes 42 files under `glnxa64/bin/` in four folders: `lrs` (18),
    `quadPrecision` (17), `minos` (4), `DQQ` (3).
  - Solvers `dqqMinos`/`quadMinos` load from `quadPrecision`. The tests that use them
    (at least testSolveCobraLP, testSolveCobraQP, testQuadLP, testDuals,
    testMapSolverStatus) MUST be run locally before and after the bump, and any change
    in outcome reported.

### Key Entities

- **binary submodule pointer**: the commit of the shipped executables repository that a
  checkout (and CI) uses.
- **lrs driver**: the toolbox function that writes lrs input, runs lrs/redund, and reads
  the output.
- **console-capture filter**: the test helper that records console text during a
  printLevel-0 call and removes the expected, named warnings.
- **rank routine**: the toolbox function that returns the rank of a sparse matrix via LUSOL,
  falling back to MATLAB's LU.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Of the five named tests, four pass and testReconMap is reported as skipped
  while the service refuses the account. This holds locally (under `matlab -batch` for
  the capture-based tests) and on CI once the branch runs there.
- **SC-002**: With lrs made unrunnable, every tested driver call (vertex and facet
  enumeration) stops with an error naming the command and exit status. No call reports
  "Could not read lrs output file."
- **SC-003**: Under `matlab -batch`, testGenerateFullRowRankFR passes. A scratch run that
  adds one extra printed line at printLevel 0 makes it fail.
- **SC-004**: With LUSOL forced to fail at print level 0, the first call in a session
  writes exactly one warning (with its backtrace) and no other console text, and later
  calls write nothing. The returned rank equals MATLAB's rank in every call.
- **SC-005**: On fixtures where LUSOL works, rank and permutations are bit-for-bit
  identical before and after the change.
- **SC-006**: No previously passing test in the topology and rank test folders fails after
  the change (local run reported in the implementation receipt).

## Assumptions

- The CI image lacks `libgmp.so.3`, confirmed by the exit-127 reproduction with the old
  binary.
- The binary repository's `10697a987` is the intended current set of shipped executables.
  Bumping to it is preferable to cherry-picking lrs alone, because the binary repository
  has no lrs-only commit.
- Testing the "unrunnable lrs" path uses a stand-in executable earlier on the path that
  exits non-zero. The shipped binary is not modified.
- `matlab -batch` on this machine renders warnings in the diary the way CI's
  `matlab -batch` does: brackets, wrapping, backtrace.
- Constitution III's "avoid internet access" rule is not addressed here; testReconMap
  remains a network test.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1-1 / FR-001 | testExtremePathways, testExtremePools, testLrsInterface (test/verifiedTests/analysis/testTopology/) | — (binary submodule pointer) |
| US1-2 / FR-002 | testLrsInterface (stand-in lrs, vertex + facet) | src/analysis/topology/extremeRays/lrs/lrsInterface/lrsRun.m |
| US1-3 / FR-003 | testLrsInterface (hand-written shell scripts) | src/analysis/topology/extremeRays/lrs/lrsInterface/lrsRun.m |
| US2-1..4 / FR-004 | testGenerateFullRowRankFR under `matlab -batch` | — (test-only change; generateFullRowRankFR unchanged) |
| US3-1..4 / FR-005, FR-005a, FR-005b | testReconMap under `matlab -batch` | — (test-only change) |
| US4-1..6 / FR-006..FR-009 | testRank (test/verifiedTests/analysis/testRank/) under `matlab -batch` | src/analysis/subspaces/rank/getRankLUSOL.m |
