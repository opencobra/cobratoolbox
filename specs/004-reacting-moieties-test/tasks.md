# Tasks: Repurpose reacting-moieties tutorial as a test

**Input**: spec.md, plan.md. **Tests**: this feature IS a test; validated by running it.

## Implementation status (2026-07-13) — DONE

All tasks complete. T001 (workflow run: needs MILP; reference values captured), T002
(rxnFiles fixture copied), T003/T004 (test written with genuine assertions incl. L*N=0),
T005 (passes fast 13.3s / full 7.3s; 0 figure windows), T006 (checkcode clean bar the
by-design global warning; receipt written; tutorialDerived staging committed). Deviation:
`.gitignore` `analysis/`→`/analysis/` (see receipt).

## Phase 1: Prep (read-only during implementation)

- [ ] T001 Run the tutorial workflow on the 3-reaction subnetwork in a scratch context to determine (a) the true `prepareTest` requirement (does the minimum-set-cover step need an LP solver, or none?), (b) how `buildAtomAndBondTransitionMultigraph` resolves the atom-mapped `rxnFiles`, and (c) which `rxnFiles` the 3 reactions {r0317, ACONTm, r0426} actually need — so a minimal fixture can be copied.
- [ ] T002 Copy the minimal `rxnFiles` needed by the subnetwork from `tutorials/analysis/reactingMoieties/data/rxnFiles` into `test/verifiedTests/analysis/testReactingMoieties/data/rxnFiles/` (so the test does not depend on the tutorials submodule being initialised).

## Phase 2: Test (US1)

- [ ] T003 [US1] Write `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`: openCOBRA test header; `prepareTest(...)` per T001; `onCleanup` that restores `DefaultFigureVisible`; set figures invisible; load `Recon3D_301.mat` and extract `{r0317, ACONTm, r0426}`; build the atom/bond transition multigraph; identify conserved & reacting moieties; build reacting-moiety tables; construct moiety graphs — invoking all seven target functions.
- [ ] T004 [US1] Add genuine assertions: `norm(full(arm.L) * full(subModel.S))` within tol of 0; rank/nullity of the subnetwork; non-emptiness/fields of `dATM`, `BG`, `arm.L`, `reacting.selectedReactionNames`, `moietyGraph`; and order-independent checks on the selected reacting reactions and formed/broken bond-table row counts. Capture the exact expected values from a real run (store literals, or a small `refData_reactingMoieties.mat` beside the test if a matrix is needed).

## Phase 3: Verify & polish

- [ ] T005 Run the test via `runScriptFile`/`run_matlab_test_file` in BOTH fast and full modes; confirm it passes (or skips cleanly if a dep is absent), opens no figure window, and restores figure visibility. Confirm it exercises all seven functions.
- [ ] T006 `check_matlab_code` on the new test (resolve any new warnings); commit the `test/tutorialDerived/` analysis staging as feature research; record the 5 tutorial-repair follow-ups in the feature dir; write the implementation receipt under `agent-runs/`.

## Accounted-for outcomes

- The 7 untested functions become covered by one new test asserting `L*N=0` + structure.
- Deferred (documented follow-ups, out of scope): vonBertalanffy python2/ChemAxon,
  MetaboRePort write-path, visualiseConservedMoieties missing helper,
  atomicallyResolve expected-data, metabotoolsI slow sampling.
