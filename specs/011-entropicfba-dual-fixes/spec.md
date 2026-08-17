# Feature Specification: Entropic-FBA infeasible-diagnostic hardening, legacy-test repair, and GECKO dual-residual resolution

**Feature Branch**: `011-entropicfba-dual-fixes`

**Created**: 2026-07-16

**Status**: Draft

**Input**: User description: fix two latent entropic-FBA defects and resolve-or-characterize the mosek GECKO dual-optimality warning, all surfaced during feature 010-gecko-entropic-fba (now merged on `develop`). Bug-fix + numerical-characterization work over existing `src/base/solvers/entropicFBA/` code and its tests; additive/corrective only, no public-interface or model-field change (Principle II), routed through the existing `solveCobraEP` layer (Principle IV).

## Clarifications

### Session 2026-07-16

- Q: For US3 (the mosek GECKO dual residual = 1.45), how should Bundle 3 approach the
  resolve-vs-characterize decision (effort ceiling / blast radius on a core solver)? →
  A: Pursue the fix — treat driving the mosek dual residual below `optTol` as the goal, including,
  if warranted, deeper changes to the enzyme cone-dual reconstruction (`Fty_K` reordering / offsets)
  in `solveCobraEP`; fall back to characterize-and-tolerate ONLY if a correct fix proves infeasible.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Infeasible enzyme-constrained EP returns a clean status instead of crashing (Priority: P1)

A user runs `entropicFluxBalanceAnalysis` on an enzyme-constrained (GECKO) model whose enzyme
capacity is too small to meet a forced flux, so the entropic problem is infeasible. Today the
call aborts with an undefined-variable error (`message`) rather than returning a solution with a
feasibility status. The user should instead receive a solution structure whose status reports
infeasibility, carrying an informative message, so their calling code can branch on `solution.stat`
as the documented contract promises — exactly as it already does for a plainly infeasible
(non-enzyme) model.

**Why this priority**: This is the only path in the feature that produces a hard crash of a
public solver function on legitimate input. It is the highest user-facing risk and the reason the
010 GECKO test had to avoid the strictly-infeasible case.

**Independent Test**: Construct a minimal enzyme-constrained fixture whose enzyme upper bound is
below the forced flux (a strictly-infeasible variant of the 010 toy), call
`entropicFluxBalanceAnalysis` under mosek, and assert it returns `solution.stat == 0` with a
non-empty `solution.messages` and raises no undefined-variable or dimension error. Delivers a
robust, contract-conformant infeasible path.

**Acceptance Scenarios**:

1. **Given** an enzyme-constrained model infeasible only because of the enzyme cap, **When**
   `entropicFluxBalanceAnalysis` is called under mosek, **Then** it returns `solution.stat == 0`
   with a populated `solution.messages` and no error is thrown.
2. **Given** any model where the internal LP feasibility diagnostic (`optimizeCbModel`) returns a
   status other than 0 or 1 (e.g. unbounded), **When** the EP is infeasible, **Then** `message` is
   defined and the solution is returned with a status and message rather than crashing.
3. **Given** a plainly infeasible non-enzyme model, **When** `entropicFluxBalanceAnalysis` is
   called, **Then** its existing clean `stat == 0` behaviour is preserved (no regression).

---

### User Story 2 - Legacy entropic-FBA test runs standalone and actually exercises the function (Priority: P2)

A developer runs `testEntropicFluxBalanceAnalysis` on its own (fresh MATLAB workspace) to check
`entropicFluxBalanceAnalysis`. Today it errors on line 29 with `Unrecognized function or variable
'k'` before the model is even loaded, so it never calls the function under test; in the CI harness
it only "passes" because an earlier test happens to leave a usable `k` in scope. The developer
should be able to run the test in isolation and have it genuinely execute the function and its
assertions.

**Why this priority**: It is a real test-integrity defect (the test validates nothing standalone),
but it is confined to one test file, does not affect the shipped function, and is a small change.

