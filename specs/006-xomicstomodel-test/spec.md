# Feature Specification: Test XomicsToModel by repurposing its tutorial

**Feature Branch**: `006-xomicstomodel-test`

**Created**: 2026-07-14

**Input**: User description: "XomicsToModel needs to be tested" (repurpose tutorials/dataIntegration/XomicsToModel/tutorial_XomicsToModel.m)

## Clarifications

### Session 2026-07-14

- Q: How to handle the heavy runtime (XomicsToModel did not finish within ~10 min)?
  → A: **Full-mode-only** — the test(s) run only in full mode / CI and are skipped in
  fast/default mode (via `getCobraTestMode`), so routine local runs are not slowed. The
  test can take as long as it needs; implementation must still confirm each configuration
  completes in a bounded (if long) time.
- Q: Which extractor? → A: **Both** — two tests, one using `fastCore` and one using
  `thermoKernel`, so the suite covers both `XomicsToModel` AND `thermoKernel`.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - XomicsToModel gains a real test (Priority: P1)

A maintainer runs the suite and a new test drives the `XomicsToModel` multi-omics
model-extraction pipeline end-to-end on the shipped example data, asserting the
extracted context-specific model is valid and feasible — so a major, currently
untested COBRA function is now guarded.

**Why this priority**: This is the feature — `XomicsToModel` is a major function with
no test; the user asked for it to be tested.

**Independent Test**: Run the test on the shipped generic model + omics data and
confirm it produces a non-empty, feasible extracted model and passes its assertions
(or skips cleanly if a required solver is absent).

**Acceptance Scenarios**:

1. **Given** the shipped generic model (`Recon3DModel_301_xomics_input.mat`) and the
   tutorial's shipped omics data, **When** `XomicsToModel(model, specificData, param)`
   runs, **Then** it returns a context-specific model that is non-empty, is a valid
   feasible COBRA model (`optimizeCbModel` status == 1), and contains the expected core
   reactions from the bibliomic data.
2. **Given** the extracted model, **When** its size is checked, **Then** the
   reaction/metabolite/gene counts match captured reference values (within a tolerance
   if the extractor is nondeterministic).
3. **Given** a machine without the required solver(s), **When** the test runs, **Then**
   it skips cleanly (COBRA:RequirementsNotMet), not error.

### Edge Cases

- **Runtime**: `XomicsToModel` on the Recon3D-scale model is a heavyweight run — in
  feasibility it did **not complete within ~10 minutes** in either the `thermoKernel`
  or `fastCore` configuration (both entered a long constraint-relaxation loop). The
  test must be designed so it does not make the routine suite impractically slow.
- **Submodule independence**: the generic model ships in the `papers` submodule and the
  omics data in the `tutorials` submodule; the test must resolve its fixtures reliably
  even if a submodule is not initialised (copy a minimal fixture into the test folder or
  use CBTDIR-anchored paths, and skip cleanly if truly absent).
- **Nondeterminism**: if the extractor picks among equivalent reactions, count/identity
  assertions must be order-independent or use a tolerance, never a loosened invariant.
- **Figures**: if the workflow plots, figures must be generated but not displayed.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A new test under `test/verifiedTests/` MUST drive `XomicsToModel` on the
  shipped generic model and the tutorial's shipped omics data (bibliomic, exometabolomic,
  transcriptomic), reproducing the tutorial's data-preparation and extraction call.
- **FR-002**: The test MUST assert genuine properties of the extracted model: non-empty;
  valid feasible COBRA model (`optimizeCbModel` status == 1); contains expected core
  reactions; and size (reactions/metabolites/genes) matching captured reference values
  (exact or within a stated tolerance). It MUST NOT be a bare no-error smoke run.
- **FR-003**: The test MUST declare its solver requirements via `prepareTest`
  (an LP and MILP solver, plus whatever the chosen extractor needs) so it skips cleanly
  where a required solver is absent, rather than erroring.
- **FR-004**: The test MUST be self-contained with respect to submodules — its fixtures
  (generic model + omics data) MUST resolve without an initialised submodule (minimal
  copy in the test folder or a robust CBTDIR-anchored path with a clean skip if absent).
- **FR-005**: The feature MUST NOT modify any `src` function (including `XomicsToModel`,
  `thermoKernel`, `preprocessingOmicsModel`), scientific result, or public interface.
- **FR-006**: The test(s) MUST be **full-mode-only** — skipped cleanly in fast/default
  mode (via `getCobraTestMode`) so the routine suite is not slowed, and run in full mode /
  CI. Implementation MUST confirm each configuration completes in a bounded (if long) time
  and capture its runtime; a configuration that does not complete within an agreed cap is
  deferred/documented rather than committed as a hanging test.
- **FR-007**: The feature MUST provide **two** tests: one driving `XomicsToModel` with
  `param.tissueSpecificSolver='fastCore'` and one with `'thermoKernel'`, so both
  `XomicsToModel` and `thermoKernel` are covered. Each is full-mode-only per FR-006.
- **FR-008**: If figures are produced, they MUST be generated but not displayed
  (invisible + restored), and the test MUST behave correctly in whichever execution mode(s)
  it is enabled for (feature 002).

### Key Entities *(include if feature involves data)*

- **Generic model**: `Recon3DModel_301_xomics_input.mat` (ships in papers/2023_iDopaNeuro), the
  XomicsToModel input; loaded variable `model` (5835×10600).
- **specificData**: bibliomic/exometabolomic/transcriptomic tables (ship with the tutorial),
  the context-specific inputs.
- **Extracted model**: the `XomicsToModel` output context-specific model, the assertion target.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After the feature, the suite contains a test that exercises `XomicsToModel`
  end-to-end (verifiable by coverage tooling in CI) — a function with zero coverage before.
- **SC-002**: The test asserts the extracted model is feasible (`optimizeCbModel` status==1)
  and matches captured reference size/core-reaction facts; no placeholder assertions.
- **SC-003**: The test does not make the routine (fast/default) suite meaningfully slower
  than before (per the FR-006 resolution).
- **SC-004**: No `src` file changes; no previously-passing test regresses.
- **SC-005**: The test skips cleanly where a required solver is unavailable.

## Assumptions

- The shipped `Recon3DModel_301_xomics_input.mat` and the tutorial's omics data are the
  fixtures; XomicsToModel requires a Recon3D-scale model matching the omics gene/reaction IDs
  (ecoli_core cannot substitute).
- gurobi (LP+MILP) is available and is what the extractor uses locally.
- Reference values are captured from a real (possibly long) run during implementation.
- The runtime and extractor decisions (FR-006/FR-007) are resolved in clarify before planning.
