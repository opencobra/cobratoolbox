# Contract: `greedyExtremeRayBasis`

**Feature**: [../spec.md](../spec.md) | **Date**: 2026-09-14
**Source**: `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m`

## Signature

```matlab
[Zpos, Z, status] = greedyExtremeRayBasis(model, param)
```

| Change | Compatibility |
|---|---|
| `status` added as a third output | **Additive.** MATLAB does not evaluate outputs a caller does not request, so every existing `[Zpos, Z] = ...` and `[B, L] = ...` call is unaffected (FR-015). |
| Default acceptance accuracy tightened | **Approved breaking change** (Principle II; spec.md Session 2026-09-14). Results change for callers relying on the default. Migration path: FR-015b. |
| `param.feasTol` retained but clamped | Still accepted, so no caller errors. May tighten acceptance; may never loosen it above the derived target (FR-015a). |

## Inputs

| Input | Required | Notes |
|---|---|---|
| `model.S` | yes | the stoichiometric matrix |
| `model.SConsistentRxnBool` | conditionally | required whenever it is read. Absent + not computed => `'missingField'` outcome, **returned gracefully**, never an undefined-field error (FR-013) |
| `param.leftRight` | no | `'left'` (default) or `'right'`. The full contract applies in both (FR-020) |
| `param.internalStoichiometriMatrixLeftNullspace` | no | default `0`; when true, restricts to the consistent subset |
| `param.feasTol` | no | clamped per FR-015a |
| `param.maxTime`, `param.maxNewBasisTime` | no | each governs the budget its documentation describes (FR-011, FR-012) |
| `param.printLevel` | no | gates console output only; never gates `status` (FR-017) |

## Output matrix by terminal outcome

`Sop` denotes the operative matrix — after consistency restriction and after any
transposition for the requested mode.

| `status.outcome` | `Zpos` | `Z` | Guarantees | Raises |
|---|---|---|---|---|
| `'complete'` | `r x m`, `r == status.raysExpected` | linear basis | every row meets `status.accuracyTarget`; all entries `>= 0`; **no all-zero rows** | no |
| `'incomplete'` | `r x m`, `r == status.raysFound < raysExpected` | linear basis | same per-row guarantees; **no zero padding** (FR-010) | no |
| `'emptyNullspace'` | `0 x m` | `[]` | correct answer, not a failure | no |
| `'badlyScaled'` | `[]` | `[]` | **both** withheld (FR-007); §2.4 diagnosis populated | no |
| `'missingField'` | `[]` | `[]` | `missingFieldName`, `howToObtain` populated | no |

## Invariants — hold on every return

1. **Non-negativity.** `all(Zpos(:) >= 0)`, asserted on the returned object, never
   assumed from the path that produced it (FR-004).
2. **No placeholder rows.** `size(Zpos,1) == status.raysFound`; no all-zero row is ever
   present (FR-010). A caller testing only `size(Zpos,1)` cannot be misled.
3. **Accuracy.** Every row satisfies `status.accuracyTarget`, verified on the returned
   object (FR-003). A row that cannot is dropped, not returned (FR-003a).
4. **Status completeness.** `status` is populated on every call and is complete with all
   console output suppressed (FR-009, FR-017).
5. **Graceful return.** No diagnosed condition raises. Regime B, an empty nullspace and
   a missing field are all returns, not errors (FR-008, FR-013).
6. **Mode symmetry.** Every guarantee holds identically in `'left'` and `'right'` mode
   (FR-020).
7. **Both residual forms.** `residualAbsolute` and `residualScaled` are both populated;
   neither substitutes for the other (FR-016).

## What a caller should branch on

```matlab
[L, Z, status] = greedyExtremeRayBasis(model, param);

switch status.outcome
    case 'complete'
        % safe to augment; status.residualScaled certifies the rank gap
    case 'incomplete'
        % L is valid but spans less than the full nullspace:
        % status.raysFound of status.raysExpected (an estimate --
        % status.raysExpectedIsEstimate is always true).
        % Do NOT treat size(L,1) as evidence of completeness.
    case 'emptyNullspace'
        % correct: there is no left nullspace
    case 'badlyScaled'
        % no basis exists to be had: status.scalingQuantity / scalingValue /
        % scalingBoundary / recommendedRepair say what to repair
    case 'missingField'
        % status.missingFieldName / howToObtain
end
```

The `'complete'` / `'incomplete'` distinction is the one the current downstream guards
cannot make, because today's return pads to full height with zero rows.

## Anti-contract — what this function must never do again

| Never | Because | Requirement |
|---|---|---|
| Return a basis whose rows meet only an absolute feasibility tolerance | it closes the rank gap of any matrix the basis is spliced into | FR-001, FR-003 |
| Return all-zero placeholder rows | `size(L,1)` then falsely reads as complete | FR-010 |
| Return a basis on badly scaled input | no downstream guard can recover the lost information | FR-007 |
| Report only an absolute residual | `1.418e-07` reads as small; scaled it is `2.218e-09`, and it was fatal | FR-016 |
| Raise an undefined-field error on a default-parameter call | `optimalExtremePoolDriver.m:121` does exactly this call | FR-013 |
| Signal a diagnosis only by printing | a caller that suppresses output is entitled to the same information | FR-008, FR-017 |