**Independent Test**: Run `testEntropicFluxBalanceAnalysis` from a clean workspace with no stray
`k` and confirm it reaches and executes `entropicFluxBalanceAnalysis(model, param)` and completes
green, with its existing `solution.stat == 1` assertion intact.

**Acceptance Scenarios**:

1. **Given** a fresh MATLAB workspace with no variable `k`, **When** `testEntropicFluxBalanceAnalysis`
   is run, **Then** it does not error on the solver-name print line and proceeds to load the model
   and call the function under test.
2. **Given** the repaired test, **When** it runs, **Then** the assertions it makes about
   `entropicFluxBalanceAnalysis` are unchanged (same behaviour asserted, only the index defect fixed).

---

### User Story 3 - GECKO dual-optimality residual is resolved or characterized, and its test is robust (Priority: P3)

A developer running `testEntropicFBAgecko` under mosek sees the warning `[mosek] Dual optimality
condition in solveCobraEP not satisfied, residual = 1.45, while problem optTol = 5e-05` on both
GECKO cases (the pdco backend is clean). It is unclear whether this is genuine numerical
ill-conditioning of the entropy-augmented problem (comparable to the pre-existing ~2 residual seen
on non-enzyme Recon3D) or a real defect in how the enzyme-column dual / KKT stationarity residual
is assembled. The developer needs a definite determination, and then either a fix or a documented,
tolerated characterization so the test is deterministic and the residual's meaning is recorded.

**Why this priority**: It is an investigation whose corrective scope is unknown until the residual
is traced; it does not crash and does not affect primal results. It is the most involved and least
predictable slice, so it is sequenced last.

**Independent Test**: Trace `res2 = grad + Aty + rcost` for the enzyme-augmented mosek problem,
compare against the non-enzyme baseline residual, record the determination, and confirm
`testEntropicFBAgecko` passes deterministically with the residual either driven below a documented
tolerance (if a fixable assembly defect) or documented and tolerated with primal feasibility + KKT
+ solver-status assertions.

**Acceptance Scenarios**:

1. **Given** the enzyme-augmented mosek EP, **When** the dual/KKT stationarity residual is analysed,
   **Then** a determination is recorded — genuine ill-conditioning vs. an enzyme-column
   assembly/reordering defect — with the evidence that distinguishes them.
2. **Given** the determination is "fixable assembly defect", **When** the fix is applied, **Then**
   the mosek dual residual on the GECKO cases falls to a documented tolerance and the warning no
   longer fires.
3. **Given** the determination is "genuine ill-conditioning", **When** the test is updated, **Then**
   `testEntropicFBAgecko` asserts primal constraint satisfaction, optimality/KKT conditions, and the
   exact solver-status strings, tolerates the documented dual residual, and passes deterministically
   under both backends without the warning being treated as failure.

---

### Edge Cases

- The internal LP diagnostic (`optimizeCbModel`) returns a status other than 0 or 1 (unbounded,
  error) on the infeasible-EP branch — `message` must still be defined.
- An enzyme-constrained model that is infeasible only because of the enzyme cap: the LP pre-check
  passes (it does not see `E`/`evar`/`D`) but the EP is infeasible, and the mosek infeasibility
  diagnostic must size its problem-name arrays from the actual enzyme-augmented dimension rather
  than the pre-enzyme dimension.
- A feasible enzyme-constrained model (the 010 feasible and binding cases) — must be entirely
  unchanged (regression guard).
- A model whose dual residual is genuinely large due to ill-conditioning — the test must tolerate it
  after the characterization decision rather than failing spuriously.
- mosek or the EP solver absent — the tests skip gracefully (per Principle III `prepareTest` /
  existence gating) rather than failing.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `entropicFluxBalanceAnalysis` MUST return `solution.stat == 0` with a populated
  `solution.messages` (no undefined-variable error) whenever the entropic problem is infeasible,
  for every value the internal LP feasibility diagnostic can return — including statuses other than
  0 or 1 (the branch that currently leaves `message` undefined MUST define it in all cases).
