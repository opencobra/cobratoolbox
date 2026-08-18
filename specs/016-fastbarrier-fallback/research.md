# Research: FastBarrier Fallback

## R1. Recoverable Numeric Status Scope

**Decision**: Treat Gurobi native status `NUMERIC` from a fastBarrier no-crossover LP solve
as recoverable only when the solve produced no valid optimal COBRA solution (`stat` is not
`1` and no usable flux can be read). Retry the same LP through the solver abstraction with
barrier crossover enabled or the `Crossover` override removed.

**Rationale**: Local reproduction showed the representative FVA subproblem is valid: the
same saved PFK LP solved as `OPTIMAL` with default Gurobi settings, primal simplex, dual
simplex, and barrier with crossover, but returned `NUMERIC` only with barrier no crossover.
That makes the first attempt an algorithm/settings failure, not a biological or model
infeasibility signal.

**Alternatives considered**:

- Always use barrier with crossover for fastBarrier: more robust, but gives up the successful
  fast path for all reactions.
- Fall back to default solver settings: robust, but may silently leave the intended barrier
  mode and become harder to reason about.
- Map `NUMERIC` to optimal if a primal vector exists: rejected because it risks returning a
  scientifically invalid flux unless feasibility and objective validity are proven.

## R2. Fallback Placement

**Decision**: Place fallback decision-making at the reaction-bound solve boundary inside
`fluxVariability`, where the code has the configured LP problem, the returned solver status,
and the fastBarrier mode context.

**Rationale**: `solveCobraLP` must keep canonical solver-status semantics for all callers;
changing it to auto-retry Gurobi `NUMERIC` would affect unrelated analyses. The fallback is
an FVA fastBarrier feature, so it should be activated only when fastBarrier requested the
no-crossover path.

**Alternatives considered**:

- Change `solveCobraLP`: rejected as too broad and likely to alter non-FVA solver behaviour.
- Change `mapSolverStatus`: rejected because `NUMERIC` is not an optimal status and mapping
  it differently would hide a real solver diagnostic.
- Catch the thrown FVA error at the outer `fluxVariability` level: rejected because it would
  lose the exact reaction/min-or-max context and complicate partial results.

## R3. Heuristics Interaction

**Decision**: Ensure fastBarrier does not run default FVA heuristics that rely on
interior-point solutions. The fastBarrier path should set the heuristic level to zero after
default heuristic assignment if the caller did not explicitly provide a compatible value.

**Rationale**: The current code tries to disable heuristics before the default value is
assigned, so reaction lists with at least five reactions can still receive default
heuristics. The source comment already records that heuristics are incompatible with
interior-point fastBarrier solutions.

**Alternatives considered**:

- Leave heuristics unchanged: rejected because it contradicts the existing source comment
  and can mix no-crossover interior solutions with heuristic shortcuts.
- Disable heuristics globally: rejected because ordinary FVA should keep existing
  performance behaviour.
- Add a new user option: rejected because the feature is a reliability fix and should not
  expand the public interface.

## R4. Solver State Restoration

**Decision**: Preserve the existing fastBarrier solver-state restoration behaviour and make
sure it also runs if fallback fails after temporarily selecting Gurobi.

**Rationale**: `fluxVariability` currently saves the original LP solver before selecting
Gurobi for fastBarrier. Any new failure path introduced by fallback must not leave the user
in a different solver state after the call.

**Alternatives considered**:

- Leave restoration only at normal function exit: rejected because errors before the final
  restoration can leak solver state.
- Do not select Gurobi internally: rejected because fastBarrier is currently Gurobi-backed
  and the public option depends on that backend.

## R5. Validation Strategy

**Decision**: Use the existing `testFVA` verified test as the primary validation, with a
targeted local probe allowed during implementation to confirm PFK/PPS trigger the fallback.

**Rationale**: `testFVA` already computes standard FVA reference values, runs fastBarrier on
the same reaction list, and asserts min/max flux equality within the established tolerance.
That directly discharges the feature's user-facing requirement.

**Alternatives considered**:

- Add a separate fixture saved from the failing LP: rejected because it would introduce a new
  binary/probe artifact when the existing model already reproduces the issue.
- Weaken `testFVA`: rejected by the user request and by the requirement to preserve scientific
  correctness.
