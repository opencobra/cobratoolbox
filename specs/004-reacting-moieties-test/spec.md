# Feature Specification: Repurpose the conserved-and-reacting-moieties tutorial as a test

**Feature Branch**: `004-reacting-moieties-test`

**Created**: 2026-07-13

**Status**: Draft

**Input**: User description: "go ahead and create test(s) from conserved and reacting moieties"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A moiety-analysis test contributes coverage (Priority: P1)

A maintainer runs the suite and a new test derived from the conserved-and-reacting
moieties tutorial runs, exercising seven previously-untested moiety functions and
asserting the mathematical invariants the tutorial demonstrates — so a whole
analysis workflow that only existed as human documentation now also guards the code.

**Why this priority**: This is the entire feature — turn a verified-working tutorial
into automated coverage for code that currently has none.

**Independent Test**: Add the test under `verifiedTests/`, run it via the harness,
and confirm it passes (or skips cleanly if a requirement is absent), exercises the
seven target functions, and asserts the `L*N = 0` conservation invariant.

**Acceptance Scenarios**:

1. **Given** the local solver/toolbox set the tutorial ran under, **When** the test
   runs, **Then** it passes, having built the atom/bond transition multigraph,
   identified conserved and reacting moieties, and asserted `norm(full(arm.L) * full(subModel.S))`
   is within tolerance of zero.
2. **Given** the test runs, **When** its coverage is examined, **Then** it exercises
   `buildAtomAndBondTransitionMultigraph`, `identifyConservedReactingMoieties`,
   `identifyConservedReactingSubgraphs`, `buildReactingMoietyTables`,
   `displayReactingMoieties`, `createMoietyGraph`, and `getMetMoietySubgraphs`.
3. **Given** the test runs, **When** figures are produced by the moiety-graph plotting
   calls, **Then** no figure window is displayed (figures are generated invisibly and
   the display state is restored afterwards).
4. **Given** a machine lacking a dependency the workflow truly needs, **When** the
   test runs, **Then** it skips cleanly (COBRA:RequirementsNotMet) rather than erroring.

### Edge Cases

- **Missing model/data**: if `Recon3D_301.mat` or the atom-mapped `rxnFiles` are
  absent, the test skips cleanly rather than erroring.
- **Non-deterministic ordering**: any assertion on sets (e.g. selected reacting
  reactions, table row counts) must be order-independent or compared against stored
  reference values captured from a real run — never a loosened/removed assertion.
- **Fast vs full mode (002)**: the test behaves identically in both modes (it is not
  a multi-solver test).
- **Figure state leakage**: the invisible-figure setting must be restored even if the
  test errors mid-way (so it does not affect other tests).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A new test under `test/verifiedTests/` MUST reproduce the tutorial's
  workflow: load `Recon3D_301.mat`, extract the `{r0317, ACONTm, r0426}` subnetwork,
  build the atom/bond transition multigraph, and identify conserved and reacting
  moieties — exercising the seven currently-untested functions listed in User Story 1.
- **FR-002**: The test MUST assert the conserved-moiety invariant
  `norm(full(arm.L) * full(subModel.S))` is within a stated tolerance of zero, plus at
  least the non-emptiness/well-formedness of the returned structures (`dATM`, `BG`,
  `arm.L`, `reacting.selectedReactionNames`, `moietyGraph`).
- **FR-003**: Any exact expected values (rank/nullity, selected reacting reactions,
  formed/broken bond-table row counts) MUST be captured from a real run and asserted
  against stored reference data or literal expected values — assertions MUST be genuine,
  not reduced to a bare no-error smoke run.
- **FR-004**: The test MUST generate figures without displaying them (set invisible at
  the start, restore at the end, robust to mid-test error) so plotting code is covered
  without opening windows.
- **FR-005**: The test MUST declare its true requirements via `prepareTest` so it skips
  cleanly where a needed dependency (model, data, or solver) is absent, and MUST NOT
  error in that case.
- **FR-006**: The feature MUST NOT modify any `src/` function, scientific result, or
  public interface; it only ADDS a test (and its reference data/documentation).
- **FR-007**: The test MUST behave correctly under both fast (default) and full test
  modes (feature 002) and, in the CI environment, run as part of the suite.
- **FR-008**: The atom-mapped `rxnFiles` the test needs MUST be resolved reliably —
  either referenced from the tutorial's shipped `data/rxnFiles` or a minimal copy placed
  beside the test — so the test does not depend on an un-initialised submodule path.

### Key Entities *(include if feature involves data)*

- **Sub-network model**: the 3-reaction subnetwork of Recon3D used as the deterministic
  fixture (`extractSubNetwork`).
- **Atom/bond transition multigraph** (`dATM`, `BG`): built from the atom-mapped rxnFiles;
  the substrate for moiety identification.
- **Conserved/reacting moiety result** (`arm`, `reacting`): the outputs asserted on,
  chiefly the conserved-moiety matrix `L` satisfying `L*N = 0`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After the feature, the suite contains one additional passing test (or a
  clean skip where a dependency is absent) that did not exist before.
- **SC-002**: The seven named functions are exercised by the test (verifiable by the
  test invoking them and by coverage tooling in CI).
- **SC-003**: The test asserts `L*N = 0` within tolerance and at least one additional
  stable structural fact; no assertion is a placeholder or trivially true.
- **SC-004**: Running the test opens no figure windows.
- **SC-005**: No previously-passing test fails, and no `src/` file changes.

## Assumptions

- The tutorial's atom-mapped `rxnFiles` and `Recon3D_301.mat` are the fixtures; the
  subnetwork keeps the test fast (the tutorial ran in ~17s; the test should be similar
  or faster).
- The workflow ran locally with the default solver set and no commercial dependencies;
  the exact `prepareTest` requirement is determined during planning (likely an LP solver
  for the minimum-set-cover step, or none).
- Reference values are captured from a real run during implementation and stored, so the
  assertions are exact and reproducible rather than loose.
