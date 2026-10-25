# Data model: build-function runtime reductions

No COBRA model field, output, or option is added or changed. The entities below are the
in-memory values the three edits touch and the artefacts the verification produces.

## E1: RXN file parse (`atoms`, `bonds`)

- **Produced by**: `readABRXNFile(rxnId, RXNFileDir)` (unchanged; out of scope).
- **Fields**: `atoms` table (`mets`, `elements`, `metNrs`, `atomTransitionNrs`,
  `isSubstrate`, `instances`); `bonds` table (`mets`, `headAtoms`, `tailAtoms`, `bTypes`,
  `headAtomTransitionNrs`, `tailAtomTransitionNrs`, `isSubstrate`, `instances`).
- **Lifetime rule (FR-006)**: lives only in the loop iteration that parsed it. May be handed
  to `addBondMappingsRXNFile` in the same iteration, and in `checkABRXNFiles` from block 1 to
  block 2 of the same iteration. Never stored in a container, struct array, persistent or
  global variable, and never passed between passes.
- **Validation**: a handed-on parse must come from the same reaction identifier and
  directory as the call it is handed to (guaranteed by the call sites; not re-checked at run
  time, since checking would mean reparsing).

## E2: `bondMappings`

- **Produced by**: `addBondMappingsRXNFile`; 14 variables in this order: the 8 `bonds`
  variables, `bondIndex`, `bondTypeInstance`, `isReacting`, `bondTransitionNrs` (12 after the
  first block; `isReacting` and `bondTransitionNrs` added later; order as the pre-change
  function produces it, which the golden snapshot pins).
- **Energy rows**: one per row that takes a reacting branch; `mets` = reaction identifier,
  `bTypes` 1, `headAtoms`/`tailAtoms` NaN (the build function fills them later),
  `isReacting` ±1, `isSubstrate` 0 for a broken bond and 1 for a formed one,
  `bondIndex` = last row's `bondIndex` + 1 at the time of appending, `bondTransitionNrs` = the
  reacting row's transition number.
- **Invariant (FR-003, FR-005)**: `isequaln` to the pre-change table for every RXN file,
  whether the file was parsed inside or handed in.

## E3: `dBTM.Nodes.BondElmts`

- **Type**: `b x 1` cell of char row vectors, `b = height(dBTM.Nodes)`, column 3 of the nine
  columns added by the `addvars` call.
- **Value**: `BondElmts{i} = [E{h(i)} '-' E{t(i)}]` with
  `E = dATME.Nodes.Element` (last bond-loop reaction's `dATME`),
  `h = dBTM.Nodes.BondHeadAtomIndex`, `t = dBTM.Nodes.BondTailAtomIndex`.
- **Rules**: invalid `h(i)` or `t(i)` (NaN, 0, non-integer, > numel(E)) raises an error;
  `b = 0` leaves the column as `addvars` created it and does not touch `dATME`.

## E4: Golden snapshot (per fixture)

`specs/20260921-160105-build-function-runtime/snapshots/<fixture>-golden-snapshot.mat`, for the seven subsystem fixtures, `ci`, and the derived `ci_missing` and `ci_unparsable` (CI submodel with one RXN file deleted or cut to its header; their `provenance` records the derived kind and altered file instead of corpus counts):

| Field | Content |
|---|---|
| `provenance` | corpus path, top-level `.rxn` count, sorted `flagged_for_review/` names, submodel file and `datenum`, `nRxns`, `nMets`, MATLAB version, git revision of the baseline |
| `outDefault`, `outDense` | the twelve outputs, `1 x 12` cells |
| `classInfo` | `class` and `issparse` of each output in each mode |
| `checkOut` | `modelOut` quality fields (10), `nTotalAtomTransitions`, `nTotalBondTransitions` |
| `bondMappingsByRxn` | `containers.Map`-free struct: `rxnIds` (cell) and `tables` (cell), one per RXN file referenced |
| `consoleText` | `diary` text of one default-mode call |
| `decompBranch` | `'match'`, `'rxnFileCompartmented'` or `'modelCompartmented'`: which decompartmentalisation branch the fixture takes |
| `timingBefore` | the original's 5 run times (also re-measured alternately in compare mode) |
| `countsBefore` | `readABRXNFile` calls, `energy` constructions, energy rows |
| `peakMemBefore` | `VmHWM` of a fresh process run (kB) |

## E5: CI expected-value files

Beside the tests, in `test/verifiedTests/analysis/testReactingMoieties/data/`:

- `addBondMappingsRXNFileExpected.mat`: `rxnIds` (18) and `bondMappings` (cell of tables),
  captured from the unmodified function.
- `checkABRXNFilesExpected.mat`: for each of `base`, `missing`, `unparsable`: the ten
  quality-field vectors and both counts, captured from the unmodified function.

## E6: Results record

`reproducibility-results.md` (append-only), one section per run: date, git revision,
provenance, and per fixture PASS/FAIL for outputs (default, dense, class/sparsity),
`checkABRXNFiles` fields, `bondMappings`, console rule (R5) with the list of differing
stack frames, timing (medians, ratio, noise, profile reference), counts, peak memory.

## State transitions

Only the harness has states: **capture** (baseline source, writes E4/E5; refuses to run if
any of the three source files differs from `64efe1dc8`) → source edit → **compare**
(modified source plus baseline copies on demand; reads E4, appends E6).
