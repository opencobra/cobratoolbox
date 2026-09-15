# Phase 0 Research: Measurements That Must Precede Any Tuning

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-09-15

**Status: PROCEDURES DEFINED, MEASUREMENTS NOT YET TAKEN.** Every Result slot is
deliberately empty and is filled from runs, not from reasoning.

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

*Not yet measured.*

- Mechanism chosen for holding state identical: —
- Evidence that instrumentation-off is inert (SC-011): —
- Number of paired points collected, and the `k` range covered: —

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

### Result

*Not yet measured.*

- Basis returned, per solver: —
- Solver-reported algorithm, per solver: —
- Vertex-like vs interior-like classification of returned rays: —
- **Verdict (confirmed / refuted)**: —

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

### Result

*Not yet measured.*

- gurobi configuration surface, defaults, mismatches identified: —
- mosek configuration surface, defaults, mismatches identified: —
- Proposed tuned set A3 (gurobi), with the mismatch each setting corrects: —
- Proposed tuned set A2 (mosek), with the mismatch each setting corrects: —

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

### Result

*Not yet measured.*

- Per-setting observable and before/after values: —
- Settings adopted: —
- Settings found to be ignored or rejected: —

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

*Not yet measured.*

| Approach | Rays found / expected | Residual abs / scaled | Meets SC-001? | Runtime | Replicates |
|---|---|---|---|---|---|
| A0 gurobi default | — | — | — | — | — |
| A0 mosek default | — | — | — | — | — |
| A2 mosek tuned | — | — | — | — | — |
| A3 gurobi tuned | — | — | — | — | — |

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

### Result

*Not yet measured.*

- Cost of the consistency LP at genome scale: —
- Where it belongs in the flow (always / on shortfall only): —
- How the attainable dimension is determined in the structural case: —

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

*Not yet determined.*

- CI-available stalling case, or the decision that none exists: —
- Structurally deficient fixture and its known attainable dimension: —

---

## Consolidated decisions

*To be completed once R1-R7 are measured. Decision / Rationale / Alternatives considered,
each citing the measurement that supports it.*

| # | Decision | Rationale | Alternatives considered |
|---|---|---|---|
| D1 | *(pending R1)* | — | — |
| D2 | *(pending R2)* | — | — |
| D3 | *(pending R3, R4)* | — | — |
| D4 | *(pending R5)* | — | — |
| D5 | *(pending R6)* | — | — |
| D6 | *(pending R7)* | — | — |
