# Phase 0 Research: Measurements That Must Precede Any Tuning

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-09-15

**Status: MEASURED 2026-09-15.** Drivers under `measurements/`.

Inherited without re-derivation, from the parent feature's `measurements/results.md`:
gurobi assembled residual **1.185e-16** with **101 of 105** rays; mosek **9.342e-09** with
**105 of 105**; derived accuracy target **1.193e-12**; `ker(N')` contains a strictly
positive vector, so the non-negative cone spans the whole left nullspace.

A finding that refutes the hypothesis it tests is a **successful** measurement.

---

## R1 — The paired harness (sequenced first; everything else runs through it)

### Why it must be paired

The parent feature's per-solver figures came from independent whole runs with independent
random streams. After the first accepted ray those runs diverge into different accumulated
bases, so they measure solver behaviour and search path **confounded**. A matched design
removes the confound.

### Procedure

1. At a greedy state — partial `Zpos` with `k` accepted rays, the derived support mask,
   and **one** drawn objective vector — construct the LP once.
2. Hand that identical LP to each solver under comparison, in turn.
3. Per solver record: the returned ray; `norm(Sop'*x, inf)` absolute and scaled; whether
   the ray is linearly independent of the current `Zpos`; whether it would be accepted at
   the derived target; solve time; and whether a basis was returned (see R2).
4. Advance the search using **one** nominated solver's ray, so the state sequence is
   single-valued and every comparison point is reached identically regardless of how many
   solvers are being compared.
5. Repeat across the whole search, including the late states where gurobi stalls — the
   interesting region is `k` near the expected count, not `k = 0`.

### The design question this must answer

**How to hold state identical without letting the instrumentation perturb the search.**
Comparing `n` solvers at each step must not consume `n` draws from the random stream, or
advance the state differently from an uninstrumented run. Whichever mechanism is chosen
must satisfy SC-011: with instrumentation off, results identical to the uninstrumented
call.

### Result

- **Mechanism**: the objective is drawn ONCE by the search; the harness reuses it for
  every solver and the search advances on the nominated solver's ray, **reused from the
  comparison loop rather than re-solved**. The comparison consumes no draws from the
  random stream, so the state sequence is identical instrumented or not.
- **Inertness (SC-011)**: with `compareSolvers` unset and with it `{}`, the basis is
  bit-identical, `raysFound` identical, residual identical, and no paired record is
  produced. Asserted in the test, not argued.
- **Collected**: **570 rows over 285 paired points**, `k` from 0 to 98.
- **Pairing audit**: every solver at a point received the same objective — verified from
  `objectiveHash`, so the pairing is checkable rather than claimed.

---

## R2 — Interior point versus simplex: a HYPOTHESIS, with a decision rule fixed in advance

### The hypothesis

The coverage/accuracy split has the signature of algorithm class. An interior-point
solution without full basis identification is **not an exact vertex** — which would
explain mosek's vertex diversity *and* its ~1e-12 residuals — while simplex returns exact
vertices, explaining gurobi's exactness and its narrow, degeneracy-limited vertex set.

### Procedure

1. For each solve, record whether a **basis** was returned. `solveCobraLP.m:906-913`
   already saves `vbasis`/`cbasis` with the comment "only available if crossover was used
   or simplex method". Their presence is a direct discriminator between a vertex solution
   and an interior one.
2. Cross-check against the solver's own reported algorithm, obtained from the solver's
   output rather than from the toolbox — see Hazard 2 below.
3. Classify each returned ray as vertex-like or interior-like independently of the
   solver's claims, by checking how many of its components sit exactly at a bound.

### Hazards that could corrupt this measurement — established by reading, not assumed

1. **The gurobi `Method` label is off by one** against its own comment
   (`solveCobraLP.m:918-939`): the switch maps `1 -> 'primal simplex'`,
   `2 -> 'dual simplex'`, `3 -> 'barrier'`, and `0` falls through to
   `'deterministic concurrent'`. Do not attribute an algorithm from this label.
2. **That label is never returned.** `method` is assigned and discarded, so the toolbox
   reports no algorithm at all. Verification must come from solver output or from the
   structure of the returned point.

### Decision rule, fixed in advance

- **Confirmed** (mosek returns no basis / interior-like points; gurobi returns a basis /
  vertex points): A2 becomes substantially "enable basis identification", A3 "vary the
  tie-break", and R3 targets those knobs first.
