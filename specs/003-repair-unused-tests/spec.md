# Feature Specification: Repair unused / non-contributing tests to enlarge coverage

**Feature Branch**: `003-repair-unused-tests`

**Created**: 2026-07-13

**Status**: Draft

**Input**: User description: "identify as many as yet not used test functions in test/ then repair them, if possible, to enlarge the test coverage."

## Clarifications

### Session 2026-07-13

- Q: What counts as "done" for enlarging coverage? → A: A **pass-count increase**
  (more tests pass, fewer error than baseline) with **every identified
  non-contributing test accounted for**; verified locally. The full source-line
  coverage number is confirmed in CI, not required as a local gate.
- Q: How wide is the repair scope? → A: **Widest** — repair code-bug failures,
  broaden safe (solver/toolbox-agnostic) requirement declarations, **and attempt to
  install/configure freely-available external dependencies** (e.g. the `lrs` binary,
  `obabel`, `cxcalc`, and the Parallel Computing Toolbox where a license exists) so
  their tests run; convert only genuinely-unobtainable dependencies
  (commercial-licensed solvers/toolboxes) to clean skips; remove the stray test.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Repair genuinely broken tests (Priority: P1)

A maintainer runs the suite and several tests that currently error or fail due to
code bugs in the test itself now run and pass, exercising code that was previously
untested, so overall coverage grows without any assertion being weakened.

**Why this priority**: Broken tests are pure waste — they cost time, clutter the
report, and cover nothing. Fixing the ones broken by their own bugs (not by missing
dependencies) is the highest-value, most self-contained win.

**Independent Test**: Take the set of tests that error/fail today from a code bug
(not a missing dependency), fix each, and confirm it now passes on the locally
available solvers with its original assertions intact.

**Acceptance Scenarios**:

1. **Given** a test that errors today due to a bug in the test code (e.g. misuse of a
   file identifier, indexing a struct as a cell, a stale property name), **When** the
   bug is fixed, **Then** the test runs and passes with the same assertions, and the
   code it targets is now covered.
2. **Given** a repaired test, **When** it is reviewed, **Then** no assertion or
   expected value was removed, loosened, or bypassed to achieve the pass.
3. **Given** the full suite after repairs, **When** it is run, **Then** no
   previously-passing test now fails.

---

### User Story 2 - Run tests that needlessly skip (Priority: P2)

A maintainer finds that tests which were always skipping because they demanded a
specific unavailable solver or toolbox — when the code they exercise is not actually
specific to it — now run on an available solver, adding coverage.

**Why this priority**: Over-strict requirement declarations hide runnable coverage.
Broadening them (only where the tested path is genuinely solver/toolbox-agnostic)
turns dead skips into real, passing tests. Lower priority than P1 because each case
must be individually justified as safe.

**Independent Test**: For a test that skips demanding e.g. a commercial solver, show
the exercised code path is not specific to it, broaden the requirement to a generic
solver class, and confirm it runs and passes on an available solver.

**Acceptance Scenarios**:

1. **Given** a test that skips demanding a specific unavailable solver/toolbox it does
   not truly need, **When** its requirement is broadened to the generic capability,
   **Then** it runs and passes on an available solver with unchanged assertions.
2. **Given** a test that genuinely needs a specific unavailable dependency, **When**
   requirements are reviewed, **Then** it is left to skip (not forced to run).

---

### User Story 3 - Clean up: honest skips and stray tests (Priority: P3)

A maintainer sees that tests which cannot run here for environmental reasons skip
*cleanly* (reported as skipped-for-missing-requirement) instead of erroring, and that
a stray example test targeting a nonexistent function is removed, so the report
reflects reality and the error count drops.

**Why this priority**: Improves signal (an environmental gap should read as "skipped",
not "broken") and removes clutter, but adds little direct coverage — hence lowest.

**Independent Test**: For a test that errors only because an external binary/toolbox
is absent, add the correct requirement declaration and confirm it now reports as a
clean skip; confirm the stray test is removed and the suite still runs.

**Acceptance Scenarios**:

1. **Given** a test that errors solely because an external dependency is absent,
   **When** a correct requirement declaration is added, **Then** it reports as a clean
   skip (missing-requirement), not an error, where that dependency is unavailable.
2. **Given** the stray test that targets a function which does not exist in the
   repository, **When** the feature completes, **Then** that test no longer errors
   (it is removed), and no real coverage is lost.

---

### Edge Cases

- **A "bug fix" that would change what is tested**: if repairing a test would require
  altering an assertion or expected value, the test is left unrepaired and flagged,
  rather than weakened.
- **A repair that needs a change in the function under test**: out of scope beyond the
  minimal change to fix the test's own bug; if the function itself is wrong, that is a
  separate feature.
- **Solver-numeric failures**: a test failing only on solver-specific numeric
  tolerance (e.g. assertions annotated as valid only for one solver) must be guarded
  to the solver it is valid for, not have its tolerance loosened.
- **Interaction with the coverage gate (001)**: newly-passing tests raise coverage;
  the CI coverage/skip baseline must be updated intentionally, not tripped.
