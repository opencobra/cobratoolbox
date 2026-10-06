# Feature Specification: Tier-1 test coverage pilot (5 functions)

**Feature Branch**: `025-tier1-test-pilot`

**Created**: 2026-10-06

**Status**: Draft

**Input**: User description: "Characterization feature (Constitution III-Characterization + III-Coverage, Tier 1 pilot): add one test file per function for getDefaultValue, getIDPositions, verifyRuleSyntax, getMetAbbr and extendIndicesInDimenion, aiming for 100% line coverage with documented exemptions. Source functions must not be changed; defects are documented only. The user validates these 5 tests before scaling."

This is a CHARACTERIZATION feature under Constitution Principle III
(III-Characterization), and the first application of III-Coverage and III-Naming. It
pins the EXISTING behaviour of five untested functions. It changes no `src` file.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Pin type-dispatch and ID-lookup helpers (Priority: P1)

A maintainer wants `getDefaultValue` and `getIDPositions` protected by fast tests so that
any later change to their branching is caught immediately.

**Why this priority**: These are the simplest of the five. They are pure branching and
validate the pilot approach (header, tier declaration, sections) at the lowest cost.

**Independent Test**: Run `testGetDefaultValue` and `testGetIDPositions` on their own.
Each passes on the current source and reaches every executable line.

**Acceptance Scenarios**:

1. **Given** values of each supported type (numeric of several classes and shapes,
   string, char, logical, nested cell), **When** `getDefaultValue` is called, **Then** the
   result has the documented default (NaN of the same class and size, empty
   string/char, false of the same size, recursive default per cell element).
2. **Given** a hand-built model struct, **When** `getIDPositions` is called with base
   field `rxns` or `mets`, **Then** positions and presence flags are correct both without
   and with the extra `evars`/`ctrs` fields (which are appended after `rxns`/`mets`).
3. **Given** a generic cellstr field, **When** `getIDPositions` is called with that
   field, **Then** positions are looked up in it; **and given** a missing or non-cellstr
   field, **Then** the documented error is raised.

---

### User Story 2 - Pin string-parsing helpers (Priority: P2)

A maintainer wants `getMetAbbr` and `verifyRuleSyntax` protected, including their
input-shape variants and the stateful retry behaviour of `verifyRuleSyntax`.

**Why this priority**: Regex- and eval-based, so richer edge cases, but still no model.

**Independent Test**: Run `testGetMetAbbr` and `testVerifyRuleSyntax` on their own.

**Acceptance Scenarios**:

1. **Given** a single char ID and a cell array of IDs of the form `abbr[c]`,
   **When** `getMetAbbr` is called, **Then** char input returns char outputs, cell input
   returns column cells, and the unique list is sorted and de-duplicated.
2. **Given** an empty rule, a valid rule, a syntactically invalid rule, and a valid rule
   referencing an index above the function's initial persistent capacity, **When**
   `verifyRuleSyntax` is called, **Then** it returns `true`, `true`, `false`, `true`
   respectively, and every test case starts from a cleared function state so order does
   not matter.

---

### User Story 3 - Pin array-extension helper including its failure path (Priority: P3)

A maintainer wants `extendIndicesInDimenion` protected for numeric/cell arrays, tables,
and its failure path.

**Why this priority**: Includes a catch branch that prints to the console, so needs the
exemption/handling pattern the constitution requires.

**Independent Test**: Run `testExtendIndicesInDimenion` on its own.

**Acceptance Scenarios**:

1. **Given** arrays extended in dimension 1 and 2 and a table, **When** the function is
   called, **Then** the new entries hold the given value and the original entries are
   unchanged.
2. **Given** a value class that cannot be assigned into the input, **When** the function
   is called, **Then** it raises its documented error (verified with
   `verifyCobraFunctionError`).

---

### Edge Cases

- `getDefaultValue` with an unsupported type (struct, function handle): the source has no
  matching branch, `defValue` is never assigned, and MATLAB raises an error. This is
  documented as an existing defect, asserted as current behaviour, and NOT fixed.
- `getDefaultValue` with empty inputs, 2-D arrays, and nested/empty cells.
- `getIDPositions` with IDs not present (position 0, presence false) and with duplicate IDs.
- `verifyRuleSyntax` persistent state: results MUST NOT depend on test order.
- `extendIndicesInDimenion` with `sizeIncrease = 0` and the error text printed by the
  catch block (console noise, see exemption below).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The feature MUST add exactly one test file per function, named per
  III-Naming: `testGetDefaultValue.m`, `testGetIDPositions.m`, `testVerifyRuleSyntax.m`,
  `testGetMetAbbr.m`, `testExtendIndicesInDimenion.m`, each under
  `test/verifiedTests/<category>/` matching its source domain and running within
  `test/testAll.m`.
