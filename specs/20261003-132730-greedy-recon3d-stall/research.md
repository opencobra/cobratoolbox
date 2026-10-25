# Research: Greedy Extreme-Ray Basis Stall on Recon3D

All measurements: MATLAB R2026a, gurobi via `solveCobraLP`, development workstation,
VK model loaded as-is (`load('~/drive/sbgCloud/projects/variationalKinetics/data/Recon3T/Recon3DModel_301_xomics_input_VK_withL.mat')`),
reference call from spec Clarifications. The baseline is in
`measurements/20261003-baseline-diagnosis.md`. Candidate remedies were measured with a
switchable **research prototype**: a scratchpad copy of the routine that is not in the
repository and not source. Each switch maps to one root cause. Seed `rng(20261003)`.

## R0 — All four remedies together (the end-to-end answer)

Reference call, `maxTime` capped at 900 s for safety only (not reached):

| Quantity | Baseline (develop) | All four remedies |
|---|---|---|
| outcome | incomplete / timeBudget | **complete / basisComplete** |
| rays | 237 / 251 (then no progress for 2.8 h by default) | **251 / 251** |
| elapsed | 180 s capped (10 000 s by default) | **35.9 s** |
| candidates rejected for accuracy | 884 | **0** |
| candidates rejected for dependence | 1 | 70 |
| targeted objectives | 0 | 14 |
| LP solves (`nTry`) | ~1 122 | 321 |
| accuracy target | 3.03e-14 (fallback) | **3.945e-13 (derived)** |
| regime | notAssessed | **wellScaled** |
| largest returned residual | 2.8e-17 | 3.5e-16 (<= target) |
| min entry of returned basis | 0 | 0 (no negatives) |
| spectrum cost | skipped | 5.3 s |

### Ablation — each remedy alone, same seed, `maxTime = 150 s`

| Configuration | outcome | rays | accRej | depRej | targeted | time | target |
|---|---|---|---|---|---|---|---|
| R1 only (judge raw ray) | **complete** | **251/251** | 0 | 70 | 14 | 31.0 s | 3.03e-14 (fallback) |
| R2 only (count accuracy failures) | incomplete | 239/251 | 604 | 0 | 580 | 150 s | 3.03e-14 |
| R1 + R2 | **complete** | **251/251** | 0 | 70 | 14 | 30.5 s | 3.03e-14 |
| R3 only (spectrum ceiling) | incomplete | 236/251 | 809 | 0 | 0 | 156 s | 3.95e-13 |

**Reading**: R1 is **necessary and sufficient** for the reported stall. R2 alone makes the
targeted objective fire (580 times), but every targeted ray is then destroyed by the same
truncation, so it cannot finish. R3 alone loosens the target 13x, yet still rejects
truncated rays, which miss even that target by about 9 orders of magnitude. R2 and R3
are kept as **correctness** fixes in their own right (an escalation path that cannot
fire on accuracy failures; a regime assessment that silently disappears on genome-scale
models). They do not drive the speed-up. With R1 in place, R2 is inert on gurobi here
(0 accuracy rejections) and costs nothing.

## R1 — Remedy for root cause 1 (truncation manufactures accuracy failures)

**Decision**: `greedyExtremeRayBasis` judges, and returns, the solver's own solution
vector (`sol.full`, which `findExtremePool` already returns as its second output), with
any negative entries clipped to zero. `findExtremePool` itself is **not changed**.

**Rationale**:
- The accuracy target exists to certify the ray that is *returned*. Truncation at
  `10*feasTol` is a sparsity heuristic belonging to `findExtremePool`'s other callers.
  Inside the greedy search it destroys exact vertices: 20 of 20 replayed rays went from a
  residual <= 3.2e-16 to ~1.6e-4.
- Clipping negatives preserves FR-003 (hard non-negativity). Measured on the R0 run:
  gurobi returned **no** negative entries (`min(sol.full) = 0` on every solve), so
  clipping is a guard and does not change the gurobi path. For a fallback solver that
  returns, say, -1e-17, clipping moves the residual by at most `|clip| * max|S|`, which
  the existing per-row acceptance test then judges. A ray is never returned unjudged.
- Changing nothing in `findExtremePool` satisfies FR-012 (Principle II) by
  construction. `optimalExtremePoolDriver` and the extreme-pathway code see identical
  outputs.

**Alternatives considered**:
- *Add an optional truncation argument to `findExtremePool`*: additive and
  backward-compatible, but it widens a public signature to serve one caller, when the
  untruncated vector is already returned as `sol.full`. Rejected as unnecessary
  surface.
