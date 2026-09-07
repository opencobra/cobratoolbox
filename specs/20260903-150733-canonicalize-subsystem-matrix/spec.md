# Feature Specification: Subsystem Matrix Canonicalization

**Feature Branch**: `20260903-150733-canonicalize-subsystem-matrix`

**Created**: 2026-09-03

**Status**: Draft

**Input**: User description: "Finish canonicalising reaction subsystem handling using the rxn2subSystem incidence-matrix approach introduced in PR #2362. model.subSystems exists in three legacy forms: char, cell of char, or nested cells for reactions assigned to multiple subsystems. These formats must remain fully supported as the input and interchange representation. Do not require callers to migrate or rewrite model.subSystems. buildRxn2subSystem.m already converts all three forms into model.rxn2subSystem (an rxnNum x subsystemNum logical matrix) and model.subSystemNames (an ordered subsystem list). isReactionInSubSystem.m, findRxnsFromSubSystem.m and isSameCobraModel.m already use this representation. Goal: extend rxn2subSystem/subSystemNames as the internal read/query/comparison representation where appropriate, without deleting or modifying model.subSystems as a side effect. Evaluate and update: getModelSubSystems.m, which still parses model.subSystems directly; sammi.m, whose direct ismember(model.subSystems, ss{i}) call fails for nested multi-subsystem models; verifyModel.m and COBRA_structure_fields.tab so rxn2subSystem and subSystemNames are documented and validated as optional derived fields. Fix these existing bugs rather than preserving them: (1) model2JSON.m currently writes only the first subsystem for reactions assigned to multiple subsystems; (2) verifyModel.m currently skips subSystems validation entirely. Out of scope: model2xls.m and xls2model.m, which already round-trip multiple subsystems correctly. Compatibility requirements: preserve existing function signatures and behaviour; support all three legacy model.subSystems formats; never destructively rewrite or remove model.subSystems during read/query operations; keep all existing tests for getModelSubSystems, findRxnsFromSubSystem, isReactionInSubSystem, buildRxn2subSystem, writeSBML and isSameCobraModel passing unchanged."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Multi-subsystem reactions survive JSON export (Priority: P1)

A modeller exports a COBRA model to JSON (`model2JSON`) where one or more reactions belong to more than one subsystem (`model.subSystems{i}` is a cell array with more than one name). Today the exporter silently keeps only the first name and discards the rest, with no warning — a modeller reloading or sharing the JSON gets an incomplete model with no indication data was lost.

**Why this priority**: Silent data loss on export is the most severe defect in scope — it corrupts a saved artifact without any signal to the user, and is the easiest to trigger (any multi-subsystem reaction).

**Independent Test**: Build a small model where at least one reaction has two subsystem names, call `model2JSON`, parse the resulting file, and confirm all subsystem names for that reaction are present. Can be verified without any of the other user stories.

**Acceptance Scenarios**:

1. **Given** a model with a reaction whose `subSystems` entry is `{'Glycolysis','Pentose Phosphate'}`, **When** the model is exported via `model2JSON`, **Then** the emitted JSON for that reaction lists both subsystem names.
2. **Given** a model where every reaction has exactly one subsystem (flat char or single-element cell, the common case today), **When** the model is exported via `model2JSON`, **Then** the emitted JSON is byte-for-byte identical to the output before this change.

---

### User Story 2 - Subsystem-based visualization groups multi-subsystem reactions correctly (Priority: P2)

A modeller opens `sammi(model,'subSystems')` to split a model into one subgraph per subsystem. Today the grouping compares `model.subSystems` directly with `ismember`, which only works when every reaction has a single subsystem name; a reaction assigned to more than one subsystem (nested-cell format) is silently omitted from some or all of the subgraphs it belongs to.

**Why this priority**: A visibly wrong visualization is a real, reproducible defect for any multi-subsystem model, but it is less severe than silent data loss on disk (User Story 1) — the user can still inspect `model.subSystems` directly to catch the discrepancy.

**Independent Test**: Call the internal subsystem-grouping logic (headless, no browser) on a fixture model with at least one multi-subsystem reaction and confirm that reaction appears in the reaction list of every subsystem it belongs to.

**Acceptance Scenarios**:

1. **Given** a model where reaction `R1` belongs to both `SubA` and `SubB`, **When** `sammi(model,'subSystems')` builds its per-subsystem reaction lists, **Then** `R1` appears in both the `SubA` and `SubB` lists.
2. **Given** the existing single-subsystem-per-reaction fixture already covered by `testSammi.m`, **When** the same call is made, **Then** the grouping output is unchanged from today.

---

### User Story 3 - `getModelSubSystems` is internally consistent with the rest of the matrix-based functions (Priority: P3)

