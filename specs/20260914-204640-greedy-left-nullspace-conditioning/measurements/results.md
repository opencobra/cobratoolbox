# Feature Measurement Record

**Tasks**: T042 in spirit (the replicate-bearing record), produced during the T001-T021
slice | **Date**: 2026-09-14/15 | **Environment**: [environment.md](./environment.md)

Distinct from the per-call `status` (FR-016): a single invocation cannot know a
replicate count, so campaign-level figures live here (FR-016a).

## 1. Does the augmented system end up better behaved? YES - measured directly

The question the feature exists to answer, measured on the augmented matrix a caller
actually forms, `M = [N, -I; 0, L]`, on iDopaNeuroC. Old = a basis accepted at the
pre-change tolerance (mosek-class). New = the current code under gurobi. 1 replicate,
seed 20260914.

| | Old (soft basis) | New (current code) |
|---|---|---|
| `L` | 105 x 1244 | 101 x 1244 |
| `norm(L*N, inf)` | 9.3424e-09 | **1.1852e-16** |
| augmented `M` | 1349 x 2954 | 1345 x 2954 |
| structural rank | 1244 | 1244 |
| SVD rank at tau = 1e-9, 1e-10, 1e-11, 1e-12, eps*max | `[1244 1244 1245 1248 1248]` | **`[1244 1244 1244 1244 1244]`** |
| `getRankLUSOL` | 1249 | **1244** |
| `getNullSpace` implied rank | 1259 | **1244** |
| **all three agree at the structural rank?** | **NO** | **YES** |
| `norm(M*ker(M), inf)` | **4.7752** | **2.1796e-13** |

**The rank gap is restored.** Three independent rank routines that previously returned
1248/1249/1259 now all return 1244, and the answer no longer moves across four orders of
magnitude of tolerance. The nullspace of the augmented matrix goes from **useless**
- residual 4.78, order 1, the failure mode the seed reported as 14.1 on its own instance
- to machine-precision scale at 2.18e-13.

**The honest caveat.** The new basis has 101 rows, not 105: it spans 101 of the 105
left-nullspace directions, so four conservation relations are absent from the augmented
matrix. Its rank is well defined and every routine agrees on it, but a caller wanting
every conserved moiety gets 101 of them. The difference from before is that the status
now SAYS so (`outcome = 'incomplete'`, `raysFound = 101`, `raysExpected = 105`) instead
of padding to 105 rows with four all-zero rows that read as complete. Whether 105 was
ever reachable by non-negative rays is the open question in section 6.

## 2. The headline finding about cause

**The accuracy of the returned basis is dominated by which LP solver is installed.**
Same model, same code path, same tolerances, on `iDopaNeuroC` (internal, 1244 x 1710):

| Solver | assembled residual, absolute | scaled | replicates |
|---|---|---|---|
| gurobi 1302 | **1.185e-16** | 1.707e-19 | 1 full 105-ray basis |
| mosek 11.2 | **9.342e-09** | 1.302e-11 | 1 full 105-ray basis |

