# Tasks: lrsRun without the separate redund program

**Input**: Design documents from `specs/20261120-140123-lrsrun-without-redund/`
(spec.md, plan.md, research.md, data-model.md, contracts/lrsRun.md, quickstart.md)

**Tests**: required by the spec (FR-007, FR-008): testLrsRun is changed with the source.

**Branch**: `20261113-142115-test-backfill-tiers`. The maintainer asked for this fix to go into the
open pull request (2026-11-20).

Paths: `L` = `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsRun.m`,
`T` = `test/verifiedTests/analysis/testLrsInterface/testLrsRun.m`,
`B` = `specs/20261113-142115-test-backfill-tiers` (the back-fill feature, whose pull request this joins).

## Phase 1: Setup

- [X] T001 Record the baseline: run `T` with coverage of `L` (`B/tools/run_coverage.sh`, list `specs/20261120-140123-lrsrun-without-redund/coverage-list.txt`, output `specs/20261120-140123-lrsrun-without-redund/coverage-before.jsonl`), and run `testExtremePools` and `testExtremePathways` (they call lrs through lrsRun or directly) to note their status before the change

## Phase 2: Foundational

None: no shared prerequisite beyond T001.

## Phase 3: User Story 1 - Remove redundant facets with lrs alone (P1) 🎯 MVP

**Goal**: with `redund = 0` and facet enumeration, lrsRun removes redundancy with lrs and its
`redund 0 0` option on a temporary copy, never calling `redund` (FR-001 to FR-006).

**Independent Test**: `lrsRun('q7', struct('redund', 0, 'facetEnumeration', 1))` with a `PATH`
holding lrs but no redund returns `q7_noR_noR.ine` with the two quadrant facets, and `q7_noR.ine`
is unchanged.

- [X] T002 [US1] In `T`, write the checks first (they fail against the current `L` when `redund` is hidden): in the section "redund = 0", assert that `q7_noR.ine` still holds the trivial row (unchanged by the redundancy step) and that the work folder holds only the expected files after the call; add a section that repeats the `q7` call with `PATH` set to a temporary folder holding only links to `lrs` and `which` (restored by `onCleanup`), and asserts the same output; add a check that no new file appears in `tempdir` during these calls
- [X] T003 [US1] In `L`: in the facet-enumeration branch with `param.redund == 0`, after `lrsSpecifyRows(fileNameIn)`, write `fileread(fileNameIn)` + a newline if missing + `redund 0 0` + newline to `optionFile = [tempname '.ine']`, register `onCleanup` deleting it, run `['lrs ' optionFile ' > ' pwd filesep fileNameOut]` through `system` and `checkCommandStatus`, print `['lrs ' fileNameIn ' (with option redund 0 0) > ' fileNameOut]`; remove `uselrsRedundOption`, the `sed` route and the unused `redundCmd` block (lines 89-93); keep every other line's behaviour
- [X] T004 [US1] In `L`'s header: `.redund` = "if 0, remove redundant inequalities with lrs's redund option (lrslib 7 or later)"; the NOTE names lrs and the shell script (not redund); add a dated line on this change (feature 20261120-140123-lrsrun-without-redund, Principle XI)

**Checkpoint**: `T` passes with and without `redund` on the `PATH`.

## Phase 4: User Story 2 - Test of lrsRun runs on CI (P1)

**Goal**: `T` declares only lrs, covers the new route including its failure, and documents its
exemptions (FR-007, SC-002, SC-003).

**Independent Test**: `runScriptFile('testLrsRun.m')` with a `PATH` holding only lrs and which
returns `passed`, not `skipped`.

- [X] T005 [US2] In `T`: `prepareTest('requiredSoftwares', {'lrs'})` with its comment; header Tier line names only lrs; add a failing lrs in the redundancy step (a stand-in `lrs` script that runs the real lrs unless its input file contains `redund 0 0`, in which case it exits 5) and assert `lrsRun:commandFailed` with "failed with exit status 5"; update "Coverage exemptions" (lines 133-135 are gone; give the new line number of the non-Unix branch); Purpose names the redund option route; add the Authors line "Covers redundancy removal by lrs alone (feature 20261120-140123-lrsrun-without-redund), 2026-11-20"
- [X] T006 [US2] Run `T` with coverage of `L` (output `specs/20261120-140123-lrsrun-without-redund/coverage-after.jsonl`): passed, every executable line except the non-Unix branch, no leftover; and once through `runScriptFile` with `PATH` holding only links to lrs and which: `passed`

**Checkpoint**: both stories done; the change is complete.

## Phase 5: Polish & Cross-Cutting Concerns

- [X] T007 [P] Caller check: `testExtremePools`, `testExtremePathways` and the other tests of `test/verifiedTests/analysis/testLrsInterface/` pass as in T001
- [X] T008 Back-fill records: `python3 B/tools/update_ledger.py B --check` (lrsRun stays TESTED, test path unchanged) and `python3 .github/scripts/known_defects.py --check` (registry unchanged); append to `B/review.md` (the section "Follow-up: CI failures of the pull request") that testLrsRun no longer needs redund, with the evidence; add a line to `B/tasks.md` Phase 11 pointing to this feature; addendum to `B/agent-runs/20261117T034131Z-implement/implementation-receipt.md`
- [X] T009 Write the pull request description update to `specs/20261120-140123-lrsrun-without-redund/pr-note.md`: the pull request now changes one file of `src/` (lrsRun), why (Principle XI, CI skip), the evidence, and the constitution amendments 1.9.0 and 1.10.0 it carries
- [X] T010 Implementation receipt `specs/20261120-140123-lrsrun-without-redund/implementation-receipt.md` (constitution's Implementation Receipt Ledger); mark tasks [X]
- [X] T011 Privacy scan (`B/tools/privacy_check.sh` and a grep of the staged diff for machine paths), commit as the maintainer without a co-author line; push only when the maintainer asks

## Dependencies & Execution Order

- T001 → T002 → T003 → T004 → T005 → T006 → T007/T008 → T009 → T010 → T011.
- US2 depends on US1 (the test can drop `redund` only once lrsRun no longer calls it).
- T007 can run in parallel with T008 (different files; T007 only runs tests).

## Parallel Example

```text
After T006: run T007 (MATLAB caller tests) while writing T008 (records).
```

## Implementation Strategy

MVP = US1 (T002-T004): lrsRun works without redund. US2 (T005-T006) makes CI run the test. One
commit for the feature, after T010.