`getModelSubSystems` is the function that produces the canonical subsystem name list that `buildRxn2subSystem` (and, transitively, `isReactionInSubSystem`/`findRxnsFromSubSystem`/`isSameCobraModel`) already consume — `buildRxn2subSystem` delegates its own name-enumeration to `getModelSubSystems` today. `getModelSubSystems` itself, however, computes that list through three overlapping code branches (one per legacy shape) where one branch (the dedicated flat-cell-of-char path) is unreachable dead code, since the flag guarding it is computed identically to the condition it's supposed to distinguish from — every flat-cell-of-char model is silently routed through the generic nested-cell branch instead (research.md R8). This is a maintainability gap, not a user-visible defect: the surviving code path's output is correct today for all three legacy shapes.

**Why this priority**: Lower urgency than User Stories 1-2 because current output is already correct; the value is consistency and reduced duplicate logic for future subsystem work.

**Independent Test**: Run `getModelSubSystems` against fixtures in all three legacy `subSystems` shapes (flat char, flat cell, nested cell) and confirm the returned name set is identical, element-for-element, to what the function returns today.

**Acceptance Scenarios**:

1. **Given** a model whose `subSystems` is a nested cell array (some reactions with more than one subsystem), **When** `getModelSubSystems(model)` is called, **Then** the returned list equals today's output (same names, same de-duplication, same order).
2. **Given** a model that only has the legacy `subSystems` field (no pre-existing `rxn2subSystem`/`subSystemNames`), **When** `getModelSubSystems(model)` is called, **Then** it succeeds without requiring the caller to have run `buildRxn2subSystem` first, and `model.subSystems` remains unchanged in the caller's workspace afterward.

---

### User Story 4 - The subsystem field validator stops suppressing all `subSystems` errors (Priority: P4)

Since February 2020, `verifyModel` has carried a workaround that unconditionally deletes any `subSystems` entry from its reported errors, regardless of whether the field is actually malformed — because the single validation regex in `COBRA_structure_fields.tab` could not accept both the flat and nested legacy shapes. As a result, `model.rxn2subSystem`/`model.subSystemNames` are not registered as known fields at all, and genuinely malformed `subSystems` data (for example non-string, non-cell entries) is never reported.

**Why this priority**: Lowest immediate user impact — it is a validation/tooling gap rather than a defect a modeller is likely to notice day-to-day — but it is the foundation that lets the toolbox trust `subSystems`/`rxn2subSystem` data going forward.

**Independent Test**: Run `verifyModel` against (a) a fixture in each legal legacy shape and confirm no `subSystems` error is reported, and (b) a fixture with a genuinely malformed `subSystems` entry (for example a numeric value in place of a string) and confirm an error is reported for that position.

**Acceptance Scenarios**:

1. **Given** a model whose `subSystems` field is validly flat (cell array of char), **When** `verifyModel` runs its field check, **Then** no `subSystems` error is reported.
2. **Given** a model whose `subSystems` field is validly nested (cell array of cell arrays of char), **When** `verifyModel` runs its field check, **Then** no `subSystems` error is reported.
3. **Given** a model with one reaction whose `subSystems` entry is neither a string nor a cell array of strings, **When** `verifyModel` runs its field check, **Then** an error identifying that reaction's position is reported.

---

### Edge Cases

