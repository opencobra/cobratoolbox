# Feature Measurement Record

**Tasks**: T042 in spirit (the replicate-bearing record), produced during the T001-T021
slice | **Date**: 2026-09-14/15 | **Environment**: [environment.md](./environment.md)

Distinct from the per-call `status` (FR-016): a single invocation cannot know a
replicate count, so campaign-level figures live here (FR-016a).

## 1. The headline finding

**The accuracy of the returned basis is dominated by which LP solver is installed.**
Same model, same code path, same tolerances, on `iDopaNeuroC` (internal, 1244 x 1710):

| Solver | assembled residual, absolute | scaled | replicates |
|---|---|---|---|
| gurobi 1302 | **1.185e-16** | 1.707e-19 | 1 full 105-ray basis |
| mosek 11.2 | **9.342e-09** | 1.302e-11 | 1 full 105-ray basis |

Seven orders of magnitude apart. The seed's reported 1.418e-07 / 2.218e-09 is consistent
with a mosek-class solve. Neither the `1e-6` acceptance test (the seed's diagnosis) nor
the `epsilon` truncation (this feature's hypothesis) is the operative cause.

## 2. Per-ray residual floor, raw (untruncated)

iDopaNeuroC, 20 rays per solver:

| Solver | median | max | rays clipped by the +-100 bounds |
|---|---|---|---|
| gurobi | 0.000e+00 | 0.000e+00 | 0 of 20 |
| glpk | 4.467e-27 | 1.110e-16 | 0 of 20 |
| mosek | 1.695e-12 | 3.064e-10 | 0 of 20 |

## 3. Truncation effect (R1), 200 rays plus two full bases

| Model / solver | entries zeroed per ray | largest zeroed | residual raw -> truncated |
|---|---|---|---|
| ecoli_core / gurobi | 0 | 0 | 0 -> 0 |
| ecoli_core / mosek | 0 | 0 | 0 -> 0 |
| iAF1260 / gurobi | 0 | 0 | 0 -> 0 |
| iAF1260 / mosek | 55 | 2.5e-09 | 1.37e-13 -> 0 (improved) |
| iDopaNeuroC / gurobi | **0** | 0 | 0 -> 0 |
| iDopaNeuroC / mosek | 1186 | 1.134e-07 | 1.192e-12 -> 3.342e-14 (improved) |

Truncation worsened the residual in **0 of 200** sampled rays.

## 4. US1 acceptance, after the change (1 replicate per fixture, seed 20260914)

Solver gurobi, `param.maxNewBasisTime = 20`:

| Fixture | accuracy target | residual abs | residual scaled | rays | non-neg | runtime |
|---|---|---|---|---|---|---|
| F1 square 3x3 | 3.846e-16 | 5.551e-17 | 3.925e-17 | 1/1 | yes | 0.03 s |
| F2 chain 3x2 (m != n) | 2.220e-16 | 5.551e-17 | 4.807e-17 | 1/1 | yes | 0.03 s |
| F2b two pools 4x2 | 3.140e-16 | 0.000e+00 | 0.000e+00 | 2/2 | yes | 0.20 s |
| F3 empty left nullspace | 3.846e-16 | 0.000e+00 | 0.000e+00 | 0/0 | yes | 0.00 s |
| ecoli_core (72 x 95) | 3.010e-14 | 0.000e+00 | 0.000e+00 | 5/5 | yes | 0.15 s |

No fixture timed out; no candidate was rejected for accuracy on any of them.

## 5. Accuracy target and regime boundary

| Quantity | Value | Source |
|---|---|---|
| derived target, iDopaNeuroC | 1.193e-12 absolute / 1.862e-14 scaled | R3 |
| measured crossing (rank becomes ambiguous) | between 7.340e-10 and 6.942e-09 | R3 perturbation sweep |
| conservatism of the derived bound | ~600x | ratio of the two above |
| regime boundary | `sigma_min+(Nop) < 2.379e-06` | R4 |
| iDopaNeuroC margin above the boundary | 11929x -> **Regime A** | R4 |

Validation of the target against the two known outcomes: the seed's basis (scaled
2.218e-09) **fails**, an exact basis (~1e-16) **passes** — both as required.

## 6. Restart on a dead end (T016a) — measured, and it does NOT help here

iDopaNeuroC internal, gurobi, seed 20260914, total budget 240 s, 1 replicate per arm:

| Arm | rays found | restarts | timed out | runtime | residual |
|---|---|---|---|---|---|
| no restart (`maxNewBasisTime = maxTime = 240`) | 101 / 105 | 0 | yes | 240.0 s | 1.185e-16 |
| **with restart** (`maxNewBasisTime = 20`, `maxTime = 240`) | **101 / 105** | **9** | yes | 240.4 s | 1.185e-16 |

Nine restarts from fresh randomness reached exactly the same 101 rays. **The stall is
therefore structural, not a stochastic dead end**: fresh randomness does not escape it.

A candidate explanation, offered as a hypothesis and NOT as a finding: the target count
`nVar - rankS = 105` is the dimension of the left nullspace, but the routine only admits
**non-negative** rays, and the non-negative extreme rays may span a strictly smaller
subspace. If so, 101 is the correct answer and 105 was never reachable. This is exactly
the concern FR-010 encodes as `raysExpectedIsEstimate`, and it needs its own measurement
before anything is concluded. It is recorded here as the next question, not as an answer.

The restart mechanism is retained: it costs nothing when the search is progressing (it
triggers only on exhausting the per-basis budget), it is reported via `status.nRestarts`,
and it may still help on models whose stall IS stochastic. None was found here.

## 7. SC-005 regression on iDopaNeuroC, after both slices

gurobi, seed 20260914, `maxNewBasisTime = 30`, `maxTime = 180`, 1 replicate:

| Quantity | Measured |
|---|---|
| regime | **wellScaled** (sigma_min+ 2.8382e-02 vs boundary 5.2837e-06, margin 5372x) |
| accuracy target | 1.1928e-12 |
| residual achieved, absolute / scaled | **1.1852e-16** / 1.6949e-19 |
| outcome / reason | `incomplete` / `timeBudget` |
| rays | 101 of 105, 0 rejected for accuracy, 5 restarts |
| non-negative | yes |

**SC-005 is discharged**: iDopaNeuroC yields a basis that clears the derived accuracy
target by four orders of magnitude, and its incompleteness is reported rather than
concealed. It is NOT diagnosed as badly scaled, confirming R4's Regime-A prediction
independently of R4's own graded family.

Caveat recorded rather than hidden: because FR-010 (US3) is not implemented, `Zpos` is
still padded to 105 rows of which 4 are all-zero. `status.raysFound` correctly reports
101, and the help header now warns explicitly that `size(Zpos, 1)` must not be used to
judge completeness.

## 8. US2, US3 and US4 acceptance (1 replicate each, seed 20260914, gurobi)

**Regime B, on a fixture pairing a conserved pool with two nearly-parallel rows.**
Scaling a row does NOT produce this condition: it leaves the rank-2 subspace, and hence
sigmaMinPlus, untouched. The near-dependence parameter `g` controls it directly.

| g | sigmaMinPlus | boundary | outcome | Zpos | Z |
|---|---|---|---|---|---|
| 1 | 6.180e-01 | 8.829e-02 | `complete` | returned | returned |
| 1e-4 | 7.071e-05 | 1.010e-01 | `badlyScaled` | **empty** | **empty** |
| 1e-8 | 7.071e-09 | 1.010e-01 | `badlyScaled` | **empty** | **empty** |
| 1e-12 | 7.071e-13 | 1.010e-01 | `badlyScaled` | **empty** | **empty** |

The diagnosis is complete from the returned status alone, with all console output
suppressed: quantity, measured value, boundary, what the boundary is derived from, and
the indicated repair.

**US3, truthful completeness, on iDopaNeuroC** (25 s budget, so it terminates early on
purpose):

| Quantity | Before US3 | After US3 |
|---|---|---|
| `size(Zpos, 1)` | 105 (4 all-zero) | **101** |
| `status.raysFound` | 101 | 101 |
| all-zero rows returned | 4 | **0** |
| row count agrees with rays found | no | **yes** |
| outcome | `incomplete` | `incomplete` |

**US4**: a no-parameter call on a model without `SConsistentRxnBool` — the call
`optimalExtremePoolDriver.m:121` makes — now returns `outcome = 'missingField'` with the
field name and how to obtain it, instead of raising an undefined-field error. Both
nullspace modes carry the same accuracy target, regime classification and status.

## 9. Cost note

The exact target needs `sigma_min+` of the operative matrix. A full `svd` costs minutes
at genome scale and `svds(...,'smallestnz')` is no faster (>7 minutes on iDopaNeuroC,
abandoned). The shipped default is therefore the conservative `eps*normest(Sop)`, with
the exact derivation available via `param.exactAccuracyTarget`. Measured on
iDopaNeuroC the default is 84x stricter than the exact target, so it is a safe
surrogate for a well-scaled matrix; for a badly scaled one it becomes too loose, which
is the Regime-B condition this slice does not yet detect. That limitation is stated in
the function's own comments rather than hidden.

## 10. Reporting discipline

No attainable residual, runtime, or regime membership is promised for any model not
measured here. Every figure above is a measurement with its replicate count stated.
Where a single replicate was used, that is said rather than implied.
