# Contract delta: `greedyExtremeRayBasis` (reconciled)

Base contract: `specs/20261025-235131-greedy-initial-basis/contracts/greedyExtremeRayBasis.md` (feature B, published
upstream). Everything in it holds unchanged. This file states only what the reconciliation adds.

## New optional parameters

| Field | Default | Meaning |
|---|---|---|
| `param.checkpointFile` | `''` (none) | MAT-file written during the search and on every exit path: normal return, time budget, error, interrupt, and (via the loop-top write) stop by signal within `checkpointInterval`. |
| `param.checkpointInterval` | `300` | seconds between writes during the search; a write happens at the loop top or on acceptance once this much time has passed and unsaved rays exist. |

Both absent → behaviour and every pre-existing output identical to B (FR-007).

## Checkpoint file (format v2; A's unpublished v1 is not read)

| Variable | Content |
|---|---|
| `Zpos` | largest accepted basis so far, **in the caller's orientation**: `nBases x nVar` in `'left'` mode, `nVar x nBases` in `'right'` mode. Always begins with the kept supplied vectors, unchanged and in supplied order. |
| `nBases` | number of rays in `Zpos` |
| `leftRight` | mode it was written in |
| `raysExpected`, `acceptanceTarget`, `operativeFingerprint`, `elapsedTime`, `savedUtc` | run metadata, as in A |
| `final` | `true` only for the write after final verification |

Write is atomic (temporary file, then `movefile`). A failed write on exit warns
`greedyExtremeRayBasis:checkpointFailed` and does not mask the original error.

**Resume recipe** (help text): `C = load(file); param.initialBasis = C.Zpos;` same `leftRight`, same model.

## Status

- Adds `status.checkpointFile` (the file written, or `''`) on **every** return path.
- Keeps every B field: `initialBasisSupplied`, `initialBasisKept`, `initialBasisKeptIndex`,
  `initialBasisDependent(Index)`, `initialBasisRejected(Index|Reason)`, `raysAdded`, `nSignRetries`, `nLPSolves`.
- Does **not** add `raysSeeded`.

## Numerical

`norm(·,'fro')` is taken on the sparse operands (no `full`) at both sites; values are equal to the dense
computation to the last ulp the tests can observe (FR-008).

## Source form

Every function in the file, including the local ones, ends with `end` (FR-009, RunMat compatibility).
