# Feature Specification: Fix the R2026a fast-mode suite failures

**Feature Branch**: `20261107-133937-r2026a-test-failures`

**Created**: 2026-11-07

**Status**: Draft

**Input**: User description: fix the six tests that fail in the R2026a fast-mode suite on `develop` (`2363a5a71`):
`testGetMolecularWeight`, `testOptimizeCbModelNLP`, `testFitC13Data`, `testExtractBondSubgraphs`,
`testClassifySubgraphIsomorphism` and `testEcosystemToy`. All six were diagnosed on 2026-11-07 (project memory
`agent-mode-init-false-test-failures`; diagnosis summarised under Background). "Speckit for all", with the
correction "except inchi": the defect inside `src/analysis/thermo/inchi/new/getFormulaAndChargeFromInChI` is out
of scope.

## Background (diagnosis, 2026-11-07, MATLAB R2026a Update 3)

| Test | Cause |
|---|---|
| `testGetMolecularWeight` | Agent-mode start-up leaves the thermochemistry `new/` folders on the path, so an experimental helper shadows the established one and a hydrogen is added to iron. Default-mode start-up removes those folders and the test passes. |
| `testOptimizeCbModelNLP` | Agent-mode start-up declares the `matlab` solver installed without checking; without the Optimization Toolbox the test errors instead of being skipped. Default mode skips it. |
| `testFitC13Data` | Same false availability in agent mode; once the test runs it fails on its own defect: it reads an undefined variable (`solverPkgs`) where its solver list is held in `solvers`. |
| `testExtractBondSubgraphs`, `testClassifySubgraphIsomorphism` | Each asserts that the rewritten function fails exactly as the function it replaced, by comparing the exact built-in error identifier recorded under R2024b. R2026a reports two of those built-in failures under new identifiers, so the comparison fails although the behaviour is unchanged. |
| `testEcosystemToy` | Passes with glpk and gurobi. With mosek, one or more flux variability problems behind the ecosystem cluster summary come back without an optimal value, producing a `NaN` and a different summary table. |

Also found: start-up in default mode, run inside a linked git worktree, attempts to initialise a git repository and
add a remote, because it recognises a repository only when `.git` is a folder.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - The test suite reports only real failures, whichever start-up mode is used (Priority: P1)

A maintainer runs the verified test suite on R2026a, either after a normal start-up or after the fast agent-mode
start-up their MATLAB session uses. Every test either passes or is skipped because a stated requirement is missing;
a failure means a real defect.

**Why this priority**: a suite that fails for environmental reasons hides real regressions; this was the
obstacle to judging the greedy-basis merge.

**Independent Test**: run the six tests after each start-up mode on R2026a and read their outcomes.

**Acceptance Scenarios**:

1. **Given** agent-mode start-up on a machine without the Optimization Toolbox, **When** a test requires the
   `matlab` solver or any NLP solver, **Then** it is skipped with the requirement named, not run and failed.
2. **Given** agent-mode start-up, **When** a function that exists in both an experimental `new/` folder and its
   established counterpart is called, **Then** the established one is used, exactly as after default start-up.
3. **Given** `testFitC13Data` runs where an NLP solver really is available, **When** it starts, **Then** it names
   the solver it uses and proceeds, rather than failing on an undefined name.
4. **Given** either start-up mode, **When** `testGetMolecularWeight`, `testOptimizeCbModelNLP` and
   `testFitC13Data` run, **Then** each passes or is skipped for a missing requirement.

---

### User Story 2 - Error-parity tests survive MATLAB releases (Priority: P1)

A maintainer upgrades MATLAB. The tests that prove a rewritten function fails the same way as the one it replaced
keep proving that, and fail only if the failure itself changes.

**Why this priority**: two tests are failing now on the maintainer's release, and every future release can
rename built-in identifiers again.

**Independent Test**: run both tests on R2026a; then feed each a deliberately different failure and confirm the
check still rejects it.

**Acceptance Scenarios**:

1. **Given** R2026a, **When** `testExtractBondSubgraphs` and `testClassifySubgraphIsomorphism` run, **Then** they
   pass.
2. **Given** a release that names the same built-in failure differently from R2024b, **When** the check compares
   the observed failure with the recorded one, **Then** it accepts it as the same failure.
3. **Given** a genuinely different failure (another cause, another kind of error), **When** the check compares,
   **Then** it still rejects it.
4. **Given** R2024b, where the fixtures were recorded, **When** the tests run, **Then** they still pass.

---

### User Story 3 - The ecosystem test's mosek discrepancy is understood and settled by the maintainer (Priority: P2)

The maintainer learns which optimisation problem fails under mosek, why, and what the options are, and chooses one.

**Why this priority**: the maintainer's solver policy is that solver-specific numerical issues are brought to
them with options, not settled silently.

**Independent Test**: a written diagnosis names the failing problem(s), mosek's reported status, and the options;
after the maintainer's choice, `testEcosystemToy` passes or is skipped for mosek as decided, and still passes with
glpk and gurobi.

**Acceptance Scenarios**:

1. **Given** `testEcosystemToy` under mosek, **When** diagnosed, **Then** the diagnosis identifies each problem
   that yields no optimal value, mosek's status for it, and the cause.
2. **Given** the diagnosis, **When** presented, **Then** the maintainer sees at least two options with their
   consequences, and nothing is changed until they choose.
3. **Given** the chosen option is implemented, **When** the test runs with glpk, gurobi and mosek, **Then** it
   passes for glpk and gurobi as before, and for mosek behaves as chosen.

---

### User Story 4 - Start-up inside a linked worktree leaves the repository alone (Priority: P3)

