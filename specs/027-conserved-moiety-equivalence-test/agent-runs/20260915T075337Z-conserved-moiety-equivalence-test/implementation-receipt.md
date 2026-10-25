# Implementation Receipt: Conserved-Moiety Cross-Function Equivalence Test

## Prompt

User asked to confirm regression tests still pass after implementing spec 026
(`identifyConservedReactingMoieties`), then asked whether the conserved-only output of
that function is equivalent to the sibling `identifyConservedMoieties.m`, and asked for
proof. After a manual, ad hoc MATLAB comparison confirmed bit-for-bit `isequal`
equivalence on the existing fixture, the user asked to add this as a standing automated
test ("This is vital to ensure backwards compatibility"). Per the constitution's
Principle VI gate, this was routed through the full Spec Kit workflow
(`/speckit-specify` → `/speckit-plan` → `/speckit-tasks` → `/speckit-analyze` →
apply remediation edits → `/speckit-implement`) rather than edited directly.

## Final response

Implementation complete. Added a cross-function equivalence guard to
`test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`: a
new call to `identifyConservedMoieties(subModel, dATM, optionsSibling)` with
`sanityChecks=0`, plus four `isequal` assertions (`arm.L`, `arm.M2M`, `arm.M2R`,
`moietyFormulae`) against the existing feature-026 conserved-only output. Ran the
extended file end-to-end in MATLAB R2024b — all assertions pass, including every
pre-existing one. Confirmed via `git diff --stat` that only this one test file changed;
neither `identifyConservedReactingMoieties.m` nor `identifyConservedMoieties.m` was
touched. All 14 tasks in tasks.md are now marked `[X]`. Implementation receipt recorded
at
`specs/027-conserved-moiety-equivalence-test/agent-runs/20260915T075337Z-conserved-moiety-equivalence-test/implementation-receipt.md`.

## Diff summary

- `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
  (+25 lines): new comment block, `optionsSibling`/`identifyConservedMoieties` call, and
  four `isequal` assertions, inserted between the existing feature-026 conserved-only
  block and the file's `prepareTest('needsMILP', true)` gate.
- `.specify/feature.json`: updated `feature_directory` pointer to this feature (Spec Kit
  bookkeeping, not toolbox behavior).
- `CLAUDE.md`: updated the plan-pointer line inside the `SPECKIT START`/`SPECKIT END`
  markers to this feature's `plan.md` (Spec Kit bookkeeping).
- `specs/027-conserved-moiety-equivalence-test/` (new directory): `spec.md`, `plan.md`,
  `tasks.md`, `research.md`, `data-model.md`, `quickstart.md`,
  `checklists/requirements.md`.
- No `src/` file was modified. `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m`
  and `src/analysis/topology/conservedMoieties/identifyConservedMoieties.m` were read
  and called but not edited (spec FR-008, confirmed via `git diff --stat`).

## Tests

Ran `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
end-to-end via `matlab -batch` (MATLAB R2024b at `/usr/local/MATLAB/R2024b/bin/matlab`,
COBRA Toolbox initialized with `initCobraToolbox(false)`, Gurobi 1301 licensed as the
active MILP solver). Result: `TEST_PASSED: testConservedReactingMoieties` — every
pre-existing assertion (features 004, 019, 020, 024, 026) passed unmodified, and the
new feature-027 assertions (the sibling call plus four `isequal` checks) passed. Only
pre-existing, unrelated warnings appeared (`Reaction identifier in the rxnfile
rh_14817.rxn does not match file name`, from feature 024's fixture, not touched by this
feature).

Also separately re-verified (prior to test authoring, informing the spec) via an ad hoc
scratch script: `identifyConservedReactingMoieties(subModel, BG, dATM,
conservedMoietiesOnly=true)` vs. `identifyConservedMoieties(subModel, dATM)` on the same
fixture, both with `sanityChecks=0` — `arm.L`, `arm.M2M`, `arm.M2R`, `moietyFormulae` all
`isequal` (dimensions `[2x4]`, `[4x6]`, `[6x3]`, `{'H2O','C6H3O6'}` respectively).

## Unresolved issues

- A pre-existing, out-of-scope defect remains unfixed: calling
  `identifyConservedReactingMoieties(..., conservedMoietiesOnly=true)` with
  `options.sanityChecks = 1` crashes with `Error using identifyIsomorphicClasses ...
  Inconsistent mapping of atoms to connected components`, raised from an unrelated
  bond-subgraph classification path. Spec 027 (FR-009, Edge Cases) explicitly scopes
  this out; this feature's assertions avoid it by using `sanityChecks = 0` on both
  compared calls, matching the file's existing feature-026 conserved-only call. Fixing
  it would require a separate, spec-driven feature.
- The equivalence proven here is fixture-specific (the one 4-metabolite/3-reaction
  Recon3D subnetwork already used by this test file), not validated across arbitrary
  models — consistent with spec 027's stated Assumptions and the narrowest-test
  principle.