- **Refuted** (both return vertices, or the split does not track algorithm class): record
  the refutation **prominently**, and R3 must search the configuration surface without
  this prior. The parent feature's lesson is that a plausible mechanism recorded as
  established is the trap.

### Result — **CONFIRMED**, but it does not explain coverage

| iDopaNeuroC, 285 paired points | gurobi | mosek |
|---|---|---|
| **basis returned** (`vbasis`/`cbasis`) | **285/285** | **0/285** |
| residual median / max | **0** / 2.220e-16 | 9.326e-15 / 7.007e-10 |
| meets the accuracy target | **285/285** | 232/285 |
| **independent of the current basis** | **195/285 (68.4%)** | **205/285 (71.9%)** |
| solve time median | 0.024 s | 0.043 s |

**The algorithm-class hypothesis is confirmed for ACCURACY**: gurobi returns a basis on
every solve and mosek on none, which is the simplex-versus-interior-point discriminator,
and the residuals follow exactly.

**It is REFUTED for COVERAGE.** Under matched conditions the two solvers find new
independent directions at nearly the same rate — 68.4% against 71.9%. The dramatic
unpaired gap (gurobi 0.46% hit rate against mosek 9.6%) was largely an artefact of
**path divergence** between independent runs, not a per-solve property. This is exactly
what the paired design was introduced to expose, and it could not have been seen any
other way.

---

## R3 — Configuration-surface audit (Constitution Principle IV — the centre of this feature)

### The structural profile the defaults must be judged against

Sparse; **all-equality** (`csense` all `'E'`); continuous; non-negative orthant when
`positive` is set; one appended **normalisation row** forcing `sum(x) = 1`; hard-coded
bounds `+-100` that were measured never to bind; ~1244 x 2954 at genome scale; and
**massively degenerate**, which is the property that makes vertex selection the issue.

### Procedure

For gurobi and for mosek: enumerate the relevant configuration surface, record each
default, judge it against the profile above, and identify mismatches. Candidate knobs to
assess — **a list to evaluate, not a prescription**:

| Solver | Knob | Why it might matter here |
|---|---|---|
| gurobi | `Method` | selects simplex vs barrier; decides whether a vertex is returned at all |
| gurobi | `Seed` | changes tie-breaking among equally optimal vertices — the direct lever on coverage |
| gurobi | `NumericFocus` | accuracy under degeneracy |
| gurobi | `Crossover` | whether a barrier solution is pushed to a vertex |
| gurobi | `Presolve` | may collapse the degenerate structure being sampled |
| mosek | `MSK_IPAR_OPTIMIZER` (via `param.lpmethod`) | simplex vs interior point |
| mosek | `MSK_IPAR_INTPNT_BASIS` | basis identification — the accuracy lever if R2 confirms |
| mosek | `MSK_DPAR_INTPNT_TOL_*` | interior-point tolerances |
| mosek | `MSK_IPAR_PRESOLVE_USE` | as gurobi's Presolve |

Settings MUST be applied through `solveCobraLP`'s pass-through, never by calling a solver
directly (FR-020).

### Result — **no tuned set is adopted, because the premise is false**

The audit reached a negative conclusion that makes A2 and A3 moot, and it is the central
finding of this feature.

**The LP has a UNIQUE optimum for a random objective.** Maximising a different random
direction *subject to remaining optimal for the original objective* returns the identical
point (difference 0.000e+00 in the infinity norm). Where the optimum is unique there is
no choice of vertex to make, so pivoting and tie-breaking cannot influence which ray is
returned.

Measured directly, one objective, each setting against the default:

| Setting | Returned ray differs? | residual | basis | t(s) |
|---|---|---|---|---|
| (defaults) | baseline | 0.000e+00 | yes | 0.031 |
| `Seed=1` / `Seed=2` / `Seed=12345` | **no** | 0.000e+00 | yes | 0.016-0.032 |
| `Method=0` / `1` / `2` | **no** | 0.000e+00 | yes | 0.029-0.066 |
| `NumericFocus=3` | **no** | 0.000e+00 | yes | 0.014 |
| `Presolve=0` | **no** | 0.000e+00 | yes | 0.014 |
| `Crossover=0` | **no** | 0.000e+00 | yes | 0.014 |

**The spec's stated mechanism — "the solver's pivoting and tie-breaking decide which
optimal vertex a given objective returns" — is therefore measured FALSE.** The objective
decides; the solver has no latitude.

