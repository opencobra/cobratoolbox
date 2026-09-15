# Measurement Environment Baseline

**Task**: T002 | **Date**: 2026-09-15 | **Discharges**: SC-006

| Item | Value |
|---|---|
| MATLAB | 26.1.0.3276743 (R2026a) Update 3 |
| Branch | `20260915-082551-extreme-ray-coverage` |
| Parent commit this sits on | `379bd97f8` (end of `20260914-204640-greedy-left-nullspace-conditioning`) |
| `getCobraSolverParams('LP','feasTol')` | 1e-06 |
| `getCobraSolverParams('LP','optTol')` | 1e-06 |

| Solver | Usable | Version |
|---|---|---|
| gurobi | yes | 1302 |
| mosek | yes | 11.2 |
| glpk | yes | (not reported) |
| pdco | yes | (bundled) |

**R2026a caveat**: errors on non-scalar colon operands; use `1:size(x,1)` explicitly.

**Not on `develop`.** This branch builds on the parent feature's unmerged code and must be
rebased when the parent merges. Every figure recorded here is against the parent branch's
behaviour, not against `develop`.
