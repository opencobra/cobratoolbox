---
description: "Tasks for the Tier-2 test pilot"
---

# Tasks: Tier-2 test pilot (ten model-manipulation functions)

**Input**: Design documents from `specs/20261102-142225-tier2-test-pilot/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: this feature IS tests; each task writes one test and verifies it.

## Format: `[ID] [P?] [Story] Description`

## Procedure for every US1 task (T003-T012)

1. Read the source function, its help header and research R1/R2. Look at a sibling Tier-1 test in
   the same folder for header and opening style (header blocks: Purpose, Function under test,
   Tier, Coverage exemptions, Known defects documented (NOT tested, NOT fixed here), Authors).
2. Write the test `test<Name>.m` in the folder of the spec selection table. Header: Tier 2 (model
   manipulation, no solver; model loaded through `getDistributedModel`), a "Reference values"
   paragraph stating that counts were recorded from the first run on 2026-11-02 with
   `ecoli_core_model`, no solver, and guard consistency, not independent correctness (Tier 5).
   Opening: save `currentDir`, `fileDir = fileparts(which('test<Name>')); cd(fileDir);`,
   `prepareTest();`, then `model = getDistributedModel('ecoli_core_model.mat');` once, before the
   first `%%`. End with `cd(currentDir)`.
3. One `%%` section per behaviour or branch, each runnable on its own (use only variables defined
   before the first `%%`). Assertions per research R2: structural consistency of the result
   (`size(S)` vs `mets`/`rxns`; every rxns/mets/genes-sized field matches; `rxnGeneMat` size;
   `rules` reference only existing gene indices), content agreement with the input model
   (identifiers kept/removed as documented, S columns, bounds, objective carried over), Tier-5
   counts with exact equality. Expected errors: `assert(verifyCobraFunctionError(...))`.
4. Do not change any `src` file. A defect is recorded in the header (III-Defects format: `- DEFECT:`,
   `SEVERITY:`, `TRIGGER:`, `OBSERVED:`, `EXPECTED:`, `LINES:`) and its input skipped; uncovered
   lines are listed as exemptions with reasons. Do not suppress output (no `evalc` unless the
   captured text is asserted).
5. Run with the coverage helper
   `runWithCoverage.m` (a throwaway helper, not kept in the repository)
   (after `initCobraToolbox(false)`); the test must pass and reach 100% coverage or list every
   missed line. Report runtime of the test.

## Phase 1: Setup

- [X] T001 Confirm the branch is stacked on 20261102-140321-tier1-safe-defect-fixes and `getDistributedModel('ecoli_core_model.mat')` loads
- [X] T002 Confirm none of the ten test files exists yet (III-Naming)

## Phase 2: User Story 1 — ten functions pinned (P1)

**Independent Test**: each test passes with full or documented coverage.

- [X] T003 [P] [US1] Write test/verifiedTests/reconstruction/testModelManipulation/testExtractSubSysModel.m for src/reconstruction/refinement/extractSubSysModel.m (one and several subsystems; a subsystem name not in the model)
- [X] T004 [P] [US1] Write test/verifiedTests/reconstruction/testModelManipulation/testExtractCompModel.m for src/reconstruction/refinement/extractCompModel.m (compartments c and e; intOnlyFlag true/false; updateGenes true/false; unknown compartment symbol → warning and empty)
- [X] T005 [P] [US1] Write test/verifiedTests/reconstruction/testModelManipulation/testKeepCompartment.m for src/reconstruction/refinement/keepCompartment.m (keep c; keep c and e; check removed reactions are exactly those with a metabolite outside the kept compartments)
- [X] T006 [P] [US1] Write test/verifiedTests/reconstruction/testModelManipulation/testOrderModelFields.m for src/reconstruction/refinement/orderModelFields.m (field order follows the field definitions; values unchanged; a non-standard field is kept)
- [X] T007 [P] [US1] Write test/verifiedTests/reconstruction/testModelManipulation/testUpdateFieldOrderForType.m for src/reconstruction/refinement/updateFieldOrderForType.m (permute rxns, mets, genes; every field of that type permuted consistently, S columns/rows and rxnGeneMat permuted; invalid order size errors if documented)
- [X] T008 [P] [US1] Write test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m for src/reconstruction/modelGeneration/removeCompartments.m (remove e into default [c]; explicit newComp; merged metabolites have summed stoichiometry; structural consistency)
- [X] T009 [P] [US1] Write test/verifiedTests/base/testIO/testUtilities/testCreateEmptyFields.m for src/base/io/utilities/createEmptyFields.m (standard rxns/mets/genes fields get the documented default and size; explicit fieldDefinitions; existing field behaviour per header)
- [X] T010 [P] [US1] Write test/verifiedTests/base/testIO/testUtilities/testConvertOldCouplingFormat.m for src/base/io/utilities/convertOldCouplingFormat.m (model without coupling unchanged; model with old A/b coupling rows built from the loaded model converted to C/d/dsense and S/mets/b reduced; printLevel 0 and 1)
- [X] T011 [P] [US1] Write test/verifiedTests/analysis/testExploration/testFindRxnFromCompartment.m for src/analysis/exploration/findRxnFromCompartment.m (compartment [e] and [c]; output pairs reaction IDs and formulas; unknown compartment)
- [X] T012 [P] [US1] Write test/verifiedTests/analysis/testExploration/testFindMetFromCompartment.m for src/analysis/exploration/findMetFromCompartment.m (compartment [e] and [c]; output pairs metabolite IDs and names; unknown compartment)

## Phase 3: User Story 2 — style review (P1)

- [X] T013 [US2] Write specs/20261102-142225-tier2-test-pilot/style-note.md: assertion pattern, model choice, runtime per test, memory, defects found, open questions for the maintainer; stop after this pilot (FR-010)

## Phase 4: User Story 3 — registry (P2)

- [X] T014 [US3] Run `python3 .github/scripts/known_defects.py` to regenerate test/known-defects.md; it exits 0

## Phase 5: Polish

- [X] T015 Run the ten tests in one MATLAB session through `runScriptFile`; `git diff --name-only -- src` is empty
- [X] T016 Write specs/20261102-142225-tier2-test-pilot/agent-runs/<UTC>-implement/implementation-receipt.md
- [X] T017 Commit with the maintainer identity (no co-author line), only this feature's files, and push the branch to `origin` with upstream tracking

## Dependencies

Setup → US1 (T003-T012 all [P]) → US2 and US3 → Polish.

## Parallel example

Two agents: T003-T007 (testModelManipulation) and T008-T012 (other folders).

## Implementation strategy

All ten tests form the MVP; the pilot ends with the style note for maintainer review.
