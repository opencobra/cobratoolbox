# Contract: `verifyModel` subSystems field validation

**Feature**: 20260903-150733-canonicalize-subsystem-matrix
**Public function (unchanged signature)**: `src/reconstruction/modelGeneration/modelVerification/verifyModel.m` — `results = verifyModel(model, varargin)`
**Data file changed**: `src/base/io/definitions/COBRA_structure_fields.tab` (register `rxn2subSystem`, `subSystemNames`; see data-model.md)
**Spec linkage**: US4, FR-005, FR-006, FR-011, SC-004, SC-007

## Public call surface

No signature change to `verifyModel`. All existing `varargin` options (`massBalance`, `chargeBalance`, `fluxConsistency`, `simpleCheck`, `silentCheck`, etc.) are unaffected.

## Behavioural contract

1. `verifyModel` MUST validate `model.subSystems` against both legacy shapes (flat cell array of `char`, and nested cell array of cell arrays of `char`) — replacing today's `verifyModel.m:256-273` workaround that unconditionally deletes any `subSystems` entry from `results.Errors.propertiesNotMatched` regardless of validity.
2. For a model whose `subSystems` is validly flat or validly nested, `verifyModel` MUST report **no** `subSystems` error.
3. For a model with a reaction whose `subSystems` entry is neither a string nor a cell array of strings (e.g. numeric), `verifyModel` MUST report an error identifying that reaction's position, in the same `results.Errors.propertiesNotMatched.subSystems` location and message format `checkPresentFields.m` already produces for other fields (`'Field does not match the required properties at the following positions: \n<indent><positions>'`).
4. `model.rxn2subSystem` and `model.subSystemNames`, when present on a model, MUST be validated against the field definitions added to `COBRA_structure_fields.tab` (data-model.md) rather than being unknown/unchecked fields; when absent, `verifyModel` MUST NOT report a missing-field error for them (they are optional/derived, not required — spec Assumptions).
5. `verifyModel`'s field check MUST NOT alter `model.subSystems` on the caller's model variable (FR-011); `testVerifyModel.m` MUST add an explicit `isequal` check on `model.subSystems` before/after the call (SC-007).

## Test-fixture note (from research.md R2)

The existing `testVerifyModel.m` scenario (`modelSub.subSystems(20) = {'blubb'}`) does not currently exercise real validation — `'blubb'` remains `ischar` and was never invalid under today's regex, and the guarded assertion around it is dead code. Implementing this contract requires updating that scenario to use a genuinely malformed value (e.g. a non-string, non-cell entry) so Acceptance Scenario US4.3 is actually exercised; `testVerifyModel.m` is explicitly in scope for this feature (not one of the four tests pinned unchanged by FR-008/SC-005).

## Out of scope

- No change to any other `verifyModel` check (mass balance, flux consistency, stoichiometric consistency, database ID checks, etc.).
