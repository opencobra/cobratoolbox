# Feature Specification: FastBarrier Fallback

**Feature Branch**: `016-fastbarrier-fallback`

**Created**: 2026-08-14

**Status**: Draft

**Input**: User description: "add a fastBarrier retry with Crossover removed/enabled when Gurobi reports NUMERIC. for FVA. then make sure the testFVA passes. This would be a fallback for fastbarrier option when it fails to reach to the optimal"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Complete FastBarrier FVA Despite Recoverable Solver Numeric Status (Priority: P1)

A COBRA Toolbox user runs flux variability analysis with the fastBarrier option enabled. If the faster solver attempt encounters a recoverable numerical status even though the same flux bound problem can be solved with a more robust barrier solve, the analysis retries automatically and returns the expected flux minima and maxima instead of failing the whole analysis.

**Why this priority**: This restores reliability for the fastBarrier option and prevents a numerically fragile first attempt from breaking valid FVA workflows.

**Independent Test**: Can be fully tested by running the existing FVA verified test with a Gurobi-enabled environment and confirming the fastBarrier section completes and matches standard FVA flux ranges within the established tolerance.

**Acceptance Scenarios**:

1. **Given** a model and reaction list for which the fastBarrier first attempt reports a recoverable numerical solver status, **When** the user runs FVA with fastBarrier enabled, **Then** the analysis retries using the more robust barrier path and returns finite min/max flux values that match standard FVA within the documented tolerance.
2. **Given** a model and reaction list for which the fastBarrier first attempt succeeds, **When** the user runs FVA with fastBarrier enabled, **Then** the analysis returns the fastBarrier results without changing the successful path's reported flux values.
3. **Given** a model and reaction list for which both the initial fastBarrier attempt and the retry cannot produce a valid solution, **When** the user runs FVA with fastBarrier enabled, **Then** the analysis reports the existing failure semantics rather than silently returning invalid flux values.

---

### User Story 2 - Preserve Standard FVA Behaviour (Priority: P2)

A COBRA Toolbox user runs ordinary FVA without fastBarrier. The existing solver behaviour, output shape, tolerances, and error semantics remain unchanged.

**Why this priority**: The fallback is scoped to a specialized fastBarrier path and must not perturb established FVA workflows used by existing scripts and publications.

**Independent Test**: Can be tested by comparing the ordinary FVA portions of the existing FVA verified test before and after the feature; those sections must continue to pass.

**Acceptance Scenarios**:

1. **Given** fastBarrier is not requested, **When** the user runs FVA on the existing verified models, **Then** standard FVA results and failure handling remain unchanged.
2. **Given** a caller requests full flux vectors or loopless modes already covered by the FVA test suite, **When** FVA runs without fastBarrier, **Then** the existing output availability and validation assertions continue to pass.

---

### User Story 3 - Keep FastBarrier Solver State Predictable (Priority: P3)

A COBRA Toolbox user or downstream script relies on configured solvers outside an FVA call. After a fastBarrier FVA run succeeds, falls back, or fails, the user's solver selection remains consistent with pre-call behaviour.

**Why this priority**: FastBarrier may select a specific solver internally, but user-level solver configuration must remain stable for subsequent analyses.

**Independent Test**: Can be tested by setting a known LP solver before a fastBarrier FVA call and confirming the active LP solver after the call matches the pre-call solver.

**Acceptance Scenarios**:

1. **Given** a user has an active LP solver configured before fastBarrier FVA, **When** fastBarrier FVA completes successfully after retry, **Then** the active LP solver is restored to the pre-call solver.
2. **Given** a user has an active LP solver configured before fastBarrier FVA, **When** fastBarrier FVA fails after all valid attempts, **Then** the active LP solver is restored before the failure is reported.

### Edge Cases

