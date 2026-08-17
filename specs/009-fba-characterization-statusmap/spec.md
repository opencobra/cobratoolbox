# Feature Specification: LP/FBA characterization net + consolidated mapSolverStatus

**Feature Branch**: `009-fba-characterization-statusmap`

**Created**: 2026-07-15

**Status**: Draft

**Input**: User description: "Characterization safety net + solver-status-map consolidation for the LP/FBA core (W7-core + W2 from analysis/WEAKNESSES.md). Additive, Principle-II-safe. Part 1: characterization tests pinning the CURRENT behavior of optimizeCbModel → buildOptProblemFromModel → solveCobraLP across status matrix, minNorm strategies, osense, allowLoops, and primal+dual quantities. Part 2: behavior-preserving extraction of a single mapSolverStatus(solver, problemType, origStat) helper that the four solveCobra* dispatchers route through, removing the duplicated status maps. No public interface or model-field change."

<!--
  CHARACTERIZATION MODE: this feature back-fills tests for EXISTING untested behavior of
  the LP/FBA core (Constitution Principle III, "Characterization: Legacy Back-Fill Mode").
  The "Existing Contract" section captures CURRENT behavior; the Functional Requirements
  describe the test's assertions of that contract plus the behavior-preserving refactor
  it guards — not new capabilities.
-->

## Clarifications

### Session 2026-07-15

- Q: Include both the characterization net (Part 1) and the mapSolverStatus refactor (Part 2) in feature 009, or land the net only and defer the refactor? → A: **Both in 009.** The feature delivers Part 1 (the LP/FBA characterization net) AND Part 2 (behavior-preserving `mapSolverStatus` extraction + rerouting `solveCobraLP/QP/MILP/MIQP`), with Part 2 gated behind Part 1's net being green. It is therefore an explicit "characterization-then-behavior-preserving-refactor", not a pure characterization feature: Part 1 tests do NOT change the functions under test (Principle III), and Part 2 changes only status-map routing with `.stat`/`.origStat` identical to pre-change (guarded by Part 1).
- Q: Consolidate all four dispatchers, or stop Part 2 at the cleanly-verifiable ones? → A: **Stop Part 2 at dqq (LP) + cplex (QP)** (closeout 2026-07-15). FR-009 is met for `solveCobraLP` (dqq/quadMinos map) and `solveCobraQP` (cplex-family map). MILP/MIQP consolidation is **DEFERRED to a follow-up feature**: those blocks are heterogeneous (non-identical cplex variants + gurobi + glpk + the `106||106` quirk), have no MILP/MIQP characterization net, and use solvers not installed in this environment (cplex/tomlab), so consolidating them would be verifiable only by transcription-asserting unit tests on production IP-dispatch code. The dqq consolidation is verified END-TO-END (existing `testSolveCobraLP` exercises dqqMinos/quadMinos); the QP consolidation is unit-test-guarded.
- Q: The Part 1 net caught a latent gurobi bug (`solveCobraLP.m:911` passes `param` not `gurobiParam` on the INF_OR_UNBD retry → crash on R2026a gurobi, blocking the unbounded characterization on the CI solver). Fix now or defer? → A: **Fix now, folded into 009** (in-scope defect-fix, FR-013). One-line `param`→`gurobiParam` at :911 matching the main call at :871; makes gurobi return a clean `stat==2` for unbounded. Verified. Recorded as memory `solvecobralp-gurobi-inf-or-unbd-param-bug`.

## User Scenarios & Testing *(mandatory)*

The "users" here are the toolbox maintainers and contributors who refactor the solver
spine, and the CI that must catch regressions. The value: the most-depended-upon analysis
path becomes safe to change, and the duplicated, drift-prone status maps collapse to one
canonical helper — without altering any result users see today.

### User Story 1 - A behavioral net pins the LP/FBA core so refactors are safe (Priority: P1)

A maintainer runs the suite and a new characterization test drives
`optimizeCbModel → buildOptProblemFromModel → solveCobraLP` across the behavior the
existing happy-path tests miss — the full status matrix, every `minNorm` strategy, both
optimization senses, loopless on/off, and primal **and** dual quantities — asserting the
CURRENT results within tolerance. Any later change that perturbs status semantics, an
objective, a feasibility outcome, or a dual makes the suite fail.

**Why this priority**: This is the safety net. It is the entire justification for doing W2
next (and the prerequisite W1/W4/W5/W6/W16 all cite). Shippable and valuable on its own —
even if Part 2 never lands, the net has closed the highest-leverage coverage gap.

**Independent Test**: Add the characterization suite under `test/verifiedTests/`, run it via
the harness, and confirm it passes (or skips cleanly when a required solver is absent),
exercises the documented behavior axes, and fails if a characterized value is perturbed
(demonstrated by a deliberate local perturbation).

