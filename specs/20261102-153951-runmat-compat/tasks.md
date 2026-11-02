# Tasks: RunMat compatibility of COBRA Toolbox source

**Input**: `specs/20261102-153951-runmat-compat/` (spec.md, plan.md, research.md, quickstart.md)

**Tests**: no behaviour changes, so no new test file is added (plan.md, Constitution Check). Each category task
carries its own verification: an unchanged MATLAB parse tree, or a category check, plus an analyzer snapshot
with no new message. The unchanged MATLAB `testAll` result (T030) is the end-to-end check.

**Paths**: `F` = `specs/20261102-153951-runmat-compat`. In scope: `src/`, `test/` and `initCobraToolbox.m`,
excluding `.gitmodules` paths, `external/` and `deprecated/`.

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup

- [X] T001 Write `$F/tools/scope_files.py` (lists in-scope tracked `.m` files, excluding submodule, `external/` and `deprecated/` paths) and save its output to `$F/reports/scope.txt`
- [X] T002 [P] Write `$F/tools/runmat_discovery.sh ROOT OUT`: RunMat runner discovery (`runmat test --list --path=src --path=test test/verifiedTests`) over a tree, plus an error summary by message
- [X] T003 [P] Write `$F/tools/apply_and_verify.sh CATEGORY LIST`: copy the listed files to a before-tree, run the category tool, call `parseTreeEquivalence`/`analyzerSnapshot` in MATLAB (`matlab -batch`), revert rejects into `$F/reports/rejected-<category>.txt`, and write the accepted list to `$F/reports/accepted-<category>.txt`

## Phase 2: Foundational (baseline, blocks every story)

- [X] T004 Run MATLAB `testAll` (`COBRA_CI=1`) on the unchanged branch in the background, and save `resultTable` to `$F/baseline/testAll-before.csv` with its log summary
- [X] T005 [P] Save the analyzer snapshot of every in-scope file to `$F/baseline/analyzer-before.json` (`tools/analyzerSnapshot.m`)
- [X] T006 [P] Save RunMat runner discovery on the unchanged branch to `$F/baseline/runmat-discovery-before.txt` (expected about 1,186 errors; research.md R3)

**Checkpoint**: baseline recorded; category work can start.

## Phase 3: User Story 1 - Owned source compiles under RunMat (P1) 🎯 MVP

**Goal**: remove every RunMat compile error of the mechanical categories from in-scope files, with MATLAB behaviour unchanged.

**Independent Test**: `$F/tools/runmat_discovery.sh` shows no error of a rewritten category; `$F/reports/accepted-*.txt` files all pass the parse-tree or category check; the analyzer gains no message.

- [X] T007 [US1] FR-009: re-encode `test/tutorialDerived/analysis/rMTA/tutorial_rMTA.m` from Latin-1 to UTF-8, confirm the decoded characters are identical, and commit
- [X] T008 [US1] FR-001: run `add_function_ends.py` through `apply_and_verify.sh` on the in-scope files that RunMat reports with "expected 'end'"; accept only identical parse trees; commit "Add explicit function terminators for RunMat compatibility"
- [X] T009 [US1] FR-002: run `explicit_separators.py` through `apply_and_verify.sh` on every in-scope file it changes; accept only identical parse trees; list lexer skips and rejects (research found 3 skips and 6 rejects); commit
- [X] T010 [US1] FR-003: write `$F/tools/add_empty_catch.py`, which adds `catch` (on its own line, at the `try` indentation) before the `end` that closes each `try` with no `catch`
- [X] T011 [US1] FR-003: run `add_empty_catch.py` through `apply_and_verify.sh` on the files RunMat reports with "expected 'catch' after try". The accept check: the analyzer gains no message, and the parse tree differs from the original only by the added `catch` node, checked by `parseTreeEquivalence` after removing that node. Commit.
- [X] T012 [US1] FR-001 again: rerun T008 on files that now report "expected 'end'" (unterminated files surface late, research.md R3); commit
- [X] T013 [US1] FR-004: write `$F/tools/explicit_calls.py --names A,B FILE...`, which rewrites each bare occurrence of a listed name (not followed by `(`, not after `.`, not in a string or comment, not on the left of `=`) as `name()`
- [X] T014 [US1] FR-004: from RunMat's undefined-name errors, choose the candidate names and record the decision per name in `$F/reports/explicit-calls-names.tsv`. A name is a candidate only when MATLAB `exist(name)` is 2, 3, 5 or 6, and the file never assigns, loads or `eval`s it. Run `explicit_calls.py` on the affected files; accept when the analyzer gains no message; commit.
- [X] T015 [US1] FR-006: reduce `src/analysis/sampling/BarrierRound/PolytopeSimplifier/coverage/PolytopeSimplifierTest.m` and `src/analysis/sampling/BarrierRound/CMatrix/include/AdaptiveChol.m` to the construct that crashes RunMat, using copies outside the repository. Rewrite a file only if a small change keeps the parse tree identical and avoids the crash; otherwise record defect D7 with the reproducer.
- [X] T016 [US1] Re-measure discovery with `runmat_discovery.sh` and save it to `$F/reports/runmat-discovery-after-us1.txt`; classify every residual error as either "RunMat defect" (with D-number) or "out of slice" in `$F/reports/residual.tsv`