- *Scale-relative truncation (`x < tau*max(x)`)*: still alters the vertex and so still
  needs re-judging, while adding a tolerance to justify. Rejected: it solves no measured
  problem once the raw vector is judged.
- *Loosen the acceptance target*: forbidden (FR-005; parent FR-002).

The paired-comparison instrumentation (`compareSolversAtState`) must apply the same
rule, so that instrumentation on and off judge rays identically (predecessor FR-017
inertness).

## R2 — Remedy for root cause 2 (accuracy rejections never escalate)

**Decision**: an accuracy rejection increments the same failure counter (`nfail`) that
a dependence rejection and an empty solve already increment. Escalation (relaxing
coverage-zeroing, then the targeted objective) therefore fires on a run of accuracy
failures exactly as on a run of dependence failures.

**Rationale**: the counter exists to detect "this objective family is not producing
acceptable new rays". A ray rejected for accuracy is exactly such a non-result. The
empty-solve path already counts as a failure. Excluding the accuracy path was an
inconsistency, and it is the stall mechanism: `nTargetedObjectives = 0` at baseline.

**Alternatives considered**: a separate accuracy-failure counter with its own
threshold. Rejected: it adds a tunable with no measured benefit, and the existing
`nfailMax = 5` already governs the identical decision.

## R3 — Remedy for root cause 3 (spectrum skipped just above the ceiling)

**Decision**: raise `maxElementsForSpectrum` from 5e7 to **1e8**, justified by the
measured cost recorded here.

**Measured**: dense spectrum of the 5824 x 8748 operative matrix (5.09e7 elements):
**5.3 s**, against a 35.9 s complete run (and against a search that otherwise runs
for minutes to hours). Dense storage at 1e8 elements is 0.8 GB.Dense spectrum of the full Recon3D `S` (5824 x 10554, 6.1e7
elements): **6.0 s**. Both are well inside the proposed 1e8 ceiling. **At the ceiling itself**:
`svd(full(A))` of a 7000 x 14286 sparse random matrix (1.0e8 elements, 0.75 GB dense):
**8.3 s**, measured, not extrapolated. So the ceiling is set by measured cost (FR-006):
under 10 s and under 1 GB of dense storage at the boundary.

The ceiling becomes an **additive optional parameter** `param.maxElementsForSpectrum`
(default 1e8). This makes the fallback path testable on a small model in CI (set it below
`numel`) without a genome-scale fixture. The default behaviour is the measured one.

**Rationale**: the ceiling exists to avoid an unaffordable dense factorisation, not to
mark a model class. The derived target here (3.9e-13) is 13x looser than the fallback
(3.0e-14), and both are far above what gurobi delivers (<= 3.5e-16). So the fallback
was not the cause of the stall. It did, however, suppress the regime assessment that the
parent feature added for exactly this class of model. The full Recon3D `S`
(5835 x 10600 = 6.2e7) also falls under the new ceiling.

**Alternatives considered**:
- *Spectrum of `S*S'`* (m x m): halves the cost but squares the condition number,
  degrading `sigma_min+` precisely where the regime test needs it. Rejected.
- *Iterative `svds` for `sigma_1` and `sigma_min+`*: the smallest non-zero singular
  value next to a 251-dimensional zero cluster is unreliable with `svds`. Rejected.
- *Memory-based ceiling*: more general, but platform-dependent and harder to test.
  Rejected in favour of a documented element count.

**Spec impact**: SC-003 as written ("under 10 % of total call time") fails narrowly on
the measured run (5.3 / 35.9 = 15 %), because the remedies made the search itself fast.
SC-003 is therefore re-derived as an absolute bound: spectrum under 15 s on the
development workstation for the reference matrix. This is a spec change made in
planning, flagged for Gate 2.

## R4 — Remedy for root cause 4 (wrong structural verdict)

**Decision**: compute the attainable dimension from a **provably maximal-support** LP:

    maximise sum(z)  s.t.  S'x = 0,  0 <= z <= x,  z <= 1,  x >= 0 (no upper bound)

At an optimum, `z_i = 1` for every metabolite that any non-negative nullspace vector can
carry. Since the feasible `x` form a cone, any reachable coordinate can be scaled up to
1, so `z` is 0/1 and the support threshold is robust (`z > 0.5`). The attainable
dimension is then `|support| - rank(S(support,:))`, as before.

**Rationale**: the current LP (`max sum(x)`, `0 <= x <= 1`) does not guarantee maximal
support, because a vertex optimum can leave a reachable coordinate at zero when raising
it would lower the sum elsewhere. Measured on Recon3D: current LP support 5805,
attainable 237 (wrong). Maximal-support LP support 5824, attainable **251**.

