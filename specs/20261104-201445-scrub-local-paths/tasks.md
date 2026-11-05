# Tasks: Remove local machine details from older feature records

**Input**: Design documents from `specs/20261104-201445-scrub-local-paths/`

**Prerequisites**: plan.md, spec.md, research.md, quickstart.md

**Tests**: No function under test, so no test file changes. Validation is in `quickstart.md`.

**Rule for every task**: added lines MUST NOT repeat a removed detail. Change only the named lines.

## Phase 1: Setup

- [X] T001 Confirm the branch is based on `upstream/develop` with `git merge-base`, and that the scan in `specs/20261104-201445-scrub-local-paths/quickstart.md` step 1 lists only files in the spec's Scope section

---

## Phase 2: User Story 2 - Benchmark scripts keep working (Priority: P1)

**Goal**: The six scripts run from any clone and report a missing private input.

**Independent Test**: `quickstart.md` steps 4 and 5.

- [X] T002 [P] [US2] In `specs/20261021-112509-recon-ci-scalability/bench/diffDup.m`, set `benchDir = fileparts(mfilename('fullpath'))` and `cobra = fileparts(fileparts(fileparts(benchDir)))`, and replace the scratch `addpath` with `addpath(fullfile(benchDir, 'ref'))`
- [X] T003 [P] [US2] Make the same two changes in `specs/20261021-112509-recon-ci-scalability/bench/diffRFE.m`
- [X] T004 [P] [US2] In `specs/20261021-112509-recon-ci-scalability/bench/runTest.m`, derive `cobra` the same way
- [X] T005 [P] [US2] In `specs/20261021-112509-recon-ci-scalability/bench/profRun.m`, derive the root the same way and pass `fullfile(cobra, 'src')` to `stageRun`
- [X] T006 [P] [US2] In `specs/20261021-112509-recon-ci-scalability/bench/stageRun.m`, read `COBRA_BENCH_EXTRA_CODE` in place of the fixed private path; add it to the path when set, before `cobraSrc` as today; raise `stageRun:missingExtraCode` naming the variable when the stage is `feasibility` and it is unset
- [X] T007 [P] [US2] In `specs/20261029-120000-checkmodelproperties-scalability/bench/ownCode.m`, read `COBRA_BENCH_MODEL` first and raise `ownCode:missingModel` naming it when unset, add `src` from a root derived with `mfilename('fullpath')`, and load the model from the variable
- [X] T008 [US2] Update `specs/20261021-112509-recon-ci-scalability/bench/README.md`: the scripts find the toolbox and `ref/` themselves, and `COBRA_BENCH_EXTRA_CODE` is needed for the `feasibility` stage only (depends on T002-T007)

**Checkpoint**: `quickstart.md` steps 4 and 5 pass.

---

## Phase 3: User Story 1 - Published records carry no personal machine details (Priority: P1)

**Goal**: The scan is clean.

**Independent Test**: `quickstart.md` step 1.

- [X] T009 [P] [US1] In `specs/20261021-112509-recon-ci-scalability/research.md`, drop the core count and memory size from the environment line; keep the MATLAB and Gurobi versions, the commit and the model name
- [X] T010 [P] [US1] In `specs/20261029-120000-checkmodelproperties-scalability/research.md`, change the machine line to a software line with the same versions and commit
- [X] T011 [P] [US1] In `specs/019-full-site-search/tasks.md`, replace the local checkout prefix with `<gh-pages checkout>`
- [X] T012 [P] [US1] In `specs/20260903-150733-canonicalize-subsystem-matrix/quickstart.md`, replace the clone path with `<path to your COBRA Toolbox clone>`
- [X] T013 [P] [US1] In `specs/20261102-140321-tier1-safe-defect-fixes/tasks.md`, replace the scratch path with `runWithCoverage.m` and state that this throwaway helper was not kept
- [X] T014 [P] [US1] Make the same change in `specs/20261102-142225-tier2-test-pilot/tasks.md`
- [X] T015 [P] [US1] In `deprecated/_testTopology/loop3b_neg_eq.ext`, replace the comment's absolute prefix so that it names `test/additionalTests/testTopology/loop3b_neg_eq.ine`, changing no other byte

**Checkpoint**: `quickstart.md` step 1 passes once Phase 4 is also done.

---

## Phase 4: User Story 3 - The audit trail stays intact (Priority: P2)

**Goal**: Receipts lose only the personal details, and say so.

**Independent Test**: `quickstart.md` step 3.

**Redaction note, added to each receipt under `Other information` (create the section if missing)**: "Redaction (2026-11-05): local machine details were removed or replaced with relative paths or a placeholder, as personal data. No other text changed."

- [X] T016 [P] [US3] In `specs/016-fastbarrier-fallback/agent-runs/20260814T140749Z-fastbarrier-fallback/implementation-receipt.md`, make the two links relative (`../../../../src/analysis/FVA/fluxVariability.m#L190` and `implementation-receipt.md`) and add the note
- [X] T017 [P] [US3] In `specs/017-buildgurobifrommodel-tests/agent-runs/20260817T121447Z-buildgurobifrommodel-characterization/implementation-receipt.md`, make the link relative (`../../../../test/verifiedTests/base/testSolvers/testCharacterizeBuildGurobiProblemFromModel.m`) and add the note
- [X] T018 [P] [US3] In `specs/019-full-site-search/agent-runs/20260817T170429Z-full-site-search-implement/implementation-receipt.md`, replace the prefix with `<gh-pages checkout>` and add the note
- [X] T019 [P] [US3] Make the same change in `specs/019-full-site-search/agent-runs/20260819T110014Z-review-fixes/implementation-receipt.md`
- [X] T020 [P] [US3] In `specs/20261021-112509-recon-ci-scalability/agent-runs/20261022T180000Z-checkduplicate-removefieldentries/implementation-receipt.md`, replace the core count with `[hardware redacted]`, keep the 24 GB cap, and add the note

**Checkpoint**: `quickstart.md` step 3 passes.

---

## Phase 5: Polish

- [X] T021 Run `quickstart.md` steps 1 to 5 and record the results in the implementation receipt
- [X] T023 Keep the commit message and pull request text free of any removed detail, and scan both before use (FR-011)
- [X] T022 Write `specs/20261104-201445-scrub-local-paths/agent-runs/<UTC>-scrub-local-paths/implementation-receipt.md`, with no personal detail in it

## Dependencies

- Phases 2, 3 and 4 are independent of each other and depend only on T001.
- T008 follows T002-T007. T021, T023 and T022 come last.
- All [P] tasks touch different files.

## Implementation Strategy

Do the scripts first, because they carry the only behaviour risk. Validate them before the text edits.
