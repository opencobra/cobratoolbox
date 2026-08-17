---

description: "Task list for feature implementation"
---

# Tasks: Characterize buildGurobiProblemFromModel

**Input**: Design documents from `/specs/017-buildgurobifrommodel-tests/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: The entire deliverable of this feature IS a test (a Constitution
Principle III characterization test for `buildGurobiProblemFromModel`). There is
no separate "implementation" to test — the checklist below builds the one test
file section by section; there is no `src/` change to verify against.

**Organization**: All tasks land in the same single new file,
`test/verifiedTests/base/testSolvers/testBuildGurobiProblemFromModel.m`
(mirroring the sibling `testBuildOptProblemFromModel.m`), so most
tasks are sequential edits to that one file rather than parallel — grouped by the
user story (spec.md) whose acceptance scenarios they discharge.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Every task below names the exact file path

## Path Conventions

Single-project MATLAB toolbox layout (per plan.md): source under `src/<domain>/`
(untouched by this feature), tests under `test/verifiedTests/<category>/`. The
one file this feature creates:
`test/verifiedTests/base/testSolvers/testBuildGurobiProblemFromModel.m`

---

## Phase 1: Setup

**Purpose**: Create the test file with its required COBRA Toolbox test
boilerplate (testGuide.rst §"Test template"), before any assertion content.

- [X] T001 Create `test/verifiedTests/base/testSolvers/testBuildGurobiProblemFromModel.m`
  with the `% The COBRAToolbox: testBuildGurobiProblemFromModel.m`
  header (`Purpose:` — characterization test pinning the current model→native-
  Gurobi-struct mapping performed by `buildGurobiProblemFromModel`, per
  Constitution Principle III, feature 017; `Authors:` — generated for feature
  017-buildgurobifrommodel-tests, 2026-08-17), followed by the directory
  save/restore boilerplate (`currentDir = pwd;` /
  `fileDir = fileparts(which('testBuildGurobiProblemFromModel')); cd(fileDir);`
  at the top, `cd(currentDir);` at the bottom), matching
  `test/verifiedTests/base/testSolvers/testBuildOptProblemFromModel.m`'s
  structure exactly.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Fixtures and standards checks shared by all three user stories.

**⚠️ CRITICAL**: No user-story assertion task can begin until this phase is complete.

- [X] T002 Add local helper function `buildToyModel1()` to
  `test/verifiedTests/base/testSolvers/testBuildGurobiProblemFromModel.m`
  (below the main script body, matching the sibling test's `buildToyModel()`
  placement), returning the model from data-model.md's "Toy Model 1 — mixed
  constraint senses, maximization" (`rxns`, `mets`, `S`, `lb`, `ub`, `c`, `b`,
  `csense = ['E';'L';'G']`, `osenseStr = 'max'`), then call
  `model1 = buildToyModel1();`,
  `optProblem1 = buildOptProblemFromModel(model1);`, and
  `gurobiModel1 = buildGurobiProblemFromModel(model1);` in the main script body.
- [X] T003 [P] Verify MATLAB coding standards compliance for this feature
  (Constitution VII/testGuide.rst): confirm the file being built in T001/T002
  uses no `evalc`, produces no suppressed warnings, needs no `try/catch` (assert
  failures propagate naturally — no error-swallowing), uses no `nargin`
  (no optional arguments in a test script), and follows `camelCase` naming; no
  file edit — verification only, report any deviation before Phase 3 proceeds.

**Checkpoint**: `model1`, `optProblem1`, `gurobiModel1` are available in the
script; user-story assertion tasks can now begin.

---

## Phase 3: User Story 1 - Native-Gurobi field mapping gains coverage (Priority: P1) 🎯 MVP

**Goal**: Pin the field set and the `A`/`obj`/`rhs`/`lb`/`ub` value mapping, plus
`modelsense` in both the `max` and `min` direction.

**Independent Test**: Run the test file; the field-set and field-value assertions
below pass against a fixed toy model and its independently-computed
`optProblem`, with no other user story's assertions required for these to be
meaningful.

### Implementation for User Story 1

- [X] T004 [US1] In
  `test/verifiedTests/base/testSolvers/testBuildGurobiProblemFromModel.m`,
  assert the field set: `expectedFields = {'A','obj','rhs','lb','ub','sense','modelsense'};`
  then `assert(all(ismember(expectedFields, fieldnames(gurobiModel1))) && numel(fieldnames(gurobiModel1)) == numel(expectedFields));`
  (FR-001; depends on T002).
- [X] T005 [US1] In the same file, assert
  `isequal(full(gurobiModel1.A), full(optProblem1.A))`,
  `isequal(gurobiModel1.obj, full(double(optProblem1.c)))`,
  `isequal(gurobiModel1.rhs, full(optProblem1.b))`,
  `isequal(gurobiModel1.lb, full(optProblem1.lb))`,
  `isequal(gurobiModel1.ub, full(optProblem1.ub))`
  (FR-002, data-model.md Toy Model 1 table; depends on T002).
- [X] T006 [US1] In the same file, assert
  `isequal(gurobiModel1.modelsense, 'max')` (FR-004, `osense == -1` case;
  depends on T002).
- [X] T007 [US1] Add local helper function `buildToyModel2()` to the same file
  (data-model.md "Toy Model 2 — same shape, minimization": identical to
  `buildToyModel1()` except `osenseStr = 'min'`), then call
  `model2 = buildToyModel2(); gurobiModel2 = buildGurobiProblemFromModel(model2);`
  in the main script body.
- [X] T008 [US1] In the same file, assert
  `isequal(gurobiModel2.modelsense, 'min')` (FR-004, `osense == 1` case; depends
  on T007).

**Checkpoint**: User Story 1 is fully pinned and independently verifiable —
field set, all five value-mapped fields, and both `modelsense` directions.

---

## Phase 4: User Story 2 - Constraint-sense translation is pinned (Priority: P1)

**Goal**: Pin the row-by-row `csense` → `sense` translation for `'E'`, `'L'`,
`'G'`, plus the all-`'E'` default case.

**Independent Test**: Run the test file; the two `sense` assertions below pass
using only `gurobiModel1` (from Phase 2) plus one small inline all-`'E'`
variant — no dependency on User Story 1's field-value assertions.

### Implementation for User Story 2

- [X] T009 [US2] In
  `test/verifiedTests/base/testSolvers/testBuildGurobiProblemFromModel.m`,
  assert `isequal(gurobiModel1.sense, ['=';'<';'>'])` (FR-003, row order matches
  Toy Model 1's `csense = ['E';'L';'G']`; depends on T002).
- [X] T010 [US2] In the same file, build the data-model.md "Toy Model 1b —
  all-equality constraint senses" fixture inline
  (`modelAllE = model1; modelAllE.csense = ['E';'E';'E'];`), call
  `gurobiModelAllE = buildGurobiProblemFromModel(modelAllE);`, and assert
  `isequal(gurobiModelAllE.sense, ['=';'=';'='])` (FR-003 all-`'E'` default
  case; depends on T002).

**Checkpoint**: User Stories 1 AND 2 both independently pass — field mapping and
sense translation are both pinned.

---

## Phase 5: User Story 3 - Optional verification path behaves as documented (Priority: P3)

**Goal**: Pin the `verify` argument's no-op behaviour on a valid model and its
error behaviour on an invalid model.

**Independent Test**: Run the test file; the `verify`-path assertions below pass
using only `model1` (from Phase 2) plus one small inline invalid-model variant —
no dependency on User Story 1 or 2's assertions.

### Implementation for User Story 3

- [X] T011 [US3] In
  `test/verifiedTests/base/testSolvers/testBuildGurobiProblemFromModel.m`,
  assert `isequal(buildGurobiProblemFromModel(model1), buildGurobiProblemFromModel(model1, false))`
  and `isequal(buildGurobiProblemFromModel(model1), buildGurobiProblemFromModel(model1, true))`
  (FR-005, verify omitted/false/true all identical on a valid model; depends on
  T002).
- [X] T012 [US3] In the same file, build the data-model.md "Invalid Model —
  verify=true error path" fixture inline (`invalidModel = model1; invalidModel.lb = [0; 0];`)
  and assert
  `assert(verifyCobraFunctionError('buildGurobiProblemFromModel', 'inputs', {invalidModel, true}));`
  (FR-005/SC-006, per testGuide.rst's documented expected-error pattern; depends
  on T002).

**Checkpoint**: All three user stories now independently pass within the one
test file.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final verification that the feature is complete, correct, and
scoped exactly as the plan intends.

- [X] T013 Run the quickstart.md validation guide in full: execute
  `testBuildGurobiProblemFromModel` standalone (silent success, no
  error), then run `testAll` and confirm the new test is discovered and passes
  with no other test regressed.
- [X] T014 [P] Confirm no `src` file changed: `git diff --stat -- src/` is empty
  (Constitution Principle III).
- [X] T015 Report files changed, checks run, tests passed/failed, and any
  behaviour not yet verified (Constitution Principle III reporting
  requirement).
- [X] T016 Create implementation receipt in
  `specs/017-buildgurobifrommodel-tests/agent-runs/<UTC-timestamp>-buildgurobifrommodel-characterization/implementation-receipt.md`,
  with the actual final user-facing agent completion response copied verbatim
  into the `Final response` section.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately.
- **Foundational (Phase 2)**: Depends on Setup (T001) — BLOCKS all user stories
  (T002 creates `model1`/`optProblem1`/`gurobiModel1`, which every later phase
  reads).
- **User Stories (Phase 3-5)**: All depend on Foundational (T002) completion.
  Because all three stories edit the *same file* sequentially, they are listed
  in priority order (US1 → US2 → US3) for execution, though none of their
  assertions logically depends on another story's assertions.
- **Polish (Phase 6)**: Depends on all three user stories being complete.

### User Story Dependencies

- **User Story 1 (P1)**: Depends only on Foundational (T002). No dependency on
  US2/US3.
- **User Story 2 (P1)**: Depends only on Foundational (T002). No dependency on
  US1/US3 (does not read `gurobiModel2`, the all-`'E'` invalid-model, etc.).
- **User Story 3 (P3)**: Depends only on Foundational (T002). No dependency on
  US1/US2.

### Within Each User Story

- T005/T006 depend on T004 only insofar as they share the file — logically
  independent assertions, kept sequential because they are edits to one file.
- T008 depends on T007 (needs `buildToyModel2`/`model2`/`gurobiModel2` defined
  first).
- T010 depends on T009 only for file-edit ordering, not logically.
- T012 depends on T011 only for file-edit ordering, not logically.

### Parallel Opportunities

- T003 (standards verification) can run in parallel with T002 (file edit) —
  different activity, no shared state.
- T014 (git diff check) can run in parallel with T013 (quickstart run) in
  Phase 6.
- Because T001-T012 are all edits to the *same single file*, they are otherwise
  sequential — there is no cross-file parallelism to exploit within this small,
  single-deliverable feature.

---

## Parallel Example: Foundational Phase

```bash
# T002 and T003 touch different concerns (file content vs. a standards review)
# and can proceed at the same time:
Task: "Add buildToyModel1() helper and call buildOptProblemFromModel/buildGurobiProblemFromModel in testBuildGurobiProblemFromModel.m"
Task: "Verify MATLAB coding standards compliance (no evalc/nargin, warnings visible) for the file being authored"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001).
2. Complete Phase 2: Foundational (T002-T003) — CRITICAL, blocks all stories.
3. Complete Phase 3: User Story 1 (T004-T008).
4. **STOP and VALIDATE**: run the file standalone; field-set, field-value, and
   both `modelsense` assertions pass.
