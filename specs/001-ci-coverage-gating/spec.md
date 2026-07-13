# Feature Specification: Measure test coverage in CI and gate silent test-suite erosion

**Feature Branch**: `001-ci-coverage-gating`

**Created**: 2026-07-13

**Status**: Draft

**Input**: User description: "Measure test coverage in CI and stop silent test-suite
erosion (addresses architecture weakness W8, Constitution Principle III)." Full context in
`analysis/ARCHITECTURE.md` §8 and `analysis/WEAKNESSES.md` W8.

## Clarifications

### Session 2026-07-13

- Q: Where should CI publish the coverage measurement? → A: Always produce a self-contained
  coverage artifact/summary in CI, and additionally upload to Codecov on a best-effort basis
  (never fail the build if Codecov is unreachable).
- Q: What is the first `prepareTest` backfill slice (scope of this feature)? → A: All currently
  ungated tests are audited and given requirement declarations now (complete backfill), not a
  phased subset.
- Q: What policy should the skip-count gate apply on first rollout? → A: Flag/warn with a
  recorded baseline (report and warn on increase); do not hard-fail the build initially.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Coverage is measured and visible on every pull request (Priority: P1)

A maintainer opens a pull request to `develop`. The continuous-integration run executes the
existing test suite and, in addition to the current pass/fail report, produces a
line-coverage figure for the toolbox source together with the change in coverage relative to
the target branch, surfaced where reviewers already look (the PR).

**Why this priority**: This is the core of the weakness — coverage is currently never
measured, so "green CI" hides regressions. Making coverage visible is the single highest-value
slice and delivers value even if nothing else in this feature ships. It also restores the
constitution's "coverage maintained" success criterion (Principle III), which today cannot be
checked at all.

**Independent Test**: Open a PR (or run the CI job) and confirm a coverage percentage and a
delta appear as a CI output/artifact/comment. Can be validated with no changes to any test
file — purely by wiring the already-referenced coverage tooling into the CI job.

**Acceptance Scenarios**:

1. **Given** a pull request to `develop`, **When** the CI test job completes, **Then** a
   line-coverage percentage for the toolbox source and its delta versus the base branch are
   reported to the reviewer.
2. **Given** a change that removes test exercise of a source region, **When** CI runs,
   **Then** the reported coverage delta is negative, making the regression visible.
3. **Given** the coverage tooling is unavailable or fails to produce a report, **When** CI
   runs, **Then** the job records the coverage step as failed/absent explicitly (no silent
   skip) while the existing pass/fail report still completes.

---

### User Story 2 - Requirement-gated tests skip gracefully instead of hard-failing (Priority: P2)

A contributor (or CI) runs the suite in an environment that lacks a particular commercial
solver, MATLAB toolbox, operating system, or external binary. Tests that genuinely need that
resource are reported as **skipped** (not failed), so the pass/fail signal reflects real
defects rather than environment gaps.

**Why this priority**: Roughly 82% of tests do not declare their requirements, so they
hard-fail when a resource is absent. Because CI installs only one commercial solver, this
produces false reds and masks true regressions. Gating tests makes the red/green signal
trustworthy and is a prerequisite for the coverage number in US1 to be interpretable.

**Independent Test**: Run the suite in an environment missing a given commercial solver and
confirm the dependent tests are counted as skipped via the existing `COBRA:RequirementsNotMet`
mechanism, with zero of them reported as errors.

**Acceptance Scenarios**:

1. **Given** a test that requires a solver not installed in the environment, **When** the
   suite runs, **Then** that test is reported skipped (raising `COBRA:RequirementsNotMet`),
   not errored.
2. **Given** any backfilled test, **When** its required solver/toolbox is present, **Then** the
   test runs and asserts exactly as before (no behavioural change).
3. **Given** the requirement declaration is added, **When** the test is inspected, **Then**
   its requirements are declared through the existing `prepareTest` mechanism rather than
   ad-hoc environment checks.

---

### User Story 3 - Skipped-test count is tracked and can gate the build (Priority: P3)