**Acceptance Scenarios**:

1. **Given** a feasible model, **When** `optimizeCbModel` is run for each `minNorm` in
   {0, 'one', 'zero' (each `zeroNormApprox`), a weighted vector, 'optimizeCardinality'} and
   each `osenseStr` in {'max','min'}, **Then** the returned `.stat`, objective `.f`, and the
   mass-balance residual match the pinned reference within tolerance.
2. **Given** a deliberately infeasible model and a deliberately unbounded model, **When**
   solved, **Then** the canonical `.stat` (and preserved `.origStat`) match the pinned
   values for infeasible and unbounded respectively — the status matrix the current tests
   never assert.
3. **Given** a feasible model, **When** solved, **Then** the dual quantities (reduced costs
   `.w`, shadow prices `.y`) and the primal `.v`/`.x` match the pinned reference within
   tolerance.
4. **Given** loopless FBA requested (`allowLoops=false`) versus allowed, **When** solved,
   **Then** each path's characterized outcome is pinned.
5. **Given** a machine whose configured solver lacks a required capability (e.g. no QP for
   an L2 `minNorm`), **When** the suite runs, **Then** it skips cleanly
   (`COBRA:RequirementsNotMet` via `prepareTest`) rather than erroring.

---

### User Story 2 - Duplicated solver status maps collapse to one helper, results unchanged (Priority: P2)

A maintainer extracts a single `mapSolverStatus(solver, problemType, origStat)` and routes
`solveCobraLP/QP/MILP/MIQP` through it, deleting the copy-pasted native→canonical `.stat`
translations (e.g. the `dqqStatMap` duplicated at `solveCobraLP.m:419` and `:555`, the
gurobi map rewritten in all four). Guarded by US1, the canonical `.stat` and `.origStat`
every caller sees are byte-for-byte the same as before.

**Why this priority**: Removes W2's silent-correctness hazard (the four maps can disagree),
but only safely **after** US1's net exists. Depends on US1; deferrable to a follow-up
without losing US1's value.

**Independent Test**: With US1's suite green, extract the helper, reroute the four
dispatchers, and confirm the suite still passes with identical `.stat`/`.origStat` for every
characterized case, and that the duplicated map literals are gone.

**Acceptance Scenarios**:

1. **Given** the characterization net from US1 is green, **When** `mapSolverStatus` is
   introduced and the four dispatchers routed through it, **Then** the suite still passes
   with `.stat`/`.origStat` identical to pre-change for every characterized case.
2. **Given** the refactor, **When** the four `solveCobra*` files are inspected, **Then** the
   per-solver status-map literals appear once (in the helper), not duplicated across files
   or twice within one file.
3. **Given** a solver whose native status is unmapped/unknown, **When** `mapSolverStatus`
   receives it, **Then** it returns the same canonical fallback the current code does and
   preserves `.origStat` (no swallowed states).

### Edge Cases

- **Non-deterministic / solver-dependent outputs**: fluxes and duals can vary by solver and
  tolerance; the characterization must pin with justified tolerances and fixed seeds, and
  where a value is inherently solver-specific, pin the invariant (status, objective,
  feasibility) rather than an exact flux vector (Constitution III).
- **CI runs mostly gurobi**: characterized reference values must be capturable and stable on
  the CI solver; other solvers' status maps are characterized where those solvers are
  available and skipped (not failed) otherwise.
- **Infeasible/unbounded construction**: deliberately constructing these states portably
  (across solvers) is required; the reference `.stat` must be the canonical mapping, not a
  solver-native code.
- **`minNorm` requiring QP** (L2/weighted): needs a QP solver; must `prepareTest('needsQP')`
  and skip cleanly when absent.
- **origStat immutability during refactor**: current code mutates `.origStat` with warning
  strings during post-solve residual re-checks (`solveCobraLP.m:1616`); the status-map
  extraction MUST NOT alter that observable behavior in this feature (that cleanup is W16,
  out of scope).
- **Deprecated timing APIs / dead branches** (`clock`/`etime`, unreachable statements, W17)
  in these files MUST NOT be "fixed" here — characterization pins current behavior only.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The suite MUST characterize `optimizeCbModel` across every `minNorm` strategy
  it branches on (0/[], 'one', 'zero' with each `zeroNormApprox`, a weighted vector,
  'optimizeCardinality') and both `osenseStr` values, asserting `.stat`, `.f`, and
  mass-balance residual against pinned references within tolerance.
- **FR-002**: The suite MUST characterize the **status matrix** — optimal, infeasible,
  unbounded, and (where reproducible) numerical-issue — asserting the canonical `.stat` and
  the preserved `.origStat`, which the existing tests never do.
