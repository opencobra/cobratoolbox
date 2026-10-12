# Feature Specification: Known-defects registry for test headers

**Feature Branch**: none (work stays on `develop`)

**Created**: 2026-10-12

**Status**: Draft

**Input**: User description: "Implement Constitution III-Defects: a standard machine-readable known-defects entry format in test headers, a generator that builds the single registry test/known-defects.md from those headers (never hand-edited), a staleness check that fails when the registry is out of date, and back-fill of all existing defect notes into the standard format."

This feature implements Constitution sub-clause III-Defects. The rules themselves (no
asserting defective behaviour, one standard entry format, one generated registry, a check
that fails when it is stale) live in the constitution and are referenced, not restated,
here. The exact entry grammar is fixed by the plan.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See every known defect in one place (Priority: P1)

A maintainer or contributor opens one file and sees every known defect found while writing
tests: which function, how severe, what goes wrong, what was expected, and which test file
documents it.

**Why this priority**: This is the point of the feature. Without the consolidated view the
defects stay buried in 55 test headers.

**Independent Test**: Generate the registry from the current test headers; confirm that every
defect listed in the batch-2 implementation receipt appears exactly once, with function,
severity, trigger, observed and expected behaviour and line numbers.

**Acceptance Scenarios**:

1. **Given** the back-filled test headers, **When** the registry is generated, **Then** it has
   a summary table (function, severity, one-line problem, test file) and a detail section per
   function.
2. **Given** a defect documented in a test header, **When** the registry is generated,
   **Then** the defect appears exactly once and links back to its test file.
3. **Given** the registry was generated twice from the same headers, **When** the two files
   are compared, **Then** they are identical.

---

### User Story 2 - Record a new defect in a standard format (Priority: P1)

A contributor who finds a defect while writing a test records it in the test header using the
standard entry format, runs the generator, and commits both together.

**Why this priority**: Without a simple, unambiguous format people will write free text that
a script cannot read, and the registry will lose entries.

**Independent Test**: Add an entry to a test header, run the generator, and see the entry in
the registry; add a malformed entry and see an error that names the file and line.

**Acceptance Scenarios**:

1. **Given** a header with a well-formed entry, **When** the generator runs, **Then** the entry
   is included.
2. **Given** a header entry with a missing field, an unknown severity, a function path that
   does not exist, or a duplicate defect title for the same function, **When** the generator
   runs, **Then** it reports each problem with the file and line and does not write a
   registry.
3. **Given** a test with no defect, **When** its header says "None found.", **Then** it
   contributes no entry and is not an error.

---

### User Story 3 - A stale registry fails the pull-request check (Priority: P2)

A reviewer relies on the automatic check to catch a registry that no longer matches the
headers, without needing MATLAB.

**Why this priority**: The registry is only trustworthy if it cannot silently drift.

**Independent Test**: On a clean tree the check passes; after hand-editing the registry, or
after editing a header entry without regenerating, the check fails with a message saying how
to fix it.

**Acceptance Scenarios**:

1. **Given** a registry that matches the headers, **When** the check runs, **Then** it passes.
2. **Given** a hand-edited registry or a changed header, **When** the check runs, **Then** it
   fails with a non-zero result and a message telling the contributor to regenerate.
3. **Given** a pull request, **When** the continuous-integration checks run, **Then** the
   check runs without MATLAB and its result is shown with the other checks.

---

### User Story 4 - Existing defect notes are brought into the standard format (Priority: P2)

All defect notes already written in the 5 pilot tests and the 50 batch-2 tests are rewritten
in the standard format so the first registry is complete.

**Why this priority**: Without the back-fill the registry would start empty or incomplete.

**Independent Test**: Compare the list of defects in the batch-2 receipt with the registry;
every one appears exactly once. All 55 tests still pass and no source file changed.

**Acceptance Scenarios**:

1. **Given** the 55 tests, **When** their headers are rewritten, **Then** no assertion and no
   source file changes, and all 55 tests pass through the harness runner.
2. **Given** the rewritten headers, **When** the registry is generated, **Then** it contains
   every defect named in the batch-2 implementation receipt that is a defect of a source
   function (calculateMetrics, calculateFoodScore, compareDiets, searcher, createBIGraph,
   numToFormattedString, getDataBases, parseSBMLAnnotationField, InitialDuplo, StopCritBDCA,
   StopCritDuplo, Combination, getInchiData, buildRxnEquationsFromName, makeColorGradient,
   combineChildren, checkInputData, editChemicalFormula, parseMetNames, getDefaultValue),
   plus the defects found when the pilot and batch-2 headers were re-read (compareConditions,
   getMetAbbr, cleanUpMetabolite_structure). Coverage exemptions that are not defects (the
   desktop-only line of hyperlink, the external converter of removeSmilesInchiKey) are not
   entries.

