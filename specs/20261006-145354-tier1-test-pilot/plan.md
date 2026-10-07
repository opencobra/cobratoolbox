# Implementation Plan: Tier-1 test coverage pilot (5 functions)

**Branch**: `025-tier1-test-pilot` | **Date**: 2026-10-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/20261006-145354-tier1-test-pilot/spec.md`

## Summary

Add five characterization tests, one per function (III-Naming), each declared Tier 1
(III-Coverage): no model, no solver, hand-built inputs, 100% line coverage with
documented exemptions, human-friendly headers and `%%` sections. No `src` file changes.
Expected values come from reading the source and from a MATLAB R2025a probe of current
behaviour (see [research.md](research.md)). The pilot ends with a user-validation pause.

## Technical Context

**Language/Version**: MATLAB R2025a (installed at `/usr/local/bin/matlab`)

**Primary Dependencies**: COBRA Toolbox on the path; `verifyCobraFunctionError` for
expected-error paths. No solver, no `prepareTest` requirement.

**Storage**: N/A. Tests create no files.

**Testing**: COBRA script-style tests (`test<Name>.m`) discovered by `test/testAll.m`;
coverage measured per function with `matlab.unittest` `CodeCoveragePlugin` (CI uses
MoCov).

**Target Platform**: Headless Linux CI and developer machines.

**Project Type**: MATLAB library (test back-fill).

**Performance Goals**: Each test under 5 seconds (target: well under 1 second).

**Constraints**: Very memory efficient (small literals, no large models, nothing left in
the workspace); no console output beyond what the function itself emits (documented).

**Scale/Scope**: 5 functions, 5 new test files.

## Constitution Check

*GATE: passed before Phase 0; re-checked after Phase 1 design: still passes.*

- **Scientific code quality**: No formulation/solver/interface touched. Read-only on `src`.
- **Testing and reproducibility**: Principle III + III-Characterization + III-Coverage +
  III-Naming apply. Narrowest tests: the five files below. Check command in
  [quickstart.md](quickstart.md).
- **User experience and diagnostics**: Tests are silent except `extendIndicesInDimenion`'s
  own catch-block output, which cannot be suppressed (VII-A forbids `evalc`) and is
  documented as a console-noise exemption.
- **Performance and numerical integrity**: Discrete values and NaN only; no tolerances
  needed. No solver, no speed-motivated skipping.
- **External-solver configuration audit**: N/A, no external solver invoked.
- **Spec-driven scope control**: Edit only new files under `test/verifiedTests/`. Read-only:
  all of `src/`. No new dependency or abstraction.
- **MATLAB coding standards**: No `evalc`, warnings visible, no `nargin` use, `try/catch`
  only inside `verifyCobraFunctionError`-style checks. MATLAB test-writing practice
  followed per the constitution's VII-F skill-discovery note (consulted at implement time).
- **Parameter-setting fidelity**: N/A, nothing ported or rendered.
- **Artifact placement**: Test files live beside related tests in `test/verifiedTests/`;
  no data files, no generated output; no file placement changes.

## Project Structure

### Documentation (this feature)

```text
specs/20261006-145354-tier1-test-pilot/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── tasks.md          # created by /speckit-tasks
```

No `contracts/`: the feature exposes no external interface.

### Source Code (repository root)

```text
test/verifiedTests/
├── base/testTools/
│   ├── testGetDefaultValue.m             # new  <- src/base/utilities/getDefaultValue.m
│   └── testExtendIndicesInDimenion.m     # new  <- src/base/utilities/extendIndicesInDimenion.m
└── reconstruction/
    ├── testModelManipulation/
    │   ├── testGetIDPositions.m          # new  <- src/reconstruction/refinement/getIDPositions.m
    │   └── testGetMetAbbr.m              # new  <- src/reconstruction/refinement/getMetAbbr.m
    └── testModelGeneration/
        └── testVerifyRuleSyntax.m        # new  <- .../modelVerification/verifyRuleSyntax.m
```

**Structure Decision**: Utilities tests sit with the existing `base/testTools` tests of
sibling `src/base/utilities` functions (for example `testSplitString`). `getIDPositions` and
`getMetAbbr` (model/metabolite helpers) go with `testModelManipulation`; `verifyRuleSyntax`
sits next to `testVerifyModel.m` in `testModelGeneration`.

## Complexity Tracking

No constitution violations; nothing to justify.
