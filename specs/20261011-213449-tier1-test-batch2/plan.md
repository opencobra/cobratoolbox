# Implementation Plan: Tier-1 test coverage batch 2 (50 functions)

**Branch**: `026-tier1-test-batch2` | **Date**: 2026-10-11 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/20261011-213449-tier1-test-batch2/spec.md`

## Summary

Add 50 characterization tests, one per function (III-Naming), each Tier 1 (III-Coverage):
hand-built inputs, no model, no solver, `prepareTest()` opening, 100% line coverage or
documented exemptions. No `src` change. The selection was probed in MATLAB R2025a during
this planning phase ([research.md](research.md)); six functions were demoted and replaced.
Work proceeds in folder groups with a mandatory stop after the first ten tests.

## Technical Context

**Language/Version**: MATLAB R2025a

**Primary Dependencies**: COBRA Toolbox on the path; `verifyCobraFunctionError`; base MATLAB
only (no Statistics, Optimization or other toolbox; `compareTwoSamplesStat` was demoted for
needing one).

**Storage**: N/A. Tests create no files.

**Testing**: script-style `test<Name>.m` run by `test/testAll.m`; each verified through
`runScriptFile` and coverage-measured with `matlab.unittest` `CodeCoveragePlugin`
(Cobertura; `hits` attribute precedes `number`).

**Target Platform**: headless Linux CI and developer machines.

**Project Type**: MATLAB library (test back-fill).

**Performance Goals**: whole batch under 5 minutes; each test target under 1 second.

**Constraints**: very memory efficient; no files written; no persistent or global state left
behind; function console output not suppressed (documented as noise).

**Scale/Scope**: 50 functions, 50 new test files, 5 new test folders.

## Constitution Check

*GATE: passed before research; re-checked after design: still passes.*

- **Scientific code quality**: no formulation, solver or interface touched; `src` read-only.
- **Testing and reproducibility**: Principle III with III-Characterization, III-Coverage
  (Tier 1, `prepareTest()` opening, memory efficiency, readability) and III-Naming apply.
  Check commands are in [quickstart.md](quickstart.md).
- **User experience and diagnostics**: tests are silent except console output printed by
  the function itself (for example `analyzeRxns`, `cleanUpMetabolite_structure`,
  `Combination`), which cannot be suppressed (VII-A) and is documented per test.
- **Performance and numerical integrity**: outputs are discrete or small floating-point
  values; every floating-point comparison uses a tolerance justified in the test.
- **External-solver configuration audit**: N/A, no solver invoked.
- **Spec-driven scope control**: edit only new files under `test/verifiedTests/` plus this
  feature's `specs/` folder; all of `src/` read-only.
- **MATLAB coding standards**: no `evalc`, warnings visible (expected warnings are
  documented, not silenced), try/catch only via `verifyCobraFunctionError`, no `nargin` use.
- **Parameter-setting fidelity**: N/A.
- **Artifact placement**: tests beside sibling tests; five new test folders for domains
  without one (listed below); no data files, no generated output.

## Project Structure

### Documentation (this feature)

```text
specs/20261011-213449-tier1-test-batch2/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── tasks.md          # created by /speckit-tasks
```

No `contracts/`: the feature exposes no external interface.

### Source Code (repository root)

The 50 test files and their folders are the amended selection table in
[spec.md](spec.md) (single source; not repeated here). Folder summary:

```text
test/verifiedTests/
├── analysis/    testExploration  testPersephone*  testRumba*  testSubspaces  testThermo
│                testTopology  testWholeBody*
├── base/        testCardOpt  testIO/testUtilities  testSolvers  testTools
├── dataIntegration/  testChemoInformatics  testFitC13Data  testMetaboAnnotator*
├── design/
├── reconstruction/   testDemeter*  testModelBorgifier  testModelManipulation
└── visualization/    testReconMap
(* = new folder)
```

**Structure Decision**: follow sibling convention; create a folder only where no existing one
fits the source domain.

## Phasing

1. Checkpoint 1: first ten rows of the table (analysis/ groups), then STOP for review.
2. Remaining forty rows, one phase per source-folder group.
3. Batch verification, receipt, stop.

## Complexity Tracking

No constitution violations; nothing to justify.
