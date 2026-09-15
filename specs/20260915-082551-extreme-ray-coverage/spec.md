# Feature Specification: Extreme-Ray Coverage Without Sacrificing Accuracy

**Feature Branch**: `20260915-082551-extreme-ray-coverage`

**Created**: 2026-09-15

**Status**: Draft

**Input**: Follow-up identified by feature `20260914-204640-greedy-left-nullspace-conditioning`,
whose measurements are the evidence base for this one.

**Function under change**: `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m`

---

## Dependency on the parent feature

This branch is cut from `20260914-204640-greedy-left-nullspace-conditioning`, **not from
`develop`**, because it builds directly on that feature's unmerged code: the derived
accuracy target, the five-outcome status, the trimmed basis and the Regime-B diagnosis.
**This branch MUST be rebased onto `develop` once the parent feature merges.** Until
then, every measurement quoted here is against the parent branch's behaviour.

## Problem Statement

`greedyExtremeRayBasis` must find `nVar - rankS` linearly independent non-negative
extreme rays, each accurate enough to meet the accuracy target derived by the parent
feature. **No single LP solver currently delivers both.** Measured on `iDopaNeuroC`
(internal matrix 1244 x 1710, rank 1139, left nullity 105), one replicate, seed 20260914:

| Solver | Coverage | Accuracy (assembled residual) | Verdict |
|---|---|---|---|
| gurobi | **101 of 105** rays; hit rate 0.46% (101 from 22 027 attempts), then stalls | **1.185e-16** — passes the 1.193e-12 target by ~4 orders | accurate, incomplete |
| mosek | **105 of 105** rays; hit rate 9.6% (105 from 1 096 attempts, 44.6 s) | **9.342e-09** — fails the target by ~4 orders | complete, inaccurate |

A caller therefore gets a basis that either spans the left nullspace **or** gives an
augmented matrix a well-defined numerical rank, never both.

### What is already established — the starting point, not to be re-derived

**The geometry is not the obstacle.** All 105 directions are reachable with non-negative
weights:

* `ker(N')` contains a strictly positive vector, measured by the feasibility LP
  `N'x = 0, x >= 1`: `min(x) = 1`, `max(x) = 93.75`, residual 7.105e-15.
* Whenever `ker(N')` holds a strictly positive `x*`, then for any `y` in `ker(N')` and
  large enough `t`, `x* + y/t >= 0`, so `y = t((x* + y/t) - x*)` lies in the span of the
  non-negative cone. Hence `span(K) = ker(N')`, where `K = ker(N') ∩ R^m_+`.
* That strictly positive vector is exactly **stoichiometric consistency**, which
  restricting to `SConsistentRxnBool` guarantees.
* The cone is pointed, so its extreme rays generate it: extreme rays are sufficient in
  principle.

**The obstacle is vertex sampling under degeneracy.** Each ray is a vertex of
`{x >= 0, x'N = 0, sum(x) = 1}` selected by maximising a random linear objective. The
polytope is massively degenerate, so the solver's pivoting and tie-breaking decide which
optimal vertex a given objective returns, and different algorithms reach different
subsets. **Restarting from fresh randomness does not help**: nine restarts under gurobi
reached exactly the same 101 rays, because the limitation lies downstream of the random
objective.

Verification scripts, in the parent feature directory:
`measurements/checkNonNegativeConeSpan.m` and `measurements/results.md` sections 6-7.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - One call that is both complete and accurate (Priority: P1)

A modeller computes a non-negative left-nullspace basis for a well-scaled model and
receives a basis that spans the full left nullspace **and** meets the accuracy target, in
a single call, without having to know which solver is installed or run the routine twice.

**Why this priority**: it is the entire feature. Every other story is a fallback for the
case where this proves unattainable.

**Independent Test**: on `iDopaNeuroC` (where coverage and accuracy are each individually
achievable today), one call returns `outcome = 'complete'` with
`raysFound == raysExpected` and `residualAbsolute <= accuracyTarget`.

**Acceptance Scenarios**:

