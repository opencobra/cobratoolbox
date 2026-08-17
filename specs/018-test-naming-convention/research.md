# Phase 0 Research: Single-Test-Per-Function Naming Convention

No `[NEEDS CLARIFICATION]` markers remain in `spec.md`. This records the decisions
made from direct repository inspection.

## R1 — Full inventory of `testCharacterize*` files

- **Decision**: exactly four exist, confirmed by
  `grep -rl "testCharacterize" test --include="*.m"` and
  `find test -iname "testCharacterize*.m"` (both agree):
  `testCharacterizeSolveCobraLP.m`, `testCharacterizeOptimizeCbModel/testCharacterizeOptimizeCbModel.m`,
  `testCharacterizeEntropicFBA/testCharacterizeEntropicFBA.m`,
  `testCharacterizeBuildOptProblemFromModel.m`. No fifth file exists, so the
  spec's "handled the same way if implementation discovers another" assumption is
  moot for this run.
- **Rationale**: an exhaustive search, not a sample, is required before claiming
  SC-001 ("exactly zero `testCharacterize*.m` remain") — undercounting would leave
  a file the feature was supposed to eliminate.

## R2 — Collision check: which of the four have an existing conventional counterpart?

- **Decision**: three collide, one does not.
  - `testCharacterizeSolveCobraLP.m` → `test/verifiedTests/base/testSolvers/testSolveCobraLP.m` exists (2017, CI integration).
  - `testCharacterizeOptimizeCbModel.m` → `test/verifiedTests/analysis/testOptimizeCbModel/testOptimizeCbModel.m` exists.
  - `testCharacterizeEntropicFBA.m` → its target name is `testEntropicFluxBalanceAnalysis.m`
    (test+PascalCase of the actual function name, `entropicFluxBalanceAnalysis` —
    NOT `testEntropicFBA.m`, which would be the wrong target since the function's
    real name is longer than "EntropicFBA"). `test/verifiedTests/base/testEntropicFBA/testEntropicFluxBalanceAnalysis.m`
    already exists.
  - `testCharacterizeBuildOptProblemFromModel.m` → no `testBuildOptProblemFromModel.m`
    exists anywhere in `test/verifiedTests/` (confirmed by `find`); `buildOptProblemFromModel`
    had zero prior conventional coverage, matching this session's own
    017-buildgurobifrommodel-tests precedent for `buildGurobiProblemFromModel`.
- **Rationale**: this determines merge vs. pure rename per file — the spec's FR-003
  through FR-006 encode exactly this three-merge-one-rename split.

## R3 — Merge mechanics: how to combine two script-level MATLAB test files without variable collisions

- **Decision**: for each colliding pair, append the `Characterize` file's full
  assertion body (everything between its own `currentDir`/`fileDir` boilerplate)
  into the destination file, inserted **immediately before the destination's own
  final `cd(currentDir)` line**. Any local helper function the `Characterize` file
  defined (MATLAB requires local functions at the true end of a script) is moved to
  after the destination's final `cd(currentDir)`.
- **Rationale**: MATLAB test scripts here are not function-scoped — all variables
  live in one script namespace, so appending code risks a later statement reading a
  variable the appended block redefined. Reading all three destination files in
  full (`testSolveCobraLP.m`, `testOptimizeCbModel.m`,
  `testEntropicFluxBalanceAnalysis.m`) confirms each currently ends with nothing
  but `cd(currentDir)` after its last assertion — there is no "downstream" code for
  an appended block to interfere with. Placing the appended block immediately
  before that final line makes every variable/function it introduces provably dead
  for the rest of the file, which satisfies the spec's edge case ("must not let one
  silently shadow or overwrite the other's fixture") by construction rather than by
  manual variable-renaming, which would be more invasive and error-prone for files
  this large (testOptimizeCbModel.m alone is 209 lines with `model.g0`/`model.g1`
  mutated repeatedly).
- **Alternatives considered**: renaming every appended-block variable to a
  `char`-prefixed form (e.g. `charModel`, `charSolverPkgs`) — rejected as
  unnecessary extra edit surface once the append-before-final-`cd` ordering already
  makes collision impossible; also considered interleaving the characterization
  assertions into the existing file's per-solver loop — rejected because the two
  sides use different models/solver-requirement scopes (toy model vs. genome-scale
  `iAF1260`/`ecoli_core_model`), so interleaving would conflate two independent
  fixtures rather than cleanly append two independent, already-passing blocks.

## R4 — `prepareTest` requirement union, not intersection

- **Decision**: each merged file keeps BOTH sides' own `prepareTest` call, verbatim,
  at their original position in their own block (the destination's existing
  `prepareTest` at the top for its own assertions, the appended block's own
  `prepareTest('needsLP', true)`/`prepareTest('requiredSolvers', {'mosek'}, ...)`
  immediately preceding its own assertions).
- **Rationale**: FR-007 requires the union of requirements, not a single unified
  call — since the two blocks have historically had different (though overlapping)
  solver needs (e.g. `testSolveCobraLP.m`'s broad `useSolversIfAvailable` list vs.
  `testCharacterizeSolveCobraLP.m`'s plain `needsLP`), keeping each side's own call
  exactly preserves each side's existing skip-clean behaviour without having to
  prove a merged call is equivalent to both originals.

## R5 — Constitution placement for the new rule

- **Decision**: a new sub-clause `#### III-Naming: One Test File Per Function`
  immediately after the existing `#### III-Characterization: Legacy Back-Fill
  Mode` sub-clause (both are sub-clauses of Principle III, "Testing,
  Reproducibility, And Continuous Integration").
- **Rationale**: the rule is a testing-convention constraint most naturally paired
  with the sibling characterization-mode clause it directly modifies (III-
  Characterization currently says nothing about naming; this clause supplies that
  missing piece and cross-references it). Principle VII-G ("openCOBRA Contribution
  Conventions") was considered but rejected as the primary location because it is
  explicitly function/identifier-naming (camelCase, `is`/`Is` prefixes), not
  test-file naming, and Principle X (single-sourcing) means the rule should live in
  exactly one place, not be duplicated across both principles.
- **Version bump**: MINOR (1.4.0 → 1.5.0) per the Governance section's own rule
  ("new principles, new governance sections, or materially expanded compliance
  requirements") — this is a new, materially-expanded compliance requirement
  within an existing principle, the same category the constitution's own history
  uses for the III-Characterization clause's own addition (1.1.0 → 1.2.0, per the
  Sync Impact Report already in the file).

## R6 — Live-doc reference scope (correcting the original request)

- **Decision**: `grep -rl "testCharacterizeSolveCobraLP\|testCharacterizeOptimizeCbModel\|testCharacterizeBuildOptProblemFromModel\|testCharacterizeEntropicFBA" specs/`
  returns hits only in `specs/009-fba-characterization-statusmap/`,
  `specs/010-gecko-entropic-fba/`, `specs/011-entropicfba-dual-fixes/`, and
  `specs/017-buildgurobifrommodel-tests/` — not `004-reacting-moieties-test` or
  `006-xomicstomodel-test`, which the feature description (based on this session's
  earlier, unverified guess) had named.
- **Rationale**: features 004/006 characterize unrelated functions (moiety
  analysis, `XomicsToModel`) and never reference any of the four renamed/merged
  test files. Acting on the grep result rather than the original guess avoids
  editing files that have no actual stale reference (which would be a no-op edit
  at best, or a mistaken edit to an unrelated feature's docs at worst).