A reviewer needs to know when the number of skipped tests jumps — the signature of silent
erosion (a newly solver-pinned test, a broken requirement, a disabled test). CI records the
skip count and compares it against a recorded baseline/threshold, flagging or failing the
build when the count rises beyond the allowed bound.

**Why this priority**: Even with US1 and US2, a rising tide of skips silently shrinks the
effectively-tested surface. Tracking and thresholding skip count closes the loop, but it
depends on US2 producing meaningful skip counts first, so it is lowest priority.

**Independent Test**: Increase the number of skipped tests (e.g. by removing a solver from the
environment or pinning a test to an absent one) and confirm CI surfaces the higher skip count
and applies the configured threshold behaviour (flag or fail).

**Acceptance Scenarios**:

1. **Given** a CI run, **When** it completes, **Then** the number of skipped tests is reported
   as a visible CI output/artifact.
2. **Given** the skip count exceeds the configured threshold, **When** CI runs, **Then** the
   build is flagged or failed according to the configured policy.
3. **Given** the skip count is at or below the threshold, **When** CI runs, **Then** the
   threshold check passes without affecting the existing pass/fail outcome.

---

### Edge Cases

- **Coverage instrumentation failure**: if the coverage tool errors mid-run, the coverage
  step is reported as failed/absent explicitly; it must not silently pass nor abort the
  underlying pass/fail test report.
- **No base branch / first run on a new branch**: coverage delta has nothing to compare
  against — the absolute coverage number is still reported and the delta is shown as
  not-applicable rather than an error.
- **A test declares a requirement that is actually available**: it must run normally, not be
  spuriously skipped.
- **A previously-failing test converted to skip that was masking a real defect**: skip must be
  driven only by genuine environment requirements; converting a real failure into a skip to
  "green" the build is explicitly out of scope and prohibited.
- **Skip threshold false alarm** from a legitimately reduced environment (e.g. an intentional
  solver removal): the baseline/threshold policy must be adjustable so intentional changes can
  update the baseline rather than block indefinitely.
- **Coverage tooling adds runtime**: instrumentation slows the suite; the added wall-clock
  must stay within an agreed bound so CI does not time out.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: CI MUST measure line coverage of the toolbox source (`src/`) during the existing
  test run on pull requests targeting `develop`.
- **FR-002**: CI MUST always produce a self-contained coverage artifact/summary for the run
  (the coverage percentage and its delta versus the base branch), AND additionally upload to
  Codecov on a best-effort basis, so coverage is visible to reviewers even when the external
  service is unavailable.
- **FR-003**: The coverage mechanism MUST reuse the coverage tooling already referenced by the
  test harness (MoCov + jsonlab) unless a documented, justified alternative is adopted in the
  plan; it MUST NOT require re-architecting the harness.
- **FR-004**: The build MUST NOT fail if the best-effort Codecov upload is unreachable; if
  coverage *measurement* itself fails, CI MUST report that step as failed/absent explicitly and
  MUST NOT silently show a green build with no coverage.
- **FR-005**: Tests that require a specific solver, MATLAB toolbox, operating system, or
  external binary MUST declare those requirements via `prepareTest`
  (`src/base/install/prepareTest.m`) so they raise `COBRA:RequirementsNotMet` and are counted
  as skipped when the requirement is absent.
- **FR-006**: The backfill MUST cover **all currently-ungated tests** under
  `test/verifiedTests/` (complete backfill, not a phased subset): each ungated test is audited
  for the solvers/toolboxes/OS/binaries it uses and given the corresponding `prepareTest`
  declaration (or explicitly recorded as needing none). The audit method and the
  per-test outcome MUST be recorded so the backfill is auditable.
- **FR-007**: CI MUST report the number of skipped tests as a visible output/artifact of the
  run.
- **FR-008**: CI MUST record a skipped-test-count baseline and compare each run against it,
  **flagging/warning** (not failing the build) when the count exceeds the baseline; the
  baseline MUST be updatable for intentional environment changes. (Hardening the flag into a
  hard-fail is explicitly deferred to follow-up once the baseline is trusted.)
- **FR-009**: The feature MUST preserve the existing test harness behaviour — `test/testAll.m`
  → `test/runTestSuite.m` running tests as scripts, skip detection via `COBRA:RequirementsNotMet`,
  and the JUnit→CTRF pass/fail PR report MUST continue to work unchanged.