- The first fastBarrier attempt reports a recoverable numerical status and provides no usable primal solution.
- The first fastBarrier attempt reports a non-recoverable status; the feature must not misclassify infeasible or unbounded models as solvable.
- A retry succeeds for some reactions and the initial fast path succeeds for others within the same reaction list; all returned fluxes must align with their reaction order.
- The retry path must not return full flux-vector outputs that fastBarrier mode does not support.
- The active solver must be restored even when an error is thrown during the fallback process.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: FVA with fastBarrier enabled MUST retry a reaction-specific flux bound solve when the initial fast attempt reports a recoverable numerical solver status and no valid flux value can be returned.
- **FR-002**: The fallback retry MUST use a more robust barrier solve that is expected to produce the same flux bound when the model is numerically solvable.
- **FR-003**: The fallback retry MUST preserve the same model, objective sense, optimality percentage constraint, reaction target, loop allowance, and caller-supplied non-conflicting solver controls as the failed initial attempt.
- **FR-004**: If the fallback retry returns a valid optimal solution, FVA MUST return the retry's flux value for that reaction and continue processing the requested reaction list.
- **FR-005**: If both the initial fast attempt and the fallback retry fail to produce a valid solution, FVA MUST retain existing failure semantics and MUST NOT return an invalid or missing flux value as if it were valid.
- **FR-006**: Standard FVA calls that do not enable fastBarrier MUST preserve documented public interfaces, diagnostic semantics, output shapes, and solver-status behaviour.
- **FR-007**: FastBarrier FVA MUST restore the caller's pre-call LP solver selection after successful completion and after reported failure.
- **FR-008**: The feature MUST include a reproducibility check using the existing FVA verified test that exercises the fastBarrier fallback and confirms the test passes in a Gurobi-enabled environment.
- **FR-009**: The feature MUST verify that fastBarrier min/max fluxes match standard FVA min/max fluxes for the existing verified reaction set within the established FVA tolerance.
- **FR-010**: The feature MUST avoid expanding the scope of fastBarrier beyond min/max flux values; unsupported output modes MUST continue to behave according to the existing documented constraints.

### Key Entities

- **FVA Request**: A user request to compute minimum and maximum allowable fluxes for one or more reactions under an optimality percentage and objective sense.
- **Reaction Flux Bound Solve**: The individual optimization problem used to obtain a minimum or maximum flux value for one reaction.
- **FastBarrier Attempt**: The first fastBarrier optimization attempt for a reaction flux bound solve.
- **Fallback Attempt**: The retry path used only when the fastBarrier attempt reaches a recoverable numerical solver status.
- **Solver Status**: The result classification returned from the optimization solver, including success, infeasible/unbounded, and numerical trouble states.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The existing verified FVA test completes successfully in the local Gurobi-enabled environment, including the fastBarrier section that previously failed.
- **SC-002**: For the verified FVA reaction list, fastBarrier min/max flux values match standard FVA min/max flux values with maximum absolute difference below the existing FVA tolerance.
- **SC-003**: For a targeted recoverable numerical-status case, the fastBarrier call completes without user intervention and returns finite min/max flux values.
- **SC-004**: Ordinary FVA test scenarios in the verified FVA test continue to pass, demonstrating that non-fastBarrier workflows are unaffected.
- **SC-005**: A solver-state preservation check confirms the active LP solver after a fastBarrier call is the same as before the call in both success and failure paths.
- **SC-006**: If both the initial fast attempt and fallback retry fail, the user receives a failure rather than silent or partial success, preserving scientific correctness.

## Assumptions

- The fallback applies only to recoverable numerical solver statuses from the fastBarrier first attempt, not to scientifically meaningful infeasible or unbounded outcomes.
- Gurobi is the solver used for fastBarrier mode in the target environment.
- The existing FVA verified test is the authoritative regression test for this feature because it already covers standard FVA, fastBarrier comparison, solver availability, and numerical tolerances.
- The established FVA tolerance remains appropriate for comparing fastBarrier and standard FVA min/max flux values.
- The feature is a reliability improvement for an existing public option and does not introduce new user-facing parameters.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, FR-002, FR-004, FR-008, FR-009 | test/verifiedTests/analysis/testFVA/testFVA.m | src/analysis/FVA/fluxVariability.m |
| US1 / FR-003 | test/verifiedTests/analysis/testFVA/testFVA.m | src/analysis/FVA/fluxVariability.m |
| US1 / FR-005, SC-006 | Targeted expected-failure check or existing error-path assertion added to the verified FVA coverage | src/analysis/FVA/fluxVariability.m |
| US2 / FR-006, FR-010 | test/verifiedTests/analysis/testFVA/testFVA.m | src/analysis/FVA/fluxVariability.m |
| US3 / FR-007, SC-005 | Solver-state preservation check in verified FVA coverage or a focused FVA regression check | src/analysis/FVA/fluxVariability.m |
