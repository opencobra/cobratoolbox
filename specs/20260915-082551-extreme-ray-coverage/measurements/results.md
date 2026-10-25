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

## 5. Full verification sweep, and a defect it exposed

Every model x both solvers, seed 20260915, 1 replicate, 120 s budget.

**The sweep found a real defect before the fix**: mosek on iAF1260 reported
`outcome = 'complete'` with an assembled residual of **3.047e-12 against a target of
~1e-12** — success reported while the number said otherwise, which is the exact class of
defect this work exists to eliminate. Two causes, both introduced by me:

1. **Mismatched norms.** Ray acceptance used a VECTOR inf-norm (max |entry|) while the
   verification used a MATRIX inf-norm (max row sum). Different quantities, so a row
   admitted at the target could be reported above it.
2. **The verification was computed but never acted on.** FR-003 requires verifying on the
   returned object; the residual was measured, reported, and then ignored.

Fixed by using the per-row max-entry metric for both, and by DROPPING rows that fail
verification exactly as a candidate failing acceptance is dropped (FR-003a).

### After the fix — all 16 within target

| Model | gurobi | mosek |
|---|---|---|
| F1 cycle 3x3 | complete 1/1, 5.551e-17 | complete 1/1, 5.551e-17 |
| F2 chain 3x2 | complete 1/1, 5.551e-17 | complete 1/1, 5.551e-17 |
| F2b two pools | complete 2/2, 0 | complete 2/2, 0 |
| F3 empty nullspace | emptyNullspace 0/0 | emptyNullspace 0/0 |
| G1 inconsistent | incomplete 0/1 (correct) | incomplete 0/1 (correct) |
| ecoli_core | complete 5/5, 0 | complete 5/5, 0 |
| iAF1260 | complete 38/38, 0 | complete 38/38, **6.092e-13** |
| iDopaNeuroC (internal) | **complete 105/105, 2.220e-16** | incomplete 99/105, 1.052e-12 |

**16 of 16 report a residual within target, non-negative, with no all-zero rows.**

### Two limitations this sweep makes visible

- **Full coverage on iDopaNeuroC is achieved under gurobi, not under mosek** (99 of 105).
  The targeted objective supplies the aim, but mosek's rays still sometimes miss the
  tighter accuracy target and are dropped. A mosek user gets an honest `'incomplete'`
  with a `'sampling'` shortfall rather than a complete basis.
- **The structural case burns its whole budget.** G1 is decided correctly but takes the
  full 120 s to conclude that nothing is findable, because the attainable dimension is
  only computed after the search gives up. Correct, but wasteful; computing it on first
  stall would end the search immediately.

## 6. Reporting discipline

No attainable residual, runtime or coverage level is promised for any model not measured
here. Every figure is a measurement with its replicate count stated; where one replicate
was used, that is said rather than implied. Whether the gap was closable was a finding of
this work, not an assumption: the answer happens to be yes, by a route the specification
listed only as an open candidate.
