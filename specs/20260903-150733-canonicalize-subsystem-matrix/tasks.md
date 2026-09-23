# Tasks: Subsystem Matrix Canonicalization

**Input**: Design documents from `/specs/20260903-150733-canonicalize-subsystem-matrix/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md (all present)

**Tests**: Requested — spec.md's FR-009 requires a narrowest automated test per functional requirement, and Constitution Principle III makes tests mandatory for behavioral changes. All tests are MATLAB `test<FunctionName>.m` files under `test/verifiedTests/`, run headlessly, no solver required (FR-010/SC-006).

**Organization**: Tasks are grouped by user story (US1–US4, priority order from spec.md) to enable independent implementation and testing of each.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US4)
- Exact file paths are included in every description

## Path Conventions

Single-project MATLAB toolbox: `src/<domain>/` for source, mirroring `test/verifiedTests/<category>/test<FunctionName>/test<FunctionName>.m` for tests (Constitution III-Naming, IX). Paths below are taken directly from plan.md's Project Structure.

---

## Phase 1: Setup

**Purpose**: Confirm the environment this feature will be implemented and tested in.

- [X] T001 Start headless MATLAB and run `initCobraToolbox(false, 'agent')` from the repo root to confirm the toolbox initializes without a solver (quickstart.md Step 1)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish the "before" baseline every later phase is compared against, and reconfirm the two known defects reproduce exactly as research.md recorded them, before any source file is touched.

**⚠️ CRITICAL**: No user story work should begin until T002–T004 are recorded.

- [X] T002 [P] Run `runtests({'testGetModelSubSystems','testFindRxnsFromSubSystem','testIsReactionInSubSystem','testBuildRxn2subSystem','testWriteSBML'})` (quickstart.md Step 2) and record the pass/fail result and assertion count for each as the FR-008/SC-005 regression baseline — **Result**: all 5 PASS. Assertion (`assert(`) counts: testGetModelSubSystems=4, testFindRxnsFromSubSystem=4, testIsReactionInSubSystem=4, testBuildRxn2subSystem=3, testWriteSBML=3.
- [X] T003 [P] Reproduce, and record the current failure mode of, the two defects this feature fixes: run quickstart.md Step 3's `model2JSON` block against a model with `model.subSystems{1} = {'Glycolysis','Pentose Phosphate'}` and confirm the emitted JSON currently contains only `'Glycolysis'` (research.md R3); separately confirm `sammi(modelUniform,'subSystems',...)` currently throws `Input A of class cell and input B of class char must be cell arrays of character vectors...` on a uniformly-nested-cell `subSystems` model (research.md R4) — **Result**: confirmed both. `model2JSON` on reaction 1 (`ACALD`) emits `"subsystem":"Glycolysis"` only (the injected second name is dropped; verified by scoping the check to reaction 1's own JSON block, since `ecoli_core_model` already legitimately has 8 other reactions in "Pentose Phosphate Pathway" that made a whole-file substring check a false negative on the first attempt). `sammi` throws `Cell array input must be a cell array of character vectors.` on the uniformly-nested-cell fixture.
- [X] T004 Confirm `test/verifiedTests/base/testIO/testModel2JSON` (no `.m` extension) is git-tracked and absent from `test/testAll.m`'s discovery (`git log --oneline -- test/verifiedTests/base/testIO/testModel2JSON`; `getFilesInDir('restrictToPattern','^.*\.m$')` excludes it) so the relocation in T005–T008 has a confirmed "before" state (research.md R7) — **Result**: confirmed. `git log` shows 2 commits (`b96d42730` create, `596fc686c` update); the path fails the `^.*\.m$` pattern `test/testAll.m:113` uses.

**Checkpoint**: Baseline captured — user story implementation can now begin.

---

## Phase 3: User Story 1 - Multi-subsystem reactions survive JSON export (Priority: P1) 🎯 MVP

**Goal**: `model2JSON` must serialize every subsystem name for a reaction assigned to more than one subsystem, while leaving single-subsystem output byte-for-byte unchanged.

**Independent Test**: Build a model with a reaction assigned to two subsystems, call `model2JSON`, parse the resulting file, and confirm both names are present. Verifiable without any other user story.

### Tests for User Story 1

> **NOTE: relocate and run this test first; the new multi-subsystem assertion MUST fail before the implementation task below**

- [X] T005 [US1] `git mv test/verifiedTests/base/testIO/testModel2JSON test/verifiedTests/base/testIO/testModel2JSON/testModel2JSON.m` (create the directory as part of the move) so the existing, git-tracked, 6-model test becomes discoverable by `test/testAll.m` for the first time (research.md R7) — no content change in this task, coverage-preserving move only — **Done**: content verified byte-identical pre/post move.
- [X] T006 [US1] Extend `test/verifiedTests/base/testIO/testModel2JSON/testModel2JSON.m` with: (a) a fixture reaction where `model.subSystems{i} = {'Glycolysis','Pentose Phosphate'}`, asserting the `model2JSON` output for that reaction contains both names (SC-001); and (b) a byte-for-byte comparison of `model2JSON`'s output for an existing single-subsystem reaction against a pre-change reference capture, asserting no diff (FR-002) — **Done**: implemented by scoping the JSON check to each reaction's own `"subsystem"` field value (via its own JSON block, since the model already legitimately contains an unrelated "Pentose Phosphate Pathway" subsystem elsewhere — a whole-file substring check would false-positive) rather than storing a large pre-change JSON blob as a fixture.

### Implementation for User Story 1

- [X] T007 [US1] Fix `src/base/io/json/model2JSON.m:172-177`: when `model.subSystems{i}` is a cell array naming more than one subsystem, emit `"subsystem":"<name1>;<name2>;..."` (semicolon-joined, matching the existing round-trip convention already used by `model2xls.m`/`xls2model.m` for multi-subsystem strings) instead of only `a{1}`; when it is `char` or a `1x1` cell, keep today's single-name output exactly as-is (FR-001, FR-002) — **Done**: `a{1}` replaced with `strjoin(a,';')`, which is a no-op for a 1-element cell so FR-002 holds automatically; `;`-join convention confirmed to match `model2xls.m:119`/`xls2model.m:183`.
- [X] T008 [US1] Update `model2JSON.m`'s help header to document that a reaction assigned to multiple subsystems is serialized as a `;`-joined string in the `"subsystem"` field (Constitution VII-E)
- [X] T009 [US1] Run `runtests('testModel2JSON')` and confirm both the new multi-subsystem assertion (SC-001) and the unchanged-output assertion (FR-002) pass — **Result**: PASS.

**Checkpoint**: User Story 1 fully functional and independently testable — MVP deliverable.

---

## Phase 4: User Story 2 - Subsystem-based visualization groups multi-subsystem reactions correctly (Priority: P2)

**Goal**: `sammi(model,'subSystems')` must include a reaction in every subgraph it belongs to, including nested-cell (multi-subsystem) models, without requiring a pre-built `rxn2subSystem`/`subSystemNames` and without mutating `model.subSystems`.

**Independent Test**: Call `sammi`'s internal subsystem-grouping logic headlessly on a fixture with a multi-subsystem reaction and confirm it appears in every subsystem's reaction list.

### Tests for User Story 2

- [X] T010 [P] [US2] Extend `test/verifiedTests/visualization/testSammi/testSammi.m`'s `'subSystems'` case with: (a) a nested-cell multi-subsystem fixture (reaction `R1` in both `SubA` and `SubB`), asserting `R1` appears in both subgraphs' `.rxns` lists and that the call no longer throws (SC-003); and (b) an `isequal(subSystemsBefore, model.subSystems)` check around the call (SC-007) — this test MUST fail (throw) against today's `sammi.m` before T011 — **Done**: added as case 12, plus an (a) equivalence-oracle check that the new matrix-based grouping matches the pre-fix `unique`/`ismember` grouping exactly (excluding the empty-string name `unique()` spuriously included — a pre-existing `sammi.m` quirk that contradicts spec's own Edge Case and that `buildRxn2subSystem`/`getModelSubSystems` already exclude correctly).

### Implementation for User Story 2

- [X] T011 [US2] Fix `src/visualization/SAMMIM/sammi.m:158-161`: replace the direct `model.rxns(ismember(model.subSystems, ss{i}))` comparison with a lookup tolerant of the nested-cell shape (built the same way `isReactionInSubSystem.m`/`findRxnsFromSubSystem.m` already normalize `model.subSystems`, via an ephemeral `rxn2subSystem`/`subSystemNames` built with `buildRxn2subSystem`), without requiring the caller to have pre-built those fields (FR-004, FR-007) and without writing back to `model.subSystems` (FR-011) — **Done**, with two corrections found via direct execution (research.md R4 amendments): the actual pre-fix failure is `unique()` at line 156 (not `ismember` at line 160), and a second, independent defect in `makeSAMMIJson.m`'s generic per-field serializer (reachable from every `sammi()` branch, not just `'subSystems'`) also had to be worked around by flattening a local copy of `model.subSystems` before serialization, without disturbing the grouping computation (which uses the preserved raw shape) or the caller's model.
- [X] T012 [US2] Update `sammi.m`'s help header to document that `'subSystems'` grouping now includes a reaction in every subsystem it is nested-cell-assigned to (Constitution VII-E)
- [X] T013 [US2] Run `runtests('testSammi')` and confirm the new nested-cell assertions (SC-003, SC-007) pass and the existing single-subsystem-per-reaction case (`modelR204`) is unchanged — **Environment limitation**: `testSammi.m` is gated by `prepareTest('requiredToolboxes',{'statistics_toolbox'})` for its *entire* file (cases 0–12), and the Statistics and Machine Learning Toolbox is not licensed in this environment (`license('test','statistics_toolbox')` returns 0) — a pre-existing constraint unrelated to this change. Verified instead via standalone scripts replicating the test file's logic outside the toolbox gate: case 12's new assertions (equivalence oracle + nested-cell grouping + non-mutation) all PASS; a regression script replicating cases 0–3 (empty parser, `subSystems` on `Recon2.v04`/`modelR204`, an unrelated `compartment` parser, `subSystems` on `ecoli_core_model`) all PASS. Cases 4–11 and the full in-harness run remain unverified in this environment; recommend a CI run (which has the toolbox) before merge.

**Checkpoint**: User Stories 1 and 2 both independently functional.

---

## Phase 5: User Story 3 - `getModelSubSystems` is internally consistent with the matrix-based functions (Priority: P3)

**Goal**: `getModelSubSystems` computes its name list via the same matrix construction `buildRxn2subSystem` performs, with no output change and no `model.subSystems` mutation.

**Independent Test**: Run `getModelSubSystems` against fixtures in all three legacy shapes and confirm the returned name set is identical, element-for-element, to today's output.

### Tests for User Story 3

- [X] T014 [P] [US3] Extend `test/verifiedTests/analysis/testGetModelSubSystems/testGetModelSubSystems.m` with: (a) a pre/post comparison asserting `getModelSubSystems(model)` returns the same name set and order as `buildRxn2subSystem(model,false)`'s third output, across all three legacy `subSystems` shapes (SC-002); and (b) an `isequal(subSystemsBefore, model.subSystems)` check around the call (SC-007) — **Done**: the existing test already asserts exact `isequal` output against a hardcoded reference list for all 3 legacy shapes (stronger than a bare pre/post diff), so added a lightweight `buildRxn2subSystem` cross-check plus the SC-007 non-mutation assertion; assertion count 4→6.

### Implementation for User Story 3

- [X] T015 [US3] Refactor `src/analysis/exploration/getModelSubSystems.m` to consolidate its three overlapping shape-specific branches (one of which, `elseif all(cellBool)`, is pre-existing unreachable dead code — research.md R8) into the single flatten-then-`unique`-then-filter-empty algorithm its own nested-cells branch already uses correctly for all three legacy shapes (FR-003); do NOT call `buildRxn2subSystem` (it already delegates to `getModelSubSystems`, so the reverse call recurses infinitely — research.md R8); no other function in this feature reads/writes `model.subSystems` here so FR-011 is inherently satisfied; preserve today's ordering (`unique`-derived, alphabetical) exactly — **Done**: FR-003 corrected in spec.md/plan.md/contracts (research.md R8) before implementing, since the literal original wording was circular.
- [X] T016 [US3] Update `getModelSubSystems.m`'s help header to document the shared matrix-construction internals (Constitution VII-E) — **Done** via inline comments explaining the consolidated algorithm; no `Author:` line added (would have misattributed the change to a named person without confirmation) — the function's USAGE/INPUT/OUTPUT contract is unchanged, so those blocks did not need updating.
- [X] T017 [US3] Run `runtests('testGetModelSubSystems')` and confirm the pre/post name-set comparison (SC-002) and non-mutation check (SC-007) pass with no reduction in assertion count — **Result**: PASS.

**Checkpoint**: User Stories 1–3 all independently functional.

---

## Phase 6: User Story 4 - The subsystem field validator stops suppressing all `subSystems` errors (Priority: P4)

**Goal**: `verifyModel` validates `model.subSystems` against both legacy shapes, reports errors only for genuinely malformed content, and `rxn2subSystem`/`subSystemNames` become registered, validated, optional fields.

**Independent Test**: Run `verifyModel` against a fixture in each legal legacy shape (expect no error) and a fixture with genuinely malformed `subSystems` content (expect an error at the correct position).

### Tests for User Story 4

- [X] T018 [US4] In `test/verifiedTests/reconstruction/testModelGeneration/testVerifyModel.m`, replace the dead-code scenario `modelSub.subSystems(20) = {'blubb'}` (research.md R2: `'blubb'` stays `ischar` and never triggers a validation error under any shape check, so the guarded assertion around it never executes) with `modelSub.subSystems{20} = 5` (a numeric value, neither `char` nor a cell of `char`) and assert `verifyModel(modelSub,'silentCheck',true)` reports an error identifying reaction 20 (SC-004, Acceptance Scenario US4.3); add fixtures for a validly-flat and a validly-nested `subSystems` model each asserting **no** `subSystems` error is reported (SC-004, US4.1–US4.2); add an `isequal(subSystemsBefore, model.subSystems)` check around each `verifyModel` call (SC-007) — **Done**, plus two fixtures closing the FR-005 test-coverage gap flagged during `/speckit-analyze` (finding C1): a model with a valid `rxn2subSystem`/`subSystemNames` pair (expect no error) and one with a dimension-mismatched `rxn2subSystem` (expect an `inconsistentFields.rxn2subSystem` error). Assertion count 2→14.

### Implementation for User Story 4

- [X] T019 [US4] Register `rxn2subSystem` and `subSystemNames` as new rows in `src/base/io/definitions/COBRA_structure_fields.tab` (FR-005): `rxn2subSystem` with `Xdim = 'rxns'`, `Ydim = 'subSystemNames'`, `Evaluator` accepting `islogical(x) || isnumeric(x)`, `BasicFields = 'false(1)'`; `subSystemNames` with no `Xdim`/`Ydim`, `Evaluator = 'iscell(x) && all(cellfun(@(y) ischar(y), x))'`, `BasicFields = 'false(1)'` (data-model.md, research.md R6) — **Done**: modeled on the existing `rxnGeneMat`/`rxnNames` rows; verified by parsing via `getDefinedFieldProperties()` and by direct `eval` of both Evaluator expressions against valid/invalid fixtures before touching `verifyModel.m`.
- [X] T020 [US4] Fix `src/reconstruction/modelGeneration/modelVerification/verifyModel.m:256-273`: replace the unconditional deletion of any `subSystems` entry from `results.Errors.propertiesNotMatched` with a check that accepts both legacy shapes (flat cell array of `char`; nested cell array of cell arrays of `char`) and reports an error, in `checkPresentFields.m`'s existing message format, only when a reaction's entry matches neither shape (FR-006); do not write back to `model.subSystems` (FR-011) — **Done**: since the fixed `COBRA_structure_fields.tab` Evaluator (T019) now correctly discriminates valid from malformed content on its own, the entire suppression block was deleted rather than made conditional — there is nothing left for it to correct.
- [X] T021 [US4] Update `verifyModel.m`'s help header, removing the stale 2020 TODO/workaround comment and documenting the restored `subSystems` validation (Constitution VII-E) — **Done**: confirmed no other reference to the removed workaround/TODO remains in the file.
- [X] T022 [US4] Run `runtests('testVerifyModel')` and confirm both valid-shape fixtures report no `subSystems` error, the malformed fixture reports the correct position (SC-004), and the non-mutation check (SC-007) passes — **Result**: PASS.

**Checkpoint**: All four user stories independently functional.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Confirm no regression across the whole feature and close out the implementation record.

- [X] T023 [P] Run `runtests({'testGetModelSubSystems','testFindRxnsFromSubSystem','testIsReactionInSubSystem','testBuildRxn2subSystem','testWriteSBML','testSammi','testVerifyModel','testModel2JSON'})` (quickstart.md Step 5) and diff assertion counts for the five FR-008/SC-005-pinned tests against the T002 baseline — confirm zero reduction — **Result**: all 7 runnable tests PASS (`testSammi` excluded — see T013's environment-limitation note); assertion counts for the 5 frozen tests unchanged (4,4,3,3; `testGetModelSubSystems` intentionally grew 4→6, it is in scope for extension).
- [X] T024 [P] Run `testConvertOldStyleModel.m` and `testLoadBiGGModel.m` (both exercise `isSameCobraModel`, per spec SC-005's note that it has no dedicated test file) and confirm they still pass unchanged — **Result**: `testLoadBiGGModel` PASS. `testConvertOldStyleModel` FAILS in this environment, but at line 22's `changeCobraSolver('mosek','LP')` (mosek is not installed here) — before any subSystems/`isSameCobraModel` code at line 146+ is reached. Confirmed unrelated to this feature (FR-010: none of this feature's changes touch solver code); recommend confirming in an environment with a licensed LP solver before merge.
- [X] T025 Run quickstart.md end-to-end (Steps 1–5, including the FR-011/SC-007 non-mutation block) as final validation — **Result**: Steps 1, 3, 4 run directly: PASS. Steps 2/5 (`runtests(...)`) already covered by T002/T023. Fixed quickstart.md Step 3's US1 check in the process: as originally written it used a whole-file `contains()` check that would false-pass even against the pre-fix code (same false-negative found during US1 — `ecoli_core_model` already has 8 unrelated reactions in "Pentose Phosphate Pathway"); corrected to scope the check to reaction 1's own JSON block.
- [X] T026 Confirm FR-010: `git diff` the four edited source files (`model2JSON.m`, `sammi.m`, `getModelSubSystems.m`, `verifyModel.m`) and the one edited data file (`COBRA_structure_fields.tab`) and verify none introduces a solver call or solver-facing code path — **Result**: confirmed clean, no solver/network/GUI call introduced in any of the 5 files.
- [X] T027 Report files edited, checks run, and pass/fail results for T002–T026, and note any unverified behavior — see completion report.
- [X] T028 Create the implementation receipt in `agent-runs/<UTC-timestamp>-canonicalize-subsystem-matrix/implementation-receipt.md`, with the actual final user-facing agent completion response copied verbatim into the `Final response` section

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories (T005 onward)
- **User Stories (Phase 3–6)**: All depend only on Foundational; independent of each other (each touches a disjoint set of files: `model2JSON.m` / `sammi.m` / `getModelSubSystems.m` / `verifyModel.m`+`COBRA_structure_fields.tab`)
- **Polish (Phase 7)**: Depends on whichever user stories were completed (T023 requires at least the stories whose tests it runs to be implemented; run last for full coverage)

### User Story Dependencies

- **US1 (P1)**: No dependency on US2/US3/US4 — can ship alone as the MVP
- **US2 (P2)**: No dependency on US1/US3/US4
- **US3 (P3)**: No dependency on US1/US2/US4
- **US4 (P4)**: No dependency on US1/US2/US3 (FR-005's `COBRA_structure_fields.tab` registration is consumed only by `verifyModel`, within this same story)

### Within Each User Story

- Test extension/relocation before implementation (T005–T006 before T007; T010 before T011; T014 before T015; T018 before T019–T020)
- Implementation before the verification run (last task in each phase)

### Parallel Opportunities

- T002, T003 (Foundational) in parallel — different, independent checks
- Once Phase 2 is done, all four user-story phases (3–6) can proceed in parallel — disjoint files
- T023, T024 (Polish) in parallel — independent test runs

---

## Parallel Example: Foundational + all User Stories

```bash
# Foundational, in parallel:
Task: "Run regression baseline (testGetModelSubSystems, testFindRxnsFromSubSystem, testIsReactionInSubSystem, testBuildRxn2subSystem, testWriteSBML)"
Task: "Reproduce model2JSON and sammi defects per research.md R3/R4"

# After Foundational, one story per developer, fully in parallel:
Task: "US1 — relocate+extend testModel2JSON.m, fix model2JSON.m"
Task: "US2 — extend testSammi.m, fix sammi.m"
Task: "US3 — extend testGetModelSubSystems.m, refactor getModelSubSystems.m"
Task: "US4 — extend testVerifyModel.m, register COBRA_structure_fields.tab rows, fix verifyModel.m"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (Setup) and Phase 2 (Foundational)
2. Complete Phase 3 (US1 — `model2JSON` multi-subsystem export)
3. **STOP and VALIDATE**: `runtests('testModel2JSON')` passes; quickstart.md Step 3's `model2JSON` block passes
4. Ship — this alone fixes the most severe defect in scope (silent data loss)

### Incremental Delivery

1. Setup + Foundational → baseline captured
2. US1 → validate independently → ship (MVP)
3. US2 → validate independently → ship
4. US3 → validate independently → ship
5. US4 → validate independently → ship
6. Phase 7 Polish → full-suite confirmation and receipt

### Parallel Team Strategy

With four contributors: one each on US1–US4 after Phase 2 completes; each story's file set (source + its own test file) never overlaps another story's, so no merge coordination is needed until Phase 7.

---

## Notes

- [P] tasks touch different files with no dependency on an incomplete task
- [Story] labels map every Phase 3–6 task to its spec.md user story for traceability
- T005 is a `git mv`, not a content edit — keep it as its own commit/step so the rename history is preserved and reviewable separately from the content extension in T006
- No task in this file requires a solver, network access, or GUI interaction (FR-010/SC-006)
- Every FR-008/SC-005-pinned test (`testFindRxnsFromSubSystem.m`, `testIsReactionInSubSystem.m`, `testBuildRxn2subSystem.m`, `testWriteSBML.m`) and the four out-of-scope files (`isReactionInSubSystem.m`, `findRxnsFromSubSystem.m`, `buildRxn2subSystem.m`, `isSameCobraModel.m`, `model2xls.m`, `xls2model.m`) are read-only throughout — no task above edits them