- **FR-002**: Each test MUST aim for 100% line coverage of its function (III-Coverage);
  any uncovered line MUST be listed with its reason in the test header.
- **FR-003**: Each test MUST declare "Tier 1" in its header and use only hand-built inputs:
  no genome-scale model, no solver, no `prepareTest` requirement beyond none needed.
- **FR-004**: Each test header MUST state purpose, tier, function under test, coverage
  exemptions, and authors/date. The body MUST use a `%%` section per behaviour or branch
  with a comment on each assertion group.
- **FR-005**: Assertions MUST be `assert`-based; exact equality only for discrete values;
  expected-failure paths MUST use `verifyCobraFunctionError`. No floating-point tolerance
  is expected since all outputs are discrete or NaN, and any use MUST be justified.
- **FR-006**: Tests MUST be memory efficient (small hand-built inputs, no copies of large
  data, large variables cleared) and print nothing to the console beyond what the
  function itself emits, which MUST be documented.
- **FR-007**: Tests MUST NOT modify any `src` file or leave artifacts on disk. Defects found
  are documented in the test header and in the test's final report only.
- **FR-008**: `verifyRuleSyntax` tests MUST clear the function's persistent state before
  each case.
- **FR-009**: The contributor MUST report files changed, checks run, tests passed/failed,
  and behaviours not yet verified (Principle III), and the pilot MUST pause for user
  validation before any further function is added.

### Key Entities

- **Test file**: one per function; a header plus sections of assertions.
- **Coverage exemption**: a header entry naming an uncovered line and its reason.

## Existing Contract *(characterization mode)*

- **Function(s) under test**:
  `src/base/utilities/getDefaultValue.m`, `src/reconstruction/refinement/getIDPositions.m`,
  `src/reconstruction/modelGeneration/modelVerification/verifyRuleSyntax.m`,
  `src/reconstruction/refinement/getMetAbbr.m`, `src/base/utilities/extendIndicesInDimenion.m`
- **Current inputs / arities**: `defValue = getDefaultValue(value)`;
  `[pos, pres] = getIDPositions(model, ids, basefield)`; `tf = verifyRuleSyntax(ruleString)`;
  `[metAbbr, uniqueMetAbbrs] = getMetAbbr(mets)`;
  `added = extendIndicesInDimenion(input, dimension, value, sizeIncrease)`.
- **Current outputs**: as above; `getMetAbbr` returns column cells (char for char input);
  `getIDPositions` returns `ismember` outputs on `rxns[;evars]`, `mets[;ctrs]`, or the
  named field; `extendIndicesInDimenion` prints diagnostics then errors on class mismatch.
- **Invariants & expected results**: discrete values and NaN only, so no numeric tolerance.
  Expected values are derived by reading the source (independent derivation), not by
  recording output, except where noted in the test.
- **Coverage gap**: none of the five functions is referenced by any existing test.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All 5 test files exist, are named per III-Naming, and pass on the unmodified
  source.
- **SC-002**: Each test reaches 100% of the executable lines of its function, or the
  header documents every uncovered line; measured by a line-coverage report per function.
- **SC-003**: `git diff` shows zero changes under `src/`.
- **SC-004**: Each of the 5 tests runs in under 5 seconds and creates no files.
- **SC-005**: A reviewer can identify purpose, tier, and exemptions of each test from its
  first screen of text, without reading the source function.
- **SC-006**: The user validates the 5 tests before further batches are specified.

## Assumptions

- Test location by domain: base utilities tests under `test/verifiedTests/base/testTools/`
  (to be confirmed in the plan); reconstruction tests under
  `test/verifiedTests/reconstruction/testModelManipulation/` or a sibling folder (plan).
- A MATLAB session with the toolbox initialized is available to run and measure coverage.
- Line coverage can be measured per function with MATLAB's coverage tooling or MoCov.
- `getIDPositions` and `verifyRuleSyntax` behaviours are taken from the current source;
  `verifyRuleSyntax` uses `eval`, whose result depends on the persistent array `x`.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001..008 (type dispatch) | testGetDefaultValue (test/verifiedTests/base/) | src/base/utilities/getDefaultValue |
| US1 / FR-001..008 (ID lookup) | testGetIDPositions (test/verifiedTests/reconstruction/) | src/reconstruction/refinement/getIDPositions |
| US2 / FR-001..008, FR-008 (rule syntax) | testVerifyRuleSyntax (test/verifiedTests/reconstruction/) | src/reconstruction/modelGeneration/modelVerification/verifyRuleSyntax |
| US2 / FR-001..008 (metabolite abbreviation) | testGetMetAbbr (test/verifiedTests/reconstruction/) | src/reconstruction/refinement/getMetAbbr |
| US3 / FR-001..008 (array extension) | testExtendIndicesInDimenion (test/verifiedTests/base/) | src/base/utilities/extendIndicesInDimenion |