- A reaction with an empty subsystem assignment (`''` or `{}`) MUST NOT appear under any subsystem name in `model2JSON` output, `sammi` grouping, or `getModelSubSystems`'s name list, matching today's behavior.
- A reaction whose subsystem cell contains a duplicate name (e.g. `{'Glycolysis','Glycolysis'}`) MUST be counted once per subsystem, not twice, consistent with today's `buildRxn2subSystem` matrix construction.
- `getModelSubSystems`'s subsystem name ordering (currently alphabetical, from `unique`) MUST stay stable so it continues to correctly index the columns of `model.rxn2subSystem` wherever both are used together.
- A model that already carries a stale `model.rxn2subSystem`/`model.subSystemNames` (built before `model.subSystems` was last edited) is out of scope for this feature: the already-converted functions (`isReactionInSubSystem`, `findRxnsFromSubSystem`) already trust a pre-existing matrix as authoritative today, and this feature does not change that contract.
- `verifyModel`'s existing `testVerifyModel.m` assertion about a `subSystems` validation error (`modelSub.subSystems(20) = {'blubb'}`) is currently guarded by `if isfield(res,'Errors')`; because today's unconditional suppression can remove `results.Errors` entirely when `subSystems` was the only problem found, this assertion may not currently execute. Confirming its current, actual behavior (rather than assuming it already passes meaningfully) is required before changing `verifyModel`, since fixing the suppression will make this assertion live for the first time.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `model2JSON` MUST serialize every subsystem name associated with a reaction when `model.subSystems{i}` is a cell array naming more than one subsystem, not only the first.
- **FR-002**: `model2JSON`'s output for a reaction with exactly one subsystem (in any of the three legacy shapes) MUST be unchanged from today's output.
- **FR-003**: `getModelSubSystems` MUST enumerate unique subsystem names through a single consolidated code path for all three legacy `model.subSystems` shapes (removing the dead, unreachable flat-cell-of-char branch identified in research.md R8), rather than three overlapping shape-specific branches, while returning the same de-duplicated, non-empty name set (same names, same order) it does today for every existing test fixture. (Calling `buildRxn2subSystem` from inside `getModelSubSystems` is not a valid implementation of this requirement: `buildRxn2subSystem` already delegates its own name-enumeration to `getModelSubSystems`, so doing so would recurse infinitely — research.md R8.)
- **FR-004**: `sammi`'s `'subSystems'` grouping mode MUST include a reaction in every subsystem-named subgraph it belongs to, including when `model.subSystems{i}` names more than one subsystem.
- **FR-005**: `COBRA_structure_fields.tab` MUST register `rxn2subSystem` and `subSystemNames` as optional, derived fields (not required on every model) with a validator matching the actual shapes `buildRxn2subSystem` produces (an `rxns x subSystemNames`-length logical/double matrix and an ordered cell array of strings, respectively).
- **FR-006**: `verifyModel` MUST validate `model.subSystems` against a check that accepts both legacy shapes (flat cell array of strings, and nested cell array of cell arrays of strings) and MUST report an error only when the field content matches neither shape, replacing today's unconditional suppression of all `subSystems` errors.
- **FR-007**: None of `getModelSubSystems`, `sammi`'s grouping logic, or `verifyModel`'s field check may require the caller to have pre-generated `model.rxn2subSystem`/`model.subSystemNames`, or to have removed `model.subSystems` — each MUST work correctly when called with only the legacy `model.subSystems` field present, exactly as today.
- **FR-008**: System MUST preserve the documented public interfaces of `buildRxn2subSystem`, `isReactionInSubSystem`, `findRxnsFromSubSystem`, and `isSameCobraModel` exactly as they exist today (signatures, default argument values, and file locations), since they are out of scope for behavioral change in this feature.
- **FR-009**: System MUST define, for each of FR-001 through FR-006 and FR-011, the narrowest automated test in `test/verifiedTests/` that proves the behavior (see Traceability), created where no test currently exists and extended where one does. `model2JSON`'s existing test (`test/verifiedTests/base/testIO/testModel2JSON`, currently missing the `.m` extension and therefore never executed by `test/testAll.m`'s file-discovery pattern) MUST be relocated to the constitutionally-correct `test/verifiedTests/base/testIO/testModel2JSON/testModel2JSON.m` and extended, not left in place or duplicated (research.md R7).
- **FR-010**: None of the changes in this feature invoke a solver or alter solver-facing code paths; system MUST confirm no numerical, solver-status, or performance regression is possible as a result (Principle IV), since subsystem lookups remain pure data-structure operations.
- **FR-011**: `getModelSubSystems`, `sammi`'s grouping logic, and `verifyModel`'s field check MUST NOT delete, overwrite, or otherwise mutate `model.subSystems` as a side effect of reading, querying, or validating it — `model.subSystems` MUST remain present and byte-for-byte identical in the caller's model afterward, regardless of whether the function also builds a working `rxn2subSystem`/`subSystemNames` matrix internally.

### Key Entities

