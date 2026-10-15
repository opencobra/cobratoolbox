# Contract: `generateFullRowRankFR`

## Signature

```matlab
[modelOut, report] = generateFullRowRankFR(model, param)
```

`model` is any COBRA model with at least the fields `S`, `mets`, `rxns`, `lb` and `ub`. `param` is optional (fields in `data-model.md`).

## Guarantees

1. **Postcondition on success**: `report.fullRowRank == true` means that `rank([F, R]) == size(modelOut.S, 1)` for the internal `[F, R]` of `modelOut`.
2. **Traceability**: every metabolite in `setdiff(model.mets, modelOut.mets)` appears in `report.removedMets`, and every reaction in `setdiff(model.rxns, modelOut.rxns)` appears in `report.removedRxns`. Both carry a reason.
3. **Only reported edits**: the stoichiometric columns of reactions still in `modelOut` are unchanged, except for reactions listed in `report.lumpedGroups(:).rxnsRewritten`. In those, only lumped-away metabolites have left the column.
4. **Field preservation**: every reaction-indexed field of a surviving reaction keeps its value, except `S`, and except `grRules` up to whitespace normalisation (research R6).
5. **External reactions**: an external column is removed only when it has become empty (reason `emptyColumn`), or, with `irreducibleRemedy = 'removeMetabolites'` only, when it contains a species chosen for general removal (reason `generalRemoval`, `internal = false`). Otherwise, an external column's stoichiometry changes in only one way: when a metabolite removed as `zeroRow` (FR-005) or `lumped` (FR-006) also occurs in it, that metabolite's entry leaves the column (`removeMetabolites(model, mets, false)`). A single-metabolite external column then becomes empty and is removed as `emptyColumn`. A multi-metabolite external column (for example a biomass reaction) survives without that entry. (Reconciled at Gate 3, 2026-10-15. On Recon3T, Recon3D and iDopaNeuroC, every external column touched this way had a single metabolite: 29, 23 and 0 columns respectively, all removed as `emptyColumn`.)
5a. **Complete side-effect accounting**: any metabolite, reaction or coupling constraint that disappears because of a reused function's side effects is reported (`orphaned`, `emptyColumn`, `removedCtrs`). The report lists accounts for the whole of `setdiff` between input and output.
6. **No guessing**: when `report.stopReason == 'irreducibleDependency'`, the last `report.nullVectors` entries have `remedy == 'none'` and residual ≤ `tol`, and no edit was made in that pass.
6a. **General removal (opt-in)**: with `irreducibleRemedy = 'removeMetabolites'` and the default `maxIterations`, `report.fullRowRank == true` whenever the input has at least one internal column. General removal never fires in a pass where a specific remedy applies. With the option off, behaviour is identical to guarantee 6.
7. **Unchanged input**: if the input already has full row rank, `isequal(modelOut, model)` holds and every change list is empty.
8. **Determinism**: two identical calls give identical `modelOut` and `report`.
9. **Warnings visible**: no warning raised by a called function is suppressed. With `printLevel = 0` the function itself prints nothing.

## Errors

- `param.remedy` not in `{'lump', 'removeRxns'}`: `error` with identifier `generateFullRowRankFR:badRemedy`.
- `param.irreducibleRemedy` not in `{'stop', 'removeMetabolites'}`: `error` with identifier `generateFullRowRankFR:badIrreducibleRemedy`.
- `param.rxnBool` of wrong length: `error` with identifier `generateFullRowRankFR:badRxnBool`.

## Dependencies (reused unchanged, FR-014)

- `removeMetabolites` (also `removeMetabolites(model, mets, true, 'inclusive')` for general removal)
- `removeTrivialStoichiometry`
- `removeRxns`
- `findRxnsFromMets`
- `findMetsFromRxns`
- `addReaction`
- `checkDuplicateRxn` (`'FR'`, detect only)
- `removeUnusedGenes`
- `findSExRxnInd`
- `getRankLUSOL`
- `verifyModel` (optional final check, `printLevel > 0` only)