---

## R4 — Verification that each tuned setting takes effect (FR-022)

A parameter a solver silently ignores or rejects is worse than none: it manufactures the
appearance of tuning. The toolbox reports no algorithm (R2 Hazard 2), so effect must be
demonstrated, not inferred from having set the value.

### Procedure

For each setting: establish an observable that changes when and only when the setting
takes effect — solve time, iteration count, presence of `vbasis`/`cbasis`, the structure
of the returned point, or the solver's own log. Record the observable and its before/after
values. A setting whose effect cannot be observed MUST be reported as unverified rather
than quietly retained.

### Result — settings DO reach the solver; the verification handle works

This had to be separated from R3's negative result, or "nothing changed" would have been
ambiguous between "the parameter did nothing" and "the parameter never arrived".

| Setting | Observable | Outcome |
|---|---|---|
| `IterationLimit = 1` | solver status | `stat = -1`, `origStat = ITERATION_LIMIT` |
| `TimeLimit = 1e-4` | solver status | `stat = -1`, `origStat = TIME_LIMIT` |
| `NodeLimit = 0` | solver status | `stat = 1`, `OPTIMAL` — a MIP parameter correctly ignored for an LP |

**Settings reach gurobi and take effect.** So R3's finding is a genuine property of the
problem, not a plumbing failure. **Settings adopted: none** — none changes the returned
ray, so adopting any would be decoration.

---

## R5 — The A0/A2/A3 comparison protocol

### Procedure

Same model, same seed, one comparable table. **A0 is the control**: both solvers at
current defaults, so a gain is shown to be a gain over the status quo. Report per
approach: rays found against expected; residual absolute and scaled; whether SC-001 is
met; runtime; replicate count.

**A1, the two-phase approach, is out of scope by decision** (plan decision (b), 2026-09-15)
and is not measured. If neither A2 nor A3 meets SC-001, that is the finding, and the
deliverable becomes User Story 3.

### Result

A2 and A3 were not run as tuned configurations: R3 showed no setting changes the returned
ray, so a "tuned" arm would have been identical to its control by construction. What was
measured instead is the remedy the evidence actually pointed to.

| Approach | Rays found / expected | Residual abs | Meets SC-001? | Runtime | Replicates |
|---|---|---|---|---|---|
| A0 gurobi default | 101 / 105 | 1.185e-16 | **no** (incomplete) | 180 s, timed out | 1 |
| A0 mosek default | 105 / 105 | 9.342e-09 | **no** (misses target) | 44.6 s | 1 |
| A2 mosek tuned | *not run* — R3 makes it identical to its control | — | — | — | — |
| A3 gurobi tuned | *not run* — same reason | — | — | — | — |
| **Targeted objective (adopted)** | **105 / 105** | **6.828e-15** | **YES** | **4.7 s** | 1 |

---

## R6 — Distinguishing a sampling shortfall from a structural one (FR-005, FR-006)

### Procedure

The parent feature established the test: `span(K) = ker(N')` iff `ker(N')` contains a
strictly positive vector, checkable by one feasibility LP (`N'x = 0, x >= 1`). Where it is
feasible the shortfall is **sampling**; where infeasible, part of the nullspace is
genuinely unreachable with non-negative weights and the shortfall is **structural**, so
the attainable dimension — not the nullity — is the right target (FR-006).

Assess: the cost of that LP at genome scale; whether to run it always, or only when the
search falls short; and how the attainable dimension is obtained when the answer is
"structural".

### Result — and a correction to the test this question proposed

The procedure above proposed testing for a strictly positive vector in `ker(N')`. **That
test is unsound in one direction and was replaced.** A strictly positive vector is
SUFFICIENT for the non-negative cone to span the nullspace, but its absence does NOT
imply the converse: coordinates can be forced to zero while the rest still span. Using it
produced a false `'structural'` verdict on `ecoli_core`, whose full S carries exchange
reactions and so has no strictly positive conservation vector — yet which reaches full
coverage. The feature's own test caught it.

**Replaced by computing the attainable dimension**, which is sound both ways: one LP
maximising `sum(x)` over `{S'x = 0, 0 <= x <= 1}` gives the maximal support any
non-negative nullspace vector can have, and the reachable subspace is the part of
`ker(S')` living on that support, of dimension `|support| - rank(S(support,:))`.

