# Data Model: Subsystem Matrix Canonicalization

This feature introduces no new persistent record types — it works entirely within the existing COBRA model struct's subsystem-related fields. This document defines those fields' shapes precisely enough to implement FR-001 through FR-011 consistently.

## Entity: `model.subSystems` (legacy field, read-only in this feature)

Per-reaction subsystem assignment; `numel(model.subSystems) == numel(model.rxns)`. Exactly one of three shapes, all of which every function touched by this feature MUST continue to accept as input (spec FR-002, FR-007):

| Shape | `model.subSystems{i}` | Example |
|---|---|---|
| Flat char | `char` | `'Glycolysis'` |
| Flat cell (single subsystem) | `1x1 cell` of `char` | `{'Glycolysis'}` |
| Nested cell (multi-subsystem) | `1xN cell` of `char`, `N>=1` | `{'Glycolysis','Pentose Phosphate'}` |

A model's `subSystems` field uses one shape uniformly across all reactions (`convertOldStyleModel.m` normalizes per-load to whichever of the three the source data implies) — this feature does not need to handle a single model mixing shapes across different reactions; R4 in research.md used a mixed fixture only to isolate `ismember`'s failure mode, not as a state this feature must support.

**Invariant preserved by this feature**: no function touched here writes to or deletes `model.subSystems` as a side effect of being called (FR-011, verified per-function by SC-007). It remains the interchange format for every reader/writer not in scope (`xls2model.m`, `model2xls.m`, `writeSBML.m`, `readSBML.m`, etc.).

## Entity: `model.rxn2subSystem` (derived field, newly registered by FR-005)

An `nRxns x nSubsystems` logical (or numeric 0/1) incidence matrix, where `nRxns = numel(model.rxns)` and `nSubsystems = numel(model.subSystemNames)`. Entry `(i,j)` is true iff reaction `i` is assigned to subsystem `j`. Produced today by `buildRxn2subSystem.m`; this feature adds it to `COBRA_structure_fields.tab` (research.md R6) as an **optional** field with:

- `Xdim = 'rxns'` (row count must equal `numel(model.rxns)`)
- `Ydim = 'subSystemNames'` (column count must equal `numel(model.subSystemNames)`)
- `Evaluator`: a type check accepting `islogical(x) || isnumeric(x)`

Not required to be present on every model (`BasicFields = 'false(1)'`); when absent, functions needing it build an ephemeral copy internally rather than requiring the caller to have called `buildRxn2subSystem` first (FR-007).

## Entity: `model.subSystemNames` (derived field, newly registered by FR-005)

An ordered, de-duplicated `1xN` or `Nx1` cell array of subsystem name strings (`char` elements only, no empty-string entries — see spec Edge Cases). Column `j` of `model.rxn2subSystem` corresponds to `model.subSystemNames{j}`. Order is whatever `unique()` produces today (alphabetical) — this feature does not change the ordering rule (spec Edge Cases), only ensures `getModelSubSystems` and `buildRxn2subSystem` compute it via the same code path (FR-003).

Registered with:

- No `Xdim`/`Ydim` (variable length, like other name-list fields)
- `Evaluator`: `iscell(x) && all(cellfun(@(y) ischar(y), x))`
- `BasicFields = 'false(1)'` (optional/derived, same as `rxn2subSystem`)

## Relationships

```text
model.subSystems (legacy, authoritative, 3 possible shapes)
        │
        │  buildRxn2subSystem.m (unchanged; FR-008)
        ▼
model.rxn2subSystem  ◄──── column index ────►  model.subSystemNames
   (nRxns x nSubsystems)                          (nSubsystems x 1, ordered)
        │
        │  consumed by (unchanged; FR-008)
        ▼
isReactionInSubSystem.m, findRxnsFromSubSystem.m, isSameCobraModel.m
        │
        │  now also consumed internally, ephemerally, non-destructively (FR-003, FR-004, FR-007, FR-011)
        ▼
getModelSubSystems.m, sammi.m ('subSystems' grouping mode)
```

No state transitions apply — these are pure derived-data relationships recomputed from `model.subSystems` on demand, not a stateful object lifecycle.
