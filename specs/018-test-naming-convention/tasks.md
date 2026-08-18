---

description: "Task list for feature implementation"
---

# Tasks: Single-Test-Per-Function Naming Convention

**Input**: Design documents from `/specs/018-test-naming-convention/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: The three merges and one rename ARE the test-suite change; each is
verified by actually running the affected `.m` file in MATLAB (per quickstart.md),
not by a separate new test.

**Organization**: Tasks are grouped by user story from spec.md: US1 (merges +
rename, P1), US2 (constitution amendment, P1), US3 (live-doc reference cleanup,
P3). The three stories touch disjoint file sets and are independently completable
in any order; sequential US1→US2→US3 execution is listed for a single developer.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Every task names the exact file path

## Path Conventions

MATLAB toolbox layout: tests under `test/verifiedTests/<category>/`; governance at
`.specify/memory/constitution.md`; Spec Kit artifacts under `specs/<feature>/`.

---

## Phase 1: Setup

**Purpose**: Capture a baseline so the "no assertion lost" requirement (FR-003/
004/005) can be checked concretely after each merge, not just asserted by eye.

- [X] T001 Count `assert(` occurrences in each of the six pre-merge files —
  `test/verifiedTests/base/testSolvers/testSolveCobraLP.m`,
  `test/verifiedTests/base/testSolvers/testCharacterizeSolveCobraLP.m`,
  `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m`,
  `test/verifiedTests/analysis/testCharacterizeOptimizeCbModel/testCharacterizeOptimizeCbModel.m`,
  `test/verifiedTests/base/testEntropicFBA/testEntropicFluxBalanceAnalysis.m`,
  `test/verifiedTests/analysis/testCharacterizeEntropicFBA/testCharacterizeEntropicFBA.m`
  — record the six counts (e.g. via `grep -c 'assert('`) for later comparison.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: None of the three user stories share a blocking dependency — they
touch disjoint files (test files vs. the constitution vs. other features' docs).
This phase is a no-op placeholder per the template; proceed directly to Phase 3.

**Checkpoint**: T001's baseline counts are recorded; user-story work can begin.

---

## Phase 3: User Story 1 - A maintainer always finds one, complete test per function (Priority: P1) 🎯 MVP

**Goal**: Merge the three colliding `testCharacterize*` files into their
conventional counterparts (no assertion lost), and rename the fourth
(collision-free) file — leaving zero `testCharacterize*.m` files in the repo.

**Independent Test**: For each of the four functions, `test/verifiedTests/<category>/`
contains exactly one `test<FunctionName>.m`; running it (standalone and through
`runTestSuite`) exercises every assertion from both of its pre-merge sources
(count check against T001's baseline) and passes.

### Implementation for User Story 1

- [X] T002 [US1] Merge `test/verifiedTests/base/testSolvers/testCharacterizeSolveCobraLP.m`
  into `test/verifiedTests/base/testSolvers/testSolveCobraLP.m` per data-model.md
  "Merge 1": insert the characterize file's body (its own `tol`, `prepareTest`,
  `model`/`optProblem` setup, and OPTIMAL/INFEASIBLE/UNBOUNDED/gurobi-barrier loop)
  immediately before the destination's final `cd(currentDir)`; move
  `function model = buildToyModel()` to after that `cd(currentDir)`; update the
  destination header's `Purpose:`/`Authors:` to note the merged feature-009
  characterization coverage (depends on T001).
- [X] T003 [US1] Delete
  `test/verifiedTests/base/testSolvers/testCharacterizeSolveCobraLP.m` (depends on
  T002 passing verification in T004).
- [X] T004 [US1] Run `testSolveCobraLP` standalone in MATLAB; confirm it completes
  with no error and both the original and appended assertion blocks' `fprintf`
  progress messages appear (depends on T002).
- [X] T005 [US1] Merge
  `test/verifiedTests/analysis/testCharacterizeOptimizeCbModel/testCharacterizeOptimizeCbModel.m`
  into `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m` per
  data-model.md "Merge 2": insert before the destination's final `cd(currentDir)`;
  move `function model = buildToyModel()` to after it; update header (depends on
  T001).
- [X] T006 [US1] Delete the
  `test/verifiedTests/analysis/testCharacterizeOptimizeCbModel/` directory
  (file + now-empty directory) (depends on T005 passing verification in T007).
- [X] T007 [US1] Run `testOptimizeCbModel` standalone in MATLAB; confirm it
  completes with no error and both assertion blocks run (depends on T005).
- [X] T008 [US1] Merge
  `test/verifiedTests/analysis/testCharacterizeEntropicFBA/testCharacterizeEntropicFBA.m`
  into `test/verifiedTests/base/testEntropicFBA/testEntropicFluxBalanceAnalysis.m`
  per data-model.md "Merge 3": insert before the destination's final
  `cd(currentDir)` (no local function to move — the characterize file defines
  none); update header (depends on T001).
- [X] T009 [US1] Delete the
  `test/verifiedTests/analysis/testCharacterizeEntropicFBA/` directory (file +
  now-empty directory) (depends on T008 passing verification in T010).
- [X] T010 [US1] Run `testEntropicFluxBalanceAnalysis` standalone in MATLAB;
  confirm it completes with no error and both assertion blocks run (depends on
  T008).
- [X] T011 [US1] [P] Rename
  `test/verifiedTests/base/testSolvers/testCharacterizeBuildOptProblemFromModel.m`
  to `testBuildOptProblemFromModel.m`, updating the header's
  `% The COBRAToolbox: ...m` line and the `which('...')` call, exactly as this
  session already did for `testCharacterizeBuildGurobiProblemFromModel.m` in
  feature 017; run it standalone in MATLAB to confirm it still passes.
- [X] T012 [US1] Run all four merged/renamed tests through the real harness:
  `runTestSuite('test(SolveCobraLP|OptimizeCbModel|EntropicFluxBalanceAnalysis|BuildOptProblemFromModel)$')`;
  confirm all `passed`, none `skipped`/`failed`, and no `testCharacterize*` name
  appears in the result table (depends on T004, T007, T010, T011).
- [X] T013 [US1] Re-count `assert(` occurrences in the three merged destination
  files and confirm each is ≥ the sum of its two pre-merge source counts from
  T001 (no assertion silently dropped) (depends on T002, T005, T008).

**Checkpoint**: `find test -iname "testCharacterize*.m"` returns empty; all four
functions have exactly one passing test file.

---

## Phase 4: User Story 2 - Future characterization work extends, not forks, a function's test (Priority: P1)

**Goal**: Codify the one-file-per-function naming rule in the constitution via its
own amendment process (Sync Impact Report, version bump).

**Independent Test**: Read the amended constitution; the new sub-clause states the
`test<FunctionName>.m` rule and the extend-don't-fork instruction unambiguously,
with the version/Governance metadata correctly bumped.

### Implementation for User Story 2

- [X] T014 [US2] Add a new `#### III-Naming: One Test File Per Function`
  sub-clause to `.specify/memory/constitution.md`, immediately after the existing
  `#### III-Characterization: Legacy Back-Fill Mode` sub-clause (both under
  `### III. Testing, Reproducibility, And Continuous Integration`), stating: every
  test file is named `test<FunctionName>.m` (PascalCase = capitalize only the
  function's leading character); exactly one test file per source function; new
  characterization work extends that existing file rather than creating a second,
  differently-named file (no `Characterize` or other infix).
- [X] T015 [US2] Add a Sync Impact Report HTML comment block at the top of
  `.specify/memory/constitution.md` (above the existing Sync Impact Report
  entries, matching their established format) documenting this MINOR amendment:
  version `1.4.0` → `1.5.0`, the new III-Naming sub-clause, and the retroactive
  file merges/rename applied by this feature.
- [X] T016 [US2] Update the `## Governance` section's closing line in
  `.specify/memory/constitution.md` from `**Version**: 1.4.0 | **Ratified**:
  2026-07-12 | **Last Amended**: 2026-07-17` to `**Version**: 1.5.0 | **Ratified**:
  2026-07-12 | **Last Amended**: 2026-08-17` (depends on T014).
- [X] T017 [US2] [P] Review `.specify/templates/spec-template.md`,
  `checklist-template.md`, `plan-template.md`, and `tasks-template.md` for whether
  the new III-Naming clause requires any template change; record the finding (the
  III-Characterization precedent required none, since it's a binding-by-reference
  rule, not a template section).
- [X] T018 [US2] [P] Review `CLAUDE.md` and `AGENTS.md` for consistency with the
  new clause per the Governance section's amendment requirements; confirm neither
  needs a change (Principle X: the constitution is the single source, `CLAUDE.md`
  is only a pointer).

**Checkpoint**: `grep -n "III-Naming" .specify/memory/constitution.md` finds the
new clause; the file's closing Version line reads `1.5.0`.

---

## Phase 5: Historical records stay historically accurate (Priority: P3)

**Goal**: Update live planning-doc references to the four renamed/merged test
files in features 009, 010, 011, and 017; leave every `agent-runs/*/
implementation-receipt.md` untouched.

**Independent Test**: A repository-wide grep for the four old test file names,
excluding `agent-runs/`, returns zero hits; the same grep including `agent-runs/`
returns unchanged hits (byte-identical to before this feature).

### Implementation for User Story 3

- [X] T019 [US3] Update live-doc references (`spec.md`, `plan.md`, `tasks.md`,
  `research.md`, `data-model.md`, `quickstart.md`, `human-loop.md`,
  `implementation-review.md` — whichever exist) in
  `specs/009-fba-characterization-statusmap/` from
  `testCharacterizeSolveCobraLP`/`testCharacterizeOptimizeCbModel`/
  `testCharacterizeBuildOptProblemFromModel` to their new names; do not touch
  anything under `specs/009-fba-characterization-statusmap/agent-runs/`.
- [X] T020 [US3] [P] Same for `specs/010-gecko-entropic-fba/`
  (`testCharacterizeEntropicFBA` → `testEntropicFluxBalanceAnalysis`), excluding
  its `agent-runs/`.
- [X] T021 [US3] [P] Same for `specs/011-entropicfba-dual-fixes/`, excluding its
  `agent-runs/`.
- [X] T022 [US3] [P] Same for `specs/017-buildgurobifrommodel-tests/` (its
  sibling-test references to `testCharacterizeBuildOptProblemFromModel`), excluding
  its `agent-runs/`.
- [X] T023 [US3] Grep-verify: zero hits for the four old names across
  `specs/*/{spec,plan,tasks,research,data-model,quickstart,human-loop,implementation-review}.md`
  (excluding `agent-runs/`), and confirm every `specs/*/agent-runs/*/
  implementation-receipt.md` that mentions an old name is byte-unchanged from
  before this feature (depends on T019, T020, T021, T022).

**Checkpoint**: SC-006 grep passes exactly as specified in quickstart.md.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T024 Run the quickstart.md validation guide in full (all sections).
- [X] T025 [P] Confirm no `src` file changed: `git diff --stat -- src/` is empty.
- [X] T026 Report files changed, checks run, tests passed/failed, and any
  behaviour not yet verified.
- [X] T027 Create implementation receipt in
  `specs/018-test-naming-convention/agent-runs/<UTC-timestamp>-test-naming-convention/implementation-receipt.md`,
  with the actual final user-facing agent completion response copied verbatim
  into the `Final response` section.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately.
- **Foundational (Phase 2)**: No-op; T001's baseline is the only cross-story
  input, and it's already captured in Setup.
- **User Stories (Phase 3-5)**: Each depends only on T001 (baseline counts) for
  US1's verification step (T013); US2 and US3 have no dependency on T001 at all.
  The three stories touch fully disjoint files and can proceed in any order or in
  parallel across developers; single-developer execution is listed US1 → US2 →
  US3 for a natural "ship the file changes, then the governance change, then the
  paperwork" narrative.
- **Polish (Phase 6)**: Depends on all three user stories being complete.

### User Story Dependencies

- **User Story 1 (P1)**: Depends only on T001. No dependency on US2/US3.
- **User Story 2 (P1)**: No dependency on T001, US1, or US3 — fully independent.
- **User Story 3 (P3)**: No dependency on T001 or US2. Practically sequenced
  after US1 in this list only because it references US1's final file names
  (which are already fully determined by data-model.md, so this is a convenience
  ordering, not a hard blocker).

### Within Each User Story

- Each merge's delete task (T003/T006/T009) follows its own standalone-run
  verification task (T004/T007/T010), not the reverse — never delete the source
  of a merge before confirming the destination actually passes with the merged
  content.
- T012 (harness run) depends on all four individual verifications (T004, T007,
  T010, T011) being green first.
- T013 (assertion-count check) depends on all three merges (T002, T005, T008)
  having been written.

### Parallel Opportunities

- T011 (the collision-free rename) has no dependency on T002-T010 and can run in
  parallel with any of the three merges.
- T017 and T018 (template/CLAUDE.md review) can run in parallel with each other
  and with T014-T016 once T014 exists to review against.
- T020, T021, T022 (the three other features' doc updates) can run in parallel
  with each other once the final file names are known (they already are, from
  data-model.md — no need to wait for T002-T011 to literally complete).
- US1, US2, and US3 can in principle all proceed in parallel (disjoint files);
  this list sequences them for single-developer clarity only.

---

## Parallel Example: User Story 1

```bash
# T011 has no dependency on the three merges and can run alongside them:
Task: "Rename testCharacterizeBuildOptProblemFromModel.m to testBuildOptProblemFromModel.m and verify"
Task: "Merge testCharacterizeSolveCobraLP.m into testSolveCobraLP.m and verify"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001).
2. Complete Phase 3: User Story 1 (T002-T013) — this alone eliminates every
   `testCharacterize*.m` file and is independently mergeable; it satisfies SC-001,
   SC-002, SC-003, SC-004 on its own.
3. **STOP and VALIDATE**: `find test -iname "testCharacterize*.m"` is empty; all
   four tests pass via `runTestSuite`.

### Incremental Delivery

1. Setup → baseline captured.
2. User Story 1 → file-level cleanup complete → validate (MVP).
3. User Story 2 → constitution amended → validate (`grep III-Naming`).
4. User Story 3 → other features' docs cleaned up → validate (SC-006 grep).
5. Polish → full quickstart run, no-`src`-diff confirmation, receipt.

### Single-Developer Note

All three stories are safe to do in any order given their disjoint file sets;
T001→T002...→T027 as listed is simply the most legible single pass.