---

### Edge Cases

- A test documents several defects for one function: each is its own entry.
- Two tests document the same function: their entries are merged under one function section;
  an identical defect title for the same function in two files is a duplicate error.
- A header lists coverage exemptions but no defect (for example a desktop-only line): this is
  not a defect entry and does not appear in the registry.
- Entry text spans several comment lines: continuation lines belong to the previous field.
- The registry is empty (no defects anywhere): it is still generated, saying so.
- Non-test files and tests outside the verified-tests folder are ignored.
- The generator is run from any working directory: paths are resolved from the repository
  root.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Each test header MUST be able to record zero or more defects under the heading
  "Known defects documented (NOT tested, NOT fixed here):" in one standard entry format with
  the fields DEFECT, SEVERITY, TRIGGER, OBSERVED, EXPECTED and LINES (Constitution
  III-Defects). The plan fixes the exact grammar so that it is easy to write by hand in a
  comment block and unambiguous to read by a script.
- **FR-002**: A test with no defect MUST say "None found." under that heading.
- **FR-003**: A generator MUST read the "Function under test:" line and the defect entries of
  every test file in the verified-tests folder and write the registry at
  `test/known-defects.md`.
- **FR-004**: The generator MUST validate each entry: all fields present, SEVERITY one of
  wrong-result, error, unusable-option, cosmetic, limitation; the function path exists in the
  source tree; no duplicate defect title for the same function; line numbers well formed. Any
  problem MUST be reported with the file and line, and no registry is written.
- **FR-005**: The registry MUST be deterministic: stable ordering, no timestamps, identical
  output on repeated runs, independent of the working directory and file-system order.
- **FR-006**: The registry MUST contain a summary table (function, severity, one-line problem,
  test file) and a detail section per function with every field of every entry, and MUST state
  at its top that it is generated and must not be edited by hand.
- **FR-007**: The same tool MUST offer a check mode that regenerates in memory, compares with
  the file on disk, and fails with a non-zero result and a clear instruction when they differ.
- **FR-008**: The check MUST run in the pull-request continuous-integration checks without
  MATLAB, and the generator and check MUST be documented where the other CI scripts are
  documented.
- **FR-009**: All defect notes in the 5 pilot tests and the 50 batch-2 tests MUST be rewritten
  in the standard format without changing any assertion and without changing any source file.
- **FR-010**: The generator and check MUST be covered by automated tests that run in the same
  continuous-integration checks (Constitution Principle III).
- **FR-011**: The tool, registry and back-filled headers MUST NOT introduce personal
  information into the repository (names, email addresses, account names).
- **FR-012**: No file under `src/` may change.

### Key Entities

- **Defect entry**: one documented defect: title, severity, trigger, observed behaviour,
  expected behaviour, affected source lines.
- **Registry**: the single generated file listing all defect entries by function.
- **Test header**: the comment block at the top of a test file: the only source of truth.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Every defect documented in the headers of the 55 tests appears in the registry
  exactly once (29 defects in 23 functions at the time of the back-fill).
- **SC-002**: Generating the registry twice, from different working directories, produces
  byte-identical files.
- **SC-003**: The check passes on a clean tree and fails after hand-editing the registry and
  after editing a header entry without regenerating.
- **SC-004**: All 55 tests pass through the harness runner after the back-fill, and
  `git diff --stat -- src` prints nothing.
- **SC-005**: Generating or checking the registry takes under 10 seconds on the full test tree.
- **SC-006**: A contributor can write a correct entry from the format description alone: a
  deliberately malformed entry is rejected with a message naming the file and line.
- **SC-007**: No personal information appears in any file added or changed by this feature.

## Assumptions

- The generator and its automated tests are written in a language available on the
  continuous-integration runners without MATLAB; the existing CI scripts folder
  (`.github/scripts/`) is their home, consistent with the change-based test selector there.
- The registry location `test/known-defects.md` was chosen by the maintainer.
- Only the 55 tests created in features 025 and 026 are back-filled; other tests have no
  defect notes in this format and simply have no entries.
- Defect notes currently live in the "Known defects" and "Coverage exemptions" parts of the
  headers; coverage exemptions stay as they are.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-003, FR-005, FR-006, SC-001, SC-002 | automated generator tests and the back-filled registry run | — (no source function; tooling under .github/scripts/) |
| US2 / FR-001, FR-002, FR-004, SC-006 | automated generator tests (valid and malformed headers) | — (no source function) |
| US3 / FR-007, FR-008, SC-003 | automated check-mode tests and the CI check | — (no source function) |
| US4 / FR-009, FR-012, SC-004 | the 55 existing tests via the harness runner; `git diff -- src` | — (no source function) |
