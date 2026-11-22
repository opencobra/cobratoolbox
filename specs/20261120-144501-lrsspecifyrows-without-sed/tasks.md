# Tasks: lrsSpecifyRows without sed

**Input**: `specs/20261120-144501-lrsspecifyrows-without-sed/` (spec, plan, research, contract)

**Tests**: required (FR-006, FR-007).

**Branch**: `20261113-142115-test-backfill-tiers` (open pull request).

Paths: `S` = `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsSpecifyRows.m`,
`T` = `test/verifiedTests/analysis/testLrsInterface/testLrsSpecifyRows.m`,
`R` = `test/verifiedTests/analysis/testLrsInterface/testLrsRun.m`,
`B` = `specs/20261113-142115-test-backfill-tiers`, `F` = this feature folder.

## Phase 1: Setup

- [X] T001 Baseline: run `T` and `R` with coverage (`F/coverage-list.txt` → `F/coverage-before.jsonl`); record, with GNU sed, the exact output of `S` for the new test inputs (several placeholders, a six-star run) to use as expected text

## Phase 2: Foundational

None.

## Phase 3: User Story 1 - Row count filled in on every platform (P1) 🎯 MVP

- [X] T002 [US1] In `T` (tests first): `prepareTest()` without requirement and without the GNU sed check; a section "placeholders" (two `*****` and one `******` in one file) compared with the T001 sed output; a section that runs `S` with `PATH` set to an empty string (restored with onCleanup) and checks the same result; assert `status == 0 && isempty(result)` as before; replace the failing-sed section; run `T` against the current `S` and see the empty-PATH section fail
- [X] T003 [US1] In `S`: read with `fopen(..., 'r+')`/`fread`, close, count by the current rule, `regexprep` the placeholders, write back with `fwrite`, close; `status = 0`, `result = ''`; remove the sed call and its comments; header OUTPUTS and a dated NOTE (feature 20261120-144501-lrsspecifyrows-without-sed, Principle XI)

## Phase 4: User Story 2 - Clear errors and no open files (P2)

- [X] T004 [US2] In `T`: a section "a file that cannot be opened" (`fullfile(tempname, 'nope.ext')` gives 'Could not open lrs output file.'); a file with `begin` but no `end` gives 'Could not read lrs output file.' and is unchanged; after every section assert that no identifier opened by `S` remains (compare the open-file list with the one at the start); remove both defect entries and the coverage exemptions from the header; Purpose, Tier (Tier 1, no requirement) and Authors updated
- [X] T005 [US2] In `S`: no `disp(fileNameOut)`; the open error is the documented one (done with T003; check here)

## Phase 5: Polish & Cross-Cutting Concerns

- [X] T006 In `R`: `runWithOnlyPrograms({'lrs', 'which'}, ...)`, the comment and the header Tier line no longer mention sed
- [X] T007 Run `T` and `R` with coverage (`F/coverage-after.jsonl`): both pass, `S` fully covered, `lrsRun` all but line 156; update the ledger rows of lrsSpecifyRows (missed/exempt empty, notes) and lrsRun (notes); `--verify-coverage`, `--check` 0 problems
- [X] T008 [P] Callers: the ten lrs-related tests pass
- [X] T009 Regenerate the registry (`python3 .github/scripts/known_defects.py`): 861 defects, the two lrsSpecifyRows entries gone
- [X] T010 Records: `B/review.md` note (replace the "Outside this change: lrsSpecifyRows ..." sentence with the fix), `B/tasks.md` T041 pointer, `B` receipt addendum, `specs/20261120-140123-lrsrun-without-redund/pr-note.md` updated (two files of src/ change); receipt `F/agent-runs/<UTC>-implement/implementation-receipt.md`; tasks [X]
- [X] T011 Privacy scan and commit as the maintainer, no co-author line; push only when asked

## Dependencies & Execution Order

T001 → T002 → T003 → T004 → T005 → T006 → T007 → T008/T009 → T010 → T011. US2 shares `S` and `T`
with US1, so it follows it.