Seven orders of magnitude apart. The seed's reported 1.418e-07 / 2.218e-09 is consistent
with a mosek-class solve. Neither the `1e-6` acceptance test (the seed's diagnosis) nor
the `epsilon` truncation (this feature's hypothesis) is the operative cause.

## 3. Per-ray residual floor, raw (untruncated)

iDopaNeuroC, 20 rays per solver:

| Solver | median | max | rays clipped by the +-100 bounds |
|---|---|---|---|
| gurobi | 0.000e+00 | 0.000e+00 | 0 of 20 |
| glpk | 4.467e-27 | 1.110e-16 | 0 of 20 |
| mosek | 1.695e-12 | 3.064e-10 | 0 of 20 |

## 4. Truncation effect (R1), 200 rays plus two full bases

| Model / solver | entries zeroed per ray | largest zeroed | residual raw -> truncated |
|---|---|---|---|
| ecoli_core / gurobi | 0 | 0 | 0 -> 0 |
| ecoli_core / mosek | 0 | 0 | 0 -> 0 |
| iAF1260 / gurobi | 0 | 0 | 0 -> 0 |
| iAF1260 / mosek | 55 | 2.5e-09 | 1.37e-13 -> 0 (improved) |
| iDopaNeuroC / gurobi | **0** | 0 | 0 -> 0 |
| iDopaNeuroC / mosek | 1186 | 1.134e-07 | 1.192e-12 -> 3.342e-14 (improved) |

Truncation worsened the residual in **0 of 200** sampled rays.

## 5. US1 acceptance, after the change (1 replicate per fixture, seed 20260914)

Solver gurobi, `param.maxNewBasisTime = 20`:

| Fixture | accuracy target | residual abs | residual scaled | rays | non-neg | runtime |
|---|---|---|---|---|---|---|
| F1 square 3x3 | 3.846e-16 | 5.551e-17 | 3.925e-17 | 1/1 | yes | 0.03 s |
| F2 chain 3x2 (m != n) | 2.220e-16 | 5.551e-17 | 4.807e-17 | 1/1 | yes | 0.03 s |
| F2b two pools 4x2 | 3.140e-16 | 0.000e+00 | 0.000e+00 | 2/2 | yes | 0.20 s |
| F3 empty left nullspace | 3.846e-16 | 0.000e+00 | 0.000e+00 | 0/0 | yes | 0.00 s |
| ecoli_core (72 x 95) | 3.010e-14 | 0.000e+00 | 0.000e+00 | 5/5 | yes | 0.15 s |

No fixture timed out; no candidate was rejected for accuracy on any of them.

## 6. Accuracy target and regime boundary

| Quantity | Value | Source |
|---|---|---|
| derived target, iDopaNeuroC | 1.193e-12 absolute / 1.862e-14 scaled | R3 |
| measured crossing (rank becomes ambiguous) | between 7.340e-10 and 6.942e-09 | R3 perturbation sweep |
| conservatism of the derived bound | ~600x | ratio of the two above |
| regime boundary | `sigma_min+(Nop) < 2.379e-06` | R4 |
| iDopaNeuroC margin above the boundary | 11929x -> **Regime A** | R4 |

Validation of the target against the two known outcomes: the seed's basis (scaled
2.218e-09) **fails**, an exact basis (~1e-16) **passes** — both as required.

## 7. Restart on a dead end (T016a) — measured, and it does NOT help here

iDopaNeuroC internal, gurobi, seed 20260914, total budget 240 s, 1 replicate per arm:

| Arm | rays found | restarts | timed out | runtime | residual |
|---|---|---|---|---|---|
| no restart (`maxNewBasisTime = maxTime = 240`) | 101 / 105 | 0 | yes | 240.0 s | 1.185e-16 |
| **with restart** (`maxNewBasisTime = 20`, `maxTime = 240`) | **101 / 105** | **9** | yes | 240.4 s | 1.185e-16 |

Nine restarts from fresh randomness reached exactly the same 101 rays, so fresh
randomness alone does not escape it.

**CORRECTION (2026-09-15).** This was first written up as "the stall is structural, not a
stochastic dead end", with the hypothesis that the non-negative extreme rays span fewer
than `nVar - rankS = 105` dimensions. **Two measurements refute that**, and the
hypothesis is withdrawn:

1. **The cone spans the whole left nullspace.** A feasibility LP (`N'x = 0, x >= 1`)
   returns a STRICTLY POSITIVE conservation vector: `min(x) = 1`, `max(x) = 93.75`,
   `norm(x'N, inf) = 7.105e-15`. Whenever `ker(N')` contains a strictly positive vector
   `x*`, every `y` in `ker(N')` satisfies `x* + y/t >= 0` for large enough `t`, so
   `y = t((x* + y/t) - x*)` lies in the span of the non-negative cone. Hence
   `span(K) = ker(N')` and **all 105 directions are reachable with non-negative
   weights**. That strictly positive vector is exactly stoichiometric consistency, which
   is what restricting to `SConsistentRxnBool` guarantees.
2. **mosek actually found all 105** (section 4: "accepted 105 of 105 in 1096 tries,
   44.6 s"), at the pre-change tolerance. So 105 independent non-negative rays are not
   merely reachable in principle, they were found in practice.

**The real cause is vertex sampling, not geometry.** Each ray is a vertex of
`{x >= 0, x'N = 0, sum(x) = 1}` selected by maximising a random linear objective. The
cone is pointed, so its extreme rays do generate it -- but the polytope is massively
degenerate, and a solver's pivoting and tie-breaking decide WHICH optimal vertex a given
objective returns. Different algorithms therefore reach different subsets: gurobi's hit
rate is 0.46% and it stalls at 101, mosek's is 9.6% and it reaches 105. Restarting does
not help because the deficiency is in the solver's deterministic vertex selection, not
in the randomness of the objective it is handed.

The bind is that neither solver gives both properties at once: gurobi supplies the
accuracy (1.185e-16) but not the coverage; mosek supplies the coverage but not the
accuracy (9.342e-09, four orders above the derived target). Closing the gap is a
follow-up, and the promising directions are solver-side rather than algorithmic --
perturbing the objective to break ties, forcing a different pivot rule, or seeding the
search with the strictly positive vector above -- not accepting 101 as the answer.

The restart mechanism is retained: it costs nothing when the search is progressing (it
triggers only on exhausting the per-basis budget), it is reported via `status.nRestarts`,
and it may still help on models whose stall IS stochastic. None was found here.

## 8. SC-005 regression on iDopaNeuroC, after both slices

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

## 9. US2, US3 and US4 acceptance (1 replicate each, seed 20260914, gurobi)

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

## 10. Cost note

The exact target needs `sigma_min+` of the operative matrix. A full `svd` costs minutes
at genome scale and `svds(...,'smallestnz')` is no faster (>7 minutes on iDopaNeuroC,
abandoned). The shipped default is therefore the conservative `eps*normest(Sop)`, with
the exact derivation available via `param.exactAccuracyTarget`. Measured on
iDopaNeuroC the default is 84x stricter than the exact target, so it is a safe
surrogate for a well-scaled matrix; for a badly scaled one it becomes too loose, which
is the Regime-B condition this slice does not yet detect. That limitation is stated in
the function's own comments rather than hidden.

## 11. Reporting discipline

No attainable residual, runtime, or regime membership is promised for any model not
measured here. Every figure above is a measurement with its replicate count stated.
Where a single replicate was used, that is said rather than implied.