1. **Given** a well-scaled model whose full non-negative left nullspace is reachable,
   **When** the basis is computed, **Then** `raysFound == raysExpected` and every
   returned row meets the accuracy target, in one call.
2. **Given** that same basis spliced into an augmented matrix, **When** the rank is
   computed, **Then** independent rank routines agree at the structural rank across a
   tolerance span of at least three orders of magnitude.
3. **Given** the same model and the same seed, **When** the computation is repeated,
   **Then** the coverage achieved is reproducible.
4. **Given** the small fixtures whose non-negative left nullspace is known exactly,
   **When** the basis is computed, **Then** coverage is complete and non-negativity holds.

---

### User Story 2 - Knowing whether the gap was closed, and by how much (Priority: P1)

A modeller, or a reviewer, can tell from the returned status how much of the nullspace
was covered and at what accuracy, and can tell a genuine improvement from a configuration
that merely traded one failure for the other.

**Why this priority**: the failure mode this feature must avoid is buying coverage by
loosening accuracy. Without per-call evidence of both, that trade is invisible.

**Independent Test**: the status reports coverage and accuracy together for every call,
and a run that gained coverage by relaxing accuracy is distinguishable from one that
gained both.

**Acceptance Scenarios**:

1. **Given** any call, **When** the status is inspected, **Then** it reports rays found
   against rays expected AND the residual in both absolute and scaled form.
2. **Given** a configuration that improves coverage, **When** its accuracy is compared
   with the parent feature's baseline, **Then** any regression in accuracy is visible
   rather than implied.

---

### User Story 3 - An honest contract when the gap cannot be closed (Priority: P2)

Where no available configuration yields both properties, the routine says so precisely —
which property it could not achieve, how far short it fell, and what the caller can do —
rather than silently returning whichever it managed.

**Why this priority**: the parent feature established that a confident partial answer is
the defect. If full coverage proves unattainable, the correct deliverable is an honest
account of the limit, not a quiet compromise.

**Independent Test**: force the unattainable case and confirm the status distinguishes
"could not cover" from "could not meet accuracy", with the shortfall quantified.

**Acceptance Scenarios**:

1. **Given** a model where full coverage is not achieved, **When** the call returns,
   **Then** the status reports coverage as incomplete, quantifies the shortfall, and does
   not report the basis as complete.
2. **Given** a model where the accuracy target cannot be met, **When** the call returns,
   **Then** that is reported distinctly from a coverage shortfall.

---

### Edge Cases

- **Coverage and accuracy conflict.** A configuration reaches full coverage only by
  admitting rays that miss the accuracy target. This MUST NOT be reported as success.
- **Genuinely unreachable directions.** A stoichiometrically inconsistent input, where
  `span(K)` really is smaller than `ker(N')` and no non-negative search can complete the
  basis. This is a different condition from a sampling shortfall and must be
  distinguishable from it.
- **Solver availability.** A configuration that depends on a particular solver, or on two
  solvers at once, on a machine where they are not installed.
- **Degeneracy that does not respond.** No configuration measurably improves coverage.
- **Coverage improves but cost explodes.** A configuration reaches full coverage at a
  runtime that makes it unusable at genome scale.
- **Small fixtures.** Coverage is already complete, so a remedy must not regress them.

## Requirements *(mandatory)*

### Functional Requirements

**Coverage**

- **FR-001**: On a model where the full non-negative left nullspace is reachable and the
  accuracy target is attainable, a single call MUST return a basis that is both complete
  (`raysFound == raysExpected`) and accurate (every row meeting the accuracy target).
- **FR-002**: Coverage MUST NOT be obtained by weakening the accuracy target derived by
  the parent feature. The target, the acceptance rule and the clamp on the tolerance
  parameter all remain as they are.
- **FR-003**: Non-negativity of every returned ray remains a hard requirement.
- **FR-004**: The remedy MUST be selected by measurement across the candidate approaches,
  not assumed. The comparison and its evidence MUST be recorded.

**Distinguishing the two shortfalls**

- **FR-005**: The status MUST distinguish a **sampling** shortfall (directions reachable
  but not found) from a **structural** one (directions not reachable with non-negative
  weights because the input is stoichiometrically inconsistent). These have different
  remedies and MUST NOT be reported identically.
