# Accuracy-target invariants (T002) — unmodified source, 2026-10-03

`status.accuracyTarget` from greedyExtremeRayBasis (develop logic, branch @ 4e876fe97), gurobi,
`param = struct('printLevel',0,'maxNewBasisTime',60)`, `SConsistentRxnBool = true`. Bitwise
reference for T006: after extraction into nullspaceAccuracyTarget these MUST be identical.

| Fixture | side | accuracyTarget (%.17g) | derived | regime |
|---|---|---|---|---|
| F1 | left | 3.9968028886505628e-15 | 1 | wellScaled |
| F2 | left | 1.9229626863835637e-15 | 1 | wellScaled |
| F2b | left | 2.6645352591003761e-15 | 1 | wellScaled |
| F3 | left | 1.9229626863835637e-15 | 1 | wellScaled |
| G1 | left | 1.9229626863835641e-15 | 1 | wellScaled |
| ecoliFull | left | 5.8374129083746378e-13 | 1 | wellScaled |
| badly1e-12 | left | 1.5543122344752188e-27 | 1 | badlyScaled |
| well1 | left | 1.5543122344752188e-15 | 1 | wellScaled |
| F2 transposed | right | 1.9229626863835637e-15 | 1 | wellScaled |

## T006 — after extraction into nullspaceAccuracyTarget (2026-10-03)

All 9 values above reproduced **bit-for-bit** (`isequal` true, 9 of 9), same seed and parameters.
testNullspaceAccuracyTarget: PASS. testGreedyExtremeRayBasis: PASS (78.6 s).
