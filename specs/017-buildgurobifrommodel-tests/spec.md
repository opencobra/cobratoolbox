# Feature Specification: Characterize buildGurobiProblemFromModel

**Feature Branch**: `017-buildgurobifrommodel-tests`

**Created**: 2026-08-17

**Status**: Draft

**Input**: User description: "write the test function for buildGurobiFromModel function based on the cobratoolbox standards for the tests and guidelines. Follow the COBRA Toolbox documentation convention"

<!--
  CHARACTERIZATION MODE: this feature back-fills a test for an EXISTING untested
  function (Constitution Principle III, "Characterization: Legacy Back-Fill Mode").
  The "Existing Contract" section below captures CURRENT behaviour — existing
  inputs, outputs, invariants, tolerances — instead of net-new requirements. The
  Functional Requirements describe the test's assertions of that existing contract,
  not new capabilities.
-->

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Native-Gurobi field mapping gains coverage (Priority: P1)

A maintainer runs the suite and a new characterization test exercises
`buildGurobiProblemFromModel`, asserting that the COBRA model is translated into a
struct with the exact native Gurobi field names and values the function currently
produces — so a small but easy-to-silently-break translation layer (the one
`solveCobraLP.m`'s `'gurobi'` case itself relies on) is now guarded by CI instead of
being verified only by chance when someone happens to run a Gurobi-backed solve.

**Why this priority**: This is the entire feature — `buildGurobiProblemFromModel` has
zero test coverage today; pinning its field mapping is the concrete deliverable.

**Independent Test**: Add the test under `test/verifiedTests/base/testSolvers/`, run
it via the test harness, and confirm it passes, exercising every output field
(`A`, `obj`, `rhs`, `lb`, `ub`, `sense`, `modelsense`) against values derived
independently from `buildOptProblemFromModel`'s own (already-characterized) output.

**Acceptance Scenarios**:

1. **Given** a small, fixed toy COBRA model, **When**
   `buildGurobiProblemFromModel(model)` is called, **Then** the returned struct
   contains exactly the fields `A`, `obj`, `rhs`, `lb`, `ub`, `sense`, `modelsense`,
   and `A`, `obj`, `rhs`, `lb`, `ub` equal the model's stoichiometric matrix,
   objective, right-hand side, and bounds (as full/dense arrays for `obj`, `rhs`,
   `lb`, `ub`) exactly as produced by `buildOptProblemFromModel`.
2. **Given** the toy model is a maximization problem (`osenseStr = 'max'`), **When**
   the function is called, **Then** `modelsense` equals `'max'`.
3. **Given** a toy model built with `osenseStr = 'min'`, **When** the function is
   called, **Then** `modelsense` equals `'min'`.

---

### User Story 2 - Constraint-sense translation is pinned (Priority: P1)

A maintainer confirms that every constraint-sense case COBRA supports (`'E'`, `'L'`,
`'G'`) is translated to the corresponding native Gurobi character (`'='`, `'<'`,
`'>'`), since this row-by-row translation is the part of the function most likely to
silently regress (e.g. an inverted comparison or a dropped default).

**Why this priority**: Sense translation is the single most solver-behavior-critical
piece of this function — a wrong sense flips a constraint direction and yields a
wrong or infeasible optimization without an obvious symptom.

**Independent Test**: Can be tested by building a toy model whose `csense` includes
`'E'`, `'L'`, and `'G'` rows in the same call and asserting the returned `sense`
vector matches `'='`, `'<'`, `'>'` per row, in row order.

**Acceptance Scenarios**:

1. **Given** a toy model with `csense = ['E'; 'L'; 'G']`, **When**
   `buildGurobiProblemFromModel(model)` is called, **Then** `gurobiModel.sense`
   equals `['=' ; '<' ; '>']` in the same row order.
2. **Given** a toy model whose `csense` is all `'E'` (the common case), **When** the
   function is called, **Then** every entry of `gurobiModel.sense` equals `'='`
   (the unconditional default that the `'L'`/`'G'` branches would otherwise
   overwrite).

---

### User Story 3 - Optional verification path behaves as documented (Priority: P3)

A maintainer confirms the documented `verify` optional argument: omitted or `false`
skips model verification (current default behaviour), while `true` on a structurally
invalid model reproduces the function's existing error behaviour rather than
returning a malformed struct silently.

**Why this priority**: Lowest priority because `verify` is a secondary,
already-documented optional argument; the primary contract is the field mapping
(User Stories 1-2).

**Independent Test**: Can be tested by calling the function once with `verify`
omitted and once with `verify = true` on the same valid toy model and asserting
identical output, then calling it with `verify = true` on a structurally invalid
model and asserting it errors.

**Acceptance Scenarios**:

1. **Given** a structurally valid toy model, **When**
   `buildGurobiProblemFromModel(model)` (verify omitted) and
   `buildGurobiProblemFromModel(model, true)` are both called, **Then** the two
   returned structs are identical.
2. **Given** a structurally invalid model (fails `verifyModel`), **When**
   `buildGurobiProblemFromModel(model, true)` is called, **Then** it throws an error
   (the existing pass-through from `buildOptProblemFromModel`'s `verify` path)
   instead of returning a struct.

### Edge Cases

- A model whose `csense` is entirely `'E'` must still produce a fully-populated
  `sense` vector via the unconditional default assignment, not leave it empty.
- `obj`, `rhs`, `lb`, `ub` must be returned as full (dense) arrays even when the
  intermediate `optProblem` fields are sparse or of an integer/logical class
  (the function applies `full(double(...))` / `full(...)`).
- `osense` values other than exactly `-1` (i.e. `1`, the minimization case) must map
  to `modelsense = 'min'`, confirming the function's `if/else` (not a lookup table)
  handles the two-valued case correctly.
- `verify = true` on an invalid model must error before returning any struct — no
  partially-built `gurobiModel` should be observable.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A new test under `test/verifiedTests/base/testSolvers/` MUST call
  `buildGurobiProblemFromModel` on a small, fixed toy COBRA model and assert the
  returned struct's field set is exactly `{A, obj, rhs, lb, ub, sense, modelsense}`.
- **FR-002**: The test MUST assert `A`, `obj`, `rhs`, `lb`, `ub` equal the values
  independently derivable from `buildOptProblemFromModel(model)` (`A`↔`A`,
  `obj`↔`full(double(c))`, `rhs`↔`full(b)`, `lb`↔`full(lb)`, `ub`↔`full(ub)`) using
  exact equality (`isequal`), not a tolerance, since the toy model uses exact
  numeric values and the mapping performs no floating-point computation.
- **FR-003**: The test MUST assert the constraint-sense translation for all three
  COBRA `csense` values in one model (`'E'`→`'='`, `'L'`→`'<'`, `'G'`→`'>'`), in row
  order, plus the all-`'E'` default case.
- **FR-004**: The test MUST assert `modelsense` equals `'max'` when the toy model's
  `osense` resolves to `-1` and `'min'` when it resolves to `1`.
- **FR-005**: The test MUST assert that the optional `verify` argument, when omitted
  vs. explicitly `false` vs. explicitly `true` on a valid model, produces identical
  output, and that `verify = true` on a structurally invalid model raises an error
  rather than returning a struct.
- **FR-006**: The feature MUST NOT modify `buildGurobiProblemFromModel`,
  `buildOptProblemFromModel`, or any other `src` function, scientific result, or
  public interface (Constitution Principle III: characterization test only).
- **FR-007**: The test MUST NOT require a Gurobi solver license or installation to
  run — `buildGurobiProblemFromModel` never invokes the `gurobi()` solver call
  itself, so the test constructs the struct and asserts on it directly, without a
  `prepareTest` solver requirement, matching the sibling
  `testBuildOptProblemFromModel.m` pattern.
- **FR-008**: The test file MUST follow the COBRA Toolbox test template
  (documentation/source/guides/testGuide.rst): a `% The COBRAToolbox: <name>.m`
  header with Purpose/Authors blocks, save-and-restore of the current directory via
  `cd(fileparts(which(...)))` / `cd(currentDir)`, and `assert()`-based checks only
  (no pass/fail counters).

### Key Entities

- **Toy COBRA model**: a small, hand-built model struct (rxns, mets, `S`, `lb`,
  `ub`, `c`, `b`, `csense`, `osenseStr`) used as the fixed input, analogous to the
  `buildToyModel()` helper in `testBuildOptProblemFromModel.m`.
- **optProblem**: the intermediate struct produced by `buildOptProblemFromModel`,
  used as the independent reference for the field-mapping assertions (not
  re-derived by hand, since its own mapping is already characterized separately).
- **gurobiModel**: the struct under test — the native-Gurobi-shaped output of
  `buildGurobiProblemFromModel` (`A`, `obj`, `rhs`, `lb`, `ub`, `sense`,
  `modelsense`).

## Existing Contract *(characterization mode)*

- **Function(s) under test**: `src/base/solvers/gurobi/buildGurobiProblemFromModel.m`
- **Current inputs / arities**: `gurobiModel = buildGurobiProblemFromModel(model, verify)`.
  `model` is required (a COBRA model struct accepted by `buildOptProblemFromModel`,
  minimally `.S`, `.c`, `.lb`, `.ub`, plus whatever `buildOptProblemFromModel` needs
  to resolve `.b`, `.csense`, `.osense`). `verify` is optional logical, defaulting to
  `false` when omitted (`~exist('verify','var')` branch).
- **Current outputs**: a struct `gurobiModel` with exactly the fields `A` (=
  `optProblem.A`, unchanged sparsity), `obj` (= `full(double(optProblem.c))`), `rhs`
  (= `full(optProblem.b)`), `lb`/`ub` (= `full(optProblem.lb)`/`full(optProblem.ub)`),
  `sense` (char column vector: defaults to `'='` for every row, then rows are
  overwritten to `'<'` where `csense == 'L'` and `'>'` where `csense == 'G'`), and
  `modelsense` (`'max'` iff `optProblem.osense == -1`, else `'min'`).
- **Invariants & expected results**: the function is a pure, deterministic struct
  translation with no randomness and no solver invocation — for a fixed toy model
  the output is exactly reproducible, so assertions use exact equality (`isequal`),
  no numeric tolerance is needed, and no random seed applies.
- **Coverage gap**: a repository-wide search (`grep -rli buildgurobifrommodel`)
  finds no reference to `buildGurobiProblemFromModel` anywhere under `test/`; the
  function was added in commit `03415118f` ("Adding testing functions and fixing
  the CI license") without an accompanying test.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After the feature, `buildGurobiProblemFromModel` — previously at zero
  test coverage — is exercised by a passing test, verifiable by CI coverage tooling.
- **SC-002**: All seven output fields (`A`, `obj`, `rhs`, `lb`, `ub`, `sense`,
  `modelsense`) are asserted with concrete expected values for at least one toy
  model exercising all three `csense` values and both `osense` values; no
  placeholder or no-op assertions.
- **SC-003**: The test runs to completion in a CI environment that has no Gurobi
  license installed, because the function under test never calls the Gurobi solver.
- **SC-004**: The test completes in well under one second (a toy model with a
  handful of reactions/metabolites and no optimization call).
- **SC-005**: No `src` file changes; no previously-passing test regresses.
- **SC-006**: The `verify = true` error path is exercised and confirmed to raise an
  error rather than return a struct, matching current behaviour.

## Assumptions

- `buildOptProblemFromModel`'s own model→LP-problem mapping is already
  characterized by `testBuildOptProblemFromModel.m`; this feature scopes
  itself to the additional native-Gurobi renaming/sense-translation layer that
  `buildGurobiProblemFromModel` adds on top, using `buildOptProblemFromModel`'s
  output as the reference rather than re-deriving it from the raw model.
- A small, hand-built toy model (mirroring the `buildToyModel()` helper already used
  by the sibling test) is sufficient; no genome-scale model is required since the
  transformation under test is purely structural, not scientific.
- The function requires no installed Gurobi solver license to execute, despite
  living in `src/base/solvers/gurobi/` and `test/verifiedTests/base/testSolvers/` —
  it only builds the struct that would be passed to `gurobi()`, it never calls it.
- The new test file lives alongside
  `test/verifiedTests/base/testSolvers/testBuildOptProblemFromModel.m`
  and is auto-discovered by `test/testAll.m`'s recursive scan of `verifiedTests/`
  (no manual registration step).

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, FR-002, FR-008 | test/verifiedTests/base/testSolvers/testBuildGurobiProblemFromModel.m | src/base/solvers/gurobi/buildGurobiProblemFromModel.m |
| US1 / FR-004 | test/verifiedTests/base/testSolvers/testBuildGurobiProblemFromModel.m | src/base/solvers/gurobi/buildGurobiProblemFromModel.m |
| US2 / FR-003 | test/verifiedTests/base/testSolvers/testBuildGurobiProblemFromModel.m | src/base/solvers/gurobi/buildGurobiProblemFromModel.m |
| US3 / FR-005, SC-006 | test/verifiedTests/base/testSolvers/testBuildGurobiProblemFromModel.m | src/base/solvers/gurobi/buildGurobiProblemFromModel.m |
| SC-001, SC-003, SC-004, FR-007 | test/verifiedTests/base/testSolvers/testBuildGurobiProblemFromModel.m | src/base/solvers/gurobi/buildGurobiProblemFromModel.m |
| SC-005, FR-006 | — (no source function; verified by `git diff` showing no `src` changes) | — (no source function) |
