# Feature Specification: Tier-2 test pilot (ten model-manipulation functions)

**Feature Branch**: `20261102-142225-tier2-test-pilot` (stacked on `20261102-140321-tier1-safe-defect-fixes`)

**Created**: 2026-11-02

**Status**: Draft

**Input**: User description: "Start Tier-2 test coverage (Constitution III-Coverage, Tier 2 = model manipulation, no solver) with a pilot batch of ten untested model-manipulation functions: extractSubSysModel, extractCompModel, keepCompartment, orderModelFields, updateFieldOrderForType, removeCompartments, createEmptyFields, convertOldCouplingFormat, findRxnFromCompartment, findMetFromCompartment. One characterization test per function, models loaded with getDistributedModel, structural-consistency assertions (sizes and mutual agreement of S, rxns, mets, genes, rules, rxnGeneMat), defects recorded per III-Defects, then stop for maintainer review of the Tier-2 style before the next batch."

This is a CHARACTERIZATION feature under Constitution Principle III (III-Characterization). It
applies III-Coverage (Tier 2: model manipulation, no solver; Tier 4: models obtained through
`getDistributedModel`; Tier 5: first-run reference values stated as such), III-Naming (one
`test<FunctionName>.m` per function) and III-Defects (a defect found while testing is recorded in
the header and skipped, never asserted; every test passes). It changes no `src` file.

## Why now

Tier 1 is complete for plain-data functions, and the safe Tier-1 defects were fixed by feature
20261102-140321-tier1-safe-defect-fixes. Its impact analysis showed that no known defect can
silently change a Tier-2 result (`attention-defects.md` of that feature), so Tier-2 reference
values can now be recorded. This pilot fixes the Tier-2 test style on ten small functions before
the remaining model-manipulation functions are covered.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ten model-manipulation functions are pinned (Priority: P1)

A maintainer can change any of the ten functions and learn from CI whether the structure of the
model it returns changed.

**Why this priority**: these functions have no test today; model manipulation underlies most
analyses.

**Independent Test**: each of the ten tests passes through the harness runner and reaches 100%
line coverage of its function, or documents every uncovered line.

**Acceptance Scenarios**:

1. **Given** a selected function, **When** its test runs, **Then** it loads its model(s) through
   `getDistributedModel` once, calls the function on each meaningful input/arity, and asserts the
   structural consistency of the result: sizes of `S`, `rxns`, `mets`, `genes`, `rules`,
   `rxnGeneMat` and of every field of the same type agree, and the content of the result agrees
   with the input model (selected reactions/metabolites present, others absent, values carried
   over unchanged).
2. **Given** a result whose exact counts have no independent reference, **When** the test is
   written, **Then** the counts from the first run are recorded as reference constants and the
   header states they guard consistency, with date and model (Tier 5).
3. **Given** a defect found while writing a test, **When** it is found, **Then** it is recorded in
   the header in the III-Defects format, the input is skipped, the uncovered lines are listed as
   exemptions, and the test passes.

---

### User Story 2 - The Tier-2 style is reviewed before the next batch (Priority: P1)

**Independent Test**: the pilot ends with a short style note for the maintainer (model choice,
assertion pattern, runtime, memory) and work stops; no further Tier-2 batch starts in this
feature.

**Acceptance Scenarios**:

1. **Given** the ten tests, **When** they are complete, **Then** the style note lists the pattern
   used, the per-test runtime, and open questions for the maintainer.

---

### User Story 3 - The registry reflects new defects (Priority: P2)

**Independent Test**: after the tests are written the registry is regenerated; the generator exits
0 and lists any defect recorded by the pilot.

### Edge Cases

- A function that needs a field the distributed model lacks (for example old-style coupling
  `A`): the test derives the input from the loaded model (adds or renames fields) instead of
  loading another model.
- A function that prints or warns: output is not suppressed (VII-A/VII-B) and is documented.
- A branch reachable only with a solver, file or GUI: the line is listed as an exemption with the
  reason; no solver is used.
- A function whose probe shows it needs a solver or a file: dropped from the pilot and reported.
- A large model would be needed to reach a branch: the smallest distributed model that reaches it
  is used and the header says why.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Exactly one test file per selected function, named per III-Naming, in the folder of
  the selection table, run by `test/testAll.m`.
- **FR-002**: Each test declares Tier 2 in its header, opens with `prepareTest()` after the
  `cd(fileDir)` lines (no solver, toolbox or OS requirement), and loads models only through
  `getDistributedModel`, each model once per file.
- **FR-003**: Assertions check structural consistency (sizes and mutual agreement of `S`, `rxns`,
  `mets`, `genes`, `rules`, `rxnGeneMat` and fields of the same type) and content agreement with
  the input model; equality only for discrete values; floating-point comparisons with a
  justified tolerance; expected errors with `verifyCobraFunctionError` wrapped in `assert`.