- **FR-006**: Where the shortfall is structural, the routine MUST report the attainable
  dimension rather than the nullity, so `raysExpected` is not presented as a target that
  was missed when it was never reachable.

**Reporting**

- **FR-007**: The status MUST report coverage and accuracy together on every call, so a
  configuration that trades one for the other is visible.
- **FR-008**: Where a configuration improves coverage, its effect on accuracy and runtime
  MUST be reported alongside, with replicate counts stated.

**Interface and verification**

- **FR-009**: The parent feature's contract MUST NOT be weakened: the five terminal
  outcomes, the trimmed basis, the Regime-B diagnosis and the derived accuracy target all
  stay as they are. Any new field is additive.
- **FR-010**: Any solver parameter this feature sets MUST be recorded with the reason,
  and MUST be reached through the toolbox's solver abstraction rather than by calling a
  solver directly (Constitution Principle IV).
- **FR-011**: A single call MUST NOT require two solvers. The two-phase approach is out
  of scope by decision (Clarifications, 2026-09-15). Where no single-solver configuration
  meets SC-001, the routine MUST report the limit honestly under User Story 3 rather than
  reaching for a second solver.
- **FR-014**: The approaches A2 and A3 named in Clarifications MUST each be
  measured on the same model with the same seed, and compared on coverage, accuracy,
  runtime and replicate count. **The comparison MUST also include the current default
  behaviour of each solver as a control**, so an apparent gain is shown to be a gain over
  the status quo rather than over an unstated baseline. The selected remedy MUST be
  traceable to that comparison, and an approach MUST NOT be dismissed without
  measurement.
- **FR-015**: Any per-solver setting adopted MUST be recorded with the reason it was
  chosen and the measurement that justifies it, and MUST be reached through the toolbox's
  solver abstraction (Principle IV).

**Paired comparison**

- **FR-016**: The solver comparison MUST be **paired**: every solver compared MUST be
  given the identical partially complete basis and the identical drawn objective vector,
  at the same point in the greedy search, and their returned rays compared against one
  another. Comparisons assembled from independent whole runs do NOT satisfy this, because
  they confound the solver's contribution with the divergent search path.
- **FR-017**: Because that state exists only inside the search, the comparison MUST be
  instrumented within `greedyExtremeRayBasis` rather than driven from outside it. The
  instrumentation MUST be off by default and MUST NOT alter the result of an ordinary
  call when it is off.
- **FR-018**: For each compared solver at each paired point, the record MUST capture the
  residual of the returned ray, whether it is linearly independent of the current basis,
  and whether it was accepted — so that a solver's advantage is attributable to accuracy,
  to vertex diversity, or to both.

**Solver settings tuned to this problem, encoded in the routine**

- **FR-019**: `greedyExtremeRayBasis` MUST carry its own **per-solver parameter sets,
  tuned to this problem**, for at least mosek and gurobi. The generic
  `setCobraSolverParams` layer covers only a basic set of parameters and is NOT the
  vehicle for this: the settings that matter here are solver-specific and problem-specific
  (degeneracy handling, vertex identification, interior-point tolerances), and they belong
  with the routine that knows the problem, not in a shared layer every toolbox solve
  passes through.
- **FR-020**: Those settings MUST be applied through the `solveCobraLP` parameter
  pass-through rather than by calling a solver's own API directly, so the solver
  abstraction is preserved (Constitution Principle IV).
- **FR-021**: The chosen settings MUST be **derived by measurement**, and each MUST be
  recorded with the mismatch it corrects between the solver's default and this problem's
  structural profile — sparse, all-equality, simplex-normalised, massively degenerate.
  Principle IV requires exactly this audit and requires mismatched defaults to be
  identified and overridden with the rationale recorded.
- **FR-022**: Each setting MUST be **verified to take effect** rather than assumed. A
  parameter a solver silently ignores, or rejects, is worse than none, because it creates
  the appearance of tuning where there is none.
