# Feature Specification: Conserved-Moiety Cross-Function Equivalence Test

**Feature Branch**: `027-conserved-moiety-equivalence-test`

**Created**: 2026-09-15

**Status**: Draft

**Input**: User description: "Add a regression test that asserts identifyConservedReactingMoieties.m (called with options.conservedMoietiesOnly = true) produces conserved-moiety outputs (arm.L, arm.M2M, arm.M2R, moietyFormulae) that are equivalent to those produced by the sibling function identifyConservedMoieties.m, when both are run on the same atom-transition-multigraph fixture. This guards against future divergence between the two independent implementations of the conserved-moiety decomposition algorithm (identifyConservedReactingMoieties.m uses the newer prefiltered classifySubgraphIsomorphism helper internally, while identifyConservedMoieties.m still uses the original nested-loop isisomorphic approach), which was manually verified equivalent (isequal, bit-for-bit) on the existing 4-metabolite x 3-reaction Recon3D subnetwork fixture ({r0317, ACONTm, r0426}) already used by test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m, but has no automated test coverage today."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Automated cross-implementation equivalence guard (Priority: P1)

A maintainer changes either `identifyConservedReactingMoieties.m`'s conserved-moiety
code path or `identifyConservedMoieties.m` (for example, refactoring the isomorphism
classification internals of either function, as already happened once when
`identifyConservedReactingMoieties.m` was migrated to the prefiltered
`classifySubgraphIsomorphism` helper while `identifyConservedMoieties.m` was not).
Today nothing in the test suite would notice if that change caused the two
independent implementations of the same conserved-moiety decomposition algorithm to
diverge — the only evidence that they currently agree is a one-off manual comparison
run outside of CI. This user story adds that comparison as a standing, CI-executed
regression assertion.

**Why this priority**: This is the entire scope of the feature. Without it, a future
change to either function's internals can silently break the documented equivalence
between `identifyConservedReactingMoieties(..., options.conservedMoietiesOnly=true)`
and `identifyConservedMoieties(...)`, and nobody would find out until a downstream
user noticed a discrepancy.

**Independent Test**: Run the extended test file
(`test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`)
via `test/testAll.m` or directly in MATLAB; it passes today (bit-for-bit equivalence
already holds) and must fail if a future change breaks that equivalence.

**Acceptance Scenarios**:

1. **Given** the existing self-contained fixture already built earlier in
   `testConservedReactingMoieties.m` (the `subModel`/`dATM` pair derived from the
   `{r0317, ACONTm, r0426}` Recon3D subnetwork) and the `armConservedOnly`/
   `moietyFormulaeConservedOnly` outputs already computed there via
   `identifyConservedReactingMoieties(subModel, BG, dATM, options)` with
   `options.conservedMoietiesOnly = true`, **When** `identifyConservedMoieties(subModel,
   dATM, options)` is additionally called on the same `subModel`/`dATM`, producing
   `armSibling`/`moietyFormulaeSibling`, **Then** `armSibling.L`, `armSibling.M2M`,
   `armSibling.M2R`, and `moietyFormulaeSibling` are each `isequal` to
   `armConservedOnly.L`, `armConservedOnly.M2M`, `armConservedOnly.M2R`, and
   `moietyFormulaeConservedOnly` respectively.
2. **Given** the same two calls, **When** a future change to either function's
   internal isomorphism-classification algorithm alters the conserved-moiety
   decomposition it returns, **Then** the new assertions fail (rather than silently
   passing), giving CI a concrete signal of the divergence.
3. **Given** a CI runner with no MILP solver licensed, **When** this test file runs,
   **Then** the new assertions still execute and pass (neither function call under
   comparison requires a MILP solver), consistent with the existing conserved-only
   assertions from feature 026.

---

### Edge Cases

- What happens if `identifyConservedMoieties.m` is called with `options.sanityChecks =
  1`? A pre-existing, out-of-scope defect (found while manually verifying this
  equivalence) makes the *conserved-only* call to `identifyConservedReactingMoieties.m`
  crash with `sanityChecks = 1` (an unrelated bond-subgraph isomorphism check inside
  the reacting-moiety machinery). This feature MUST NOT attempt to fix that defect; it
  keeps `options.sanityChecks = 0` for both calls under comparison, matching what the
  existing conserved-only assertions from feature 026 already use.
- What happens if the two implementations produce isomorphic-but-differently-ordered
  results (same decomposition, different row/column labeling of isomorphism classes or
  moiety instances)? Manual verification on the reference fixture found the two
  functions' outputs already `isequal` (identical ordering, not merely isomorphic up
  to relabeling), so this is the acceptance bar the test encodes. See Assumptions for
  the consequence if a future legitimate change intentionally reorders results without
  changing their meaning.
- What happens if a fixture-building step upstream (e.g. `buildAtomAndBondTransitionMultigraph`)
  changes? The new assertions depend on the same `subModel`/`dATM` already used by the
  existing test; no new fixture is introduced by this feature.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The test suite MUST call `identifyConservedMoieties(subModel, dATM,
  options)` on exactly the same `subModel`/`dATM` fixture already constructed in
  `testConservedReactingMoieties.m`, with `options.sanityChecks = 0` (matching the
  existing conserved-only call in that file).
- **FR-002**: The test suite MUST assert `isequal(armSibling.L, armConservedOnly.L)`
  between the `identifyConservedMoieties` output (`armSibling`) and the existing
  conserved-only `identifyConservedReactingMoieties` output from feature 026
  (`armConservedOnly`).