**Checkpoint**: US1 complete. Its result is accepted only after T030 confirms MATLAB results are unchanged.

## Phase 4: User Story 2 - testAll entry point under RunMat (P2)

**Goal**: `test/testAll.m` and `initCobraToolbox.m` contain no construct of the slice that stops RunMat during start-up.

**Independent Test**: run `testAll` under RunMat (T019) and record where it stops.

- [ ] T017 [US2] FR-005: in `test/testAll.m`, rewrite the `PERFORMANCE_REPORT_ON` expression so that no undefined variable is named outside the `exist` guard, keeping its value in MATLAB, e.g. `PERFORMANCE_REPORT_ON = strcmp(getenv('COBRA_PERF'), '1'); if ~PERFORMANCE_REPORT_ON && exist('PERFORMANCE_REPORT', 'var') && ~isempty(PERFORMANCE_REPORT), PERFORMANCE_REPORT_ON = PERFORMANCE_REPORT; end`. Verify that `checkcode` gains no message, and run the four combinations (env var set or not × variable present or absent) in MATLAB to confirm the same value.
- [ ] T018 [US2] FR-004/FR-008 in `test/testAll.m` and `initCobraToolbox.m`: write bare calls such as `initCobraToolbox`, `exit` and `prefdir` as `name()` (T013 tool); analyzer check; commit with T017
- [X] T019 [US2] FR-014: build the measurement copy outside the repository (failing `external/` and submodule folders off the path, T016 residual files set aside), run `testAll` under RunMat with `COBRA_CI=1` and a time limit, and save the log and stopping point to `$F/reports/runmat-testAll.txt`

## Phase 5: User Story 3 - Measurement and report (P3)

**Goal**: one report with the counts and the RunMat defects.

**Independent Test**: re-running the quickstart commands reproduces the counts.

- [ ] T020 [US3] Write `$F/reports/runmat-compat-report.md`:
  - discovery counts before and after;
  - files changed per category, with rejects;
  - the `testAll` under RunMat outcome: passed, failed and skipped counts, or the stopping point with its cause;
  - the RunMat defects D1–D12 (plus any new ones), each with a reproducer of at most 10 lines and the number of COBRA files affected.

## Phase 6: Polish & cross-cutting verification

- [X] T030 Run MATLAB `testAll` (`COBRA_CI=1`) on the finished branch; save `$F/reports/testAll-after.csv`; compare with `$F/baseline/testAll-before.csv` by test name and status (SC-003). Any difference blocks completion and is traced to its category commit.
- [ ] T031 [P] Run an analyzer snapshot of all changed files and compare it with `$F/baseline/analyzer-before.json` (SC-002)
- [ ] T032 [P] Check that `git diff --stat develop` touches no path under `external/`, `deprecated/` or a `.gitmodules` path (FR-007, FR-013)
- [ ] T033 Update the quickstart with the final commands, write the implementation receipt (constitution ledger), and update `human-loop.md`

## Dependencies & Execution Order

- T001–T003, then T004–T006 (T004 runs in the background while US1 proceeds, but must finish before T030).
- US1 in order: T007 → T008 → T009 → T010/T011 → T012 → T013/T014 → T015 → T016. Each category is
  committed separately, because later categories depend on the file states before them.
- US2 (T017–T019) after T013 and T016. US3 (T020) after T019.
- T030–T033 last.

## Implementation Strategy

MVP = Phases 1–3 plus T030 (US1 verified as MATLAB-equivalent). US2 and US3 then add the measurement and the
report. Commit one category at a time; never batch categories into one commit.
