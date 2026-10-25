# Public contract: functions touched by this feature

## `buildAtomAndBondTransitionMultigraph` — unchanged

```matlab
[dATM, metAtomMappedBool, rxnAtomMappedBool, M2Ai, Ti2R, dATME, BG, dBTM, M2BiE, M2BiW, BTi2R, BTiE] = ...
    buildAtomAndBondTransitionMultigraph(model, RXNFileDir, options)
```

- Signature, option names and defaults (including `sanityChecks`,
  `bondTransitionMultigraph`, `denseBondMatrices`), output order, dimensions, classes,
  sparsity and values: unchanged (FR-001, FR-002).
- Console: unchanged except that a message printed by `readABRXNFile` may appear fewer
  times, never zero (FR-009). Stack-frame lines may differ (research R5).
- Errors: raised under the same conditions. An invalid bond atom index still errors
  (message may come from a paren index instead of a brace index).

## `checkABRXNFiles` — unchanged

```matlab
[modelOut, nTotalAtomTransitions, nTotalBondTransitions] = checkABRXNFiles(model, RXNFileDir)
```

- Call form, the ten quality fields of `modelOut`, both counts, and all `fprintf` lines:
  unchanged (FR-007). Internal change only: each reaction's RXN file is parsed once.

## `addBondMappingsRXNFile` — two optional trailing inputs

```matlab
[bondMappings] = addBondMappingsRXNFile(rxnfileName, rxnfileDirectory)              % unchanged
[bondMappings] = addBondMappingsRXNFile(rxnfileName, rxnfileDirectory, atoms, bonds) % new
```

| Input | Status | Meaning |
|---|---|---|
| `rxnfileName` | unchanged | reaction identifier, `.rxn` suffix optional |
| `rxnfileDirectory` | unchanged, optional | directory of the file; default `pwd` |
| `atoms` | **new, optional** | the `atoms` table `readABRXNFile(rxnfileName, rxnfileDirectory)` returns |
| `bonds` | **new, optional** | the `bonds` table from the same call |

- If `atoms` or `bonds` is absent or empty, the function parses the file itself, exactly as
  before. Otherwise it does not read the file.
- Guarantee: `isequaln(addBondMappingsRXNFile(id, dir), addBondMappingsRXNFile(id, dir, atoms, bonds))`
  when `[atoms, bonds] = readABRXNFile(id, dir)`.
- Supplying tables from a different file or from `readABRXNFile` with `readBonds = 0` is
  outside the contract (documented in the header `NOTE:`; not checked).
- Output: unchanged (FR-003). Its unbalanced-graph `warning` fires once per call, as before.
- Header: `USAGE:` and `OPTIONAL INPUTS:` updated in the same change (VII-E); `Author:` line
  appended.

Backward compatibility (Principle II): additive only; every existing caller is unaffected.
