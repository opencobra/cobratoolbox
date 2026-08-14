# Data Model: FastBarrier Fallback

## FVA Request

Represents a user-level flux variability request.

**Fields / attributes**:

- `model`: COBRA model with stoichiometry, bounds, objective, and reaction identifiers.
- `optPercentage`: required fraction of the original objective optimum.
- `osenseStr`: optimization sense for the original model objective.
- `rxnNameList`: ordered list of target reactions for min/max flux analysis.
- `allowLoops`: loop handling mode.
- `method`: flux-vector post-processing method when full vectors are requested.
- `threads`: serial or parallel execution selection.
- `fastBarrier`: binary request for the fastBarrier min/max path.

**Validation rules**:

- Reaction names must exist in the model.
- fastBarrier remains limited to min/max flux values and must not expand unsupported vector
  output modes.
- Ordinary FVA requests must keep existing behaviour.

## Reaction Flux Bound Solve

Represents one minimum or maximum optimization for one target reaction.

**Fields / attributes**:

- `LPproblem`: COBRA LP problem after the original objective optimum constraint is applied.
- `rxnID`: target reaction index.
- `osense`: direction of the bound solve.
- `solverParameters`: LP solver controls supplied through FVA and COBRA parameter parsing.
- `allowLoopsI`: per-reaction loop-law decision.
- `precomputedSolution`: optional heuristic solution.

**Relationships**:

- Belongs to one FVA Request.
- Produces one Flux Bound Result.
- May have one FastBarrier Attempt and, conditionally, one Fallback Attempt.

**Validation rules**:

- The fallback attempt must solve the same LP objective, target reaction, bounds, constraints,
  and sense as the failed fast attempt.
- A result is valid only when the solver status is optimal or the existing unbounded handling
  applies.

## FastBarrier Attempt

Represents the initial fast solver attempt for a Reaction Flux Bound Solve.

**Fields / attributes**:

- `algorithmMode`: barrier.
- `crossoverMode`: disabled.
- `solverStatus`: canonical COBRA status plus native status.
- `solutionVector`: primal solution when available.

**State transitions**:

- `notRun` -> `optimal`: use result immediately.
- `notRun` -> `recoverableNumericFailure`: trigger Fallback Attempt.
- `notRun` -> `nonRecoverableFailure`: report through existing FVA failure semantics.
- `notRun` -> `unbounded`: use existing unbounded flux handling.

## Fallback Attempt

Represents the retry used only for recoverable fastBarrier numerical failure.

**Fields / attributes**:

- `algorithmMode`: barrier.
- `crossoverMode`: enabled or solver default.
- `solverStatus`: canonical COBRA status plus native status.
- `solutionVector`: primal solution when available.

**State transitions**:

- `notRun` -> `optimal`: return retry flux value.
- `notRun` -> `failed`: propagate existing FVA failure semantics.
- `notRun` -> `unbounded`: use existing unbounded flux handling if appropriate.

**Validation rules**:

- Must not run for ordinary FVA.
- Must not run for non-recoverable infeasible or unbounded statuses unless existing FVA logic
  already treats the status as a valid outcome.
- Must not suppress solver warnings.

## Flux Bound Result

Represents the min or max flux value returned for one reaction.

**Fields / attributes**:

- `fluxValue`: finite value or existing infinity value for unbounded cases.
- `sourceAttempt`: fast attempt, fallback attempt, or precomputed heuristic.
- `reactionOrder`: position in the user's requested reaction list.

**Validation rules**:

- Returned values must preserve request order.
- fastBarrier values must match standard FVA values within the established test tolerance.

## Solver State Snapshot

Represents the user's active LP solver selection before fastBarrier temporarily selects
Gurobi.

**Fields / attributes**:

- `originalLPSolver`: active LP solver before fastBarrier setup.
- `temporaryLPSolver`: Gurobi while fastBarrier executes.

**Validation rules**:

- `originalLPSolver` must be restored on success and failure.
