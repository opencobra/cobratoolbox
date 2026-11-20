# Feature Specification: lrsSpecifyRows without sed

**Feature Branch**: `20261113-142115-test-backfill-tiers` (the open pull request's branch, as for
the lrsRun change; maintainer, 2026-11-20)

**Created**: 2026-11-20

**Status**: Draft

**Input**: User description: "Can you fix this one? Follow-up I noticed: lrsSpecifyRows, which
lrsRun calls, uses GNU-style sed -i. That fails with macOS's BSD sed."

## Context

`lrsSpecifyRows` (src/analysis/topology/extremeRays/lrs/lrsInterface/lrsSpecifyRows.m) fills in the
row count of an lrs file. lrs writes `*****` in place of the number of data rows, and this function
counts the rows between `begin` and `end` and replaces `*****` in place. It does the replacement
with `sed -i 's/.../g' file`, the GNU form. BSD sed on macOS reads the expression as a backup
suffix and fails, and Windows has no sed. So every lrsRun call fails on macOS, and testLrsSpecifyRows
must require GNU sed and is skipped elsewhere.

Its test documents two more defects (registry, test/known-defects.md):

- **cosmetic:** a file that cannot be opened gives "Unrecognized function or variable
  'fileNameOut'" instead of 'Could not open lrs output file.' (line 22).
- **limitation:** the file identifier opened on line 20 is never closed.

Constitution Principle XI, option 1: base MATLAB can read the file, replace the text and write it
back, so sed is not needed.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Row count filled in on every platform (Priority: P1)

A researcher runs lrsRun (which calls lrsSpecifyRows) on macOS, Linux or Windows.

**Why this priority**: lrsRun fails on macOS today, and the test runs only with GNU sed.

**Independent Test**: on a machine or `PATH` without sed, `lrsSpecifyRows('x.ext')` on a file with
`***** 3 rational` and two data rows writes `2 3 rational` and changes nothing else.

**Acceptance Scenarios**:

1. **Given** an lrs file whose count line is `***** 3 rational` with two data rows before `end`,
   **When** lrsSpecifyRows runs (relative or absolute name), **Then** the file reads `2 3 rational`
   and is otherwise byte for byte the same, and the outputs are `status = 0` and an empty `result`.
2. **Given** no `sed` on the `PATH`, **When** it runs, **Then** the result is the same.
3. **Given** zero data rows, or text after `end`, **When** it runs, **Then** the count is 0 and the
   text after `end` is unchanged; every `*****` in the file is replaced, as sed's `g` did.

### User Story 2 - Clear errors and no open files (Priority: P2)

**Why this priority**: the two documented defects of the same few lines.

**Independent Test**: a missing file gives 'Could not open lrs output file.'; after any call,
successful or not, no file identifier is left open.

**Acceptance Scenarios**:

1. **Given** a path that does not exist, **When** lrsSpecifyRows runs, **Then** it raises 'Could not
   open lrs output file.'
2. **Given** a file without `begin` or without `end`, **When** it runs, **Then** it raises 'Could
   not read lrs output file.' as today, and the file is unchanged.
3. **Given** any call, **When** it returns or raises, **Then** no file identifier opened by it stays
   open.

### Edge Cases

- A run of more than five `*` (for example `******`): the replacement is leftmost and
  non-overlapping, as sed's, so `******` becomes `<n>*`.
- Files without a final newline, and lines ending in `\r`: preserved as they are. `begin` and `end`
  are matched as whole lines, as fgetl did.
- `end` before `begin`: the count is computed as today (no behaviour change).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: lrsSpecifyRows MUST NOT call sed or any other external program; it MUST read, edit
  and rewrite the file with base MATLAB.
- **FR-002**: The row count and the replaced text MUST equal what the GNU sed version produced:
  every leftmost, non-overlapping `*****` becomes the count, and all other bytes are unchanged.
- **FR-003**: Inputs and outputs keep their form (Principle II): a name without a file separator is
  relative to the current folder; `[status, result]` are returned, now always `0` and `''` on
  success; the error 'Could not read lrs output file.' is unchanged.
- **FR-004**: A file that cannot be opened for reading and writing MUST raise 'Could not open lrs
  output file.' (the documented cosmetic defect is fixed).
- **FR-005**: No file identifier MUST stay open after a call, successful or not (the documented
  limitation is fixed).
- **FR-006**: testLrsSpecifyRows MUST declare no requirement (Tier 1), MUST check FR-001 to FR-005,
  including a run with an empty `PATH`, and MUST drop the two defect entries; the registry is
  regenerated. testLrsRun's minimal `PATH` no longer lists sed.
- **FR-007**: The narrowest reproducibility checks are testLrsSpecifyRows and testLrsRun with
  coverage, and the lrs-related tests as callers.

### Key Entities

- **lrs file**: text with `begin`, a count line (`<rows|*****> <columns> <type>`), data rows,
  `end`, then options and comments.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: testLrsSpecifyRows runs without any requirement and passes, covering every
  executable line of lrsSpecifyRows; it would no longer be skipped on macOS or Windows.
- **SC-002**: For every file of the existing test, the output is byte for byte what the sed
  version wrote.
- **SC-003**: The registry loses exactly the two lrsSpecifyRows entries; lrsRun, extremePools,
  extremePathways and the other lrs tests pass as before.

## Assumptions

- lrs files are text; the function reads and writes them as bytes, so the encoding does not matter.
- The scope is lrsSpecifyRows.m, testLrsSpecifyRows.m and the sed entry of testLrsRun's minimal
  `PATH`, plus records.

## Traceability

| Acceptance criterion | Test | Source function |
|---|---|---|
| US1-1 count written, rest unchanged, outputs 0 and '' | testLrsSpecifyRows, "relative file name" and "absolute file name" | src/analysis/topology/extremeRays/lrs/lrsInterface/lrsSpecifyRows.m |
| US1-2 no sed needed | testLrsSpecifyRows, run with an empty PATH | lrsSpecifyRows.m |
| US1-3 zero rows, text after end, every placeholder, six stars | testLrsSpecifyRows, "absolute file name" and "placeholders" | lrsSpecifyRows.m |
| US2-1 missing file error | testLrsSpecifyRows, "a file that cannot be opened" | lrsSpecifyRows.m |
| US2-2 no begin/end error, file unchanged | testLrsSpecifyRows, "a file without begin" | lrsSpecifyRows.m |
| US2-3 no open identifiers | testLrsSpecifyRows, open-file check after every section | lrsSpecifyRows.m |
