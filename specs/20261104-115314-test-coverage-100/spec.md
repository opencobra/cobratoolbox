# Feature Specification: Bring every test to 100% line coverage of its function (or documented exemptions)

**Feature Branch**: `20261104-115314-test-coverage-100` (from `upstream/develop` at 56dcc3064)

**Created**: 2026-11-04

**Status**: Draft

**Input**: User description: "Use speckit. and for all the current tests in testAll in the COBRA Toolbox develop branch make their code coverage 100 with respect to exeptions in the constitution. Naturally we cannot make the code coverage 100% for all the tests, the exemptions are listed in constitution"

This feature applies Constitution III-Coverage ("Every test file MUST aim for 100% line coverage
of the single function it tests. A line that cannot be reached (unavailable solver or toolbox,
GUI, OS-specific branch) is permitted to stay uncovered ONLY when the test file header documents
the exemption: the line number(s) and the reason.") together with III-Defects (lines left
uncovered because a defective input is skipped are listed as exemptions) and
III-Characterization (tests pin existing behaviour; no source function changes).

## Scope

`test/testAll.m` runs every `test*.m` under `test/verifiedTests/` (605 files on develop
56dcc3064). Each test is mapped to its function under test:

- 309 tests name it in a "Function under test:" header;
- 218 tests follow `test<Name>.m` → `<name>.m` with exactly one match in `src/`;
- 78 tests have no single function under test (legacy tests that exercise several functions or
  a feature, e.g. `testGPRLogic`, `testDuals`, `testReadWriteCbModel`). III-Coverage is defined
  per single function, so these are listed and left out of scope; splitting them into
  one-function tests is a separate feature (III-Naming).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Coverage inventory (Priority: P1)

A maintainer can see, for every mapped test, whether it runs on the reference machine, its line
coverage of the function under test, the missed lines, and whether every missed line is
documented as an exemption.

**Independent Test**: the inventory lists all 527 mapped tests with one status each:
COMPLETE (100%, or every missed line documented), GAP (undocumented missed lines), SKIPPED
(requirements unmet on the reference machine: solver, toolbox, OS), FAILING (the test fails
before any change in this feature), plus the 78 out-of-scope tests.

### User Story 2 - Close the gaps (Priority: P1)

For every GAP test, each undocumented missed line is either covered by a new test section that
reaches it, or documented in the header as an exemption with one of the constitution's reasons
(unavailable solver or toolbox, GUI, OS-specific branch, defective input skipped per
III-Defects, or a line that cannot be reached by any input — dead code — stated as such).

**Independent Test**: after the work, re-measuring the test gives 100% or every missed line is
listed under "Coverage exemptions" with a reason; the test still passes.

**Acceptance Scenarios**:

1. **Given** a GAP test, **When** it is updated, **Then** its existing assertions are unchanged
   and pass, new sections are independent (`%%` sections that run alone), and its coverage is
   100% or fully documented.
2. **Given** a missed line reachable only with a defective input, **When** found, **Then** the
   defect is recorded per III-Defects and the line listed as an exemption.
3. **Given** a missed line reachable only with a solver or toolbox missing on the reference
   machine, **When** found, **Then** it is listed as an exemption naming the solver/toolbox.

### User Story 3 - Tests that cannot be measured here (Priority: P2)

SKIPPED and FAILING tests are reported with the reason, so they can be completed on an
installation that has the requirement (e.g. CPLEX) or after the failure is fixed.

### Edge Cases

- A test whose function is a script or class: measure the file as given; class methods count.
- A missed line inside an `if 0`/debug block: dead code, documented.
- A test that takes very long: measured once; no runtime limit (III-Coverage).
- Tests that leave state (pools, globals, path): unchanged by this feature unless the new
  section would otherwise interfere; then the new section restores state.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Coverage is measured per test by running the whole test script once (as
  `testAll` does) with MATLAB's code-coverage plugin restricted to the function under test,
  on MATLAB R2025a with Gurobi; executable lines and hits come from the Cobertura report.
- **FR-002**: The inventory (`coverage-inventory.md`, generated) lists per test: function,
  status, covered/total, missed lines, documented exemption lines, undocumented missed lines.
- **FR-003**: For each GAP test, undocumented missed lines are covered by new sections or
  documented as exemptions with an allowed reason; nothing else in the test changes.
- **FR-004**: No file under `src/` changes; defects found are recorded per III-Defects and the
  registry is regenerated.
- **FR-005**: New sections follow III-Coverage (tier, readability, memory) and the test's tier
  (no solver in Tier 1/2 tests; a Tier 3 section may use the solvers the test already declares).
- **FR-006**: Every changed test passes on the reference machine; tests that cannot run here
  are not changed by guesswork.
- **FR-007**: Work proceeds in batches by source domain; each batch is committed with the
  maintainer identity (no co-author line), only feature files staged, and pushed.
- **FR-008**: A final re-measurement updates the inventory; the receipt reports counts per
  status before and after.

### Key Entities

- **Mapped test**: test file, function under test, mapping source (header or name).
- **Coverage record**: status, covered/total, missed lines, documented and undocumented lines.
- **Exemption**: line numbers and reason, in the test header.

## Success Criteria *(mandatory)*

- **SC-001**: 100% of the 527 mapped tests appear in the inventory with a status.
- **SC-002**: 0 GAP tests remain among tests that run on the reference machine (each is 100% or
  fully documented).
- **SC-003**: 100% of changed tests pass; 0 `src/` files change.
- **SC-004**: Every SKIPPED or FAILING test is reported with its reason.

## Assumptions

- The reference machine is a maintainer workstation; which requirements it lacks shows in the
  SKIPPED table of the inventory.
  Tests needing those are SKIPPED here.
- "Line coverage" means executable lines as reported by MATLAB's coverage tooling.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, FR-002 | `tools/measure_coverage` + `coverage-inventory.md` | — (no source function) |
| US2 / FR-003..FR-006 | each updated `test<Name>.m` | its function under test |
| US3 / SC-004 | inventory SKIPPED/FAILING sections | — (no source function) |
