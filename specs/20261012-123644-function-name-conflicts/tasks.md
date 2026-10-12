---

description: "Task list for the function-name conflict test"
---

# Tasks: Test that blocks function-name conflicts

**Input**: Design documents from `/specs/20261012-123644-function-name-conflicts/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: the deliverable is a test. It must pass on the current repository and be shown to fail on a synthetic conflict. No `src/` file may change. Work stays on `develop`; no personal information.

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup

- [ ] T001 Confirm the baseline: on `develop`, `git diff --stat -- src` empty, MATLAB R2025a runs, `initCobraToolbox(false)` succeeds.
- [ ] T002 Generate the list of existing conflicts with a throwaway scratch script (independent of the final detector): duplicate names inside `src/` and `external/` (case-insensitive, ignoring `private/`, `@*`, `+*`) and `src/` names that exist under the MATLAB root (not inside class or package folders).

---

## Phase 2: Baseline and detector (US1, US2, US4)

- [ ] T003 [US4] Create `test/verifiedTests/base/testInstall/knownFunctionNameConflicts.txt` from T002: one line per name `name | kind | reason`, with a comment header explaining the format and how to add an entry; every existing conflict gets a reason (old/new copies, separate solver copies, MATLAB-shadowing names).
- [ ] T004 [US1] [US2] Write `test/verifiedTests/base/testInstall/testFunctionNameConflicts.m`: header (purpose, tier 1, no source function, exemptions, defects), `prepareTest()`, local functions at the end of the file: the detector (file-system scan for toolbox duplicates, `which -all` for MATLAB conflicts), the reader of the known-conflicts file, and the message formatter.

---

## Phase 3: Self-check and message (US3)

- [ ] T005 [US3] Add the self-check section: temporary tree with a duplicate across folders, a case-only twin, a file named after a MATLAB function, a clean file, and ignored `private/` and `@cls/` files; assert the findings, assert the formatted message contains the five required items (name, conflicting paths incl. MATLAB location, why it matters, how to fix incl. recording an entry, MATLAB release) and that several conflicts appear in one message; remove the tree even on failure.
- [ ] T006 [US1] [US2] Add the repository section: run the detector on the real tree, fail with the formatted message for conflicts not in the known file; add the stale-entry note (no failure).

---

## Phase 4: Verification (US1, US2, US4)

- [ ] T007 Run the test through the harness runner: passes on the current repository; record the run time (target under 30 s); confirm no file is left behind and the MATLAB path and working directory are unchanged.
- [ ] T008 Demonstrate failures: (a) copy an existing function file to another `src/` folder; (b) add a file named after a MATLAB function; (c) add a case-only twin; (d) remove one baseline line; for each, the test fails with the expected message; then restore (leave no change).
- [ ] T009 Measure coverage-like value: confirm every branch of the detector is exercised by the self-check (duplicate, case-only, MATLAB conflict, ignored folders, clean tree).

---

## Phase 5: CI selection (FR-011)

- [ ] T010 Add the rule to `.github/scripts/select_tests.py`: when any changed path matches `src/**/*.m` and the name-conflict test exists in the indexed tests, also select it.
- [ ] T011 Add `.github/scripts/test_select_tests.py` (stdlib `unittest`): a synthetic tree where the changed list holds only a new src function file; assert the output selects the name-conflict test; a change list without src files does not select it.
- [ ] T012 Document the rule in `.github/scripts/README.md` (one short paragraph).

---

## Phase 6: Polish

- [ ] T013 Scan every added or changed file for personal information; none.
- [ ] T014 Write the implementation receipt `specs/20261012-123644-function-name-conflicts/agent-runs/<UTC-timestamp>-function-name-conflicts/implementation-receipt.md`.
- [ ] T015 Commit on `develop` (author from the local git configuration, no co-author line); do not push.

---

## Dependencies & Execution Order

Phase 1 -> Phase 2 (T003 before T004 is not required, but the test needs the file to pass) -> Phase 3 -> Phase 4 -> Phase 5 -> Phase 6. Total tasks: 15.
