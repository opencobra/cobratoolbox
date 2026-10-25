# Contract: checkNullspaceBasis (new)

`report = checkNullspaceBasis(model, B, param)`

Inputs
- `model.S`, and `model.SConsistentRxnBool` when `param.internalStoichiometriMatrixLeftNullspace` is true (same meaning and default as greedyExtremeRayBasis).
- `B`: caller-held basis, rows are candidate left-nullspace vectors (`param.leftRight = 'right'`: columns of a right-nullspace basis, mirrored as in greedyExtremeRayBasis).
- `param.feasTol` (may only tighten, as in greedyExtremeRayBasis), `param.maxElementsForSpectrum`, `param.printLevel` (default 1).

Output `report` (struct)
| Field | Meaning |
|---|---|
| `outcome` | `'valid'` (non-negative, full row rank = nullity, every row within target), `'inaccurate'` (some rows exceed target), `'rankDeficient'` (rank < nullity, or more rows than nullity), `'negative'` (any entry < 0); precedence negative > rankDeficient > inaccurate |
| `accuracyTarget`, `accuracyTargetDerived`, `acceptanceTarget`, `regime` | as in greedyExtremeRayBasis (from nullspaceAccuracyTarget) |
| `residualByRow` | `max(abs(B*Sop),[],2)` — the same per-row metric the routine uses |
| `failingRows` | indices with `residualByRow > acceptanceTarget` |
| `residualAbsolute`, `residualScaled` | as in greedyExtremeRayBasis |
| `nonNegative` | `all(B(:) >= 0)` |
| `rankB`, `nullity` | rank of B; `size(Sop,1) - rank(Sop)` |
| `spansNullspace` | `rankB == nullity` |
| `message` | one sentence |

Never errors on a bad basis: the verdict is data. Errors only on malformed input (dimension mismatch).