- **FR-004**: First-run reference values are marked in the header with date, model and solver
  ("none"), per Tier 5.
- **FR-005**: Each test aims at 100% line coverage of its function; every uncovered line is listed
  with its reason.
- **FR-006**: A defect is never asserted and the function is never changed (III-Defects); every
  test passes.
- **FR-007**: Tests are memory efficient (one model load per file, large variables cleared, no
  model copies beyond what an assertion needs), create no files, leave no global state, and do
  not suppress output.
- **FR-008**: No file under `src/` changes.
- **FR-009**: The known-defects registry is regenerated after the tests are written.
- **FR-010**: Work stops after the ten tests with a style note for maintainer review.
- **FR-011**: Commits use the maintainer identity with no co-author line and contain only this
  feature's files; the branch is pushed to the maintainer's fork.
- **FR-012**: The contributor reports files changed, checks run, tests passed or failed, coverage
  per function, functions dropped with reasons, and writes the implementation receipt.

### Key Entities

- **Selected function**: source function, test file, test folder, model(s) used.
- **Reference value**: a first-run count or value with date and model.
- **Defect entry**: a III-Defects entry in a test header.

## Existing Contract *(characterization mode)*

- **Function(s) under test**: the ten functions in the selection table.
- **Current inputs / outputs**: as in each source function's header; recorded by the probe.
- **Invariants & expected results**: structural consistency as in FR-003; counts from the first
  run (Tier 5).
- **Coverage gap**: none of the ten function names appears in any file under `test/` (scan of
  2026-11-02 over all functions whose first argument is a model and whose code calls no solver,
  file, plot or network function).

### Selection

| # | Source function | Test file | Test folder | Code lines |
|---|-----------------|-----------|-------------|-----------:|
| 1 | `src/reconstruction/refinement/extractSubSysModel.m` | `testExtractSubSysModel.m` | `test/verifiedTests/reconstruction/testModelManipulation/` | 5 |
| 2 | `src/reconstruction/refinement/extractCompModel.m` | `testExtractCompModel.m` | `test/verifiedTests/reconstruction/testModelManipulation/` | 37 |
| 3 | `src/reconstruction/refinement/keepCompartment.m` | `testKeepCompartment.m` | `test/verifiedTests/reconstruction/testModelManipulation/` | 30 |
| 4 | `src/reconstruction/refinement/orderModelFields.m` | `testOrderModelFields.m` | `test/verifiedTests/reconstruction/testModelManipulation/` | 11 |
| 5 | `src/reconstruction/refinement/updateFieldOrderForType.m` | `testUpdateFieldOrderForType.m` | `test/verifiedTests/reconstruction/testModelManipulation/` | 31 |
| 6 | `src/reconstruction/modelGeneration/removeCompartments.m` | `testRemoveCompartments.m` | `test/verifiedTests/reconstruction/testModelGeneration/` | 83 |
| 7 | `src/base/io/utilities/createEmptyFields.m` | `testCreateEmptyFields.m` | `test/verifiedTests/base/testIO/testUtilities/` | 65 |
| 8 | `src/base/io/utilities/convertOldCouplingFormat.m` | `testConvertOldCouplingFormat.m` | `test/verifiedTests/base/testIO/testUtilities/` | 35 |
| 9 | `src/analysis/exploration/findRxnFromCompartment.m` | `testFindRxnFromCompartment.m` | `test/verifiedTests/analysis/testExploration/` | 7 |
| 10 | `src/analysis/exploration/findMetFromCompartment.m` | `testFindMetFromCompartment.m` | `test/verifiedTests/analysis/testExploration/` | 13 |

Folders follow the sibling convention (the folder that holds most tests of the function's source
folder). Code lines count non-comment lines.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 10 of 10 functions have a passing test, or each one not covered is reported with the
  reason it is not Tier 2.
- **SC-002**: Each test reaches 100% line coverage of its function or lists every uncovered line.
- **SC-003**: Every test loads each model at most once and uses no solver.
- **SC-004**: The registry tool exits successfully after regeneration.
- **SC-005**: The diff contains no file under `src/`.

## Assumptions

- `ecoli_core_model` (two compartments, subsystems, genes and rules) reaches every branch of most
  of the ten functions; a larger distributed model is used only when a branch needs it.
- Tier-2 tests may take longer than Tier-1 tests; there is no CI time budget (III-Coverage).
- Defects known from the attention document of the previous feature are not re-documented unless
  the test reaches them.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001..FR-007 | the ten `test<Function>.m` files of the selection table | the ten functions of the selection table |
| US2 / FR-010 | `style-note.md` in this feature folder | — (no source function) |
| US3 / FR-009 | `python3 .github/scripts/known_defects.py` | — (no source function) |
| FR-008 / SC-005 | `git diff --name-only` against the base, no `src/` path | — (no source function) |
| FR-011 | `git log` author and message check | — (no source function) |
