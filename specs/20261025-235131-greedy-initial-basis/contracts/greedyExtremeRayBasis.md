# Contract: `greedyExtremeRayBasis` (additive change)

Signature unchanged: `[Zpos, Z, status] = greedyExtremeRayBasis(model, param)`.
Every existing input, output and status field keeps its meaning. All changes are additive.
The single exception, a change of default behaviour, is stated in C4.

## C1. New optional inputs

| Field | Default | Contract |
|---|---|---|
| `param.initialBasis` | absent / `[]` | Candidate non-negative nullspace vectors. Left: `k x m`; right: `n x k` (operative dimensions). Validated, partitioned and kept per [data-model E1/E2](../data-model.md). |
| `param.testHook` | absent | **Test only.** `.targetedSignFirst ∈ {+1,-1}` makes the first targeted objective use the canonically oriented direction with that sign. `.forceTargeted` (logical) uses the targeted objective on every iteration with `0 < nBases < raysExpected`. Absent means exactly today's behaviour. |

## C2. Errors and warnings (identifiers)

| Identifier | When |
|---|---|
| `greedyExtremeRayBasis:initialBasisSize` (error) | `initialBasis` is non-numeric, complex, or has the wrong length for the operative matrix and mode |
| `greedyExtremeRayBasis:keptRowFailedVerification` (error) | the final per-row verification would drop a kept row. This cannot happen, since kept rows passed the same check, so it signals a defect |
| `greedyExtremeRayBasis:keptExceedsNullity` (warning) | `initialBasisKept > raysExpected`; all kept rows are returned, outcome `'complete'` |
| existing `missingField`, `badlyScaled`, `incompleteBasis`, `zeroBasisRow`, `negativeBasisEntry` | unchanged |

## C3. Output guarantees with `initialBasis`

1. `Zpos(1:kept, :)` (right: `Zpos(:, 1:kept)`) is value-identical to `B(keptIndex, :)`
   (right: `B(:, keptIndex)`), in that order.
2. If `kept >= raysExpected`, `nLPSolves = 0` and `raysAdded = 0`.
3. `outcome = 'complete'` iff `raysFound >= raysExpected` (equality unless C2's warning
   applies).
4. Every row meets `acceptanceTarget`, `Zpos >= 0`, and the rank of `Zpos` equals `raysFound`.
5. New status fields per [data-model E5](../data-model.md) are present on every return path.

## C4. Change of default behaviour (sign retry)

On every call, a targeted `+d` vertex that passes accuracy but is dependent triggers one
re-solve with `-d` before a failure is counted. No random draw is consumed. Outputs are
value-identical to the pre-feature function on every run with `nSignRetries = 0`. This is
recorded as a header NOTE.
