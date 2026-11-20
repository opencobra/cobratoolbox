# Tasks: Help text matches the code

**Input**: `specs/20261120-151023-doc-matches-code/` (spec.md, plan.md)

**Tests**: required (US2; FR-004 to FR-006).

`F` = this feature folder; `B` = `specs/20261113-142115-test-backfill-tiers`.

## Phase 1: Setup

- [X] T001 `F/inventory/cosmetic.json` and five slices (done at planning: 146 entries, 130 test files; testParseSolverParameters and testChangeCobraSolverParams kept for the lead), `F/tools/comment_only_check.py`, and the agent brief `F/inventory/cosmetic-brief.md`

## Phase 2: Foundational

None.

## Phase 3: User Story 1 - Help text that tells the truth (P1) 🎯 MVP

- [X] T002 [P] [US1] Helper agents classify and fix slices 1-5 by the brief; records `F/inventory/results/cosmetic-slice-N.jsonl`
- [X] T003 [US1] Lead second reading of every class-A fix (comment now matches the code; not a slip) and of every class-C report; run `F/tools/comment_only_check.py` with 0 problems
- [X] T004 [US1] Run the test of every changed source file (runScriptFile): all pass as before

## Phase 4: User Story 2 - New tests for the functions this clears (P2)

- [X] T005 [US2] Correct the help of parseSolverParameters, changeCobraSolverParams, getElementalWeightMatrix, getEcosystemClusterDescriptor and transportReactionBool (comment lines only, same line count); remove those entries from their tests
- [X] T006 [US2] Rewrite the five quarantine tests as full tests (contract `B/contracts/test-file.md`; wave versions from git history as the starting point); a test that reveals a new serious defect goes back to quarantine with the defect confirmed
- [X] T007 [US2] Write `test/verifiedTests/analysis/testThermo/testDeltaG0concFluxConstraintBounds.m` (or the existing folder for its area)
- [X] T008 [US2] Coverage run of the six tests (`F/coverage-list.txt` → `F/coverage.jsonl`); ledger rows → TESTED with lines/missed/exempt; blocked rows drop cleared blockers; `--verify-coverage`, `--check` 0 problems

## Phase 5: Polish & Cross-Cutting Concerns

- [X] T009 Regenerate the registry; guard again; `B/review.md` ("For the human review" item 2 resolved, readSimPhenyCMPD kept, with the reason); summary of the classification in `F/review.md`
- [X] T010 Receipt `F/agent-runs/<UTC>-implement/implementation-receipt.md`; tasks [X]
- [X] T011 Privacy scan; commit as the maintainer, no co-author; push the new branch to origin (the maintainer asked for it)

## Dependencies & Execution Order

T001 → T002 (parallel slices) → T003 → T004. T005-T008 can start after T001; they do not touch the
slice files. T009 → T010 → T011.
