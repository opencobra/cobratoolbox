# Phase 0 Research: Conserved-Moiety Cross-Function Equivalence Test

No open NEEDS CLARIFICATION markers remain in plan.md's Technical Context — the
comparison this feature automates was already run manually (see "Investigation"
below), so Phase 0 mainly records that investigation's findings and the resulting
decisions.

## Decision: What "equivalent" means for this test

- **Investigation**: Ran `identifyConservedReactingMoieties(subModel, BG, dATM,
  options)` with `options.conservedMoietiesOnly = true` and, separately,
  `identifyConservedMoieties(subModel, dATM, options)` (both with
  `options.sanityChecks = 0`), on the same `subModel`/`dATM` fixture already built by
  `testConservedReactingMoieties.m` (the 4-metabolite/3-reaction Recon3D subnetwork
  `{r0317, ACONTm, r0426}`). Compared `arm.L`, `arm.M2M`, `arm.M2R`, and
  `moietyFormulae` directly.
- **Finding**: All four fields are exactly `isequal` — not merely isomorphic up to
  relabeling/reordering, but identical in dimensions, row/column order, and content.
  `moietyFormulae` was `{'H2O'; 'C6H3O6'}` for both calls; `norm(L*N) = 0` for both.
- **Decision**: The test asserts exact `isequal` on all four fields, matching what was
  observed, rather than a weaker permutation-invariant or set-based comparison.
- **Rationale**: Exact `isequal` is the strongest, simplest, and most sensitive
  assertion available, and it is what the current code actually produces. A weaker
  comparison (e.g., sorting `moietyFormulae` before comparing, or searching for a row
  permutation of `L`) would hide a real class of future regressions — e.g., a change
  that silently drops or duplicates a moiety instance while keeping the multiset of
  formulae superficially similar.
- **Alternatives considered**: A permutation-invariant comparison of `arm.L`'s rows
  and a sorted-multiset comparison of `moietyFormulae` (rejected as the primary
  assertion — weaker than what the current implementations actually guarantee; kept
  only as a documented fallback strategy in spec.md's Assumptions, to be adopted only
  if a future *legitimate* internal-ordering change requires it).

## Decision: `options.sanityChecks` value for both compared calls

- **Investigation**: Re-ran the same comparison with `options.sanityChecks = 1` on
  the conserved-only `identifyConservedReactingMoieties` call. It crashed:
  `Error using identifyIsomorphicClasses ... Inconsistent mapping of atoms to
  connected components`, raised from a bond-subgraph classification step inside
  `identifyConservedReactingMoieties.m` (a sanity-check code path unrelated to the
  conserved-moiety computation the option is meant to isolate).
- **Decision**: Both compared calls in the new assertions use
  `options.sanityChecks = 0`.
- **Rationale**: This matches what the file's existing feature-026 conserved-only
  call already uses (`optionsConservedOnly.sanityChecks = 0`), so the new assertions
  introduce no new failure mode and stay consistent with the surrounding test. Fixing
  the `sanityChecks = 1` crash is a separate, pre-existing defect outside this
  feature's scope (spec FR-009, Edge Cases).
- **Alternatives considered**: Fixing the underlying `sanityChecks = 1` crash as part
  of this feature (rejected — out of scope per spec; it lives in the bond-graph
  classification path, not the conserved-moiety path this feature is about, and
  fixing it is a separate, spec-driven change per Constitution Principle VI).

## Decision: Test placement and fixture reuse

- **Investigation**: Confirmed `identifyConservedMoieties.m`
  (`src/analysis/topology/conservedMoieties/`) has its own existing test coverage
  under a differently-named file
  (`test/verifiedTests/analysis/testTopology/testMoieties.m`), separate from
  `identifyConservedReactingMoieties.m`'s dedicated test file
  (`test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`,
  which already contains the `subModel`, `dATM`, `armConservedOnly`, and
  `moietyFormulaeConservedOnly` variables this feature needs, from feature 026).
- **Decision**: Extend `testConservedReactingMoieties.m` in place, immediately after
  the existing feature-026 conserved-only block, rather than adding assertions to
  `testMoieties.m` or creating a new file.
- **Rationale**: Constitution Principle III-Naming designates
  `testConservedReactingMoieties.m` as the one test file for
  `identifyConservedReactingMoieties.m`; the property under test here — "this
  function's conserved-only mode is equivalent to the sibling implementation" — is
  specifically about that function's behavior, and the fixture/outputs it depends on
  already live in that file. Reusing them avoids duplicating the fixture-construction
  code (`buildAtomAndBondTransitionMultigraph` call, `extractSubNetwork`, etc.) in a
  second file, which the narrowest-test principle (Constitution III) disfavors.
- **Alternatives considered**: Adding the comparison to `testMoieties.m` instead
  (rejected — that file does not build the `BG`/`dATM` fixture this comparison
  needs in the same form, and `identifyConservedMoieties.m` is the read-only,
  comparison-only side of this equivalence, not the function whose contract is being
  extended); creating a new dedicated `testConservedMoietyEquivalence.m`-style file
  (rejected — Principle III-Naming ties one file to one source function's contract,
  and this assertion is scoped to `identifyConservedReactingMoieties.m`'s conserved-
  only mode, not a new function).
