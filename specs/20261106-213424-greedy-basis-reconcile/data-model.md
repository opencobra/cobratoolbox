# Data model

## Supplied candidate
One row (left) or column (right) of `param.initialBasis`. Partitioned exactly as in B:
`kept` | `dependent` | `rejected` (`negative` | `accuracy`). Kept candidates occupy `Zpos(1:nKept,:)`
(operative orientation) for the whole run, across restarts.

## Checkpoint
See `contracts/greedyExtremeRayBasis.md`. Internal state (a `containers.Map` handle so `onCleanup` sees updates):

| Key | Type | Invariant |
|---|---|---|
| `Zpos` | sparse, operative orientation | `size(·,1) >= nKept`; first `nKept` rows equal `keptBasis`; non-decreasing row count across restarts |
| `dirty` | logical | true iff `Zpos` holds rays not yet on disk |
| `done` | logical | true after the final verified write; cleanup then does nothing |

Transitions: *init* (write kept basis) → *accept* (grow `Zpos` if larger, set dirty, maybe write) →
*loop top* (write if dirty and interval elapsed) → *return* (write verified basis, `final=true`, done) or
*error/interrupt* (cleanup writes `Zpos`, `final=false`). Orientation transpose happens only inside `writeCheckpoint`.

## Merge baseline
Per-test outcome table `{testName, outcome}` for: old `develop` (`2409e7fd5`), `upstream/develop` (`56dcc3064`),
merged tree. Regression = pass on both baselines and fail after merge. Stored as a results file under
`results/` (gitignored) and summarised in the receipt.