- **FR-023**: A solver for which no tuned set exists MUST still work, using the solver's
  defaults, and the status MUST record whether a tuned set was applied — so a user on
  glpk or pdco is never left believing they received tuned behaviour they did not get.
- **FR-012**: Coverage behaviour MUST be exercised by tests that run in CI without
  git-submodule content, extending the existing `testGreedyExtremeRayBasis.m` per
  Constitution Principle III-Naming.
- **FR-013**: Every guard introduced MUST be tested against the failure it guards.

### Key Entities

- **Coverage**: rays found against the attainable dimension of the non-negative cone.
- **Attainable dimension**: `dim span(K)`, which equals `dim ker(N')` when the input is
  stoichiometrically consistent and may be smaller otherwise. Distinct from `raysExpected`.
- **Accuracy**: the residual of each returned row against the derived target, unchanged
  from the parent feature.
- **Vertex selection**: how a particular optimal vertex is chosen among many under
  degeneracy — the mechanism this feature acts on.

## Clarifications

### Session 2026-09-15

- Q: May one call use two different solvers, given that a two-phase approach would make
  it depend on two specific installs? -> A: **Initially yes as a fallback; then WITHDRAWN.**
  On review (2026-09-15) the two-phase approach A1 is **dropped from scope entirely** — not
  deferred, not conditional. The feature pursues the two single-solver approaches only.
  **Consequence, stated rather than left implicit**: if neither A2 nor A3 meets SC-001
  there is no remaining approach that closes the gap, and the deliverable becomes User
  Story 3 — an honest account of the limit, with coverage reported truthfully against the
  attainable dimension. That is an acceptable landing point, not a failure.
- Q: If the gap cannot be closed, what is the deliverable? -> A: **Settled by the same
  comparison.** Three named approaches are measured against SC-001; whichever meets it is
  the remedy. If none does, User Story 3 (an honest account of the limit) becomes the
  deliverable, and that is a legitimate outcome rather than a failure.

### The three approaches to measure (FR-014)

| # | Approach | Rationale |
|---|---|---|
| **A2** | **mosek, parameters tailored to the problem** — numerical emphasis raised, via the interior-point tolerances and optimizer selection the toolbox already exposes | mosek already achieves full coverage (105 of 105); the open question is whether its accuracy can be lifted to the target without losing that. |
| **A3** | **gurobi, parameters tailored to the problem** — the same intent expressed with gurobi's own knobs | gurobi already achieves the accuracy (1.185e-16); the open question is whether its vertex coverage can be widened without losing that. |
| **A0** | **Control: both solvers at current defaults** | Not an approach but the baseline the other three are judged against, so a gain is demonstrably a gain over the status quo. |

A2 and A3 are the only approaches pursued. The two-phase approach A1 is **out of scope by
decision**, so neither is a fallback for the other: if both fail, the feature delivers
User Story 3. **Neither is assumed to work**; the choice follows the measurement.

### How the comparison must be run: PAIRED, at identical greedy state

The comparison MUST be a matched one. At a given point in the greedy search the state is
the partially complete basis `Zpos`, the derived support mask, and one drawn objective
vector. Every solver under comparison MUST be handed **that same partial `Zpos` and that
same objective vector**, and their returned rays compared against each other.

This is not a refinement of convenience. The parent feature's per-solver figures came
from independent whole runs with independent random streams, which diverge into different
accumulated bases after the first accepted ray — so they measure solver effect and search
path *confounded together*. A matched design isolates the solver's contribution: given
identical state and identical objective, which vertex does each solver return, how
accurate is it, and does it add a new independent direction?

Because the state exists only inside the search, **the comparison must be instrumented
within `greedyExtremeRayBasis` itself**, not assembled from separate outer runs.

**A grounding note carried from reading the solver interfaces.** The generic
`NUMERICALEMPHASIS` parameter defaults to 1 but is consumed only by the CPLEX interface,
which sets it to 0; mosek and gurobi ignore it. The tuned settings for A2 and A3 are
therefore expressed in each solver's own terms and **encoded in the routine** (FR-019),
passed through `solveCobraLP` rather than set on a solver directly (FR-020). Both are
reachable that way: mosek through `param.lpmethod` -> `MSK_IPAR_OPTIMIZER` and the
`MSK_DPAR_INTPNT_*` tolerances, gurobi through `param.Method`. Which specific settings to
use is a Phase-0 research question, decided by measurement, not here.

