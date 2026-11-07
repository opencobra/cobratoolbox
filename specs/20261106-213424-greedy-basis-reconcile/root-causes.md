# Root causes of the three tests failing on old `develop` (`2409e7fd5`)

FR-010, SC-004. Recorded during implementation, 2026-11-07.

| # | Test | Root cause | Evidence | Fix |
|---|---|---|---|---|
| 1 | `testGreedyExtremeRayBasis` | `greedyExtremeRayBasis.m` did not parse. Feature 089 added the local functions `writeCheckpoint` and `finalCheckpoint` without `end`; the RunMat rewrite (`7cc5b6b48`) had terminated every other function, and MATLAB rejects a file that mixes terminated and unterminated functions. The two met in merge `6a391cab3`. Every call errored, so every test calling the function failed. | `checkcode` on `2409e7fd5`: `ENDCT` at lines 1013 and 1029 (the two functions). | Reconciled file terminates all 14 functions (T015, T018); test passes (T020). |
| 2 | `testGreedyExtremeRayBasisResume` | Same parse error as 1. | as 1 | as 1, plus test adapted to the supplied-basis semantics (T013); passes (T020). |
| 3 | `testCheckNullspaceBasis` | Same parse error as 1: the test builds the basis it checks with `greedyExtremeRayBasis` (test line 45). `checkNullspaceBasis.m` itself is clean. (Planning research R4 had missed the call: a truncated grep.) | `checkcode` clean on `checkNullspaceBasis.m` and the test; test calls `greedyExtremeRayBasis(ecoliModel, param)` at line 45. | No change needed; passes on the merged tree (T022). |

One defect, not three: all three failures were the single missing-`end` parse error in `greedyExtremeRayBasis.m`.
