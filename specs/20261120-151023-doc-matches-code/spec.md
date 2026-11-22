# Feature Specification: Help text matches the code

**Feature Branch**: `20261120-151023-doc-matches-code` (new branch, started from the open pull
request's branch `20261113-142115-test-backfill-tiers`, whose tests and records it builds on)

**Created**: 2026-11-20

**Status**: Draft

**Input**: Maintainer, 2026-11-20: "fix the cosmetic ones that are there is inconsistency between
text and code. And change the text to match the code. dont change the code. Push it to a new branch.
Use speckit to do this. Once you solved that ... write test functions for them ... lets increase the
test coverage as much as possible." Scope chosen by the maintainer: "Docs + 6 quarantines". This
covers the cosmetic text/code mismatches and the quarantines that rest only on help text, with no
code change. After that come full tests for the functions this clears and for the callers it
unblocks.

## Context

`test/known-defects.md` lists 146 cosmetic entries (130 test files). Some of them are help text or
comments that contradict what the code does; others concern messages, printing or behaviour. The
back-fill review (`specs/20261113-142115-test-backfill-tiers/review.md`, "For the human review" item
2) named quarantines that rest only on help text. On re-reading, five of them are documentation
fixes:

- parseSolverParameters: `param` is documented to include the additional parameters, but the code
  returns them only in `solverOnlyParams`, which is what every caller uses.
- changeCobraSolverParams: `solverType` is documented as optional with default 'LP', but the code
  and the USAGE line require it.
- getElementalWeightMatrix: the help documents an input `printWarning` that does not exist.
- getEcosystemClusterDescriptor: the column is documented as `status`, but the code names it
  `status_c<id>`.
- transportReactionBool: the help says the compartments matter only for unidirectional, but the
  code applies them in both cases.

readSimPhenyCMPD is not one: its quarantine rests on the intent of its own code (a deblank loop
that misses the blank after '/'), and documenting the blank would make a likely bug the documented
behaviour. It stays quarantined. Clearing transportReactionBool unblocks one caller,
deltaG0concFluxConstraintBounds.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Help text that tells the truth (Priority: P1)

A user reads `help <function>` and gets a description of what the function actually does.

**Independent Test**: for every corrected entry, the comment text now states what the code does,
the code is byte-for-byte unchanged, the test header no longer lists the entry, and the function's
test still passes.

**Acceptance Scenarios**:

1. **Given** a cosmetic entry whose help or comment contradicts the code, **When** the feature is
   done, **Then** the text describes the code's behaviour, and only comment lines of that file
   changed, with the same number of lines.
2. **Given** a cosmetic entry about a message, printed output or behaviour, **When** the feature is
   done, **Then** it is unchanged and still listed.
3. **Given** a mismatch where the help describes the evident intent and the code is a slip (a typo, a
   wrong variable), **When** the feature is done, **Then** it is left as a defect and reported, not
   documented as behaviour.

### User Story 2 - New tests for the functions this clears (Priority: P2)

**Independent Test**: parseSolverParameters, changeCobraSolverParams, getElementalWeightMatrix,
getEcosystemClusterDescriptor, transportReactionBool and deltaG0concFluxConstraintBounds have full
tests that pass with coverage. The ledger records them as TESTED.

**Acceptance Scenarios**:

1. **Given** a quarantine that rests only on help text, **When** its help is corrected, **Then** its
   quarantine test becomes a full test of the documented (corrected) behaviour, with expected values
   derived independently, and its remaining entries (if any) stay as non-quarantining entries.
2. **Given** a BLOCKED function whose blockers are all cleared, **When** the feature is done,
   **Then** it has a full test, or a quarantine test if writing the test reveals a defect of its own.

### Edge Cases

- A help text fix that needs more words than the old lines hold: reword within the same number of
  lines, since lines may get longer. Line numbers stay valid for every other entry, coverage
  exemption and ledger row.
- A cosmetic entry whose test exempts lines because of it: reported; exemptions change only if the
  test then covers those lines.
- A trailing comment after code, or a block comment: treated as code and not edited.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Only full comment lines of `src/` files change. Every changed file keeps its number of
  lines. `tools/comment_only_check.py` verifies both against the branch start.
- **FR-002**: Each corrected entry describes the code's behaviour. The entry is removed from its test
  header, and the test's Authors section records the correction.
- **FR-003**: Cosmetic entries about messages, printing or behaviour, and mismatches where the code is
  the evident slip, stay listed. Each one is classified with a reason in
  `inventory/results/cosmetic-slice-N.jsonl`.
- **FR-004**: The five help-text quarantines are corrected. Their tests become full tests (Tier per
  III-Coverage, expected values derived independently or from the first run as Tier 5 states), and
  their ledger rows move to TESTED.
- **FR-005**: Every BLOCKED function whose blockers are all cleared gets a test. That is
  deltaG0concFluxConstraintBounds: a full test, or a quarantine test with a confirmed defect.
- **FR-006**: The registry is regenerated. Ledger `--check` and `--verify-coverage` report 0 problems
  for the new tests, and every test of a changed source file passes.
- **FR-007**: Readers and records stay consistent: the back-fill review.md (item 2 resolved, except
  readSimPhenyCMPD) and a receipt.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 0 non-comment lines changed in `src/`, and 0 changes in line count.
- **SC-002**: Every cosmetic entry is classified; the number corrected and the number kept are
  reported.
- **SC-003**: 6 more TESTED functions (5 cleared plus 1 unblocked), each passing with coverage of
  every executable line not exempted.
- **SC-004**: The tests of all changed source files pass as before.

## Assumptions

- The new branch starts from the pull request's branch, so it is a follow-up pull request after
  that one, or is merged into it.
- Changing a comment cannot change results. MATLAB's `help` output is the only thing affected.
- Error and warning message strings are code, not text, and are out of scope.

## Traceability

| Acceptance criterion | Test | Source function |
|---|---|---|
| US1-1/2/3 text fixes only, entries classified | `tools/comment_only_check.py`; the test of each changed source file | every changed `src/` file |
| US2-1 cleared quarantines tested | testParseSolverParameters, testChangeCobraSolverParams, testGetElementalWeightMatrix, testGetEcosystemClusterDescriptor, testTransportReactionBool | the five functions |
| US2-2 unblocked caller tested | testDeltaG0concFluxConstraintBounds | src/analysis/thermo/thermoDirectionality/deltaG0concFluxConstraintBounds.m |