- **Interaction with fast/full modes (002)**: a repaired test must behave correctly
  in both modes.
- **A test that passes locally but only because a dependency happens to be present**:
  its requirement declaration must still be correct so it skips cleanly elsewhere.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The feature MUST repair tests that currently error or fail because of a
  bug in the test code itself (not a missing dependency), so they run and pass on the
  locally available solvers.
- **FR-002**: A repaired test MUST retain all of its original assertions and expected
  values; no assertion may be removed, loosened, bypassed, or have its expected value
  changed to force a pass.
- **FR-003**: The feature MUST NOT break any test that passes today, and MUST NOT
  change any function-under-test's behaviour, public interface, or scientific result
  beyond the minimal change (if any) required to fix a test's own bug.
- **FR-004**: The feature MUST broaden over-strict test requirement declarations to a
  generic capability (e.g. "an LP solver") ONLY where the exercised code path is
  demonstrably not specific to the originally-demanded solver/toolbox, so the test
  runs on an available solver instead of needlessly skipping.
- **FR-005**: Tests that genuinely require an absent dependency MUST skip cleanly
  (reported as skipped for a missing requirement), not error; and MUST still skip
  cleanly on systems lacking that dependency after repair.
- **FR-006**: The stray test targeting a function that does not exist in the
  repository MUST be resolved so it no longer errors (removed, since its target does
  not exist), without losing any real coverage.
- **FR-007**: Environment-dependent failures that cannot be fixed in test code MUST
  be either converted to clean skips (correct requirement declaration) or explicitly
  documented as out of scope — never masked or silently deleted.
- **FR-008**: The feature's definition of done is a **pass-count increase** — after
  the feature, strictly more tests pass and strictly fewer error than the pre-feature
  baseline — with the before/after figures recorded and every identified
  non-contributing test accounted for. Verified locally; the full source-line coverage
  number is confirmed in CI and is not a local gate.
- **FR-009**: The repair scope is the **widest** over the identified set: (a) code-bug
  failures; (b) safe requirement-broadenings; (c) freely-available env dependencies
  installed/configured so their tests run; (d) the stray test removed. The set MUST be
  bounded and explicit (enumerated in the plan after per-test triage), not silently
  expanded beyond the identified non-contributing tests.
- **FR-010**: Repaired tests MUST behave correctly under both the fast (default) and
  full test-execution modes introduced by feature 002.
- **FR-011**: Where a failing/skipping test depends on a **freely-obtainable** external
  dependency (e.g. the `lrs` binary, `obabel`, `cxcalc`, or a toolbox for which a
  license is available), the feature MUST attempt to install/configure that dependency
  so the test runs. Installation steps that change system state MUST be surfaced to the
  user (not run silently), and MUST be reproducible/documented. Dependencies that cannot
  be obtained (commercial solver/toolbox licenses) MUST instead be left as clean skips
  (FR-005), not forced.

### Key Entities *(include if feature involves data)*

- **Non-contributing test**: a test file that adds no coverage because it is not run,
  always skips, or fails/errors. Categorised as: code-bug failure, over-strict-skip,
  environment-skip/error, or stray (targets a nonexistent function).
- **Repair**: a minimal change to a test (or its requirement declaration) that makes
  it run and pass — or skip cleanly — with its assertions intact.
- **Coverage baseline**: the pre-feature count of passing tests and covered source
  lines, against which enlargement is measured.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After the feature, the number of tests that pass is strictly greater
  than the pre-feature baseline, and the number that error is lower.
- **SC-002**: Every test repaired to pass does so with its original assertions intact
  (zero assertions weakened, deleted, or bypassed) — verifiable by diff review.
- **SC-003**: No test that passed before the feature fails after it.
- **SC-004**: Every identified non-contributing test is accounted for with an outcome:
  repaired-to-pass, repaired-to-clean-skip, removed (stray), or documented out-of-scope
  (with reason).
- **SC-005**: Source-line coverage after the feature is greater than or equal to the
  pre-feature baseline (and higher for the repaired code paths); confirmed by the
  existing coverage tooling in CI (not required as a local close-out gate per FR-008).
- **SC-006**: The stray test targeting a nonexistent function no longer appears as an
  error in the suite report.

## Assumptions

- "Locally available solvers" are gurobi, mosek, glpk, pdco, quadMinos, dqqMinos; a
  repaired test must pass on at least the default solver for the class it needs.
- Coverage is measured with the existing tooling from feature 001; this feature does
  not change how coverage is computed, only enlarges what is covered.
- The functions under test are assumed correct; test failures are treated as test-side
  bugs unless clearly shown otherwise (in which case the function fix is out of scope).
- The identified categories (from the read-only survey) are the working set; the plan
  phase may refine membership after per-test triage, but will not silently expand scope.
- Removing the stray `test_myfunction.m` loses no real coverage because its target
  function does not exist in the repository.
- Freely-obtainable dependencies (`lrs`, `obabel`, `cxcalc`, open toolboxes) can be
  installed on this Linux system; their installation is in scope but surfaced to the
  user before changing system state. Commercial solver/toolbox licenses cannot be
  obtained here and remain clean skips.
