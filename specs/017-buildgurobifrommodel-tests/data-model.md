# Phase 1 Data Model: Characterize buildGurobiProblemFromModel

This feature adds no persistent data or new struct type. It fixes two in-memory
toy COBRA models as test fixtures and documents the exact `gurobiModel` output
each must produce, per the Existing Contract in `spec.md`. Values here are the
concrete assertions the test in `tasks.md` implements — derived by hand-tracing
`buildOptProblemFromModel.m` (pass-through case, no `.C`/`.E` fields) followed by
`buildGurobiProblemFromModel.m`'s field mapping (lines 44-58), not by running
MATLAB.

## Entity: Toy Model 1 — mixed constraint senses, maximization

```matlab
model.rxns      = {'R1'; 'R2'; 'R3'};
model.mets      = {'A'; 'B'; 'C'};
model.S         = [1, -1,  0;
                    0,  1, -1;
                   -1,  0,  1];
model.lb        = [0; 0; 0];
model.ub        = [10; 1000; 1000];
model.c         = [0; 0; 1];
model.b         = [0; 0; 0];
model.csense    = ['E'; 'L'; 'G'];
model.osenseStr = 'max';
```

Chosen to exercise all three `csense` values in one model (User Story 2) and the
`osense == -1` branch (User Story 1, scenario 2).

**Expected `optProblem` (via `buildOptProblemFromModel`, no `.C`/`.E` fields →
pass-through case, lines 197-203 of `buildOptProblemFromModel.m`)**:

| Field | Value |
|-------|-------|
| `A` | `model.S` (unchanged) |
| `b` | `model.b` = `[0;0;0]` |
| `c` | `model.c` = `[0;0;1]` |
| `lb` | `model.lb` = `[0;0;0]` |
| `ub` | `model.ub` = `[10;1000;1000]` |
| `csense` | `['E';'L';'G']` |
| `osense` | `-1` (from `osenseStr = 'max'` via `getObjectiveSense`) |

**Expected `gurobiModel` (via `buildGurobiProblemFromModel`)**:

| Field | Value | Derivation |
|-------|-------|------------|
| `A` | `[1,-1,0; 0,1,-1; -1,0,1]` | `= optProblem.A` |
| `obj` | `[0;0;1]` | `= full(double(optProblem.c))` |
| `rhs` | `[0;0;0]` | `= full(optProblem.b)` |
| `lb` | `[0;0;0]` | `= full(optProblem.lb)` |
| `ub` | `[10;1000;1000]` | `= full(optProblem.ub)` |
| `sense` | `['='; '<'; '>']` | row 1 default `'='` (E), row 2 → `'<'` (L), row 3 → `'>'` (G) |
| `modelsense` | `'max'` | `optProblem.osense == -1` |

## Entity: Toy Model 1b — all-equality constraint senses

Toy Model 1 with `csense` changed to all `'E'` (everything else — `S`, `lb`, `ub`,
`c`, `b`, `osenseStr`— identical to Toy Model 1):

```matlab
modelAllE = <Toy Model 1>;
modelAllE.csense = ['E'; 'E'; 'E'];
```

Exercises spec.md User Story 2, acceptance scenario 2 / the edge case "a model
whose `csense` is entirely `'E'` must still produce a fully-populated `sense`
vector via the unconditional default assignment, not leave it empty."

**Expected `gurobiModel.sense`**: `['='; '='; '=']` (the unconditional default from
line 50 of `buildGurobiProblemFromModel.m`, with neither the `'L'` nor `'G'`
overwrite branch triggered). All other fields identical to Toy Model 1's expected
values.

## Entity: Toy Model 2 — same shape, minimization

Identical to Toy Model 1 except:

```matlab
model.osenseStr = 'min';
```

**Expected `optProblem.osense`**: `1` (from `osenseStr = 'min'`).

**Expected `gurobiModel.modelsense`**: `'min'`. All other fields identical to Toy
Model 1's expected values (isolates the `osense`/`modelsense` branch — User Story
1, scenario 3).

## Entity: Invalid Model — verify=true error path

Toy Model 1 with `model.lb` truncated to the wrong length (2 elements instead of
3, mismatching `model.rxns`/`model.S`'s 3 columns):

```matlab
invalidModel = <Toy Model 1>;
invalidModel.lb = [0; 0];   % length mismatch vs. 3 reactions
```

**Expected behaviour**: `buildGurobiProblemFromModel(invalidModel, true)` MUST
throw an error — `verifyModel(invalidModel, 'FBAOnly', true)` (invoked inside
`buildOptProblemFromModel` when `verify == true`, line 168-172) returns non-empty
findings for the dimension mismatch, and `buildOptProblemFromModel` raises
`'The input model does have inconsistent fields! ...'` before
`buildGurobiProblemFromModel` reaches its own field-mapping code. This is an
existing pass-through behaviour, not new logic — the test asserts the error is
thrown (via `verifyCobraFunctionError` or an equivalent try/catch), not any
specific downstream field state.

## Entity: gurobiModel (output struct under test)

The struct returned by `buildGurobiProblemFromModel`. Field set is exactly
`{A, obj, rhs, lb, ub, sense, modelsense}` for every input in this feature's
scope (`buildGurobiProblemFromModel` adds no conditional fields — unlike
`buildOptProblemFromModel`, it has no `.C`/`.E`/`.F` branch of its own; those
would only ever reach it via `optProblem.A`'s already-merged shape, which none of
this feature's toy models exercise since neither defines `model.C` or `model.E`).

No state transitions — this is a one-shot pure function; there is no lifecycle to
model beyond "called once, returns a struct or throws."