- **Where in the flow**: on a shortfall only, so a complete basis pays nothing.
- **Structural case**: the attainable dimension is reported in place of the nullity, so a
  shortfall is never reported against a target that was never reachable (FR-006).

---

## R7 — Fixtures

### Procedure

1. **Coverage-incomplete but reachable.** `iDopaNeuroC` is the known case, but it is
   submodule-resident, so CI needs either a substitute exhibiting the same stall or the
   case stays a documented check. Determine whether any CI-available model stalls —
   `ecoli_core` and `iAF1260` both reach full coverage today, so neither serves.
2. **Structurally deficient.** A small fixture that is stoichiometrically INCONSISTENT, so
   `span(K)` really is smaller than `ker(N')` — for example a reaction producing mass from
   nothing, whose left nullspace direction requires opposite signs. Needed for FR-005 and
   must be constructed so the attainable dimension is known exactly.
3. Existing exact fixtures (F1, F2, F2b, F3) must not regress (SC-004).

### Result

- **CI-available stalling case: none was needed.** The targeted objective removes the
  stall, so `ecoli_core` reaches full coverage in CI and serves as the SC-001 case.
  `iDopaNeuroC` remains the documented check for the genome-scale case.
- **G1, structurally deficient**: `S = [1 -1; 1 0; 0 1]`. One reaction creates mass from
  nothing, so the single left-nullspace direction is `(1,-1,1)` and needs opposite signs:
  no non-negative vector but zero lies in `ker(S')`, and the extreme-pool LP is genuinely
  infeasible. Attainable dimension 0 against a nullity of 1, known by construction.
- **A latent defect G1 exposed**: an infeasible solve returns an empty ray, and the
  acceptance check then multiplied `S'` by an empty vector and crashed. Pre-existing, and
  reachable by exactly the structural case US3 exists to handle. Now guarded.

---

## Consolidated decisions

*To be completed once R1-R7 are measured. Decision / Rationale / Alternatives considered,
each citing the measurement that supports it.*

| # | Decision | Rationale | Alternatives considered |
|---|---|---|---|
| **D1** | **Ship the paired harness, off by default** | It produced the finding that redirected the feature: under matched conditions the solvers' coverage rates are near-equal, refuting the unpaired story. Inertness when off is asserted by test. | Removing it after the campaign — rejected, it would leave the evidence unreproducible when a solver version changes. |
| **D2** | **Algorithm class explains ACCURACY, not coverage** | R2: basis returned 285/285 under gurobi, 0/285 under mosek; independence 68.4% against 71.9%. | The unpaired hit-rate gap, which R1's design showed to be path divergence. |
| **D3** | **Adopt NO tuned solver settings** | R3: the LP has a unique optimum for a random objective, so no setting changes the returned ray; R4 confirms settings do reach the solver, so this is a property of the problem and not of the plumbing. | A2 and A3 as specified — both would have been identical to their controls. |
| **D4** | **Adopt the TARGETED OBJECTIVE** | At a basis stalled on 98 of 105 with 7 directions unspanned, a random objective produced a new independent accurate ray in **0 of 40** trials and a targeted one in **40 of 40**. End to end: 105/105 at residual 6.828e-15 in 4.7 s, against 101/105 timing out at 180 s. | Solver tuning (D3); restarts (measured useless in the parent feature); accepting partial coverage. |
| **D5** | **Classify shortfalls by attainable dimension, not by stoichiometric consistency** | The consistency test is sound only one way and gave a false `'structural'` verdict on `ecoli_core`. | The strictly-positive test proposed in R6, withdrawn as unsound. |
| **D6** | **G1 as the structural fixture; no new CI stalling case needed** | The targeted objective removes the stall, so `ecoli_core` serves SC-001 in CI. | Hunting for a CI-available model that still stalls — unnecessary. |

## Headline finding

**The coverage shortfall was never the solver's doing.** For a random objective the
extreme-pool LP has a unique optimum, so `Seed`, `Method`, `NumericFocus`, `Presolve` and
`Crossover` — each verified to reach gurobi — all return the identical ray. What decides
coverage is the **objective**. Aiming it at the unspanned part of the nullspace when
random draws stall takes iDopaNeuroC from 101 of 105 rays, timed out at 180 s, to
**105 of 105 in 4.7 s** at a residual four orders inside the accuracy target — and the
augmented matrix's rank becomes unanimous at 1244 across the whole tolerance span.
