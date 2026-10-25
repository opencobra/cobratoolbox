# Contract: `sammi` subsystem-based subgraph grouping

**Feature**: 20260903-150733-canonicalize-subsystem-matrix
**Public function (unchanged signature)**: `src/visualization/SAMMIM/sammi.m` — `sammi(model, parser, data, secondaries, options)`
**Read, not modified**: `src/analysis/exploration/getModelSubSystems.m`, `src/reconstruction/refinement/buildRxn2subSystem.m` (contract only relies on their existing output; see FR-008)
**Spec linkage**: US2, FR-004, FR-007, FR-011, SC-003, SC-007

## Public call surface

No signature change. `sammi(model,'subSystems', ...)` continues to be the call that splits the model into one subgraph per subsystem (`sammi.m:158-161` today).

## Behavioural contract

1. For a reaction `r` assigned to subsystems `{S_a, S_b}` (nested-cell, multi-subsystem shape), the subgraph data for both `S_a` and `S_b` MUST include `r` in its `.rxns` list.
2. For the pre-existing single-subsystem-per-reaction case (already covered by `testSammi.m`'s `modelR204` scenario), the grouping output MUST be unchanged from today.
3. `sammi(model,'subSystems', ...)` MUST NOT error for a model whose `subSystems` is uniformly the nested-cell shape. Two independent failure points must both be addressed (research.md R4 and its correction/second finding): (a) `unique(model.(parser))` at `sammi.m:156`, which runs before the `ismember` this contract originally cited; and (b) `makeSAMMIJson.m`'s generic per-reaction-field serializer, which any `sammi()` call reaches regardless of `parser` and which cannot serialize a cell-shaped `subSystems` entry — addressed by flattening a local copy of `model.subSystems` (`;`-joined, matching `model2JSON.m`) before serialization, computed from the raw shape for grouping purposes first.
4. The fix MUST NOT require the caller to have pre-built `model.rxn2subSystem`/`model.subSystemNames` (FR-007) — `sammi` builds whatever lookup it needs internally from `model.subSystems`, exactly as it does today, just without the direct `ismember` call that assumes a flat shape.
5. `sammi` MUST NOT leave `model.subSystems` altered on the caller's model variable after the call returns (FR-011); `testSammi.m`'s `'subSystems'` case MUST add an explicit `isequal` check on `model.subSystems` before/after the call (SC-007).

## Out of scope

- No change to `sammi`'s other parsing modes (`parser` values other than `'subSystems'`), its HTML/rendering output, or its other test cases in `testSammi.m` (case 0, case 2, etc.).
- No GUI/visual verification is required or expected — Constitution Principle III prohibits GUI interaction in tests; the fix is verified by checking the internal per-subsystem reaction-list data `sammi` computes before rendering, exercised headlessly.