- **FR-003**: The suite MUST characterize **dual** quantities (reduced costs `.w`, shadow
  prices `.y`) alongside primal (`.v`/`.x`), within tolerance.
- **FR-004**: The suite MUST characterize `buildOptProblemFromModel` directly (its currently
  untested model→problem mapping) for at least the LP and QP problem types on a small model.
- **FR-005**: The suite MUST characterize `solveCobraLP` on a built problem, covering the
  status outcomes in FR-002 at the dispatcher level.
- **FR-006**: All new tests MUST declare requirements via `prepareTest`
  (`needsLP`/`needsQP`, solver exclusions), skip cleanly when unmet, use assert-with-
  tolerance (justified `tol`), fix random seeds, keep output gated behind `printLevel`, run
  under `test/testAll.m` and CI, and avoid internet/GUI.
- **FR-007**: The tests MUST NOT modify the functions under test (characterization mode,
  Constitution Principle III); a defect discovered is recorded, not fixed here.
- **FR-008**: A single `mapSolverStatus(solver, problemType, origStat)` helper MUST be
  introduced under a new subfolder of `src/base/solvers/`, returning the canonical `.stat`
  for a solver's native status and preserving `.origStat`.
- **FR-009**: `solveCobraLP`, `solveCobraQP`, `solveCobraMILP`, and `solveCobraMIQP` MUST
  route native→canonical status translation through `mapSolverStatus`, and the duplicated
  status-map literals (including the twice-in-one-file `dqqStatMap`) MUST be removed.
- **FR-010**: The refactor MUST be behavior-preserving: for every characterized case the
  canonical `.stat` and `.origStat` MUST be identical to pre-change (verified by US1's suite
  staying green with the same pinned values).
- **FR-011**: No public interface change (Principle II): `changeCobraSolver`, the
  `solveCobra*` signatures, and returned solution fields (`.stat`, `.origStat`, `.full`,
  `.obj`, duals) MUST be unchanged; no model-field change.
- **FR-012**: For each solver whose status map is consolidated, the plan MUST record an
  external-solver configuration-surface audit (relevant status codes/options and the
  representative instance used), per Constitution Principle IV.
- **FR-013** *(added during implementation — in-scope defect-fix)*: `solveCobraLP.m` MUST pass
  the correctly-built gurobi param struct (`gurobiParam`) on the `INF_OR_UNBD` retry (line 911),
  not the raw merged `param`, so gurobi returns a clean canonical `.stat == 2` for unbounded LPs
  instead of crashing on newer gurobi (`params.logFile must be a string`). This is the one latent
  bug the Part 1 net surfaced; the fix is a single token and changes only the previously-crashing
  path.

### Key Entities *(the behaviors/artifacts this feature touches)*

- **LP/FBA spine** (`src/analysis/FBA/optimizeCbModel.m`,
  `src/base/solvers/buildOptProblemFromModel.m`, `src/base/solvers/solveCobraLP.m`): the
  functions whose EXISTING behavior is characterized (read-only in Part 1).
- **Solver dispatchers** (`solveCobraLP/QP/MILP/MIQP.m`): route through the new helper in
  Part 2; only the status-map translation changes, behavior preserved.
- **`mapSolverStatus` helper** (new, under `src/base/solvers/`): the single canonical
  native→`.stat` map.
- **Characterization suite** (new, under `test/verifiedTests/`): the pinned behavioral net.

## Existing Contract *(characterization mode — the CURRENT behavior being pinned)*

<!-- Captured from the current code; the suite asserts this, it is not a new design. -->

- **Function(s) under test**: `optimizeCbModel(model, osenseStr, minNorm, allowLoops, param)`;
  `buildOptProblemFromModel(model, ...)`; `solveCobraLP(LPproblem, ...)`.
- **Current inputs / arities**: `optimizeCbModel` accepts `osenseStr∈{'max','min'}`;
  `minNorm∈{0/[]/logical, 'one', 'zero'(+`zeroNormApprox`, default 'cappedL1'), n×1 vector,
  'optimizeCardinality'}` (`optimizeCbModel.m:80,276–417`); `allowLoops` toggles loopless;
  optional `param` struct. `minNorm=0` is normalized to `[]`; `minNorm=true→1e-6`.
- **Current outputs**: a `solution` struct with `.stat` (canonical: 1 optimal, 0 infeasible,
  2 unbounded, 3 ~feasible/numerical), `.origStat` (solver-native), `.f`, `.v`/`.x`, and
  duals `.w` (reduced costs), `.y` (shadow prices); mass balance `‖S·v − b‖ ≈ 0` at
  optimality.