A maintainer starts the toolbox in default mode from a linked git worktree.

**Why this priority**: it was harmless only because the remote already existed; it should not depend on that.

**Independent Test**: start-up in a linked worktree completes without running repository-creating commands, and
the shared repository's configuration is unchanged.

**Acceptance Scenarios**:

1. **Given** a linked worktree, **When** default-mode start-up runs, **Then** it recognises the checkout as a git
   repository, runs no repository initialisation, and adds no remote.
2. **Given** a directory that truly is not a git repository, **When** start-up runs, **Then** its existing
   behaviour is unchanged.

### Edge Cases

- A machine that has the Optimization Toolbox: agent mode reports the `matlab` solver available, and the NLP tests
  run.
- A solver library on the path that provides a function of the same name as an optional MATLAB toolbox (mosek's
  own `linprog`): it does not make the `matlab` solver appear available.
- A user who deliberately puts a `new/` folder on the path after start-up: start-up does not fight them later.
- Error-parity fixtures where the recorded failure was not an error at all (outcome "ok"): unchanged comparison.
- A MATLAB release that changes an identifier AND the message: still recognised as the same failure when its kind
  is the same.
- gurobi absent in agent mode: unchanged; it is already checked by a local, fast test.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: After agent-mode start-up, a solver MUST be reported installed only when its interface is actually
  present on the machine. The check MUST be local and fast: no network, no license call that can block, no
  solving of a validation problem.
- **FR-002**: After agent-mode start-up, the thermochemistry `new/` folders MUST be off the path, as after
  default-mode start-up.
- **FR-003**: Default-mode start-up behaviour MUST be unchanged, except FR-008.
- **FR-004**: `testFitC13Data` MUST read its solver list from the value its requirement check returns.
- **FR-005**: The error-parity checks in `testExtractBondSubgraphs` and `testClassifySubgraphIsomorphism` MUST
  accept a failure that is the same as the recorded one under another release's naming, and MUST reject a
  different failure. The recorded R2024b fixtures MUST remain the reference; nothing is re-recorded unless the
  plan shows that is the only sound option.
- **FR-006**: The mosek discrepancy in `testEcosystemToy` MUST be diagnosed (which problem, which status, why)
  and presented to the maintainer with options; implementation of US3 waits for that choice.
- **FR-007**: The functions under the ecosystem analysis MUST NOT change their results for glpk or gurobi.
- **FR-008**: Default-mode start-up MUST recognise a linked worktree as a git repository and MUST NOT run
  repository initialisation or remote creation there.
- **FR-009**: `src/analysis/thermo/inchi/` MUST NOT be modified (out of scope by the maintainer's decision).
- **FR-010**: The fast-mode suite on R2026a after both start-up modes MUST show no test passing on `develop`
  (`2363a5a71`) that fails after this feature.

## Existing Contract

- **Function(s) under test**: `initCobraToolbox` (agent mode and the git-detection step), the tests named above.
- **Current behaviour**: agent mode marks glpk, pdco, mosek and matlab installed and working without checking,
  checks gurobi by a local path lookup, and skips the `new/` path clean-up; default mode probes every solver.
- **Invariants**: agent mode stays fast; default mode results unchanged (FR-003).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On R2026a, after each start-up mode, 6 of 6 named tests pass or are skipped for a named missing
  requirement; 0 fail (except `testEcosystemToy` under mosek until US3's option is implemented, then 0).
- **SC-002**: Agent-mode start-up takes no more than 1 second longer than before, measured as the median of 5
  runs.
- **SC-003**: The two error-parity tests reject 100% of a set of deliberately different failures (at least one
  per recorded error case).
- **SC-004**: The fast-mode suite shows 0 regressions against `develop` after either start-up mode.
- **SC-005**: Start-up in a linked worktree runs 0 repository-creating commands; the shared repository's
  configuration is byte-identical before and after.
- **SC-006**: The mosek diagnosis names every non-optimal problem, its status and the cause, and gives at least 2
  options.

## Assumptions

- MATLAB R2026a Update 3 is the reference; R2024b compatibility of the parity tests is argued from the recorded
  fixtures if R2024b is not installed.
- "Installed" for the `matlab` solver means the Optimization Toolbox functions it uses are present and licensed;
  a same-named function from another vendor does not count.
- The maintainer's startup with agent mode is the main motivation; CI uses default mode and is unaffected except
  by FR-004, FR-005 and FR-008.
- The inchi `new/` helper defect stays known and unfixed; FR-002 makes it unreachable through start-up.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|---|---|---|
| US1-1, US1-4, FR-001 | `testOptimizeCbModelNLP`, `testFitC13Data` after agent start-up; a start-up test asserting solver status | `initCobraToolbox` (agent mode) |
| US1-2, FR-002 | `testGetMolecularWeight` after agent start-up; path assertion | `initCobraToolbox` (agent mode) |
| US1-3, FR-004 | `testFitC13Data` where an NLP solver exists | — (test defect) |
| US2-1–US2-4, FR-005, SC-003 | `testExtractBondSubgraphs`, `testClassifySubgraphIsomorphism` | `extractBondSubgraphs`, `classifySubgraphIsomorphism` |
| US3-1–US3-3, FR-006, FR-007, SC-006 | `testEcosystemToy`; diagnosis note | `src/analysis/ecosystem/` |
| US4-1, US4-2, FR-008, SC-005 | start-up in a temporary linked worktree | `initCobraToolbox` (git detection) |
| FR-003, FR-010, SC-004 | fast-mode suite after both modes vs `develop` | — |
| SC-002 | timed agent start-up | `initCobraToolbox` |
