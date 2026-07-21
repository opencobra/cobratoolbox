# Feature Specification: testAll performance modes

**Feature Branch**: `002-testall-performance-modes`

**Created**: 2026-07-13

**Status**: Draft

**Input**: User description: "testAll performance modes — a fast-by-default, coverage-preserving test-suite mode plus an opt-in profiling report."

## Clarifications

### Amendment 2026-07-21 (post-implementation, via DIRECT IMPLEMENTATION OVERRIDE)

- The "CI runs **full** mode" decision below (and the matching Edge Case and
  **FR-012**) is **superseded**: CI now runs **fast** by default and **full** only
  for pull requests targeting `master`, so develop PRs get fast feedback while the
  coverage-gate baseline is preserved for merges to `master`. Rationale, exact
  resolution order, and files changed are recorded in
  `agent-runs/20260721T195656Z-ci-mode-by-base-ref/change-note.md` (PR
  opencobra/cobratoolbox#2681). FR-012 should be reconciled into the spec body on
  the next normal Spec Kit revision of this feature.

### Session 2026-07-13

- Q: When fast mode is the default, which mode should CI run given the
  `001-ci-coverage-gating` coverage gate? → A: CI runs **full** mode (preserving
  the existing gate baseline); local/interactive runs default to **fast**.
- Q: How much coverage may fast mode give up versus full mode? → A: Up to a
  **5 percentage-point absolute drop** in measured source-line coverage.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Fast, coverage-preserving suite by default (Priority: P1)

A contributor (or CI) runs the COBRA Toolbox test suite and it completes
materially faster than today, while still exercising essentially the same code
paths, so routine validation is cheaper without meaningfully weakening it.

**Why this priority**: This is the core value — the suite's runtime is dominated
by redundant work (the same feature re-validated across every installed solver,
large models re-parsed, dead waits). Reducing that redundancy is what makes the
feature worth doing; without it, nothing else matters.

**Independent Test**: Run the suite in its default configuration on a machine with
several solvers installed and confirm (a) total wall-clock time is materially lower
than the full run and (b) measured line coverage is within the agreed tolerance of
the full run, with the same set of tests reported (none silently dropped).

**Acceptance Scenarios**:

1. **Given** a machine with multiple working LP/MILP/QP solvers, **When** the suite
   is run with no special option, **Then** it runs in fast mode, completes
   materially faster than full mode, and reports the same tests (pass/fail/skip)
   with coverage within the agreed tolerance of full mode.
2. **Given** a test whose assertions are solver-independent, **When** run in fast
   mode, **Then** it exercises one representative solver rather than looping over
   all installed solvers, and its pass/fail outcome is unchanged.
3. **Given** a machine with only one working solver, **When** the suite is run in
   fast mode, **Then** behavior and coverage are effectively identical to full mode
   (there is no redundant solver loop to trim).

---

### User Story 2 - Revert to the complete, thorough suite (Priority: P2)

A maintainer preparing a release, or investigating a solver-specific discrepancy,
runs the complete, slower suite exactly as it behaves today, so nothing is traded
away when full rigor is required.

**Why this priority**: The speedups deliberately reduce redundant cross-solver and
large-model checks; those checks still have value for release validation and
solver-regression hunting. A reliable, documented way back to full behavior is
what makes fast-by-default safe to adopt.

**Independent Test**: Run the suite in full mode and confirm it reproduces the
current behavior — same tests, same solver loops, same models, same timing profile
(within noise) as the pre-feature suite.

**Acceptance Scenarios**:

1. **Given** the full-mode control is selected, **When** the suite runs, **Then**
   every test behaves exactly as it does today (all solver loops, all models, all
   currently-executed work), with no fast-mode trimming applied.
2. **Given** a contributor unaware of the feature, **When** they read the test
   documentation, **Then** they can discover how to select full mode and why they
   might want to.

---

### User Story 3 - Opt-in performance report (Priority: P3)

A developer runs the suite with a performance-analysis option and receives a ranked
list of the slowest tests plus function-level hotspots, so they can see where time
goes and target future optimization without hand-instrumenting anything.

**Why this priority**: Valuable for maintenance and for validating the fast-mode
speedups, but not required for the suite to be faster. It mostly surfaces data the
suite already collects, so it is low-risk and low-cost, hence lowest priority.

**Independent Test**: Run the suite with the performance option enabled and confirm
it produces a ranked per-test timing table and a function-level hotspot list as
artifacts, while pass/fail outcomes are identical to a run without the option.

**Acceptance Scenarios**:

1. **Given** the performance option is enabled, **When** the suite finishes,
   **Then** a ranked slowest-tests table and a function-level hotspot report are
   written as artifacts and the slowest tests are printed to the console.
2. **Given** the performance option is not enabled (default), **When** the suite
   runs, **Then** no performance artifacts are produced and behavior is unchanged.
3. **Given** the performance option is enabled but the profiling facility is
   unavailable, **When** the suite runs, **Then** the run still completes and
   reports pass/fail normally, with a clear warning that hotspots were unavailable.

---

### Edge Cases

- **Single-solver environment**: fast mode must not error or skip tests when there
  is nothing to trim; it degrades to full-mode-equivalent behavior.
- **Invalid/unknown mode value**: the suite must reject or safely default an
  unrecognized mode selection with a clear message, not run in an undefined state.
- **CI + coverage gate interaction**: fast mode reduces exercised paths, so it can
  lower measured coverage. CI therefore runs **full** mode so the coverage/skip gate
  from feature `001-ci-coverage-gating` keeps its existing baseline; fast mode is a
  local/interactive default only and does not feed the gate.
- **Already-broken tests**: `testFVA` (fails) and `testdynamicRFBA` (errors) today;
  fast mode must not hide or "fix" these by skipping them — they must remain
  visibly failing/erroring so the mode is not blamed for masking regressions.
- **Performance option in a non-interactive/headless run**: artifact writing must
  not block on a UI and must tolerate a missing HTML-report facility.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The suite MUST support two execution modes — a fast mode and a full
  mode — selectable through a single documented control, defaulting to fast mode
  when no selection is made.
- **FR-002**: Fast mode MUST reduce total suite wall-clock time relative to full
  mode on a machine with multiple working solvers, by eliminating redundant work
  (per-test solver-loop breadth, large-model re-parsing, dead waits, plot-only or
  unasserted computation, and duplicated model builds).
- **FR-003**: Fast mode MUST preserve code coverage to within a **5 percentage-point
  absolute drop** of full-mode measured source-line coverage, and MUST run the same
  set of tests (no test silently removed or skipped as a speed measure).
- **FR-004**: Full mode MUST reproduce the current (pre-feature) behavior exactly:
  all solver loops, all models, and all currently-executed work, with no fast-mode
  trimming.
- **FR-005**: Tests whose purpose IS cross-solver agreement (e.g. the solver-suite
  tests) MUST continue to exercise all relevant solvers even in fast mode; only
  tests whose assertions are solver-independent may reduce to one representative
  solver in fast mode.
- **FR-006**: The feature MUST NOT change any scientific result, expected value,
  assertion, tolerance, or public function interface; it changes only how much
  redundant work runs, not what "correct" means.
- **FR-007**: Fast mode MUST NOT mask currently failing or erroring tests; tests
  that fail or error in full mode MUST still fail or error (visibly) in fast mode.
- **FR-008**: The suite MUST provide an opt-in performance-analysis report,
  disabled by default, that produces a ranked per-test timing table and a
  function-level hotspot report as artifacts, and prints the slowest tests.
- **FR-009**: Enabling or disabling the performance report MUST NOT change any
  test's pass/fail/skip outcome, and its failure (e.g. profiling unavailable) MUST
  be surfaced as a warning without failing the run.
- **FR-010**: The mode control and the performance option MUST be documented for
  contributors (how to run fast, how to revert to full, how to get a performance
  report, and the backward-compatibility note that fast is the new default).
- **FR-011**: The default-to-fast behavior change MUST be recorded as a
  backward-compatibility note (per constitution Principle II), stating that the
  same tests run with reduced redundant work and how to restore prior behavior.
- **FR-012**: In the CI environment the suite MUST run in full mode (regardless of
  the local default), so the `001-ci-coverage-gating` coverage/skip gate continues
  to measure the complete suite and its baseline is unaffected by fast mode.

### Key Entities *(include if feature involves data)*

- **Execution mode**: the selected suite behavior (fast or full), with fast as the
  default; determines whether redundant-work reductions are applied.
- **Per-test timing record**: name, status (pass/fail/skip), and wall-clock time
  for each test — already produced by the runner; ranked for the report.
- **Performance report artifacts**: a ranked slowest-tests table and a
  function-level hotspot report, written only when the performance option is on.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On a machine with multiple working solvers, fast mode reduces total
  suite wall-clock time by a material margin versus full mode (target on the order
  of 40–50%), measured as end-to-end run time.
- **SC-002**: Fast-mode source-line coverage is no more than 5 percentage points
  (absolute) below full-mode coverage, measured by the existing coverage tooling.
- **SC-003**: Full mode's per-test outcomes and timing profile match the
  pre-feature suite within run-to-run noise (no test added, removed, or changed).
- **SC-004**: The same set of tests is reported (pass/fail/skip counts reconcile)
  between fast and full mode, aside from tuned redundant iterations; no test is
  silently dropped in fast mode.
- **SC-005**: With the performance option enabled, the ranked slowest-tests table
  correctly orders tests by measured time and the hotspot report lists the highest
  total-time functions; with it disabled, no artifacts are produced.
- **SC-006**: A contributor can, from the documentation alone, select fast mode,
  revert to full mode, and produce a performance report without reading source.

## Assumptions

- Mode and performance-option selection use a single, discoverable control
  consistent with how the suite is already configured (the exact mechanism is an
  implementation choice deferred to planning; the spec only requires it be
  documented and default to fast).
- "Representative solver" in fast mode means the suite's already-selected default
  solver for the relevant problem class, so no new solver-selection policy is
  introduced.
- The performance report surfaces data the runner already collects (per-test time)
  plus the profiler the suite already enables; it does not add new instrumentation
  to individual tests.
- Coverage is measured with the existing coverage tooling used by feature
  `001-ci-coverage-gating`; this feature does not change how coverage is computed.
- Fixing the root cause of the currently broken `testFVA`/`testdynamicRFBA` is out
  of scope; they are only required to remain visibly broken (not masked).