- **FR-003**: The test suite MUST assert `isequal(armSibling.M2M, armConservedOnly.M2M)`
  between the two outputs.
- **FR-004**: The test suite MUST assert `isequal(armSibling.M2R, armConservedOnly.M2R)`
  between the two outputs.
- **FR-005**: The test suite MUST assert `isequal(moietyFormulaeSibling,
  moietyFormulaeConservedOnly)` between the two outputs.
- **FR-006**: The new assertions MUST reuse the fixture, options, and outputs already
  established earlier in `testConservedReactingMoieties.m` (in particular the
  `subModel`, `dATM`, `armConservedOnly`, and `moietyFormulaeConservedOnly` variables
  from feature 026) rather than constructing a second, duplicate fixture.
- **FR-007**: The new assertions MUST NOT be gated behind an additional
  `prepareTest('needsMILP', true)` requirement — neither function call under
  comparison invokes a MILP solver — and MUST be placed so they still execute on a
  runner with no MILP solver licensed, consistent with the existing placement of the
  feature-026 conserved-only assertions relative to the file's MILP gate.
- **FR-008**: This feature MUST NOT modify `identifyConservedReactingMoieties.m` or
  `identifyConservedMoieties.m`; it is test-only and must not change the behavior of
  either function under test.
- **FR-009**: This feature MUST NOT attempt to fix the pre-existing, out-of-scope
  defect (conserved-only mode combined with `options.sanityChecks = 1` crashing in
  `identifyConservedReactingMoieties.m`'s bond-subgraph classification) found during
  manual verification; the new assertions MUST avoid triggering it by using
  `options.sanityChecks = 0`.

### Key Entities

- **`armConservedOnly` / `moietyFormulaeConservedOnly`**: the existing outputs
  (feature 026) of `identifyConservedReactingMoieties(subModel, BG, dATM, options)`
  with `options.conservedMoietiesOnly = true`, already computed in
  `testConservedReactingMoieties.m`.
- **`armSibling` / `moietyFormulaeSibling` (new, from `identifyConservedMoieties`)**:
  the outputs of `identifyConservedMoieties(subModel, dATM, options)` on the same
  fixture, newly introduced by this feature purely for comparison. These use
  deliberately distinct local variable names (not the bare `arm`/`moietyFormulae`
  used in `identifyConservedMoieties.m`'s own documentation) so as not to collide
  with the file's pre-existing full-mode `arm`/`moietyFormulae` variables from
  `identifyConservedReactingMoieties`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A code change to either function's internal conserved-moiety algorithm
  that alters the returned decomposition (`arm.L`, `arm.M2M`, `arm.M2R`, or
  `moietyFormulae`) relative to the other function causes this test to fail on the
  very next run of `test/testAll.m` — no separate manual comparison is required to
  catch it.
- **SC-002**: The test passes today, reproducing the manually-verified result
  (`isequal` true on all four compared fields) without modification to either
  function under test.
- **SC-003**: The new assertions execute and pass on a CI runner with no MILP solver
  licensed (no new `prepareTest('needsMILP', true)` requirement is introduced).
- **SC-004**: No new fixture, model file, or `rxnFiles` asset is added to the
  repository — confirmed by `git diff --stat` showing only the one test file changed.

## Assumptions

- The comparison is fixture-specific: this test proves equivalence for the one
  existing self-contained fixture (the 4-metabolite x 3-reaction Recon3D subnetwork),
  not exhaustively across all possible models — consistent with the narrowest-test
  principle (Constitution III) and the scope of the existing test it extends.
- Exact `isequal` (not a permutation- or isomorphism-invariant comparison) is the
  correct assertion strength, based on the manual verification showing bit-for-bit
  identical outputs today. If a future legitimate refactor of either function
  intentionally changes internal ordering (e.g., isomorphism-class or moiety-instance
  numbering) without changing the decomposition's meaning, these assertions would
  need to be loosened to a permutation-invariant comparison; that revision is
  out of scope here because current behavior is exact and no such reordering is
  proposed by this feature.
- `options.sanityChecks` is fixed at `0` for both calls under comparison to avoid the
  known, unrelated, pre-existing crash in `identifyConservedReactingMoieties.m`'s
  bond-subgraph classification when conserved-only mode is combined with
  `sanityChecks = 1`; fixing that defect is a separate, out-of-scope concern.
- The new assertions belong in
  `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
  (the file Constitution Principle III-Naming already designates as the sole test file
  for `identifyConservedReactingMoieties.m`), rather than in `identifyConservedMoieties.m`'s
  own test coverage (`test/verifiedTests/analysis/testTopology/testMoieties.m`),
  because the property under test — "conserved-only mode of
  `identifyConservedReactingMoieties.m` is equivalent to the sibling implementation" —
  is specifically about this function's conserved-only mode, and the fixture and
  conserved-only outputs it depends on already live in that file (feature 026). This
  reuses the file's existing MILP-free placement rather than duplicating the fixture in
  a second file.
- `identifyConservedMoieties.m` is treated as read-only by this feature, exactly as
  `identifyConservedReactingMoieties.m`'s own plan (feature 026) already stipulated;
  this feature only ever calls it, never modifies it.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001..FR-007, FR-009 / SC-001..SC-004 | `testConservedReactingMoieties` under `test/verifiedTests/analysis/testReactingMoieties/` | `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m` (compared against `src/analysis/topology/conservedMoieties/identifyConservedMoieties.m`, called read-only) |
