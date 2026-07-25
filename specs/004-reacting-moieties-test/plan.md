# Implementation Plan: Repurpose reacting-moieties tutorial as a test

**Branch**: `004-reacting-moieties-test` | **Date**: 2026-07-13 | **Spec**: [spec.md](./spec.md)

## Summary

Add one new test under `test/verifiedTests/` that reproduces the verified-working
`tutorial_conservedAndReactingMoieties` workflow on a small deterministic Recon3D
subnetwork, exercising seven currently-untested moiety functions and asserting the
`L*N = 0` conservation invariant plus stable structural facts. Figures are generated
invisibly. No `src/` change.

## Technical Context

**Language/Version**: MATLAB (R2020a+ per tutorial; harness R2014b+).
**Primary Dependencies**: `extractSubNetwork`, `buildAtomAndBondTransitionMultigraph`,
`identifyConservedReactingMoieties`, `identifyConservedReactingSubgraphs`,
`buildReactingMoietyTables`, `displayReactingMoieties`, `createMoietyGraph`,
`getMetMoietySubgraphs`; `Recon3D_301.mat` (present in `test/models/mat`); the
atom-mapped `rxnFiles` shipped with the tutorial.
**Testing**: the new test itself; run via `runScriptFile` / `run_matlab_test_file`.
**Target Platform**: Linux/CI; both fast and full modes (002).
**Performance Goals**: fast — the subnetwork ran in ~17s as a tutorial; aim similar/less.
**Constraints**: no `src`/interface/result change (FR-006); genuine assertions incl.
`L*N=0` (FR-002/003); figures invisible + restored (FR-004); clean skip when a dep is
absent (FR-005); MATLAB standards (warnings visible, propagate stacks, no evalc-suppress,
no nargin).
**Scale/Scope**: one test file (+ optional small refData .mat + minimal rxnFiles fixture).

## Constitution Check

- **Scientific code quality**: asserts a real mathematical invariant (`L*N = 0`) of the
  conserved-moiety decomposition; no model math or interface changed.
- **Testing and reproducibility**: narrowest check = the new test run via the harness in
  both modes; exact expected values captured from a real run and stored (refData), not
  loosened. Coverage of the 7 functions confirmed by the test invoking them.
- **UX/diagnostics**: figures generated invisibly; a missing dependency → clean skip.
- **Performance/numerical integrity**: no verification step removed; `L*N=0` tolerance is
  tight and justified.
- **External-solver config audit**: determine in T001 whether the minimum-set-cover step
  needs an LP solver; if so declare it via prepareTest (using the class default), change
  no solver settings. Likely no commercial dep (the tutorial ran locally without one).
- **Spec-driven scope control**: ADD `test/verifiedTests/analysis/testReactingMoieties/`
  (new test + optional refData + minimal rxnFiles). Read-only: all `src/` functions under
  test, the tutorial submodule. Also commit the `test/tutorialDerived/` analysis staging
  (research) as part of this feature.
- **MATLAB standards**: header/help per openCOBRA test template; assert-with-tolerance;
  restore figure-visibility in an onCleanup/try-finally so state never leaks.
- **Parameter-setting fidelity**: N/A.
- **Artifact placement**: test + fixtures beside the test under `verifiedTests/`; the
  `tutorialDerived/` staging is analysis output committed as feature research.

## Project Structure

```text
test/verifiedTests/analysis/testReactingMoieties/
├── testConservedReactingMoieties.m     # NEW: the test
├── refData_reactingMoieties.mat        # NEW (if exact expected values are stored)
└── data/rxnFiles/                      # NEW: minimal atom-mapped fixture (or reference the tutorial's)
test/tutorialDerived/                   # analysis staging (committed as research)
specs/004-reacting-moieties-test/       # spec docs
```

**Structure Decision**: New `testReactingMoieties` folder (the existing `testMoieties`
covers older functions). Fixtures live beside the test so it does not depend on an
un-initialised submodule path.

## Complexity Tracking

No constitution violations. (Single additive test; figures invisible; genuine assertions.)