- **FR-010**: The feature MUST NOT change scientific/model behaviour, public function
  interfaces, solver-status semantics (`.stat`/`.origStat`), or COBRA model fields
  (Constitution II, IV). Only CI configuration, test-harness reporting glue, and per-test
  requirement metadata may change; a test's assertions MUST be unchanged when its requirements
  are met.
- **FR-011**: The feature MUST define the narrowest reproducibility check that proves the new
  behaviour — at minimum, a demonstration that a requirement-gated test is skipped (not
  errored) when its resource is absent and runs when present, and that CI emits coverage and
  skip-count values.
- **FR-012**: The feature MUST state its measurable runtime/CI constraints — the coverage
  instrumentation's added wall-clock time and any network/secret dependency introduced by
  coverage upload MUST be identified and bounded (headless Linux/Docker, Principle III).

### Key Entities *(include if feature involves data)*

- **Coverage report**: the per-run measurement of toolbox-source line coverage (percentage and
  a per-file/line breakdown) plus the delta versus the base branch; consumed by reviewers.
- **Test requirement declaration**: the `prepareTest` metadata on a test stating the solvers,
  toolboxes, OS, or binaries it needs; determines run-vs-skip.
- **Skip ledger / threshold**: the recorded count of skipped tests for a run and the
  baseline/threshold it is compared against, plus the policy applied on exceedance.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A pull request to `develop` shows a toolbox-source line-coverage percentage and a
  delta from CI (previously: zero coverage information was produced).
- **SC-002**: Running the full suite without a given commercial solver yields **0** dependent
  tests reported as errors due to the missing solver — all are reported as skipped (measured
  across all currently-ungated tests, which are backfilled in this feature).
- **SC-003**: CI reports a skipped-test count on every run and compares it to a recorded
  baseline, flagging/warning when the count rises above it; the flag does not fail the build
  (hard-fail is deferred).
- **SC-004**: The existing pass/fail CTRF PR report is produced with no regression, and no
  test's pass/fail outcome changes when its required resources are present.
- **SC-005**: The reproducibility check completes as specified — a requirement-gated test is
  skipped when its resource is absent and passes when present — with solver-status strings and
  any residual labels preserved.
- **SC-006**: Coverage instrumentation increases total suite wall-clock by no more than the
  bound agreed in the plan, and any coverage-upload network/secret dependency is documented and
  optional (the pass/fail run must still succeed without it).

## Assumptions

- **Coverage destination** (resolved, Session 2026-07-13): CI always produces a self-contained
  coverage artifact/summary AND uploads to Codecov best-effort (`codecov.yml` already exists);
  a Codecov outage or missing token degrades only the hosted view, never the build.
- **Backfill scope** (resolved, Session 2026-07-13): the `prepareTest` backfill covers **all
  currently-ungated tests** under `test/verifiedTests/` in this feature (complete backfill),
  each audited for its resource needs; this is a large scope and the plan/tasks must decompose
  it into reviewable batches (e.g. by test category) even though all are in-scope.
- **Skip-gate policy** (resolved, Session 2026-07-13): the skip-count gate **flags/warns**
  against a recorded baseline and does not hard-fail the build on first rollout; the hard-fail
  hardening is deferred to follow-up.
- CI continues to run MATLAB headless in Docker on Linux with only the gurobi commercial solver
  plus available open-source solvers; the feature must work in that environment and locally.
- `prepareTest` and its requirement keys (`needsLP/QP/MILP/MIQP/NLP/EP`, `requireOneSolverOf`,
  `requiredSolvers`, `requiredToolboxes`, `needsUnix/Windows/Mac`, `needsWebAddress`, …) are the
  correct and sufficient mechanism for declaring test requirements; no new gating mechanism is
  introduced.
- Determining which tests need which resources is done by inspection of each test's solver/
  toolbox usage; where ambiguous, the safe default is to gate conservatively (declare the
  requirement) rather than leave a test to hard-fail.
- This feature does not delete, disable, or weaken any test; it only adds requirement metadata,
  CI coverage wiring, and skip-count reporting.