- **FR-002**: `entropicFluxBalanceAnalysis` MUST return a clean infeasible status (not crash) for an
  enzyme-constrained (`E`/`evar*`/`D`) model that is infeasible only because of the enzyme capacity
  constraint, i.e. where the LP pre-check reports feasible but the EP is infeasible.
- **FR-003**: The mosek infeasibility diagnostic reached from `solveCobraEP` MUST size its
  problem-name / constraint-name arrays from the actual problem dimension, so an enzyme-augmented
  problem (extra enzyme columns) does not trigger a dimension error (`err_argument_dimension`) in
  the diagnostic path.
- **FR-004**: The feasible/optimal path (`solution.stat == 1`) MUST be unchanged, including the
  010-verified GECKO feasible and enzyme-limited (binding) cases: the returned fluxes `v`, enzyme
  variable `e`, and objective MUST match the pre-change results within their existing test
  tolerances, and the default (no-enzyme) path MUST be behaviourally unchanged.
- **FR-005**: `testEntropicFluxBalanceAnalysis` MUST define its solver index so the test runs from a
  fresh workspace with no reliance on a stray `k`, actually invokes `entropicFluxBalanceAnalysis`,
  and preserves the behaviour it asserts about the function (only the index defect is corrected).
- **FR-006**: The GECKO mosek dual-optimality residual MUST be investigated and a determination
  recorded (genuine entropic-dual ill-conditioning vs. an enzyme-column dual/KKT-assembly defect).
  Per the Session 2026-07-16 clarification, the feature MUST **pursue a fix** that drives the mosek
  dual residual below `optTol` on the GECKO cases — including, where warranted, corrections to the
  enzyme cone-dual reconstruction / reduced-cost reordering (`Fty_K` and offsets) in `solveCobraEP`
  — so the warning no longer fires. It MAY fall back to characterizing the residual as expected
  numerical behaviour and making `testEntropicFBAgecko` robust to it (asserting primal constraint
  satisfaction, optimality/KKT conditions, and the exact solver status strings, and tolerating the
  documented residual) ONLY if a correct fix is shown to be infeasible, with that finding recorded.
  Any change to the dual reconstruction MUST preserve the primal solution and `.stat`/`.origStat`
  semantics (Principle II/IV) and MUST NOT regress the non-enzyme dual residual.
- **FR-007**: The feature MUST NOT change any public function signature, documented option/parameter
  name, COBRA model-field meaning, the `solveCobraEP`/`entropicFluxBalanceAnalysis` interface, or the
  `.stat`/`.origStat` status semantics (Principle II, IV).
- **FR-008**: Warnings MUST remain visible (no suppression, routing away, or swallowing); the exact
  solver status strings (`OPTIMAL`, `MSK_RES_OK`) and residual scale labels MUST be preserved in any
  diagnostic or test output (Principle IV, VII-B).
- **FR-009**: Edits MUST be confined to `src/base/solvers/entropicFBA/**` and the entropic-FBA tests
  under `test/verifiedTests/base/testEntropicFBA/**` and `test/verifiedTests/analysis/testEntropicFBAgecko/**`
  (and, only if a regression guard requires it, `test/verifiedTests/analysis/testEntropicFluxBalanceAnalysis/**`).
- **FR-010**: Each corrected behaviour MUST be covered by the narrowest automated test that runs
  under `test/testAll.m` and the CI harness, declaring its solver requirement via `prepareTest`
  (`needsEP` / mosek) so it skips gracefully when the EP solver is unavailable.

### Key Entities *(include if feature involves data)*

- **Enzyme-constrained EP problem**: the entropic problem augmented with enzyme structures
  (`E`/`evarlb`/`evarub`/`evarc`/`D`) and the `[S E; C D]` block; its feasibility depends on the
  enzyme capacity bound `evarub`.
