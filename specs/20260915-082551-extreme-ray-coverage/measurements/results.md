# Feature Measurement Record

**Tasks**: T031 | **Date**: 2026-09-15 | **Environment**: [environment.md](./environment.md)

Campaign-level figures with replicate counts, distinct from the per-call `status`
(FR-008, FR-016a, SC-006).

## 1. The headline result

iDopaNeuroC internal matrix (1244 x 1710, rank 1139, left nullity 105), gurobi,
seed 20260915, 1 replicate per arm:

| Arm | Rays found / expected | Residual absolute | Meets target (1.193e-12)? | Runtime |
|---|---|---|---|---|
| Before (random objective only) | 101 / 105 | 1.185e-16 | incomplete | 180 s, **timed out** |
| mosek default | 105 / 105 | 9.342e-09 | **no** | 44.6 s |
| **After (targeted objective)** | **105 / 105** | **6.828e-15** | **YES** | **4.7 s** |

The augmented matrix built from the complete basis has rank **1244** from SVD at
1e-9/1e-10/1e-11/1e-12 and from `getRankLUSOL` — unanimous at the structural rank.

`status.nTargetedObjectives = 8`, `status.nRestarts = 0`: eight aimed draws replaced a
search that had been failing thousands of random ones.

## 2. Paired comparison (570 rows, 285 points, k from 0 to 98)

| | gurobi | mosek |
|---|---|---|
| basis returned (`vbasis`/`cbasis`) | **285/285** | **0/285** |
| residual median / max | 0 / 2.220e-16 | 9.326e-15 / 7.007e-10 |
| meets accuracy target | 285/285 | 232/285 |
| **independent of current basis** | **195/285 (68.4%)** | **205/285 (71.9%)** |
| solve time median | 0.024 s | 0.043 s |

Pairing audit passed: every solver at a point received the same objective, verified from
`objectiveHash` rather than asserted.

**What this refutes.** The unpaired hit-rate gap (gurobi 0.46%, mosek 9.6%) suggested
mosek finds far more diverse vertices. Matched, the rates are 68.4% against 71.9%. The
gap was **path divergence between independent runs**, not a property of the solvers. Only
a paired design could show this.

## 3. Why solver tuning cannot help (1 objective, each setting against the default)

**The LP has a unique optimum**: maximising a different random direction subject to
staying optimal for the original returns the identical point (difference 0.000e+00).

| Setting | Ray differs from default? |
|---|---|
| `Seed` = 1, 2, 12345 | no |
| `Method` = 0, 1, 2 | no |
| `NumericFocus=3`, `Presolve=0`, `Crossover=0` | no |

And the settings genuinely arrive: `IterationLimit=1` yields `ITERATION_LIMIT`,
`TimeLimit=1e-4` yields `TIME_LIMIT`. So this is a property of the problem, not a
plumbing failure — which is precisely the distinction FR-022 exists to force.

## 4. Why a targeted objective does help (40 trials each, at a basis stalled on 98/105)

7 directions unspanned:

| Objective | New independent accurate ray |
|---|---|
| random (what the search did) | **0 of 40 (0%)** |
| targeted at the unspanned subspace | **40 of 40 (100%)** |

## 5. Reporting discipline

No attainable residual, runtime or coverage level is promised for any model not measured
here. Every figure is a measurement with its replicate count stated; where one replicate
was used, that is said rather than implied. Whether the gap was closable was a finding of
this work, not an assumption: the answer happens to be yes, by a route the specification
listed only as an open candidate.