Measured with the maximal-support LP (gurobi):

| Fixture | nullity | maximal-support attainable | current LP attainable |
|---|---|---|---|
| Recon3D operative matrix | 251 | **251** (support 5824/5824) | 237 (support 5805) |
| G1 = `[1 -1; 1 0; 0 1]` (inconsistent) | 1 | **0** (support 0) | 0 |
| ecoli_core full `S` | 5 | 5 (support 12/72) | 5 |
| ecoli_core internal | 11 | 11 (support 72/72) | 11 |
| **F4 = `[1; -1; 2]`** (new micro-fixture) | 2 | **2** | **1 (wrong)** |

F4 is the smallest exhibit of the defect. Its non-negative left-nullspace cone has
extreme rays (1,1,0) and (0,2,1). `max sum(y)` subject to `y <= 1` picks (1,1,0) (sum 2
beats 1.5), so metabolite 3 is excluded, although it is reachable. The structural verdict
on G1 is preserved.

**Alternatives considered**: iterating the current LP while forcing uncovered
coordinates positive one by one. Correct, but costs up to m LPs. Rejected for one LP of
size 2m.

## R5 — CI fixture behaviour (ecoli_core)

**Measured**: plain `ecoli_core` does **not** exhibit the stall. Its internal operative
matrix gives 11/11 with 0 accuracy rejections, both before and after the remedies
(0.6 s). Its rays have no entries below 1e-5.

**Decision**: the CI test derives a mechanism fixture **from ecoli_core** by rescaling one
conserved metabolite's row of the internal operative matrix by 2e5. That is a change of
units: it scales that metabolite's entries in every conservation vector by 1/2e5 and
leaves the nullspace structure intact. The metabolite chosen is the one present in the
most nullspace directions (`acald[e]` in the measured run, selected programmatically so
the test does not hard-code a name). Measured:

| ecoli_core, one row x 2e5 | regime | outcome | rays | accRej |
|---|---|---|---|---|
| current routine (`maxTime 30 s`) | wellScaled | incomplete | 7/11 | **1814** |
| with remedies | wellScaled | **complete** | **11/11** | 0 |

The returned basis has a smallest positive entry of 3.5e-8. It is exactly the class of
legitimately tiny entry that truncation at 1e-5 destroyed. This reproduces the Recon3D
mechanism in under a second of LP work, so it is the CI regression test for R1.

**R2 test**: an additive status field `nStallEscalations` counts the times the failure
counter reaches `nfailMax`. On the existing impossible-target case (`feasTol = -1`),
every candidate is an accuracy rejection, so `nStallEscalations > 0` after the remedy and
0 before it. That gives a deterministic test that does not depend on search luck.

**R3 test**: `param.maxElementsForSpectrum` below `numel` forces the documented fallback
(`accuracyTargetDerived = false`, `regime = 'notAssessed'`). The default derives the
target on ecoli_core.

**R4 test**: F4 with an impossible target forces a shortfall. `attainableDimension` must
be 2. G1 must stay `structural` with 0.

## R6 — Supplied-basis validation (US4, FR-010)

**Decision**: a new function `checkNullspaceBasis(model, B, param)` in
`src/analysis/topology/extremeRays/optimalRays/`. It returns a status struct with the
same field names and meanings as `greedyExtremeRayBasis` uses for its own output where
they apply (`accuracyTarget`, `accuracyTargetDerived`, `acceptanceTarget`,
`residualAbsolute`, `residualScaled`, `nonNegative`, `regime`, `independentRank`), plus
`residualByRow`, `failingRows`, `rankB`, `nullity`, `spansNullspace` and `outcome`
(`'valid'`, `'inaccurate'`, `'rankDeficient'`, `'negative'`). The target derivation is
**shared** with the greedy routine by extracting it into one helper, so the two cannot
drift (constitution single-sourcing).

**Rationale**: the user's question ("is `model.L` a basis?") recurs whenever a basis is
loaded rather than computed. Answering it with the same contract the routine certifies
its own output against is the only answer that means something downstream.

**Alternatives considered**: a `param.validateOnly` mode of `greedyExtremeRayBasis`.
Rejected: it overloads a search routine with a non-search behaviour and complicates its
five-outcome contract.

**Measured answer for the shipped `model.L`**, against the derived target 3.945e-13 of the
reference operative matrix: non-negative, 251 rows, rank 251 = nullity, and **101 of 251
rows fail the target**. The worst row's residual is 3.2e-9. With the remedies in place,
the routine itself returns a basis whose worst row is 3.5e-16, so the recommended
replacement for `model.L` is the routine's own output under the reference call.