5. This alone already satisfies spec.md's SC-001/SC-002 for the field-mapping
   half of the contract and is a legitimate, mergeable increment.

### Incremental Delivery

1. Setup + Foundational → toy model 1 and its `gurobiModel1` exist.
2. Add User Story 1 (T004-T008) → field mapping + modelsense pinned → validate.
3. Add User Story 2 (T009-T010) → sense translation pinned → validate.
4. Add User Story 3 (T011-T012) → verify-path behaviour pinned → validate.
5. Phase 6 polish → full-suite run, no-`src`-diff confirmation, receipt.

### Single-File Note

Unlike a typical multi-story feature, every task here edits the same MATLAB
script. "Independently testable" for this feature means: each story's
assertions are self-contained logical blocks that do not read state only
another story creates (US1 does not need `modelAllE` or `invalidModel`; US2
does not need `gurobiModel2`; US3 does not need `gurobiModelAllE`) — not that
they can be delivered as separate files or separate PRs without merge conflicts.
Sequential single-developer execution in T001→T016 order is the practical path.

---

## Notes

- [P] tasks = independent activity, no shared file-edit ordering constraint.
- [Story] label maps each assertion task to the spec.md user story it
  discharges (see spec.md's Traceability table for the full FR/SC mapping).
- No `src/` file is ever edited by this feature (Constitution Principle III).
- All numeric/struct assertions use `isequal` (exact), never a floating-point
  tolerance — justified in plan.md's Technical Context and research.md R5: the
  toy models use small exact integers and the function performs no arithmetic.
- Commit after each phase (or after the full file, given its small size) per
  the user's own commit cadence — no auto-commit is assumed here.
