# Data Model: greedyExtremeRayBasis initialBasis and sign retry

Spec: [spec.md](spec.md) · Research: [research.md](research.md) · Contract:
[contracts/greedyExtremeRayBasis.md](contracts/greedyExtremeRayBasis.md)

## E1. Supplied basis `B` (`param.initialBasis`)

| Attribute | Definition |
|---|---|
| Shape | left mode `k x m` (rows are candidates); right mode `n x k` (columns are candidates), where `m`/`n` are the OPERATIVE dimensions after any consistency restriction |
| Type | real numeric, full or sparse; `[]` or absent = none |
| Index `i` | position in supplied order (row in left mode, column in right mode), `1..k` |

**Partition.** Every supplied index lands in exactly one of three disjoint sets, in this
order of precedence:

```
supplied (k) ──► rejected  : 'negative'  (any entry < 0)
             │              'accuracy'  (max|v*Sop| > acceptanceTarget)
             ├─► dependent : passes both checks, does not raise the rank of those kept before it
             └─► kept      : passes both checks and raises the rank
```

Invariant: `kept + dependent + rejected = supplied`, and the three index lists are
disjoint, sorted ascending, and cover `1..k` exactly.

Validation runs only when the call reaches the search (`regime` not `'badlyScaled'`, field
present, nullspace non-empty). On the early returns every supplied index is unclassified:
`supplied = k`, the other counts are 0, and the lists are empty.

## E2. Kept rows `Zk` (`nKept x m` after orientation)

- They occupy `Zpos(1:nKept, :)` (left) or `Zpos(:, 1:nKept)` (right), in supplied order.
- They are value-identical to the supplied vectors (FR-004) and are never modified.
- After a restart, `Zpos` is reset to `[Zk; zeros]`, `nBases = nKept`, and
  `nonZeroColumnsBool = any(Zk ~= 0, 1)`.
- They count as accepted rays for the support mask, the rank tests and the targeted
  objective's `G`.

## E3. Added rays

`Zpos(nKept+1 : nBases, :)`, found by the search and judged exactly as today. On completion,
`raysAdded = raysFound - nKept`, which equals `raysExpected - nKept` when `nKept <= raysExpected`.

## E4. Targeted step state (per targeted iteration)

| State | Meaning |
|---|---|
| `d` | unit leading direction of `ker(N')` orthogonal to `span(Zpos(1:nBases,:))`, from `targetedObjective`; sign as returned by `svd`, or canonical (largest-magnitude entry positive) when `testHook.targetedSignFirst` is set |
| `s1` | first sign: `+1`, or `testHook.targetedSignFirst` |
| transitions | solve(`s1*d`) → accuracy fail ⇒ failure (no retry) · independent ⇒ accept · dependent ⇒ `nSignRetries++`, `raysRejectedForDependence++`, solve(`-s1*d`) → judged as any candidate (accept or one failure) |

## E5. Status additions (all return paths)

| Field | Type | Meaning |
|---|---|---|
| `initialBasisSupplied` | double scalar | `k` (0 if absent/empty) |
| `initialBasisKept` | double scalar | `nKept` |
| `initialBasisKeptIndex` | `1 x nKept` double | supplied indices kept, ascending |
| `initialBasisDependent` | double scalar | count dropped as dependent |
| `initialBasisDependentIndex` | row double | their indices |
| `initialBasisRejected` | double scalar | count rejected for sign or accuracy |
| `initialBasisRejectedIndex` | row double | their indices |
| `initialBasisRejectedReason` | `1 x nRejected` cellstr | `'negative'` or `'accuracy'`, aligned with the index list |
| `raysAdded` | double scalar | rays found by the search and returned (`raysFound - initialBasisKept`) |
| `nSignRetries` | double scalar | targeted solves repeated with the opposite sign |
| `nLPSolves` | double scalar | extreme-pool LPs solved by the nominated solver, sign retries included; excludes the shortfall-classification LP and the extra solves of the paired comparison |

Unchanged meanings (FR-011): `raysFound = size(Zpos, 1)` (left) and the count of `Zpos`
columns (right); `raysExpected` = estimated nullity; `raysRejectedForAccuracy` and
`raysRejectedForDependence` count only search candidates (including a `+g` vertex dropped
as dependent before a retry); `nTargetedObjectives` counts targeted steps.
