# Contract: `getModelSubSystems` internal matrix consistency

**Feature**: 20260903-150733-canonicalize-subsystem-matrix
**Public function (unchanged signature)**: `src/analysis/exploration/getModelSubSystems.m` — `[subSystems] = getModelSubSystems(model)`
**Read, not modified**: `src/reconstruction/refinement/buildRxn2subSystem.m` (FR-008 — its signature and default arguments are unchanged; this contract only requires `getModelSubSystems` to reuse its matrix-construction logic, not to change it)
**Spec linkage**: US3, FR-003, FR-007, FR-011, SC-002, SC-007

## Public call surface

No signature change. `getModelSubSystems(model)` continues to take exactly one input and return one output: the de-duplicated cell array of subsystem names.

## Behavioural contract

1. For every one of the three legacy `model.subSystems` shapes, `getModelSubSystems(model)` MUST return the identical name set, in the identical order, that it returns today (research.md R5 confirms today's output is already correct — this is a refactor-for-consistency, not a behavior fix).
2. Internally, the function MUST enumerate names through a single consolidated flatten-then-`unique`-then-filter-empty code path for all three legacy shapes, removing the dead, unreachable flat-cell-of-char branch (research.md R8), rather than three overlapping shape-specific branches. It MUST NOT call `buildRxn2subSystem` internally: `buildRxn2subSystem.m:73` already delegates its own name-enumeration to `getModelSubSystems`, so the reverse call would recurse infinitely (research.md R8).
3. `getModelSubSystems` MUST NOT require `model.rxn2subSystem`/`model.subSystemNames` to already be present on the input model (FR-007); it MUST NOT leave `model.subSystems` altered in the caller's model variable after returning (FR-011) — MATLAB pass-by-value already guarantees this as long as `getModelSubSystems` does not return a mutated `model`, which it does not, it returns only the name list, but `testGetModelSubSystems.m` MUST add an explicit `isequal(modelBefore.subSystems, modelAfter.subSystems)` assertion (SC-007) rather than relying on that guarantee implicitly.

## Out of scope

- No change to how `isReactionInSubSystem.m`, `findRxnsFromSubSystem.m`, or `isSameCobraModel.m` obtain `subSystemNames` (they already consume `model.subSystemNames` if present or call `buildRxn2subSystem` themselves; unaffected by this contract).