- **Invariants & expected results** (pin within `tol`, fixed seed where stochastic): at
  optimality `.stat==1` and residual `< tol`; objective consistent across `minNorm` variants
  that preserve the optimum; infeasible→`.stat==0`, unbounded→`.stat==2`; `.origStat`
  retained from the solver.
- **Status-map duplication (the target of Part 2)**: `solveCobraLP.m` defines `dqqStatMap`
  at `:419` and again at `:555`; gurobi native→canonical translation is re-implemented in
  `solveCobraLP/QP/MILP/MIQP`; only mosek is factored out (`mosek/parseMskResult.m`).
- **Coverage gap**: `testOptimizeCbModel.m` asserts only `.stat==1`, mass balance, and
  objective for `minNorm∈{0,'one'}` and `osense='max'`; `buildOptProblemFromModel` has no
  direct test (from CI coverage / W7-core, W2).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The characterization suite pins `optimizeCbModel` behavior across all
  documented `minNorm` strategies and both senses; introducing a deliberate perturbation to
  any characterized status/objective/feasibility/dual makes the suite fail.
- **SC-002**: The suite asserts the full status matrix (optimal/infeasible/unbounded, plus
  numerical where reproducible) with canonical `.stat` and preserved `.origStat` — coverage
  the pre-feature suite did not have.
- **SC-003**: `buildOptProblemFromModel` and `solveCobraLP` each gain a direct
  characterization test that runs in CI and skips cleanly when a required solver is absent.
- **SC-004**: A single `mapSolverStatus` helper exists and all four `solveCobra*` dispatchers
  route through it; the duplicated status-map literals (incl. the twice-in-one-file
  `dqqStatMap`) are removed (verifiable by search).
- **SC-005**: After the refactor, every characterized case yields `.stat`/`.origStat`
  identical to pre-change (US1 suite green with unchanged pinned values); CI passes.
- **SC-006**: No public interface or model-field changed: `changeCobraSolver` and the
  `solveCobra*` signatures/return fields are unchanged (verifiable by diff and by the
  existing solver tests still passing).

## Assumptions

- The consumers are maintainers/contributors and CI; there is no end-user-facing surface.
- Confirmed (clarification 2026-07-15): this feature includes BOTH the characterization net
  (Part 1) and the behavior-preserving `mapSolverStatus` extraction (Part 2); Part 2 is gated
  on Part 1 being green. Not split — both land in 009.
- Reference values are captured by running the CURRENT code under the CI-available solver
  (gurobi) during implementation; other solvers are characterized where available, skipped
  otherwise. Fixed seeds and justified tolerances make them CI-stable.
- Small purpose-built models (and/or an existing tiny shipped model) are used as fixtures so
  infeasible/unbounded/QP cases are constructed portably; heavyweight genome-scale runs are
  avoided (default/fast mode friendly).
- Out of scope and explicitly NOT changed here: W1 (solver globals), W5 (`optimizeCbModel`
  decomposition), W16 (`.origStat` mutation cleanup / build-solve orchestrator), W17 (dead
  code / deprecated timing APIs), W3 leaks, and all non-LP/FBA subtrees.

## Traceability

*(Per FR-001…; each acceptance criterion maps to a characterization test and the
`src/<domain>/` function under test.)*

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1-1 / FR-001 — minNorm × osense matrix | `testOptimizeCbModel` (new, test/verifiedTests/analysis/) | `src/analysis/FBA/optimizeCbModel.m` |
| US1-2 / FR-002 — status matrix (infeasible/unbounded) | `testOptimizeCbModel` + `testSolveCobraLP` | `src/analysis/FBA/optimizeCbModel.m`; `src/base/solvers/solveCobraLP.m` |
| US1-3 / FR-003 — primal + dual quantities | `testOptimizeCbModel` | `src/analysis/FBA/optimizeCbModel.m` |
| US1-4 / FR-001 — allowLoops on/off | `testOptimizeCbModel` | `src/analysis/FBA/optimizeCbModel.m` |
| US1-5 / FR-006 — clean skip when solver absent | all new tests (prepareTest gating) | `src/base/solvers/` (solver availability) |
| US1 / FR-004 — model→problem mapping | `testBuildOptProblemFromModel` (new) | `src/base/solvers/buildOptProblemFromModel.m` |
| US2-1,2 / FR-008, FR-009, FR-010 — mapSolverStatus + reroute, results unchanged | US1 suite re-run green + search for removed literals | `src/base/solvers/mapSolverStatus.m` (new); `solveCobraLP/QP/MILP/MIQP.m` |
| US2-3 / FR-008 — unknown native status fallback | `testMapSolverStatus` (new, unit) | `src/base/solvers/mapSolverStatus.m` |
| FR-011, FR-012, SC-006 — no interface change; config-surface audit | existing solver tests still pass; plan research note | `solveCobra*.m` signatures / return fields |
