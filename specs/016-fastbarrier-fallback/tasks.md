# Tasks: FastBarrier Fallback

**Input**: Design documents from `specs/016-fastbarrier-fallback/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/fluxVariability-fastBarrier.md](./contracts/fluxVariability-fastBarrier.md), [quickstart.md](./quickstart.md)

**Tests**: Required. This feature changes numerical solver behaviour and must keep `test/verifiedTests/analysis/testFVA/testFVA.m` passing without weakening its existing fastBarrier comparison assertions.

**Organization**: Tasks are grouped by user story to keep the fallback, ordinary-FVA regression, and solver-state restoration independently testable.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm the implementation context and reproducibility baseline before code edits.

- [X] T001 Read the active feature artifacts `specs/016-fastbarrier-fallback/spec.md`, `specs/016-fastbarrier-fallback/plan.md`, `specs/016-fastbarrier-fallback/research.md`, `specs/016-fastbarrier-fallback/data-model.md`, `specs/016-fastbarrier-fallback/contracts/fluxVariability-fastBarrier.md`, and `specs/016-fastbarrier-fallback/quickstart.md`
- [X] T002 Inspect current fastBarrier setup and per-reaction solve flow in `src/analysis/FVA/fluxVariability.m`
- [X] T003 Inspect current fastBarrier assertions and solver preparation in `test/verifiedTests/analysis/testFVA/testFVA.m`
- [X] T004 [P] Search available skills for MATLAB coding/linting guidance and record the result in `specs/016-fastbarrier-fallback/tasks.md` or the implementation receipt required by T024

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish the failing behaviour and the exact solver-status boundary every story depends on.

**CRITICAL**: No user story implementation can begin until this phase is complete.

- [X] T005 Run the focused pre-fix `PFK`/`PPS` fastBarrier probe from `specs/016-fastbarrier-fallback/quickstart.md` and capture the observed failure summary for the implementation receipt
- [X] T006 Confirm in `src/analysis/FVA/fluxVariability.m` that fallback activation can be scoped to `fastBarrier` LP solves without changing `solveCobraLP.m`
- [X] T007 Confirm in `src/analysis/FVA/fluxVariability.m` that default fastBarrier heuristics are still assigned after the early heuristic-disabling block and note the required adjustment point

**Checkpoint**: Failure reproduced and implementation boundary confirmed.

---

## Phase 3: User Story 1 - Complete FastBarrier FVA Despite Recoverable Solver Numeric Status (Priority: P1) MVP

**Goal**: fastBarrier FVA retries recoverable Gurobi numeric failures with a robust barrier path and returns min/max fluxes matching standard FVA.

**Independent Test**: The focused `PFK`/`PPS` probe from `quickstart.md` exits successfully and prints finite min/max flux values; the full `testFVA` fastBarrier section reaches `fastBarrier mode test passed.`

### Tests for User Story 1

- [X] T008 [P] [US1] Preserve the existing standard-vs-fastBarrier min/max assertions in `test/verifiedTests/analysis/testFVA/testFVA.m` without weakening tolerance or skipping `PFK`/`PPS`
- [X] T009 [P] [US1] Define the focused `PFK`/`PPS` fastBarrier validation command from `specs/016-fastbarrier-fallback/quickstart.md` as the US1 reproducibility check in the implementation receipt

### Implementation for User Story 1

- [X] T010 [US1] Add a fastBarrier-aware retry path around the LP solve in `src/analysis/FVA/fluxVariability.m` so Gurobi native status `NUMERIC` with no valid optimal solution retries the same LP with barrier crossover enabled or defaulted
- [X] T011 [US1] Ensure the retry path in `src/analysis/FVA/fluxVariability.m` preserves LP objective, target reaction, objective sense, bounds, constraints, loop decision, and caller-supplied non-conflicting solver parameters
- [X] T012 [US1] Ensure the retry path in `src/analysis/FVA/fluxVariability.m` returns the retry flux only for valid optimal solutions and otherwise preserves the existing FVA failure semantics
- [X] T013 [US1] Run the focused `PFK`/`PPS` fastBarrier validation command from `specs/016-fastbarrier-fallback/quickstart.md` and record pass/fail evidence for the implementation receipt

**Checkpoint**: User Story 1 is complete when `PFK` and `PPS` fastBarrier calls return finite values and no invalid solver status is treated as success.

---

## Phase 4: User Story 2 - Preserve Standard FVA Behaviour (Priority: P2)

**Goal**: ordinary FVA and existing FVA output modes continue to behave as before.

**Independent Test**: The ordinary non-fastBarrier sections of `testFVA` continue to pass as part of the full `testFVA` run.

### Tests for User Story 2

- [X] T014 [P] [US2] Confirm `test/verifiedTests/analysis/testFVA/testFVA.m` still exercises ordinary FVA, loopless FVA, printLevel, and method variants without adding fastBarrier-specific skips

### Implementation for User Story 2

- [X] T015 [US2] Scope all new logic in `src/analysis/FVA/fluxVariability.m` behind fastBarrier-specific state so calls without `fastBarrier` keep the existing solve path
- [X] T016 [US2] Move or add fastBarrier heuristic disabling in `src/analysis/FVA/fluxVariability.m` after default heuristic assignment so ordinary FVA heuristics remain unchanged
- [X] T017 [US2] Run the full `testFVA` validation command from `specs/016-fastbarrier-fallback/quickstart.md` and record ordinary-FVA and fastBarrier pass/fail evidence for the implementation receipt

**Checkpoint**: User Story 2 is complete when full `testFVA` passes and no ordinary FVA branch was weakened or skipped.

---

## Phase 5: User Story 3 - Keep FastBarrier Solver State Predictable (Priority: P3)

**Goal**: fastBarrier restores the pre-call LP solver after success and after failure.

**Independent Test**: The solver-state preservation command in `quickstart.md` exits successfully and reports the LP solver restored.

### Tests for User Story 3

- [X] T018 [P] [US3] Define the solver-state preservation command from `specs/016-fastbarrier-fallback/quickstart.md` as the US3 reproducibility check in the implementation receipt

### Implementation for User Story 3

- [X] T019 [US3] Update `src/analysis/FVA/fluxVariability.m` so the original LP solver is restored on all fastBarrier exits, including retry failure paths
- [X] T020 [US3] Run the solver-state preservation command from `specs/016-fastbarrier-fallback/quickstart.md` and record pass/fail evidence for the implementation receipt

**Checkpoint**: User Story 3 is complete when solver state is restored after a fastBarrier call and failure paths do not leak the temporary Gurobi selection.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation, diff hygiene, and receipt.

- [X] T021 [P] Review `src/analysis/FVA/fluxVariability.m` for MATLAB standards: no `evalc`, warnings visible, no new `nargin`, full-stack error propagation for any new `try/catch`, minimal `printLevel`-gated output
- [X] T022 [P] Review `test/verifiedTests/analysis/testFVA/testFVA.m` to confirm no existing assertion was weakened, deleted, or skipped
- [X] T023 Run `git status --short` and remove any untracked generated logs, diaries, or temporary `.mat` probe artifacts outside `specs/016-fastbarrier-fallback/`
- [X] T024 Create implementation receipt in `agent-runs/<UTC-timestamp>-fastbarrier-fallback/implementation-receipt.md` with files changed, checks run, pass/fail results, residual unverified behaviour, and final response copied verbatim

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Setup completion and blocks all user stories.
- **US1 (Phase 3)**: Depends on Foundational; MVP and primary user value.
- **US2 (Phase 4)**: Depends on Foundational and should be validated after US1 implementation so full `testFVA` proves the combined path.
- **US3 (Phase 5)**: Depends on Foundational; may be implemented after US1 or alongside US2 if edits are coordinated in `fluxVariability.m`.
- **Polish (Phase 6)**: Depends on all desired user stories.

### User Story Dependencies

- **User Story 1 (P1)**: Start after Foundational; no dependency on US2 or US3.
- **User Story 2 (P2)**: Start after Foundational; final full-test validation should run after US1 code exists.
- **User Story 3 (P3)**: Start after Foundational; coordinates with US1 because both edit `fluxVariability.m`.

### Parallel Opportunities

- T004 can run in parallel with T002/T003 because it only searches skills.
- T008 and T009 can run in parallel because they inspect/define test evidence without source edits.
- T014 can run in parallel with US1 implementation tasks because it inspects the test file while US1 edits source.
- T018 can run in parallel with US2 inspection because it defines a command from quickstart.
- T021 and T022 can run in parallel because they review different files.

---

## Parallel Example: User Story 1

```text
Task: "T008 [P] [US1] Preserve the existing standard-vs-fastBarrier min/max assertions in test/verifiedTests/analysis/testFVA/testFVA.m without weakening tolerance or skipping PFK/PPS"
Task: "T009 [P] [US1] Define the focused PFK/PPS fastBarrier validation command from specs/016-fastbarrier-fallback/quickstart.md as the US1 reproducibility check in the implementation receipt"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and Phase 2.
2. Implement US1 retry behaviour in `src/analysis/FVA/fluxVariability.m`.
3. Validate with the focused `PFK`/`PPS` probe.
4. Stop and confirm no invalid solver status is treated as success.

### Incremental Delivery

1. US1: Recover from fastBarrier `NUMERIC` for valid FVA subproblems.
2. US2: Confirm ordinary FVA and the full verified test remain stable.
3. US3: Confirm solver-state restoration on success and failure.
4. Polish: run final hygiene checks and create the implementation receipt.

### Notes

- Every task above follows `- [ ] T### [P?] [US?] Description with file path`.
- `[P]` marks tasks that touch different files or only gather evidence.
- Do not edit source or tests until the implementation phase is explicitly invoked.
- Do not commit generated logs, diaries, saved LP probe `.mat` files, or temporary MATLAB artifacts.