**A hypothesis for Phase 0 to test, not an assumption.** The coverage/accuracy split has
the signature of interior-point versus simplex. An interior-point solution without full
basis identification is not an exact vertex, which would explain both mosek's vertex
diversity and its ~1e-12 residuals; simplex returns exact vertices, explaining gurobi's
exactness and its narrow, degeneracy-limited vertex set. If that holds, A2 is
substantially "enable basis identification" and A3 is "vary the tie-break". It must be
measured before it is relied on.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On `iDopaNeuroC`, a single call returns `outcome = 'complete'` with
  `raysFound == raysExpected == 105` and `residualAbsolute <= accuracyTarget`. This is the
  headline criterion; both halves are individually achievable today, so failing it means
  the gap is genuinely hard rather than merely unaddressed.
- **SC-002**: The augmented matrix built from that basis has the same rank integer from
  independent rank routines across at least three orders of magnitude of tolerance, at
  the structural rank.
- **SC-003**: Accuracy does not regress against the parent feature's measured baseline on
  any case where the parent achieved the target.
- **SC-004**: Coverage on the small exact fixtures remains complete, with non-negativity
  intact.
- **SC-005**: A sampling shortfall and a structural shortfall are distinguishable from the
  status alone, each with its shortfall quantified.
- **SC-006**: Approaches A1, A2 and A3 are each measured on the same model and seed, with
  coverage, accuracy, runtime and replicate counts reported per approach in one
  comparable table, so the selected remedy is traceable to evidence and any rejected
  approach was rejected on measurement rather than assumption.
- **SC-009**: If neither A2 nor A3 meets SC-001, the feature delivers User Story 3 and
  records plainly that the gap was not closed by either tuned single-solver configuration,
  with the measured shortfall of each.
- **SC-010**: The comparison record shows, for at least one full greedy search, each
  compared solver's ray at the SAME paired state — identical partial basis, identical
  objective vector — with residual, independence and acceptance per solver per point.
- **SC-011**: With the comparison instrumentation off, results are identical to the same
  call before this feature, demonstrating the instrumentation is inert by default.
- **SC-012**: Every tuned setting the routine applies is demonstrated to take effect for
  the solver it targets — verified, not inferred from having set it.
- **SC-013**: A solver with no tuned set still produces a working result, and the status
  reports that no tuned set was applied.
- **SC-014**: Each tuned setting is recorded against the specific default/profile mismatch
  it corrects, so a reviewer can judge the choice without rerunning the search.
- **SC-007**: Any solver parameter set by the feature is recorded with its rationale and
  reached through the solver abstraction.
- **SC-008**: The coverage tests run within `test/testAll.m`, pass in CI, skip gracefully
  where a required solver is absent, and depend on no submodule content.

## Assumptions

- The parent feature's measurements are taken as given and are not re-derived; they are
  reproducible from the scripts named above.
- **No remedy is assumed to work**, including the three named in Clarifications. Approach
  A1 is known to combine two individually-measured strengths, but whether the combination
  survives being run as one procedure is itself unmeasured. Objective perturbation,
  targeted search for directions outside the current span, and seeding from the strictly
  positive conservation vector remain open candidates that may be folded into A2 or A3.
- **Whether the gap is closable at all is a FINDING of this work, not an input.** If no
  configuration delivers both properties, that MUST be reported plainly; it would make
  User Story 3 the deliverable and would be a legitimate outcome.
- **No runtime is promised**, and no claim is made in advance about which models reach
  full coverage.
- The 105-of-105 figure for mosek was measured at the pre-change acceptance tolerance;
  it establishes that 105 independent non-negative rays are *findable*, not that mosek can
  find 105 *accurate* ones.
- Coverage is measured against the attainable dimension of the non-negative cone, which
  equals the nullity only under stoichiometric consistency.

## Out of Scope