- **Solution status**: canonical `solution.stat` (0 = infeasible, 1 = optimal), preserved
  `solution.origStat`, and `solution.messages` (the diagnostic text collection).
- **Dual/KKT stationarity residual**: `res2 = grad + Aty + rcost` in `solveCobraEP`, compared to a
  fixed `optTol` (currently `5e-5`); the quantity whose magnitude (1.45 on GECKO) is under
  investigation.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: An infeasible enzyme-constrained EP fixture returns `solution.stat == 0` with a
  non-empty `solution.messages` and raises no undefined-variable or `err_argument_dimension` error,
  on 100% of mosek runs.
- **SC-002**: `testEntropicFluxBalanceAnalysis` runs green from a fresh MATLAB workspace (standalone,
  no stray `k`) and executes `entropicFluxBalanceAnalysis(model, param)` — the previously-unreached
  code path is now exercised.
- **SC-003**: `testEntropicFBAgecko` passes deterministically under both mosek and pdco, with the
  GECKO dual residual either at or below a documented tolerance or documented-and-tolerated; no
  emitted warning causes the test to fail.
- **SC-004**: The 010 regression tests — `testEntropicFluxBalanceAnalysis` and the `testEntropicFBAgecko`
  feasible + binding assertions — still pass under mosek and pdco (no regression), with the default
  (no-enzyme) `fluxes` path objective/`v` unchanged within the existing 1e-6 tolerance.
- **SC-005**: `check_matlab_code` reports no NEW warnings or errors at the edited sites relative to
  the pre-change baseline; the helper/edited functions carry the openCOBRA header conventions where
  applicable.
- **SC-006**: No public function signature, documented parameter, or model-field meaning changes;
  `.stat`/`.origStat` semantics are preserved (verified by diff review against Principle II/IV).

## Assumptions

- mosek (with the exponential-cone EP capability) and the EP solver path are available in the
  development/CI environment used to verify this feature; tests gate on `prepareTest`
  (`needsEP` / mosek) and skip gracefully otherwise.
- A strictly-infeasible enzyme-constrained fixture can be built as a small toy model (a variant of
  the existing 010 `buildEnzymeToy` with `evarub` below the forced flux), keeping the test fast and
  CI-friendly.
- The pdco backend is already clean on the dual-optimality condition for the GECKO cases; the US3
  investigation and any fix are mosek-focused.
- "Resolve-or-characterize" (FR-006, US3) is deliberately open: the outcome is decided by the
  evidence gathered when tracing the residual, not pre-committed. Either outcome satisfies the
  requirement provided the test becomes deterministic and the determination is documented.
- The infeasible-case assertion may be added to `testEntropicFBAgecko` or to a dedicated new test;
  either placement satisfies FR-001/FR-002 (a plan/tasks decision).

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, FR-002, FR-003 (infeasible enzyme-constrained EP returns stat=0 with a message) | new infeasible assertion in `test/verifiedTests/analysis/testEntropicFBAgecko/testEntropicFBAgecko.m` (or a dedicated test) | `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m`, `src/base/solvers/entropicFBA/solveCobraEP.m` |
| US1 / FR-001 (non-0/1 LP diagnostic status defines `message`) | same infeasible assertion / diagnostic-path check | `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m` |
| US2 / FR-005 (legacy test runs standalone and exercises the function) | `test/verifiedTests/base/testEntropicFBA/testEntropicFluxBalanceAnalysis.m` | `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m` |
| US3 / FR-006 (dual residual resolved or characterized; test robust) | `test/verifiedTests/analysis/testEntropicFBAgecko/testEntropicFBAgecko.m` | `src/base/solvers/entropicFBA/solveCobraEP.m` |
| FR-004 / SC-004 (feasible path + no-enzyme path unchanged) | `test/verifiedTests/analysis/testEntropicFluxBalanceAnalysis/testEntropicFluxBalanceAnalysis.m`, `testEntropicFBAgecko` feasible/binding cases | `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m` |
