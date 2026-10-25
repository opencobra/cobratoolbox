# Measurement Environment Baseline

**Task**: T002 | **Date**: 2026-09-14 | **Discharges**: SC-008 (every later measurement
is meaningless without the environment it was taken in)

## Platform

| Item | Value |
|---|---|
| MATLAB | 26.1.0.3276743 (R2026a) Update 3 |
| Repository HEAD | `78d4eade5` (branch `20260914-204640-greedy-left-nullspace-conditioning`) |
| OS | Linux (headless-capable) |

**R2026a caveat carried into every measurement below**: this MATLAB release errors on
non-scalar colon operands, so `1:size(x)` idioms that earlier releases silently accepted
now crash. Any probe or source edit in this feature must use `1:size(x,1)` explicitly.

## LP solvers available

| Solver | Usable | Version |
|---|---|---|
| gurobi | yes | 1302 |
| mosek | yes | 11.2 |
| glpk | yes | (not reported) |
| pdco | yes | (bundled) |
| ibm_cplex | **no** | not on path |
| matlab | **no** | not installed |

Session default at baseline: `CBT_LP_SOLVER = mosek`.

R1 and R2 require at least two solvers; **gurobi and mosek** are used, which also matches
the project's standing solver policy (gurobi for LP/QP).

## Tolerances as actually returned

| Parameter | Value |
|---|---|
| `getCobraSolverParams('LP','feasTol')` | **1e-06** |
| `getCobraSolverParams('LP','optTol')` | 1e-06 |

## The number this baseline exists to pin down

`findExtremePool.m:36-39` derives its truncation threshold from the first of these:

```matlab
feasTol = getCobraSolverParams('LP', 'feasTol');   % measured above as 1e-06
epsilon = feasTol*10;                              % therefore 1e-05
```

**`epsilon = 1e-05` is confirmed by measurement, not assumed.** This is the threshold at
which `findExtremePool.m:66` zeroes solution entries, and it is the quantity the R1
hypothesis turns on. Note also the coupling flagged in research.md R5: this threshold
moves whenever a user changes the *global* LP feasibility tolerance, which is an
unrelated setting.