- **The `varkin` repository**, entirely, as in the parent feature.
- **Weakening the parent feature's accuracy contract** in any form.
- **Changing the rank routines** `getRankLUSOL` and `getNullSpace`, which remain
  measurement instruments.
- **Repairing stoichiometric inconsistency.** Where directions are genuinely unreachable,
  this feature reports that; making the network consistent is separate work.
- **Whether `findExtremePool.m` is edited** is a plan-level decision, to be taken
  explicitly with its blast radius stated — its other callers are
  `optimalExtremePoolDriver.m:119` and `testFindExtremePathway.m:75` — and routed to the
  implementation-approval gate rather than assumed here.

## Why the tuned settings are NOT plumbed through the generic parameter layer

An earlier draft of this specification required the numerical-emphasis concept to be
given an analogue for every solver in the shared `src/base/solvers/` parameter layer.
**That approach is withdrawn**, on two grounds:

1. **`setCobraSolverParams` covers only a basic set of parameters.** What this problem
   needs is neither basic nor general: it is degeneracy handling and vertex identification
   chosen for a massively degenerate, simplex-normalised, all-equality LP. Those settings
   have no meaning for most toolbox solves and do not belong in a shared layer.
2. **The blast radius was unacceptable for the gain.** `NUMERICALEMPHASIS` already
   defaults to 1 while the only interface that reads it, CPLEX, sets it to 0. Making the
   other interfaces honour a previously-ignored default would change every LP, QP, MILP
   and EP solve in the toolbox at once, and would have needed regression evidence across
   every solver to ship safely.

The settings therefore live in `greedyExtremeRayBasis`, applied through `solveCobraLP`'s
parameter pass-through. This keeps the solver abstraction intact (FR-020) while putting
problem-specific knowledge with the routine that holds the problem.

**Recorded for a future feature, not fixed here**: the generic `NUMERICALEMPHASIS`
parameter is in an inconsistent state — defaulted to 1 in `getCobraSolverParams`, set to 0
by `CPLEXParamSet`, and ignored by every other interface. That is a real defect in the
shared layer, but it is not this feature's to fix.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, SC-001 (complete AND accurate in one call) | `testGreedyExtremeRayBasis.m` — coverage case | `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m` |
| FR-016, FR-018, SC-010 (paired comparison at identical greedy state) | comparison record under this feature directory | same |
| FR-017, SC-011 (instrumentation inert when off) | `testGreedyExtremeRayBasis.m` — instrumentation-off equivalence case | same |
| FR-019, FR-021, FR-022, SC-012, SC-014 (tuned per-solver settings, measured and verified to take effect) | `testGreedyExtremeRayBasis.m` — tuned-settings cases + research record | `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m` |
| FR-020 (applied through the solver abstraction, not a direct solver API) | code review against Principle IV + `testGreedyExtremeRayBasis.m` | same |
| FR-023, SC-013 (untuned solver still works and says so) | `testGreedyExtremeRayBasis.m` — untuned-solver case | same |
| US1 / SC-002 (augmented rank unambiguous) | `testGreedyExtremeRayBasis.m` — augmented-rank case | same |
| US1 / FR-003, SC-004 (non-negativity, fixtures unregressed) | `testGreedyExtremeRayBasis.m` — exact fixtures | same |
| US2 / FR-007, SC-003 (coverage and accuracy reported together; no accuracy regression) | `testGreedyExtremeRayBasis.m` — status assertions | same |
| US3 / FR-005, FR-006, SC-005 (sampling vs structural shortfall) | `testGreedyExtremeRayBasis.m` — forced shortfall cases | same |
| FR-002, FR-009 (parent contract intact) | `testGreedyExtremeRayBasis.m` — existing parent assertions retained | same |
| FR-004, SC-006 (remedy selected by measurement) | research record under this feature directory | same |
| FR-010, FR-011, SC-007 (solver configuration audit) | research record + plan Constitution Check | same |
| FR-012, FR-013, SC-008 (tests in CI, guards tested against failure) | `testGreedyExtremeRayBasis.m` under `test/verifiedTests/analysis/testTopology/` | same |
