# Data Model: generateFullRowRankFR

## Mathematical objects (Principle I)

| Symbol | Domain / size | Meaning |
|---|---|---|
| `S` | ℝ^{m×n} | `model.S`; rows correspond to `model.mets`, columns to `model.rxns` |
| `rxnBool` | {0,1}^n | internal-column selector (resolution order in spec *Background*) |
| `N = S(:, rxnBool)` | ℝ^{m×k} | internal stoichiometric matrix |
| `F = max(−N, 0)` | ℝ^{m×k}_{≥0} | forward (substrate) half-stoichiometry |
| `R = max(N, 0)` | ℝ^{m×k}_{≥0} | reverse (product) half-stoichiometry |
| `[F, R]` | ℝ^{m×2k}_{≥0} | target matrix; goal `rank([F, R]) = m` |
| `y` | ℝ^m | left-null witness, `[F, R]ᵀ y ≈ 0` |

All of these are recomputed from the current model after every edit.

## Input `param` (all fields optional)

| Field | Type | Default | Validation |
|---|---|---|---|
| `rxnBool` | logical n×1 | see spec *Background* | must have length n; must select at least 1 column, else stop with `noInternalReactions` |
| `printLevel` | nonnegative integer | 0 | — |
| `maxIterations` | positive integer | 20 | — |
| `remedy` | char | `'lump'` | must be one of `'lump'` or `'removeRxns'`, else `error` |
| `tol` | positive scalar | 1e-9 | — |
| `irreducibleRemedy` | char | `'stop'` | must be `'stop'` or `'removeMetabolites'`, else `error` `generateFullRowRankFR:badIrreducibleRemedy`. With `'removeMetabolites'`, the default `maxIterations` becomes `m + n` of the input (a provable termination bound, research R12) |

## Output `report` (struct, every field initialised on every return path)

| Field | Type | Content |
|---|---|---|
| `mBefore`, `nBefore` | double | size of `model.S` on input |
| `mAfter`, `nAfter` | double | size of `modelOut.S` |
| `rankBefore`, `rankAfter` | double | rank of the internal `[F, R]` on input and output |
| `rankMethod` | cellstr | one entry per rank decision: `'getRankLUSOL'`, `'sparseQR'` or `'empty'` (m = 0 or no columns) |
| `rankLog` | struct array (`iteration`, `m`, `rankLUSOL`, `rankQR`, `rankMethod`) | every rank decision, including LUSOL/QR disagreements (R7) |
| `rxnBoolSource` | char | `'param'`, `'SConsistentRxnBool'` or `'findSExRxnInd'` |
| `fullRowRank` | logical | `rankAfter == mAfter` |
| `removedMets` | struct array (`met`, `iteration`, `reason`) | `reason` is one of:<br>• `'zeroRow'`<br>• `'lumped'`<br>• `'generalRemoval'` (chosen species, FR-020)<br>• `'orphaned'`: removed as a side effect of another edit, detected by comparing `mets` before and after (research R13) |
| `removedRxns` | struct array (`rxn`, `iteration`, `reason`, `internal`) | `reason` is one of:<br>• `'deadEnd'`<br>• `'identicalRowGroup'` (remedy `removeRxns`)<br>• `'duplicateAfterLump'`<br>• `'generalRemoval'`<br>• `'emptyColumn'`: removed as a side effect, detected by comparing `rxns` before and after<br>`internal` is true if the reaction was internal under the current `rxnBool` |
| `removedCtrs` | struct array (`ctr`, `iteration`) | coupling constraints (`model.ctrs`) removed as a side effect of reaction removal (`removeRxns` default `'exclusive'`); empty if the model has no `C` |
| `lumpedGroups` | struct array (`members`, `representative`, `rxnsRewritten`, `differenceVectors`, `iteration`) | `differenceVectors` is a cell with one entry per non-representative member i: `{met_i, +1; representative, −1}`. Under `remedy = 'removeRxns'`, `representative` is `''` and `rxnsRewritten` is empty |
| `nullVectors` | struct array (`iteration`, `support`, `coefficients`, `residual`, `remedy`, `chosenMet`, `rxnsRemoved`) | `remedy` is `'deadEndRemoval'`, `'generalRemoval'` or `'none'`; `chosenMet` is the species chosen by FR-019 (general removal only, otherwise `''`) |
| `iterations` | double | number of passes executed |
| `generalRemovalUsed` | logical | true if general removal fired in any pass (FR-020) |
| `stopReason` | char | `''` on success; otherwise `'irreducibleDependency'`, `'maxIterations'` or `'noInternalReactions'` |
| `flaggedForReview` | struct array (`rxns`, `sharedSubstrate`, `iteration`) | pairs of reactions removed together by one dead-end remedy that share a substrate, **excluding** substrates common to every reaction in that remedy (for example `h2o[e]`). On Recon3T this yields exactly HEPDECETH/PENDECAETH (`pe15_hs[e]`) and DIDECAETH/TETDECAETH (`pe12_hs[e]`). The function reports them for human review and never alters them beyond the dead-end remedy |

**Empty-report invariant (SC-006)**: for a full-rank input:
- `removedMets`, `removedRxns`, `removedCtrs`, `lumpedGroups`, `nullVectors` and `flaggedForReview` are 0×1 (empty) arrays with the fields above;
- `generalRemovalUsed` = false;
- `iterations` = 1;
- `stopReason` = `''`;
- `fullRowRank` = true;
- `rankBefore` = `rankAfter` = `mBefore` = `mAfter`.

## State transitions (one pass)

```text
compute FR, rank ──full──▶ DONE (fullRowRank = true)
       │ deficient
       ▼
zero rows? ──yes──▶ removeMetabolites + removeTrivialStoichiometry + removeUnusedGenes ──▶ next pass
       │ no
       ▼
identical groups? ──yes──▶ lump (addReaction rewrite, removeMetabolites, internal dup removal)
       │                   or removeRxns (remedy = 'removeRxns') ──▶ next pass
       │ no
       ▼
left-null basis ──▶ dead ends in support? ──yes──▶ removeRxns + removeUnusedGenes ──▶ next pass
                                          └─no──▶ irreducibleRemedy?
                                                   ├─'stop'──────────────▶ STOP (irreducibleDependency, witness reported)
                                                   └─'removeMetabolites'─▶ removeMetabolites(chosen, true, 'inclusive')
                                                                            + removeUnusedGenes ──▶ next pass
pass count = maxIterations ──▶ STOP (maxIterations)
```