- **`model.subSystems` (legacy field)**: per-reaction subsystem assignment, in one of three shapes — flat char per reaction, flat cell array of char, or nested cell array of cell arrays of char (multiple subsystems per reaction). Remains the primary, backward-compatible interchange format; not modified in place by any function touched in this feature.
- **`model.rxn2subSystem` (derived field)**: an `nRxns x nSubsystems` logical/double incidence matrix produced by `buildRxn2subSystem`, where entry `(i,j)` is true if reaction `i` belongs to subsystem `j`.
- **`model.subSystemNames` (derived field)**: an ordered, de-duplicated cell array of subsystem name strings whose order corresponds to the columns of `model.rxn2subSystem`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: For a model with at least one multi-subsystem reaction, `model2JSON`'s output for that reaction includes every one of its subsystem names, verified by `testModel2JSON.m` (relocated from the existing, currently-undiscovered `test/verifiedTests/base/testIO/testModel2JSON` and extended — research.md R7).
- **SC-002**: `getModelSubSystems` returns an identical name set and order, for all three legacy `subSystems` shapes, before and after this feature — verified by extending `testGetModelSubSystems.m` with a pre/post comparison on existing fixtures.
- **SC-003**: `sammi(model,'subSystems')`'s internal grouping includes a multi-subsystem reaction in every subgraph it belongs to, verified by a new headless (non-GUI) assertion added to `testSammi.m`.
- **SC-004**: `verifyModel` reports zero `subSystems` errors for fixtures in either legal legacy shape, and reports an error identifying the correct reaction position for a fixture with genuinely malformed `subSystems` content — verified by extending `testVerifyModel.m`.
- **SC-005**: All of `testGetModelSubSystems.m`, `testFindRxnsFromSubSystem.m`, `testIsReactionInSubSystem.m`, `testBuildRxn2subSystem.m`, and `testWriteSBML.m` pass with no reduction in assertion count and no change to the functions under test other than `getModelSubSystems`'s internal construction (FR-003). `isSameCobraModel` has no dedicated test file; its behavior is exercised via `testWriteSBML.m` and other consumer tests (e.g. `testConvertOldStyleModel.m`, `testLoadBiGGModel.m`), which MUST also keep passing unchanged.
- **SC-006**: No test introduced or modified by this feature requires a solver, network access, or GUI interaction, consistent with headless CI (Principle III).
- **SC-007**: For each of `getModelSubSystems`, `sammi(model,'subSystems')`, and `verifyModel`, an automated test asserts `model.subSystems` is present and unchanged (`isequal`) in the model after the call, verified by an assertion added to each function's test file.

## Assumptions

- `model2xls.m` and `xls2model.m` are excluded from this feature: they already correctly round-trip multi-subsystem reactions via `;`-joined strings and do not exhibit the data-loss defect being fixed elsewhere.
- "Malformed" `subSystems` content for `verifyModel` test-fixture purposes means an entry that is neither a string nor a cell array of strings (for example a numeric value), consistent with the two candidate validator expressions already present as comments in `verifyModel.m`.
- `sammi.m`'s fix is verified through its internal grouping logic exercised headlessly (as `testSammi.m` already does for its other cases), not through visual/GUI inspection, per Principle III's prohibition on GUI interaction in tests.
- Registering `rxn2subSystem`/`subSystemNames` in `COBRA_structure_fields.tab` marks them optional/derived; it does not make them required on every COBRA model, consistent with how other derived fields are treated.
- `buildRxn2subSystem`'s existing `removeSubSystems` default (`true`) is unchanged by this feature (FR-008); functions newly relying on the matrix internally (`getModelSubSystems`, `sammi`) build their own working matrix without depending on or triggering that removal.
- The exact current pass/fail status of `testVerifyModel.m`'s existing `subSystems`-position assertion (see Edge Cases) will be confirmed by direct execution during planning, before `verifyModel.m` is changed, so the fix's effect on that specific assertion is known rather than assumed.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, FR-002 / SC-001 | testModel2JSON.m, relocated from test/verifiedTests/base/testIO/testModel2JSON (currently `.m`-less and undiscovered — research.md R7) to test/verifiedTests/base/testIO/testModel2JSON/testModel2JSON.m and extended | src/base/io/json/model2JSON.m |
| US2 / FR-004 / SC-003 | testSammi under test/verifiedTests/visualization/testSammi/ | src/visualization/SAMMIM/sammi.m |
| US3 / FR-003, FR-007 / SC-002 | testGetModelSubSystems under test/verifiedTests/analysis/testGetModelSubSystems/ | src/analysis/exploration/getModelSubSystems.m |
| US4 / FR-005, FR-006 / SC-004 | testVerifyModel under test/verifiedTests/reconstruction/testModelGeneration/ | src/reconstruction/modelGeneration/modelVerification/verifyModel.m |
| FR-008 (no regression) / SC-005 | testFindRxnsFromSubSystem, testIsReactionInSubSystem, testBuildRxn2subSystem, testWriteSBML (also exercises isSameCobraModel) | src/analysis/exploration/findRxnsFromSubSystem.m, src/analysis/exploration/isReactionInSubSystem.m, src/reconstruction/refinement/buildRxn2subSystem.m, src/base/io/utilities/writeSBML.m, src/reconstruction/refinement/isSameCobraModel.m |
| FR-011 / SC-007 | testGetModelSubSystems, testSammi, testVerifyModel (each extended with an `isequal` check on `model.subSystems` pre/post call) | src/analysis/exploration/getModelSubSystems.m, src/visualization/SAMMIM/sammi.m, src/reconstruction/modelGeneration/modelVerification/verifyModel.m |
